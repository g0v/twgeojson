# Our projection.
projection = d3.geo.mercator!scale 50000 .translate [-16400 3800]
path = d3.geo.path!projection(projection)
[width, height] = [600 800]
g = null
click = (d) ->
    [x, y, k] = [0 0 1]
    if d && centered !~= d
      [x, y] = path.centroid d
      k = 4
      x -= width / 2 / k
      y -= height / 2 / k
      centered = d

    g.selectAll "path"
        .classed "active", centered && -> it ~= centered

    g.transition!
        .duration 1000
        .attr "transform", "scale(#k)translate(#{-x},#{-y})"
        .style "stroke-width", 1.5 / k + "px"

data = null
pctscale = null

quantize = -> "q#{pctscale parseFloat data[it.properties.name]?percentage}-9"

edge = (a, b) ->
  dx = a.x - b.x
  dy = a.y - b.y
  {
    source: a
    target: b
    distance: Math.sqrt dx * dx + dy * dy
  }

collide = (node) ->
  r = node.radius + 16
  nx1 = node.x - r
  nx2 = node.x + r
  ny1 = node.y - r
  ny2 = node.y + r
  (quad, x1, y1, x2, y2) ->
    if quad.point and quad.point isnt node
      x = node.x - quad.point.x
      y = node.y - quad.point.y
      l = Math.sqrt x * x + y * y
      r := node.radius + quad.point.radius
      if l < r
        l = (l - r) / l * 0.5
        node.x -= x *= l
        node.y -= y *= l
        quad.point.x += x
        quad.point.y += y
    x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1

dolinks = (svg, nodes, links) ->
  force = d3.layout.force!size [width, height]
  force
      .gravity 0
      .friction 0.1
      .charge 0
      .nodes nodes
      .links links
      .linkDistance (.distance)
      .size [width, height]
      .start!

  parent = g.selectAll \g .data nodes
    .enter!append \g
    .attr \transform -> "translate(#{-it.x},#{-it.y})"
    .call force.drag

  node = parent.append \path
    .attr \transform -> "translate(#{it.x},#{it.y})"
    .attr \class -> quantize it.feature
    .attr "d" -> path it.feature
    .on \click -> click it.feature

  link = g.selectAll \line .data links
    .enter!append \line
    .attr \x1 (.source.x)
    .attr \y1 (.source.y)
    .attr \x2 (.target.x)
    .attr \y2 (.target.y)

  force.on \tick (e) ->
    link
      .attr \x1 (.source.x)
      .attr \y1 (.source.y)
      .attr \x2 (.target.x)
      .attr \y2 (.target.y)

    q = d3.geom.quadtree nodes
    for n in nodes => q.visit collide n

    node
      .attr \transform ->
          it.x <?= width - it.radius
          it.x >?= it.radius
          it.y <?= height - it.radius
          it.y >?= it.radius
          me = "translate(#{it.x},#{it.y})"
          if it.feature.x
              [x, y, scale] = it.feature<[x y scale]>
              me += "translate(#x,#y)" + "scale(#scale)" + "translate(#{-x},#{-y})" 
          me

  force.start!
  force

