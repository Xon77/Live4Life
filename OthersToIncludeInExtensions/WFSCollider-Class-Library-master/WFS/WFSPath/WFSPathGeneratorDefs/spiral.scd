WFSPathGeneratorDef(
	\spiral,
	{ |f, path, n| 
		var clockwise, startAngle, center, radius, periods;
		var close, nn = n;
		clockwise = f.get( \clockwise ).binaryValue.linlin( 0,1,-1,1);
		startAngle = (f.get( \startAngle ) / 360) * 2pi;
		center = [ f.get( \startCenter ), f.get( \endCenter ) ];
		radius = [ f.get( \startRadius ), f.get( \endRadius ) ];
		periods = f.get( \periods );
		close = f.get( \close );
		if( close ) { nn = n-1 };
		path.positions = n.collect({ |i|
			(((i.linlin(0,nn,0,2pi * periods) * clockwise) + [0,0.5pi] + startAngle)
				.sin.asPoint * radius[0].blend(radius[1], i/nn) ) 
					+ center[0].blend(center[1], i/nn)
		});
		path;
	},
	[ \periods, 1, \close, true, \startAngle, 0, 
		\clockwise, true, \startCenter, 0@0, \startRadius, 8@8,  
		\endCenter, 0@0, \endRadius, 0@0,  
	]
)
	.changesT_( false )
	.setSpec( \periods, [0, inf, \lin, 0.125, 1].asSpec )
	.setSpec( \startAngle, [-180,180,\lin,1,0].asSpec )
	.setSpec( \startCenter, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \startRadius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) )
	.setSpec( \endCenter, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \endRadius, PointSpec( Rect(-200,-200,400,400), 0.1@0.1 ) );