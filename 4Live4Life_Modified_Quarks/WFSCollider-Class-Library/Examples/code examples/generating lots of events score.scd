// the code below generates the 'lots of events.uscore' example score

x = UScore(
	*200.collect({ 
		UChain(10 - (0.5 exprand: 10), 
			[ \formant, [ 
				\freq, (40 rrand: 100).midicps,
				\formant, (60 rrand: 120).midicps,
			] ], 
			[ \wfsSource, [ \point, (20.0 @ 20.0).rand2 ] ]
		).duration_( 0.1 rrand: 0.3 ).fadeOut_( 0.0 rrand: 1.0 );
	}).sort
).cleanOverlaps;
x.gui;