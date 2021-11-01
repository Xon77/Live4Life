/*
\delay_point

Creates an UMap for applying a delay to a point input. When the point is moving the delayed point will always follow behind it.

point: the point to lag
time: the length of the delay.
timeScale: the number of seconds by which 'time' is multiplied. This value can not be changed during playback. 
lag: smoothing time applied to change of delay time, use to prevent sudden jumps during change of delay time.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/


UMapDef( \delay_point, { |
		point = #[0.0, 0.0], 
		time = 0.1,
		timeScale = 1,
		lag = 0
		|
	var delayed;
	time = time.lag3( lag ) * timeScale;
	delayed = DelayC.kr( point, timeScale * 2, time );
	point = Select.kr( Line.kr(0,1,time) >= 1, [Latch.kr( point, Impulse.kr(0) ), delayed] );
	UMapOut.kr(point, false);
})
	.setSpec( \point, WFSPointSpec(200, 0.1) )
	.setSpec( \time, [ 0, 2, \lin, 0, 0.1 ] )
	.setSpec( \timeScale, ListSpec([0.1,1,10],1,["0.1s", "1s", "10s"]), \init )
	.setSpec( \lag, [0,1,\lin].asSpec )
	.category_( 'point_filter' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})