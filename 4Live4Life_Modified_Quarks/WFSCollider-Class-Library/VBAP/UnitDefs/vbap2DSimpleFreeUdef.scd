FreeUdef( \vbap2D_Simple_Panner, [
    [ \pointFromBus: 	false,	BoolSpec( false ) ],
    [ \point: 	0@0,  	PointSpec( 200, 0.1 ) ],
    [ \lag:		0,  	[ 0, 5, \lin, 0, 0 ].asSpec ], // lagtime for angles
    [ \spread:  1,	    [ 1, 100.0, \lin, 0, 0 ].asSpec ]
    ])
    .createSynthFunc_({ |unit, target, startPos = 0|

		var conf = VBAPSpeakerConf.default;
		var buf = conf.buffers.at(target.asTarget.server);
		var n = conf.numSpeakers;

		Synth( ("VBAP_SIMPLE_2D_"++n).asSymbol,
		    unit.getArgsFor( target, startPos ) ++ [\u_bufnum,buf.bufnum]
		    , target, \addToTail );
    })
    .category_(\vbap_panner)
    .addUEnv
    .addUGlobalEQ
    .addUIO( UIn, \ar, 0, 1 )
    .addUIO( UIn, \kr, 0, 2 );


		