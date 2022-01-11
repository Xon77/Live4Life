/*
\crossfade_point

Creates an UMap for crossfading between two points via linear interpolation. The points can also be UMaps.

a: the first point
b: the second point
crossfade: (0-1) the crossfading position (a to b)

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \crossfade_point, { |
		a = #[0.0, 0.0],
		b = #[10.0,10.0],
		crossfade = 0.5|
	UMapOut.kr( (a * (1-crossfade)) + (b * crossfade), false );
})
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})
	.setSpec( \a, WFSPointSpec(200) )
	.setSpec( \b, WFSPointSpec(200) );