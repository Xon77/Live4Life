/*
\map_point

Creates an UMap allowing dynamic mapped access to x and y of a point

x: position x (-1 - 1, 0 means center)
y: position y (-1 - 1)
center: center of the mapped area
radius: radius of the mapped area

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

UMapDef( \map_point, { |
		x = 0, 
		y = 0,
		center = #[0.0,0.0],
		radius = #[10.0,10.0]|
	UMapOut.kr([x,y] * radius + center, false );
})
	.mappedArgs_( [] )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) )
	.setSpec( \x, [-1,1,\lin,0,0].asSpec )
	.setSpec( \y, [-1,1,\lin,0,0].asSpec )
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});
