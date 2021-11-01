ArrayTransformerDef( \round, { |f, obj|
	if( f.spec.notNil ) {
		f.spec.unmap( f.spec.map( obj ).round( f.getMapped( \round ) ) );
	} {
		obj.round( f.get( \round ) );
	};
}, [ \round, 0.0] )
	.mappedArgs_( [ \round ] )
	.setSpec( \round, UAdaptSpec({ |spec|
		var x;
		if( spec.notNil ) {
			spec = ControlSpec.newFrom( spec );
			if( spec.warp.isKindOf( ExponentialWarp ) ) {
				x = (spec.map(0.5)
					.linlin( spec.minval, spec.maxval, 0, 1 ).reciprocal-1).squared.log;
			};
			spec.minval = 0;
			spec.default = 0;
			if( x.notNil ) { spec.warp = x; };
			spec;
		} {
			ControlSpec( 0, 1, \lin, 0.0, 0 );
		};
	}) 
	);
