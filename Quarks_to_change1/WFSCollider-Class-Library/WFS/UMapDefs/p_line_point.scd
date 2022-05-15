/*
\p_line

Creates an pattern UMap making a line trajectory. New values are generated each time the chain is started, or in a UPattern for each of the generated events.

a: the start point
b: the end point
curve: a curve value (x,y) for the line. A 0 (zero) curve creates a linear line, a positive curve 
value makes the line tend towards the low value, and v.v.
easeIn: a positive value makes the movement start slow, a negative value makes it start fast
easeOut: a positive value makes the movement end slow, a negative value makes it end fast
time: time to it takes from a to b;
loop: loop mode;
	\off: no looping (will stay at end value after completing)
	\loop: (default) wrap around between lo and hi
	\backwards: loop backwards
	\alternate: move back and forth between lo and hi

The 'lo' and 'hi' arg ranges are mapped to that of the parameter to which the UMap is connected

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UPatDef( \p_line_point, { |unit, 
		a = (0@0),
		b = (10@10),
		curve = (0.0@0.0),
		easeIn = 0.0,
		easeOut = 0.0,
		time = 10,
		loop = \loop|
	{
		var current = 0, direction = 1;
		var timer = UPattern.deltaTimer;
		var aa, bb, ccurve;
		if( loop.next === \backwards ) { direction = -1; current = 1; };
		inf.do { |i|
			aa = a.next.asArray;
			bb = b.next.asArray;
			ccurve = curve.next.asArray;
			[0,1].splineIntFunction( current, 
				easeIn.next.linlin(-1,1,2/3,0), 
				easeOut.next.linlin(-1,1,1/3,1)
			).dup.collect({ |item, i|
				item.lincurve(0,1, aa[i], bb[i], ccurve[i]);
			}).asPoint.yield;
			current = (current + ((direction * timer.value/time.next).clip2( 1.0e12 )));
			switch( loop.next,
				\loop, { current = current.wrap( 0.0, 1.0 );  direction = 1 },
				\backwards, { current = current.wrap( 0.0, 1.0 );  direction = -1; },
				\alternate, { 
					case { current > 1 } {
						current = current.fold(0.0,1.0);
						direction = -1;
					} { current < 0 } {
						current = current.fold(0.0,1.0);
						direction = 1;
					};
				},
				\off, { current = current.clip(0.0,1.0); }
			);
		};
	}.r;
})
	.valueIsMapped_( false )
	.numChannels_( 2 )
	.setSpec( \value, DisplaySpec( PointSpec(Rect(0,0,1,1)), { |point|
		"% @ %".format(point.x, point.y ) 
	}) )
	.setDefault( \value, 0.0@0.0 )
	.setDefault( \a, 0.0@0.0 )
	.setDefault( \b, 10@10 )
	.setDefault( \curve, 0@0 )
	.setSpec( \a, WFSPointSpec(200) )
	.setSpec( \b, WFSPointSpec(200) )
	.setSpec( \curve, WFSPointSpec(200) )
	.setSpec( \time, SMPTESpec() )
	.setSpec( \loop, ListSpec( [ \off, \loop, \backwards, \alternate ], 1 ) )
	.category_( 'pattern_point' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		var spec;
		spec = unit.getSpec( key );
		[ PointSpec, UAdaptSpec ].any({ |class| spec.isKindOf( class ); });
	});
