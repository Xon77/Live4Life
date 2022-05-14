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

WFSCrossfader {
	// handles the crossfading between arrays, for point sources
	var <>arrayConfs;
	var <>point;	
	var <focusWidth = 0.5pi;
	var <cornerPoints, <crossfadeData;
	
	*new { |point = (0@0), arrays, cornerArrays, focusWidth = 0.5pi|
		
		// feed me with: 
		//   arrays: an array of WFSArrayConfs, or an array of arrays that can be 
		//           converted to WFSArrayConfs
		//   cornerArrays: arrays formatted as 
		//                 [ [ corner1, corner2, cornerAngle1, cornerAngle2 ], ...etc]
		//     - cornerArrays will override the corner settings stored in the WFSArrayConfs.
		//       Why? Because these may be provided as controls of a SynthDef
		
		arrays = arrays.collect(_.asWFSArrayConf).collect(_.copy);
		cornerArrays.do({ |item, i|
			arrays[i].fromCornersArray( item );
		});
		
		^super.newCopyArgs( arrays, point.asPoint, focusWidth ).init;
	}
	
	init {
		
		var globalAngle, fadeArea;
		
		// for the focusFades
		globalAngle = point.angle;
		fadeArea = point.rho.linlin(0.5,1,pi,focusWidth/2,\none).clip(focusWidth/2,pi); 
		
		cornerPoints = arrayConfs.collect( _.cornerPoints );
		
		crossfadeData = cornerPoints.collect({ |pts, i|
			var angle, arr, focusedActive;
			var rotatedAngle, firstAngle, lastAngle, angleIsPositive;
			
			angle = arrayConfs[i].angle;
			
			arr = pts.collect({ |pt, ii|
				var pos, alpha, halfAlpha, invHalfAlpha;
				var cornerFade, focused;
				alpha = arrayConfs[i].cornerAngles[ii]; // angle towards prev/next array
				pos = (point - pt).angle - angle;
				if( ii.odd ) { pos = pos.neg };
				
				// corner fade
				halfAlpha = alpha / 2;
				invHalfAlpha = (0.5pi - halfAlpha);
				cornerFade = (pos - halfAlpha)
					.fold( -0.5pi, 0.5pi )
					.linlin( invHalfAlpha.neg, invHalfAlpha, 1, 0, \minmax );
					
				// focused (0/1)
				focused = pos.wrap( -0.5pi, 1.5pi )
					.inRange( 0.5pi + alpha, 1.5pi )
					.binaryValue;
				
				[ cornerFade, focused ];
				
			}).flop;
			
			// focused active
			if( WFSArrayPan.useFocusFades ) {
				
				rotatedAngle = (globalAngle - angle).wrap(-pi,pi);
				firstAngle = (arrayConfs[i].lastPoint.angle - angle).wrap(-pi,pi);
				lastAngle = (arrayConfs[i].firstPoint.angle - angle).wrap(-pi,pi);
				angleIsPositive = (rotatedAngle > 0).binaryValue;

				focusedActive = [
					((rotatedAngle - fadeArea) < firstAngle).binaryValue,
					((rotatedAngle + fadeArea) > lastAngle).binaryValue,
				] * [ angleIsPositive, 1 - angleIsPositive ];
				
				focusedActive = focusedActive[0].max( focusedActive[1] );
			} {
				focusedActive = 1;
			};
			
			[ arr[0].product.sqrt, arr[1].product, focusedActive ];

		});		

	}
	
	focusWidth_ { |new = 0.5pi|
		focusWidth = new;
		this.init;
	}
	
	kr {
				
		// outputs array of crossfades per speakerArray
		// first value: corner crossfade level (for normal (unfocused) point sources)
		// second value: focused (1 if focused, 0 if not)
		// third value: focusedActive (1 if focused source is actually sounding on this array, 0 if not)
		//  format:
		// [ [ cornerfade, focused, focusedActive ], [ cornerfade, focused, focusedActive ] etc.. ]
		
		^crossfadeData;	
	}
	
	cornerfades {
		^crossfadeData.flop[0];
	}
	
	focused {
		^crossfadeData.flop[1];
	}
	
	focusedActive {
		^crossfadeData.flop[2];
	}
	
	normalArraysShouldRun {
		^crossfadeData.collect({ |item|
			(item[0] > 0).binaryValue * (1-item[1]);
		});
	}
	
	focusedArraysShouldRun {
		^crossfadeData.collect({ |item|
			item[1] * item[2];
		});
	}
	
	arraysShouldRun { |focus|
		case { focus.isNil } {
			^max( this.normalArraysShouldRun, this.focusedArraysShouldRun );
		} { focus == true } {
			^this.focusedArraysShouldRun;
		} { focus == false } {
			^this.normalArraysShouldRun;
		};
	}
	
}

