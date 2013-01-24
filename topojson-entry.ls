<- $ document .ready 
(graph) <- Geograph.fromjson \twCounty1982.topojson, do
  container: \body
,_

#graph.use Layout.flat
#graph.transition graph.path.transition! .duration 750
setTimeout ->
  graph.use Layout.dorling
  graph.layout.force.on \tick (e) ->
    n = graph.blocks
    a = graph.layout.force.alpha!
    #for it,i in n
    #  it.x = it.feature.t.0 + 180 + (0.1 - a)*it.x
    #  it.y = it.feature.t.1 + 230 + (0.1 - a)*it.y
    for it,i in n
      for jt,j in n
        if i==j then continue
        r = it.feature.r + jt.feature.r
        d = Math.sqrt((it.feature.t.0 - jt.feature.t.0 + (0.1 - a)*(it.x - jt.x))**2 + (it.feature.t.1 - jt.feature.t.1 + (0.1 - a)*(it.y - jt.y))**2)
        if r>d then
          d = (d - r) / d * 12
          dx = (it.feature.t.0 - jt.feature.t.0 + (0.1 - a)*(it.x - jt.x)) * d
          dy = (it.feature.t.1 - jt.feature.t.1 + (0.1 - a)*(it.y - jt.y)) * d
          it.x = it.x - dx
          it.y = it.y - dy
          jt.x = jt.x + dx
          jt.y = jt.y + dy
    graph.path.attr \transform -> 
      x = it.feature.t.0 + 180 + (0.1 - a)*it.x
      y = it.feature.t.1 + 230 + (0.1 - a)*it.y
      "translate(#{x} #{y})"
      #"translate(#{it.x+it.feature.t.0+180} #{it.y+it.feature.t.1+230})"
  graph.transition (graph.path.transition! .duration 750)
  setTimeout -> graph.layout.force.start!
  , 750
  setTimeout -> 
    graph.layout.force.stop!
    graph.use Layout.flat
    graph.transition (graph.path.transition! .duration 750)
  , 4000
  setTimeout -> 
    graph.use Layout.cartogram
    graph.transition (graph.path.transition! .duration 750)
  , 6000
,1000
