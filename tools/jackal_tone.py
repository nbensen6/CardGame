"""Measure the fight's per-channel tone curve on the drawn jackal against
TARGET and fold its inverse into tools/jackal_tone_fix.json (read by
beast_rig.py tone_fix). Run from the repo root on a rest shot:

    python3 tools/jackal_tone.py <shot.png>

then fade the table to identity above 40 (only the crushed darks need it).
"""
import sys, json
from PIL import Image
import numpy as np
from scipy import ndimage as ndi
sys.path.insert(0,'tools')
import beast_rig as b
shot=sys.argv[1]
g=np.asarray(Image.open(shot).convert('RGB'))[:,280:1000].astype(float)
T1=np.asarray(Image.open(b.TARGET).convert('RGB')).astype(float)
m,_,_=b.silhouette(T1)
m=ndi.binary_erosion(m,iterations=12)
m[350:]=False   # stones and below
m720=np.asarray(Image.fromarray((m*255).astype(np.uint8)).resize((720,720),Image.NEAREST))>0
t=np.asarray(Image.open(b.TARGET).convert('RGB').resize((720,720),Image.LANCZOS)).astype(float)
T,G=t[m720],g[m720]
try: old=json.load(open('tools/jackal_tone_fix.json'))['lut']
except Exception: old=[list(range(256))]*3
new=[]
for k in range(3):
    xs=np.arange(0,256,4); fx=[];fy=[]
    for x in xs:
        mk=np.abs(T[:,k]-x)<3
        if mk.sum()>40: fx.append(x); fy.append(G[mk,k].mean())
    fx,fy=np.array(fx,float),np.maximum.accumulate(np.array(fy,float))
    # out = f(in_effective); in_effective = old[want]. We want f(old'[w]) = w.
    # Game response as a function of what TARGET asked: resp(w)=fy. Correct
    # the asked value by the error: old'[w] = old[w] + (w - resp(w)) * 0.8
    resp=np.interp(np.arange(256),fx,fy)
    err=np.arange(256)-resp
    lut=np.clip(np.array(old[k],float)+0.8*err,0,255)
    lut=np.maximum.accumulate(lut)
    new.append([round(v,2) for v in lut])
    print('ch',k,'resp@',[ (int(a),round(b,1)) for a,b in zip(fx[:8],fy[:8])])
json.dump({'note':'per-channel tone fix for the drawn jackal, from tone.py','lut':new},open('tools/jackal_tone_fix.json','w'))
