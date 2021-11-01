/*
\line_trajectory

Creates an UMap for generating a line trajectory between two points. The points can also be UMaps.

a: the start point of the line
b: the end point of the line
curve: a curve value (x,y) for the line. A 0 (zero) curve creates a linear line, a positive curve value makes the line tend towards the low value, and v.v.
easeIn: a positive value makes the movement start slow, a negative value makes it start fast
easeOut: a positive value makes the movement end slow, a negative value makes it end fast
duration: duration of the line in seconds (can be modulated)
loop: loopmode (0: off, 1: loop, 2: alternate)
delay: delay time before the line starts
trigger: a trigger that restarts the line

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \line_trajectory, { |
		a = #[0.0, 0.0],
		b = #[10.0,10.0],
		curve = #[0.0,0.0],
		easeIn = 0.0,
		easeOut = 0.0
		duration = 10|
	var line;
	line = ULine.kr( 0, 1, duration, \loop, \delay, \trigger );
	line = [0,1].splineIntFunction( line, 
		easeIn.linlin(-1,1,2/3,0), 
		easeOut.linlin(-1,1,1/3,1)
	);
	line = 2.collect({ |i|
		Select.kr( curve[i].inRange(-0.001,0.001), [
			line.lincurve(0,1, a[i], b[i], curve[i] ),
			line.linlin(0,1, a[i], b[i] )
		]);
	});
	UMapOut.kr( line, false );
})
	.category_( 'point_trajectory' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})
	.setSpec( \a, WFSPointSpec(200) )
	.setSpec( \b, WFSPointSpec(200) ) 
	.setSpec( \curve, WFSPointSpec(16, 0.1) )
	.setSpec( \easeIn, [-1,1,\lin,0,0].asSpec )
	.setSpec( \easeOut, [-1,1,\lin,0,0].asSpec )
	.setSpec( \duration, SMPTESpec() )
	.setSpec( \delay, SMPTESpec() );