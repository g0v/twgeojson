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

# See Also

* http://www.iot.gov.tw/ct.asp?xItem=154948&ctNode=1091
* https://github.com/d3/d3-plugins/tree/master/simplify

# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to jscex-jquery.

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
