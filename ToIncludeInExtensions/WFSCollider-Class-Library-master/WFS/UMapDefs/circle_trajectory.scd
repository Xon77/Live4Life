/*
\circle_trajectory

Creates an UMap for generating a circular or elliptical trajectory for modulatable point parameters.

speed: frequency (cycles per second).
startAngle: starting angle of the path in degrees.
clockwise: select to turn clockwise, otherwise the path turns anti-clockwise.
center: the center of the circle (Point).
radius: x and y radius of the circle/ellipse (Point).

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \circle_trajectory, { |
		speed = 0.1, 
		startAngle = 0,
		clockwise = 1, 
		center = #[0.0,0.0],
		radius = #[10.0,10.0],
		u_startPos = 0|
	var circle;
	circle = SinOsc.kr(  
		speed * clockwise.linlin(0,1,-1,1), 
		[ 0, 0.5pi ] + (startAngle + (u_startPos * speed * 2pi).wrap(0,2pi)),
		radius,
		center
	);
	UMapOut.kr( circle, false );
})
	.category_( 'point_trajectory' )
	.canInsert_( false )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})
	.setSpec( \speed, [ 0, 100, 1.calcCurve(0,100), 0, 0.1 ].asSpec )
	.setSpec( \startAngle, AngleSpec() )
	.setSpec( \clockwise, BoolSpec( true ) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) )
	.setSpec( \lag, [ 0, 1, \lin, 0, 0].asSpec );