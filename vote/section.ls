require! <[fs csvjs]>
# check https://ethercalc.org/g0v-admin-changes

map-csv = \districts.csv
map3166 = \3166-2-tw.json
raw-dir = \./json
name-idx = {}
ivid-idx = {}

if !fs.existsSync map-csv => console.log("#{map-csv} doesn't exist.") and process.exit -1
if !fs.existsSync map3166 => console.log("#{map3166} doesn't exist.") and process.exit -1
if !fs.lstatSync raw-dir .isDirectory! => console.log("#{raw-dir} is not a directory.") and process.exit -1

d = fs.readFileSync map-csv .toString!
csvjs.parse d, (err, row) ->
  name-idx["#{row.county}#{row.town}#{row.name}"] = row
  ivid-idx[row.ivid] = row
m3166 = JSON.parse(fs.readFileSync map3166 .toString!)
i2s = {}
s2i = {}
errant = []

files = fs.readdirSync raw-dir
for f in files
  [code,n] = f.split \. .0 .split \-
  section = f.split \. .0
  [code,n] = (section = f.split \. .0).split \-
  c = m3166[code]
  r = JSON.parse(fs.readFileSync "#{raw-dir}/#{f}" .toString!)
  s2i[section] = []
  for t of r["投票狀況"]
    for vs of r["投票狀況"][t]
      for v in vs.split "、"
        name = c+t+v
        ivid = name-idx[name]? .ivid or null
        if !ivid => errant.push name
        else
          i2s[ivid] = section
          s2i[section].push ivid

fs.writeFileSync \output JSON.stringify [i2s,s2i]
fs.writeFileSync \errant JSON.stringify errant
