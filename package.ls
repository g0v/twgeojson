author:
  name: ['Chia-liang Kao']
  email: 'clkao@clkao.org'
name: 'twgeojson'
description: 'GeoJSON files for Administrative divisions in Taiwan'
version: '0.0.3'
repository:
  type: 'git'
  url: 'git://github.com/g0v/twgeojson.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
  """
engines: {node: '*'}
dependencies: {}
devDependencies:
  LiveScript: \1.1.x
  optimist: \*
  d3: \3.0.x
  d3-plugins: "git://github.com/d3/d3-plugins.git"
optionalDependencies: {}
