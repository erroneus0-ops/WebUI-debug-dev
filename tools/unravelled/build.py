import os
import json
import shutil; import os; shutil.rmtree(os.environ.get('UNRAV_OUT','out/unravelled'),ignore_errors=True)
import re, os, hashlib, collections
from parse import *
OUT=os.environ.get('UNRAV_OUT','out/unravelled')
LISTINGS=[('CB 1.2','cb-1.2','cb','Color BASIC 1.2'),('ECB 1.1','ecb-1.1','ecb','Extended Color BASIC 1.1'),
          ('DECB 1.1','decb-1.1','decb11','Disk Extended Color BASIC 1.1'),('DECB 1.0','decb-1.0','decb10','Disk Extended Color BASIC 1.0'),
          ('SECB','secb','secb','Super Extended Color BASIC 2.0 (CoCo 3)')]
LOCAL=re.compile(r'^L[0-9A-F]{4}$')
MAXLINES=260; MINLINES=60
corrections=collections.defaultdict(list)

def fmt(x):
    lab=x['label']; op=x['op']; arg=x['arg']; cmt=x['cmt']
    if lab.startswith('*') and not op:      # comment line
        return (lab+(' '+cmt if cmt else '')).rstrip()
    if not (x['addr'] or x['bytes'] or lab or op or arg):
        return ('; '+cmt) if cmt else ''
    if x['force']=='>' and arg: arg='>'+arg
    by=' '.join(x['bytes'])
    s=f"{x['addr']:<4}  {by:<17} {lab:<8} {op:<5} {arg}"
    if cmt: s=f"{s:<58} ; {cmt}" if len(s)<58 else f"{s} ; {cmt}"
    return s.rstrip()

def fix_bytes(name,R):
    rp,base=ROMS[name]; rom=open(rp,'rb').read()
    for x in R:
        if not x['bytes'] or not x['addr'] or x['op'] in('EQU','RMB','ORG'): continue
        a=int(x['addr'],16)-base; act=[f'{b:02X}' for b in rom[a:a+len(x['bytes'])]]
        if act!=x['bytes']:
            corrections[name].append((x['addr'],' '.join(x['bytes']),' '.join(act),x['label'],x['op'],x['arg']))
            note=f"[bytes corrected to match genuine ROM; spreadsheet had {' '.join(x['bytes'])}]"
            x['cmt']=(x['cmt']+' '+note).strip(); x['bytes']=act
    return hashlib.sha1(rom).hexdigest(), base, len(rom)

def is_named(x): return x['label'] and not x['label'].startswith('*') and not LOCAL.match(x['label']) and x['op']!='EQU'

def chunk(R):
    # candidate break points: start of a comment block or blank line immediately preceding a named label, or the named label itself
    breaks=set()
    for i,x in enumerate(R):
        if is_named(x):
            j=i
            while j>0 and (R[j-1]['label'].startswith('*') and not R[j-1]['op'] or fmt(R[j-1])==''): j-=1
            breaks.add(j)
    chunks=[];cur=0;i=0
    bl=sorted(breaks)
    start=0
    while start<len(R):
        # furthest break <= start+MAXLINES and >= start+MINLINES
        cands=[b for b in bl if start+MINLINES<=b<=start+MAXLINES]
        if start+MAXLINES>=len(R): end=len(R)
        elif cands: end=cands[-1]
        else:
            # fallback: any blank/comment boundary
            end=start+MAXLINES
            for k in range(start+MAXLINES,start+MINLINES,-1):
                if fmt(R[k])=='' : end=k;break
        chunks.append((start,end)); start=end
    return chunks

def addr_span(rows):
    a=[int(x['addr'],16) for x in rows if x['addr'] and x['op'] not in('EQU',) and re.fullmatch('[0-9A-F]{4}',x['addr'])]
    if not a: return None,None
    last=[x for x in rows if x['addr'] and x['op']!='EQU' and re.fullmatch('[0-9A-F]{4}',x['addr'])][-1]
    end=int(last['addr'],16)+max(len(last['bytes']),1)-1
    return min(a),end

