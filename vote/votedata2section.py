#!/usr/bin/python
# -*- coding: utf-8 -*-
#coding=utf-8
import os,sys,re,glob
import json

# import pua mapping
puamap = json.load(open("pua-map.json","r"))
# import iso 3166 code mapping
m3166 = json.load(open("3166-2-tw.json","r"))
# import section data
files = glob.glob("raw/*")
section = {}
for f in files:
  result = re.search("/([^-]+)-(\d+)\.", f)
  if not result: continue
  county,number = result.group(1), result.group(2)
  if not county in section: section[county] = {}
  section[county][number] = []
  data = json.load(open(f))[u"投票狀況"]
  for town in data.keys():
    for villages in data[town].keys():
      if "," in villages: villages = villages.split(",")
      else: villages = [villages]
      for village in villages:
        if m3166[county]+town+village in puamap:
          village,town,_ = puamap[m3166[county]+town+village][1].split(",")
        section[county][number].append(re.sub(u"臺",u"台",'"%s-%s"'%(town,village)))

# patch section data
errant = json.load(open("errant.json","r"))
for item in errant:
  c,n = errant[item]
  if not c in section: section[c] = {}
  if not n in section[c]: section[c][n] = []
  section[c][n].append(re.sub(u"臺",u"台",'"%s"'%re.sub("^.+?-","",item)))

lysectionfn = "ly-section.json"
if os.path.exists(lysectionfn): os.remove(lysectionfn)
f = open(lysectionfn,"w")

f1,f2 = 1,1
f.write("{\n")
for c in section.keys():
  f.write('%s  "%s": {\n'%(("" if f1 else ",\n"),c))
  f1,f2=0,1
  for n in section[c].keys():
    f.write('%s    "%s": ['%(("" if f2 else ",\n"),n))
    f.write(""+(",".join(section[c][n]).encode("utf8")))
    f.write(']')
    f2=0
  f.write("}")
f.write("}")
f.close()
