/*
\wfsStaticPlane

This udef creates a static plane wave source on the WFS system. The position of the source can not be changed in realtime (static); changes will only become audible after the unit has been stopped and started again.

point (i): This Point represents the closest point of the plane wave to the center.
latencyComp: (i) cancels the delay caused by the distance of the source. 0 = no compensation, 1 = full compensation. This can ensure synchronicity between this source and other sources.
dbRollOff: decrease in level due to a doubling of the distance. In theory this is should be 0 dB, as perfect plane waves will not loose energy over distance. However, it will in many cases be convenient to use similar settings to point sources (-3 to -6 db) in practice.
maxAmpRadius: defines the radius of the circular area in the centre where the level will always be 0 dB. The dbRollOff starts where this area ends. So the larger the area, the louder the sounds outside of it.

Changes to arguments marked with (i) only become effective the next time the event is played.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

var def;

def = FreeUdef( \wfsStaticPlane, [
		[ \point: 		0@0,  	WFSPlaneSpec( 200, 0.1 ) ],
		[ \latencyComp:  	0,		[0,1].asSpec ],
		[ \dbRollOff:		0,		[ -24, 0, \lin, 1, 0 ].asSpec ],
		[ \maxAmpRadius:	2,		[ 1, 5, \lin, 0, 2, "m" ].asSpec ],
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
	.envPut( \init_wfsp, [ \latencyComp, \u_dur, \point ] ) // controls only set at init
	.envPut( \set_wfsp, [ // controls that can always be set
		\dbRollOff, \maxAmpRadius,
		\u_i_ar_0_bus, 
		\u_doneAction, \u_gain, \u_gate, \u_mute,
		\u_fadeIn, \u_fadeOut,
		\u_fadeInCurve, \u_fadeOutCurve,
		\u_globalGain,
		\u_globalEQ_setting, \u_globalEQ_bypass,  
	] )
	.envPut( \init_wfsa, [ \point ] )
	.envPut( \set_wfsa, [ \u_i_ar_0_bus ] )
	.addUEnv
	.addUGlobalEQ
	.setSpecMode( \latencyComp, \init, \point, \init )
	.addUIO( UIn, \ar, 0, 1 )
	.inputIsEndPoint_( true )
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
	
if( WFSPreviewSynthDefs.pannerFuncs.keys.includes( WFSLib.previewMode ).not ) {
	def.createSynthFunc_({ |unit, target, startPos = 0|
		var server, n = 0;
		var arrayConfs;
		var arrayGroup;
		var prePanSynth;
		var planeLevels;
		var planeSynths = [];
		var defName;
		var crossfader;
		var gain;
		var point;
		
		server = target.asTarget.server;
		
		point = unit.get( \point ).value.asPoint;
		
		arrayConfs = WFSSpeakerConf.default.getArraysFor( server );
		crossfader = WFSCrossfaderPlane( point, arrayConfs );
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		defName = "wfsa_psn_";
				
		planeLevels = crossfader.crossfades;
		
		// make the pre-panner synth (has to know the nodeID's of the panner synths)
		prePanSynth = Synth( "wfsp_n_0",
		 	unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ),
			arrayGroup, addAction: \addBefore
		);
		
		gain = WFSSpeakerConf.default.gain.dbamp * WFSSpeakerConf.default.planeWaveMakeUpGain;
		
		// make the panner synths
		n = 0;
		arrayConfs.do({ |ac, i|
			if( planeLevels[i] > 0 ) {
				planeSynths = planeSynths.add(							Synth( defName ++ ac.n, [ 
							\gain, gain,
							\arrayConf, ac, 
							\outOffset, n + WFSSpeakerConf.getOutputBusStartOffset( server ),
							\amp, planeLevels[i]
						] ++ unit.def.env.getInitArgsFor( \wfsa, unit.args, server, startPos ), 
						arrayGroup, addAction: \addToTail 
					) 
				);
			};
			n = n + arrayConfs[i].n;
		});
				
		arrayGroup.freeAction_({ |group| unit.removeSynth( group ); });
		unit.synths = unit.synths.add( arrayGroup );
		
		prePanSynth;
	})
	.shouldPlayOnFunc_({ |unit, target|
		var arrays, crossfader;
		arrays = WFSSpeakerConf.default.getArraysFor( target.asTarget.server );
		(arrays.size > 0) && {
			crossfader = WFSCrossfaderPlane( unit.get( \point ).uPrepareValue.asPoint, arrays );
			crossfader.crossfades.maxItem > 0;
		};
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
		prePanSynth = Synth( "wfsp_n_0",
		 	unit.def.env.getInitArgsFor( \wfsp, unit.args, server, startPos ),
			target, \addToTail
		);
		
		arrayGroup = Group(target, addAction: \addToTail);
		
		previewSynth = Synth( 
			WFSPreviewSynthDefs.getDefName( WFSLib.previewMode, \s ),
			unit.def.env.getInitArgsFor( \wfsa, unit.args, server, startPos ) ++
				[ \out, WFSSpeakerConf.getOutputBusStartOffset( target ) ],
			arrayGroup, \addToTail 
		);
				
		arrayGroup.freeAction_({ |synth| unit.removeSynth( synth ); });
		unit.synths = unit.synths.add( arrayGroup );
		
		prePanSynth;
	})
	.shouldPlayOnFunc_({ |unit, target|
		target.asTarget.server.isLocal; // safety measure: no output on wfs servers
	});
};

def.uchainInitFunc_({ |unit, chain|
	unit.def = \wfsSource.asUdef;
	unit.type = \plane;
});

def; // return def