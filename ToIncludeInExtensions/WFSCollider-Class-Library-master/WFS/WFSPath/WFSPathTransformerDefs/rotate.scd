WFSPathTransformerDef( \rotate,  
	{ |f, path| 
		var rotate;
		rotate = (f.get( \rotate ).neg / 360) * 2pi;
		path.positions_( path.positions.collect(_.rotate(rotate)) );
	}, 
	[ \rotate, 0 ] 
)
	.setSpec( \rotate, ControlSpec( -180, 180, \lin, 0, 1 ) )
	.useSelection_( true );