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


WFSSynth {
		
		var <>wfsDefName, <wfsPath, <server, <>filePath, <>dur, <level = 1;
		var <>pbRate = 1, <>loop = 1.0, <>input = 0, <>args, >fadeTimes, <>startFrame = 0; 
			// args: extra arguments for specific synthdefs
		var <>synth, <delayBuffer, <sfBuffer;
		var <loaded = false, <buffersLoaded = false, <isRunning = false;
		var <>sfNumFrames, <>sfSampleRate;
		var <>wfsServers, <>index = 0;
		var >useSwitch = false;
		var <>prefServer = nil;
		var <>useFocused = true;
		
		var <>wfsPathStartIndex = 0;
				
		classvar <>outOffset = 0, <>clock;
		classvar <>usedNodeIDs;
		classvar <>sampleAccurateTiming = true;
		//classvar <>useSyncPulse = false;
		classvar <loadedSynths, <>bigTempoClock;
		classvar <schedSize = 2048;
		
		useSwitch { if( [\linear, \cubic].includes( this.intType ) )
					{ ^useSwitch } { ^false }
				}
		
		level_ { |newLevel| 
			level = newLevel ? level; 
			synth.asCollection.do({ |syn| 
				 if( syn.respondsTo( \level_ ) ) // can be nested WFSSynth
				 	 { syn.level = level }
				 	 { if( loaded ) { syn.set( \level, level ); } }
				 }); 
			}
		
		*initClass { 
			bigTempoClock = TempoClock.newBig( size: schedSize ).permanent_(true);
			clock = bigTempoClock; usedNodeIDs = []; }
		
		*newClock { |newClock| clock = newClock ?? { bigTempoClock }; }
		
		*schedSize_ {  |newSize = 1024| schedSize = newSize; 
			bigTempoClock = TempoClock.newBig( size: schedSize ).permanent_(true);
			clock = bigTempoClock; }
		
		*newLoad { |wfsDefName, wfsPath, server, path = "", dur = 5, 
			level = 1, pbRate = 1, loop = 1.0, input = 0, args, fadeTimes, startFrame = 0| 
			// does not play, but does load
			// wfsPath can also be WFSPoint, but only when wfsDef.intType == 'static'
			
			^this.new( wfsDefName, wfsPath, server, path, dur, level, pbRate, 
				loop, input, args, fadeTimes, startFrame).load;
		}
		
		*new { |wfsDefName, wfsPath, server, path = "", dur = 5, 
			level = 1, pbRate = 1, loop = 1.0, input = 0, args, fadeTimes, startFrame = 0,
			stdPath = true| 
			// does not load or; call load, then run to start
			// wfsPath can also be WFSPoint, but only when wfsDef.intType == 'static'
		
			var synth, outSynth;
			
			server = server ? Server.default;		
			
			if( wfsDefName.class == WFSSynthDef ) 
				{ wfsDefName = wfsDefName.def.name; }
				{ if( wfsDefName.asString.split( $_ ).first.asSymbol != 'WFS' )
					{ wfsDefName = "WFS_" ++ wfsDefName; };
				};
			
			if( ( wfsDefName.wfsIntType === 'linear') or: ( wfsDefName.wfsIntType === 'cubic'))
				{ dur = wfsPath.length; };
			
			if( stdPath ) { path = path.standardizePath; };
									
			^super.newCopyArgs( wfsDefName.asString, wfsPath, server, 
				path, dur, level, pbRate, loop, input, args, fadeTimes, startFrame )
					.wfsServers_( WFSServers.default );
		}
		
		fadeInTime { ^( fadeTimes ? [0,0] )[0]  }
		fadeOutTime { ^( fadeTimes ? [0,0] )[1]  }
		
		fadeInTime_ { |time = 0| 
			fadeTimes = ( ( fadeTimes ? [0,0] )[0] = time.max(0) ); 
			}
			
		fadeOutTime_ { |time = 0| 
			fadeTimes = ( ( fadeTimes ? [0,0] )[1] = time.max(0) ); 
			}

		fadeTimes { ^( fadeTimes ? [0,0] ) }
		
		*basicNew {|wfsDefName, wfsPath, server, path = "", dur = 5, 
					level = 1, pbRate = 1, loop = 1.0, input = 0, args, fadeTimes, 
					startFrame = 0| 
			^this.new( wfsDefName, wfsPath, server, path, dur, 
				level, pbRate, loop, input, args, fadeTimes, startFrame); 
			// backwards compatibility:
			// same as *new
			}
			
		wfsPath_ { | newWFSPath, changeDur = true |
			wfsPath = newWFSPath;
			if( changeDur )
				{ if( ( wfsDefName.wfsIntType === 'linear') or: 
					 ( wfsDefName.wfsIntType === 'cubic'))
					{ dur = wfsPath.length; }; };
		}

		intType { ^wfsDefName.wfsIntType; }
		audioType {  ^wfsDefName.wfsAudioType; } 
		
		intType_ { |type = \linear | wfsDefName = wfsDefName.wfsIntType_( type ) ; }
		audioType_ { |type = \blip | wfsDefName = wfsDefName.wfsAudioType_( type ); } 
		
		cancel { synth.free; this.freeBuffers; }
		releaseFree { this.release; this.freeBuffers; }
			
		resetFlags { loaded = false; buffersLoaded = false; isRunning = false;  } 
		clearVars { synth = nil; delayBuffer = nil; sfBuffer = nil; }
			
		copyNew { // ^this.copy.resetFlags.clearVars.wfsPath_( wfsPath.copyNew ); 
			// really copy..
			^this.class.new(  wfsDefName, wfsPath.copyNew, server, filePath, dur, 
				level, pbRate, loop, input, args.copy, fadeTimes.copy, startFrame, false )
					.useSwitch_( useSwitch )
					.prefServer_( prefServer )
					.useFocused_( useFocused )
					; 
		} // bugfix switch 20/11/2008 ws
		
		checkSoundFile { |nChaAlert, srAlert, notFoundAction|
			var sf;
			nChaAlert = nChaAlert ? { |synth, soundFile|
				"soundfile '%': numChannels != 1\n".postf( soundFile.path.basename );  };
			srAlert = srAlert ? { |synth, soundFile|
				"soundfile '%': sampleRate != 44100\n".postf( soundFile.path.basename ); };
			notFoundAction = notFoundAction ? { 	|synth, soundFile|
				"soundfile '%': not found or wrong type".postf( soundFile.path ); };
			if( filePath.size > 0 ) { 
				sf = SoundFile.new;
				if( sf.openRead( filePath ) )
					{ 	sfSampleRate = sf.sampleRate;
						sfNumFrames = sf.numFrames;
						
					  if( sf.numChannels != 1 )
						{ nChaAlert.value( this, sf ); };
					
					  if( this.audioType == \disk )
					  	{ if( sf.sampleRate != 44100 ) 
							{ srAlert.value( this, sf ); };
						};
					  sf.close;
					  ^true
					} 
					{  this.initSoundFileInfo;
						notFoundAction.value( this, sf );
					   ^false };
				} { ^true };
			}
		
		initSoundFileInfo {  sfSampleRate = nil; sfNumFrames = nil; }
		
		startTime {  |usePBRate = true, useSampleRate = true, update = false|
				if( update )
					{ this.checkSoundFile };
				^(startFrame / 
						(if( useSampleRate, { sfSampleRate ? 44100 }, { 44100 }))) / 
						(if( usePBRate, { pbRate }, { 1 })); 
				}
		
		startTime_ { |newStartTime = 0, usePBRate = true, useSampleRate = true|
			startFrame = (newStartTime *
				(if( useSampleRate, { sfSampleRate ? 44100 }, { 44100 }))) * 
				(if( usePBRate, { pbRate }, { 1 })); 
			}
		
		soundFileDur { |usePBRate = true, useSampleRate = true, update = false|
				if( update )
					{ this.checkSoundFile };
				if( sfNumFrames.notNil && { sfNumFrames != (-1) } )
					{ ^(sfNumFrames / 
						(if( useSampleRate, { sfSampleRate ? 44100 }, { 44100 }))) / 
						(if( usePBRate, { pbRate }, { 1 }));  }
					{ ^nil; }
			}	
			
		useSoundFileDur { |ask = false, action, usePBRate = true|
			var okFunc;
			if( [ \static, \plane ].includes( this.intType ) )
				{ dur = 
					((this.soundFileDur( usePBRate, update: true ) !?
						{ this.soundFileDur - this.startTime( usePBRate ) })
						? dur).max(0.01); action.value; }
				{ okFunc =  { dur = 
					( (this.soundFileDur( usePBRate, update: true ) !?
						{ this.soundFileDur - this.startTime( usePBRate ) })
						? dur ).max(0.01); 								wfsPath.length_( dur ); 
						action.value; };
				if( ask )
					{   SCAlert( "change path length?", 
								[ "cancel", "ok"], 
				  				[ {}, okFunc ] );
				  	} { okFunc.value }
				 };
			}
			
		copySoundFileTo { |newFolder, newName, alwaysUse = false, doneAction|
			var oldPath;
			if( [ \disk, \buf ].includes( this.audioType ) &&
					{ newFolder.notNil && { this.checkSoundFile } } )
				{  oldPath = filePath;
				 if( filePath.copyTo( newFolder, newName ) or: alwaysUse )
					{ filePath = newFolder.standardizePath ++ "/" ++ 
							( newName ? filePath.basename );
						doneAction.value( filePath ); }
					{ SCAlert( "file '" ++ 
						( newName ? filePath.basename ) ++ 
						"'\probably already exists",
							[ "cancel", "use old",
								 "auto-rename", "overwrite", "use existing" ],
							[ {  },
							  { filePath = oldPath; doneAction.value( filePath ); },
							  { this.copySoundFileTo( newFolder, 
							  	( newName ? filePath.basename ).realNextName, 
							  		false, doneAction: doneAction ); }, 
							  { filePath.copyTo( newFolder, newName, true );
							  		doneAction.value( filePath ) },
							  { filePath = newFolder.standardizePath ++ "/" 
							  	++ ( newName ? filePath.basename ); 
							  		doneAction.value( filePath ) } ] );
						
					 };
				} { doneAction.value( filePath ) };
			 }
		
		sampleRateScale {  |update = false|
				if( update )
					{ this.checkSoundFile };
				if( sfSampleRate.notNil )
					{ ^sfSampleRate/44100 }
					{ ^1 };
			}
			
		samplesPlayed { |useSR = true, update = false| 
			// number of buffer samples actually played (used for .loadBuffersSync)
			if( update ) { this.checkSoundFile };
			^( if( useSR )
				{ dur * ( sfSampleRate ? 44100 )  }
				{  dur * 44100 } ).min( 
					( sfNumFrames !? { 
						(sfNumFrames - startFrame).max(0) } ) ? inf )
					
			}
			
		
		asWFSEvent { |startTime = 0, track = 0|
			 ^WFSEvent( startTime, this.copyNew, track );
			}
		
		printOn { arg stream;
			stream << this.class.name << "( '" << wfsDefName << "', " 
				<< wfsPath << if( filePath.size != 0 ) 
					{ ", \"" ++ filePath.basename ++ "\"" } { "" } << " )";
		}
			
		
	
	}