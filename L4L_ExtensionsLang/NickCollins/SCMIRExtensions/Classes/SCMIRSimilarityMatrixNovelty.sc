//create novelty curve using similarity matrix (only for self similarity) 
//Foote method is checkerboard kernel; may need to take account of different separations 
//from 1 to 3 seconds say 
 
+ SCMIRSimilarityMatrix {   
	 
	
	novelty {|kernelsize=10|  
		  
		var file;  
		var temp; 
		var numcols;  //should be exact    
		var noveltycurve;  
		var data; 
		var outputfilename, inputfilename;
		
		data = matrix; 

		if (matrix.isNil){ 
			"SCMIRAudioFile:novelty: no similarity matrix calculated".postln; ^nil 
		}; 
		
		if (reducedcolumns != reducedrows){ 
			"SCMIRAudioFile:novelty: similiarity matrix not square".postln; ^nil 
		};     
			  
		numcols = reducedcolumns; //should be same as reducedrows //matrix.size.sqrt.asInteger;  
		  
		inputfilename = SCMIR.getTempDir ++ "noveltyinput"; 
		outputfilename = SCMIR.getTempDir ++ "noveltyoutput"; 
		  
		file = SCMIRFile(inputfilename,"wb");  
			 
		file.putInt32LE(data.size);  
		file.putInt32LE(numcols);  
			 
		file.writeLE(data);  
			 
		file.close;   
			 
		temp = ((SCMIR.executabledirectory)++"noveltycurve") + kernelsize + inputfilename + outputfilename; //"noveltyinput"+ "noveltyoutput";  
		  
		//unixCmd(temp);   
		//SCMIR.processWait("noveltycurve");  
		
		SCMIR.external(temp); 
		  
		file = SCMIRFile(outputfilename,"rb");   
		  
		noveltycurve= FloatArray.newClear(numcols);      
		  
		//file.readLE(noveltycurve) ; 
	  
			numcols.do{|j|   
				noveltycurve[j] = file.getFloatLE;   
			};
   
		  
		file.close;    
		  
		^noveltycurve;    
		  
		  
	} 
	 
	 	  
} 












