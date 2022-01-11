WFSArrayPanDir : WFSArrayPan {
	
	ar { |source, inPos, int, direction = 0, sines = #[0,1], sineMul = 1, mul = 1, add = 0| // inPos: Point or Polar
		var difx, dify, sqrdifx, inFront, crossing, delayOffset;
		var globalDist, globalAngle, speakerAngleRange, focusFades, fadeArea;
		var adifx, angles, angleAmplitudes, angleLimit = 1;

		// rotate point to array
		pos = (inPos ? pos ? (0@0)).rotate( angle.neg ).asPoint;
		
		globalDist = pos.dist( 0 @ 0 ); // distance to center
		
		// ------- calculate distances --------
		difx = pos.x - dist; // only once
		dify = pos.y - speakerArray;
		
		distances = ( difx.squared + dify.squared ).sqrt;
		
		// determine focus multiplier (-1 for focused or 1 for normal) 
		inFront = ( ( difx >= 0 ).binaryValue * 2 ) - 1;
		
		// ------- calculate directional amplitudes ------
		adifx = difx.excess(1) + ((difx > 0).binaryValue * 2 - 1 ); // limit distance to 1m
		
		angles = atan2( dify, adifx ).wrap(0.5pi,1.5pi) + (angle - direction);
		
		sines = sines / sines.abs.sum.max(1e-12); // normalize abs sum of sines
		
		angleAmplitudes = angles.collect({ |angle|
			sines[0] + sines[1..].collect({ |sine, i|
				(angle * (i+1) * sineMul).cos * sine;
			}).sum;
		});
		
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
		
		amplitudes = amplitudes * angleAmplitudes;
		
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
