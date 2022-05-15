WFSPathGeneratorDef(
	\spline,
	{ |f, path, n| 
		var start, end, c1, c2;
		var part1;
		start = f.get( \start );
		end = f.get( \end );
		c1 = f.get( \c1 );
		c2 = f.get( \c2 );
		part1 = [ start, end ].splineIntPart1( c1, c2 );
		path.positions = n.collect({ |i|
			part1.splineIntPart2( i / (n-1) )
		});
		path;
	},
	[ \start, 0@0, \end, 5@5, \c1, 0@5, \c2, 5@0 ]
)	
	.changesT_( false )
	.setSpec( \start, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \end, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \c1, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \c2, PointSpec( 200, 0.1@0.1 ) );