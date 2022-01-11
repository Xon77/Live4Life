/*
\p_map_polar

Creates an pattern UMap for converting angle and distance (rho, theta) to a cartesian point

rho: distance from center (0-1)
theta: angle (-pi - pi)
center: center of the mapped area
radius: radius of the mapped area

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UPatDef( \p_map_polar, { |unit,
		rho = 0, 
		theta = 0,
		center = (0@0),
		radius = (10@10)|
	{	
		loop {
			(Polar(rho.next, theta.next).asPoint.asArray * radius.next.asArray + center.next.asArray).asPoint.yield
		};
	}.r
}).category_( 'pattern_point' )
	.valueIsMapped_( false )
	.numChannels_( 2 )
	.setSpec( \value, DisplaySpec( PointSpec(Rect(0,0,1,1)), { |point|
		"% @ %".format(point.x, point.y ) 
	}) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) )
	.setDefault( \radius, 10@10 )
	.setSpec( \rho, [0,1,\lin,0,0].asSpec )
	.setSpec( \theta, AngleSpec() )
	.canUseUMapFunc_({ |unit, key, umapdef|
		var spec;
		spec = unit.getSpec( key );
		[ PointSpec, UAdaptSpec ].any({ |class| spec.isKindOf( class ); });
	});