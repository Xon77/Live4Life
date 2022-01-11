/*
\trajectory

A player for 2D spatial trajectories. The WFSPathGUI; an editor for trajectories, can be called up via the [edit] button in the UChain window. This umap is intended for use on units with PointSpec or WFSPointSpec based args.

trajectory: a WFSPathBuffer object. This object creates and points to a buffer with the data of the trajectory. This buffer is either filled with data sent directly, or data read from a .wfspath file (generated via the [write data] button in the GUI). Data from file is usually more reliable than sending via network.
trigger: a trigger to (re)start the trajectory
addPoint: a point (or point UMap) can be added to the trajectory position, effectively moving the trajectory as a whole.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \trajectory, {
	var sig;
	sig = WFSPathBufferPlayer.kr( \trajectory, \trigger );
	sig = sig + \addPoint.kr([0,0]);
	UMapOut.kr( sig, false );
}, [ 
	[ \trajectory, nil, WFSPathSpec() ], 
	[ \trigger, 1, TriggerSpec() ], 
	[ \addPoint, 0@0, WFSPointSpec(200, 0.1@0.1) ]
])
	.category_( \point_trajectory )
	.canInsert_( false )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});