WFSPathTransformerDef( \scale, 
	{ |f, path| path.positions_( path.positions * [f.get( \scale ) ] ); }, 
	[ \scale, 1@1 ] 
)	
	.setSpec( \scale, PointSpec( 10, 0.1 ) )
	.useSelection_( true );