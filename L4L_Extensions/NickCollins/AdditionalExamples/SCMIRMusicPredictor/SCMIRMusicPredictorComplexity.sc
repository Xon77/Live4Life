//required in order to assess how difficult particular sequences are to predict, to counteract 
//simple things getting high average logloss

+ SCMIRMusicPredictor {
	
	//don't apply probabilitic model, extract token sequences and assess LZW compression 
	//via RedSys Quark for RedLZW
	
	complexity {|filename| 
		
		var score = 0.0; 
		var g,f; 
		var classes;
		var numtimbrefeatures = timbrefeatures.size; 
		var outputcomplexity = 0!3; 
		var temp, temp2; 
		var numonsets,onsetdata;
		var iois; 
		
		SCMIR.loadGlobalFeatureNorms(normdir++"timbrefeaturenorms.scmirZ"); 
	
		g = SCMIRAudioFile(filename,timbrefeatures, start:filestart,dur:filedur);

		//uses global normalization 
		g.extractFeatures(true, true); 
		g.extractBeats();
		
		g.gatherFeaturesByBeats; 

		classes = Array.fill(g.featuredata.size.div(numtimbrefeatures),{|j|
		var indexnow = j*numtimbrefeatures; 
		
		timbrekmeans.classify(g.featuredata.copyRange(indexnow,indexnow+numtimbrefeatures-1)); 
		
		}); 	 
		
		temp2= RedLZW.compress(classes);
		//what is compression reduction?
		outputcomplexity[0] = temp2.size/classes.size;

		f = SCMIRAudioFile(filename,start:filestart,dur:filedur);
		f.extractOnsets();
		
		numonsets = f.numonsets; 
		onsetdata = f.onsetdata;
	
		//nPVI
		iois =  Array.fill(numonsets-1,{|i| onsetdata[i+1] - onsetdata[i]; }); 

		if(iois.size<1) {iois = [filedur]}; 

		//PPM-C over IOIs
		classes = iois.collect{|ioi| this.classifyIOI(ioi); }; 
		
		temp2= RedLZW.compress(classes);	
		
		outputcomplexity[1] = temp2.size/classes.size;

		SCMIR.loadGlobalFeatureNorms(normdir++"pitchfeaturenorms.scmirZ"); 
	
		f = SCMIRAudioFile(filename,pitchfeatures,start:filestart,dur:filedur);
		f.extractFeatures(true,true);
		f.extractBeats(); 
		f.gatherFeaturesByBeats; 
		f.differentiateFeature(0,1); //absolute difference
		f.sumMultiFeature(0);

		classes = f.featuredata.collect{|diff| this.classifyChromaDiff(diff); }; 
		
		temp2= RedLZW.compress(classes);	
		
		outputcomplexity[2] = temp2.size/classes.size;

		^outputcomplexity; 
	}
	
	
	
	
}