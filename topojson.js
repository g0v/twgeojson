(function(){
  $(document).ready(function(){
    var svg, layer, states, proj, carto;
    svg = d3.select('#map');
    layer = svg.append('g').attr('id', 'layer');
    states = layer.append('g', 'id', 'states').selectAll('path');
    proj = d3.geo.mercator().scale(50000).translate([-16500, 3650]);
    carto = d3.cartogram().projection(proj);
    return d3.json('twCounty1982.topojson', function(topo){
      var geometries, features, path;
      geometries = topo.objects.twCounty1982.geometries;
      features = carto.features(topo, geometries);
      path = d3.geo.path().projection(proj);
      return states = states.data(features).enter().append('path').attr('class', 'state').attr('fill', '#fafafa').attr('stroke-width', '1px').attr('stroke', '#999').attr('d', path);
    });
  });
}).call(this);
