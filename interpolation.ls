
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

# inspector = d3.select \body
#               .append \div
#               .attr \class \inspector
#               .style \opacity 0

# station-label = inspector.append "p"
# rainfall-label = inspector.append "p"


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
current = root.child "rainfall/current"

# {"七股":{"10m":"-", "today":"20.5"}, …}
rain-data = {}

# [[x, y, z], …]
samples = {}


# p1: [x1, y1]
# p2: [x2, y2]
# return (x1-x2)^2 + (y1-y2)
distance = ([x1, y1], [x2, y2]) ->
  (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)

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
    # weight = Math.pow(d, -power * 0.5)
    weight = 1.0 / (d * d)
    sum := sum + weight
    sum-weight := sum-weight + weight * s[2]
  sum-weight / sum

color-of = (z) ->
  scale = [0, 30, 60, 100, 150, 210, 280, 400, 600, 1000]
  color = [d3.hsl(240, 1.0, 1.0),
           d3.hsl(240, 0.4, 0.7),
           d3.hsl(190, 0.4, 0.6),
           d3.hsl(130, 0.4, 0.6),
           d3.hsl(60, 0.4, 0.6),
           d3.hsl(30, 0.4, 0.6),
           d3.hsl(0, 0.4, 0.6),
           d3.hsl(-80, 0.4, 0.6),
           d3.hsl(-80, 1.0, 0.5),
           d3.hsl(-80, 1.0, 0.0)]

  for i from 0 to scale.length - 2 
    if scale[i] <= z and (z < scale[i + 1] or i == scale.length - 1) 
      nz = z <? scale[i + 1]
      return d3.interpolateHsl(color[i], color[i + 1])((nz - scale[i]) / (scale[i + 1] - scale[i])).toString!

y-pixel = 0

plot-interpolated-data = ->
  y-pixel := height

  render-line = ->
    if y-pixel >= 0
      for x-pixel from 0 to width by 2
        y = min-latitude + dy * y-pixel
        x = min-longitude + dx * x-pixel
        z = 0 >? idw-interpolate samples, 2.75, [x, y]
        
        canvas.fillStyle = color-of z
        canvas.fillRect x-pixel, height - y-pixel, 2, 2
      y-pixel := y-pixel - 2
      setTimeout render-line, 0

  render-line!

# value should be a four-character-length string.
update-seven-segment = (value-string) ->
  pins = "abcdefg"
  seven-segment-char-map = 
    ' ': 0x00
    '-': 0x40
    '0': 0x3F
    '1': 0x06
    '2': 0x5B
    '3': 0x4F
    '4': 0x66
    '5': 0x6D
    '6': 0x7D
    '7': 0x07
    '8': 0x7F
    '9': 0x6F

  d3.selectAll \.seven-segment
    .data value-string
    .each (d, i) ->
      bite = seven-segment-char-map[d]

      for i from 0 to pins.length - 1
        bit = Math.pow 2 i 
        d3.select this .select ".#{pins[i]}" .classed \on, (bit .&. bite) == bit

current.on \value ->
  rain-data := it.val!data
  d3.select \#rainfall-timestamp
    .text "DATE: #{it.val!date} #{it.val!time} "
  
  d3.select \#station-name
    .text "已更新"

  update-seven-segment "    "

  samples := [[+st.longitude, +st.latitude, parseFloat rain-data[st.name][\today] ] for st in stations when rain-data[st.name]? and not isNaN rain-data[st.name][\today] ]

  # calculate the legend

  # update station's value 
  svg.selectAll \circle
    .data stations
    .style \fill (st) ->
      if rain-data[st.name]? and not isNaN rain-data[st.name][\today]
        color-of parseFloat rain-data[st.name][\today]
      else 
        \#FFFFFF
    .on \mouseover (d, i) ->
      d3.select \#station-name
        .text d.name

      if rain-data[d.name]? and not isNaN rain-data[d.name][\today]
        raw-value = (parseInt rain-data[d.name][\today]) + ""
        update-seven-segment (" " * (0 >? 4 - raw-value.length)) + raw-value
      else
        update-seven-segment "----"

  # plot interpolated value
  plot-interpolated-data!
