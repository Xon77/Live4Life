WFSPathTransformerDef( \equal,
	{ |f, path|
		var oldTimes, deltas;
		var newPos, equalTimes, newTimes;
		var mode, amt;
		
		mode = f.get( \equal );
		amt = f.get( \amount );
		oldTimes = path.times;
		equalTimes = oldTimes.blend( 
			((1/oldTimes.size) * oldTimes.sum)!(oldTimes.size),
			amt 
		);
		
		switch( mode,
			\times, {
				newTimes = equalTimes;
			}, 
			\speeds, {
				deltas = path.positions[1..].collect({ |pos, i|
					pos.dist( path.positions[i] )
				}).normalizeSum;
				oldTimes = path.times;
				newTimes = oldTimes.blend( 
					deltas * oldTimes.sum,
					amt 
				);
				path.times = newTimes;
			}
		);
		
		if( f.get( \resample ) == true ) {
			
			newPos = ([0] ++ equalTimes.integrate).collect({ |item|
				path.atTime( item );
			});
			path.positions = newPos;
			newTimes = equalTimes;
		};
		newTimes = newTimes.max(0); // clip negative times
		path.times_( newTimes );
	},
	[ \equal, \times, \amount, 0, \resample, false ], 
	{ |f, path| [ \equal, f.get( \equal ), \amount, 0, \resample, f.get( \resample ) ] }
)
	.setSpec( \equal, ListSpec( [ \times, \speeds ] ))
	.setSpec( \amount, ControlSpec(-1,1,\lin,0,0) )
	.setSpec( \resample, BoolSpec( false ) )
	.useSelection_( false );
