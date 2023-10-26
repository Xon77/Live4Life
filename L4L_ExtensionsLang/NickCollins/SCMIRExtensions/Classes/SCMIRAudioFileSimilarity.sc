+ SCMIRAudioFile {  
	  
	 
	similarityMatrix { |unit=1, metric=0, prepost=0, reductiontype=1, other=nil|
	
		var matrix; 
		var data1, data2; 
		
		if(featuredata.isNil) {"SCMIRAudioFile:similarityMatrix: this file has no feature data".postln;  ^nil };

		
		data1 = featuredata; 
		
		if (unit<1) {"SCMIRAudioFile:similarityMatrix: unit less than 1".postln; ^nil}; 
		
	
				//check if self similarity or comparative
		if(other.notNil) {
			
			if(other.isKindOf(SCMIRAudioFile)==false) {"SCMIRAudioFile:similarityMatrix: other file not an SCMIRAudioFile".postln;  ^nil };
			if(other.featuredata.isNil) {"SCMIRAudioFile:similarityMatrix: other file has no feature data".postln;  ^nil };
 			if(featureinfo!=other.featureinfo) {"SCMIRAudioFile:similarityMatrix: other file different feature info; different features extracted".postln;  ^nil }; //implies then if pass this test that they have the same numfeatures
 
			//if(other.numframes<framesconsidered){framesconsidered = other.numframes;};
			
			data2 = other.featuredata; 			 
			
			matrix = SCMIRSimilarityMatrix(numfeatures, data1, data2); 
				
		} {
		
			matrix = SCMIRSimilarityMatrix(numfeatures, data1);  //self similarity
			
		};	
		
		"Calculating Similarity Matrix".postln;
		
		matrix.calculate(unit,metric,prepost,reductiontype); 
		
		"Calculated Similarity Matrix".postln;
		
		^matrix;
	} 
	  
	  
//	  ///////////////////////////EVERYTHING BELOW HERE OLDER CODE////////////////////////////////////////////
//	  
//	  
//	 //eventual plan:
//	 //metric = 
//	 //0 euclidean
//	 //1 manhattan
//	 //could also compare features themselves, their average, their max, etc
//	  
//	  //later: other can be another SCMIRAudioFile; comparison is over length of shorter, no beat matching for now
//	  
//	  //no other metrics supported, too slow. Actually calculated now via external program 
//	  similarityMatrixSC { |unit=1, other|
//		  
//		var matrix; 
//		var numcols; //square matrix, will be same as numrows
//		var topindex;
//		var topleftover; 
//		var data1, data2; 
//		var framesconsidered; 
//		var precalc, precalc2; 
//		
//		framesconsidered= numframes; 
//		data1= featuredata; 
//		data2= featuredata; 
//		
//		
//		if(featuredata.isNil) {"SCMIRAudioFile:similarityMatrixSC: this file has no feature data".postln;  ^nil };
//
//		//check if self similarity or comparative
//		if(other.notNil, {
//			
//			if(other.isKindOf(SCMIRAudioFile)==false) {"SCMIRAudioFile:similarityMatrixSC: other file not an SCMIRAudioFile".postln;  ^nil };
//			if(other.featuredata.isNil) {"SCMIRAudioFile:similarityMatrixSC: other file has no feature data".postln;  ^nil };
// 			if(featureinfo!=other.featureinfo) {"SCMIRAudioFile:similarityMatrixSC: other file different feature info; different features extracted".postln;  ^nil }; //implies then if pass this test that they have the same numfeatures
// 
//			if(other.numframes<framesconsidered){framesconsidered = other.numframes;};
//			
//			data2 = other.featuredata; 			 
//			
//		}); 
//		 
//		//unit is framesperblock, must be integer
//		
//		unit = unit.asInteger; 
//		
//		if (unit<1) {"SCMIRAudioFile:similaritymatrix: unit less than 1".postln; ^nil}; 
//		
//		if (unit>framesconsidered) {unit=framesconsidered; }; 	  
//		  
//		numcols= framesconsidered.div(unit); //rounds down, miss off any odd bit at the end; 
//		  
//		//numcols = (framesconsidered/unit).roundUp;  
////		topleftover = framesconsidered%unit; 
////		if(topleftover==0,{topleftover= unit}); //in this case, there is no leftover, so last is usual size
////		
//		//matrix = Array.fill(numcols,{Array.fill(numcols,{0.0}); });   
//		matrix = FloatArray.newClear(numcols.squared);     
//		  
//		topindex = numcols-1;
//		
//		precalc = unit*numfeatures;
//		precalc2= (precalc).reciprocal; 
//		
//		//symmetric matrix, calculate half
//		for(0,topindex,{|i| 
//			//var numconsidered1; 
//			var pos1; 
//			var baseindex; 
//			
//			//numconsidered1 = if(i<topindex,unit,topleftover); 
//			
//			pos1 = i*precalc; //if using other, numfeatures is same here
//			baseindex= i*numcols;  
//			 
//		for(i,topindex,{|j|
//			//var numconsidered2;
//			var pos2;
//			var similarity = 0.0; 
//			//var considerinsum; 
//			
//			//numconsidered2 = if(j<topindex,unit,topleftover); 
//			
//			pos2 = j*precalc; 
//			
//			//considerinsum = min(numconsidered1,numconsidered2); //other terms would be zero anyway
//			
//			//now actually work out similarity as Manhattan distance (cheapest for now) 
//			//features already normalized between 0.0 to 1.0
//			precalc.do{|k|
//			
//				similarity = similarity + (abs(data1[pos1+k] - data2[pos2+k]));  
//					
//			};
//			
//			similarity = similarity*precalc2; 
//			
//			//matrix[i][j] = similarity;
//			//symmetric filling in
//			//matrix[j][i] = similarity; 
//			
//			matrix[baseindex+j]= similarity; 
//			matrix[(j*numcols)+i]= similarity; 
//			
//			
//		});    
//		
//		}); 
//		  
//		^matrix;   
//	  }
//	  
//	 
//
//
//	
//	  
//	 //call external program to calculate matrix; assumed this call comes within a Routine 
//	 similarityMatrixOld { |unit=1, metric=2, prepost=0, reductiontype=1, other=nil|
//		  
//		var matrix; 
//		var numcols; //square matrix, will be same as numrows
//		var topindex;
//		var topleftover; 
//		var data1, data2; 
//		var framesconsidered; 
//		var precalc, precalc2; 
//		var file; 
//		var temp; 
//		
//		framesconsidered= numframes; 
//		data1= featuredata; 
//		data2= featuredata; 
//		
//		
//		if(featuredata.isNil) {"SCMIRAudioFile:similarityMatrix: this file has no feature data".postln;  ^nil };
//
//		//check if self similarity or comparative
//		if(other.notNil, {
//			
//			if(other.isKindOf(SCMIRAudioFile)==false) {"SCMIRAudioFile:similarityMatrix: other file not an SCMIRAudioFile".postln;  ^nil };
//			if(other.featuredata.isNil) {"SCMIRAudioFile:similarityMatrix: other file has no feature data".postln;  ^nil };
// 			if(featureinfo!=other.featureinfo) {"SCMIRAudioFile:similarityMatrix: other file different feature info; different features extracted".postln;  ^nil }; //implies then if pass this test that they have the same numfeatures
// 
//			if(other.numframes<framesconsidered){framesconsidered = other.numframes;};
//			
//			data2 = other.featuredata; 			 
//			
//		}); 
//		 
//		//unit is framesperblock, must be integer
//		
//		unit = unit.asInteger; 
//		
//		if (unit<1) {"SCMIRAudioFile:similarityMatrix: unit less than 1".postln; ^nil}; 
//		
//		if (unit>framesconsidered) {unit=framesconsidered; }; 	  
//		  
//		numcols= framesconsidered.div(unit); //rounds down, miss off any odd bit at the end; 
//				
//		//write out binary file with first data
//		file = File("similaritymatrixinput1","wb"); 
//		
//		file.putInt32LE(framesconsidered); 
//		file.putInt32LE(numfeatures); 
//		
//		file.writeLE(data1); 
//		
////		framesconsidered.do{|i| 
////			var pos = i*numfeatures; 
////			
////			numfeatures.do{|j| file.putFloatLE(data1[pos+j])}; 
////			
////			}; 
//		
//		file.close; 
//		
//		//if second file, write out further file
//		if(other.notNil) {
//		
//		file = File("similaritymatrixinput2","wb"); 
//		
//		file.putInt32LE(framesconsidered); 
//		file.putInt32LE(numfeatures); 
//		
//		file.writeLE(data2); 
//		
////		framesconsidered.do{|i| 
////			var pos = i*numfeatures; 
////			
////			numfeatures.do{|j| file.putFloatLE(data2[pos+j])}; 
////			
////			}; 
//		
//		file.close; 	
//			
//			
//		};
//		
//		//call auxilliary program
//			 
//	 //"/data/sussex/code/SC/sclangextensions/similaritymatrix/build/Debug/similaritymatrix"
//	 //similaritymatrix metric unit combinationtype outputfilename inputfile1 [inputfile2]
//
//		//temp = "/data/sussex/code/SC/sclangextensions/similaritymatrix/build/Debug/"
//		temp = SCMIR.executabledirectory++"similaritymatrix" + metric + unit + prepost + reductiontype + "similaritymatrixoutput"+ "similaritymatrixinput1"; 
//
//		if(other.notNil) {
//			temp = temp + "similaritymatrixinput2"; 
//		};
//		
//		temp.postln;
//				 
//		unixCmd(temp);  
//		  
////	  	limit=2000;		     
////		 
////		0.01.wait; //make sure scsynth running first (can be zero but better safe than sorry)     
//	//	while({     
////			a="ps -xc | grep 'similaritymatrix'".systemCmd; //256 if not running, 0 if running     
////			  
////			if(limit%10==0,{a.postln});     
////			  
////			(a==0) and: {(limit = limit - 1) > 0}     
////			},{     
////			0.1.wait;	     
////		});     
//
//		SCMIR.processWait("similaritymatrix"); 
//	  
//		//matrix = FloatArray.fill(numcols,{Array.fill(numcols,{0.0}); }); 
//		//read result back in
//		file = File("similaritymatrixoutput","rb");  
//		    
//		temp = numcols*numcols;  
//		matrix= FloatArray.newClear(temp);     
//		  
//		  
//		file.readLE(matrix) ;
//		  
////		numframes.do{|i|  
////			  
////			numframes.do{|j|   
////				matrix[i][j] = file.getFloatLE;   
////			}
////		};  
//		  
//		file.close;   
//		
//		  
//		^matrix;   
//	  }
	  
	  
}