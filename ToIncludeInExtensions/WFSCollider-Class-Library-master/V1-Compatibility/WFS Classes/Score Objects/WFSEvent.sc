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

WFSEvent {
	
	// simple placeholder for timed WFSSynths
	
	classvar <>allEvents;
	classvar <>wait = 5; // default wait time ( between load and play )
	
	var <>startTime, <>wfsSynth, <>track, <muted = false, <>currentSynth;
	
	// wfsSynth should not already be loaded
		
	*initAllEvents { allEvents = []; }
			
	*new { |startTime = 0, wfsSynth, track = 0 |
		wfsSynth = wfsSynth ?? { 
			WFSSynth( 'linear_blip',
				WFSPath.circle( 35, 0, 7.5 ).length_( 5 ) ) };
				
		^super.newCopyArgs( startTime, wfsSynth, track ).addToAllEvents;
		
		}
	
	addToAllEvents { allEvents = (allEvents ? []).add( this ); }
	
	isFolder { ^wfsSynth.class == WFSScore }
		
	playNow { |server| if( wfsSynth.notNil )
		{ 	if( server.class == MultiServer )
				{ server = server.next };
				
			^wfsSynth.copy.play( server, wait ); }
		{ "WFSUnit-playNow: empty unit".postln; };
		} // always waits a second
	
	play { |server|
		WFSSynth.clock.sched( startTime, { currentSynth = this.playNow( server ) } ) }
	
	plotSmooth { wfsSynth.wfsPath.plotSmooth; }
	
	dur { ^wfsSynth.dur }
	dur_ { |newDur| wfsSynth.dur = newDur }
	
	endTime { ^startTime + this.dur; }
	
	muted_{ |bool|
		muted = bool;
		if(wfsSynth.class == WFSScore){
			wfsSynth.events.do{ |event| event.muted = bool };
		}
	}

	mute { this.muted_(true) }
	unMute { this.muted_(false) }
	
	toggleMute { this.muted_(muted.not) }
	
	notMuted { ^muted.not }
	
	<= { |that| ^startTime <= that.startTime } // sort support
	
	asWFSEvent { ^this }
	
	duplicate { // full copy
		^this.class.new( startTime, wfsSynth.copyNew, track ).muted_( muted );
		}
		
	copyNew { ^this.duplicate }
	
	printOn { arg stream;
		stream << this.class.name << "( " << startTime <<  ", " << wfsSynth << " )";
		}
	
	edit { |leftTop, closeOldWindow = true, parent, toFront=false| 
		WFSEventEditor.new( this, leftTop, closeOldWindow, parent, toFront ) }
	
	x { if( [ 'static', 'plane' ].includes( wfsSynth.intType ) )
			{ ^wfsSynth.wfsPath.x } { ^nil } }
	y { if( [ 'static', 'plane' ].includes( wfsSynth.intType ) )
			{ ^wfsSynth.wfsPath.y } { ^nil } }
	angle { if( [ 'plane' ].includes( wfsSynth.intType ) )
			{ ^wfsSynth.wfsPath.angle } { ^nil } }
	distance { if( [ 'plane' ].includes( wfsSynth.intType ) )
			{ ^wfsSynth.wfsPath.distance } { ^nil } }
	
	}
	
	
