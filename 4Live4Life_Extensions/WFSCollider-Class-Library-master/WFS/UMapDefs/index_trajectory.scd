/*
\index_trajectory

Creates an UMap for indexing through 2D spatial trajectories. Via the 'index' value, which can be another UMap, all positions on the course of the path can be reached. The index scales between 0 and 1, the start and end positions of the trajectory. The time information stored in the trajectory object is not used; the distance between the breakpoints is used equally. This umap is intended for use on units with PointSpec or WFSPointSpec based args.

index: a value between 0 and 1, referring to the start and end points of the path. If the path is set to 'loop', the path is extended by adding the start point as last point.
trajectory: a WFSPathBuffer object. This object creates and points to a buffer with the data of the trajectory. This buffer is either filled with data sent directly, or data read from a .wfspath file (generated via the [write data] button in the GUI). Data from file is usually more reliable than sending via network. Note that the 'delay' and 'rate' settings have no effect on the behaviour of this UMap.
addPoint: a point (or point UMap) can be added to the trajectory position, effectively moving the trajectory as a whole.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \index_trajectory, {
	var sig, index, bufFrames, numDim = 2;
	var bufnum, startFrame, rate, loop, delay;
	index = \index.kr(0.0);
	#bufnum, startFrame, rate, loop, delay = WFSPathBufferPlayer.getArgs( \trajectory );
	bufFrames = BufFrames.kr( bufnum ) - 1;
	index = (index * (bufFrames + loop));
	sig = BufRd.kr( (numDim * 4) + 1, bufnum, index, 1, 1 );
	sig = numDim.collect({ |i| sig[ (1..4) + (i*4) ].splineIntPart2( index.wrap(0,1) ); });
	sig = sig + \addPoint.kr([0,0]);
	UMapOut.kr( sig, false );
}, [ [ \index, 0, [0,1].asSpec], [ \trajectory, nil, WFSPathSpec() ], [ \addPoint, 0@0, WFSPointSpec(200, 0.1@0.1) ]])
	.category_( \point_utility )
	.canInsert_( false )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});