WFSCrossfaderPlane {
	var <>arrayConfs;
	var <>point;
	var <crossfades;
	
	*new { |point = (0@0), arrays|
		
		// feed me with: 
		//   arrays: an array of WFSArrayConfs, or an array of arrays that can be 
		//           converted to WFSArrayConfs
		
		arrays = arrays.collect(_.asWFSArrayConf).collect(_.copy);
		^super.newCopyArgs( arrays, point.asPoint ).init;
	}
	
	init {
		
		var globalAngle;
		
		// for the focusFades
		globalAngle = point.angle;
		
		crossfades = arrayConfs.collect({ |conf, i|
			(globalAngle - conf.angle)
				.wrap(-pi,pi)
				.linlin(-0.5pi,0.5pi,0,2,\minmax)
				.fold(0,1)
				.sqrt;
		});		

	}
	
}

WFSBasicPan {
	
	classvar <>defaultSpWidth = 0.164;
	classvar <>speedOfSound = 344; // replaced in initClass by more accurate value
	classvar >sampleRate = 44100;
	
	var <>buffer, <pos;
		
	var <>maxDist = 200;
	var <>addDelay = 0;
	
	*initClass {
		this.setSpeedOfSound;
	}
	
	*setSpeedOfSound { |temp = 20| // 20 = normal room temperature
		^speedOfSound = Number.speedOfSound(temp);
	}
	
	latencyComp { ^1 }
	
	maxDelay { ^( this.preDelay * 2 ) + this.addDelay + ( ( maxDist * ( 1 - this.latencyComp ) ) / speedOfSound ) }
	bufSize { ^2 ** ( (this.maxDelay * this.sampleRate).log2.roundUp(1).max(0) ) } // next power of two, but not 0
	
	// set in subclasses (can be vars too)
	preDelay { ^0 } 
	intType { ^'C' } 
	
	sampleRate {
		if( UGen.buildSynthDef.notNil ) { // if in a SynthDef
			^SampleRate.ir; // return actual sampleRate
		} { 
			^sampleRate
		};	
	}
	
	delay { |source, delay, amp, add = 0|
		if( UGen.buildSynthDef.notNil ) { // if in a SynthDef
			if( buffer.isNil ) { // create LocalBuf if needed
				buffer = LocalBuf( this.bufSize, 1 ).clear;
			};
					
			^("BufDelay" ++ this.intType.toUpper).asSymbol.asClass
				.ar( buffer, source, delay, amp, add );
		} { 
			^[ delay, source * amp ] // return delays and amplitudes (if not in a SynthDef)
		};	
	}
	
}

// the actual panners:

WFSPrePan : WFSBasicPan {
	
	// pre panning stage:
	/*
	- add large global delay (based on distance from center)
	- impose global amplitude roll-off
	- apply to source before WFSArrayPan
	*/
	
	var <>dbRollOff = -6; // global rolloff (relative to center of room)
	var <>limit = 2; // center radius in m (no rolloff here)
	var <>latencyComp = 0; // 1: max, 0: off 

	preDelay { ^0 } // no predelay here
	intType { ^'C' } // fixed (we might want this to be changeable?)
	
	*new { |dbRollOff = -6, limit = 2, latencyComp = 0, buffer|
		^this.newCopyArgs()
			.dbRollOff_( dbRollOff )
			.limit_( limit )
			.latencyComp_( latencyComp )
			.buffer_( buffer )
	}
	
	ar { |source, inPos, mul = 1, add = 0|
		var dist, limitAmp, amp;
		
		pos = (inPos ? pos ? (0@0)).asPoint;
		
		dist =  pos.dist( 0 @ 0 ); // distance to center
		
		limitAmp = limit.max(1).pow(dbRollOff/6); // limiting the limit to 1m to prevent large amp
		amp = (dist.pow(dbRollOff/6) / limitAmp).min( 1 ); // limit to prevent blowup
		
		// all together
		^this.delay( source * amp, 
			( ( dist / speedOfSound ) * (1 - latencyComp) ) + addDelay, 
			mul,
			add  
		);
	}
	
}


