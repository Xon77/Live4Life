ArrayGeneratorDef( \pulse, { |f, n = 1|
	var phase, width, periods, range, close, size;
	periods = f.get( \periods );	
	width = f.get( \width );
	phase = f.get( \phase ) / 2;
	range = f.get( \range );
	close = f.get( \close ).not.binaryValue;
	n.collect({ |i|
		((((i * periods) / (n-close)) + phase).wrap(0,1) < width )
			.binaryValue
			.linlin(0,1,*range);
	});
	
}, [ \range, [0.0,1.0], \periods, 1, \width, 0.5, \phase, 0, \close, true ], { |f, obj|
	[ 
		\range, if( obj.minItem == obj.maxItem ) { [0,1] } { [ obj.minItem, obj.maxItem ] }, 
		\periods, f.get( \periods ), 
		\width, f.get( \width ), 
		\phase, f.get( \phase ),
		\close, f.get( \close ) 
	]
} )
	.mappedArgs_([ \range ])
	.setSpec( \periods, [0, inf, \lin, 0.125].asSpec )
	.setSpec( \width, [0, 1, \lin, 0, 0.5].asSpec )
	.setSpec( \phase, [0,2,\lin].asSpec )
	.setSpec( \range, [0,1].asSpec.asRangeSpec );