symbols=[]   # (name, addr, rom, kind, file)
os.makedirs(OUT,exist_ok=True)
summary=[]
import labelcheck
ALL={}; META={}
for sheet,dirn,pfx,title in LISTINGS:
    ALL[sheet]=rows(sheet); META[sheet]=fix_bytes(sheet,ALL[sheet])
# --- move labels whose position contradicts the ROM-encoded targets of branches/JSRs/vectors ---
label_moves=[]; label_stats=collections.Counter()
for ss in [['CB 1.2','ECB 1.1','DECB 1.1'],['CB 1.2','ECB 1.1','DECB 1.0'],['CB 1.2','ECB 1.1','SECB']]:
    defs=collections.defaultdict(list); ev=collections.defaultdict(collections.Counter)
    for sh in ss:
        for x in ALL[sh]:
            if x['label'] and not x['label'].startswith('*') and x['addr'] and x['op']!='EQU': defs[x['label']].append((sh,x))
    for sh in ss:
        for x in ALL[sh]:
            arg=x['arg'].lstrip('<>')
            if x['bytes'] and re.fullmatch(r'[A-Z][A-Z0-9$]*',arg):
                tg=labelcheck.target(x)
                if tg is not None: ev[arg][tg]+=1
    for lab,cnt in ev.items():
        if lab not in defs: continue
        for sh,x in defs[lab]:
            label_stats[(lab,sh)]=1
        addrs={int(x['addr'],16) for _,x in defs[lab]}
        bad=[tg for tg in cnt if tg not in addrs]
        if len(cnt)==1 and bad and len(defs[lab])==1:
            sh,x=defs[lab][0]; tg=bad[0]
            dest=[y for y in ALL[sh] if y['addr'] and y['op']!='EQU' and int(y['addr'],16)==tg and y['bytes']]
            if len(dest)==1 and not dest[0]['label']:
                d=dest[0]; d['label']=lab; x['label']=''
                d['cmt']=(d['cmt']+f' [label {lab} moved here from ${x["addr"]}: the ROM bytes of the code that references it point here]').strip()
                label_moves.append((sh,lab,x['addr'],f'{tg:04X}'))
print('labels verified against code references:',len(label_stats),'moved:',label_moves)
for sheet,dirn,pfx,title in LISTINGS:
    R=ALL[sheet]; sha,base,size=META[sheet]
    d=f'{OUT}/{dirn}'; os.makedirs(d,exist_ok=True)
    idx=[]
    for s,e in chunk(R):
        part=R[s:e]; lo,hi=addr_span(part)
        fn=f'{pfx}_{lo:04X}-{hi:04X}.asm'
        named=[(x['label'],x['addr']) for x in part if is_named(x)]
        hdr=[f'; {title} -- ${lo:04X}-${hi:04X}',
             f'; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "{sheet}"',
             f'; Object bytes verified against genuine ROM image (SHA-1 {sha}). See ../README.md for line format.',
             '; Named entry points here: '+(', '.join(f'{n}=${a}' for n,a in named) if named else '(none -- local labels only)'),'']
        body=[fmt(x) for x in part]
        while body and body[0]=='': body.pop(0)
        open(f'{d}/{fn}','w').write('\n'.join(hdr+body).rstrip()+'\n')
        idx.append((fn,lo,hi,len(body),named))
        for x in part:
            if x['label'] and not x['label'].startswith('*') and x['addr']:
                kind='equ' if x['op']=='EQU' else ('rmb' if x['op']=='RMB' else ('entry' if not LOCAL.match(x['label']) else 'local'))
                symbols.append((x['label'],x['addr'],dirn,kind,f'{dirn}/{fn}'))
    with open(f'{d}/INDEX.md','w') as f:
        f.write(f'# {title} -- listing index\n\nROM image: ${base:04X}-${base+size-1:04X}, SHA-1 `{sha}`.\n')
        f.write(f'Chunks are split only at named-label boundaries (a routine is never cut mid-way), ~{MAXLINES} lines max.\n')
        f.write('To find an address: pick the chunk whose range contains it. To find a label: `grep` ../SYMBOLS.txt.\n\n')
        f.write('| File | Range | Named entry points |\n|---|---|---|\n')
        for fn,lo,hi,n,named in idx:
            f.write(f'| {fn} | ${lo:04X}-${hi:04X} | {", ".join(nm for nm,_ in named) or "-"} |\n')
    summary.append((sheet,dirn,len(idx),len(R)))

