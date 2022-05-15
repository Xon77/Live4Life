ArrayTransformerDef( \rotate, { |f, obj|
	obj = obj.permute( f.get( \permute ).asInteger );
	obj = obj.rotate( f.get( \rotate ).asInteger );
	if( f.get( \reverse ) == true ) {
		obj.reverse;
	} {
		obj;
	};
}, [ \permute, 0, \rotate, 0, \reverse, false ] )
	.setSpec( \permute, [0,inf,\lin,1,0].asSpec )
	.setSpec( \rotate, [-inf,inf,\lin,1,0].asSpec )
	.setSpec( \reverse, BoolSpec(false) )