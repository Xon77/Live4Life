ArrayTransformerDef( \scale, { |f, obj|
	var center;
	center = [ obj.maxItem, obj.minItem ].mean;
	((obj - center) * f.get( \scale ) * (if( f.get( \invert ) ) { -1 } { 1 })) + center;
}, [ \scale, 1, \invert, false] )
	.setSpec( \scale, [0,8,7.squared.log,0,1].asSpec )
	.setSpec( \invert, BoolSpec( false ) );