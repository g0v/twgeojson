var G0V;
G0V = G0V || {};
G0V.TOPOJSON = {};
G0V.TOPOJSON.util = {};
G0V.TOPOJSON.util.isZeroArea = function(coordinate, delta){
  var x, y, coord, i$, len$, v;
  x = void 8;
  y = void 8;
  if (!delta) {
    delta = 0;
  }
  coord = coordinate[0][0] instanceof Array ? coordinate[0] : coordinate;
  for (i$ = 0, len$ = coord.length; i$ < len$; ++i$) {
    v = coord[i$];
    if ((x === void 8 && y === void 8) || (Math.abs(v[0] - x) < delta && Math.abs(v[1] - y) < delta)) {
      x = v[0];
      y = v[1];
    } else {
      return false;
    }
  }
  return true;
};
G0V.TOPOJSON.util.filterOutZeroArea = function(coordinates, delta){
  var newCoord, i$, len$, coord;
  newCoord = [];
  for (i$ = 0, len$ = coordinates.length; i$ < len$; ++i$) {
    coord = coordinates[i$];
    if (!G0V.TOPOJSON.util.isZeroArea(coord, delta)) {
      newCoord.push(coord);
    }
  }
  return newCoord;
};