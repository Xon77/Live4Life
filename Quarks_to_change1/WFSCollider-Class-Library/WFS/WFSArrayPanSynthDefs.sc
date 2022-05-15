/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Wouter Snoei.

    GameOfLife WFSCollider software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    GameOfLife WFSCollider is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GameOfLife WFSCollider.  If not, see <http://www.gnu.org/licenses/>.
*/

AbstractWFSSynthDefs {
	
	classvar <>synthDefs;
	
	*checkIfExists { |dir|
		^((dir ? SynthDef.synthDefDir) +/+ this.prefix ++ "_*.scsyndef" ).pathMatch.size > 0;
	}
	
	*generateAllOnce { |action, dir|
		if( this.checkIfExists( dir ).not ) {
			this.generateAll( action, dir );
		} {
			action.value( this );
		};
	}
	
}

WFSSynthDefs {
	
	*generateAllOrCopyFromResources { |action, dir|
		if( File.exists( Platform.resourceDir +/+ "synthdefs.zip" ) ) {
			"copying WFS synthdefs from resources directory (if missing)".postln;
			if( dir.notNil ) { dir = dir.dirname; } { dir = SynthDef.synthDefDir.dirname };
			"unzip -ou % -d %".format( 
				Platform.resourceDir.escapeChar( $ ) +/+ "synthdefs.zip",
				dir.escapeChar( $ )
			).unixCmd( action: action );
		} {
			this.generateAllOnce( action, dir );
		};
	}
	
	*generateAllOnce { |action, dir|
		WFSPrePanSynthDefs.generateAllOnce( dir: dir );
		WFSPreviewSynthDefs.generateAllOnce( dir: dir );
		WFSArrayPanSynthDefs.generateAllOnce( { |synthDefs|
			WFSArrayPanDirSynthDefs.generateAllOnce( action, dir );
		}, dir );
	}
	
	*generateAll { |action, dir|
		WFSPrePanSynthDefs.generateAll( dir: dir );
		WFSPreviewSynthDefs.generateAll( dir: dir );
		WFSArrayPanSynthDefs.generateAll( { |synthDefs|
			WFSArrayPanDirSynthDefs.generateAll( action, dir );
		}, dir );
	}
	
	*loadAll { |action, dir|
		dir = dir ? SynthDef.synthDefDir;
		this.generateAll({ 
			Server.all.do({ |srv|
				if( srv.isLocal && srv.serverRunning ) {
					srv.loadDirectory( dir );
					"loaded WFSSynthDefs to %\n".postf( srv );
				};
			});
			action.value;
		});
	}
	
}

