/*
\wfsIndex

This udef can send sound to an individual speaker on the WFS system. The index of the speaker can be changed in realtime (dynamic) when attaching an UMap, and will be static when no UMap is attached.

index: the number of the speaker, starting at 0.
gain: the output level (dB).

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

(
var dynamicIndex;
var staticIndex;
var multiDef;

dynamicIndex = HiddenFreeUdef( \dynamic, [	
		[ \index: 		0,  		PositiveIntegerSpec(0,0,191) ],
		[ \gain:			-6,		[ -96, 0, \db, 1, -6].asSpec ],
] )
	.category_( \wfs_panner )
	.synthDef_(
		SynthDef( "wfsi_id", {
			var input, env, maxIndex;
			var gain = -10.dbamp;
			var index = 0, indexFromBus = 0;
			
			index = \index.kr(index);
			
			index = index - \startIndex.kr(0);
			gain = gain * \i_gain.ir(0).dbamp;
			gain = gain * \gain.kr(-6).dbamp;
			maxIndex = NumOutputBuses.ir; // only output to hardware outs
			
			gain = gain * InRange.kr(index, 0, maxIndex); // mute when out of range
			
			input = UGlobalEQ.ar( UIn.ar(0, 1) ) * gain * UEnv.kr;
			
			Out.ar( index.clip(0, maxIndex), input );
		})
	)
	.addSynthDefControls
	.shouldPlayOnFunc_({ |unit, target|
		WFSSpeakerConf.includesServer( target.asTarget.server );
	})
	.createSynthFunc_({ |unit, target, startPos = 0|
		var startIndex;
		startIndex = WFSSpeakerConf.default.firstSpeakerIndexOf( target.asTarget.server );
		Synth( "wfsi_id", [ 
				\startIndex, startIndex - WFSSpeakerConf.getOutputBusStartOffset( target ), 
				\i_gain, WFSSpeakerConf.default.gain 
			] ++ unit.getArgsFor( target, startPos ), 
			target, \addToTail );
	})
	.setControlInName( 0, 'index' );

dynamicIndex.removeArgSpec( \startIndex ); // this is set by createSynthFunc
dynamicIndex.removeArgSpec( \i_gain ); // this is set by createSynthFunc


staticIndex = HiddenFreeUdef( \static, [	
		[ \index: 		0,  		PositiveIntegerSpec(0,0,191) ],
		[ \gain:			-6,		[ -96, 0, \db, 1, -6].asSpec ],
] )
	.category_( \wfs_panner )
	.synthDef_(
		SynthDef( "wfsi_is", {
			var input, env, maxIndex;
			var gain = -10.dbamp;
			var index = 0, indexFromBus = 0;
		
			index = \index.kr(index); // not really static
			index = index - \startIndex.kr(0);
			gain = gain * \i_gain.ir(0).dbamp;
			gain = gain * \gain.kr(-6).dbamp;
			maxIndex = NumOutputBuses.ir; // only output to hardware outs
			
			gain = gain * InRange.kr(index, 0, maxIndex); // mute when out of range
			
			input = UGlobalEQ.ar( UIn.ar(0, 1) ) * gain * UEnv.kr;
			
			Out.ar( index.clip(0, maxIndex), input );
		})
	)
	.addSynthDefControls
	.shouldPlayOnFunc_({ |unit, target|
		target = target.asTarget.server;
		WFSSpeakerConf.includesServer( target ) && {
			unit.get( \index ).inclusivelyBetween( 
				WFSSpeakerConf.default.firstSpeakerIndexOf( target ),
				WFSSpeakerConf.default.lastSpeakerIndexOf( target )
			);
		};
	})
	.createSynthFunc_({ |unit, target, startPos = 0|
		var startIndex;
		startIndex = WFSSpeakerConf.default.firstSpeakerIndexOf( target.asTarget.server );
		Synth( "wfsi_is", [ 
			\startIndex, startIndex - WFSSpeakerConf.getOutputBusStartOffset( target ), 
			\i_gain, WFSSpeakerConf.default.gain 
		] ++ 
			unit.getArgsFor( target.asTarget.server, startPos ), 
			target, \addToTail );
	});

staticIndex.removeArgSpec( \startIndex ); // this is set by createSynthFunc
staticIndex.removeArgSpec( \i_gain ); // this is set by createSynthFunc


multiDef = MultiUdef( \wfsIndex, [ staticIndex, dynamicIndex ], \wfs_panner, \mode, true )
	.dontStoreArgNames_([ \mode ])
	.chooseFunc_( { |args|
		var index;
		index = args.indexOf( \index );
		if( index.notNil && {
			args[index+1].isUMap && {
				args[index+1].def.allowedModes.includes( \init ).not;
			}
		}) { 
			\dynamic;
		} {
			\static;
		};
	} );

)