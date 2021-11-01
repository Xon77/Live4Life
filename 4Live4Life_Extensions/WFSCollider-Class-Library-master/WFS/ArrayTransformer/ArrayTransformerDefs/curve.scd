ArrayTransformerDef( \curve, { |f, obj|
	var curve, range;
	curve = f.get( \curve );
	range = [ obj.minItem, obj.maxItem ];
	if( (abs(curve) >= 0.001) && { (range[1] - range[0]) > 0 } ) {
		obj.lincurve( *range ++ range ++ [ curve, 'none' ] );
	} {
		obj;
	};
}, [ \curve, 0 ] )
	.setSpec( \curve,  [-16,16,\lin,0,0].asSpec );