# ---------- memory maps (listing-format EQU/RMB tabs) ----------
def mm_rows(name):
    s=book().sheet_by_name(name); out=[]
    for r in range(s.nrows):
        c=[t(s.cell_value(r,i)) for i in range(s.ncols)]+['']*12
        if not any(c[:12]): continue
        # layout: 0 line | 1 RAM/code address | 2 EQU value or object bytes | 3 label | 4 op | 5 operand | 6+ comment
        op=c[4]; isequ=(op=='EQU')
        addr=(c[2] if isequ else c[1]).upper()
        by=[] if isequ else [b.zfill(2) for b in c[2].upper().split()]
        out.append(dict(line=c[0],force='',addr=addr,bytes=by,label=c[3],op=op,arg=c[5],cmt=' '.join(v for v in c[6:12] if v)))
    return out
for sheet,fn,title in [('Memory Map CB','memory-map-cb.asm','Color BASIC'),('Memory Map ECB','memory-map-ecb.asm','Extended Color BASIC'),
                       ('Memory Map SECB','memory-map-secb.asm','Super Extended Color BASIC'),('Memory Map DECB','memory-map-decb.asm','Disk Extended Color BASIC')]:
    R=mm_rows(sheet)
    lines=[f'; {title} memory map: constants (EQU) and RAM variables (RMB), incl. direct page.',
           f'; Source: Unravelled II.xls tab "{sheet}". First column = RAM address (RMB/code) or the constant VALUE (EQU).',
           '; 6809 is big-endian:',
           '; a 2-byte variable at $nn holds its high byte at $nn and low byte at $nn+1.','']
    lines+= [fmt(x) for x in R]
    open(f'{OUT}/{fn}','w').write('\n'.join(lines).rstrip()+'\n')
    tag=fn.replace('memory-map-','').replace('.asm','')
    for x in R:
        if x['label'] and not x['label'].startswith('*') and x['addr'] and re.fullmatch('[0-9A-F]{1,4}',x['addr']):
            k={'EQU':'equ','RMB':'rmb'}.get(x['op'],'code')
            symbols.append((x['label'],x['addr'].zfill(4),'map-'+tag,k,fn))

# ---------- routine tabs -> one entry per line ----------
def routines(sheet):
    s=book().sheet_by_name(sheet); grid=[[t(s.cell_value(r,i)) for i in range(s.ncols)] for r in range(s.nrows)]
    hdr=None
    for r,row in enumerate(grid):
        if any('DESCRIPTION' in v for v in row): hdr=r;break
    intro=[' '.join(v for v in row if v) for row in grid[:hdr-1] if any(row)] if hdr is not None else []
    ents=[]; cur=None
    if hdr is None: return intro,ents
    H=grid[hdr]; dcol=[i for i,v in enumerate(H) if 'DESCRIPTION' in v][0]
    keycols=[i for i in range(dcol) if any(grid[r][i] for r in range(hdr+1,len(grid)))]
    for row in grid[hdr+1:]:
        if not any(row): cur=None; continue
        keys=[row[i] for i in keycols]; desc=' '.join(v for v in row[dcol:] if v)
        if cur is None:
            cur={'keys':keys,'desc':desc}; ents.append(cur)
        else:
            for k,i in zip(keys,range(len(keys))):
                if k: cur['keys'][i]=(cur['keys'][i]+' '+k).strip()
            cur['desc']=(cur['desc']+' '+desc).strip()
    hnames=[(grid[hdr-1][i]+' '+H[i]).strip() if hdr>0 else H[i] for i in keycols]
    return intro,ents,hnames
