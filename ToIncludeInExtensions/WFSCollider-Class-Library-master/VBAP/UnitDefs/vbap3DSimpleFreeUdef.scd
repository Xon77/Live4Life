FreeUdef( \vbap3D_Simple_Panner, [
    [ \anglesFromBus: 	false,	BoolSpec( false ) ],
    [ \angles: 	UnitSpherical(0,0), UnitSphericalSpec() ],
    [ \lag:		0,  	[ 0, 5, \lin, 0, 0 ].asSpec ], // lagtime for angles
    [ \spread:  1,	    [ 1, 100.0, \lin, 0, 0 ].asSpec ]
])
.createSynthFunc_({ |unit, target, startPos = 0, buses|
	if( VBAPLib.previewMode.notNil ) {
		Synth("VBAP_preview_"++VBAPLib.previewMode, unit.getArgsFor( target, startPos, buses ), target, 'addToTail' )
	} {

		var conf = VBAPSpeakerConf.default;
		var buf = conf.buffers.at(target.asTarget.server);
		var n = conf.numSpeakers;
		var delays = conf.distances !? VBAPDistComp2.delayTimes(_);

		delays !? { |delays|
			Synth( ("VBAP_SIMPLE_3D_DistComp_"++n).asSymbol,
				unit.getArgsFor( target, startPos, buses ) ++ [\u_bufnum,buf.bufnum, \u_delays, delays]
				, target, \addToTail );
		} ?? {
			Synth( ("VBAP_SIMPLE_3D_"++n).asSymbol,
				unit.getArgsFor( target, startPos, buses ) ++ [\u_bufnum,buf.bufnum]
				, target, \addToTail );
		}
	}
})
.category_(\vbap_panner)
.addUEnv
.addUGlobalEQ
.addUIO( UIn, \ar, 0, 1 )
.addUIO( UIn, \kr, 0, 2 );


