/*
\shared_point

** this Udef should be used in conjunction with 'shared_point_in' UMap **

The shared_point Udef creates an unit that is able to share point information with other units used further in the chain. This is useful when multiple units or unit parameters need to use the same point information, or derrive things from it. The shared_point would always need to come first in the order of the chain; it sends the point data to a bus. To retreive the data in another unit use the 'shared_in_point' UMapDef, and make sure the 'id' setting is the same on both. This will only work _within_ a single chain.

point: the point to be shared (can be an UMap)
id: the id (0-99) by which the point can be retreived by 'shared_point_in'

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

Udef( \shared_point, { |point = #[0.0, 0.0]|
	UEnv.kr( extraSilence: 0.2, useGlobalGain: 0 );
	USharedPointOut.kr( \id, point );
})
	.setSpec( \point, WFSPointSpec(200, 0.1) )
	.category_( 'shared_io' );