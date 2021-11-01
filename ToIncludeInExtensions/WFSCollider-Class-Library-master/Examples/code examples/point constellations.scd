// below is code for generating groups of moving or static points

(
// circle
n = 12; // number of events
r = 8; // radius
a = UScore(
	*n.collect({ |i|
		UChain(0, i,
			[ \formant, [ 
				\freq, 50.0 rrand: 60,
				\formant, 100 exprand: 1000,
			] ], 
			[ \tremolo, [ \speed, (i*3/n) ] ],
			[ \wfsSource, [ \point, Polar(r, i.linlin(0,n,0,2pi) ).asPoint ] ]
		).duration_( 10 ).fadeOut_( 1 );
	})
);
a.gui;
)


(
// moving circle (check the WFSPositionTracker)
n = 12; // number of events
r = 8; // radius
b = UScore(
	*n.collect({ |i|
		UChain(0, i,
			[ \formant, [ 
				\freq, 100.0 rrand: 120,
				\formant, 130 exprand: 1200,
			] ], 
			[ \wfsSource, [ \point, [ \circle_trajectory, [ 
					\speed, 0.1, 
					\startAngle, i.linlin(0,n,-pi,pi),
					\radius, r@r 
				 ] ] 
			] ]
		).duration_( 10 ).fadeOut_( 1 );
	})
);
b.gui;
)

(
// swarm
n = 12; // number of events
r = 12; // radius
c = UScore(
	*n.collect({ |i|
		UChain(0, i,
			[ \formant, [ 
				\freq, 600.0 rrand: 1000,
				\formant, 1400 exprand: 2000,
			] ], 
			[ \wfsSource, [ \point, [ \random_trajectory, [
					\speed, 0.7,
					\radius, r@r,
					\seed, 1234,
					\center, [ \random_trajectory, [
						\speed, 2,
						\radius, 2@2,
					] ]
				] ] 
			] ]
		).duration_( 10 ).fadeOut_( 1 ).gain_( -6 );
	})
);
c.gui;
)

(
// line
n = 12; // number of events
p = -8 @ -8; // start point
q = 8 @ 8; // end point
d = UScore(
	*n.collect({ |i|
		UChain(0, i,
			[ \formant, [ 
				\freq, (44 + (i*2)).midicps,
				\formant, 100 exprand: 1000,
			] ], 
			[ \tremolo, [ \speed, i.linlin(0,n-1,0.5,1.5), \smooth, 0.05 ] ],
			[ \wfsSource, [ \point, i.linlin( 0@0, (n-1)@(n-1), p, q ) ] ]
		).duration_( 10 ).fadeOut_( 1 );
	})
);
d.gui;
)

(
// rotating line
n = 12; // number of events
r = 8; // radius
e = UScore(
	*n.collect({ |i|
		UChain(0, i,
			[ \formant, [ 
				\freq, 160.0 rrand: 280,
				\formant, 280 exprand: 2000,
			] ], 
			[ \wfsSource, [ \point, [ \circle_trajectory, [
					\speed, 0.1,
					\startAngle, if( i < (n/2) ) { 0 } { pi },
					\radius, i.linlin(0,n-1,r.neg,r).abs.asPoint 
				] ]
			] ]
		).duration_( 10 ).fadeOut_( 1 );
	})
);
e.gui;
)

(
// all scores together in one:
UScore( 
	a.name_( "circle" ),
	b.name_( "moving circle" ).startTime_(10).track_(1),
	c.name_( "swarm" ).startTime_(20),
	d.name_( "line" ).startTime_(30).track_(1),
	e.name_( "rotating line" ).startTime_(40),
).gui;
)



