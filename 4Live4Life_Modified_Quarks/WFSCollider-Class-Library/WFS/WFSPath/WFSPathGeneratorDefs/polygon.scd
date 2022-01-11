WFSPathGeneratorDef(
	\polygon,
	{ |f, path, n| 
		var sides, clockwise, orientation, offset, startAngle, center, radius, periods;
		var close, nn = n;
		var polygon;
		clockwise = f.get( \clockwise ).binaryValue.linlin( 0,1,-1,1);
		sides = f.get( \sides );
		orientation = f.get( \orientation );
		startAngle = (orientation / sides) * 2pi;
		center = f.get( \center );
		radius = f.get( \radius );
		offset = f.get( \offset );
		periods = f.get( \periods );
		close = f.get( \close );
		if( close ) { nn = n-1 };
		polygon = ((sides * periods).ceil).asInteger.collect({ |i|
			(((i.linlin(0,sides,0,2pi * periods) * clockwise) + [0,0.5pi] + startAngle)
				.sin.asPoint * radius) + center
		});
		path.positions = n.asInteger.collect({ |i|
			polygon.atL( ((i/nn) + offset ) * sides * periods );
		});
		path;
	},
	[ \sides, 6, \orientation, 0, \offset, 0.0, \periods, 1, \close, false, 
		\clockwise, true, \center, 0@0, \radius, 8@8 
	]
)
	.changesT_( false )
	.setSpec( \sides, [2, inf, \lin, 0.125, 6].asSpec )
	.setSpec( \periods, [0, inf, \lin, 0.125, 1].asSpec )
	.setSpec( \orientation, [-0.5,0.5,\lin,0,0].asSpec )
	.setSpec( \offset, [0.0,1.0,\lin,0,0].asSpec )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) );