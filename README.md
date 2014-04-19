twgeojson
============

# Synopsis

```javascript
var county = require('twgeojson/twCounty1982');

projection = d3.geo.mercator().scale(50000).translate([-16500, 3650]);
```

# Demo

* http://g0v.github.com/twgeojson/

# Description

The package provides the geojson files for administrative divisions in Taiwan.
The data has been simplified with d3.simplify and is suitable for geographical visualisation.
The county level data file is about 64K in size.

For raw data or different levels of simplification, see Makefile for the rules
generating them.

# Installation

Use npm to install all required modules, including d3:

    npm install


To build taiwan geographic json files you'll need the following:
 * unrar - install it with 'brew install unrar' or your favorite package manager.

then build json files with make:

    make twVote1982.topo.json
    make twVillage1982.topo.json
    make twTown1982.topo.json
    make twCounty2010.topo.json


# Todo

* Merge subsumed polygons in the 2010 city merge
* Town level translation for the 2010 city merge
* Provide zip code as layer properties for towns
* fix vote/errant.json
* fix XXX-1 to XXX-0

# Note

* we used d3-plugins/simplify to simplify the output json files,
  but d3-plugins/simplify is declared deprecated, replaced by TopoJSON and removed from github.
  Thus, we made some changes to adopt this issue. Please use TopoJSON format instead of GeoJSON in the future.
  
# See Also

* http://www.iot.gov.tw/ct.asp?xItem=154948&ctNode=1091
* https://github.com/d3/d3-plugins/tree/master/simplify

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to twgeojson.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
