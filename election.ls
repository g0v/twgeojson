width = window.innerWidth * 0.8
height = window.innerHeight - 10
vote = d3.map!
village-name = d3.map!

svg = d3.select 'body' .append 'svg' .attr 'width', width .attr 'height', height

tw <- d3.json "tw.json"
<- d3.csv "districts.csv" -> village-name.set it.ivid, it{name, town, county}

<- d3.csv "election2009.csv" -> vote.set it.ivid, do
  blue:  +it.blue
  green: +it.green

val = -> if it => it.blue + it.green else 0
val-win = -> if it => Math.abs it.blue - it.green else 0
color-win = ->
  if it
    if it.blue > it.green => 'blue' else 'green'
  else
    'white'

max = d3.max [val c for c in vote.values!]
min = d3.min [val c for c in vote.values!]
console.log min, max
scale = d3.scale.log!domain [min+1, max+1] .range [0, 9]
scale2 = d3.scale.sqrt!domain [min, max] .range [0, 10]
quantize = -> "q#{ ~~scale it }-9"

proj = mtw!

villages = topojson.feature tw, tw.objects['villages']


path = d3.geo.path!projection proj

g = svg.append 'g'
  .attr 'class', 'villages'

part-of = (name) -> -> 0 is it?indexOf name

var wanted, zoomin

set-wanted = ->
    wanted := part-of it

    zoomin := villages.features.filter -> wanted it.properties?ivid

    # draw exterior borders of given subset
    selected = topojson.mesh tw, tw.objects['villages'], (a, b) ->
      f = topojson.feature tw, a
      aa = wanted f.properties.ivid
      return true if a is b and aa

      g = topojson.feature tw, b
      bb = wanted g.properties.ivid
      (a isnt b and aa isnt bb)

    g.selectAll 'path.selected' .remove!
    g.append 'path'
      .datum selected
      .attr 'class', 'selected'
      .attr 'd', path

show = ->
  v = village-name.get it.properties.ivid
  cnt = vote.get it.properties.ivid
  total = val cnt
  d3.select 'h3.village-name' .text v<[county town name]>.join ''
  d3.select 'span.village-blue' .text if total => "#{cnt.blue} (#{Math.round(100 * cnt.blue / total) }%)" else ''
  d3.select 'span.village-green' .text if total => "#{cnt.green} (#{Math.round(100 * cnt.green / total) }%)" else ''
  console?log it.properties.ivid, val vote.get it.properties.ivid

g.selectAll 'path'
  .data villages.features
  .enter!
    ..append 'path'
#      .attr 'class' ->
#        if it.properties.ivid
#          quantize val vote.get that
      .attr 'd', path
      .on \mouseover show
    ..append 'circle'
      .attr 'opacity' 0.5
      .attr 'r' ->
        scale2 val vote.get it.properties.ivid
      .attr "stroke-width" ->
        scale2 val-win vote.get it.properties.ivid
      .attr "stroke" -> color-win vote.get it.properties.ivid

      .attr 'cx' ->
        path.centroid(it)?0
      .attr 'cy' ->
        path.centroid(it)?1
      .on \mouseover show

d3.select 'input.filter' .attr 'value' 'ILA'
set-wanted 'ILA'

zoom-to = (set) ->
  b = path.bounds set
  s = 0.95 / Math.max((b.1.0 - b.0.0) / width, (b.1.1 - b.0.1) / height)
  [x, y] = b.0
  x -= (width/s - (b.1.0 - b.0.0)) / 2
  y -= (height/s - (b.1.1 - b.0.1)) / 2

  g.transition!duration 1000
    .attr "transform" "translate(#{0 / 2},#{0 / 2})scale(#{s})translate(#{-x},#{-y})"
    .style "stroke-width", 5 / s + "px"

zoom-to {type: \FeatureCollection, features: zoomin}

d3.select 'span.zoomout'
  .on \click ->
    zoom-to villages

d3.select 'span.zoomin'
  .on \click ->
    zoom-to {type: \FeatureCollection, features: zoomin}

d3.select 'input.filter'
  ..on \change ->
    z = ..0.0.value
    set-wanted z
