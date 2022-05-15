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

WFSPathBuffer : AbstractRichBuffer {
	
	classvar <>writeServers;
	
	// if a filePath is specified, the path is read from there
	// at playback. Otherwise wfsPath is used by sending it.
	// Using a filePath is safer, but of course it needs to
	// be saved and taken separately.
	
	// wfsPath can also be a file path. In that case the gui doesn't
	// know the WFSPath, but it is still played on the server (if found)
	
	// file frame 0 is used for format settings and should not be read for playback
	
	var <wfsPath;
	var <>fileStartFrame = 1, <>fileEndFrame;
	var <startFrame = 0, endFrame;
	var <rate = 1;
	var <loop = false;
	var <delay = 0;
	
	*initClass {
		writeServers = [ Server.default ];
	}
	
	*new { |wfsPath, startFrame = 0, rate = 1, loop = false, delay = 0|
		^super.new( nil, 9 ).wfsPath_( wfsPath ).startFrame_( startFrame ).rate_( rate )
			.loop_( loop ).delay_( delay );
	}
	
	shallowCopy{
        ^this.class.new(wfsPath);
	}
	
	asControlInputFor { |server, startPos = 0| 
		var realStartPos, realStartFrame, realDelay;
		realStartPos = (startPos * rate) - delay;
		if( (realStartPos > 0) && { wfsPath.isWFSPath2 } ) {
			realStartFrame = wfsPath.indexAtTime( 
				realStartPos + wfsPath.timeAtIndex( startFrame ) 
			);
		};
		realDelay = delay - startPos;
	    ^[ this.currentBuffer(server), realStartFrame ? startFrame, rate, loop.binaryValue, realDelay ] 
	 }
	 
	wfsPath_ { |new|
		wfsPath = (new ? wfsPath);
		if( wfsPath.isWFSPath2.not ) { wfsPath = wfsPath.asWFSPath2 };
		if( wfsPath.isWFSPath2 ) {
			numFrames = wfsPath.positions.size;
		} {
			numFrames = nil;
		};
		this.changed( \wfsPath, wfsPath );
	}
	
	filePath { ^if( wfsPath.isWFSPath2 ) { wfsPath.filePath } { wfsPath }; }
	 
	filePath_ { |new|
		var tempPath;
		if( new.notNil ) {
			tempPath = new.asWFSPath2;
			/*
			if( (tempPath.class == WFSPathURL) && { tempPath.wfsPath.isNil } ) {
				this.duplicatePath
					.filePath_( new )
					.savedCopy_( nil );
			} {
				
			};
			*/
			this.wfsPath = tempPath;
			this.changed( \filePath, this.filePath );
		} {
			this.duplicatePath;
		};
	}
	
	dirty { ^wfsPath.dirty }
	
	duplicatePath {
		if( wfsPath.class == WFSPathURL ) {
			this.wfsPath = wfsPath.wfsPath.deepCopy;
		} {
			this.wfsPath = wfsPath.deepCopy;
		};
		^wfsPath;
	}
		
	== { |that| // use === for identity
		^this.compareObject(that);
	}

	rate_ { |new|
		rate = new ? 1;
		this.changed( \rate, rate );
		this.unitSet;
	}
	
	loop_ { |new|
		loop = new ? false;
		this.changed( \loop, loop );
		this.unitSet;
	}
	
	delay_ { |new|
		delay = new ? delay;
		this.changed( \delay, delay );
		this.unitSet;
	}
	
	startFrame_ { |new|
		startFrame = (new ? 0).max(0);
		this.changed( \startFrame, startFrame );
	}
	
	endFrame_ { |new|
		endFrame = new.min(wfsPath.positions.size);
		this.changed( \endFrame, endFrame );
	}
	
	endFrame { 
		if( numFrames.notNil ) { 
			^(endFrame ? numFrames) % (numFrames+1) 
		} { 
			^endFrame 
		};
	}
	
	startSecond_ { |second = 0|
		if( wfsPath.isWFSPath2 ) {
			this.startFrame = wfsPath.indexAtTime( second );
		} {
			"%-startSecond_ : can't set startSecond because path % is unknown"
				.format( this.class, wfsPath )
				.warn;
		};
	}
	
	startSecond {
		if( wfsPath.isWFSPath2 && { wfsPath.exists } ) {
			^wfsPath.timeAtIndex( startFrame );
		} {
			"%-startSecond : can't get startSecond because path % is unknown"
				.format( this.class, wfsPath )
				.warn;
			^0;
		};
	}
	
	cutStart { |time = 0|
		this.startSecond = this.startSecond + time;
	}
	
	name_ { |new|
		wfsPath.name = new.asString;
	}
	
	name { ^wfsPath.name }
	
	makeBuffer { |server, action, bufnum|
	    var buf;
	    if( this.filePath.notNil && { wfsPath.dirty.not } ) {
		    buf = this.readBuffer( server, action, bufnum );
	    } {
		    buf = this.sendBuffer( server, action, bufnum );
	    };
		this.addBuffer( buf );
		^buf;
	}
	
	readBuffer { |server, action, bufnum, path|
		path = path ?? { this.filePath; };
		if( path.notNil ) {
			^Buffer.read( server, path.getGPath,
					fileStartFrame ? 1, fileEndFrame ? -1, action, bufnum );
		} {
			"WFSPathBuffer:readBuffer - no filePath specified".postln;
			action.value;
			^nil;
		}
	}
	
	sendBuffer { |server, action, bufnum, forWriting = false|
		var array, buf, sendFunc;
		if( wfsPath.isWFSPath2 ) {	
			array = wfsPath.asBufferArray( forWriting );
			^Buffer.uSendCollection( server, array, 9, 0.02, action );
		} {
			"WFSPathBuffer:sendBuffer - can't send, WFSPath2 unknown".postln;
			"\twill try to read the buffer instead from %\n".postf( wfsPath );
			^this.readBuffer( server, action, bufnum );
		};
	}
	
	writeFile { |servers, path, action|
		if( wfsPath.isWFSPath2 ) {
			servers = (servers ? writeServers).asCollection;
			if( path.notNil ) {
				wfsPath.filePath = path.replaceExtension( "wfspath" );
			};
			wfsPath.savedCopy = wfsPath.deepCopy;
			if( this.filePath.notNil ) {
				servers.do({ |srv|
					this.writeBuffer( srv, this.filePath, action );
				});
				if( wfsPath.class != WFSPathURL ) {
					this.wfsPath = WFSPathURL( wfsPath.filePath );
				};
			} {
				"%-writeFile : can't write file because filePath is unknown"
					.format( this.class )
					.warn;
			};
		} {
			"%-writeFile : can't write file because path % is unknown"
				.format( this.class, wfsPath )
				.warn;
		};
	}
	
	writeBuffer { |server, path, action|
		var buf, writeFunc, removeFunc;
		
		path = path ? this.filePath;
		
		writeFunc = { |buf|
			buf.write( path.getGPath, "aiff", "float32", -1, 0, false );
		};
		
		buf = this.sendBuffer( server, writeFunc, forWriting: true );
		
		OSCFunc( { |msg, time, addr|
			buf.free;
		}, '/done', server.addr, argTemplate: [ '/b_write', buf.bufnum ]).oneShot; 
	}
	
	storeArgs { ^[ wfsPath, startFrame, rate, loop, delay ] }
	
}

+ WFSPath2 {
	
	asUnitArg { |unit|
		^WFSPathBuffer( this ).asUnitArg( unit );
	}
	
	asUnit {
		^U( \wfsPathPlayer, [ \wfsPath, this ] );
	}
}