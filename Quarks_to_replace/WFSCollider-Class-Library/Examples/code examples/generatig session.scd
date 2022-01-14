(
f = { 12.collect({ |i|
		var evt;
		evt = UChain(i/2,i+1,rrand(3.0,10.0),false,\sine, \wfsSource).fadeOut_(1).fadeIn_(1);
		evt.units[0].set(\freq,rrand(200.0,600.0) );
		evt.units[1].set(\point, rrand(-5.0,5.0)@rrand(-5.0,5.0));
		evt;
	}) };
z = UScore(*(12.collect({ |i|
		var evt;
		evt = BufSndFile("@resources/sounds/a11wlk01-44_1.aiff", 
				rate: (i-6).midiratio, loop: [true,false].wrapAt(i) ).makeUChain( \wfsSource )
				.releaseSelf_(true).startTime_(i/2).track_(i).fadeOut_(1).fadeIn_(1);
		
		if( evt.duration == inf ) {
			evt.duration = 8; // looped events stopped by UScore
		};
		evt;
	})++f.()++[
	UScore(*f.()++[
		UScore(*f.())
	]
)]));
z.cleanOverlaps;
x = USession(z,
	UChain(\sine,\wfsSource),
	UChain(\sine,\wfsSource),
	UChain(\sine,\wfsSource),
	UChain(\sine,\wfsSource),
	UChainGroup(
		UChain([\sine,[\freq,200]],\wfsSource),
		UChain([\sine,[\freq,400]],\wfsSource)
	)
);
x.gui;
)