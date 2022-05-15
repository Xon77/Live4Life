WFSPathGeneratorDef(
	\sine,
	{ |f, path, n| 
		var start, end, phase, amp, periods;
		var polar;
		start = f.get( \start );
		end = f.get( \end );
		periods = f.get( \periods );
		amp = f.get( \amp );
		phase = f.get( \phase ) * pi;
		polar = (end - start).asPolar;
		path.positions = n.collect({ |i|
			var sin;
			sin = (i.linlin(0,n-1,0,2pi * periods) + phase).sin * amp;
			( i.linlin(0,n-1,0,polar.rho) @ sin ).rotate( polar.theta ) + start;
		});
		path;
	},
	[ \periods, 1, \phase, 0, \start, 0@0, \end, 5@5, \amp, 2 ]
)
	.changesT_( false )
	.setSpec( \periods, [0, inf, \lin, 0.125].asSpec )
	.setSpec( \phase, [0, 2, \lin].asSpec )
	.setSpec( \start, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \end, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \amp, [ -inf, inf, \lin, 0.125 ].asSpec );