/*
\simpleReverb

** simpleReverb is deprecated, please use FreeVerb and UMaps instead **

This reverb has to be used together with a wfs_control, like wfsPoint. The control busses of wfsPoint have to be connected to the control busses of simpleReverb. To connect the busses, click on i/o in the toolbar. 
The distance of the point from the center of the speaker arrays is used to calculate the damping of the reverb. The maximum damping occurs at a distance of 8 metres. The distance is static and stays the same after the reverb is started.
To mix the reverb with the original signal, another wfs-panner is needed, like wfsStaticPoint. This Udef needs to be placed directly behind the source that goes into simpleReverb.
time: reverb length.room: room size.amp: level of the reverberated signal (wet only).

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef( \simpleReverb, { |point = #[0,0], time = 0.1, room = 0.5, amp = 0.2|
	var in, rev, dist;
	in = UIn.ar( 0, 1 );
	dist = point.asPoint.rho;
	rev = FreeVerb.ar( in, 1, room, dist.linlin(0.0,8.0,0.0,1.0) ) * amp * dist.linlin(0.0,8.0,0.0,1.0);
	UOut.ar( 0, rev )
} )
	.category_( \private )
	.prepareArgsFunc_({ |argPairs|
		argPairs = argPairs.asCollection;
		if( argPairs.includes( \point ).not ) {
			if( argPairs.includes( \u_i_kr_0_bus ) or: { argPairs.includes( \u_i_kr_1_bus ) } ) {				argPairs = [ \point, [ \map_control_point, [ 
							\bus_x, argPairs.pairsAt( \u_i_kr_0_bus ) ? 0,
							\bus_y, argPairs.pairsAt( \u_i_kr_1_bus ) ? 1
						] 
					],
				] ++	argPairs;	
			} {
				argPairs = [ \point, \map_control_point ] ++ argPairs;
			};
		};
		argPairs;
	})
	.setSpec( \point, WFSPointSpec(200,0.1) )
	.setSpec( \room, [ 0, 1, \lin, 0, 0.5 ] )
	.setSpec( \amp, [0,1,\lin, 0.2], \normal )
