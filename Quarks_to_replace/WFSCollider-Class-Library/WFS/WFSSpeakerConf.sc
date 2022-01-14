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

WFSArrayConf { // configuration for one single speaker array
	
	var <n = 48, <dist = 5, <angle = 0.5pi, <offset = 0, <spWidth;
	var <>corners;
	var <>cornerAngles; // angle to next array
	var <>oppositeDist = -inf;
	
	/*
	
	A WFSArrayConf describes a single straight line of n equally spaced loudspeakers.
	
		n: number of speakers
		dist (m): distance from center
		angle (radians): angle from center (facing the speakers)
		offset (m): amount of shift to right when facing the speakers
		spWidth (m): spacing between individual speakers
	
	explanation of variables:
	
	angles are counter-clockwise starting at x axis:
	
	 angle 0.5pi: front array      angle 0: righthand side array
	       
	          |y(+)                               |y(+)
	          |                                   |
	          |                                   |        
	       ---+---                                |    
	x(-)      |dist   x(+)              x(-)      |   |   x(+)
	----------+----------               ----------+---+------            
	          |                                   |   | 
	          |                                   |    
	          |                                   |     
	          |y(-)                               |y(-)          
	          
	and so on:
	 	angle -0.5pi: back array
		angle pi (or -pi): lefthand side array
		
		
	
	corners are the points where two adjecent arrays cross:
	
	  array
	---------  x <- corner
	        
	           |a
	           |r
	           |r
	           |a
	           |y
	           
	           
	 each array has two corner points:
	  
	 x  -------------  x
	 1      array      2
	 
	 the cornerAngles are the angles between the adjecent arrays. They are also the area
	 where the crosfade happens when a point passes from behind one array to behind another.
	 
	 
	           |
	array      | angle, crossfade area  <- (0.5pi in this case)
	---------  x ----
	        
	           |a
	           |r
	           |r
	           |a
	           |y
	*/
	
	*new { |n = 48, dist = 5, angle = 0.5pi, offset = 0, spWidth|
		^super.newCopyArgs( n, dist, angle, offset, spWidth ? WFSBasicPan.defaultSpWidth )
			.init;
	}
	
	== { |that| // use === for identity
		^this.compareObject(that);
	}
	
	init {
		corners = [ dist, dist.neg ]; // assumes square setup
		cornerAngles = [ 0.5pi, 0.5pi ]; // assumes rectangular setup
	}
	
	asWFSArrayConf { ^this }
	
	adjustCorner1To { |aWFSArrayConf|
		aWFSArrayConf = aWFSArrayConf.asWFSArrayConf;
		cornerAngles[0] = (angle - aWFSArrayConf.angle).wrap(-pi,pi).abs;
		corners[0] = ( dist - ( aWFSArrayConf.dist/ cos(cornerAngles[0]) ) )
			/ tan(cornerAngles[0]).neg;
		if( corners[0].isNaN ) { corners[0] = 200 };
		if( cornerAngles[0].equalWithPrecision( pi ) ) { 
			cornerAngles[0] = 0.5pi;
			corners[0] = 200;
		}; 
	}
	
	adjustCorner2To { |aWFSArrayConf|
		aWFSArrayConf = aWFSArrayConf.asWFSArrayConf;
		cornerAngles[1] = (angle - aWFSArrayConf.angle).wrap(-pi,pi).abs;
		corners[1] =  ( dist - ( aWFSArrayConf.dist/ cos(cornerAngles[1]) ) )
			/ tan(cornerAngles[1]);
		if( corners[1].isNaN ) { corners[1] = -200 };
		if( cornerAngles[1].equalWithPrecision( pi ) ) {
			cornerAngles[1] = 0.5pi;
			corners[1] = -200;
		}; 
	}
	
	findOppositeDist { |wfsSpeakerConf|
		var oppositeArray, myAngle;
		myAngle = angle.wrap(-pi,pi);
		oppositeArray = wfsSpeakerConf.arrayConfs.detect({ |item|
			(item.angle + pi).wrap(-pi,pi).equalWithPrecision( myAngle )
		});
		if( oppositeArray.notNil ) {
			oppositeDist = oppositeArray.dist.neg;
		} {
			oppositeDist = -inf;
		};
	}
	
	asArray { ^[ n, dist, angle, offset, spWidth ] }
	asCornersArray { ^(corners ++ cornerAngles); }
	
	asControlInput { ^this.asArray }
	asOSCArgEmbeddedArray { | array| ^this.asArray.asOSCArgEmbeddedArray(array) }
	
	*fromArray { |array| ^this.new( *array ); }
	
	fromCornersArray { |array| // adjust corners / angles from array
		if( array.notNil ) {
			corners = array[[0,1]];
			cornerAngles = array[[2,3]];
		};
	}
	
	n_ { |newN| n = newN.asInteger; this.changed( \n, n ); }
	dist_ { |newDist| 
		dist = newDist; 
		this.changed( \dist, dist );
		this.changed( \center, this.center ); 
	}
	angle_ { |newAngle| 
		angle = newAngle; 
		this.changed( \angle, angle ); 
		this.changed( \center, this.center ); 
	}
	offset_ { |newOffset| offset = newOffset; this.changed( \offset, offset ); }
	spWidth_ { |newSpWidth| spWidth = newSpWidth; this.changed( \spWidth, spWidth ); }
	
	center { ^Polar( dist, angle ).asPoint; }
	center_ { |newCenter|
		newCenter = newCenter.asPolar;
		dist = newCenter.rho;
		angle = newCenter.theta; 
		this.changed( \dist, dist );
		this.changed( \angle, angle );
		this.changed( \center, this.center );
	}
	
	rotate { |amount = 0| this.angle = angle + amount; }
	
	rotatedPointAt { |index = 0|
		^( dist @ ( ( (index - ((n-1)/2)) * spWidth) - offset ) );
	}
	
	rotatedFirstPoint {
		^this.rotatedPointAt(0);
	}
	
	rotatedLastPoint {
		^this.rotatedPointAt(n-1);
	}
	
	pointAt { |index = 0|
		^this.rotatedPointAt(index).rotate( angle )
	}
	
	firstPoint {
		^this.pointAt(0);
	}
	
	lastPoint {
		^this.pointAt(n-1);
	}
	
	centerPoint {
		^( dist @ offset.neg ).rotate( angle );
	}
		
	asPoints { // for plotting
		^n.collect({ |i| this.pointAt(i)});
	}
	asLine { // for plotting; start point and end point
		^[ this.firstPoint, this.lastPoint ];
	}
	
	cornerPoints {
		^corners.collect({ |c|
			( dist @ c ).rotate( angle );
		});
	}
	
	cornerPoints_ { |array|
		var current;
		array = array.asCollection.extend( 2, nil );
		if( array.any(_.isNil) ) {
			current = this.cornerPoints;
			array[0] = array[0] ? current[0];
			array[1] = array[1] ? current[1];
		};
		this.prCornerPoints_( array );
	}
	
	prCornerPoints_ { |array|
		// re-calculate angle and dist from corner points
		angle = ((array[1] - array[0]).angle + 0.5pi).wrap(-pi,pi);
		dist = array[0].dist(0@0) * (angle - array[0].angle.wrap(-pi,pi)).cos;
		if( dist < 0 ) { 
			angle = (angle + pi).wrap(-pi,pi);
			dist = dist.neg;
			array = array.reverse;
		};
		corners = array.collect({ |pt| pt.rotate( angle.neg ).y });
	}
	
	draw { |mode = \lines| // 1m = 1px
		Pen.use({
			Pen.scale(1,-1);
			switch( mode,
				\lines, { 
					Pen.line( *this.asLine ).stroke 
				},
				\points, {
					this.asPoints.do({ |pt| 
						Pen.addWedge( pt, spWidth / 2, angle - 0.5pi, pi ).fill;
					}) 
			 	}
			);
		});
	}
	
	storeArgs { ^[n, dist, Angle(angle), offset, spWidth] }

}


