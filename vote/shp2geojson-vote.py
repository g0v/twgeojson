#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding=utf-8
import os,sys,re,glob,json
import gdal,ogr,json

if len(sys.argv)<3:
  print("usage: shp2votetopojson.py infile.shp out.topojson")
  sys.exit(-1)

infile,outfile = sys.argv[1], sys.argv[2]

patch_county = {"台南縣":"台南市","台北縣":"新北市","台中縣":"台中市","高雄縣": "高雄市"}

# query: m3166["TPQ"] = "新北市"
m3166 = json.load(open("vote/3166-2-tw.json","r"))

raw_sec = json.load(open("vote/ly-section.json","r"))
# query: section[u"新北市-雙溪區-上林里"] = ["TPQ","12"]
section = {}
for c in raw_sec.keys():
  for n in raw_sec[c].keys():
    for item in raw_sec[c][n]: section["%s-%s"%(m3166[c],item)] = [c,n]

shape = ogr.Open(infile)
layer = shape.GetLayerByIndex(0)

sec_geom = {}

for f in layer:
  g = f.GetGeometryRef()
  if not g: continue
  g = g.Clone()
  if not g: continue
  county,town,village = f.GetFieldAsString(2), f.GetFieldAsString(3), f.GetFieldAsString(4)
  if county in patch_county:
    county,town,village = patch_county[county],re.sub("...$","區",town),re.sub("村", "里", village)
  key = re.sub("臺","台","%s-%s-%s"%(county,town,village)).decode("utf8")
  if not key in section:
    print("warning: 找不到 '%s' 的選區對應"%key)
    continue
  c,n = section[key]
  #if key==u"屏東縣-滿州鄉-響林村" or key==u"高雄市-六龜區-建山里":
  #  print("%s: %s"%(key,n))
  if not c in sec_geom: sec_geom[c] = {}
  if not n in sec_geom[c]: sec_geom[c][n] = []
  sec_geom[c][n] += [[g,key]]

# failed item:台南市-麻豆區-北勢里;雲林縣-水林鄉-大山村;新竹縣-五峰鄉-大隘村
features = []
for c in sec_geom.keys():
  for n in sec_geom[c].keys():
    if not sec_geom[c][n]: continue
    g = None
    for item in sec_geom[c][n]:
      gi = item[0]
      # hack
      if item[1]==u"新竹縣-五峰鄉-大隘村": continue
      if g: 
        gr = g.Union(gi)
        if gr!=None: g = gr
        else: print(" -> fail: %s"%item[1].encode("utf8"))
      else: g = gi
    if g: 
      features += ['{"properties":{"name":"%s","county":"%s","number":"%s"},"type":"Feature","geometry":%s}'%(
        u"%s第%s選區"%(m3166[c],n),
        c,n,
        g.ExportToJson()
      )]

if os.path.exists(outfile): os.remove(outfile)
outfile = open(outfile, "w")
outfile.write('{"type": "FeatureCollection", "features": [%s]}'%(",".join(features).encode("utf8") ))
outfile.close()
