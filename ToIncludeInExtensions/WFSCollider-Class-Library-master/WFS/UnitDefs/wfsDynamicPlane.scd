/*
\wfsDynamicPlane

This udef creates a dynamic plane wave source on the WFS system. The position of the source can be changed in realtime (dynamic).

pointFromBus: (Boolean) set to true if you want to set the plane wave from the input of another unit in the chain (such as \wfsPathPlayer or another from the wfs_control category).point: This point represents the closest point of the plane wave to the center.pointLag: damps the movement of the point. This is useful if your controller has a low resolution or the point is changed manually. This uses a second-order filter, which may cause slight oscillations at beginnings and endings of movements. Changing the lag time during playback may cause audible artifacts.quality: (i) (\normal or \better) setting for the interpolation quality of the delays.
	normal = linear interpolation
	better = cubic interpolation
Cubic interpolation uses about 50% more cpu.
latencyComp: (i) cancels the delay caused bu the distance of the source. 0 = no compensation, 1 = full compensation. This can reduce the doppler shift for moving sources, and can ensure synchronicity between this source and other sources.
dbRollOff: decrease in level due to a doubling of the distance. In theory this is should be 0 dB, as perfect plane waves will not loose energy over distance. However, it will in many cases be convenient to use similar settings to point sources (-3 to -6 db) in practice.maxAmpRadius: defines the radius of the circular area in the centre where the level will always be 0 dB. The dbRollOff starts where this area ends. So the larger the area, the louder the sounds outside of it.dontPause: when processes are not sounding, processes are dynamically switched off. However, there could be cases where the movement is too fast for the pausing engine to keep up.

Changes to arguments marked with (i) only become effective the next time the event is played.
--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

var def;

def = FreeUdef( \wfsDynamicPlane, [	
		[ \point: 		0@0,  	WFSPlaneSpec( 200, 0.1 ) ],
		[ \quality:		0,		ListSpec([ \normal, \better ], 0 ) ], // for \l or \c
		[ \latencyComp:  	0,		[0,1].asSpec ],
		[ \dbRollOff:		0,		[ -24, 0, \lin, 1, 0 ].asSpec ],
		[ \maxAmpRadius:	2,		[ 1, 5, \lin, 0, 2, "m" ].asSpec ],
		[ \dontPause:		false,	BoolSpec( false ), true ]
	] )
	.category_( \private )
	// first a few general things
	.envPut( \getArgsFor, { |evt, which, args, server, startPos = 0|
		if( which.notNil ) {
			U.formatArgs( 
				(args ? []).clump(2)
					.select({ |arr| which.includes( arr[0] ) }).flatten(1),
				server,
				startPos
			)
		} {
			[];
		}
	})
	.envPut( \getInitArgsFor, { |evt, defName, args, server, startPos = 0|
		var which;
		which = evt[ ("init_" ++ defName).asSymbol ] ++ evt[ ("set_" ++ defName).asSymbol ];
		evt.getArgsFor( which, args, server, startPos );
	})
	.envPut( \getSetArgsFor, { |evt, defName, args, server, startPos = 0|
		evt.getArgsFor( evt[ ("set_" ++ defName).asSymbol ], args, server, startPos );
	})
	.envPut( \init_wfsp, [ \latencyComp, \u_dur ] )
	.envPut( \set_wfsp, [ 
		\point, \dbRollOff, 
		\maxAmpRadius, \dontPause,
		\u_i_ar_0_bus,
		\u_doneAction, \u_gain, \u_gate, \u_mute,
		\u_fadeIn, \u_fadeOut,
		\u_fadeInCurve, \u_fadeOutCurve,
		\u_globalGain,
		\u_globalEQ_setting, \u_globalEQ_bypass,  
	] )
	.envPut( \set_wfsa, [ \point, \u_i_ar_0_bus ] )
	.addUEnv
	.addUGlobalEQ
	.addUIO( UIn, \ar, 0, 1 )
	.inputIsEndPoint_( true )
	.setSpecMode( \latencyComp, \init, \quality, \init )
	.setSynthFunc_({ |unit ...keyValuePairs|
		unit.synths.do({ |sn|
			var server = sn.server;
			var key = switch( sn.class, Group, \wfsa, Synth, \wfsp );
			server.sendSyncedBundle( Server.default.latency, nil, 
				*server.makeBundle( false, {
		    			sn.set( *unit.def.env.getSetArgsFor( key, keyValuePairs, server ) )
	    			})
	    		);
		})
	});

// ensure backwards compatibility
def.prepareArgsFunc = { |argPairs|
	var point;
	if( argPairs.notNil) {
		if( argPairs.pairsAt( \pointFromBus ) == true ) {
			if( argPairs.includes( \u_i_kr_0_bus ) or: { argPairs.includes( \u_i_kr_1_bus ) } ) {				argPairs = [ \point, [ \map_control_point, [ 
								\bus_x, argPairs.pairsAt( \u_i_kr_0_bus ) ? 0,
								\bus_y, argPairs.pairsAt( \u_i_kr_1_bus ) ? 1
						] 
					],
				  \pointFromBus, false
				] ++	argPairs;	
			} {
				argPairs = [ \point, \map_control_point, \pointFromBus, false ] ++ argPairs;
			};
		};
		if( argPairs.pairsAt( \pointLag ).notNil ) {
			if( argPairs.pairsAt( \point ).notNil ) {
				argPairs = [ \point, [ \lag_point, [ 
					\point, argPairs.pairsAt( \point ),
					\time, argPairs.pairsAt( \pointLag ),
				] ] ] ++ argPairs;
			} {
				argPairs = [ \point, [ \lag_point, [ \time, argPairs.pairsAt( \pointLag ) ] ] ] 
					++ argPairs;
			};
		};
		argPairs;
	};
};

if( WFSPreviewSynthDefs.pannerFuncs.keys.includes( WFSLib.previewMode ).not ) {
	// dynamic plane wfs panner
	def.createSynthFunc_({ |unit, target, startPos = 0|
		var server, n = 0;
		var arrayConfs;
		var arrayGroup;
		var prePanSynth;
		var planeSynths;
		var planeLevelBuses;
		var defName;
		var gain;
		
		server = target.asTarget.server;
		
		arrayConfs = WFSSpeakerConf.default.getArraysFor( server );
		
		planeLevelBuses = arrayConfs.collect({ |item, i| i + 2000 });
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		defName =  "wfsa_pd" ++ switch( unit.get( \quality ), \good, \l_, \better, \c_, \l_ );		
		// make the panner synths, but don't send yet
		planeSynths = arrayConfs.collect({ |item| 
			Synth.basicNew( defName ++ item.n, server ); 
		}); 
		
		// make the pre-panner synth (has to know the nodeID's of the panner synths)
		prePanSynth = Synth( "wfsp_p_" ++ arrayConfs.size, arrayConfs.collect({ |item,i|
			[ "arrayConf" ++ i, item.asArray ]
			}).flatten( 1 ) ++ [ 
				\planeLevelBuses, planeLevelBuses, 
				\planeIDs, planeSynths.collect(_.nodeID),
				\sendPointRate, WFSPositionTracker.getRate
			] ++ unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ),
			arrayGroup, addAction: \addBefore
		);
		
		gain = WFSSpeakerConf.default.gain.dbamp * WFSSpeakerConf.default.planeWaveMakeUpGain;
		
		// send the panner synths
		n = 0;
		planeSynths.do({ |sn, i|
			server.sendMsg( *sn.newMsg( arrayGroup, [ 
					\gain, gain, 
					\arrayConf, arrayConfs[i], 
					\amp, ("c" ++planeLevelBuses[i]).asSymbol,
					\outOffset, n +  WFSSpeakerConf.getOutputBusStartOffset( server )
				] ++ unit.def.env.getInitArgsFor( \wfsa, unit.args, server, startPos ), 
				\addToTail ) 
			);
			n = n + arrayConfs[i].n;
		});
		
		arrayGroup.freeAction_({ |group| unit.removeSynth( group ); });
		unit.addSynth( arrayGroup );
		
		prePanSynth;
	})
	.shouldPlayOnFunc_({ |unit, target|
		WFSSpeakerConf.default.getArraysFor( target.asTarget.server ).size > 0;
	});
} {
	// preview panner; exact same parameters, different panner synthdefs
	// the actual panning in this preview is no different to point sources
	// since there is no difference in a stereo situation in this case
	def.createSynthFunc_({ |unit, target, startPos = 0|
			var server, n = 0;
		var prePanSynth;
		var previewSynth;
		var arrayGroup;
		
		server = target.asTarget.server;		
		
		// make the pre-panner synth (has to know the nodeID's of the panner synths)
		prePanSynth = Synth( "wfsp_p_0",
			unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ) ++
				[ \sendPointRate, WFSPositionTracker.getRate ],
			target, \addToTail
		);
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		previewSynth = Synth( 
			WFSPreviewSynthDefs.getDefName( WFSLib.previewMode, \d ),
			unit.def.env.getInitArgsFor( \wfsa, unit.args, server, startPos ) ++
				[ \out, WFSSpeakerConf.getOutputBusStartOffset( target ) ],
			arrayGroup, \addToTail 
		);
					
		arrayGroup.freeAction_({ |synth| unit.removeSynth( synth ); });
		unit.addSynth( arrayGroup );
		
		prePanSynth;
	})
	.shouldPlayOnFunc_({ |unit, target|
		target.asTarget.server.isLocal; // safety measure: no output on wfs servers
	});
};

def.uchainInitFunc_({ |unit, chain|
	var quality;
	if( unit.point.isUMap.not or: { unit.point.def.allowedModes.includes( \init ); } ) {
		unit.point = [ \lag_point, [ \point, unit.point, \time, 0 ] ]; // force dynamic
	};
	quality = unit.quality;
	unit.def = \wfsSource.asUdef;
	unit.type = \plane;
	unit.quality = quality;
});

def; // return def