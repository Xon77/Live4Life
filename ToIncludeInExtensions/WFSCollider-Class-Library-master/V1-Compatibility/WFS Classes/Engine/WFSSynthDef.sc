/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2010 Wouter Snoei.

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

WFSSynthDef {

	classvar <>pathInterpolation = 4; // 2 : linear; 4 : cubic (hermite)
	
	var <type, <configuration, <def, <>isSent = false, <>isLoaded = false;
	
	*new { |type, configuration, func, extraName = "", def|
		configuration = configuration ? WFSConfiguration.default;
		type = type ? 'linear_blip';
		def = def ?? { WFSSynthDef.generateDef( type, configuration, func, extraName ) };
		^super.newCopyArgs( type, configuration, def );
		}
	
	*generateDef { |type = 'linear_blip', conf, func, extraName = ""|
		var intType, audioType;
		var posFunc, audioFunc;
		type = type.asString.split( $_ );
		intType = type[0].asSymbol;
		audioType = type[1].asSymbol;
		
		if( extraName.notNil && (extraName.asString.size != 0 ) )
			{ extraName = "_" ++ extraName}
			{ extraName = "" };
		
		/*
		
		global Control names
		
		bufD, totalTime, fadeOutTime, level, rate;
		
		extra Control names
		
		static: i_x, i_y, i_z;
		plane: i_a, i_d;
		linear/cubic: bufXYZ, bufT, i_x, i_y, i_z;
		
		buf: bufP, loop;
		live: input;
		
		*/
		
		posFunc = ( 'static':	{ |i_x, i_y, i_z| WFSPoint( i_x, i_y, i_z ); },
				   'staticOut':	{ |i_x, i_y, i_z| WFSPoint( i_x, i_y, i_z ); },
				   'plane':	{ |i_a, i_d| WFSPlane( i_a, i_d ); },
				   'index': { |i_index, i_use| [ i_index, i_use ]; } // work in progress
					)[intType] ?
				{ |bufXYZ, bufT, i_x, i_y, i_z| 
					Poll.kr( Impulse.kr( 0 ), bufXYZ, \bufxyz );
					PlayWFSPath.kr( bufXYZ, bufT, 
						pathInterpolation ) + WFSPoint( i_x, i_y, i_z ); }; 
				
		audioFunc = ( 'blip': 	{ |rate = 1, freq = 100, noiseLevel = 0.125, blipLevel = 1|
		
						RandSeed.ir( 12345 ); // always the same noise
						 
						( Blip.ar( freq, 100, blipLevel * 0.125) + 
							PinkNoise.ar( noiseLevel )) * 
							LFPulse.kr(10 * rate); 
						},
					'buf':	{ |bufP, rate = 1, loop = 0.0| 
						PlayBuf.ar(1, bufP, rate * 
							BufRateScale.kr( bufP ), loop: loop); },
					'disk':	{ |bufP| DiskIn.ar(1, bufP );  },
					'live': 	{ |input = 1| AudioIn.ar( input ); }
				  )[audioType] ? func;
		
		^SynthDef( 
			("WFS_" ++ intType ++ "_" ++ audioType ++ extraName), 
			{ |bufD, totalTime, extraTime = 0.01, level = 1,
				i_fadeInTime = 0, i_fadeOutTime = 0,
				outOffset = 0, gate = 1|
				
				var out, env, pos, in, busLevel, scaledIn;
				
				env = EnvGen.kr( Env.new([0,1,1,0], 
					[ i_fadeInTime, 
						(totalTime - (i_fadeInTime + i_fadeOutTime)).max(0) + extraTime, 
						i_fadeOutTime]), doneAction:2) *
					 EnvGen.kr( Env.new([1,1,0], [0, 0.2], \lin, 0), gate, doneAction:2);
				
				pos = UGen.buildSynthDef.buildUgenGraph( posFunc );
				
				//"% : %\n".postf( intType, pos.rate );
				//SendTrig.kr( Impulse.kr( 0.5 ), 1, pos.x ); // checking
				//SendTrig.kr( Impulse.kr( 0.5 ), 2, pos.y );
						
				in = UGen.buildSynthDef.buildUgenGraph( audioFunc );
				
				busLevel = WFSLevelBus.kr;
				
				scaledIn = WFSEQ.unit( in * level * env * busLevel );
				
				out = (
						static:	{ WFSPan2D.arBufN( scaledIn,  // no buffers for static / plane
							bufD, pos, conf ) },
						staticOut:
								{ WFSPan2D.arBufN( scaledIn,  // no buffers for static / plane
							bufD, pos, conf, useFocused: false ) },
						plane: 	{ WFSPan2D.arBufN( scaledIn, 
							bufD, pos, conf ) },
						
						/*	
						linear: 	{ WFSPan2D.ar( scaledIn, pos, conf )  },
						cubic:  	{ WFSPan2D.arC( scaledIn, pos, conf ) },
						*/
						
						linear: 	{ WFSPan2D.arBufL( scaledIn, 
							bufD, pos, conf )  },
							
						linearOut: 	{ WFSPan2D.arBufL( scaledIn, 
							bufD, pos, conf, useFocused: false )  },
							
						cubic:  	{ WFSPan2D.arBufC( scaledIn,
							bufD, pos, conf ) },
						
						cubicOut:  	{ WFSPan2D.arBufC( scaledIn,
							bufD, pos, conf, useFocused: false  ) },
	
						switch:	{  WFSPan2D.arBufSwitch( scaledIn, 
							bufD, pos, conf )  },
						
							
						index: { DelayN.ar( scaledIn * pos[1], 0.05 ) } )
					[intType].value;
				
				case { intType == \index }	
					{ PanOut.ar( pos[0] + outOffset, out ); }
					{ true }
					{ Out.ar(outOffset, out); };
				
			});
		}
		
	*validAudioTypes { ^['buf', 'disk', 'blip']; }
	*validIntTypes { ^['linear', 'cubic', 'static', 'plane', 'index', 'switch']; }
		
	*validTypes {
		^this.validIntTypes.collect { |item|
			this.validAudioTypes.collect { |subItem|
				(item.asString ++ "_" ++ subItem).asSymbol }
			} .flat;
		}
	
	*validTypesNoFunc {
		^(this.validIntTypes ++ [ \linearOut, \cubicOut, \staticOut ]).collect { |item|
			['buf', 'disk', 'blip', 'live'].collect { |subItem|
				(item.asString ++ "_" ++ subItem).asSymbol }
			} .flat;
		}
		
	*allTypes { |conf, extraName = ""| 
		^this.validTypesNoFunc.collect({ |type|
				this.new( type, conf, extraName: extraName ); });		}
	
	intType { ^type.asString.split( $_ ).first.asSymbol; }
	audioType {  ^type.asString.split( $_ ).last.asSymbol; } 
		
	// shortcuts:
	*blip { |conf| ^WFSSynthDef( 'linear_blip', conf ); }
	
	send { arg server, completionMsg;
		server = server ? Server.default;
		def.send( server, completionMsg );
		isSent = true;
		}
		
	load { arg server, completionMsg, dir;
		server = server ? Server.default;
		if( server.class == MultiServer )
			{ 
			dir = dir ? server.synthDefDir;
			def.writeDefFile(dir);
			server.listSendMsg(
					["/d_load", dir ++ def.name ++ ".scsyndef", 
						completionMsg ]
				)
	  		}
			{ def.load( server, completionMsg, dir ); };
		isSent = true;
		isLoaded = true;
		}
	
}