
width = 600
height = 800

canvas = (d3.select \body
          .append \canvas
          .attr \width, width
          .attr \height, height
          .style \position, \absolute
          .style \top, \0px
          .style \left, \0px)[0][0].getContext(\2d)
      
svg = d3.select \body
      .append \svg
      .attr \width, width
      .attr \height, height
      .style \position, \absolute
      .style \top, \0px
      .style \left, \0px


min-latitude = 21.5 # min-y
max-latitude = 25.5 # max-y
min-longitude = 119.5 # min-x
max-longitude = 122.5 # max-x
dy = (max-latitude - min-latitude) / height
dx = (max-longitude - min-longitude) / width


### Draw Taiwan
countiestopo <- d3.json "twCounty2010.topo.json"
counties = topojson.feature countiestopo, countiestopo.objects['twCounty2010.geo']
proj = ([x, y]) ->
        [(x - min-longitude) / dx, height - (y - min-latitude) / dy]
path = d3.geo.path!projection proj

g = svg.append \g
      .attr \id, \taiwan
      .attr \class, \counties

g.selectAll 'path'
  .data counties.features
  .enter!append 'path'
  .attr 'class', -> \q-9-9
  .attr 'd', path

### Draw Stations

# [{"name":"三星", "latitude":"24.6725", "longitude":"121.6461", "id":"C1U66", "altitude":"103"}, …]
stations <- d3.json "stations.json"
svg.selectAll \circle
  .data stations
  .enter!append 'circle'
  .style \stroke \black
  .style \fill \none
  .attr \r 2
  .attr "transform" ->
      "translate(#{ proj [+it.longitude, +it.latitude] })"



#console.log [[+it.longitude, +it.latitude, it.name] for it in stations]
root = new Firebase "https://cwbtw.firebaseio.com"
current = root.child "rainfall/2013-07-13/23:50:00"

# {"七股":{"10m":"-", "today":"20.5"}, …}
rain-data = {}

# [[x, y, z], …]
samples = {}


# p1: [x1, y1]
# p2: [x2, y2]
# return sqrt((x1-x2)^2 + (y1-y2)^2)
distance = ([x1, y1], [x2, y2]) ->
  Math.sqrt (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)

# samples: [[x, y, z], …]
# power: positive integer
# point: [x, y]
# return z
idw-interpolate = (samples, power, point) -> 
  sum = 0.0
  sum-weight = 0.0
  for s in samples
    d = distance(s, point)
    return s[2] if d == 0.0
    weight = Math.pow(d, -power)
    sum := sum + weight
    sum-weight := sum-weight + weight * s[2]
  sum-weight / sum

y-pixel = 0

plot-interpolated-data = ->
  y-pixel := height

  render-line = ->
    if y-pixel >= 0
      for x-pixel from 0 to width by 2
        y = min-latitude + dy * y-pixel
        x = min-longitude + dx * x-pixel
        z = 0 >? idw-interpolate samples, 2.75, [x, y]
        c = (500.0 - z) / 500.0 * 240
        canvas.fillStyle = d3.hsl(c, 0.6, 0.5).toString!
        canvas.fillRect x-pixel, height - y-pixel, 2, 2
      y-pixel := y-pixel - 2
      setTimeout render-line, 0
    # else
      
    #   draw-polygon = (polygon, ctx) ->
    #     ctx.strokeStyle = \#eee
    #     ctx.lineWidth = 1
      
    #     firstPoint = true
    #     ctx.beginPath!
    #     console.log polygon
        
    #     for pt in polygon
    #       x = (pt[0] - min-longitude) / dx
    #       y = height - (pt[1] - min-latitude) / dx
          
    #       if (firstPoint)
    #         ctx.moveTo x, y
    #         firstPoint := false
    #       else 
    #         ctx.lineTo x, y
    #     ctx.closePath!
    #     ctx.stroke!

    #   for ct in counties.features
    #     for coordinate in ct.geometry.coordinates
    #       if ct.geometry.type == \MultiPolygon
    #         for polygon in coordinate
    #           draw-polygon polygon, canvas
    #       else if ct.geometry.type == \Polygon
    #         draw-polygon coordinate, canvas
    #       else 
    #         console.log ct.geometry.type

    #   canvas.strokeStyle = \#000
    #   canvas.lineWidth = 1
    #   for st in stations
    #     x = (+st.longitude - min-longitude) / dx
    #     y = height - (+st.latitude - min-latitude) / dx
    #     canvas.beginPath!
    #     canvas.arc x, y, 2.0, 0, 2 * Math.PI, false
    #     canvas.closePath!
    #     canvas.stroke!

  render-line!



current.on \value ->
  rain-data := it.val!
  samples := [[+st.longitude, +st.latitude, parseFloat rain-data[st.name][\today] ] for st in stations when rain-data[st.name]? and not isNaN rain-data[st.name][\today] ]
  plot-interpolated-data!
