/*
\random_point

Creates an UMap that generates a new random point value each time it is started. This UMap can also be used on 'init' mode parameters.

center: (Point) the center of the rectangle within which a random point can be generated. 
radius: (Point) x and y radius of the rectangle within which the random point is generated.
value: the output point (can only be changed by the UMap itself)

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

FuncUMapDef( \random_point, { |
		unit, 
		center = #[0.0,0.0],
		radius = #[10.0,10.0]|
	(center + radius.rand2).asPoint;
})	
	.category_( 'random' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec ) or: { 
			unit.getSpec( key ).isKindOf( UAdaptSpec )
		}
	})
	.valueIsMapped_( false )
	.numChannels_( 2 )
	.setSpec( \value, DisplaySpec( PointSpec(Rect(0,0,1,1)), { |point|
		"% @ %".format(point.x, point.y ) 
	}) )
	.setDefault( \value, 0.0@0.0 )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) );