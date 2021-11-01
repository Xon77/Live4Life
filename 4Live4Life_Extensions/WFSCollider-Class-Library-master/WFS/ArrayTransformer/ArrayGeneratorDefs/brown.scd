ArrayGeneratorDef( \brown, { |f, n = 1|
	var range, center, step, stream;
	range = f.get( \range );
	thisThread.randSeed = f.get( \seed );
	step = f.get( \step ) * (range[1] - range[0]);
	center = f.get( \center ).linlin(0,1,*range);
	stream = Pcbrown( range[0], range[1], step, center ).asStream;
	stream.nextN( n );
}, [ \range, [0.0,1.0], \step, 0.125, \center, 0.5, \seed, 12345 ], { |f, obj|
	[ 
		\range, if( obj.minItem == obj.maxItem ) { [0,1] } { [ obj.minItem, obj.maxItem ] }, 
		\step, f.get( \step ), 
		\center, f.get( \center ), 
		\seed, 1569325056.rand ]
} )
	.mappedArgs_([ \range ])
	.setSpec( \range, [0,1].asSpec.asRangeSpec )
	.setSpec( \center, [0,1,\lin,0,0.5].asSpec )
	.setSpec( \step, [0,1].asSpec )
	.setSpec( \seed, PositiveIntegerSpec(12345) );