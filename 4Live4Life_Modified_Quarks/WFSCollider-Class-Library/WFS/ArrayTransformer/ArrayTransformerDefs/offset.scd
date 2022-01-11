ArrayTransformerDef( \offset, { |f, obj|
	obj + f.get( \offset );
}, [ \offset, 0 ] ).setSpec( \offset, [-1,1,\lin,0,0].asSpec );