constituency = require \./ly-section
tw3166 = require \./3166-2-tw

ctv-to-constituency = (county, town, village) ->
  [c] = [c for c, name of tw3166 when name is county]
  
  return [c, 0] if constituency[c].length is 1
  village = null
  [which] = [area for area, list of constituency[c] when "#town-#village" in list]

  unless which
    matched = [area for area, list of constituency[c] when list.filter(-> it.indexOf(town) is 0).length]
    throw matched if matched.length isnt 1
    which = matched.0
  [c, which]

address-to-constituency = (input) ->
  address = input.results.0.address_components
  types = {[types[0], long_name] for {long_name, types} in address}
  [county, town, village] = types<[administrative_area_level_2 locality sublocality]>
  ctv-to-constituency county, town, village

# curl 'http://maps.googleapis.com/maps/api/geocode/json?address=台北市研究院路二段,TW&sensor=false&language=zh_TW' > gc.json
input = require \./gc
console.log address-to-constituency input
