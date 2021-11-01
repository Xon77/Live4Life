WFSPathTransformerDef( \circleSize, 
	{ |f, path|
		var angles, distances;
		var newPos, newTimes;
		var n;
		n = f.get( \size ).asInteger;
		if( path.repondsTo( \times ) ) {
			newTimes = [0] ++ path.times.integrate;
			newTimes = newTimes.resize( n, \linear, false ).differentiate[1..];
			path.times = newTimes;
		};
		angles = path.positions.collect(_.angle);
		distances = path.positions.collect(_.rho);
		
		newPos = path.positions.resize( n, \hermite, true );
		path.positions_( newPos );
	},
	[ \size, 10 ],
	{ |f, path| [ \size, path.positions.size ] }
)
	.setSpec( \size, PositiveIntegerSpec(2, 2) )
	.useSelection_( false );