WFSScore {

	// array of events with name
	
	var <>events, <>name = "untitled";
	var <>clickTrackPath; // clicktrack addition 29/10/08 ws
	var <>filePath;
	
	*new { |... events| 
		^super.newCopyArgs( events.select({ |item| item.class == WFSEvent }) );
		}
		
	*current { ^(WFSScoreEditor.current !? { WFSScoreEditor.current.score }) }
	
	// array support
	at { |index|  ^events[ index ];  }
	collect { |func|  ^events.collect( func );  }
	do { |func| events.do( func ); }
	first { ^events.first }
	last { ^events.last }
	
	audioType { ^\folder }
	intType { ^\folder }
	
	play { |server| events.do({ |event| event.play( server ) }); }
	
	add { |event| events = events.add( event.asWFSEvent ); }
		
	size { ^events.size }
	
	startTimes { ^events.collect( _.startTime ); }
	durations { ^events.collect( _.dur ); }
	
	duration { ^(this.startTimes + this.durations).maxItem ? 0; }
	dur { ^this.duration } 
	dur_ { } // no effect
	
	copyNew { ^WFSScore( *events.collect( _.duplicate ) ).name_( name ); }
	duplicate { ^WFSScore( *events.collect( _.duplicate ) ).name_( name ); }
	
	track { |track = 0| ^this.class.new( events.select({ |event| event.track == track }) ); }
	
	sort { events.sort; }
	
	edit { |parent| WFSScoreEditor( this, parent.isNil, parent ) }
	
	moveOverlappingEventsToNextTrack { |track = 0|
		var trackEvents, overlapDetectFunc, didChange = false;
		trackEvents = events.select({ |item| item.track == track }).sort;
		
		overlapDetectFunc = { |index = 0|
			var currentEvent, overlappingEvent;
			currentEvent = trackEvents[index];
			if( currentEvent.notNil )
				{ overlappingEvent = trackEvents;
					overlappingEvent.remove( currentEvent );
					overlappingEvent = overlappingEvent.detect({ |event| 
						( currentEvent.endTime > event.startTime ) 
							&& { (event.startTime >= currentEvent.startTime)  } });
				  if( overlappingEvent.isNil )
				  		{ overlapDetectFunc.value( index+1 ) }
				  		{ overlappingEvent.track = track+1; didChange = true;
				  		  trackEvents = 
				  			events.select({ |item| item.track == track }).sort;
				  		 overlapDetectFunc.value( index );
				  		};		
					};
			};
			
		overlapDetectFunc.value;
		
		^didChange; // return true if anything was moved
		}
	
	cleanOverlaps {
		// recursively move overlapping events to next track
		var index, maxTracksToCheck, didMove = false;
		// first check used tracks
		maxTracksToCheck = (events.collect( _.track ).maxItem ? 0);
		(maxTracksToCheck+1).do({ |i| didMove = this.moveOverlappingEventsToNextTrack( i ) });
		
		// then continue until all newly used tracks are checked
		while { didMove }
			{ maxTracksToCheck = maxTracksToCheck + 1;
			  didMove = this.moveOverlappingEventsToNextTrack( maxTracksToCheck );
			  };
		}
		
	checkSoundFile { |nChaAlert, srAlert, notFoundAction| 
		^events.collect({ |event| event.wfsSynth
			.checkSoundFile( nChaAlert, srAlert, notFoundAction ) })
		}
		
	copySoundFileTo { |newFolder, newName, alwaysUse = false, doneAction, index = 0|
		// be careful not to use newName!!
		var  currentEvent;
		currentEvent = events[ index ];
		if( currentEvent.notNil )
			{ currentEvent.wfsSynth
				.copySoundFileTo( newFolder, newName, alwaysUse, 
				{ this.copySoundFileTo( 
						newFolder, newName, alwaysUse, doneAction, index + 1) }
					)
			}
			{ doneAction.value };
		
		}
			
	prCollectFilePaths { // as symbols 
	
		^events.collect({ |event|
			if( event.wfsSynth.isMemberOf( WFSScore ) )
				{ event.wfsSynth.prCollectFilePaths }
				{ if( ['buf', 'disk' ].includes( event.wfsSynth.audioType ) )
					{ event.wfsSynth.filePath.asSymbol }
					{ nil }; 
				};
			 });
		}
	
	collectFilePaths {
		var prPaths, outPaths = [];
		prPaths = this.prCollectFilePaths.flat.sort;
		prPaths = prPaths.select({ |item| item.notNil });
		prPaths.do({	|path| if( outPaths.includes( path ).not )
				{ outPaths = outPaths ++ [ path ] };
			});
		^outPaths;
		}
	
	detectDupFileNames { |inPaths|
		var fileNames = [], outDict = ();
		inPaths = inPaths ?? { this.collectFilePaths };
		inPaths.do({ |path|
			var basename;
			basename = path.asString.basename.asSymbol;
			if( fileNames.includes( basename ) )
				{ outDict[ basename ] = ( outDict[ basename ] ? [] ) ++ [ path ] }
				{ fileNames = fileNames ++ [ basename ]; };
			});
		^outDict;
		}
		
	createCopyToDict { |newPath|
		var filePaths, dupNames, outDict = ();
		newPath = ( newPath ? "/WFSSoundFiles/default/" ).standardizePath;
		filePaths = this.collectFilePaths;
		dupNames = this.detectDupFileNames( filePaths );
		filePaths.do({ |path|
			var basename, dup;
			basename = path.asString.basename;
			dup = dupNames[ basename.asSymbol ];
			if( dup.isNil or: { dup.includes( path ).not;  } )
				{ outDict[ path ] = newPath ++ "/" ++ basename; }
				{ outDict[ path ] = newPath ++ "/" ++ 
					path.asString.dirname.basename ++ "/" ++ basename; };
				
			});
			
		^outDict;
		}
	
	copyFilesToFolder { |folderName, replaceExisting = false, doneAction|
		var copyDict;
		copyDict = this.createCopyToDict( folderName );
		copyDict.keysValuesDo({ |key, value|
			key.asString.copyFile( value.asString, replaceExisting )
			});
		this.changeFileReferences( copyDict );
		doneAction.value;
		}
		
	changeFileReferences { |copyDict|
		copyDict = copyDict ? ();
		events.do({ |event|
			if( event.wfsSynth.class == WFSScore )
				{ event.wfsSynth.changeFileReferences( copyDict ); }
				{ if(  ['disk', 'buf'].includes( event.wfsSynth.audioType ) &&
						{ copyDict[ event.wfsSynth.filePath.asSymbol ].notNil } )
					{ event.wfsSynth.filePath = 
						copyDict[ event.wfsSynth.filePath.asSymbol ].asString; };
				};
			});
		}
	
	findEmptyTrack { |startTime = 0, endTime = inf|
		var evts, tracks;

		evts = events.select({ |item|
			(item.startTime <= endTime) and: (item.endTime >= startTime )
		});

		tracks = evts.collect(_.track);

		(tracks.maxItem+2).do({ |i|
			if( tracks.includes( i ).not ) { ^i };
		});
	}

	checkIfInEmptyTrack { |evt|
		var evts, tracks;

		evts = events.detect({ |item|
			(item.startTime <= evt.endTime) and:
			(item.endTime >= evt.startTime ) and:
			(item.track == evt.track)
		});

		^evts.isNil;
	}

	addEventToEmptyTrack { |evt|
		if( this.checkIfInEmptyTrack( evt ).not ) {
			evt.track = this.findEmptyTrack( evt.startTime, evt.endTime );
		};
		events = events.add( evt );

	}

	findCompletelyEmptyTrack {
		^( (events.collect(_.track).maxItem ? -1) + 1);
	}

	addEventToCompletelyEmptyTrack { |evt|
		evt.track = this.findCompletelyEmptyTrack;
		events = events.add( evt );

	}

}