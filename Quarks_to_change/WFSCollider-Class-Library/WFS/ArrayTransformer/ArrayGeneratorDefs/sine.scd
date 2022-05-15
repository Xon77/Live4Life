ArrayGeneratorDef( \sine, { |f, n = 1|
	var phase, periods, range, close;
	periods = f.get( \periods );	
	phase = f.get( \phase ) * pi;
	range = f.get( \range );
	close = f.get( \close ).not.binaryValue;
	n.collect({ |i|
		(i.linlin(0,n-close,0,2pi * periods) + phase).sin.linlin(-1,1,*range);
	});
	
}, [ \range, [0.0,1.0], \periods, 1, \phase, 0, \close, true ], { |f, obj|
	[ \range, if( obj.minItem == obj.maxItem ) { [0,1] } { [ obj.minItem, obj.maxItem ] }, 
	\periods, f.get( \periods ), \phase,  f.get( \phase ), \close, f.get( \close ) ]
} )
	.mappedArgs_([ \range ])
	.setSpec( \periods, [0, inf, \lin, 0.125].asSpec )
	.setSpec( \phase, [0,2,\lin].asSpec )
	.setSpec( \range, [0,1].asSpec.asRangeSpec );