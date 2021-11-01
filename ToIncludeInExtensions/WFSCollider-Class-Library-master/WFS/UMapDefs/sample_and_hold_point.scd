/*
\sample_and_hold_point

This UMap implements sample-and-hold process for points. Every time a trigger is received the output point becomes the input point of that moment.

point: the point or point UMap to sample
trigger: the trigger
time: a linear lag time to move to the new point

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \sample_and_hold_point, {
	var point, trigger, output;
	point = \point.kr([0.0,0.0]);
	trigger = \trigger.tr;
	output = Select.kr( Peak.kr( trigger), [ DC.kr( point ), Latch.kr( point, trigger ) ]);
	output = output.varlag( \time.kr(0.0) );
	UMapOut.kr( output, false );
})
.canUseUMapFunc_({ |unit, key, umapdef|
	unit.getSpec( key ).isKindOf( PointSpec );
})
.setSpec( \point, WFSPointSpec(200,0.1) )
.setSpec( \trigger, TriggerSpec() )
.category_( 'point_utility' )