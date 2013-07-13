var smallscale, bigscale, changescale, rainscale;
smallscale = [1, 2, 6, 10, 15, 20, 30, 40, 50, 70, 90, 110, 130, 150, 200, 300];
bigscale = [10, 20, 60, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1200, 1500];
changescale = function(scale){
  return d3.scale.quantile().domain(scale).range(['#c5bec2', '#99feff', '#00ccfc', '#0795fd', '#025ffe', '#3c9700', '#2bfe00', '#fdfe00', '#ffcb00', '#eaa200', '#f30500', '#d60002', '#9e0003', '#9e009d', '#d400d1', '#fa00ff', '#facefb']);
};
rainscale = changescale(bigscale);
d3.json("stations.json", function(stations){
  var root, current, rainToday;
  root = new Firebase("https://cwbtw.firebaseio.com");
  current = root.child("rainfall/2013-07-13/23:50:00");
  rainToday = {};
  return d3.json("twCounty2010.topo.json", function(countiestopo){
    var proj, counties, path, extent, regions, it, world, setscale, addGeoObject, init3d;
    proj = mtw();
    counties = topojson.feature(countiestopo, countiestopo.objects['twCounty2010.geo']);
    path = d3.geo.path().projection(proj);
    extent = path.bounds(counties);
    regions = d3.geom.voronoi().clipExtent(extent)((function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = stations).length; i$ < len$; ++i$) {
        it = ref$[i$];
        results$.push(proj([+it.longitude, +it.latitude, it.name]));
      }
      return results$;
    }()));
    current.on('value', function(it){
      var time, data, today, res$, name, parsed, meshes;
      time = it.name();
      data = it.val();
      d3.select('#time').text(time);
      rainToday = data;
      res$ = [];
      for (name in data) {
        today = data[name].today;
        if (parsed = parseFloat(today)) {
          res$.push(parsed);
        }
      }
      today = res$;
      meshes = addGeoObject(world, regions);
      return setTimeout(function(){
        return setInterval(function(){
          var i$, ref$, len$, m, mesh, amount, fraction, results$ = [];
          for (i$ = 0, len$ = (ref$ = meshes).length; i$ < len$; ++i$) {
            m = ref$[i$], mesh = m[0], amount = m[1], fraction = m[2];
            setscale(mesh, amount, fraction);
            results$.push(m[2] += (1 - fraction) / 50);
          }
          return results$;
        }, 50);
      }, 1000);
    });
    setscale = function(mesh, amount, scale){
      mesh.scale.z = scale;
      return mesh.position.y = amount * scale;
    };
    addGeoObject = function(scene, features){
      var meshes, i$, len$, i, geoFeature, mesh, today, ref$, color, material, amount, simpleShapes, j$, len1$, simpleShape, shape3d, x$, toAdd, e;
      meshes = [];
      for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
        i = i$;
        geoFeature = features[i$];
        mesh = $d3g.transformSVGPath("M" + geoFeature.join('L') + "Z");
        today = +((ref$ = rainToday[stations[i].name]) != null ? ref$.today : void 8);
        color = new THREE.Color(rainscale(today)).getHex();
        material = new THREE.MeshLambertMaterial({
          color: color
        });
        amount = today * 0.3;
        simpleShapes = mesh.toShapes(false);
        for (j$ = 0, len1$ = simpleShapes.length; j$ < len1$; ++j$) {
          simpleShape = simpleShapes[j$];
          try {
            shape3d = simpleShape.extrude({
              amount: amount,
              bevelEnabled: false
            });
            shape3d.boundingSphere = {
              radius: 3 * 100
            };
            x$ = toAdd = new THREE.Mesh(shape3d, material);
            x$.rotation.x = Math.PI / 2;
            x$.translateY(amount);
            x$.translateX(-window.innerWidth / 4);
            x$.translateZ(-window.innerHeight / 2);
            scene.add(toAdd);
            meshes.push([toAdd, amount, 1 / amount]);
            setscale(toAdd, amount, 1 / amount);
          } catch (e$) {
            e = e$;
            console.log(e);
          }
        }
      }
      return meshes;
    };
    init3d = function(){
      var cam, x$, plane, ambientLight, directionalLight;
      world = tQuery.createWorld({
        webGLNeeded: false
      });
      if (!tQuery.World.hasWebGL()) {
        $('#nowebgl').show();
      }
      cam = world.tCamera();
      cam.near = 20.0;
      cam.updateProjectionMatrix();
      world.boilerplate().start();
      x$ = world.getCameraControls();
      x$.rangeY = 3000;
      x$.rangeX = -2000;
      cam.position.set(0, 1000, 600);
      plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 20, 20), new THREE.MeshBasicMaterial({
        color: 5592405,
        wireframe: true
      }));
      plane.rotation.x = -Math.PI / 2;
      world.add(plane);
      ambientLight = new THREE.AmbientLight(6316128);
      world.add(ambientLight);
      directionalLight = new THREE.DirectionalLight(16777215);
      directionalLight.position.set(1, 0.75, 0.5).normalize();
      return world.add(directionalLight);
    };
    return $(function(){
      return init3d();
    });
  });
});