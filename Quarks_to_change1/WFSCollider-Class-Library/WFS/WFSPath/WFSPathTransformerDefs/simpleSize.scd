WFSPathTransformerDef( \simpleSize, 
	{ |f, path|
		var oldTimes;
		var newPos, newTimes;
		var n;
		n = f.get( \size ).asInteger;
		newTimes = [0] ++ path.times.integrate;
		newTimes = newTimes.resize( n, \linear, false );
		newPos = newTimes.collect({ |item| path.atTime( item ) });
		newTimes = newTimes.differentiate[1..];
		path.positions_( newPos ).times_( newTimes );
	},
	[ \size, 10 ],
	{ |f, path| [ \size, path.positions.size ] }
)
	.setSpec( \size, PositiveIntegerSpec(2, 2) )
	.useSelection_( false );