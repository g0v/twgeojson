width = window.innerWidth * 0.8
height = window.innerHeight - 10
census = d3.map!

svg = d3.select 'body' .append 'svg' .attr 'width', width .attr 'height', height

stations <- d3.json "stations.json"

root = new Firebase "https://cwbtw.firebaseio.com"
current = root.child "rainfall/current"
rainscale = d3.scale.quantile!
.domain([ 1 2 6 10 15 20 30 40 50 70 90 110 130 150 200 300 ])
.range <[ #c5bec2 #99feff #00ccfc #0795fd #025ffe #3c9700 #2bfe00 #fdfe00 #ffcb00 #eaa200 #f30500 #d60002 #9e0003 #9e009d #d400d1 #fa00ff #facefb]>

rain-today = {}

tw <- d3.json "twCounty2010.topo.json"

proj = mtw!

county = topojson.feature tw, tw.objects['twCounty2010.geo']

path = d3.geo.path!projection proj

sg = svg.append 'g'

regions = d3.geom.voronoi [proj [+it.longitude, +it.latitude, it.name] for it in stations]

update = ->
  paths = sg.selectAll("path")
  .data regions
  paths.enter!append("svg:path")
#  .attr "class" (d, i) ->
#    if i => "q" + (i % 9) + "-9" else null
  .attr "d" -> "M#{ it.join \L }Z"
  paths.style \fill (d, i) ->
    today = +rain-today[stations[i].name]?today
    today = null if today is NaN
    if today
      rainscale today
    else
      '#fff'
  sg.selectAll 'circle'
    .data stations
    .enter!append 'circle'
    .style \stroke \black
    .attr \r 1
    .attr "transform" ->
      "translate(#{ proj [+it.longitude, +it.latitude] })"


g = svg.append 'g'
  .attr 'class', 'villages'

g.selectAll 'path'
  .data county.features
  .enter!append 'path'
  .attr 'class', -> \q-9-9
  .attr 'd', path

current.on \value ->
  {time, data} = it.val!
  d3.select \#time
    .text time
  rain-today := data
  today = [parsed for name, {today} of data when parsed = parseFloat today]
  update!
[]
