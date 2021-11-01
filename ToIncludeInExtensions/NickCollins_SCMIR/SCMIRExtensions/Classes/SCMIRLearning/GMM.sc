//Gaussian mixture model
//calls out to external gmm program executable for calculations

GMM {
	//classvar <executablepath; 
	//classvar <defaulttemp; 
	classvar <modelcount; 
	var <numstates; 
	var <numfeatures; 
	var <>modelpath; //path to unique Gaussian model data used by this class; automatically in temp directory, but can be set 
	var <modelnum; 
	var <modelloaded;
	//if loaded model, can calculate within sclang
	//covarA is covar matrix's 'square root' A such that AAtranspose = covar
	var <stateprobs, <meanvectors, <covarmatrices, <covarmatrixinverses, <covarmatrixdeterminants, <covarA; 
	
	*initClass {
		
		modelcount = 0; 
		
		//executablepath = GMM.filenameSymbol.asString.dirname.escapeChar($ )++"/gmm"; 
		
		//defaulttemp = "/tmp"; 
	}
	
	*new {|numstates,numfeatures|
		
		^super.new.initGMM(numstates,numfeatures); 	
		
	}
	
	//newFromModel?
	

	initGMM {|numst,numf|
		
		numstates = numst;
		
		numfeatures = numf;  
		 
		modelnum = modelcount; 
		
		modelcount = modelcount + 1;  
		 
		modelpath =  SCMIR.tempdir++"gmmmodel"++modelnum; 
		 
		modelloaded = false;  
	}
	
	train {|data|
		var file; 
		
		file = File((SCMIR.tempdir++"gmminput"), "w"); //was "wb", should just be ascii, so no need for SCMIRFile
	
		numfeatures = data[0].size; 
	
		data.do{|row|
			
			(row.size-1).do{|i|
			
				file.write((row[i].asString)++" "); 	
			};
			
			file.write((row.last.asString)++"\n");
		};
	
		file.close; 
		
		//invoke program to act on it
		
		SCMIR.external(SCMIR.executabledirectory++"gmm"+ 0 + numstates + (SCMIR.tempdir++"gmminput")+modelpath); // + "noveltyoutput";  
		 
		
	}
	
	
	//requires MathLib quark
	loadModel {
		var data; 
		var indexbase = 0; 
		
		data = FileReader.read(modelpath, skipBlanks:true);
		
		//remove end of line " " entries
		data = data.collect{|array| array.copyRange(0,array.size-2)}; 

		numfeatures = data[0][0].asInteger;  
		
		numstates = data[0][1].asInteger; 
		
		stateprobs = data[1].asFloat; 
		
		meanvectors = nil!numstates;
		covarmatrices = {Matrix.newClear(numfeatures,numfeatures)}!numstates;
		covarmatrixinverses = {Matrix.newClear(numfeatures,numfeatures)}!numstates;
		covarmatrixdeterminants = 0!numstates; //assume singular until proven otherwise...
		covarA = {Matrix.newClear(numfeatures,numfeatures)}!numstates; 
		
		numstates.do {|i|
			
			meanvectors[i] = data[2+i].asFloat; 		
		}; 
		
		numstates.do {|i|
			var matrixnow = covarmatrices[i];
			
			indexbase = 2+numstates+(i*numfeatures); 
			
			//was output from C program as one column per line
			
			numfeatures.do {|j| 
				var array; 
				
				matrixnow.putCol(j,data[indexbase+j].asFloat); 
				
			}; 
			
		}; 
		
		indexbase = 2+numstates+(numstates*numfeatures);
		
		numstates.do {|i|
			var matrixnow = covarmatrixinverses[i];
			var test;
			 
			//[i,indexbase].postln;
			
			test = data[indexbase][0].asInteger; 
			
			
			if(test ==1) {
				
			//data[indexbase].postln;	
				
			covarmatrixdeterminants	[i] = (data[indexbase][1]).asFloat;
			
			indexbase = indexbase + 1; 
				
			numfeatures.do {|j| 
				var array; 
		
				//data[indexbase+j].asFloat.postln;
				matrixnow.putCol(j,data[indexbase+j].asFloat); 
			}; 
			
			indexbase = indexbase + numfeatures; 
			} {
				
			indexbase = indexbase + 1; 
				
			};
			
		}; 
		
		//[\indexbasenow,indexbase, \check, 2+numstates+(numstates*numfeatures) + (numstates*(1+numfeatures))].postln;
		
		
		numstates.do {|i|
			var matrixnow = covarA[i];

			//was output from C program as one column per line
			
			numfeatures.do {|j| 
				var array; 
				
				//[\state, i, \column, j, \data, data[indexbase+j].asFloat].postln; 
				
				matrixnow.putCol(j,data[indexbase+j].asFloat); 
				
			}; 
			indexbase = indexbase + numfeatures; 
		}; 
		
		
		
		modelloaded = true; 
		
	}
	
	
	//draw from the GMM distribution, see
	//http://en.wikipedia.org/wiki/Multivariate_normal_distribution#Drawing_values_from_the_distribution
	//assumes covarA and meanvectors exist
	//requires Matrix class from MathLib
	generate {
	
		var randomvector = Matrix.withFlatArray(numfeatures,1,{gauss(0.0,1.0)}!numfeatures); 
		var whichstate = (0..(numstates-1)).wchoose(stateprobs); 
		var a = covarA[whichstate]; 
		
		^meanvectors[whichstate] +  ((a*randomvector).getCol(0));
		
	}
	
	//input vector; find best matching state
	test {|input, outputscore=false|
		
			var file; 
			var result, probs; 
			var bestscore= 0.0; 
			
			if(input.size!= numfeatures) {
			
			("GMM:test input vector not same number of dimensions as model; GMM expects "++numfeatures).postln;
			
			^nil; 	
			};
		
		//do calculation locally in SC if have matrix data of model, else farm out to C program
		if (modelloaded) {
		
		numstates.do{|i|
			var scorenow=0.0; 
			var diff; 
			
			//if non-singular, if has inverse...
			if (covarmatrixdeterminants[i]!=0) {
		
			diff = input - meanvectors[i]; 
			
			diff = Matrix.withFlatArray(numfeatures,1,diff); 
			
			scorenow = covarmatrixinverses[i]*diff; 
			
			scorenow = ((diff.flop)*scorenow).at(0,0); 

			//if numerical issues, convert to work with log of this quantity, mins start at -inf
			scorenow = exp(-0.5*scorenow)/sqrt((2pi**numfeatures)*(covarmatrixdeterminants[i].abs));
		
			if(scorenow < 1e-40) {scorenow = 1e-40};
		
			if (scorenow >bestscore) {
				
			bestscore = scorenow; 
			//[i,bestscore].postln;
			result = i; 
				
			}
			
			}
			
		};
		
		if(outputscore) {
			^[result, bestscore]; 	
		}
		
		
		} {
			file = SCMIRFile((SCMIR.tempdir++"gmmtest"), "wb");
	
			file.writeLE(FloatArray.newFrom(input));  
	
			file.close; 
		
		//invoke program to act on it
		
		SCMIR.external(SCMIR.executabledirectory++"gmm"+ 1 + modelpath + (SCMIR.tempdir++"gmmtest")+(SCMIR.tempdir++"gmmoutput")); // + "noveltyoutput";  
		
			file = SCMIRFile(SCMIR.tempdir++"gmmoutput","rb");   
		 
		 result = file.getInt32LE();  	
		  
	//	probs= FloatArray.newClear(numstates);      
//		  
//			numstates.do{|j|   
//				noveltycurve[j] = file.getFloatLE;   
//			};
//   
//		  
		file.close;    
		}
		 
		^result; 
	}

	
	
}