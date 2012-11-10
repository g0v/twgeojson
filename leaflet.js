var map, svg, g;
map = new L.Map('map').setView(new L.LatLng(22.8, 121.9), 7).addLayer(new L.TileLayer('http://{s}.tile.cloudmade.com/ae2dc46faa384973b408b2467d727490/998/256/{z}/{x}/{y}.png'));
svg = d3.select(map.getPanes().overlayPane).append('svg');
g = svg.append('g');
d3.json('twCounty2010.json', function(collection){
  var reset, project, bounds, path, feature;
  reset = function(){
    var bottomLeft, topRight;
    bottomLeft = project(bounds[0]);
    topRight = project(bounds[1]);
    svg.attr('width', topRight[0] - bottomLeft[0]).attr('height', bottomLeft[1] - topRight[1]).style('margin-left', bottomLeft[0] + 'px').style('margin-top', topRight[1] + 'px');
    g.attr('transform', 'translate(' + -bottomLeft[0] + ',' + -topRight[1] + ')');
    return feature.attr('d', path);
  };
  project = function(x){
    var point;
    point = map.latLngToLayerPoint(new L.LatLng(x[1], x[0]));
    return [point.x, point.y];
  };
  bounds = d3.geo.bounds(collection);
  path = d3.geo.path().projection(project);
  feature = g.selectAll('path').data(collection.features).enter().append('path');
  map.on('viewreset', function(){
    console.log('reseting');
    return reset();
  });
  return reset();
});