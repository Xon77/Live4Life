ArrayTransformerDef( \tilt, { |f, obj|
	var tiltAmt, size;
	tiltAmt = ((f.get( \tilt ) * 0.5pi).tan / 2);
	size = obj.size;
	obj.collect({ |item, i|
		item + i.linlin(0,size-1,tiltAmt.neg, tiltAmt)
	});
}, [ \tilt, 0] )
	.setSpec( \tilt, [-1,1,\lin,0,0].asSpec );