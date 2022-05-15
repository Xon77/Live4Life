/*
\map_control_point

Creates an lightweight UMap that listens to two control bus from a previous unit in the chain and routes them directly to the point parameter it is connected to. No scaling or clipping is applied, so the user has to make sure that the bus contains data within the allowed input range.

bus_x: the number of the control bus for x(usually 0)
bus_y: the number of the control bus for y (usually 1)

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

FuncUMapDef( \map_control_point, { |unit, bus_x = 0, bus_y = 1|
	[ bus_x, bus_y ].collect({ |bus|
		("c" ++ (bus + UIn.firstControlBus)).asSymbol
	});
}, valueIsPrivate: true )
	.valueIsMapped_( false )
	.numChannels_(2)
	.allowedModes_([ 'normal', 'sync' ])
	.setSpec( \value, AnythingSpec() )
	.setSpec( \bus_x, PositiveIntegerSpec(0,0,31) )
	.setSpec( \bus_y, PositiveIntegerSpec(0,0,31) )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec )
	})
	.category_( 'private' )