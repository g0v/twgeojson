# this works on https://github.com/ronnywang/twgeojson/blob/master/village-list.csv
require! <[csv fs]>
var c, ci, candidate, header, county

county = {}
town = {}
village = {}

iso3166-map = {
  "CHA":"彰化縣",
  "CYI":"嘉義市",
  "CYQ":"嘉義縣",
  "HSQ":"新竹縣",
  "HSZ":"新竹市",
  "HUA":"花蓮縣",
  "ILA":"宜蘭縣",
  "KEE":"基隆市",
  "KHH":"高雄市",
  "KHQ":"高雄市",
  "MIA":"苗栗縣",
  "NAN":"南投縣",
  "PEN":"澎湖縣",
  "PIF":"屏東縣",
  "TAO":"桃園縣",
  "TNN":"台南市",
  "TNQ":"台南市",
  "TPE":"台北市",
  "TPQ":"新北市",
  "TTT":"台東縣",
  "TXG":"台中市",
  "TXQ":"台中市",
  "YUN":"雲林縣",
  "JME":"金門縣",
  "LJF":"連江縣"
}

iso3166 = ->
  it.=replace /臺/, '台'
  [id for id,name of iso3166-map when name is it]?0

fixup-map = {}

<- csv!from.stream fs.createReadStream './village-fix.csv'
.on \record ([vid, name]) ->
  fixup-map[vid] = name
.on \end

<- csv!from.stream process.stdin
.on \record (row, i) ->
  unless header
    header := row
    return
  entry = {[h, row[i]] for h, i in header}

  #return if entry.COUNTY is /金門|連江/

  return  unless entry.V_ID

  unless entry.TOWN_ID.length
    wtf = entry.V_ID.match /^(\d{5})(\d+)-(\d+)/
    [_, c, t, v] = wtf
    #[_, COUNTY_ID, town, VILLAGE_ID] =  wtf
    entry.COUNTY_ID = c
    entry.VILLAGE_ID = v
    entry.TOWN_ID = entry.COUNTY_ID + t
    [_, entry.VID] = entry.VILLAGE_ID.split /-/

  return unless entry.VILLAGE_ID
  if c = county[entry.COUNTY_ID]
    console.log "#{entry.COUNTY} vs #{c.name} for #{entry.COUNTY_ID}" if c.name isnt entry.COUNTY
  else
    county[entry.COUNTY_ID] = do
      name: entry.COUNTY
      iso3166: iso3166 entry.COUNTY
  if t = town[entry.TOWN_ID]
    console.log "#{t.name} for #{JSON.stringify entry}" if t.name isnt entry.TOWN
  else
    console.log JSON.stringify entry if entry.TOWN_ID.substr(0,5) isnt entry.COUNTY_ID
    town[entry.TOWN_ID] = do
      name: entry.TOWN
      icid: county[entry.COUNTY_ID].iso3166
      itid: county[entry.COUNTY_ID].iso3166 + '-' + entry.TOWN_ID.substr(5,3)

  if v = village[entry.VILLAGE_ID]
    console.log "#{v.name} for #{JSON.stringify entry}" if v.name isnt entry.VILLAGE
  else
    console.log \=== JSON.stringify entry if entry.V_ID.split /-/ .0 isnt entry.TOWN_ID
    village[entry.V_ID] = do
      name: fixup-map[entry.V_ID] ? entry.VILLAGE
      town: entry.TOWN
      county: entry.COUNTY
      vid: entry.VILLAGE_ID
      tid: entry.TOWN_ID
      cid: entry.COUNTY_ID
      icid: county[entry.COUNTY_ID].iso3166
      itid: town[entry.TOWN_ID].itid
      ivid: town[entry.TOWN_ID].itid + '-' + entry.VILLAGE_ID
      code: entry.VILLCODE
#  console.log entry
.on \end

#console.log {county, town, village}
console.log <[id name town county vid tid cid icid itid ivid code]>.join \,
for id, v of village
  console.log ([id] ++ v<[name town county vid tid cid icid itid ivid code]>).join \,
console.log \hi
