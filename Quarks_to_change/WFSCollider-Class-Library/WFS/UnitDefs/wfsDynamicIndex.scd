/*
\wfsDynamicIndex

This udef can send sound to an individual speaker on the WFS system. The index of the speaker can be changed in realtime (dynamic).

index: the number of the speaker, starting at 0.
gain: the output level (dB).

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

(
var def;
def = FreeUdef( \wfsDynamicIndex, [	
		[ \index: 		0,  		PositiveIntegerSpec() ],
		[ \gain:			-6,		[ -96, 0, \db, 1, -6].asSpec ],
] )
	.category_( \private )
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

def.removeArgSpec( \startIndex ); // this is set by createSynthFunc
def.removeArgSpec( \i_gain ); // this is set by createSynthFunc

def.uchainInitFunc_({ |unit, chain|
	if( unit.index.isUMap.not or: { unit.index.def.allowedModes.includes( \init ); } ) {
		unit.index = [ \lag, [ \value, unit.index, \time, 0 ] ]; // force dynamic
	};
	unit.def = \wfsIndex.asUdef;
});

def
)