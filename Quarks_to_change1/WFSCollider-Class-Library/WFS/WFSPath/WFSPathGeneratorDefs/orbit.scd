WFSPathGeneratorDef(
	\orbit,
	{ |f, path, n| 
		var clockwise, startAngle, center, radius, periods;
		var close, nn = n;
		var eccentricity, eccentAngle;
		clockwise = f.get( \clockwise ).binaryValue.linlin( 0,1,-1,1);
		startAngle = (f.get( \startAngle ) / 360) * 2pi;
		center = f.get( \center );
		radius = f.get( \radius );
		periods = f.get( \periods );
		close = f.get( \close );
		eccentricity = f.get( \eccent ).clip( -0.999, 0.999 );
		eccentAngle = (f.get( \eccentAngle ) / 360) * 2pi;
		if( close ) { nn = n-1 };
		path.positions = n.collect({ |i|
			var r, v;
			v = (i.linlin(0,nn,0,2pi * periods) * clockwise) + startAngle + eccentAngle;
			r = (radius * (1-eccentricity.squared)) / (1 + (eccentricity * v.cos) );
			( (v - eccentAngle + [0,0.5pi]).sin.asPoint * r ) + center
		});
		path;
	},
	[ \periods, 1, \close, false, \startAngle, 0, 
		\clockwise, true, \center, 0@0, \radius, 8@8,
		\eccent, 0, \eccentAngle, 0
	]
)
	.changesT_( false )
	.setSpec( \periods, [0, inf, \lin, 0.125, 1].asSpec )
	.setSpec( \startAngle, [-180,180,\lin,1,0].asSpec )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \eccent, [-0.999,0.999,\lin,0,0].asSpec )
	.setSpec( \eccentAngle, [-180,180,\lin,1,0].asSpec );