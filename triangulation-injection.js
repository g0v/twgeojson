///
/// Mindos found the code at THREE.Shape.Utils.triangulate2
/// in three.js / src/extras/core/Shape.js and rewrote it.
/// So the author and license should follow the original.


THREE.Shape.Utils.triangulateShape = function( pts, holes ) {

		// For use with Poly2Tri.js

        var i, pt, len;

		var allpts = [];
        len = pts.length;

        if ( len < 3 ) {
            return;
        }

        for (i = 0; i < len; i++) {
            pt = pts[i];
            allpts.push( pt );
		}

		//var allpts = pts.concat( );
		var shape = [];

        len = allpts.length;
        for (i = 0; i < len; i++) {
			shape.push(new js.poly2tri.Point(allpts[i].x, allpts[i].y));
		}

		var swctx = new js.poly2tri.SweepContext(shape);

		for (var h in holes) {
			var aHole = holes[h];
            len = aHole.length;
			var newHole = [];
			for (i=0; i<len; ++i) {
                pt = aHole[i];
                newHole.push(new js.poly2tri.Point(pt.x, pt.y));
                allpts.push(pt);
			}
			swctx.AddHole(newHole);
		}

		var find;
		var findIndexForPt = function (pt) {
			find = new THREE.Vector2(pt.x, pt.y);
			var p;
			for (p=0, pl = allpts.length; p<pl; p++) {
				if (allpts[p].equals(find)) return p;
			}
			return -1;
		};

		// triangulate
		js.poly2tri.sweep.Triangulate(swctx);

		var triangles =  swctx.GetTriangles();
		var tr ;
		var facesPts = [];
		for (var t in triangles) {
			tr =  triangles[t];
			facesPts.push([
				findIndexForPt(tr.GetPoint(0)),
				findIndexForPt(tr.GetPoint(1)),
				findIndexForPt(tr.GetPoint(2))
					]);
		}


	//	console.log(facesPts);
	//	console.log("triangles", triangles.length, triangles);

		// Returns array of faces with 3 element each
	return facesPts;
	}

