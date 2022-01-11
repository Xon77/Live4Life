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

+ WFSEvent {
	
	asUEvent {
		^wfsSynth.asUEvent
			.startTime_( startTime )
			.track_( track ); 
	}
	
}

+ WFSSynth {
	
	asUEvent { 
		var units, gain = 0;
		
		units = Array.new( 4 );
		
		switch( this.audioType,
			\buf, { 
				units.add( U( \bufSoundFile, [ \soundFile, this.asBufSndFile ] ) );
			}, 
			\disk, {
				units.add( U( \diskSoundFile, [ \soundFile, this.asDiskSndFile ] ) );
			},
			\blip, {
				units.add( U( \blipTest, args ) );
			}
		);
		
		switch( this.intType,
			\linear, {
				units.add( 
					U( \wfsSource, [ 
						\point, UMap( \trajectory, [ \trajectory, WFSPathBuffer( wfsPath.asWFSPath2 ) ] ),
						\distanceFilter, 1,
						\maxAmpRadius, 2,
					] ) 
				);
			},
			\cubic, {
				units.add( 
					U( \wfsSource, [
						\point, UMap( \trajectory, [ \trajectory, WFSPathBuffer( wfsPath.asWFSPath2 ) ] ), 
						\distanceFilter, 1,
						\maxAmpRadius, 2,
						\quality, \better
					] ) 
				);
			}, 
			\static, {
				units.add( U( \wfsSource, [ 
					\point, wfsPath.asPoint, 
					\distanceFilter, 1, 
					\maxAmpRadius, 2 
				] ) );
			},
			\plane, {
				units.add( U( \wfsSource, [ 
					\point, wfsPath.distance_(wfsPath.distance.max(1.0e-12)).asPoint,
					\type, \plane,
					\distanceFilter, 1,
					\maxAmpRadius, 2,
					\dbRollOff, -6 // this mimicks the old behaviour
				] ) );
			},
			\index, {
				units.add( U( \wfsIndex, [ \index, wfsPath ] ) );
			}
		);
		
		^UChain( 0, 0, dur, true, *units )
			.fadeIn_( this.fadeInTime )
			.fadeOut_( this.fadeOutTime )
			.setGain( level.ampdb + gain );
	}
	
	asBufSndFile { 
		^BufSndFile.newBasic( filePath, sfNumFrames, 1, sfSampleRate, startFrame, 
			startFrame + this.samplesPlayed, pbRate, loop.asInteger.booleanValue 
		);
	}
	
	asDiskSndFile { 
		^BufSndFile.newBasic( filePath, sfNumFrames, 1, sfSampleRate, startFrame, 
			startFrame + this.samplesPlayed, pbRate, loop.asInteger.booleanValue 
		);
	}
	
}


+ WFSScore {
	
	asUEvent {
		var uevts, maxTrack = 0;
		uevts = events.collect(_.asUEvent);
		if( uevts.size > 0 ) {
			maxTrack = uevts.collect(_.track).maxItem;
		};
		if( clickTrackPath.notNil ) {
			uevts = [ 
				UChain( 0, maxTrack + 1, inf, false,
					[ \diskSoundFile, [ \soundFile, clickTrackPath ] ],
					[ \wfsMasterOut, [ \toServers, false ] ]
				)
			] ++ uevts
		};
		^UScore( *uevts );
	}
}