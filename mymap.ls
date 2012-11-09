# Our projection.
projection = d3.geo.mercator!scale 50000 .translate [-16500 3650]
path = d3.geo.path!projection(projection)
[width, height] = [460 600]
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

quantize = ->
    pct = parseFloat(data[it.properties.name]?percentage)
    ret = 'q' + (Math.min 8, (pct * 9 / 12)) + '-9'
    ret

mymap = ->
    svg = d3.select("body").append("svg")
        .attr \width width
        .attr \height height

    svg.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height)
        .on("click", click);

    g := svg.append("g")
        .append \g
        .attr \id \taiwan
        .attr \class \Blues

    d <- d3.tsv "test.tsv"
    console.log d
    eligibles = d.map (.eligible)
    data := {[city.replace(/臺/g, '台'), entry] for {city}:entry in d}
    #baseEligible = Math.max ... eligibles
    [baseEligible] = [+x.eligible for name,x of data when name is \台北市]
    baseArea = null

    d3.json "twCounty2010.json" (collection) ->
      areas = for f in collection.features
          f.properties.area = Math.abs path.area f
#      baseArea := Math.max ...areas
      [baseArea] := [properties.area for {properties} in collection.features when properties.name is \台北市]

      g.selectAll("path")data collection.features
      .enter!append \path
      .attr \class if data => quantize else null
      .attr \d path
      .on \click click

    d3.select \#bar .on \click ->
      g.selectAll \path
      .transition!duration 1000
      .attr \transform -> "scale(1)"
    d3.select \#foo .on \click ->
      g.selectAll \path
      .transition!duration 1000
      .attr \transform ->
          {name, area} = it.properties
          entry = data[name]
          scale = 1
          if entry?
              console.log baseEligible, baseArea
              scale = entry.eligible / baseEligible
              scale *= Math.sqrt(baseArea / it.properties.area)
              console.log \toscale
              console.log name, scale, area, area / baseArea, entry.eligible, entry.eligible / baseEligible
          [x, y] = path.centroid it
          "translate(#x,#y)" + "scale(#scale)" + "translate(#{-x},#{-y})"
#      .style("stroke-width", function(d) {
#        return 1 / Math.sqrt(data[+d.id] * 5 || 1);
#      });



