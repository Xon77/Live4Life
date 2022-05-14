WFSPathTransformerDef( \reverse, 
		{ |f, path|
		var positions;
		switch( f.get( \reverse ),
			\all, {
				path.positions = path.positions.reverse;
				path.times = path.times.reverse;
			},
			\x, {
				positions = path.positions.collect(_.asArray).flop;
				positions[0] = positions[0].reverse;
				path.positions = positions.flop.collect(_.asPoint);
			},
			\y, {
				positions = path.positions.collect(_.asArray).flop;
				positions[1] = positions[1].reverse;
				path.positions = positions.flop.collect(_.asPoint);
			},
			\angles, {
				positions = path.positions.collect({|x|
					x = x.asPolar;
					[ x.rho, x.theta ]
				}).flop;
				positions[1] = positions[1].reverse;
				path.positions = positions.flop.collect({|x|
					Polar( *x ).asPoint
				});
			},
			\distances, {
				positions = path.positions.collect({|x|
					x = x.asPolar;
					[ x.rho, x.theta ]
				}).flop;
				positions[0] = positions[0].reverse;
				path.positions = positions.flop.collect({|x|
					Polar( *x ).asPoint
				});
			},
			\positions, {
				path.positions = path.positions.reverse;
			},
			\times, {
				path.times = path.times.reverse;
			}
		);
		path;
	},
	[ \reverse, \off ]
)	
	.setSpec( \reverse, ListSpec([ \off, \all, \x, \y, \angles, \distances, \positions, \times ]) )