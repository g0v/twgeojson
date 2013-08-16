var proj, path, ramp, calculateBBoxSum, addGeoObject, init3d;
proj = mtw().scale(5000);
path = d3.geo.path().projection(proj);
ramp = d3.scale.linear().domain([0, 255]).range(["red", "green"]);
calculateBBoxSum = function(shapes, debugName, debugCW){
  var sum, i$, len$, shape, geometry, bbox, e;
  sum = 0;
  if (shapes.length) {
    for (i$ = 0, len$ = shapes.length; i$ < len$; ++i$) {
      shape = shapes[i$];
      try {
        geometry = shape.makeGeometry();
        bbox = geometry.shapebb;
        sum += (Math.abs(bbox.maxY - bbox.minY) + 1) * (Math.abs(bbox.maxX - bbox.minX) + 1);
      } catch (e$) {
        e = e$;
        console.log("exception in calculateBBoxSum\n");
        console.log(e);
        console.log(shape);
      }
    }
    if (!sum) {
      console.log("Zero sum " + debugName + " " + debugCW + "\n");
      console.log(shapes);
    }
  }
  return sum;
};
addGeoObject = function(scene, features){
  var i$, len$, geoFeature, lresult$, name, coords, mesh, rgb, color, ref$, material, amount, simpleShapes, simpleShapesCCW, j$, len1$, simpleShape, shape3d, x$, toAdd, e, results$ = [];
  for (i$ = 0, len$ = features.length; i$ < len$; ++i$) {
    geoFeature = features[i$];
    lresult$ = [];
    name = geoFeature.properties.name;
    if (true || false) {
      coords = geoFeature.geometry.coordinates;
      coords = G0V.TOPOJSON.util.filterOutZeroArea(coords, 0.01);
      geoFeature.geometry.coordinates = coords;
      mesh = $d3g.transformSVGPath(path(geoFeature));
      rgb = d3.rgb(ramp(Math.random() * 255));
      color = (ref$ = new THREE.Color()).setRGB.apply(ref$, [rgb['r'], rgb['g'], rgb['b']]).getHex();
      material = new THREE.MeshLambertMaterial({
        color: color
      });
      amount = parseInt(Math.random() * 100);
      simpleShapes = mesh.toShapes(false);
      simpleShapesCCW = mesh.toShapes(true);
      simpleShapes = simpleShapesCCW;
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
          x$.rotation.x = Math.PI;
          x$.translateZ(-amount);
          x$.translateX(-window.innerWidth / 4 + 10);
          x$.translateY(-window.innerHeight / 2 + 140);
          lresult$.push(scene.add(toAdd));
        } catch (e$) {
          e = e$;
          console.log("error in extrude " + name + ". Ignored.\n");
          console.log(e);
          lresult$.push(console.log(simpleShape));
        }
      }
    }
    results$.push(lresult$);
  }
  return results$;
};
init3d = function(){
  var world, cam;
  world = tQuery.createWorld({
    webGLNeeded: false
  });
  if (!tQuery.World.hasWebGL()) {
    $(function(){
      return $('#nowebgl').show();
    });
  }
  cam = world.tCamera();
  cam.near = 20.0;
  cam.updateProjectionMatrix();
  console.log(cam.position);
  world.boilerplate().start();
  world.getCameraControls().rangeY = 3000;
  world.getCameraControls().rangeX = -2000;
  cam.position.set(0, 0, 800);
  return d3.json("twCounty2010.topo.json", function(tw){
    var twtopo, data, plane, ambientLight, directionalLight;
    twtopo = topojson.feature(tw, tw.objects['twCounty2010.geo']);
    data = twtopo.features;
    plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 20, 20), new THREE.MeshBasicMaterial({
      color: 5592405,
      wireframe: true
    }));
    plane.rotation.x = Math.PI;
    world.add(plane);
    ambientLight = new THREE.AmbientLight(6316128);
    world.add(ambientLight);
    directionalLight = new THREE.DirectionalLight(16777215);
    directionalLight.position.set(1, 0.75, 0.5).normalize();
    world.add(directionalLight);
    return addGeoObject(world, data);
  });
};