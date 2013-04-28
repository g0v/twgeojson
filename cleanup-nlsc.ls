# Usage: lsc cleanup-nlsc.ls > villages.json
require! <[csv optimist fs]>
villages = []
var header
<- csv!from.stream fs.createReadStream \./districts.csv
.on \record (row,index) ->
    if index is 0
        header := row
    else
        villages.push {[header[i], row[i]] for i of row}
.on \end
# from http://tgos.nat.gov.tw/tgos/Web/MAPData/Apply/TGOS_Apply_FreeDownload.aspx?ID=1076
set = require \./raw/tw-2013-03

by-vid = {}

set.features.=map ({properties}:f) ->
    return f if properties.TOWN is /\(海\)/
    # incorrect id
    delete properties.V_ID if properties.V_ID in <[10004010-021 10002030-009]>
    if properties.ET_ID is 7822
        properties.V_ID = '09007020-005'

    unless properties.V_ID
        if properties.VILLAGE is /[村里]$/
            [matched] = [v for v in villages when v<[county town name]> === properties<[COUNTY TOWN VILLAGE]>]
            if matched
                console.error \ASSIGN: matched<[county town name]>, matched.id
                properties.VILLAGE_ID = matched.vid
                properties.V_ID = matched.id
            else
                console.error \NULL: properties<[COUNTY TOWN VILLAGE]>
                return f
        else
            return f
    if v = by-vid[properties.V_ID]
        x = that.properties
        if x.VILLAGE is properties.VILLAGE
            console.error \MULTI x.VILLAGE
            if v.geometry.type isnt \MultiPolygon
              v.geometry.type = \MultiPolygon
              v.geometry.coordinates = [v.geometry.coordinates]
            v.geometry.coordinates.push f.geometry.coordinates
            return
        else
            console.error \DUP x.VILLAGE, properties.VILLAGE, x
    [matched] = [v for v in villages when v.id is properties.V_ID]
    throw JSON.stringify properties unless matched
    unless matched<[county town name]> === properties<[COUNTY TOWN VILLAGE]>
        console.error \FIX: matched.id, properties.VILLAGE, \=>, matched.name
        properties.VILLAGE = matched.name
    by-vid[properties.V_ID] = f
    f

set.features.=filter -> it

seen = {[V_ID, 1] for {properties:{V_ID}} in set.features when V_ID}
for {id}:v in villages when !seen[id]
    console.error "NOT FOUND", v<[county town name]>
console.log JSON.stringify set