for sheet,fn in [('Routines CB','routines-cb.txt'),('Routines ECB','routines-ecb.txt'),('Routines SECB','routines-secb.txt'),
                 ('Routines DECB','routines-decb.txt'),('Floating Point Routines CB','floating-point-routines-cb.txt')]:
    res=routines(sheet); intro,ents=res[0],res[1]; hn=res[2] if len(res)>2 else []
    L=[f'# {sheet} -- one routine per line (from Unravelled II.xls). Fields: '+' | '.join(hn)+' | DESCRIPTION','']
    if intro: L+=['# '+x for x in intro]+['']
    for e in ents: L.append(' | '.join(k or '-' for k in e['keys'])+' | '+e['desc'])
    open(f'{OUT}/{fn}','w').write('\n'.join(L)+'\n')
    print(sheet,len(ents),'entries')

# ---------- everything else: faithful aligned text ----------
def aligned(sheet):
    s=book().sheet_by_name(sheet); grid=[[t(s.cell_value(r,i)) for i in range(s.ncols)] for r in range(s.nrows)]
    while grid and not any(grid[-1]): grid.pop()
    ncol=max((max([i for i,v in enumerate(r) if v],default=-1) for r in grid),default=-1)+1
    # prose rows: a single long cell -> print as-is; tabular rows -> align
    w=[0]*ncol
    for r in grid:
        filled=[i for i,v in enumerate(r) if v]
        if len(filled)>1:
            for i in filled[:-1]:            # last cell in a row may overflow freely
                w[i]=max(w[i],len(r[i]))
            w[filled[-1]]=max(w[filled[-1]],1)
    out=[];blank=0
    for r in grid:
        filled=[i for i,v in enumerate(r) if v]
        if not filled: 
            if out and out[-1]!='': out.append('')
            continue
        if len(filled)==1: out.append(r[filled[0]]); continue
        line=''
        for i in range(ncol):
            if w[i]==0: continue
            line+=f'{r[i]:<{w[i]}}  '
        out.append(line.rstrip())
    return out
OTHER=[('Data Tables CB','data-tables-cb.txt'),('Data Tables ECB','data-tables-ecb.txt'),('Data Tables SECB','data-tables-secb.txt'),('Data Tables DECB','data-tables-decb.txt'),
       ('Differences CB 1.0','differences-cb-1.0.txt'),('Differences CB 1.1','differences-cb-1.1.txt'),('Differences ECB','differences-ecb.txt'),('DIFFERENCES SECB','differences-secb.txt'),
       ('Error Entry ECB','error-entry-ecb.txt'),('Error Entry DECB','error-entry-decb.txt'),('ROM Routines SECB','rom-routines-secb.txt'),
       ('GIME Chip','gime-chip.txt'),('CoCo 3 Colors','coco3-colors.txt'),('CHARSET','charset-coco3.txt'),
       ('Ascii Chart CB','ascii-chart-cb.txt'),('Ascii Chart ECB','ascii-chart-ecb.txt'),('Ascii Chart DECB','ascii-chart-decb.txt')]
os.makedirs(f'{OUT}/tables',exist_ok=True)
for sheet,fn in OTHER:
    open(f'{OUT}/tables/{fn}','w').write(f'# Unravelled II.xls tab "{sheet}"\n\n'+'\n'.join(aligned(sheet)).rstrip()+'\n')

# ---------- symbols ----------
grp=collections.OrderedDict()
for n,a,w,k,fl in symbols:
    grp.setdefault((n,a,k),[]).append(fl)
