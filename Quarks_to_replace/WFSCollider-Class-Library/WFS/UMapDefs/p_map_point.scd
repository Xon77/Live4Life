/*
\p_map_point

Creates an pattern UMap allowing mapped access to x and y of a point

x: position x (-1 - 1, 0 means center)
y: position y (-1 - 1)
center: center of the mapped area
radius: radius of the mapped area

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UPatDef( \p_map_point, { |unit,
		x = 0, 
		y = 0,
		center = (0@0),
		radius = (10@10)|
	{	
		loop {
			([x.next, y.next] * radius.next.asArray + center.next.asArray).asPoint.yield
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
	.setSpec( \x, [-1,1,\lin,0,0].asSpec )
	.setSpec( \y, [-1,1,\lin,0,0].asSpec )
	.canUseUMapFunc_({ |unit, key, umapdef|
		var spec;
		spec = unit.getSpec( key );
		[ PointSpec, UAdaptSpec ].any({ |class| spec.isKindOf( class ); });
	});