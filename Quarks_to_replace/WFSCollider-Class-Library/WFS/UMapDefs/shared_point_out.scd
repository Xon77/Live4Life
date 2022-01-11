/*
\shared_point_out

** this UMapDef should be used in conjunction with 'shared_point_in' **

The shared_point_out UMapDef creates an UMap that is able to share point information with other UMaps used further in the chain. This is useful when multiple units or unit parameters need to use the same point information, or derrive things from it. The shared_point_out would always need to come first in the order of the chain; it sends the point data to a bus. To retreive the data in an other unit or parameter use the 'shared_in_point' UMapDef, and make sure the 'id' setting is the same on both. This will only work _within_ a single chain.

point: the point to be shared (can be an UMap)
id: the id (0-99) by which the point can be retreived by 'shared_point_in'

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \shared_point_out, { |point = #[0.0, 0.0], id = 0|
	id = id * 2;
	ReplaceOut.kr(id + 1200, point[0]);
	ReplaceOut.kr(id + 1201, point[1]);
	UMapOut.kr(point, false);
})
	.setSpec( \point, WFSPointSpec(200, 0.1) )
	.setSpec( \id, SharedPointIDSpec( 0 ) )
	.category_( 'shared_io' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});