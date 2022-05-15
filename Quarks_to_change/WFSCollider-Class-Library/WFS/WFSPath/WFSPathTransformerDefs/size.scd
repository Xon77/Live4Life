WFSPathTransformerDef( \size, 
	{ |f, path|
		var oldTimes;
		var newPos, newTimes;
		var mode, n;
		mode = f.get( \mode );
		n = f.get( \size ).asInteger;
		switch( mode,
			\interpolate, {
				newTimes = [0] ++ path.times.integrate;
				newTimes = newTimes.resize( n, \linear, false );
				newPos = newTimes.collect({ |item| path.atTime( item ) });
				newTimes = newTimes.differentiate[1..];
			}, 
			\wrap, {
				oldTimes = path.times ++ [ path.times.last ];
				newPos = n.collect({ |i|
					path.positions.wrapAt( i ).copy;
				});
				newTimes = n.collect({ |i|
					oldTimes.wrapAt( i );
				});
				newTimes.pop;
				oldTimes.pop;
				newTimes = newTimes.normalizeSum( oldTimes.sum );
			},
			\fold, {
				oldTimes = path.times ++ [ path.times.last ];
				newPos = n.collect({ |i|
					path.positions.foldAt( i ).copy;
				});
				newTimes = n.collect({ |i|
					oldTimes.foldAt( i );
				});
				newTimes.pop;
				oldTimes.pop;
				newTimes = newTimes.normalizeSum( oldTimes.sum );
			
			}
		);
		path.positions_( newPos ).times_( newTimes );
	},
	[ \size, 10, \mode, \interpolate ],
	{ |f, path| [ \size, path.positions.size, \mode, f.get( \mode ) ] }
)
	.setSpec( \size, PositiveIntegerSpec(2, 2) )
	.setSpec( \mode, ListSpec( [ \interpolate, \wrap, \fold ] ) )
	.useSelection_( false );