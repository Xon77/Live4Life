ArrayGeneratorDef( \line, { |f, n = 1|
	var a, b, curve;
	if( f.get( \direction ) == \down ) {
		#b, a = f.get( \range );
	} {
		#a, b = f.get( \range );
	};	
	curve = f.get( \curve );
	n.collect({ |i|
		i.lincurve( 0, n-1, a, b, curve );
	});
	
}, [ \range, [0,1], \direction, \up, \curve, 0 ], { |f, obj|
	[ \range, if( obj.minItem == obj.maxItem ) { [0,1] } { [ obj.minItem, obj.maxItem ] }, 
	\direction, f.get( \direction ), \curve, f.get( \curve ) ]
} )
	.mappedArgs_([ \range ])
	.setSpec( \range, [0,1].asSpec.asRangeSpec )
	.setSpec( \direction, ListSpec( [\up, \down] ) )
	.setSpec( \curve, [ -16, 16, \lin, 0, 0 ].asSpec );
