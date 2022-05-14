WFSPathTransformerDef( \move, 
	{ |f, path| 
		var toCenterAmt = 0;
		if( f.get( \center ) == true ) {
			toCenterAmt = path.positions.mean
		};
		path.positions_( path.positions + [f.get( \move ) - toCenterAmt ] ); 
	}, 
	[ \center, false, \move, 0@0 ] 
)	
	.setSpec( \move, PointSpec( 200, 0.1 ) )
	.setSpec( \center, BoolSpec(false) )
	.useSelection_( true );