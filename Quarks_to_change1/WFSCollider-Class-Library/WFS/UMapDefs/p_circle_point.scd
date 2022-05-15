/*
\p_circle_point

Creates an pattern UMap for a circular movement of points. New values are generated each time the chain is started, or in a UPattern for each of the generated events.

speed: speed in periods per next point
startAngle: the start angle in radians
clockwise: rotate clockwise if true, counterclockwise if false
center: center of the circle
radius: radius of the circle (can be an ellipse too)

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UPatDef( \p_circle_point, { |unit,
		speed = 0.1, 
		startAngle = 0,
		clockwise = true, 
		center = (0@0),
		radius = (10@10)
		timeBase = \seconds|
	{	
		var i = 0;
		var timer = UPattern.deltaTimer;
		var spd;
		if( timeBase.next === \seconds ) {
			spd = speed.next * clockwise.next.binaryValue.linlin(0,1,-1,1);
			i = spd * UPattern.startPos;
		};
		loop {
			((((((i % 1) * 2pi) + [0, 0.5pi] + startAngle.next).sin 
				* radius.next.asArray) + center.next.asArray))
				.asPoint.yield;
			spd = speed.next * clockwise.next.binaryValue.linlin(0,1,-1,1);
			switch( timeBase.next, 
				\events, { i = i + spd }, 
				\seconds, { i = i + (spd * timer.value); },
			);
		};
	}.r
}).category_( 'pattern_point' )
	.valueIsMapped_( false )
	.numChannels_( 2 )
	.setSpec( \value, DisplaySpec( PointSpec(Rect(0,0,1,1)), { |point|
		"% @ %".format(point.x, point.y ) 
	}) )
	.setDefault( \value, 0.0@0.0 )
	.setDefault( \center, 0.0@0.0 )
	.setDefault( \radius, 10@10 )
	.setSpec( \speed, [ 0, 100, 99.squared.log, 0, 0.1 ].asSpec )
	.setSpec( \startAngle, AngleSpec() )
	.setSpec( \clockwise, BoolSpec( true ) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) )
	.setSpec( \timeBase, ListSpec( [ 'events', 'seconds' ] ) )
	.canUseUMapFunc_({ |unit, key, umapdef|
		var spec;
		spec = unit.getSpec( key );
		[ PointSpec, UAdaptSpec ].any({ |class| spec.isKindOf( class ); });
	});