#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding=utf-8
import os,sys,re,glob,json
import gdal,ogr,json

patch_county = {"台南縣":"台南市","台北縣":"新北市","台中縣":"台中市","高雄縣": "高雄市"}
# query: m3166["TPQ"] = "新北市"
m3166 = json.load(open("3166-2-tw.json","r"))
raw_sec = json.load(open("ly-section.json","r"))
# query: section[u"新北市-雙溪區-上林里"] = ["TPQ","12"]
section = {}
for c in raw_sec.keys():
  for n in raw_sec[c].keys():
    for item in raw_sec[c][n]: section["%s-%s"%(m3166[c],item)] = [c,n]

shape = ogr.Open("shp/TWN_VILLAGE.shp")
layer = shape.GetLayerByIndex(0)

sec_geom = {}
features = []
for f in layer:
  g = f.GetGeometryRef()
  if not g: continue
  county,town,village = f.GetFieldAsString(2), f.GetFieldAsString(3), f.GetFieldAsString(4)
  if county in patch_county:
    county,town,village = patch_county[county],re.sub("...$","區",town),re.sub("村", "里", village)
  key = re.sub("臺","台","%s-%s-%s"%(county,town,village)).decode("utf8")
  features += ['{"properties":{"name":"%s"},"type":"Feature","geometry":%s}'%(
    key.encode("utf8"),
    g.ExportToJson()
  )]

outfn = "web/villiage.json"
if os.path.exists(outfn): os.remove(outfn)
outfile = open(outfn, "w")
outfile.write('{"type": "FeatureCollection", "features": [%s]}'%(",".join(features) ))
outfile.close()
