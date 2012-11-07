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

    d3.json "twCounty1982.json" (collection) ->
      g.selectAll("path")data collection.features
      .enter!append \path
      .attr \d path
      .on \click click
