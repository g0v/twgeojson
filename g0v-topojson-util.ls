

G0V = G0V || {}

G0V.TOPOJSON = {}

G0V.TOPOJSON.util = {}

let @ = G0V.TOPOJSON.util
  # geoFeature.geometry.coordinates[i]
  @isDeepCoordinate = ( coordinate ) ->
    coordinate[0][0] instanceof Array

  # geoFeature.geometry.coordinates[i], 0.01
  @isZeroArea = ( coordinate, delta = 1/1024 ) ->

    coord = if @isDeepCoordinate coordinate
            then coordinate[0]
            else coordinate

    xmin = Number.MAX_VALUE
    ymin = Number.MAX_VALUE
    xmax = - Number.MAX_VALUE
    ymax = - Number.MAX_VALUE
    for v in coord
      xmin = xmin <? v[0]
      ymin = ymin <? v[1]
      xmax = xmax >? v[0]
      ymax = ymax >? v[1]
      if (xmax - xmin >= delta) and (ymax - ymin >= delta)
        return false
    true

  # geoFeature.geometry.coordinates
  @filterOutZeroArea = ( coordinates, delta ) ->
    newCoords = []
    for coord in coordinates
      if not @isZeroArea( coord, delta )
        newCoords.push coord
    newCoords

  # geoFeature.geometry.coordinate[i], 1/1024
  @filterOutRepeatedPointsSingleList = ( coordinate, delta=1/1024 ) ->
    if not coordinate.length
      return []

    coord = if @isDeepCoordinate coordinate
            then coordinate[0]
            else coordinate

    processList = []

    hasHole = false
    if @isDeepCoordinate coordinate
        for coord in coordinate
            processList.push coord
    else
        processList.push coordinate

    newCoords = []

    for coord in processList
      newCoord = []
      x = void
      y = void
      for v in coord
        if (x==void and y==void) or (Math.abs(v[0]-x)>=delta or Math.abs(v[1]-y)>=delta)
          x = v[0]
          y = v[1]
          newCoord.push v
      if newCoord.length >= 3
        newCoords.push newCoord

    if @isDeepCoordinate coordinate
    then newCoords
    else newCoords[0]

  # geoFeature.geometry.coordinates
  @filterOutRepeatedPoints = ( coordinates, delta ) ->
    newCoords = []
    for coord in coordinates
      newCoord = @filterOutRepeatedPointsSingleList( coord, delta )
      length = newCoord.length
      if length
        newCoords.push newCoord
    newCoords
