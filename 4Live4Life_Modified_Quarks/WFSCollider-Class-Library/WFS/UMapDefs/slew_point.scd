/*
\slew_point

Creates an UMap for applying a speed limit to point input.

point: the point to lag
maxSpeed: maximum speed in m/s

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \slew_point, { |
		point = #[0.0, 0.0], 
		maxSpeed = 1
		|
	point = Slew.kr( point, maxSpeed, maxSpeed );
	UMapOut.kr(point, false);
})
	.setSpec( \point, WFSPointSpec(200, 0.1) )
	.setSpec( \maxSpeed, [0,344,8].asSpec )
	.category_( 'point_filter' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})