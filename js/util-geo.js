var geons = {};

// this file contains all the geo related objects and functions
geons.geoConfig = function() {
    this.TRANSLATE_0 = appConstants.TRANSLATE_0;
    this.TRANSLATE_1 = appConstants.TRANSLATE_1;
    this.SCALE = appConstants.SCALE;

    this.mercator = d3.geo.mercator();
    this.path = d3.geo.path().projection(this.mercator);

    this.setupGeo = function() {
        var translate = this.mercator.translate();
        translate[0] = this.TRANSLATE_0;
        translate[1] = this.TRANSLATE_1;

        this.mercator.translate(translate);
        this.mercator.scale(this.SCALE);
    }
}

// geoConfig contains the configuration for the geo functions
geo = new geons.geoConfig();