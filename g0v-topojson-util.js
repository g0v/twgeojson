var G0V;
G0V = G0V || {};
G0V.TOPOJSON = {};
G0V.TOPOJSON.util = {};
(function(){
  this.isDeepCoordinate = function(coordinate){
    return coordinate[0][0] instanceof Array;
  };
  this.isZeroArea = function(coordinate, delta){
    var coord, xmin, ymin, xmax, ymax, i$, len$, v, ref$;
    delta == null && (delta = 1 / 1024);
    coord = this.isDeepCoordinate(coordinate) ? coordinate[0] : coordinate;
    xmin = Number.MAX_VALUE;
    ymin = Number.MAX_VALUE;
    xmax = -Number.MAX_VALUE;
    ymax = -Number.MAX_VALUE;
    for (i$ = 0, len$ = coord.length; i$ < len$; ++i$) {
      v = coord[i$];
      xmin = xmin < (ref$ = v[0]) ? xmin : ref$;
      ymin = ymin < (ref$ = v[1]) ? ymin : ref$;
      xmax = xmax > (ref$ = v[0]) ? xmax : ref$;
      ymax = ymax > (ref$ = v[1]) ? ymax : ref$;
      if (xmax - xmin >= delta && ymax - ymin >= delta) {
        return false;
      }
    }
    return true;
  };
  this.filterOutZeroArea = function(coordinates, delta){
    var newCoords, i$, len$, coord;
    newCoords = [];
    for (i$ = 0, len$ = coordinates.length; i$ < len$; ++i$) {
      coord = coordinates[i$];
      if (!this.isZeroArea(coord, delta)) {
        newCoords.push(coord);
      }
    }
    return newCoords;
  };
  this.filterOutRepeatedPointsSingleList = function(coordinate, delta){
    var coord, processList, hasHole, i$, len$, newCoords, newCoord, x, y, j$, len1$, v;
    delta == null && (delta = 1 / 1024);
    if (!coordinate.length) {
      return [];
    }
    coord = this.isDeepCoordinate(coordinate) ? coordinate[0] : coordinate;
    processList = [];
    hasHole = false;
    if (this.isDeepCoordinate(coordinate)) {
      for (i$ = 0, len$ = coordinate.length; i$ < len$; ++i$) {
        coord = coordinate[i$];
        processList.push(coord);
      }
    } else {
      processList.push(coordinate);
    }
    newCoords = [];
    for (i$ = 0, len$ = processList.length; i$ < len$; ++i$) {
      coord = processList[i$];
      newCoord = [];
      x = void 8;
      y = void 8;
      for (j$ = 0, len1$ = coord.length; j$ < len1$; ++j$) {
        v = coord[j$];
        if ((x === void 8 && y === void 8) || (Math.abs(v[0] - x) >= delta || Math.abs(v[1] - y) >= delta)) {
          x = v[0];
          y = v[1];
          newCoord.push(v);
        }
      }
      if (newCoord.length >= 3) {
        newCoords.push(newCoord);
      }
    }
    if (this.isDeepCoordinate(coordinate)) {
      return newCoords;
    } else {
      return newCoords[0];
    }
  };
  this.filterOutRepeatedPoints = function(coordinates, delta){
    var newCoords, i$, len$, coord, newCoord, length;
    newCoords = [];
    for (i$ = 0, len$ = coordinates.length; i$ < len$; ++i$) {
      coord = coordinates[i$];
      newCoord = this.filterOutRepeatedPointsSingleList(coord, delta);
      length = newCoord.length;
      if (length) {
        newCoords.push(newCoord);
      }
    }
    return newCoords;
  };
}.call(G0V.TOPOJSON.util));