WFSArrayPanSynthDefs : AbstractWFSSynthDefs {
	
	/*
	generates and maintains the SynthDefs needed for array panners.
	Normally an array panner synthdef is preceeded by a pre panner, but static sources
	might not need one of those (or only for the env and gain)
	*/
	
	classvar <>minSize = 1, <>maxSize = 96, <>division = 8;
		// if we get > 64 we might want to combine multiple
	classvar <>types, <>modes, <>intTypes;
	
	*prefix { ^"wfsa" }
	
	*initClass {
		types = [ \n, \f, \u, \p ]; // normal, focused, uni (= normal and focused), plane
		modes = [ \s, \d ];  // static, dynamic
		intTypes = [ \n, \l, \c ];  // non-int, linear, cubic
	}
	
	*allSizes { 
		var sizes;
		sizes = ((maxSize/division).asInteger + 1).collect({ |i|
			((i * division) + (0,(2**i)..division-1)).asInteger
		}).flat.select(_ >= minSize);
		if( WFSSpeakerConf.default.notNil ) {
			 WFSSpeakerConf.default.arrayConfs.collect(_.n).do({ |item|
				 if( sizes.includes( item ).not ) { sizes = sizes.add( item ) };
			 });
		};
		^sizes;
	}
	
	*getDefName { |size = 8, type = \u, mode = \s, int = \n|
		
		#type, mode, int = [ type, mode, int ].collect({ |item|
			item.asString[0].toLower;
		});
		
		// example of synthdef name:
		// 'wfsa_fdl_32' : focused dynamic linear point, 32 speakers
		// 'wfsa_psn_40' : static non-interpolating plane, 40 speakers
		
		^[ this.prefix, [type, mode, int].join(""), size ].join("_");
	}
	
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
			
			if( type != \p ) { // only for points, not planes
				arrayRollOff = \arrayDbRollOff.ir( arrayRollOff );
				arrayLimit = \arrayLimit.ir( arrayLimit );
			};	
			
			gain = \gain.kr( gain );
			input = UIn.ar(0, 1) * gain * amp;
			
			if( type === \p ) {
				panner = WFSArrayPanPlane( size, *arrayConf[1..] ).addDelay_( addDelay );
			} {
				panner = WFSArrayPan( size, *arrayConf[1..] )
					.addDelay_( addDelay )
					.dbRollOff_( arrayRollOff )
					.limit_( arrayLimit )
					.focusWidth_( \focusWidth.ir( 0.5pi ) )
					.focus_( switch( type, \f, { true }, \n, { false }, { nil } ) );
			};
			
			Out.ar( outOffset, panner.ar( input, point, int, 1 ) ); 
			
			
		});
	}
	
	*generateAll { |action, dir, estimatedTime = 60| // and write to disk
		
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
			[ plane, static, n ],
			[ plane, dynamic, l ],
			[ plane, dynamic, c ] 
		];
		waitTime = estimatedTime / all.size;
		
		// now we generate them:
		{	
			var started;
			started = Main.elapsedTime;
			"started generating WFSArrayPanSynth synthdefs".postln;
			" this may take % seconds or more\n".postf( estimatedTime );
			synthDefs = all.collect({ |item|
				var out = this.allSizes.collect({ |size|
					this.generateDef(size, *item )
						.justWriteDefFile( dir );
				});
				waitTime.wait;
				"  WFSArrayPanSynth synthdefs for % ready\n".postf( item.join("_") );
				out;
			});
			"done generating WFSArrayPanSynth synthdefs in %s\n"
				.postf( (Main.elapsedTime - started).round(0.001) );
			action.value( synthDefs );
		}.fork(AppClock);
	}
}

