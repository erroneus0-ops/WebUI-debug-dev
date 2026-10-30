import xlrd, re, os
XLS=os.environ.get('UNRAV_XLS','../Exploring-6809-Assembly/documentation/reference/Unravelled II.xls')
ROMDIR=os.environ.get('UNRAV_ROMS','coco_roms')
ROMS={'CB 1.2':(ROMDIR+'/bas12.rom',0xA000),
      'ECB 1.1':(ROMDIR+'/extbas11.rom',0x8000),
      'DECB 1.0':(ROMDIR+'/disk10.rom',0xC000),
      'DECB 1.1':(ROMDIR+'/disk11.rom',0xC000),
      'SECB':(ROMDIR+'/supbas20.rom',0xC000)}
def t(v):
    if isinstance(v,float): return str(int(v)) if v==int(v) else str(v)
    return str(v).replace('\u2019',"'").replace('\u2018',"'").replace('\u201c','"').replace('\u201d','"').rstrip()
_book=None
def book():
    global _book
    if _book is None: _book=xlrd.open_workbook(XLS)
    return _book
def rows(name):
    s=book().sheet_by_name(name); out=[]
    for r in range(s.nrows):
        c=[t(s.cell_value(r,i)) for i in range(min(13,s.ncols))]+['']*13
        if not any(c[:13]): continue
        out.append(dict(xrow=r+1,line=c[0],force=c[1],addr=c[2].upper(),
            bytes=[x.upper().zfill(2) for x in c[3:9] if x],label=c[9],op=c[10],arg=c[11],cmt=c[12]))
    return out
