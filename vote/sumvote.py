#!/usr/bin/python
# -*- coding: utf-8 -*-
import glob, json, copy, re
files = glob.glob("raw/*")
outjson = {}
xx=0
for f in files:
  result = re.search("/([^-]+)-(\d+)\.",f)
  if not result: continue
  county,number = result.group(1),result.group(2)
  if not county in outjson: outjson[county] = {}
  js = json.load(open(f,"r"))
  data = js[u"投票狀況"]
  out = copy.deepcopy({
    "有效票數": 0,
    "無效票數": 0,
    "投票數": 0,
    "已領未投票數": 0,
    "發出票數": 0,
    "用餘票數": 0,
    "選舉人數": 0
  })
  for town in data.keys():
    for village in data[town].keys():
      for item in out:
        item2 = item.decode("utf-8")
        #if item in data[town][village][0]: print("hi")
        if not item2 in data[town][village][0]: continue
        out[item] += data[town][village][0][item2]
  outjson[county][number] = out
json.dump(outjson, open("votedata.json","w"), ensure_ascii=False)
