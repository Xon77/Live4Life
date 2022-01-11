/*
\scale_point

Creates an UMap for scaling and moving a point. The point can also be UMaps.

point: the first point
scale: a multiplier for x/y
move: a point to add to the point

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \scale_point, { |
		point = #[0.0, 0.0],
		scale = #[1.0,1.0],
		move = #[0.0,0.0]|
	UMapOut.kr( (point * scale) + move, false );
})
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})
	.setSpec( \point, WFSPointSpec(200) )
	.setSpec( \scale, WFSPointSpec(200) )
	.setSpec( \move, WFSPointSpec(200) );