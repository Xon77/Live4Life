/*
\wfsDynamicDirectional

This udef creates a dynamic point source on the WFS system, with a directional radiation pattern. The position of the source can be changed in realtime (dynamic).

*This feature of WFSCollider is currently under development, please test and report your findings*

point: This point represents the absolute location of the point source.
direction: the direction of the radiation pattern
radiation: defines the radiation pattern in 4 values; [o,d,q,n]
	- o: omnidirectional component (0-1)
	- d: dipole component (0-1)
	- q: quadrupole component (0-1)
	- n: pole multiplier (1-8)
	the graphic interface shows a directional amplitude plot of the currently set values
quality: (i) (\normal or \better) setting for the interpolation quality of the delays.
	normal = linear interpolation
	better = cubic interpolation
Cubic interpolation uses about 50% more cpu.
latencyComp: (i) cancels the delay caused bu the distance of the source. 0 = no compensation, 1 = full compensation. This can reduce the doppler shift for moving sources, and can ensure synchronicity between this source and other sources.
dbRollOff: decrease in level due to a doubling of the distance. In nature this is -6 dB in free field conditions, and might be -3 dB in extremely reverberant rooms.
maxAmpRadius: defines the radius of the circular area in the centre where the level will always be 0 dB. The dbRollOff starts where this area ends. So the larger the area, the louder the sounds outside of it.

Changes to arguments marked with (i) only become effective the next time the event is played.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

var def;

def = FreeUdef( \wfsDynamicDirectional, [	
		[ \point: 		0@0,  	WFSPointSpec( 200, 0.1 ) ],
		[ \direction:		0,		AngleSpec() ],
		[ \radiation:		[0,1,0,1], RadiationPatternSpec() ],
		[ \quality:		0,		ListSpec([ \good, \better ], 0 ) ], // \l or \c
		[ \distanceFilter:	0,		[0,2,\lin,0,1].asSpec ],
		[ \latencyComp:  	0,		[0,1].asSpec ],
		[ \dbRollOff:		-6,		[ -24, 0, \lin, 1, -6 ].asSpec ],
		[ \maxAmpRadius:	2,		[ 1, 5, \lin, 0, 2, "m" ].asSpec ],
		[ \crossfadeLag:	0.2,		[ 0, 1, \lin, 0, 0.2 ].asSpec, true ],
		[ \dontPause:		false,	BoolSpec( false ), true ]
	], true ).category_( \wfs_experimental )
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
		\point, \distanceFilter, \dbRollOff, 
		\maxAmpRadius, \crossfadeLag, \dontPause,
		\u_i_ar_0_bus,
		\u_doneAction, \u_gain, \u_gate, \u_mute,
		\u_fadeIn, \u_fadeOut,
		\u_globalGain,
		\u_globalEQ_setting, \u_globalEQ_bypass,  
	] )
	.envPut( \set_wfsd, [ \point, \u_i_ar_0_bus, \direction, \radiation ] )
	.addUGlobalEQ
	.addUIO( UIn, \ar, 0, 1 )
	.setSpecMode( \latencyComp, \init, \quality, \nonsynth )
	.setSynthFunc_({ |unit ...keyValuePairs|
		unit.synths.do({ |sn|
			var server = sn.server;
			var key = switch( sn.class, Group, \wfsd, Synth, \wfsp );
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
	
if( WFSPreviewSynthDefs.pannerFuncs[\n].keys.includes( WFSLib.previewMode ).not ) {
// dynamic point wfs panner
	def.createSynthFunc_({ |unit, target, startPos = 0|
		var server, n = 0;
		var arrayConfs;
		var arrayGroup;
		var prePanSynth;
		var normalSynths, focusSynths;
		var normalLevelBuses, focusLevelBuses;
		var defNames;
		
		server = target.asTarget.server;
		
		arrayConfs = WFSSpeakerConf.default.getArraysFor( server );
		
		normalLevelBuses = arrayConfs.collect({ |item, i| (i*2) + 2000 });
		focusLevelBuses = arrayConfs.collect({ |item, i| (i*2) + 2001 });
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		defNames = [ 
			[ "wfsd_nd", "wfsd_fd" ], 
			[ switch( unit.get( \quality ), \good, \l_, \better, \c_, \l_ ) ] 
		].flop.collect(_.join);
		
		// make the panner synths, but don't send yet
		normalSynths = arrayConfs.collect({ |item| 
			Synth.basicNew( defNames[0] ++ item.n, server ); 
		}); 
		focusSynths = arrayConfs.collect({ |item| 
			Synth.basicNew( defNames[1] ++ item.n, server ); 
		});
		
		// make the pre-panner synth (has to know the nodeID's of the panner synths)
		prePanSynth = Synth( "wfsp_d_" ++ arrayConfs.size, arrayConfs.collect({ |item,i|
			[ "arrayConf" ++ i, item.asArray, "cornerPoints" ++ i, item.asCornersArray ]
			}).flatten( 1 ) ++ [ 
				\normalLevelBuses, normalLevelBuses, 
				\focusLevelBuses, focusLevelBuses,
				\normalIDs, normalSynths.collect(_.nodeID),
				\focusIDs, focusSynths.collect(_.nodeID),
				\sendPointRate, WFSPositionTracker.getRate,
				\focusWidth, WFSSpeakerConf.default.focusWidth
			] ++ unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ),
			arrayGroup, addAction: \addBefore
		);
		
		
		// send the panner synths
		n = 0;
		normalSynths.do({ |sn, i|
			server.sendMsg( *sn.newMsg( arrayGroup, [ 
					\gain, WFSSpeakerConf.default.gain.dbamp,
					\arrayConf, arrayConfs[i], 
					\amp, ("c" ++ normalLevelBuses[i]).asSymbol,
					\outOffset, n + WFSSpeakerConf.getOutputBusStartOffset( server ),
					\arrayLimit, WFSSpeakerConf.default.arrayLimit,
					\focusWidth, WFSSpeakerConf.default.focusWidth
				] ++ unit.def.env.getInitArgsFor( \wfsd, unit.args, server, startPos ), 
				\addToTail ) 
			);
			n = n + arrayConfs[i].n;
		});
		
		n = 0;
		focusSynths.do({ |sn, i|
			server.sendMsg( *sn.newMsg( arrayGroup, [ 
					\gain, WFSSpeakerConf.default.gain.dbamp,
					\arrayConf, arrayConfs[i], 
					\amp, ("c" ++ focusLevelBuses[i]).asSymbol,
					\outOffset, n + WFSSpeakerConf.getOutputBusStartOffset( server ),
					\arrayLimit, WFSSpeakerConf.default.arrayLimit,
					\focusWidth, WFSSpeakerConf.default.focusWidth
				] ++ unit.def.env.getInitArgsFor( \wfsd, unit.args, server, startPos ), 
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
	def.createSynthFunc_({ |unit, target, startPos = 0|
		var server, n = 0;
		var prePanSynth;
		var previewSynth;
		var arrayGroup;
		
		server = target.asTarget.server;
		
		// make the pre-panner synth (has to know the nodeID's of the panner synths)
		prePanSynth = Synth( "wfsp_d_0",
			unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ) ++ 
				[ \sendPointRate, WFSPositionTracker.getRate ],
			target, \addToTail
		);
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		previewSynth = Synth( 
			WFSPreviewSynthDefs.getDefName( WFSLib.previewMode, \d ),
			unit.def.env.getInitArgsFor( \wfsd, unit.args, server, startPos ) ++
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

def; // return def
