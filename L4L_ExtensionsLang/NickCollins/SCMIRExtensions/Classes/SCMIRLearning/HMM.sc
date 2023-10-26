//Hidden Markov Model (for discrete observation symbols)   
//calls out to external hmm program executable for calculations   
//depends on external saved model file    
  
HMM {   
	classvar <modelcount;    
	var <numstates;    
	var <numsymbols;    
	var <>modelpath; //path to unique HMM data used by this class; automatically in temp directory, but can also be set    
	  
	var <modelnum; 	   
	  
	*initClass {   
		  
		modelcount = 0;    
		  
	}   
	  
	*new {|numstates,numsymbols|   
		  
		//newCopyArgs   
		^super.new.initHMM(numstates,numsymbols); 	   
		  
	}   
	  
	initHMM {|numst,numsym|   
		  
		numstates = numst;   
		numsymbols = numsym;   
		  
		modelnum = modelcount;    
		  
		modelcount = modelcount + 1;     
		  
		modelpath =  SCMIR.tempdir++"hmmmodel"++modelnum;    
		  
	}   
	  
	train {|observations, numiterations=5|   
		  
		var file;   
		  
		if(observations.isArray) {   
			file = SCMIRFile((SCMIR.tempdir++"hmminput"), "wb");   
			  
			file. putInt32LE(observations.size);    
			  
			observations.do {|sequence|    
				  
				file.putInt32LE(sequence.size);    
				  
				sequence.do{|val|    
					  
					file.putInt32LE(val);    
					  
				};   
				  
			};    
			  
			file.close;    
			  
			//invoke program to act on it   
			  
			SCMIR.external(SCMIR.executabledirectory++"hmm"+ 0 + numstates + numsymbols + (SCMIR.tempdir++"hmminput")+modelpath + numiterations); // + "noveltyoutput";     
			  
		};   
		  
	}   
	  
	generate {|length=10|   
		  
		var result, file; 	   
		  
		  
		SCMIR.external(SCMIR.executabledirectory++"hmm"+ 1 + modelpath + length+(SCMIR.tempdir++"hmmoutput"++modelnum)); // + "noveltyoutput";    
		  
		  
		file = SCMIRFile(SCMIR.tempdir++"hmmoutput"++modelnum,"rb");     
		  
		//should be the same, hopefully  
		length = file.getInt32LE();   
		  
		result= List[];   
		  
		length.do {  
			result.add(file.getInt32LE());   
		}; 	  
		  
		file.close;   
		  
		^result;    
	}   
	  
	  
	//viterbi  
	mostprobablestatesequence {|observationsequence|   
		  
		var result, file, length; 	   
		  
		if(observationsequence.isArray) {   
			file = SCMIRFile((SCMIR.tempdir++"hmminput"), "wb");   
			  
			file. putInt32LE(observationsequence.size);    
			  
			observationsequence.do {|val|    
				  
				file.putInt32LE(val);    
				  
			};    
			  
			file.close;    
			  
			//invoke program to act on it   
			  
			SCMIR.external(SCMIR.executabledirectory++"hmm"+ 2 +modelpath + (SCMIR.tempdir++"hmminput") + (SCMIR.tempdir++"hmmoutput"++modelnum)); // + "noveltyoutput";     
			  
			file = SCMIRFile(SCMIR.tempdir++"hmmoutput"++modelnum,"rb");     
			  
			//should be the same, hopefully  
			length = file.getInt32LE();   
			  
			result= List[];   
			  
			length.do {  
				result.add(file.getInt32LE());   
			}; 	  
			  
			  
			file.close;   
			  
		}; 	   
		  
		^result;    
	}   
	  
	  
	 //could convert to take an array of observationsequences and return an array of probabilities
	probability {|observationsequence|   
		  
		var result, file; 	   
		  
		if(observationsequence.isArray) {   
			file = SCMIRFile((SCMIR.tempdir++"hmminput"), "wb");   
			  
			file. putInt32LE(observationsequence.size);    
			  
			observationsequence.do {|val|    
				  
				file.putInt32LE(val);    
				  
			};    
			  
			file.close;    
			  
			//invoke program to act on it   
			  
			SCMIR.external(SCMIR.executabledirectory++"hmm"+ 3 +modelpath + (SCMIR.tempdir++"hmminput") + (SCMIR.tempdir++"hmmoutput"++modelnum));     
			  
			file = SCMIRFile(SCMIR.tempdir++"hmmoutput"++modelnum,"rb");     
			  
			result = file.getDoubleLE();   
				 
			file.close;   
			  
		}; 	   
		  
		^result;    
	}   		 
	  
}   
  
  
  
 
