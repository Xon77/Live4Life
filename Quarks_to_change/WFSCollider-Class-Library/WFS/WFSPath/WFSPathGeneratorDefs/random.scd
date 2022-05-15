WFSPathGeneratorDef(
	\random,
	{ |f, path, n| 
		var center, radius;
		center = f.get( \center );
		radius = f.get( \radius );
		thisThread.randSeed = f.get( \seed );
		path.positions = n.collect({ 
			(Polar( 1.0.rand, 2pi.rand ).asPoint * radius ) + center;
		});
		path;
	},
	[ \center, 0@0, \radius, 8@8, \seed, 12345 ]
)
	.changesT_( false )
	.setSpec( \seed, PositiveIntegerSpec(12345) )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) );