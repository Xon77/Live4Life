WFSPathGeneratorDef(
	\lissajous,
	{ |f, path, n| 
		var startAngle, center, radius, periods;
		var close, nn = n;
		startAngle = (f.get( \startAngle ) / 360) * 2pi;
		center = f.get( \center );
		radius = f.get( \radius );
		periods = f.get( \periods );
		close = f.get( \close );
		if( close ) { nn = n-1 };
		path.positions = n.collect({ |i|
			(((i.linlin(0,nn,0,2pi * periods)) + [0,0.5pi] + startAngle)
				.sin.asPoint * radius) + center
		});
		path;
	},
	[ \periods, 1@1, \close, true, \startAngle, 0@0, \center, 0@0, \radius, 8@8 ]
)
	.changesT_( false )
	.setSpec( \periods, PointSpec( 100, 1@1 ))
	.setSpec( \startAngle, PointSpec( 180, 0@0 ) )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) );