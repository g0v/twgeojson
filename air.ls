
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
stations <- d3.csv "epa-site.csv"

function ConvertDMSToDD(days, minutes, seconds)
  days = +days
  minutes = +minutes
  seconds = +seconds
  dd = minutes/60 + seconds/(60*60)
  return if days > 0
    days + dd
  else
    days - dd

stations = for s in stations
  s.lng = ConvertDMSToDD ...(s.SITE_EAST_LONG.split \,)
  s.lat = ConvertDMSToDD ...(s.SITE_NORTH_LAT.split \,)
  s.name = s.SITE
  s

svg.selectAll \circle
  .data stations
  .enter!append 'circle'
  .style \stroke \black
  .style \fill \none
  .attr \r 2
  .attr "transform" ->
      "translate(#{ proj [+it.lng, +it.lat] })"


#console.log [[+it.longitude, +it.latitude, it.name] for it in stations]
#root = new Firebase "https://cwbtw.firebaseio.com"
#current = root.child "rainfall/current"

# {"七股":{"10m":"-", "today":"20.5"}, …}
rain-data = {}

# [[x, y, z], …]
samples = {}


# p1: [x1, y1]
# p2: [x2, y2]
# return (x1-x2)^2 + (y1-y2)
distanceSquare = ([x1, y1], [x2, y2]) ->
  (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)

# samples: [[x, y, z], …]
# power: positive integer
# point: [x, y]
# return z
idw-interpolate = (samples, power, point) ->
  sum = 0.0
  sum-weight = 0.0
  for s in samples
    d = distanceSquare(s, point)
    return s[2] if d == 0.0
    weight = 1.0 / (d * d) # Performance Hack: Let power = 4 for fast exp calculation.
    sum := sum + weight
    sum-weight := sum-weight + weight * s[2]
  sum-weight / sum


color-of = d3.scale.linear()
.domain [0, 50, 100, 200, 300]
.range [ d3.hsl(100, 1.0, 0.6),
         d3.hsl(60, 1.0, 0.6),
         d3.hsl(30, 1.0, 0.6),
         d3.hsl(0, 1.0, 0.6),
         d3.hsl(0, 1.0, 0.1)]


y-pixel = 0

plot-interpolated-data = ->
  y-pixel := height

  render-line = ->
    if y-pixel >= 0
      for x-pixel from 0 to width by 2
        y = min-latitude + dy * y-pixel
        x = min-longitude + dx * x-pixel
        z = 0 >? idw-interpolate samples, 4.0, [x, y]

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

#current.on \value ->
d3.csv "http://datapipes.okfnlabs.org/csv/?url=http%3A//opendata.epa.gov.tw/ws/Data/AQX/%3F%24orderby%3DSiteName%26%24skip%3D0%26%24top%3D1000%26format%3Dcsv" ->
  rain-data := {[e.SiteName, e] for e in it}
  d3.select \#rainfall-timestamp
    .text "DATE: #{it.0.PublishTime}"

  d3.select \#station-name
    .text "已更新"

  update-seven-segment "    "

  samples := for st in stations when rain-data[st.name]? and not isNaN rain-data[st.name][\PM10]
    [+st.lng, +st.lat, parseFloat rain-data[st.name][\PM10]]

  # calculate the legend
  y = 0
  svg.append \rect
    .attr \width 150
    .attr \height 32*5
    .attr \x 20
    .attr \y 20
    .style \fill \#000000
    .style \stroke \#555555
    .style \stroke-width \2
  for c in [0, 50, 100, 200, 300]
    y += 30
    legend = svg.append \g
    legend
      .append \rect
      .attr \width 20
      .attr \height 20
      .attr \x 30
      .attr \y y
      .style \fill color-of c
    legend
      .append \text
      .attr \x 55
      .attr \y y+15
      .attr \d \.35em
      .text c+' 微克/立方公尺'
      .style \fill \#AAAAAA
      .style \font-size \10px

  # update station's value
  svg.selectAll \circle
    .data stations
    .style \fill (st) ->
      if rain-data[st.name]? and not isNaN rain-data[st.name][\PM10]
        color-of parseFloat rain-data[st.name][\PM10]
      else
        \#FFFFFF
    .on \mouseover (d, i) ->
      d3.select \#station-name
        .text d.name

      if rain-data[d.name]? and not isNaN rain-data[d.name][\PM10]
        raw-value = (parseInt rain-data[d.name][\PM10]) + ""
        update-seven-segment (" " * (0 >? 4 - raw-value.length)) + raw-value
      else
        update-seven-segment "----"

  # plot interpolated value
  plot-interpolated-data!
