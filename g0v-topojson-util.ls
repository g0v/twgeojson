

G0V = G0V || {}

G0V.TOPOJSON = {}

G0V.TOPOJSON.util = {}

# geoFeature.geometry.coordinates[i], 0.01
G0V.TOPOJSON.util.isZeroArea = ( coordinate, delta ) ->
  x = void
  y = void
  if ( not delta )
    delta = 0

  coord = if (coordinate[0][0] instanceof Array)
          then coordinate[0]
          else coordinate

  for v in coord
    if (x==void and y==void) or (Math.abs(v[0]-x)<delta and Math.abs(v[1]-y)<delta)
        x = v[0]
        y = v[1]
    else
        return false
  true

# geoFeature.geometry.coordinates
G0V.TOPOJSON.util.filterOutZeroArea = ( coordinates, delta ) ->
  newCoord = []
  for coord in coordinates
    if not G0V.TOPOJSON.util.isZeroArea( coord, delta )
      newCoord.push coord
  newCoord