WFSBasicArrayPan : WFSBasicPan {
	
	// point source on single array, without large delay
	
	var <n, <dist, <angle, <offset, <spWidth;
	var <>intType = 'N'; // intType 'N', 'L', 'C'
	
	
	var <speakerArray; // fixed at init
	var <distances, <amplitudes, <delayTimes;
	
	var <>preDelay = 0.06; // in s (= 20m)
	
	*new { |n = 48, dist = 5, angle = 0.5pi, offset = 0, spWidth| // angle: 0-2pi (CCW)
		^super.newCopyArgs().init(  n, dist, angle, offset, spWidth );
	}
	
	init { |inN = 48, inDist = 5, inAngle= 0.5pi, inOffset = 0, inSpWidth|
		
		n = inN ? n; // number of speakers
		dist = inDist ? dist; // distance from center
		angle = inAngle ? angle; // angle from center
		offset = inOffset ? offset; // offset in m (to the right if angle == 0.5pi)
		spWidth = inSpWidth ? spWidth ? defaultSpWidth; // width of individual speakers
		
		speakerArray = { |i| (i.linlin(0, n-1, spWidth / 2, spWidth.neg / 2 ) * n) - offset } ! n;
	}

}
	
	
WFSArrayPan : WFSBasicArrayPan {
	
	/*
	// panning a point on a single array
	// global distance and amplitude are cancelled out, only the differences between 
	// the individual speakers are applied
	
	// use like this:
	
	p = WFSArrayPan( 48, 5, 0.5pi ); // init with array specs and int type
	p.ar( source, pos, \L ); // generate output, linear interpolation (default \N = no interp)
	
	// or:
	
	WFSArrayPan( 48, 5, -0.5pi ).ar( source, pos, \L );
	
	// when used outside a SynthDef the values are returned in the format:
	// [ [ delayTimes ... ], [ amplitudes * source .. ] ];
	
	// example of normal source straight behind a 48-speaker front array
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, 0@7 ).plot2; // delays on top, amps on bottom
	
	// when approaching the array the limit (default: 1m) kicks in
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, -2@5.5 ).plot2; // shifted left and closer to array
	
	// when inside the array the source becomes focused (i.e. delays inversed)
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, 0@3 ).plot2; // focused source
	
	// focused sources use a window for determining where they play
	// the window has a 90 degree radius. 
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, -1@1 ).plot2; // focused source
	
	// If a source is turned more than 
	// 90 degrees off the speaker array it will not sound at all:
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, -1@ -1 ).plot2; // focused source
	
	// But if it is within 1m from the center of the room
	// it will play on all speakers
	WFSArrayPan( 48, 5, 0.5pi ).ar( 1, 0@0 ).plot2; // focused source
	
	
	// WFSArrayPan can be forced to do only focused or unfocused sources via the focus var
	// 	focus = nil : switch automatically
	//	focus = false: always unfocused (also bypasses focus crossfades)
	//   focus = true: always focused
	//  
	// if focus is 0 but the location is in front WFSArrayPan will create
	// a variation of the unfocused (normal) wavefield. This is on itself a non-existent
	// and "faulty" wavefield, but it allows an overlap area between focused
	// and normal sources.
	// 
	// Typically the forced focus setting is used for dynamic wavefields to create a 
	// smooth transition between focused and unfocused. 
	
	WFSArrayPan( 48, 5, 0.5pi ).focus_(false).ar( 1, 0@3 ).plot2; // forced unfocused source
	
	( //  a transition from behind to in front with forced unfocus
	p = WFSArrayPan(48, 5, 0.5pi ).focus_(false);
	{ |i| p.ar(1, 0@i.linlin(0,9,7,3) )[0] }.dup(10).plot2
	)
	
	( //  a normal transition from behind to in front (notice the inversion in the middle)
	p = WFSArrayPan(48, 5, 0.5pi );
	{ |i| p.ar(1, 0@i.linlin(0,9,7,3) )[0] }.dup(10).plot2
	)
	
	*/
	
	classvar <>useFocusFades = true; // need to rebuild synthdefs after changing this
	classvar <>tapering = 0;
	
	var <>focus; // nil, true or false
	var <>dbRollOff = -9; // per speaker roll-off
	var <>limit = 1; // in m, clipping amplitude from here to prevent inf
	var <>focusWidth = 0.5pi;
	
	ar { |source, inPos, int, mul = 1, add = 0| // inPos: Point or Polar
		var difx, dify, sqrdifx, inFront, crossing, delayOffset;
		var globalDist, globalAngle, speakerAngleRange, focusFades, fadeArea;

		// rotate point to array
		pos = (inPos ? pos ? (0@0)).rotate( angle.neg ).asPoint;
		
		globalDist = pos.dist( 0 @ 0 ); // distance to center
		
		// ------- calculate distances --------
		difx = pos.x - dist; // only once
		dify = pos.y - speakerArray;
		
		distances = ( difx.squared + dify.squared ).sqrt;
		
		// determine focus multiplier (-1 for focused or 1 for normal) 
		inFront = ( ( difx >= 0 ).binaryValue * 2 ) - 1;
		
		
		// ------- calculate delay times --------
		if( focus.isNil ) { 
			// auto switch (for static sources)
			delayTimes = distances * inFront;
		} {	
			// create overlapping area (for dynamic sources)
			delayTimes = ( ( ( ( focus.binaryValue * -2 ) + 1 ) - inFront ) * dify.abs) 
				+ (distances * inFront);
		};
		
		delayTimes = delayTimes / speedOfSound;
		
		// subtract large delay
		delayOffset = addDelay + preDelay - ( globalDist / speedOfSound );
		
		
		// ------- calculate amplitudes --------
		amplitudes = distances.pow(dbRollOff/6).min( limit.pow(dbRollOff/6) );
		
		// apply tapering
		amplitudes = amplitudes * (1..n).fold(0,(n/2) + 0.5)
				.linlin(0, (n+1) * tapering, -0.5pi, 0.5pi )
				.sin
				.linlin(-1,1,0,1);
		
		amplitudes = amplitudes * ( mul / amplitudes.sum ); // normalize amps (sum == mul)
		
		// focus crossfades (per speaker, dependent on angle)
		//
		// these are not ideal yet
		//
		// go to all speakers when source is 0.5m to 1m from the center
		// approximation of angles, saves n * atan2 calc. Now we only calculate the corner angles and
		// draw a straight line for the rest. This might cause inconsistencies with tunnel-shaped setups.
		if( useFocusFades && { focus != false } ) { // disabled when forced unfocused
			globalAngle = pos.angle;
			speakerAngleRange = [ (dist@speakerArray[0]).angle, (dist@speakerArray.last).angle ];
			fadeArea = globalDist.linlin(0.5,1,pi,focusWidth/2,\none).clip(focusWidth/2,pi); 
			focusFades = speakerArray.collect({ |item, i|
				(i.linlin(0,n-1,*speakerAngleRange) - globalAngle).wrap(-pi,pi)
					.abs.linlin(fadeArea, fadeArea + 0.03pi,1,0,\none).clip(0,1); 
			});
			
			if( focus.isNil ) {
				amplitudes = amplitudes * focusFades.max( inFront );
			} {
				amplitudes = amplitudes * focusFades; //always apply for focused
			};
		};
	
		// all together
		
		intType = int ? intType ? 'N';
		
		^this.delay( source, 
			delayTimes + delayOffset, 
			amplitudes,
			add  );
	}
	
}


WFSArrayPanPlane : WFSBasicArrayPan {	
	
	ar { |source, inPos, int, mul = 1, add = 0|
		var delayOffset, angleOffsets, sinA, cosA, dist2;
		
		// rotate point to array, collect angle differences
		pos = (inPos ? pos ? (0@0)).asPolar.rotate( angle.neg );
		
		sinA = pos.theta.sin.neg / speedOfSound;
		cosA = pos.theta.cos;
		dist2 = (cosA * dist) / speedOfSound;
		distances = speakerArray.collect({ |item,i| (sinA * item) - dist2; });
		
		// calculate amplitudes
		amplitudes = 1/n; // normalize sum for fixed average number of speakers
		
		// subtract large delay
		delayOffset = preDelay;
		
		intType = int ? intType ? 'N';
	
		// all together
		^this.delay( 
			source * mul, 
			distances + delayOffset, 
			amplitudes,
			add 
		);
	}
	
}


+ SequenceableCollection {
	asWFSArrayConf { ^WFSArrayConf( *this ) }
}

+ Object {
	asWFSArrayConf { ^WFSArrayConf } // default conf
}