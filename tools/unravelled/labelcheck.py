import os
import re,collections,sys
from parse import *
SHORT={0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,0x8D}
def target(x):
    b=[int(v,16) for v in x['bytes']]; a=int(x['addr'],16); op=x['op']
    if op=='FDB' and len(b)==2 and ',' not in x['arg']: return (b[0]<<8)|b[1]
    if not b: return None
    if b[0] in SHORT and len(b)==2: r=b[1]-256 if b[1]>127 else b[1]; return (a+2+r)&0xFFFF
    if b[0] in (0x16,0x17) and len(b)==3: r=(b[1]<<8)|b[2]; r-=65536 if r>32767 else 0; return (a+3+r)&0xFFFF
    if b[0]==0x10 and len(b)==4 and 0x21<=b[1]<=0x2F: r=(b[2]<<8)|b[3]; r-=65536 if r>32767 else 0; return (a+4+r)&0xFFFF
    if b[0] in (0xBD,0x7E) and len(b)==3: return (b[1]<<8)|b[2]
    return None
def check(sheets):
    # defs from all listings (labels may be defined in another ROM)
    defs=collections.defaultdict(set); rows_by={}
    for sh in sheets:
        R=rows(sh); rows_by[sh]=R
        for x in R:
            if x['label'] and not x['label'].startswith('*') and x['addr'] and x['op'] not in('EQU',):
                defs[x['label']].add((sh,int(x['addr'],16)))
    evidence=collections.defaultdict(collections.Counter)
    for sh,R in rows_by.items():
        for x in R:
            arg=x['arg'].lstrip('<>')
            if not x['bytes'] or not re.fullmatch(r'[A-Z][A-Z0-9$]*',arg): continue
            tg=target(x)
            if tg is None: continue
            evidence[arg][tg]+=1
    return defs,evidence
