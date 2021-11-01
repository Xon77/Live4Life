WFSArrayPanDirSynthDefs : WFSArrayPanSynthDefs {

	*prefix { ^"wfsd" }
	
	*generateDef { |size = 8, type = \uni, mode = \static, int = \n|
		var conf;
		
		#type, mode, int = [ type, mode, int ].collect({ |item, i|
			var out;
			out = item.asString[0].toLower.asSymbol;
			if( [ types, modes, intTypes ][i].includes( out ).not ) {
				"WFSArrayPanSynth.generateDef - nonexistent %: %"
					.format( [\type, \mode, \int][i], item )
					.warn;
			};
			out;
		});
		
		^SynthDef( this.getDefName(size, type, mode, int), {
			
			// synth args:
			var arrayConf, outOffset = 0, addDelay = 0;
			var point = 0@0, amp = 1, arrayRollOff = -9, arrayLimit = 1;
			var radiation = [0,1,0,1], direction = 0;
			
			// local variables
			var gain = 0.dbamp; // hard-wired for now
			var panner, input;
			
			// always static
			arrayConf = \arrayConf.ir( [ size, 5, 0.5pi, 0, 0.164 ] ); // size is fixed in def
			outOffset = \outOffset.ir( outOffset );
			addDelay = \addDelay.ir( addDelay );
			
			// depending on mode
			if( mode === \d ) {
				point = \point.kr([0,0]).asPoint;
			} {
				point = \point.ir([0,0]).asPoint;
			};
			
			amp = \amp.kr(amp);
			
			arrayRollOff = \arrayDbRollOff.ir( arrayRollOff );
			arrayLimit = \arrayLimit.ir( arrayLimit );
			
			radiation = \radiation.kr( radiation );
			direction = \direction.kr( direction );
			
			gain = \gain.kr( gain );
			input = UIn.ar(0, 1) * gain * amp;
			
			panner = WFSArrayPanDir( size, *arrayConf[1..] )
				.addDelay_( addDelay )
				.dbRollOff_( arrayRollOff )
				.limit_( arrayLimit )
				.focusWidth_( \focusWidth.ir( 0.5pi ) )
				.focus_( switch( type, \f, { true }, \n, { false }, { nil } ) );
			
			Out.ar( outOffset, 
				panner.ar( 
					input, point, int, 
					direction, radiation[..2], radiation[3]
				)
			); 
		});
	}
	
	*generateAll { |action, dir, estimatedTime = 90| // and write to disk
		
		// this takes about 30 seconds in normal settings
		// can be stopped via cmd-.
		
		var all, waitTime;
		dir = dir ? SynthDef.synthDefDir;
		all = #[ // these are the all types we'll probably need
			[ uni, static, n ],    // use this for any static
			[ normal, static, n ], // use this for normal static
			[ focus, dynamic, l ],
			[ normal, dynamic, l ],
			[ focus, dynamic, c ],
			[ normal, dynamic, c ],
		];
		waitTime = estimatedTime / all.size;
		
		// now we generate them:
		{	
			var started;
			started = Main.elapsedTime;
			"started generating WFSArrayPanSynthDefs".postln;
			" this may take % seconds or more\n".postf( estimatedTime );
			synthDefs = all.collect({ |item|
				var out = this.allSizes.collect({ |size|
					this.generateDef(size, *item )
						.justWriteDefFile( dir );
				});
				waitTime.wait;
				"  WFSArrayPanDirSynthDefs synthdefs for % ready\n".postf( item.join("_") );
				out;
			});
			"done generating WFSArrayPanDirSynthDefs in %s\n"
				.postf( (Main.elapsedTime - started).round(0.001) );
			action.value( synthDefs );
		}.fork(AppClock);
	}
}
