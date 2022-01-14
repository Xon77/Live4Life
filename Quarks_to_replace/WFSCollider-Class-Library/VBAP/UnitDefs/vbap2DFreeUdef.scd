FreeUdef( \vbap2D_Panner, [
    [ \pointFromBus: 	false,	BoolSpec( false ) ],
    [ \point: 	0@0,  	PointSpec( 200, 0.1 ) ],
    [ \lag:		0,  	[ 0, 5, \lin, 0, 0 ].asSpec ], // lagtime for angles,
    [ \latencyComp:  	0,		[0,1].asSpec ],
    [ \dbRollOff:		-6,		[ -24, 0, \lin, 1, -6 ].asSpec ],
    [ \maxAmpRadius:	2,		[ 1, 5, \lin, 0, 2, "m" ].asSpec ],
    [ \spread:  1,	    [ 1, 100.0, \lin, 0, 0 ].asSpec ]
    ])
    .createSynthFunc_({ |unit, target, startPos = 0|

		var conf = VBAPSpeakerConf.default;
		var buf = conf.buffers.at(target.asTarget.server);
		var n = conf.numSpeakers;
		var delays = conf.distances !? VBAPDistComp2.delayTimes(_);

        delays !? { |delays|
            Synth( ("VBAP_2D_DistComp_"++n).asSymbol,
                unit.getArgsFor( target, startPos ) ++ [\u_bufnum,buf.bufnum, \speakerDelays, delays]
                , target, \addToTail );
        } ?? {
            Synth( ("VBAP_2D_"++n).asSymbol,
                unit.getArgsFor( target ) ++ [\u_bufnum,buf.bufnum]
                , target, \addToTail );
        }
    })
    .category_(\vbap_panner)
    .addUEnv
    .addUGlobalEQ
    .addUIO( UIn, \ar, 0, 1 )
    .addUIO( UIn, \kr, 0, 2 );


		