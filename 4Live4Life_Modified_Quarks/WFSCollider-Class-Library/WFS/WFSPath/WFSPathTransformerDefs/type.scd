WFSPathTransformerDef( \type, 
	{ |f, obj| obj
	 	.type_( f.get( \type ) )
	 	.curve_( f.get( \curve ) )
	 	.clipMode_( f.get( \clipMode ) );
	}, 
	 [ \type, \bspline, \curve, 1.0, \clipMode, \clip ], 
	 { |f, obj| [ \type, obj.type, \curve, obj.curve, \clipMode, obj.clipMode ] } 
)	
	.setSpec( \type, ListSpec( [ \bspline, \cubic, \linear ] ) )
 	.setSpec( \curve, ControlSpec( 0, 2, \lin, 0.1, 1 ) )
 	.setSpec( \clipMode, ListSpec( [ \clip, \wrap, \fold ] ) )
 	.useSelection_( false );
