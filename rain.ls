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

# XXX: use consolidated topojson file

tw <- d3.json "tw.json"
countiestopo <- d3.json "twCounty2010.topo.json"

proj = mtw!

counties = topojson.feature countiestopo, countiestopo.objects['twCounty2010.geo']

villages = topojson.feature tw, tw.objects['villages']
border = topojson.mesh tw, tw.objects['villages'], (a, b) ->
  a is b and a.properties?ivid isnt /^(LJF|PEN|JME)/

path = d3.geo.path!projection proj
extent =  path.bounds counties

svg.append "defs"
  ..append "path"
    .attr "id" "border"
    .datum border
    .attr "d" path
  ..append "clipPath"
    .attr "id" "clip"
    .append "use"
    .attr "xlink:href" '#border'

sg = svg.append 'g'
  .attr "clip-path" 'url(#clip)'

regions = d3.geom.voronoi!clip-extent(extent) [proj [+it.longitude, +it.latitude, it.name] for it in stations]

legend = ->
  svg.selectAll("rect").data rainscale.domain!
    ..enter!append("rect")
      .attr "x" 400
      .attr "y" (d, i) ->
        380-i*20
      .attr "width" 20
      .attr "height" 20
      .attr "fill" (d) ->
        rainscale d
    ..enter!append("text")
      .attr "x" 425
      .attr "y" (d, i) ->
        400-i*20
      .text -> it

  svg.selectAll("text.description").data <[累積雨量 毫米(mm)]>
    ..enter!append("text")
      .attr "class" 'descrition'
      .attr "x" 425
      .attr "y" (d, i) ->
        50 + 20 * i
      .text -> it

legend!

update = ->
  sg.selectAll "path" .data regions
    ..enter!append("svg:path")
      .attr "d" -> "M#{ it.join \L }Z"
      .style \fill '#fff'
    ..transition!duration 300ms
      .style \fill (d, i) ->
        today = +rain-today[stations[i].name]?today
        today = null if today is NaN
        if today
          rainscale today
        else
          '#fff'
  sg.selectAll 'circle'
    .data stations
    .enter!append 'circle'
    .style \stroke \gray
    .attr \r 0.5
    .attr "transform" ->
      "translate(#{ proj [+it.longitude, +it.latitude] })"

g = svg.append 'g'
  .attr 'class', 'villages'

g.selectAll 'path'
  .data counties.features
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
