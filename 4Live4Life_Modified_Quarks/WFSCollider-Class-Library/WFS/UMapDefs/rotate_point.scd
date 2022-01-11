/*
\rotate_point

Creates an UMap intended that rotates and scales an input point.

point: the point to rotate (can be an UMap)
rotate: the amount of rotation in degrees (-pi - pi)
scale: a scale amount (0.25 - 4)

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

UMapDef( \rotate_point, { |point = #[0.0,0.0], rotate = 0.0, scale = 1.0|
	point = point.asPoint;
	point = point.rotate( rotate.neg ) * [scale,scale];
	UMapOut.kr(point.asArray, false);
})
	.setSpec( \point, WFSPointSpec(200) )
	.setSpec( \rotate, AngleSpec() )
	.setSpec( \scale, [0.25,4,\exp,0,1].asSpec )
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});