mymap = ->
    svg = d3.select \body .append \svg
        .attr \width width
        .attr \height height

    svg.append \rect
        .attr \class \background
        .attr \width width
        .attr \height height
        .on \click click

    g := svg.append("g")
        .append \g
        .attr \id \taiwan
        .attr \class \Blues

    d <- d3.tsv "test.tsv"
    eligibles = d.map (.eligible)
    adj =
        * <[台北市 新北市]>
        * <[新北市 基隆市]>
        * <[新北市 宜蘭縣]>
        * <[新北市 桃園縣]>
        * <[桃園縣 宜蘭縣]>
        * <[桃園縣 新竹縣]>
        * <[新竹縣 宜蘭縣]>
        * <[新竹縣 新竹市]>
        * <[新竹縣 苗栗縣]>
        * <[苗栗縣 台中市]>
        * <[新竹縣 台中市]>
        * <[宜蘭縣 花蓮縣]>
        * <[台中市 花蓮縣]>
        * <[台中市 彰化縣]>
        * <[台中市 南投縣]>
        * <[花蓮縣 南投縣]>
        * <[彰化縣 南投縣]>
        * <[彰化縣 雲林縣]>
        * <[南投縣 雲林縣]>
        * <[雲林縣 嘉義縣]>
        * <[南投縣 嘉義縣]>
        * <[嘉義縣 嘉義市]>
        * <[嘉義縣 高雄市]>
        * <[嘉義縣 台南市]>
        * <[高雄市 台南市]>
        * <[花蓮縣 高雄市]>
        * <[花蓮縣 台東縣]>
        * <[台東縣 高雄市]>
        * <[台東縣 屏東縣]>
        * <[高雄市 屏東縣]>


    data := {[city.replace(/臺/g, '台'), entry] for {city}:entry in d}
    #baseEligible = Math.max ... eligibles
    useBase = \台南市
    [baseEligible] = [+x.eligible for name,x of data when name is useBase]
    baseArea = null
    force = null
    pctscale := d3.scale.quantile!domain(d3.extent d, -> parseFloat(it.percentage))range [1 to 8]
    console.log d

    d3.json "twCounty2010.json" (collection) ->
      byname = {}
      areas = for f in collection.features
          f.properties.area = Math.abs path.area f
      nodes = for feature in collection.features# when feature.properties.name isnt /金門|連江|澎湖/
          [x, y] = path.centroid feature
          radius = 0
          byname[feature.properties.name] = {feature, x, y, radius}
      links = []

      for [a, b] in adj
          links.push edge byname[a], byname[b]

      morelinks = ->
          res = for x in nodes when x.feature.properties.name is /金門|連江|澎湖/
              y = for y in nodes when x isnt y
                  edge x, y
              y.sort (a, b) -> a.distance - b.distance
              y[0 to 5]
          links := links ++ res.reduce (++)
      morelinks!

      force := dolinks svg, nodes, links
#      baseArea := Math.max ...areas
      [baseArea] := [properties.area for {properties} in collection.features when properties.name is useBase]

    showlinks = no
    d3.select \#showlinks .on \click ->
        g.selectAll \line .classed "show", showlinks := !showlinks
    d3.select \#restore .on \click ->
      force.stop!
      g.selectAll \path
      .each ({feature:it}:d) ->
          it.scale = 1
          [d.x, d.y] = path.centroid it
          d.radius = 0
          d.distance = d.origDistance
      .transition!duration 1000
      .attr \transform ({feature:{x,y,scale}}:it) ->
           "translate(#{it.x},#{it.y})" + "translate(#x,#y)" + "scale(#scale)" + "translate(#{-x},#{-y})"
      <- (`setTimeout` 1000ms)
      force.charge 0 .resume!
    d3.select \#scale .on \click ->

      force.stop!
      g.selectAll \path
      .each ({feature:it}:d) ->
          {name, area} = it.properties
          entry = data[name]
          scale = 1
          if entry?
              console.log baseEligible, baseArea
              it.eligible = entry.eligible
              scale = entry.eligible / baseEligible
              scale *= baseArea / it.properties.area
              scale = Math.sqrt(scale)
              console.log \toscale
              console.log name, scale, area, area / baseArea, entry.eligible, entry.eligible / baseEligible
              console.log d, d3.geo.bounds(it)
              d.radius = Math.sqrt(area / Math.PI) * 1.2 * scale
          [x, y] = path.centroid it
          it <<< { scale, x, y }
      .transition!duration 1000
      .attr \transform ({feature:{x,y,scale}}:it) ->
           "translate(#{it.x},#{it.y})" + "translate(#x,#y)" + "scale(#scale)" + "translate(#{-x},#{-y})"

      g.selectAll \line
      .each (d) ->
          d.origDistance ?= d.distance
          d.distance *= (d.source.feature.scale + d.target.feature.scale) * 2 / 3
      <- (`setTimeout` 1000ms)
      force.charge -> -it.feature.properties.area * it.scale
        .alpha(0.1)
