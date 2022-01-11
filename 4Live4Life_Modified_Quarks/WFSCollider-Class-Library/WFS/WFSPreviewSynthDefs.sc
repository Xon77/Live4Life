WFSPreviewSynthDefs : AbstractWFSSynthDefs {
	
	/*
	These synthdefs should be placed after a WFSPrePanSynthDef. 
	They mimick the sound of WFSArrayPanSynthDefs. The preview might
	not be completely accurate.
	*/
	
	classvar <>modes;
	classvar <>types;
	classvar <>pannerFuncs;
	classvar <>panDist = 0.2;
	
	*prefix { ^"wfsx" }
	
	*initClass {
		modes = [ \s, \d ]; // static, dynamic
		types = [ \n, \p ]; // normal (point), plane
		pannerFuncs = ( 
		\n: ( // point
			\headphone: { |in, point|
				// simple headphone panner (ear distance 0.19cm)
				// no HRTFs involved (yet..)
				var distances, globalDist, delays, amplitudes;
				distances = [ -0.095@0, 0.095@0 ].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				delays = ((distances + 0.095 - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.1, delays );
				amplitudes = Pan2.kr( 1, (point.angle - 0.5pi).neg.fold(-0.5pi,0.5pi) / 0.5pi );
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\stereo: { |in, point|
				var distances, globalDist, delays, amplitudes;
				distances = [ -0.3@0, 0.3@0 ].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				delays = ((distances + 0.3 - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = Pan2.kr( 1, (point.angle - 0.5pi).neg.fold(-0.5pi,0.5pi) / 0.5pi );
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\quad: { |in, point| // clockwise quadraphonic panning
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = [ 
					(radius.neg)@radius, radius@radius, 
					radius@(radius.neg), (radius.neg)@(radius.neg)
				].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 4, 1, (point.angle - 0.5pi).neg / pi);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\quad_crossed: { |in, point| // quadraphonic panning L, R, Lb, Rb
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = [ 
					(radius.neg)@radius, radius@radius, 
					radius@(radius.neg), (radius.neg)@(radius.neg)
				].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 4, 1, (point.angle - 0.5pi).neg / pi);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				(in * amplitudes)[[0,1,3,2]];
			},
			\hexa: { |in, point| // clockwise hexaphonic panning, first two speakers left and right of front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((2,1..-3)*2pi/6).collect({ |item|
					Polar(radius,item).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 6, 1, (point.angle - ((2/3)*pi)).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\hexa_pairs: { |in, point| // pair-wise hexaphonic panning, stereo pairs front to back				
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((2,1..-3)*2pi/6).collect({ |item|
					Polar(radius,item).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 6, 1, (point.angle - ((2/3)*pi)).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				(in * amplitudes)[[ 0, 1, 5, 2, 4, 3 ]];
			},
			\octo: { |in, point| // clockwise octophonic panning, first speaker straight front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..7) * -2pi/8).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 8, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\octo_pairs: { |in, point| // pair-wise octophonic panning, stereo pairs from front to back				
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..7) * -2pi/8).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 8, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				(in * amplitudes)[[ 0, 1, 7, 2, 6, 3, 5, 4 ]];
			},
			\hexa_deci: { |in, point| // clockwise 16-channel panning, first speaker straight front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..15) * -2pi/16).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 16, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\twentyfour: { |in, point| // clockwise 24-channel panning, first speaker straight front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..23) * -2pi/24).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 24, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\thirtytwo: { |in, point| // clockwise 32-channel panning, first speaker straight front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..31) * -2pi/32).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 32, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\sixtyfour: { |in, point| // clockwise 64-channel panning, first speaker straight front
				var distances, globalDist, delays, amplitudes;
				var radius = panDist; // should be < 1
				distances = ((..63) * -2pi/64).collect({ |item|
					Polar(radius,item + 0.5pi).asPoint.dist( point )
				});
				globalDist = (0@0).dist( point );
				delays = ((distances + radius - globalDist) / WFSBasicPan.speedOfSound);
				in = DelayC.ar( in, 0.12, delays );
				amplitudes = PanAz.kr( 64, 1, (point.angle - 0.5pi).neg / pi, orientation: 0);
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\b_format: { |in, point| // 1st order b-format output (2D; 3 channels)
				var encoder;
				if( 'Atk'.asClass.notNil ) {
					encoder = FoaEncoderMatrix.newDirection( 0, 0 );
					in = FoaEncode.ar( in, encoder );
					in = FoaTransform.ar( in, 'directO', 
						point.rho.linlin(0,5,pi/2,0,\minmax) 
					);
					if( point.theta.rate == 'control' ) {
						FoaTransform.ar( in, 'rotate', 1.5pi + Unwrap.kr( point.theta, -pi, pi ) )[..2];
					} {
						FoaTransform.ar( in, 'rotate', 1.5pi + point.theta )[..2]
					}
				} {
					PanB2.ar( in, (point.angle - 0.5pi).neg / pi);
				};
			},
			\ambix: { |in, point| // 1st order b-format output WYZX (4-channels) with SN3D normalization
				var encoder;
				if( 'Atk'.asClass.notNil ) {
					encoder = FoaEncoderMatrix.newDirection( 0, 0 );
					in = FoaEncode.ar( in, encoder );
					in = FoaTransform.ar( in, 'directO', 
						point.rho.linlin(0,5,pi/2,0,\minmax) 
					);
					(if( point.theta.rate == 'control' ) {
						FoaTransform.ar( in, 'rotate', 1.5pi + Unwrap.kr( point.theta, -pi, pi ) )[[0,2,3,1]] * 
							[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
					} {
						FoaTransform.ar( in, 'rotate', 1.5pi + point.theta )[[0,2,3,1]] * 
							[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
					})
				} {
					(PanB2.ar( in, (point.angle - 0.5pi).neg / pi) ++ [DC.ar(0)])[[0,2,3,1]] * 
						[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
				};
			},
			\mono: { |in, point|
				in;
			}
		),
		\p: ( // plane
			\headphone: { |in, point|
				// simple headphone panner (ear distance 0.19cm)
				// no HRTFs involved (yet..)
				var distances, globalDist, amplitudes;
				distances = [ -0.095@0, 0.095@0 ].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				amplitudes = Pan2.kr( 1, (point.angle - 0.5pi).neg.fold(-0.5pi,0.5pi) / 0.5pi );
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\stereo: { |in, point|
				var distances, globalDist, amplitudes;
				distances = [ -0.3@0, 0.3@0 ].collect(_.dist( point ));
				globalDist = (0@0).dist( point );
				amplitudes = Pan2.kr( 1, (point.angle - 0.5pi).neg.fold(-0.5pi,0.5pi) / 0.5pi );
				amplitudes = amplitudes.max( globalDist.linlin(0.5,1,1,0).clip(0,1) );
				in * amplitudes;
			},
			\quad: { |in, point| // clockwise quadraphonic panning, AEP
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 4, w, x, y, 0.5 );
			},
			\quad_crossed: { |in, point| // quadraphonic panning L, R, Lb, Rb
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 4, w, x, y, 0.5 )[[0,1,3,2]];
			},
			\hexa: { |in, point| // clockwise hexaphonic AEP panning, first two speakers left and right of front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 6, w, x, y, 0.5 );
			},
			\hexa_pairs: { |in, point| // pairwise hexaphonic AEP panning, stereo pairs from front to back
				
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 6, w, x, y, 0.5 )[[ 0, 1, 5, 2, 4, 3 ]];
			},
			\octo: { |in, point| // clockwise octophonic AEP panning, first speaker straight front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 8, w, x, y, 0 );
			},
			\octo_pairs: { |in, point| // pairwise octophonic AEP panning, stereo pairs from front to back
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 8, w, x, y, 0 )[[ 0, 1, 7, 2, 6, 3, 5, 4 ]];
			},
			\hexa_deci: { |in, point| // clockwise 16-channel AEP panning, first speaker straight front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 16, w, x, y, 0 );
			},
			\twentyfour: { |in, point| // clockwise 24-channel AEP panning, first speaker straight front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 24, w, x, y, 0 );
			},
			\thirtytwo: { |in, point| // clockwise 32-channel AEP panning, first speaker straight front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 32, w, x, y, 0 );
			},
			\sixtyfour: { |in, point| // clockwise 64-channel AEP panning, first speaker straight front
				var w,x,y,z;
				#w,x,y,z = PanB.ar( in, (point.angle - 0.5pi).neg / pi, (0@0).dist( point ).linlin( 0,2,1,0,\minmax ) );
				DecodeB2.ar( 64, w, x, y, 0 );
			},
			\b_format: { |in, point| // 1st order b-format output (2D; 3 channels)
				var encoder;
				if( 'Atk'.asClass.notNil ) {
					encoder = FoaEncoderMatrix.newDirection( 0, 0 );
					in = FoaEncode.ar( in, encoder );
					if( point.theta.rate == 'control' ) {
						FoaTransform.ar( in, 'rotate', 1.5pi + Unwrap.kr( point.theta, -pi, pi ) )[..2];
					} {
						FoaTransform.ar( in, 'rotate', 1.5pi + point.theta )[..2]
					}
				} {
					PanB2.ar( in, (point.angle - 0.5pi).neg / pi);
				};
			},
			\ambix: { |in, point| // 1st order b-format output WYZX (4-channels) with SN3D normalization
				var encoder;
				if( 'Atk'.asClass.notNil ) {
					encoder = FoaEncoderMatrix.newDirection( 0, 0 );
					in = FoaEncode.ar( in, encoder );
					in = FoaTransform.ar( in, 'directO', 
						point.rho.linlin(0,5,pi/2,0,\minmax) 
					);
					(if( point.theta.rate == 'control' ) {
						FoaTransform.ar( in, 'rotate', 1.5pi + Unwrap.kr( point.theta, -pi, pi ) )[[0,2,3,1]] *
							[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
					} {
						FoaTransform.ar( in, 'rotate', 1.5pi + point.theta )[[0,2,3,1]] *
							[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
					})
				} {
					(PanB2.ar( in, (point.angle - 0.5pi).neg / pi) ++ [DC.ar(0)])[[0,2,3,1]] * 
						[ 1, 0.5.sqrt, 0.5.sqrt, 0.5.sqrt ];
				};
			},
			\mono: { |in, point|
				in;
			}
		)
		)
	}
	
	*getDefName { |which = \headphone, mode = \s, type = \n|
		^[ this.prefix, which, mode.asString[0].toLower, type ].join("_");
	}
	
	*generateDef { |which = \headphone, mode = \s, type = \n|
		
		mode = mode.asString[0].toLower.asSymbol;
		
		^SynthDef( this.getDefName( which, mode, type ), {
			
			var point = 0@0, amp = 1;
			var input;
			
			amp = \amp.kr( amp );
			
			// depending on mode
			if( mode === \d ) {
				point = \point.kr([0,0]).asPoint;
			} {
				point = \point.ir([0,0]).asPoint;
			};
				
			input = UIn.ar(0, 1) * amp;
			
			Out.ar( \out.kr(0), pannerFuncs[ type ][ which ].value( input, point ) );
		});
		
	}
	
	*generateAll { |action, dir|
		dir = dir ? SynthDef.synthDefDir;
		synthDefs = modes.collect({ |mode|
			types.collect({ |type|
				pannerFuncs[ type ].keys.as(Array).collect({ |which|
					this.generateDef( which, mode, type ).justWriteDefFile( dir );
				})
			})
		}).flatten(2);
		action.value(this);
		^synthDefs;		
	
	}
	
	
}