WFSSpeakerConf {
	
	// a collection of WFSArrayConfs, describing a full setup
	// WFSSpeakerConfs are designed to be fully surrounding setups
	
	classvar <numSystems, <>serverGroups;
	classvar <>default;
	classvar <>presetManager;
	classvar <>outputBusStartOffsets;
	
	var <arrayConfs;
	var <>arrayLimit = 1;
	var <>focusWidth = 0.5pi;
	
	var <>focusDetector;
	
	var <>gain = 0; // in db
	
	
	*initClass { 
		Class.initClassTree( PresetManager );
		presetManager = PresetManager( WFSSpeakerConf );
		presetManager.presets = [
		 	'default', WFSSpeakerConf.rect(48,dx:5),
		 	'rect',  WFSSpeakerConf.rect(40, 56, 5.5, 4.5),
		 	'square9x9',  WFSSpeakerConf.rect(48,dx:4.5),
		 	'single64',  WFSSpeakerConf([64, 5, 0.5pi, 0, 0.164]).arrayLimit_(0.5),
		 	'bea7', WFSSpeakerConf(
				[ 24, 2.77, 1.5pi, 0, 0.17 ], 
				[ 32, 2.2958816567648, 0.97527777777778pi, -0.17867399847052, 0.17 ], 
				[ 24, 2.83, 0.5pi, 0, 0.17 ], 
				[ 32, 2.2958816567648, 0.024722222222222pi, 0.17867399847052, 0.17 ]
			),
		 	'sampl', WFSSpeakerConf([32, 5, 0.5pi, 0, 0.1275]).arrayLimit_(0.3).focusWidth_(2pi),
		 	'parma', WFSSpeakerConf([ 35, 3.64, 0.5pi, 0, 0.12 ], [ 60, 2.14, 0, 0, 0.12 ], [ 34, 3.64, -0.5pi, 0.0, 0.12 ], [ 60, 2.14, pi, 0.0, 0.12 ]),
		 ];
		 presetManager.applyFunc_( { |object, preset|
			 	if( object === WFSSpeakerConf ) {
				 	preset.deepCopy;
			 	} {	
				 	object.arrayLimit = preset.arrayLimit;
				 	object.focusWidth = preset.focusWidth;
				 	object.gain = preset.gain;
				 	object.arrayConfs = preset.arrayConfs.deepCopy;
				 }
		 	} );
		
		this.numSystems = 2; // create server library
		outputBusStartOffsets = IdentityDictionary();
	}
	
	*new { |...args|
		^super.newCopyArgs().arrayConfs_( args );
	}
	
	init {
		// adjust corners and cornerAngles to each other
		
		var sortedConfs;
		
		sortedConfs = arrayConfs.copy.sort({ |a,b| a.angle >= b.angle });
		
		sortedConfs.do({ |conf, i|
			conf.adjustCorner1To( sortedConfs.wrapAt( i-1 ) );
			conf.adjustCorner2To( sortedConfs.wrapAt( i+1 ) );
		});
		
		arrayConfs.do({ |item|
			item.findOppositeDist( this );
		});
		
		focusDetector = WFSFocusDetector( this.uniqueCorners );
		
		this.changed( \init );
	}
	
	arrayConfs_ { |newConfs| 
		arrayConfs = newConfs.collect(_.asWFSArrayConf); 
		this.changed( \arrayConfs );
		this.init;
	}
	
	*fromPreset { |name| ^presetManager.apply( name ) }
	
	fromPreset { |name| ^presetManager.apply( name, this ); }
	
	== { |that| // use === for identity
		^this.compareObject(that);
	}
	
	planeWaveMakeUpGain { ^48 / arrayConfs.collect(_.n).mean } // gain if array size != 48
	
	// fast creation
	*rect { |nx = 48, ny, dx = 5, dy| // dx/dy: radius (i.e. from center to array)
		ny = ny ? nx;
		dy = dy ? dx;
		^this.new( [ nx, dx, 0.5pi ], [ ny, dy, 0 ], [ nx, dx, -0.5pi ], [ ny, dy, pi ] );
	}
	
	*polygon { |n = 6, r = 5, nsp = 192|
		^this.new( *n.collect({ |i|
			[ (nsp / n).asInteger, r, i.linlin(0, n, 0.5pi, -1.5pi) ]
		}) );
	}
	
	makeDefault { default = this; }
	
	at { |index| ^arrayConfs[ index ] }
	
	copySeries { |first, second, last|  ^arrayConfs.copySeries( first, second, last ) }
	
	put { |index, obj| this.arrayConfs = arrayConfs.put( index, obj ); }
	
	add { |arrayConf| this.arrayConfs = arrayConfs.add( arrayConf ); }
	
	addArray { |keepSpeakerCount = false|
		// intelligently expand the setup by one array
		var startAngle, diffs, scaleAmt, newAngles;
		var newConf;
		diffs = arrayConfs.collect(_.angle);
		startAngle = diffs[0];
		diffs = diffs.differentiate[1..].wrap(-pi,pi);
		scaleAmt = this.size / (this.size + 1);
		diffs = diffs * scaleAmt;
		newAngles = ([ startAngle ] ++ diffs).integrate;
		newConf = WFSArrayConf( 
			arrayConfs.last.n, 
			[ arrayConfs.last.dist, arrayConfs.first.dist ].mean,
			newAngles.last - ((newAngles.last - (newAngles.first + 2pi))/2),
			0,
			arrayConfs.last.spWidth
		);
		arrayConfs.do({ |item, i|
			item.angle = newAngles[i].wrap(-pi,pi);
		});
		this.arrayConfs = arrayConfs.add( newConf );
	}
	
	removeArray { 
		// intelligently expand the setup by one array
		var startAngle, diffs, scaleAmt, newAngles;
		if( arrayConfs.size > 1 ) {	
			diffs = arrayConfs.collect(_.angle);
			startAngle = diffs[0];
			diffs = diffs.differentiate[1..].wrap(-pi,pi);
			scaleAmt = this.size / (this.size - 1);
			diffs = diffs * scaleAmt;
			newAngles = ([ startAngle ] ++ diffs).integrate;
			arrayConfs.do({ |item, i|
				item.angle = newAngles[i].wrap(-pi,pi);
			});
			this.arrayConfs = arrayConfs[..arrayConfs.size-2];
		} {
			"%:removeArray - number of arrays can't be < 1".postln;
		};
	}
	
	rotate { |angle = 0| 
		arrayConfs.do(_.rotate(angle));
		this.init;
	}
	
	removeAt { |index|
		arrayConfs.removeAt( index );
		this.init;
	}
	
	size { ^arrayConfs.size }
	
	speakerCount { ^arrayConfs.collect(_.n).sum; }
	
	setSpeakerCount { |speakers = 192, unitSize = 8|
		var currentCount;
		var counts, countsCopy, index;
		var addArray, mul = 1, i = 0;
		speakers = speakers.round( unitSize ).max( this.size * unitSize );
		counts = arrayConfs.collect({ |item| item.n.round( unitSize ) });
		countsCopy = counts.copy;
		if( speakers < counts.sum ) { mul = -1 };
		while { (counts.sum != speakers) && { i < 1000 }} {
			index = ((counts * countsCopy) * mul).minIndex;
			counts[index] = counts[index] + (unitSize * mul);
			i = i+1; // timeout
			if( i == 1000 ) { 
				"WFSSpeakerConf:setSpeakerCount - timeout occurred";
				counts = arrayConfs.collect({ |item| item.n.round( unitSize ) });
			};
		};
		//addArray.sort;
		arrayConfs.do({ |item, i|
			item.n = counts[i]
		});
	}
	
	divideArrays { |n| // split the arrayConfs into n equal (or not so equal) groups
		n = n ? numSystems;
		^arrayConfs.clump( arrayConfs.size / n );
		
	}
	
	getArrays { |i = 0, n| // arrays for single server (server i out of n)
		^this.divideArrays(n)[i];
	} 
	
	getArraysFor { |server|
		var i;
		i = this.class.systemOfServer( server );
		if( i.notNil ) {
			^this.divideArrays[i]
		} {
			^[]; // empty array if not found
		};
	}
	
	firstSpeakerIndexOf { |server|
		var i;
		i = this.class.systemOfServer( server );
		if( i.notNil ) {
			^this.divideArrays[..i-1].flatten(1).collect(_.n).sum;
		} {
			^nil; // nil if not found
		};
	}
	
	lastSpeakerIndexOf { |server|
		var i;
		i = this.class.systemOfServer( server );
		if( i.notNil ) {
			^this.divideArrays[..i].flatten(1).collect(_.n).sum - 1;
		} {
			^nil; // nil if not found
		};
	}
	
	uniqueCorners {
		var allCorners, uniqueCorners;
		allCorners = this.arrayConfs.collect(_.cornerPoints).flatten(1);
		uniqueCorners = [];
		allCorners.do({ |a|
			if( uniqueCorners.any({ |b| 
				b = b.asArray;
				a.asArray.every({ |item, i|
					if( item.isFloat ) {
						item.equalWithPrecision( b[i] );
					} {
						item == b[i];
					};
				});
			}).not ) {
				uniqueCorners = uniqueCorners.add( a );
			};
		});
		^uniqueCorners;
	}
	
	// Server management
	
	*numSystems_ { |n = 2| // number of systems to divide the speakerarrays over
		numSystems = n;
		serverGroups = numSystems.collect({ |i|
			(serverGroups ? [])[i] ?? { Set() };
		});
	}
	
	*addServer { |server, system = 0, outputBusStartOffset|
		server = server.asCollection.collect(_.asTarget).collect(_.server);
		server.do({ |server|
			serverGroups[ system ].add( server );
			if( outputBusStartOffset.notNil ) {
				this.setOutputBusStartOffset( server, outputBusStartOffset );
			};
		});
	}
	
	*removeServer { |server|
		server = server.asCollection.collect(_.asTarget).collect(_.server);
		server.do({ |server|
			serverGroups.do(_.remove(server));
			this.removeOutputBusStartOffset( server );
		});
	}
	
	*systemOfServer { |server|
		serverGroups.do({ |item, i|
			if( item.includes(server) ) { ^i };
		});
		^nil;
	}
	
	*includesServer { |server|
		^this.systemOfServer( server ).notNil;
	}
	
	*resetServers {
		serverGroups = nil;
		this.numSystems = this.numSystems;
	}
	
	*setOutputBusStartOffset { |server, bus = 0|
		outputBusStartOffsets.put( server.asTarget.server, bus );
	}
	
	*getOutputBusStartOffset { |server|
		^outputBusStartOffsets[ server.asTarget.server ] ? 0
	}
	
	*removeOutputBusStartOffset { |server|
		outputBusStartOffsets.put( server.asTarget.server, nil );
	}
	
	// drawing
	asPoints { ^arrayConfs.collect(_.asPoints).flat }
	
	asLines { ^arrayConfs.collect(_.asLine) }
	
	asRect {
		var allPoints, allX, allY;
		allPoints = [0@0] ++ this.asLines.flatten(1);
		#allX, allY = ([0@0] ++ this.asLines.flatten(1)).collect(_.asArray).flop;
		^Rect.fromPoints( allX.minItem @ (allY.minItem), allX.maxItem @ (allY.maxItem) );
	}
	
	draw { |mode = \lines| arrayConfs.do(_.draw(mode)); }
	
	plot {
	}
	
	storeArgs { ^arrayConfs.collect(_.storeArgs) }
	storeModifiersOn { |stream|
		if( arrayLimit != 1 ) {
			stream << ".arrayLimit_( " <<< arrayLimit << " )";
		};
		if( gain != 0 ) {
			stream << ".gain_( " <<< gain << " )";
		};
		if( focusWidth != 0.5pi ) {
			stream << ".focusWidth_( " <<< (focusWidth/pi) << "pi )";
		};
	}
}
