WFSPathGeneratorDef(
	\line,
	{ |f, path, n| 
		var start, end, curve;
		start = f.get( \start );
		end = f.get( \end );
		curve = f.get( \curve );
		path.positions = n.collect({ |i|
			Point(
				i.lincurve(0,n-1,start.x,end.x,curve.x),
				i.lincurve(0,n-1,start.y,end.y,curve.y),
			);
		});
	},
	[ \start, 0@0, \end, 5@5, \curve, 0@0 ]
)	
	.changesT_( false )
	.setSpec( \start, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \end, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \curve, PointSpec( 10, 0.1@0.1 ) );