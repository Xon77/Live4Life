WFSPathGeneratorDef(
	\circle,
	{ |f, path, n| 
		var clockwise, startAngle, center, radius, periods;
		var close, nn = n;
		clockwise = f.get( \clockwise ).binaryValue.linlin( 0,1,-1,1);
		startAngle = (f.get( \startAngle ) / 360) * 2pi;
		center = f.get( \center );
		radius = f.get( \radius );
		periods = f.get( \periods );
		close = f.get( \close );
		if( close ) { nn = n-1 };
		path.positions = n.collect({ |i|
			(((i.linlin(0,nn,0,2pi * periods) * clockwise) + [0,0.5pi] + startAngle)
				.sin.asPoint * radius) + center
		});
		path;
	},
	[ \periods, 1, \close, false, \startAngle, 0, 
		\clockwise, true, \center, 0@0, \radius, 8@8 
	]
)
	.changesT_( false )
	.setSpec( \periods, [0, inf, \lin, 0.125, 1].asSpec )
	.setSpec( \startAngle, [-180,180,\lin,1,0].asSpec )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) );