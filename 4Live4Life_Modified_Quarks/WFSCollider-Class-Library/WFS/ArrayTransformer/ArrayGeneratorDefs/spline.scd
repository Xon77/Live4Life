ArrayGeneratorDef( \spline, { |f, n = 1|
	var range, p1, direction;
	range = f.get( \range );
	p1 = range.splineIntPart1( f.get( \c1 ), f.get( \c2 ) ); 
	direction = (up: 1, down: 0)[ f.get( \direction ) ];
	n.collect({ |i|
		p1.splineIntPart2( i.linlin( 0, n-1, 1-direction, direction).abs ); 
	});
	
}, [ \range, [0,1], \direction, \up, \c1, 1/3, \c2, 2/3 ], { |f, obj|
	[ \range, if( obj.minItem == obj.maxItem ) { [0,1] } { [ obj.minItem, obj.maxItem ] }, 
	\direction, f.get( \direction ), \c1, f.get( \c1 ), \c2, f.get( \c2 )
 ]
} )
	.mappedArgs_([ \range ])
	.setSpec( \range, [0,1].asSpec.asRangeSpec )
	.setSpec( \direction, ListSpec( [\up, \down] ) )
	.setSpec( \c1, [0,1,\lin,0,1/3].asSpec )
	.setSpec( \c2, [0,1,\lin,0, 2/3].asSpec );
