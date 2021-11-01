/*
\wfsStaticIndex

This udef can send sound to an individual speaker on the WFS system. The index of the speaker can not be changed in realtime (static); changes to the index will only become audible after the unit has been stopped and started again.

indexFromBus: set to true if you want to set the index with a controller or by setting index.
index: the number of the speaker, starting at 0.
gain: the output level (dB).

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

(
var def;
def = FreeUdef( \wfsStaticIndex, [	
		[ \index: 		0,  		PositiveIntegerSpec() ],
		[ \gain:			-6,		[ -96, 0, \db, 1, -6].asSpec ],
] )
	.category_( \private )
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
	.setSpecMode( \index, \init )
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

def.removeArgSpec( \startIndex ); // this is set by createSynthFunc
def.removeArgSpec( \i_gain ); // this is set by createSynthFunc

def.uchainInitFunc_({ |unit, chain|
	unit.def = \wfsIndex.asUdef;
});

def
)