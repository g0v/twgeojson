# mostly from:
# three3d editor example and
# http://www.smartjava.org/content/render-geographic-information-3d-threejs-and-d3js
container = void
stats = void
camera = void
scene = void
renderer = void
projector = void
plane = void
cube = void
mouse2D = void
mouse3D = void
ray = void
rollOveredFace = void
isShiftDown = false
theta = 45
isCtrlDown = false
rollOverMesh = void
rollOverMaterial = void
voxelPosition = new THREE.Vector3
tmpVec = new THREE.Vector3
cubeGeo = void
cubeMaterial = void
i = void
intersector = void
gui = void
voxelConfig = {orthographicProjection: false}

init = ->
  container = document.createElement 'div'
  document.body.appendChild container
  info = document.createElement 'div'
  info.style <<< do
    position: 'absolute'
    top: '10px'
    width: '100%'
    textAlign: 'center'
  info.innerHTML = 'press shift to rotate'
  container.appendChild info

  camera := new THREE.CombinedCamera window.innerWidth, window.innerHeight, 45, 1, 10000, -2000, 10000
  camera.position.y = 800
  scene := new THREE.Scene
  rollOverGeo = new THREE.CubeGeometry 50, 50, 50
  rollOverMaterial := new THREE.MeshBasicMaterial {
    color: 16711680
    opacity: 0.5
    transparent: true
  }
  rollOverMesh := new THREE.Mesh rollOverGeo, rollOverMaterial
  scene.add rollOverMesh
  cubeGeo := new THREE.CubeGeometry 50, 50, 50
  cubeMaterial := new THREE.MeshLambertMaterial {
    color: 65408
    ambient: 65408
    shading: THREE.FlatShading
    map: THREE.ImageUtils.loadTexture 'textures/square-outline-textured.png'
  }
  cubeMaterial.color.setHSV 0.1, 0.7, 1
  cubeMaterial.ambient = cubeMaterial.color
  projector := new THREE.Projector
  plane := new THREE.Mesh (new THREE.PlaneGeometry 1000, 1000, 20, 20), new THREE.MeshBasicMaterial {
    color: 5592405
    wireframe: true
  }
  plane.rotation.x = -Math.PI / 2
  scene.add plane
  mouse2D := new THREE.Vector3 0, 10000, 0.5
  ambientLight = new THREE.AmbientLight 6316128
  scene.add ambientLight
  directionalLight = new THREE.DirectionalLight 16777215
  (directionalLight.position.set 1, 0.75, 0.5).normalize!
  scene.add directionalLight
  renderer := new THREE.WebGLRenderer {
    antialias: true
    preserveDrawingBuffer: true
  }
  renderer.setSize window.innerWidth, window.innerHeight
  container.appendChild renderer.domElement
  stats := new Stats
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.top = '0px'
  container.appendChild stats.domElement
  document.addEventListener('mousemove', onDocumentMouseMove, false);
  document.addEventListener 'keydown', onDocumentKeyDown, false
  document.addEventListener 'keyup', onDocumentKeyUp, false
  window.addEventListener 'resize', onWindowResize, false
  gui := new dat.GUI
  gui.add voxelConfig, 'orthographicProjection' .onChange ->
    if voxelConfig.orthographicProjection
      camera.toOrthographic!
      camera.position <<< {x: 1000, y: 707.106, z: 1000}
      theta = 90
    else
      camera.toPerspective!
      camera.position.y = 800
  gui.close!

onWindowResize = ->
  camera.setSize window.innerWidth, window.innerHeight
  camera.updateProjectionMatrix!
  renderer.setSize window.innerWidth, window.innerHeight

getRealIntersector = (intersects) ->
  i = 0
  while i < intersects.length
    intersector = intersects[i]
    return intersector if not (intersector.object is rollOverMesh)
    i++
  null

setVoxelPosition = (intersector) ->
  tmpVec.copy intersector.face.normal
  voxelPosition.add intersector.point, intersector.object.matrixRotationWorld.multiplyVector3 tmpVec
  voxelPosition.x = (Math.floor voxelPosition.x / 50) * 50 + 25
  voxelPosition.y = (Math.floor voxelPosition.y / 50) * 50 + 25
  voxelPosition.z = (Math.floor voxelPosition.z / 50) * 50 + 25

onDocumentMouseMove = (event) ->
  event.preventDefault!
  mouse2D.x = event.clientX / window.innerWidth * 2 - 1
  mouse2D.y = -(event.clientY / window.innerHeight) * 2 + 1

onDocumentKeyDown = (event) ->
  switch event.keyCode
  case 16
    isShiftDown := true
  case 17
    isCtrlDown := true

onDocumentKeyUp = (event) ->
  switch event.keyCode
  case 16
    isShiftDown := false
  case 17
    isCtrlDown := false

save = -> window.open (renderer.domElement.toDataURL 'image/png'), 'mywindow'

animate = ->
  requestAnimationFrame animate
  render!
  stats.update!

render = ->
  theta += mouse2D.x * 3 if isShiftDown
  ray := projector.pickingRay mouse2D.clone!, camera
  intersects = ray.intersectObjects scene.children
  if intersects.length > 0
    intersector = getRealIntersector intersects
    if intersector
      setVoxelPosition intersector
      rollOverMesh.position = voxelPosition
  camera.position.x = 1400 * Math.sin theta * Math.PI / 360
  camera.position.z = 1400 * Math.cos theta * Math.PI / 360
  camera.lookAt scene.position
  renderer.render scene, camera

geo.setupGeo!

projection = d3.geo.mercator!scale 50000 .translate [-16400 3800]
path = d3.geo.path!projection projection

addGeoObject = (data) ->
    meshes = []
    averageValues = []
    totalValues = []
    maxValueAverage = 0
    minValueAverage = -1
    maxValueTotal = 0
    minValueTotal = -1
    i = 0
    while i < data.features.length
      geoFeature = data.features[i]
      feature = path geoFeature
      mesh = $d3g.transformSVGPath feature
      meshes.push mesh

      value = parseInt Math.random! * 100
      maxValueAverage = value if value > maxValueAverage
      if value < minValueAverage || minValueAverage is -1 then minValueAverage = value
      averageValues.push value

      value = parseInt Math.random! * 100
      if value > maxValueTotal then maxValueTotal = value
      if value < minValueTotal || minValueTotal is -1 then minValueTotal = value
      totalValues.push value
      i++
    i = 0
    while i < averageValues.length
      scale = (averageValues[i] - minValueAverage) / (maxValueAverage - minValueAverage) * 255
      mathColor = gradient (Math.round scale), 255
      material = new THREE.MeshLambertMaterial {color: mathColor}
      extrude = (totalValues[i] - minValueTotal) / (maxValueTotal - minValueTotal) * 100
      shape3d = meshes[i].extrude {
        amount: Math.round extrude
        bevelEnabled: false
      }
      toAdd = new THREE.Mesh shape3d, material
      toAdd.rotation.x = Math.PI / 2
      toAdd.translateY extrude / 2
      scene.add toAdd
      i++
gradient = (length, maxLength) ->
    i = length * 255 / maxLength
    r = i
    g = 255 - i
    b = 0
    rgb = b .|. g .<<. 8 .|. r .<<. 16
    rgb


init3d = ->
    if not Detector.webgl
        Detector.addGetWebGLMessage!
        $ ->
            $ \#nowebgl .show!
        return
    init!
    data <- d3.json "twCounty1982.json"
    addGeoObject data
    animate!
