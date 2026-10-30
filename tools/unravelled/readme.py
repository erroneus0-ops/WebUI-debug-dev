import os
import json
corr=json.load(open(os.path.join(os.environ.get('UNRAV_WORK','.'),'corrections.json')))['DECB 1.0']
conf=json.load(open(os.path.join(os.environ.get('UNRAV_WORK','.'),'symconflicts.json')))
lm=json.load(open(os.path.join(os.environ.get('UNRAV_WORK','.'),'labelmoves.json')))
rows='\n'.join(f'| ${a} | {o} | {n} | `{op} {arg}` |' for a,o,n,l,op,arg in corr)
mrows='\n'.join(f'| {sh} | {lab} | ${a} | ${b} |' for sh,lab,a,b in lm['moves'])
crows='\n'.join(f'| {n} | {st} | ${a} | {", ".join("$"+x for x in L)} |' for st,n,a,L in conf)
txt=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'README.template.md')).read()
txt=txt.replace('{ROWS}',rows).replace('{MROWS}',mrows).replace('{CROWS}',crows).replace('{NVER}',f"{lm['verified']:,}")
open(os.path.join(os.environ.get('UNRAV_OUT','out/unravelled'),'README.md'),'w').write(txt)
