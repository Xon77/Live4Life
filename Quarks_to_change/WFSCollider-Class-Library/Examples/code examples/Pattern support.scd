// generate a proto event
(
x = UChain( [ 'formant', [ \bw, 1 ] ], [ 'wfsSource', [ \latencyComp, 1 ] ]);
x.gui;
)

( // drone
z.stop;
y = Pbind( 
	\dur, Pwrand( [1,2], [0.9,0.1], inf ) / 10,
	\legato, Pbrown( 0.5, 1.5, 0.25, inf ),
	\formant, Pbrown( 0.0,1, 0.3).linexp(0,1,110,1000),
	\freq, Pwrand( [ 55, 110, 220 ], [ 0.1, 0.8, 0.1 ], inf ),
	\point, Pwhite( (-20.0 @ -20.0), (20.0 @ 20.0) ),
	\track, Pseq( (0..7), inf )
);
z = y.play( protoEvent: x.asProtoEvent  );
/*
y.asUScore( x ).gui; // generate a score
*/
)

( // fast jazz
z.stop;
y = Pbind( 
	\dur, 0.1,
	\fadeOut, Pwhite( 0.0, 0.1 ),
	\legato, Pwhite( 0.5, 2),
	\formant, Pwhite( 0.0,1).linexp(0,1,110,1000),
	\degree, Prand( (1..9).collect({ |item|
		Pseries(0, 2, item) - 6
		}), inf ),
	\root, Pstutter( Pwhite( -6, 6 ), Pwhite( 12, 24 ) ),
	\point, Pwhite( (-20.0 @ -20.0), (20.0 @ 20.0) ),
	\track, Pseq( (0..7), inf )
);
z = y.play( protoEvent: x.asProtoEvent );
/*
y.asUScore( x ).gui; // generate a score
*/
)

( // can your system handle this?
z.stop;
y = Pbind( 
	\dur, Pwhite( 0.01, 0.02 ),
	\legato, 8,
	\formant, Pbrown( 0.0,1, 0.05).linexp(0,1,220,1500),
	\freq, Pwhite( 220.0, 440.0 ),
	\point, Pwhite( (-20.0 @ -20.0), (20.0 @ 20.0) )
);
z = y.play( protoEvent: x.asProtoEvent );
/*
y.asUScore( x, 200 ).cleanOverlaps.gui; // generate a score
*/
)

z.stop;