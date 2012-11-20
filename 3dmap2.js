var container, stats, camera, scene, renderer, projector, plane, cube, mouse2D, mouse3D, ray, rollOveredFace, isShiftDown, theta, isCtrlDown, rollOverMesh, rollOverMaterial, voxelPosition, tmpVec, cubeGeo, cubeMaterial, i, intersector, gui, voxelConfig, init, onWindowResize, getRealIntersector, setVoxelPosition, onDocumentMouseMove, onDocumentKeyDown, onDocumentKeyUp, save, animate, render, projection, path, addGeoObject, gradient, init3d;
container = void 8;
stats = void 8;
camera = void 8;
scene = void 8;
renderer = void 8;
projector = void 8;
plane = void 8;
cube = void 8;
mouse2D = void 8;
mouse3D = void 8;
ray = void 8;
rollOveredFace = void 8;
isShiftDown = false;
theta = 45;
isCtrlDown = false;
rollOverMesh = void 8;
rollOverMaterial = void 8;
voxelPosition = new THREE.Vector3;
tmpVec = new THREE.Vector3;
cubeGeo = void 8;
cubeMaterial = void 8;
i = void 8;
intersector = void 8;
gui = void 8;
voxelConfig = {
  orthographicProjection: false
};
init = function(){
  var container, info, rollOverGeo, ambientLight, directionalLight;
  container = document.createElement('div');
  document.body.appendChild(container);
  info = document.createElement('div');
  import$(info.style, {
    position: 'absolute',
    top: '10px',
    width: '100%',
    textAlign: 'center'
  });
  info.innerHTML = 'press shift to rotate';
  container.appendChild(info);
  camera = new THREE.CombinedCamera(window.innerWidth, window.innerHeight, 45, 1, 10000, -2000, 10000);
  camera.position.y = 800;
  scene = new THREE.Scene;
  rollOverGeo = new THREE.CubeGeometry(50, 50, 50);
  rollOverMaterial = new THREE.MeshBasicMaterial({
    color: 16711680,
    opacity: 0.5,
    transparent: true
  });
  rollOverMesh = new THREE.Mesh(rollOverGeo, rollOverMaterial);
  scene.add(rollOverMesh);
  cubeGeo = new THREE.CubeGeometry(50, 50, 50);
  cubeMaterial = new THREE.MeshLambertMaterial({
    color: 65408,
    ambient: 65408,
    shading: THREE.FlatShading,
    map: THREE.ImageUtils.loadTexture('textures/square-outline-textured.png')
  });
  cubeMaterial.color.setHSV(0.1, 0.7, 1);
  cubeMaterial.ambient = cubeMaterial.color;
  projector = new THREE.Projector;
  plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000, 20, 20), new THREE.MeshBasicMaterial({
    color: 5592405,
    wireframe: true
  }));
  plane.rotation.x = -Math.PI / 2;
  scene.add(plane);
  mouse2D = new THREE.Vector3(0, 10000, 0.5);
  ambientLight = new THREE.AmbientLight(6316128);
  scene.add(ambientLight);
  directionalLight = new THREE.DirectionalLight(16777215);
  directionalLight.position.set(1, 0.75, 0.5).normalize();
  scene.add(directionalLight);
  renderer = new THREE.WebGLRenderer({
    antialias: true,
    preserveDrawingBuffer: true
  });
  renderer.setSize(window.innerWidth, window.innerHeight);
  container.appendChild(renderer.domElement);
  stats = new Stats;
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.top = '0px';
  container.appendChild(stats.domElement);
  document.addEventListener('mousemove', onDocumentMouseMove, false);
  document.addEventListener('keydown', onDocumentKeyDown, false);
  document.addEventListener('keyup', onDocumentKeyUp, false);
  window.addEventListener('resize', onWindowResize, false);
  gui = new dat.GUI;
  gui.add(voxelConfig, 'orthographicProjection').onChange(function(){
    var ref$, theta;
    if (voxelConfig.orthographicProjection) {
      camera.toOrthographic();
      ref$ = camera.position;
      ref$.x = 1000;
      ref$.y = 707.106;
      ref$.z = 1000;
      return theta = 90;
    } else {
      camera.toPerspective();
      return camera.position.y = 800;
    }
  });
  return gui.close();
};
onWindowResize = function(){
  camera.setSize(window.innerWidth, window.innerHeight);
  camera.updateProjectionMatrix();
  return renderer.setSize(window.innerWidth, window.innerHeight);
};
getRealIntersector = function(intersects){
  var i, intersector;
  i = 0;
  while (i < intersects.length) {
    intersector = intersects[i];
    if (!(intersector.object === rollOverMesh)) {
      return intersector;
    }
    i++;
  }
  return null;
};
setVoxelPosition = function(intersector){
  tmpVec.copy(intersector.face.normal);
  voxelPosition.add(intersector.point, intersector.object.matrixRotationWorld.multiplyVector3(tmpVec));
  voxelPosition.x = Math.floor(voxelPosition.x / 50) * 50 + 25;
  voxelPosition.y = Math.floor(voxelPosition.y / 50) * 50 + 25;
  return voxelPosition.z = Math.floor(voxelPosition.z / 50) * 50 + 25;
};
onDocumentMouseMove = function(event){
  event.preventDefault();
  mouse2D.x = event.clientX / window.innerWidth * 2 - 1;
  return mouse2D.y = -(event.clientY / window.innerHeight) * 2 + 1;
};
onDocumentKeyDown = function(event){
  switch (event.keyCode) {
  case 16:
    return isShiftDown = true;
  case 17:
    return isCtrlDown = true;
  }
};
onDocumentKeyUp = function(event){
  switch (event.keyCode) {
  case 16:
    return isShiftDown = false;
  case 17:
    return isCtrlDown = false;
  }
};
save = function(){
  return window.open(renderer.domElement.toDataURL('image/png'), 'mywindow');
};
animate = function(){
  requestAnimationFrame(animate);
  render();
  return stats.update();
};
render = function(){
  var intersects, intersector;
  if (isShiftDown) {
    theta += mouse2D.x * 3;
  }
  ray = projector.pickingRay(mouse2D.clone(), camera);
  intersects = ray.intersectObjects(scene.children);
  if (intersects.length > 0) {
    intersector = getRealIntersector(intersects);
    if (intersector) {
      setVoxelPosition(intersector);
      rollOverMesh.position = voxelPosition;
    }
  }
  camera.position.x = 1400 * Math.sin(theta * Math.PI / 360);
  camera.position.z = 1400 * Math.cos(theta * Math.PI / 360);
  camera.lookAt(scene.position);
  return renderer.render(scene, camera);
};
geo.setupGeo();
projection = d3.geo.mercator().scale(50000).translate([-16400, 3800]);
path = d3.geo.path().projection(projection);
addGeoObject = function(data){
  var meshes, averageValues, totalValues, maxValueAverage, minValueAverage, maxValueTotal, minValueTotal, i, geoFeature, feature, mesh, value, scale, mathColor, material, extrude, shape3d, toAdd, results$ = [];
  meshes = [];
  averageValues = [];
  totalValues = [];
  maxValueAverage = 0;
  minValueAverage = -1;
  maxValueTotal = 0;
  minValueTotal = -1;
  i = 0;
  while (i < data.features.length) {
    geoFeature = data.features[i];
    feature = path(geoFeature);
    mesh = $d3g.transformSVGPath(feature);
    meshes.push(mesh);
    value = parseInt(Math.random() * 100);
    if (value > maxValueAverage) {
      maxValueAverage = value;
    }
    if (value < minValueAverage || minValueAverage === -1) {
      minValueAverage = value;
    }
    averageValues.push(value);
    value = parseInt(Math.random() * 100);
    if (value > maxValueTotal) {
      maxValueTotal = value;
    }
    if (value < minValueTotal || minValueTotal === -1) {
      minValueTotal = value;
    }
    totalValues.push(value);
    i++;
  }
  i = 0;
  while (i < averageValues.length) {
    scale = (averageValues[i] - minValueAverage) / (maxValueAverage - minValueAverage) * 255;
    mathColor = gradient(Math.round(scale), 255);
    material = new THREE.MeshLambertMaterial({
      color: mathColor
    });
    extrude = (totalValues[i] - minValueTotal) / (maxValueTotal - minValueTotal) * 100;
    shape3d = meshes[i].extrude({
      amount: Math.round(extrude),
      bevelEnabled: false
    });
    toAdd = new THREE.Mesh(shape3d, material);
    toAdd.rotation.x = Math.PI / 2;
    toAdd.translateY(extrude / 2);
    scene.add(toAdd);
    results$.push(i++);
  }
  return results$;
};
gradient = function(length, maxLength){
  var i, r, g, b, rgb;
  i = length * 255 / maxLength;
  r = i;
  g = 255 - i;
  b = 0;
  rgb = b | g << 8 | r << 16;
  return rgb;
};
init3d = function(){
  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  }
  init();
  return d3.json("twCounty1982.json", function(data){
    addGeoObject(data);
    return animate();
  });
};
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}