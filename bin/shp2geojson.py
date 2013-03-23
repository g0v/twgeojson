#!/usr/bin/python
# -*- coding: utf-8 -*- #coding=utf-8
import os,sys,re,glob,json
import gdal,ogr,json

if len(sys.argv)<3:
  print("usage: shp2votetopojson.py infile.shp out.topojson")
  sys.exit(-1)

infile,outfile = sys.argv[1], sys.argv[2]
patch_county = {u"台南縣":u"台南市",u"台北縣":u"新北市",u"台中縣":u"台中市",u"高雄縣":u"高雄市"}

def makename(prop):
  ahash,ret = {}, ""
  for item in prop: ahash[item[0]] = item[1]
  ret = ahash["COUNTYNAME"]
  if "TOWNNAME" in ahash: ret += "/%s"%ahash["TOWNNAME"]
  if "VILLAGENAM" in ahash: ret += "/%s"%ahash["VILLAGENAM"]
  return ret

def patch(name, value, direct=False):
  if name=="COUNTYNAME": return (patch_county[value] if value in patch_county else value)
  if not direct: return value
  if name=="TOWNNAME": return re.sub(".$", u"區", value, flags=re.UNICODE)
  if name=="VILLAGENAM": return re.sub(".$", u"里", value, flags=re.UNICODE)

shape = ogr.Open(infile)
layer = shape.GetLayerByIndex(0)

features = {}
for f in layer:
  g = f.GetGeometryRef()
  if not g: continue
  prop = []
  direct = False
  for i in xrange(0,f.GetFieldCount()):
    name = f.GetFieldDefnRef(i).GetName().decode("utf-8")
    value = f.GetFieldAsString(i).decode("utf-8")
    if value in patch_county: direct = True
    value = patch(name, value, direct)
    prop += [[name, value]]
  name = makename(prop)
  prop += [["name", name]]
  if not name in features: features[name] = [prop,None]
  if features[name][1]: features[name][1] = features[name][1].Union(g)
  else: features[name][1] = g.Clone()

ftext = []
for f in features:
  prop,g = features[f]
  ftext += ['{"properties":{%s},"type":"Feature","geometry":%s}'%(
    (",".join([('"%s":"%s"'%(p[0],p[1])) for p in prop])).encode("utf-8"),
    g.ExportToJson()
  )]

if os.path.exists(outfile): os.remove(outfile)
fp = open(outfile, "w")
fp.write('{"type": "FeatureCollection", "features": [%s]}'%(",".join(ftext) ))
fp.close()
