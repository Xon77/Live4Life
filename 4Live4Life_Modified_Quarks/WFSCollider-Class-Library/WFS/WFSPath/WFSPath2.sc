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

WFSPath2 : WFSPointGroup {
	
	var >times;
	var <type = \bspline; // \bspline, \cubic, \linear (future; add \quad, \step?)
	var <>curve = 1; // curve = 1: hermite
	var <clipMode = 'clip'; // 'clip', 'wrap', 'fold' // TODO for bspline
	var <>name;	
	
	var <>savedCopy;
	
	*new { |positions, times, type, curve, clipMode|
		^super.newCopyArgs( positions, times )
			.init
			.type_( type )
			.curve_( curve ? 1 )
			.clipMode_( clipMode );
	}
	
	*newFromFile { |path|
		var out;
		path = path !? { path.formatGPath; };
		out = WFSPathURL.getWFSPath( path );
		if( out.isNil ) {
			out = this.read( path );
		};
		^out ?? { WFSPathURL( path ); }; // return WFSPathURL if not found
	}
	
	*generate { |size = 20, duration = 5 ...args|
		var editors, path;
		if( args.size == 0 ) { args = [ \circle ] };
		editors = args.collect(_.asWFSPathGenerator);
		path = this.new( {0@0}!size, (duration/(size-1))!(size-1) );
		editors.do({ |ed|
			path = ed.applyFunc( path );
		});
		^path;
	}
	
	init {
		times = times ?? {[1]};
		this.changed( \init );
	}
	
/// TYPES ////////////////////////////////////////
	
	*types { ^[ \bspline, \cubic, \linear ] }
	*clipModes { ^[ \clip, \wrap, \fold ] }
	
	*getType { |in|
		var types;
		types = this.types;
		if( in.isString ) { in = in.asSymbol };
		case { in.isNil } { 
			^types[0];
		} { in.class == Symbol } {
			if( types.includes( in ) ) {
				^in 
			} {
				"%:getType - non existent type %, using % instead\n"
					.format( this.class, in, types[0] )
					.warn;
				^types[0];
			};
		} { in.isNumber } {
			if( in < types.size ) {
				^types[ in.asInteger ];
			} { 
				"%:getType - index (%) out of range, using % instead\n"
					.format( this.class, in, types[0] )
					.warn;
				^types[0];
			};
		} { 
			^types[0];
		};
	}

	*getClipMode { |in|
		var modes;
		modes = this.clipModes;
		if( in.isString ) { in = in.asSymbol };
		case { in.isNil } { 
			^modes[0];
		} { in.class == Symbol } {
			if( modes.includes( in ) ) {
				^in 
			} {
				"%:getClipMode - non existent type %, using % instead\n"
					.format( this.class, in, modes[0] )
					.warn;
				^modes[0];
			};
		} { in.isNumber } {
			if( in < modes.size ) {
				^modes[ in.asInteger ];
			} { 
				"%:getType - index (%) out of range, using % instead\n"
					.format( this.class, in, modes[0] )
					.warn;
				^modes[0];
			};
		} { 
			^modes[0];
		};
	}
	
	indexOfType { ^this.class.types.indexOf( type ) }
	indexOfClipMode { ^this.class.clipModes.indexOf( clipMode ) }
	
	type_ { |newType| type = this.class.getType( newType ); }
	clipMode_ { |newMode| clipMode = this.class.getClipMode( newMode ); }
	
	
/// POSITIONS ////////////////////////////////////////
	
	// dimensions include controls:
	left { ^this.x.minItem.min( this.controls.flat.collect(_.x).minItem ) } 
	back { ^this.y.minItem.min( this.controls.flat.collect(_.y).minItem ) } // is top
	right { ^this.x.maxItem.max( this.controls.flat.collect(_.x).maxItem ) } 
	front { ^this.y.maxItem.max( this.controls.flat.collect(_.y).maxItem ) } // is bottom
		
/// TIMES ////////////////////////////////////////

	times { ^positions[1..].collect({ |item, i| times.wrapAt( i ) }); }
	
	duration { ^this.times.sum }
	dur { ^this.duration }
	speeds { ^this.distances / this.times } // speeds in m/s
	
	asTimeIndexEnv { ^Env( [0] ++ this.times.collect({ |time, i| i+1 }), this.times ); }
	indexAtTime { |time = 0| ^this.asTimeIndexEnv.at( time ); }
	
	timeAtIndex { |index = 0| ^([0] ++ this.times.integrate).blendAt( index ) }
	
	atTime { |time = 0|
		var index, controls;
		index = this.indexAtTime( time );
		controls = this.controls;
		^positions.wrapAt([ index.floor, index.floor+1])
			.splineIntFunction( index.frac, *(controls[index.floor]) ); 
		}	
		
/// POSITIONS AND TIMES /////////////////////////////

	at { |index|
		^[ positions.at( index ), times.clipAt( index ) ]
	}

	
/// CONTROLS ////////////////////////////////////////

	controls {
		^this.generateAutoControls
	}
		
	generateAutoControls { |inType, inClipMode, inCurve|
		if( positions.size > 1 )
		{ 
		^switch( (inType ? type).asString[0].toLower,
			$c, { positions.allSplineIntControls( (inCurve ? curve) / 3, 
					inClipMode ? clipMode ).flop },
			$b, { (	positions.modeAt( (-4..-1), inClipMode ? clipMode ) ++ 
					positions ++ 
					positions.modeAt( positions.size + (..3), inClipMode ? clipMode ) )
						.bSplineIntControls.flop[4..positions.size+4]
				},
			$l, { positions.size.collect({ |i|
					var pts;
					pts = positions.modeAt( [i, i+1], inClipMode ? clipMode );
					[ 	pts[0].blend( pts[1], curve / 3 ),  
						pts[0].blend( pts[1], 1 - (curve / 3) ) 
					]
					}) ;  
				}
			); } 
		{ ^[  [ positions.first, positions.first ] ] };
	}
	
/// EDITING  ///////////////////////////////////////////

	dur_ { |newDur|
		var oldTimes;
		oldTimes = this.times;
		times = (times / times.sum) * newDur;
	}
	
	cutStart { |time = 0| // careful: destructive
		var index, ceiledIndex, firstPos, dur;
		dur = this.dur;
		time = time.clip(0, dur);
		index = this.indexAtTime( time );
		ceiledIndex = index.ceil.asInteger;
		if( index == ceiledIndex ) {
			positions = positions[ceiledIndex..];
			times = this.times[ceiledIndex..];
		} {
			firstPos = this.atTime( time );
			positions = [ firstPos ] ++ positions[ ceiledIndex.. ];
			times = this.times[ ceiledIndex.. ];
			times = [ (dur - times.sum) - time ] ++ times;
		};
	}
	
	cutEnd { |time| // careful: destructive
		var index, flooredIndex, lastPos, dur;
		dur = this.dur;
		if( time < dur ) {
			index = this.indexAtTime( time );
			flooredIndex = index.floor.asInteger;
			if( index == flooredIndex ) {
				positions = positions[..flooredIndex];
				times = this.times[..flooredIndex-1];
			} {
				lastPos = this.atTime( time );
				positions = positions[..flooredIndex] ++ [ lastPos ];
				times = this.times[..flooredIndex-1];
				times = times ++ [ time - times.sum ];
			};
		};
	}
	
/// SELECTION //////////////////////////////////////////

	
	copySelection { |indices, newName = "selection" | // indices should not be out of range!
		var pos, tim;
		indices = indices ?? { (..positions.size-1) };
		pos = positions[ indices ].collect(_.copy);
		tim = this.times[ indices[ 0..indices.size-2 ] ];
		^this.class.new( pos, tim, type, curve, clipMode ).name_( newName );
	}
	
	putSelection { |indices, selectionPath| // in place operation !!
		selectionPath = selectionPath.asWFSPath2; 
		indices = indices ?? { (..selectionPath.positions.size-1) };
		indices.do({ |item, i|
			positions.put( item, selectionPath.positions[i].copy );
			if( i < selectionPath.times.size ) { 
				this.times = this.times.put( item, selectionPath.times[i] ) 
			};
		});	
	}	
	
/// OPERATIONS //////////////////////////////////////////////////////////////

	insertPoint { |index = 0, point|
		var timeToSplit;
		point = point.asPoint;
		timeToSplit = times.foldAt( index - 1 );
		positions = positions.insert( index, point );
		times = this.times.put( index, timeToSplit / 2 ).insert( index, timeToSplit / 2 );
	}
	
	insertMultiple { |index = 0, points, inTimes|
		points = points.asCollection;
		inTimes = (inTimes ? points.collect(0.1))
			.extend( points.size, 0.1 )
			.collect({ |item| item ? 0.1 });
		positions = positions[..index-1] ++ points ++ positions[index..];
		times = this.times[..index-1] ++ inTimes ++ this.times[index..];
		^index + (..points.size-1); // return indices of selection
	}
	
//// TESTING ////////////////////////////////////////

	== { |that|
		if (that.class != this.class) { ^false };
		^(positions == that.positions) && {
			(this.times == that.times) && {
				(clipMode == that.clipMode) && {
					(curve == that.curve) && {
						type == that.type;
					};
				};
			};
		};
	}
	
//// COMPAT WITH OLD WFSPATH VERSION ////////////////////////////////////////

	forceTimes { |timesArray| times = timesArray.asCollection; }
	
	asWFSPath {
		^WFSPath_Old( positions.collect(_.asWFSPoint), times.clipAt( (0..positions.size-2) ) );
	}
	
	asWFSPath2 { ^this }
	
//// STORING AND POSTING ////////////////////////////////////////

	archiveAsCompileString { ^true }
	
	storeOn { arg stream;
		var pth;
		pth = this.filePath;
		if( this.filePath.notNil ) {
			if( this.dirty ) {
				stream << this.class.name << "(" <<<* this.storeArgs << 
					").filePath_( " <<< pth << " )";
			} {
				stream << "WFSPathURL(" <<< pth << ")";
			};
		} {
			stream << this.class.name << "(" <<<* this.storeArgs << ")";		};
	}
	
	storeArgs { ^[ positions, times, type, curve, clipMode ] }
	
//// WRITING AND READING ////////////////////////////////////////
	
	//// Path file format:
	// 
	// 9-channel soundfile, float format
	//
	// first frame:
	//
	// [ -1, type, curve, clipMode, 0 ... ] // space for future extra params
	//
	// rest of the frames:
	//
	// each frame holds time and position date for 1 node of the path
	// each position is stored in 8 values; two sets of 4 (for x and y)
	// each set of 4 position values starts with the position itself, 
	// 		and is followed by 3 values used by the WFSPathPlayer to create the 
	// 		spline curve to the next value. I.e.:
	//
	// [ time, x1, x2, x3, x4, y1, y2, y3, y4 ] 
	
	
	asBufferArray { |includeSettings = false|
		var controls, array;
		controls = this.controls;
		array = positions.collect({ |pos, index|
			([times.clipAt( index )] ++ positions.wrapAt([ index, index+1])
				.splineIntPart1( *(controls[index]) ).collect(_.asArray).flop).flat;
		}).flat;
		if( includeSettings ) { // for writing files
			^[ -1, this.indexOfType ? 0, curve ? 1, this.indexOfClipMode ? 0 ].extend(9,0) ++
				array;
		} {
			^array;
		};
	}
	
	fromBufferArray { |bufferArray, name|
		var p2, c1, c2, controls;
		var settingsArray;
		
		bufferArray = bufferArray.clump(9);
		
		if( bufferArray[0][0] < 0 ) { // includes settings
			
			settingsArray = bufferArray[0];
			
			type = this.class.types[ settingsArray[1].asInteger ] ? this.class.types[0];
			curve = settingsArray[2];
			clipMode = this.class.clipModes[ settingsArray[3].asInteger ] ? this.class.clipModes[0];
			
			#times, positions = bufferArray[1..].collect({ |vals|
				var time, point;
				time = vals[0];
				point = vals[1] @ vals[5];
				[ time, point ]
			}).flop;
			
		} {
			// try to guess the settings
			// doesn't always work because of float32 rounding
			
			#times, positions, p2, c1, c2 = bufferArray.collect({ |vals|
				var time, y1, y2, x1, x2, controls;
				time = vals[0];
				#y1, y2, x1, x2 = vals[1..8].clump(4).collect({ |item|
					this.reverseSplineIntPart1( *item );
				}).flop.collect(_.asPoint);
				
				[ time, y1, y2, x1, x2 ];
			}).flop;
	
			switch ( positions.last.round(1e-12),
				positions.last.round(1e-12), { clipMode = 'clip' },
				positions.first.round(1e-12), { clipMode = 'wrap' },
				positions[ positions.size-2 ].round(1e-12), { clipMode = 'fold' }
			);
			
			controls = [c1, c2].flop.round( 1e-12 );
			
			block { |break|
				([ clipMode ] ++ (#[ clip, wrap, fold ].select(_ != clipMode))).do({ |cm|
					#[ cubic, bspline, linear ].do({ |it|
						if( this.generateAutoControls( it, cm ).round(1e-12) == controls ) {
							clipMode = cm;
							type = it;
							break.value;
						};
					});
				});
				"WFSPath2.fromBufferArray: could not guess type and/or clipMode from array"
					.warn;
			};
		};
		this.name = name ? this.name;
	}
	
	*fromBufferArray { |bufferArray, name|
		^this.new.fromBufferArray( bufferArray, name );
	}
	
	*reverseSplineIntPart1 { |y1, c1, c2, c3|
		var x1, x2, y2;
		x1 = (c1 / 3) + y1;
		x2 = (c2 / 3) + (x1*2) - y1;
		y2 = (c3 + y1) + ((x2 - x1) * 3);
		^[ y1, y2, x1, x2 ];
	}
	
	asBuffer { |server, bufnum, action, load = false|
		// ** NOT USED BY WFSPathBuffer ** //
		var array, buf;
		array = this.asBufferArray;
		if( load ) {
			^Buffer.loadCollection( server, array, 9, action ); 
		} {
			^Buffer.sendCollection( server, array, 9, 0, action ); 
		};
	}
	
	filePath { ^WFSPathURL.getURL( this ) }
	filePath_ { |path, keepOld = true|
		WFSPathURL.putWFSPath( path, this, keepOld );
		this.changed( \filePath );
	} 
	
	dirty { ^this != savedCopy }
	
	write { |path, action|
	    var writeFunc;
	    
	    writeFunc = { 
		    var array, sf, success;
		    array = this.asBufferArray( true ).as( Signal );
		    sf = SoundFile.new.headerFormat_("AIFF").sampleFormat_("float").numChannels_(9);
		    success = sf.openWrite( path.getGPath );
		    if( success ) {
			    sf.writeData( array );
			    sf.close;
			    this.filePath = path;
			    savedCopy = this.deepCopy;
			    action.value( this );

		    		"%:write - written to file:\n%\n".postf( this.class, this.filePath.quote );
		    } {
			    "%:write - could not write file:\n%\n".postf( this.class, path.quote );
		    };
	    };
	    
	    if( path.isNil ) {
		    Dialog.savePanel( { |pth|
			    path = pth;
			    path = path.replaceExtension( "wfspath" );
			    writeFunc.value;
		    } );
	    } {
		    writeFunc.value;
	    };
    }
    
    read { |path, action| // returns nil if no success
	    var sf, array, readFunc;
	    
	    readFunc = {	
		    sf = SoundFile.new;
		    path = path.getGPath;
		    if( sf.openRead( path ) ) {
			    if( sf.numChannels != 9 ) {
				     "%:read - numChannels (%) != 9\n% is not a valid % file\n"
				     	.format( this.class, sf.numChannels, path, this )
				     	.warn;
				     sf.close;
				     ^nil;
			    } {
				    if( sf.sampleFormat != "float" ) {
					    "%:read - sampleFormat (%) != float \n% may not be a valid % file\n"
				     		.format( this.class, sf.sampleFormat, path, this )
				     		.warn;
				    }; // read it anyway
				    array = FloatArray.newClear( sf.numFrames * 9 );
				    sf.readData( array );
				    sf.close;
				    this.fromBufferArray( array, path.basename.removeExtension );
				    this.filePath = path;
				    savedCopy = this.deepCopy;
				    action.value( this );
			    }
		    } {
			   "%:read - could not open file %\n"
			   	.format( this.class, path )
			   	.warn;
			   ^nil;
		    };
		};
		
		if( path.isNil ) {
		    Dialog.getPaths( { |pth|
			    path = pth[0];
			    readFunc.value;
		    } );
	    } {
		    readFunc.value;
	    };
    }
    
    revert { |action| 
	    if( this.filePath.notNil ) {
	    		this.read( this.filePath, action ) 
	    } {
		    "%:revert - can't revert: no filePath is known"
		    		.format( this.class )
			   	.warn;
	    };
	}
    
    *read { |path|
		^this.new.read( path );
    }
    
    //// VARIOUS //////////////////////////////////////
    
    isWFSPath2 { ^true }
    
    asWFSPointGroup { ^WFSPointGroup( positions.deepCopy ) }
    
    exists { ^true }
	
}

+ Object { 
	isWFSPath2 { ^false }
}

+ WFSPath_Old {
	asWFSPath2 {
		^WFSPath2( this.positions.collect(_.asPoint), this.times, \cubic )
			.name_( this.name );
	}
}

+ String {
	asWFSPath2 {
		^WFSPath2.newFromFile( this );
	}
}

+ Collection {
	asWFSPath2{
		^WFSPath2( this.collectAs(_.asPoint, Array) );
	}
}

+ Symbol {
	asWFSPath2 { |size = 20, dur = 5|
		^WFSPath2.generate( size, dur, this );
	}
}

+ Nil {
	asWFSPath2 { 
		^WFSPath2( { |i| Polar( 8, i.linlin(0,15,0,2pi) ).asPoint  } ! 15, [0.5], \bspline )
	}
}
