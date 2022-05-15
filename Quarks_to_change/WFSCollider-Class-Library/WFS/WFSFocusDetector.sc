WFSFocusDetector {
	
	var <>cornerPoints;
	var <>vectors;
	var <>size;
	var <>bypass = false;
	
	*new { |cornerPoints|
		^super.newCopyArgs( cornerPoints ).init;
	}
	
	*basicNew { |cornerPoints, vectors, size|
		^super.newCopyArgs( cornerPoints, vectors, size );
	}
	
	== { |that| // use === for identity
		^this.compareObject(that);
	}
	
	init {
		size = cornerPoints.size;
		if( size < 3 ) { 
			bypass = true 
		} {
			vectors = size.collect({ |i| 
				cornerPoints[i] - cornerPoints[(i-1).wrap(0,size-1)] 
			});
		};
	}
	
	kr { |point = (0@0)|
		if( bypass ) { ^1 } {
			^(vectors.collect({ |v,i| 
				(
					(v.x * (point.y - cornerPoints[i].y)) - (v.y * (point.x - cornerPoints[i].x))
				).sign 
			}).sum.abs >= size).binaryValue;
		};
	}
}