names={n for (n,a,k) in grp}
symtab_conflicts=[]
for st in ['Symbols ECB 1.1','Symbols SECB','Symbols DECB 1.1','Symbols DECB 1.0']:
    sh=book().sheet_by_name(st)
    for r in range(sh.nrows):
        v=[t(sh.cell_value(r,i)) for i in range(sh.ncols)]
        for i in range(0,len(v)-1,3):
            if v[i] and v[i+1]:
                n=v[i]; a=v[i+1].split('.')[0].upper().zfill(4)
                if n not in names: grp.setdefault((n,a,'xref'),[]).append('symtab:'+st.replace('Symbols ','').replace(' ',''))
                elif not any(k[0]==n and k[1]==a for k in grp): symtab_conflicts.append((st,n,a,sorted({k[1] for k in grp if k[0]==n})))
S=sorted(grp.items(),key=lambda kv:(kv[0][0],kv[0][1]))
with open(f'{OUT}/SYMBOLS.txt','w') as f:
    f.write('# Every label defined in the Unravelled listings and memory maps, one per line:\n')
    f.write('#   NAME  ADDR  KIND  FILE(S) where it is defined (relative to this folder)\n')
    f.write('# KIND: entry = named ROM routine/data; local = Lxxxx label; code = code in RAM (e.g. GETNCH);\n')
    f.write('#       xref = only in an Unravelled symbol-table tab (FILE shows symtab:<tab>) (usually a label in another ROM\'s listing that the\n#              listing itself leaves unlabelled); rmb = RAM variable (ADDR is its address); equ = constant (ADDR column is the VALUE).\n')
    f.write('# Spaces inside a name are shown as _ (e.g. BLOCK_6.0 is "BLOCK 6.0" in the source).\n')
    f.write('# A name can appear more than once if it differs between ROM versions (e.g. DECB 1.0 vs 1.1).\n')
    f.write('# Usage: grep -w DATPTR SYMBOLS.txt    or    grep " A01F " SYMBOLS.txt\n')
    for (n,a,k),fl in S: n=n.replace(' ','_'); f.write(f'{n:<10} {a:<5} {k:<6} {",".join(dict.fromkeys(fl))}\n')
S=[1]*len(S)
json.dump({'moves':label_moves,'verified':len(label_stats)},open(os.path.join(os.environ.get('UNRAV_WORK','.'),'labelmoves.json'),'w'))
import json; json.dump(symtab_conflicts,open(os.path.join(os.environ.get('UNRAV_WORK','.'),'symconflicts.json'),'w'),indent=1)
print(summary); print('symbols',len(S))
for k,v in corrections.items(): print('CORRECTED',k,len(v))
import json; json.dump(dict(corrections),open(os.path.join(os.environ.get('UNRAV_WORK','.'),'corrections.json'),'w'),indent=1)
# ---- post-fix audit: any remaining disagreements between labels and ROM-encoded references ----
remaining=[]
for ss in [['CB 1.2','ECB 1.1','DECB 1.1'],['CB 1.2','ECB 1.1','DECB 1.0'],['CB 1.2','ECB 1.1','SECB']]:
    defs=collections.defaultdict(set); ev=collections.defaultdict(collections.Counter)
    for sh in ss:
        for x in ALL[sh]:
            if x['label'] and not x['label'].startswith('*') and x['addr'] and x['op']!='EQU': defs[x['label']].add(int(x['addr'],16))
    for sh in ss:
        for x in ALL[sh]:
            arg=x['arg'].lstrip('<>')
            if x['bytes'] and re.fullmatch(r'[A-Z][A-Z0-9$]*',arg):
                tg=labelcheck.target(x)
                if tg is not None and arg in defs and tg not in defs[arg]: remaining.append((ss[-1],arg,x['addr'],f'{tg:04X}',sorted(f'{a:04X}' for a in defs[arg])))
print('remaining label/reference disagreements:',remaining)
