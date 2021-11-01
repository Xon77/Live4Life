(
// create a score with soundfiles
z = UScore(
	*12.collect({ |i|
		var evt;
		evt = BufSndFile("@resources/sounds/a11wlk01-44_1.aiff", 
				rate: (i-6).midiratio, loop: [true,false].wrapAt(i) ).makeUChain( \wfsSource )
				.releaseSelf_(true).startTime_(i/2).track_(i).fadeOut_(1).fadeIn_(1);
		
		if( evt.duration == inf ) {
			evt.duration = 8; // looped events limited to 8s
		};
		evt;
	})
);
y = z.gui;
)

(
// create a score with sine waves
z = UScore(
	*12.collect({ |i|
		var evt;
		evt = UChain(i/2,i,rrand(3.0,10.0),\sine, \wfsSource).fadeOut_(1).fadeIn_(1);
		evt.units[0].set(\freq,rrand(200.0,600.0) );
		evt;
	})
);
y = z.gui;
)


z.prepare( s, 0, { "done".postln } );
z.start( s, 0, true );

z.pause; // looped events keep playing
z.resume;

z.stop;

z.start( s, 0, false ); // takes extra wait time for preparing events (depends on content)

z.pos; // returns current position (keeps increasing if not stopped