WFSPrePanSynthDefs : AbstractWFSSynthDefs {
	
	/*
	generates and maintains the SynthDefs needed for pre panners.
	Normally a pre panner comes before one or more array panners.
	it provides them with a delayed input (large global delay) with 
	global amplitude rolloff applied on the source. Crossfade levels 
	are also provided for dynamic sources (static sources take them
	from the lang), and array panners can be paused/unpaused from here.
	*/
	
	// we have an UEnv and a WFSLevelBus in here as well
	// should we throw in global eqhere too?
	
	classvar <>minSize = 0, <>maxSize = 24, <>division = 6; 
	
	classvar <>crossfadeModes, <>modesThatNeedArrays;
	
	*prefix { ^"wfsp" }
	*initClass {
		crossfadeModes = [ \d, \p, \n ];  // dual, uni, plane, none (none: static sources)
		modesThatNeedArrays = [ \d, \p ];
	}
	
	*allSizes { 
		^((maxSize/division).asInteger + 1).collect({ |i|
			((i * division) + (0,(2**i)..division-1)).asInteger
		}).flat.select(_ >= minSize);
	}
	
	*getDefName { |numArrays = 1, crossfadeMode = \d|
		
		crossfadeMode = crossfadeMode.asString[0].toLower;
		
		// wfsp_d_2 : pre-panner for 2 arrays in dual mode (focused and normal separate panners )
		// wfsp_p_3 : pre-panner for 3 arrays plane wave
		
		^[ this.prefix, crossfadeMode, numArrays ].join("_");
	}
	
	*generateDef { |numArrays = 1, crossfadeMode = \dual|
		
		crossfadeMode = crossfadeMode.asString[0].toLower.asSymbol;
		
		^SynthDef( this.getDefName( numArrays, crossfadeMode ), {
			
			// synth args:
			var point = 0@0, pointFromBus = 0;
			var dbRollOff = -6, limit = 2, latencyComp = 0, pointLag = 0;
			var arrayConfs, cornerPoints, crossfadeLag = 0.2, pauseLag = 0.2;
			var pauseSigs;
			
			// local variables
			var input, output, panner, crossfader, cornerfades;
			var normalLevels, normalShouldRun, focusShouldRun;
			var sendPointRate = 0;
			var rho;
			
			point = \point.kr( point.asArray );
			
			if( crossfadeMode != \n ) {	
				SendReply.kr( Impulse.kr( \sendPointRate.kr(sendPointRate) ), '/point', point );
			} {
				SendReply.kr( Impulse.kr( 0 ), '/point', point );
			};
			
			point = point.asPoint;
			rho = point.rho;
			
			if( crossfadeMode == \p ) { dbRollOff = 0 };
			
			dbRollOff = \dbRollOff.kr( dbRollOff );
			limit = \maxAmpRadius.kr( limit );
			
			// always static
			latencyComp = \latencyComp.ir( latencyComp );			
			// the pre-panner and delayed/attenuated output 
			panner = WFSPrePan( dbRollOff, limit, latencyComp );
			
			input = UIn.ar( 0, 1 );
			
			// filter and clip input for speaker protection
			input = LeakDC.ar( input, 0.997 );
			input = UGlobalEQ.ar( input );
			input = (input / 4).softclip * 4; // 6dB headroom, then softclip to 12dB
			input = OnePole.ar( input, ( -2pi * (
		 			(
			 			100000 / ( rho * \distanceFilter.kr(0).cubed )
			 		).clip(0,10000000) / SampleRate.ir) 
		 		).exp 
			);
			input = input * UEnv.kr( extraSilence: 
				( ( rho / WFSBasicPan.speedOfSound ) * (1 - latencyComp) ) + 0.12
			);
			output = panner.ar( input, point );
			
			
			ReplaceOut.ar( UIn.firstBusFor( \ar )+ \u_i_ar_0_bus.kr, output );
			
			// crossfading: manage the array panners
			if( numArrays > 0 ) {	
				switch( crossfadeMode, \d, {
					var normalIDs, focusIDs;
					var normalLevelBuses, focusLevelBuses, dontPause = 0;
					
					// Point sources //
					
					#arrayConfs, cornerPoints = numArrays.collect({ |i| [ 
						("arrayConf" ++ i).asSymbol
							.ir( [ 48, 5, i.linlin(0,numArrays, 0.5pi, -0.5pi), 0, 0.164 ] ),
						("cornerPoints" ++ i).asSymbol.ir( [ 5, -5, 0.5pi, 0.5pi ] )
					] }).flop;
					
					
					crossfadeLag = \crossfadeLag.kr( crossfadeLag );
					crossfadeLag = (1-Impulse.kr(0)) * crossfadeLag; // first value is not lagged
					
					pauseLag = \pauseLag.kr( pauseLag ); // extra time to wait before pause (not unpause)
					
					// this part has become a bit complex
					// once we know if it sounds correctly it should be
					// made less verbose
					
					crossfader = WFSCrossfader( 
						point, arrayConfs, cornerPoints, \focusWidth.ir( 0.5pi ) 
					);
							
					cornerfades = crossfader.cornerfades;
					
					focusShouldRun = crossfader.arraysShouldRun( true );
					focusShouldRun = focusShouldRun * \focusMul.kr(1);
					focusShouldRun = Slew.kr( focusShouldRun, *(1/crossfadeLag).dup ).sqrt;
	
					normalShouldRun = crossfader.arraysShouldRun( false );
					
					// crossfadelag is variable for normal sources, depending on:
					// - if it is in a corner (should have no lag there)
					// - if it is or just came from the focused area (should have lag then)
					
					crossfadeLag = crossfadeLag * max( 
						cornerfades >= 1, // only if really behind array
						Slew.kr( crossfader.focused, inf, 1/crossfadeLag ) > 0
					);
					
					// crossfadeLag = crossfadeLag.max( pauseLag );
					
					normalShouldRun = Slew.kr( normalShouldRun, *(1/crossfadeLag).dup ).sqrt;
						
					normalLevels = crossfader.cornerfades * normalShouldRun;
								
					dontPause = \dontPause.kr(dontPause); // if 1 never pause
					
					// id's of synths to pause (998 for none) 
					normalIDs = \normalIDs.ir( 998.dup(numArrays) ).asCollection;
					focusIDs = \focusIDs.ir( 998.dup(numArrays) ).asCollection;
					
					// level buses (-1 for none)
					normalLevelBuses = \normalLevelBuses.kr( -1.dup(numArrays) ).asCollection;
					focusLevelBuses = \focusLevelBuses.kr( -1.dup(numArrays) ).asCollection;
					
					// output levels to appropriate buses (replace existing)
					normalLevelBuses.do({ |bus, i|
						ReplaceOut.kr( bus, normalLevels[i] );
					});
					
					focusLevelBuses.do({ |bus, i|
						ReplaceOut.kr( bus, focusShouldRun[i] );
					});
					
					// pause non-sounding panners
					normalIDs.do({ |id, i|
						var pause;
						pause = (normalLevels[i] > 0);
						pause = Slew.kr( pause, inf, 1/pauseLag ) > 0;
						pause = pause.max(dontPause);
						Pause.kr( pause, id );
					});
					
					focusIDs.do({ |id, i|
						var pause;
						pause = (focusShouldRun[i] > 0);
						pause = Slew.kr( pause, inf, 1/pauseLag ) > 0;
						Pause.kr( pause.max(dontPause), id );
					});
					
				}, \p, {
					var planeIDs;
					var planeLevelBuses;
					var planeLevels;
					var dontPause = 0;
					
					// Plane wave //
					
					arrayConfs = numArrays.collect({ |i| 
						("arrayConf" ++ i).asSymbol
							.ir( [ 48, 5, i.linlin(0,numArrays, 0.5pi, -0.5pi), 0, 0.164 ] ) 
					});
					
					crossfader = WFSCrossfaderPlane( point, arrayConfs );
						
					dontPause = \dontPause.kr(dontPause);
					
					// id's of synths to pause (-1 for none)
					planeIDs = \planeIDs.ir( -1.dup(numArrays) ).asCollection;
					
					// level buses (-1 for none)
					planeLevelBuses = \planeLevelBuses.kr( -1.dup(numArrays) ).asCollection;
					
					planeLevels = crossfader.crossfades;
					
					// output levels to appropriate buses (replace existing)
					planeLevelBuses.collect({ |bus, i|
						ReplaceOut.kr( bus, planeLevels[i] );
					});
					
					// pause non-sounding panners
					planeIDs.collect({ |id, i|
						var pause;
						pause = (planeLevels[i] > 0);
						pause = Slew.kr( pause, inf, 1/pauseLag ) > 0;
						Pause.kr( pause.max(dontPause), id );
					});
				});
			};
		});
		
	}
	
	*generateAll { |action, dir|
		dir = dir ? SynthDef.synthDefDir;
		synthDefs = crossfadeModes.collect({ |item|
			if( modesThatNeedArrays.includes( item ) ) {
				this.allSizes.collect({ |i|
					this.generateDef( i, item ).justWriteDefFile( dir );
				});
			} {
				[ this.generateDef( 0, item ).justWriteDefFile( dir ) ]
			};
		});
		action.value(this);
		^synthDefs;		
	}
	
}

