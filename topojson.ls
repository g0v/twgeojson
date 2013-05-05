color = d3.scale.category20c!
class Layout
  name: "default"
  features: []
  path: ->
  transform: ->
  #@proj = mercatorTW!call
  @proj = mtw!scale 5000
  @carto = d3.cartogram!.projection Layout.proj
  @flat = class extends Layout
    @name= "flat"
    (topo,geom,graph) ->
      #@carto = d3.cartogram!.projection Layout.proj
      @features = Layout.carto.features topo, geom
    path: -> 
      (d3.geo.path!.projection Layout.proj) @feature
    transform: -> "translate(0 100)"

  @cartogram = class extends Layout
    @name= "carto"
    #@carto = d3.cartogram!.projection Layout.proj
    (topo,geom,graph) ->
      @features = Layout.carto topo, geom .features
    path: -> Layout.carto.path @feature
    transform: -> "translate(0 100)"

  @dorling = class extends Layout
    @name = "dorling"
    (topo,geom,graph) ->
      features = (Layout.carto.features topo,geom)
      lens = [(((d3.geo.path!.projection Layout.proj) feature).split /[ML]/).length for feature in features]
      lens = [(d3.geo.path!.projection Layout.proj) feature .split /M/ for feature in features] 
        .map -> it.map -> it.split /L/ 
        .map -> it.sort (a,b) -> b.length - a.length 
        .map -> it.0.length
      lens = [x-1 for x in lens]
      features = [o.geometry.coordinates.reduce (++) for o in features]
      features = for feature in features
        if typeof(feature[0][0])==typeof(0.0) then feature
        else feature.reduce (++)
      z = 180
      avg = [ ( feature.reduce (a,b) -> [a.0 + b.0,a.1 + b.1], [0,0] ) 
        .map (/feature.length) for feature in features]
      center = ( avg.reduce (a,b) -> [a.0 + b.0, a.1 + b.1], [0,0] ).map (/avg.length)
      rad = []
      fx = for feature,i in features
        [angle,ret] = [0,""]
        feature = [ [ (f.0 - avg[i].0)*z, (f.1 - avg[i].1)*z ] for f in feature]
        radius = (feature .reduce ((a,b) -> a + Math.sqrt(b.0**2 + b.1**2)),0) / (feature.length)
        rad.push radius
        f = for pt in feature[0 to lens[i]]
          angle += (6.28318 / (lens[i] - 1))
          [Math.cos(angle)*radius, Math.sin(angle)*radius]
      
      @features = []
      for f,i in fx
        @features.push {f:f,z:z,r:rad[i],t:[(avg[i].0 - center.0)*z,( -avg[i].1 + center.1)*z]}
      #@features = [{f:f,z:z,r:rad[i],t:[(avg[i].0 - center.0)*z,( -avg[i].1 + center.1)*z]} for f,i in fx]

      links = []
      for a,i in avg
        for b,j in avg
          if i==j then continue
          if rad[i] + rad[j] > z*Math.sqrt((avg[i].0 - avg[j].0)**2 + (avg[i].1 - avg[j].1)**2) then
            links.push {source: i, target: j, weight: rad[i]+rad[j]}
      for block,i in graph.blocks
        block.x = 0
        block.y = 0
        block.weight = rad[i]
      #@force = d3.layout.force! .charge -50000 .gravity 1 .linkDistance 50  .friction 0.1 .size [500,300]
      @force = d3.layout.force! .charge 0 .gravity 0.9 .friction 1.0 .size [700,700]
      @force.nodes graph.blocks

    path: -> 
      ["#{(i==0 and 'M') or 'L'}#{x} #{y}" for [x,y],i in @feature.f].join " "

    transform: -> 
      f = @feature
      "translate(#{f.t.0 + 180} #{f.t.1 + 230})"
      #"translate(#{(f.a.0 - f.c.0)*f.z+180} #{-(f.a.1 - f.c.1)*f.z+230})"

class Geograph
  @fromjson = (filename, config, callback) ->
    d3.json filename, (data) -> callback new Geograph data,config

  (topo, config) ->
    @ <<< x: 0, y: 0
    @ <<< config
    throw "missing name" unless @name
    @topo = topo
    @geom = topo.objects[@name].geometries
    @layouts = {}
    @blocks = new Array @geom.length
    #@use Layout.cartogram
    @use Layout.flat
    for feature,i in @layout.features
      @blocks[i] = new Geoblock @,feature
    @avg = ( [b.avg for b in @blocks] .reduce (a,b) -> [a.0+b.0,a.1+b.1] ).map ~> it/@blocks.length
    @svg = d3.select @container .append \svg
      .attr \width ($ \body .width!)*0.9
      .attr \height ($ \body .height!)*0.9
      .style \margin "#{($ \body .height!)*0.05} 0 0 #{($ \body .width!)*0.05}"
      .attr \viewBox "0 0 1024 768"
      .attr \preserveAspectRatio "xMinYMin meet"
    @group = @svg.append \g
    @path = @group.selectAll \path .data @blocks .enter! .append \path
      .attr \stroke-width \1px
      .attr \stroke \#000
      .attr \fill (it,i) -> color(i%20) #\none #\#f00
      .attr \d ~> @layout.path.call it
      .attr \transform ~> @layout.transform.call it

  transition: (it, t=true) ->
    it.attr \d ~> @layout.path.call it
      .attr \transform (~> @layout.transform.call it)

  use: (lo) ->
    if not @layouts[lo.name] 
      @layout = new lo @topo,@geom,@
      @layouts[lo.name] = @layout
    else (@layout=@layouts[lo.name])
    for feature,i in @layout.features
      @blocks[i]?.feature = feature

class Geoblock
  (parent, feature) ->
    @feature = feature
    plys = feature.geometry.coordinates
    if feature.geometry.type=="MultiPolygon" then plys = plys.reduce (++)
    @avg = (( _plys = plys.reduce (++) ) .reduce (a,b) -> [a.0+b.0, a.1+b.1] ) .map (/_plys.length)
    pj = ~> [(it.0 - @avg.0), -(it.1 - @avg.1)]
    @pts2d = [ [[ [pt.0, pt.1] |> pj for pt in ply]].0 for ply in plys ]

@Geograph = Geograph
@Geoblock = Geoblock
@Layout = Layout
