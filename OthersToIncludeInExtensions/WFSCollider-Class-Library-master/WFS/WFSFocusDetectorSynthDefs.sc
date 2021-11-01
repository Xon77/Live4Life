WFSFocusDetectorSynthDefs : AbstractWFSSynthDefs {
	
	classvar <>minArrays = 4, <>maxArrays = 24; 
	
	*prefix { ^"wfsfd" }
	
	*getDefName { |numArrays = 4|
		
		// example: "wfsf_8" : focus detection def for 8 arrays
		
		^[ this.prefix, numArrays ].join("_");
	}
	
	*generateDef { |numArrays = 4|
		
		^SynthDef( this.getDefName( numArrays ), {
			
			// synth args:
			var point = 0@0, pointFromBus = 0;	
			var pointLag = 0;
			var outBus = 1999;
			
			// output:
			var output;
			
			pointFromBus = \pointFromBus.kr( pointFromBus );
			point = (\point.kr( point.asArray ) * (1-pointFromBus)) 
					+ ( UIn.kr(0,2) * pointFromBus );
			pointLag = \pointLag.kr( pointLag );
			point = LPFLag.kr( point, pointLag );
			point = point.asPoint;
			
			outBus = \outBus.kr(1999);
			
			output = WFSFocusDetector.basicNew( 
				\cornerPoints.ir( 0!(numArrays*2) ).clump(2).collect(_.asPoint),
				\vectors.ir( 0!(numArrays*2) ).clump(2).collect(_.asPoint),
				numArrays
			).kr( point );
			
			ReplaceOut.kr( outBus, output );
			
		});
	}
	
	*generateAll { |action, dir|
		dir = dir ? SynthDef.synthDefDir;
		synthDefs = (minArrays..maxArrays).collect({ |numArrays|
			this.generateDef( numArrays );
		});
		action.value(this);
		^synthDefs;		
	}
	
}