//critically depends on SCMIR
//assumes run within a fork as needed

SCMIRMusicPredictor {
	var <name; 
	var <corpus; 
	//var <normdata; 
	
	//timbre part via beat locked timbre features
	var <timbrefeatures; 
	var <timbrekmeans; 
	var <timbremarkovmodel; 	
	
	//rhythms part via IOIs from onset detection
	
	var <ioihistogrambounds; 
	var <npviref, <corpusnpvis; 
	var <corpustempi; 
	var <ioippmmodel; 
	//var <beatppmmodel;
	
	//pitch part via beat locked chroma features
	var <pitchfeatures; 
	var <chromadiffhistogrambounds; 
	var <chromadiffppmmodel; 
	
	//var <debugdata;
	var <directory; //calculated from name
	var <filestart; 
	var <filedur; 
	
	var <normdir; 
	
	classvar <>basedirectory;
	classvar <>normsdirectory;  
	
	*initClass {
		
		basedirectory = "/data/sussex/projects/mir/influenceprediction/"; 
		
		normsdirectory = "/data/sussex/projects/mir/influenceprediction/Global/";
	}
	
	
	*new {|name, corpus, start=0, dur=0, normd|
		
		name = name ? ""; 
		
		^super.new.initSCMIRMusicPredictor(name,corpus, start, dur, normd);	
	}
	
	setFileParams {|fstart=0.0, dur=0|
		
		filestart = fstart; 
		filedur = dur; 
		
	}
	
	//expert use
	swapCorpus {|newcorpus| 
		
		corpus = newcorpus; //so can partially use existing models on new training target 
	}
	
	changeName {|newname, normd|
		
		name = newname; 
		
		if(name.size>0) {
		directory = basedirectory++name++"/"; 
		} {
		directory = basedirectory; 
		}; 
		
		
		if(pathMatch(directory).size==0) {
			
			//create directory 
			SCMIR.external("mkdir "++(directory.asUnixPath))

		};
		
		normdir = if(normd.notNil) {directory} {SCMIRMusicPredictor.normsdirectory};
		
	}
	
	
	initSCMIRMusicPredictor {|nm,corp,st,dr,normd|
		
		//name = nm; 
		
		corpus = corp; 
		
		filestart = st.max(0.0).min(1.0);
		filedur = dr;  
		
		timbrefeatures = [\Loudness,\Transient,[\Transient,0.7,0.2],\SensoryDissonance,\SpecCentroid,[\SpecPcile,0.8],[\SpecPcile,0.95],\ZCR, \FFTCrest, \FFTSlope,[\Onsets,\rcomplex]];
		
		
		pitchfeatures = [[Chromagram,12]];	
		
		this.changeName(nm, normd); 
				
	}
	
	
	prepare {|calcnorms=false|
		
		if(calcnorms) {
		"preparing normalization over corpus".postln;
		
		this.prepareNorms; 
		}; 
		
		"preparing models".postln;
		
		this.prepareModels; 
		
	}
	
	
	//always into predictor home directory rather than any danger of overwriting of Global norms
	prepareNorms {
		
	SCMIR.findGlobalFeatureNorms(corpus,timbrefeatures,0,filestart,filedur); 
				
	//"/data/sussex/projects/algorithmiccomposition/"++(name)			
	SCMIR.saveGlobalFeatureNorms(directory++"timbrefeaturenorms.scmirZ"); 

	//SCMIR.globalfeaturenorms 
	
			
	SCMIR.findGlobalFeatureNorms(corpus,pitchfeatures,0, filestart,filedur); 
				
	SCMIR.saveGlobalFeatureNorms(directory++"pitchfeaturenorms.scmirZ"); 

	
		
	}
	
	
	
	
	prepareModels {|timbrestates=20, timbremodelorder =5, rhythmstates=20, rhythmmodelorder=5, pitchstates= 20, pitchmodelorder=5 newclasses=true|
	
		this.prepareTimbreModel(timbrestates,timbremodelorder,newclasses); 
		
		//no rhythmic attributes in this work? save for jury work 
		this.prepareRhythmModel(rhythmstates,rhythmmodelorder,newclasses); 
		
		this.preparePitchModel(pitchstates,pitchmodelorder,newclasses);
	} 
	
	
	
	
	prepareTimbreModel {|numstates= 20 modelorder = 5 newclasses=true|

		var data = List[]; 
		var numtimbrefeatures = timbrefeatures.size; 
		
		SCMIR.loadGlobalFeatureNorms(normdir++"timbrefeaturenorms.scmirZ"); 
	
		corpus.do {|filename|
			
			var g; 
			
			filename.postcs; 
			
			g = SCMIRAudioFile(filename,timbrefeatures, start:filestart,dur:filedur);
		
			//uses global normalization 
			g.extractFeatures(true, true); 
			g.extractBeats();
			
			g.gatherFeaturesByBeats; 
			
			data.add(g.featuredata); 
			
		}; 


		if(newclasses) {
		timbrekmeans = KMeans(numstates); 
		
		
		//~data = Array.newFrom(~a); 

		data.do{|array| 
			
		(array.size.div(numtimbrefeatures)).do {|j|
		var indexnow = j*numtimbrefeatures; 
		
		timbrekmeans.add(array.copyRange(indexnow,indexnow+numtimbrefeatures-1)); 
		
		}; 	
		
		}; 
	
		timbrekmeans.update; //MUST CALL!!!!!!!!!!!!!!!!!!!!
	
		timbrekmeans.reset.update; //to avoid initialisation by first few
		
		}; 
	
	
		timbremarkovmodel = PPMC(modelorder); //MarkovModel(numstates,modelorder); 	//num states, order (last order states predict next)
		
		
		//timbremarkovmodel = MarkovModel(numstates,3); 
		
	
		//debugdata = List[]; 
	
		data.do{|array| 
			
			var classes; 
			
			classes = Array.fill(array.size.div(numtimbrefeatures),{|j|
		var indexnow = j*numtimbrefeatures; 
		//var class; 
		
		//class = 
		
		timbrekmeans.classify(array.copyRange(indexnow,indexnow+numtimbrefeatures-1)); 
		
		//if(class.isNil){
//			"ERROR class was nil!".postln;
//			
//			array.copyRange(indexnow,indexnow+numtimbrefeatures-1).postln;
//			
//			}; 
		
		//class; 
		}); 	 
		//= array.collect{|val| timbrekmeans.classify(val)}; 
			
		timbremarkovmodel.train(classes); //(, false); 
		
		//debugdata.add(classes); 
		
		};
	
		//only needed if MarkovModel; actually, defaults to sorting out above
		//timbremarkovmodel.calculateProbabilities; 
	}
	


	timbreScore {|filename|
		var score = 0.0; 
		var g; 
		var classes;
		var numtimbrefeatures = timbrefeatures.size; 
		
		
SCMIR.loadGlobalFeatureNorms(normdir++"timbrefeaturenorms.scmirZ"); 
	

		
		g = SCMIRAudioFile(filename,timbrefeatures, start:filestart,dur:filedur);



	//uses global normalization 
	g.extractFeatures(true, true); 
	g.extractBeats();
	
	g.gatherFeaturesByBeats; 
	
	//g.numfeatures.postln;
	//g.numframes.postln;
		
		classes = Array.fill(g.featuredata.size.div(numtimbrefeatures),{|j|
		var indexnow = j*numtimbrefeatures; 
		
		timbrekmeans.classify(g.featuredata.copyRange(indexnow,indexnow+numtimbrefeatures-1)); 
		
		}); 	 

		^timbremarkovmodel.averagelogloss(classes)
		
		//^classes; 
	}
	
	
	
	//up to three components: nPVI, IOI model, beats model
	//uses PPM-C
	prepareRhythmModel {|numrhythmclasses=20 modelorder = 5 newclasses=true|

		var numonsets,onsetdata;
		//var numbeats,beatdata; 
		var alliois = List[]; 
		var npvisum = 0.0; 
		var temp, temp2; 
		
		
		corpusnpvis = 0.0!(corpus.size); 
		corpustempi = 1.0!(corpus.size); 
		
		//SCMIR.loadGlobalFeatureNorms("/data/sussex/projects/algorithmiccomposition/"++(name)++"timbrefeaturenorms.scmirZ"); 
	
		corpus.do {|filename, j|
			
			var f; 
			var npvi; 
			var iois; 
			
			f = SCMIRAudioFile(filename,start:filestart,dur:filedur);
			f.extractOnsets();
			//f.extractBeats(); //for quantisation
			
			numonsets = f.numonsets; 
			onsetdata = f.onsetdata;
			//numbeats = f.numbeats; 
			//beatdata = f.beatdata; 
			
			//nPVI
			iois =  Array.fill(numonsets-1,{|i| onsetdata[i+1] - onsetdata[i]; }); 

			//don't add any if none to add, since larger corpus
			//if(iois.size<1) {iois = [filedur]}; 

			npvi = Array.fill(numonsets-2,{|i| 
				var d1= iois[i+1]; var d2 = iois[i];  
				
				((d1-d2).abs)/(d1+d2);   //no point in additional *0.5 for denominator since constant throughout
				
				});    

			npvi = (npvi.sum)/(numonsets-2);
			
			corpusnpvis[j] = npvi; 
			
			npvisum = npvisum + npvi; 
	
			alliois.add(iois); 
			
			corpustempi[j] = f.tempo; 
			
		}; 

		npviref = npvisum/(corpus.size); //corpusnpvis.mean
		//crude; need to fit Gaussian to npvi data and measure probability of seeing given npvi
		//on other hand, mean here is at mean of any single fitted Gaussian
		
		
		temp = alliois.flatten.sort; 
		
		temp2 = temp.size; 
		
		//ten histogram bins
		
		temp2= temp2.div(numrhythmclasses); 
		
		
		if(newclasses) {
		//last category of 10 is anything greater than 9th, else less than
		ioihistogrambounds = Array.fill(numrhythmclasses-1,{|i|  temp[temp2*(i+1)] }); 
		}; 
		
		temp = alliois.collect{|iois|  iois.collect{|ioi| this.classifyIOI(ioi); } }; 
			
		//PPM-C over IOIs
			
		ioippmmodel = PPMC(modelorder);
		
		temp.do{|ioiclasslist| ioippmmodel.train(ioiclasslist);};
		 
		//ioippmmodel = MarkovModel(numrhythmclasses,3);
//		 
//		temp.do{|ioiclasslist| ioippmmodel.train(ioiclasslist,false);};
//		
//		ioippmmodel.calculateProbabilities; 
//		
		//ioippmmodel
			
		//PPM-C over IBIs? No, over IOIs quantised into beats
			
	}
	
	classifyIOI {|ioi|
		
		var index=0; 
		
		if(ioi>=(ioihistogrambounds.last)) {
			
			index = ioihistogrambounds.size; 
		} {
		
			block {|break| 
				
			ioihistogrambounds.do {|border,i|
				
				if(ioi<border) {
				
				index = i; 
				
				break.(); 
					
				}
				
			}
			
			}; 
			
		};
		
		
		^index; 
		
	}
	
	
	
	rhythmScore {|filename|
	
		var numonsets,onsetdata;
		//var numbeats,beatdata; 
		var iois; 
		var npvi; 
		var temp; 
		var f; 
		
		f = SCMIRAudioFile(filename,start:filestart,dur:filedur);
		f.extractOnsets();
		//f.extractBeats(); //for quantisation NOT USED!
		
		numonsets = f.numonsets; 
		onsetdata = f.onsetdata;
		//numbeats = f.numbeats; 
		//beatdata = f.beatdata; 
		
		[\numonsets,numonsets].postln;
		
		//nPVI
		iois =  Array.fill(numonsets-1,{|i| onsetdata[i+1] - onsetdata[i]; }); 

		if(iois.size<1) {iois = [filedur]}; 

		npvi = Array.fill(numonsets-2,{|i| 
			var d1= iois[i+1]; var d2 = iois[i];  
			
			((d1-d2).abs)/(d1+d2);   //no point in additional *0.5 for denominator since constant throughout
			
			});    

		npvi = (npvi.sum)/(numonsets-2);


		//PPM-C over IOIs
		temp = iois.collect{|ioi| this.classifyIOI(ioi); }; 
		
		//"double check iois!".postln;
//		
//		iois.postln;
//		
//		"histogram bounds".postln;
//		ioihistogrambounds.postln;
//		
//		temp.postln; 
		
		temp = ioippmmodel.averagelogloss(temp); 
		//temp = ioippmmodel.logloss(temp); 
		//PPM-C over beats	
		
		
		^[(npvi-npviref).abs, temp]; 
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	preparePitchModel {|numclasses=20 modelorder = 5 newclasses=true|
 
		var data = List[];  
		var temp, temp2; 
		
		SCMIR.loadGlobalFeatureNorms(normdir++"pitchfeaturenorms.scmirZ"); 
	
		corpus.do {|filename, j|
			
			var f; 
			var npvi; 
			var iois; 
			
			f = SCMIRAudioFile(filename,pitchfeatures,start:filestart,dur:filedur);
			f.extractFeatures(true,true);
			f.extractBeats(); 
			
			f.gatherFeaturesByBeats; 
			
			f.differentiateFeature(0,1); //absolute differences

			f.sumMultiFeature(0);

			data.add(f.featuredata); 
						
		}; 
		
		temp = data.flatten.sort; 
		
		temp2 = temp.size; 

		temp2= temp2.div(numclasses); 
		
		if(newclasses) {
		chromadiffhistogrambounds = Array.fill(numclasses-1,{|i|  temp[temp2*(i+1)] }); 
		}; 
		
		temp = data.collect{|diffs|  diffs.collect{|diff| this.classifyChromaDiff(diff); } }; 
			
		//PPM-C over IOIs
			
		chromadiffppmmodel = PPMC(modelorder);
		
		temp.do{|chromadiffclasslist| chromadiffppmmodel.train(chromadiffclasslist); }; 
		
		
	//	 chromadiffppmmodel = MarkovModel(numclasses,3);
//		 temp.do{|chromadiffclasslist| chromadiffppmmodel.train(chromadiffclasslist,false); }; 
//
//		chromadiffppmmodel.calculateProbabilities; 
//		
		
			
	}

	
	
	
	classifyChromaDiff {|diff|
		
		var index=0; 
		
		if(diff>=(chromadiffhistogrambounds.last)) {
			
			index = chromadiffhistogrambounds.size; 
		} {
		
			block {|break| 
				
			chromadiffhistogrambounds.do {|border,i|
				
				if(diff<border) {
				
				index = i; 
				
				break.(); 
					
				}
				
			}
			
			}; 
			
		};
		
		
		^index; 
		
	}
	
	
	
	
	pitchScore {|filename|

		var temp; 
		var f; 
		
		SCMIR.loadGlobalFeatureNorms(normdir++"pitchfeaturenorms.scmirZ"); 
	
		f = SCMIRAudioFile(filename,pitchfeatures,start:filestart,dur:filedur);
		f.extractFeatures(true,true);
		f.extractBeats(); 
		
		f.gatherFeaturesByBeats; 
		
		f.differentiateFeature(0,1); //absolute differences

		f.sumMultiFeature(0);

		//PPM-C over IOIs
		temp = f.featuredata.collect{|diff| this.classifyChromaDiff(diff); }; 
		temp = chromadiffppmmodel.averagelogloss(temp); 
		
		//PPM-C over beats	
		
		^temp; 
		
	}
	

	
	
	
	testPiece {|filename|	
		var timbrescore,rhythmscore,pitchscore;
		
		"testing timbre".postln;
		timbrescore= this.timbreScore(filename); 
		
		"testing rhythm".postln;
		rhythmscore= this.rhythmScore(filename); 
		
		"testing pitch".postln;
		pitchscore= this.pitchScore(filename); 

		^[timbrescore, rhythmscore[0], rhythmscore[1], pitchscore]; 
	
	}
	
	
	
	save {|filename|
		
		var a; 
		
		filename = filename ?? {directory++"critic.scmirZ"}; 
		
		a = SCMIRZArchive.write(filename);      
		  
		a.writeItem(name);    
		a.writeItem(corpus);      
		

		//a.writeItem(normdata);  
		a.writeItem(timbrefeatures);  
		
		//KMeans save/load added as class extension 
		timbrekmeans.save(directory++"timbrekmeans.scmirZ");
			
		timbremarkovmodel.save(directory++"timbremarkovmodel.scmirZ"); 		
		
		a.writeItem(ioihistogrambounds);
		a.writeItem(npviref);
		a.writeItem(corpusnpvis);
		a.writeItem(corpustempi);
		
		ioippmmodel.save(directory++"ioippmmodel.scmirZ"); 
		
		a.writeItem(pitchfeatures);
		a.writeItem(chromadiffhistogrambounds);
		
		chromadiffppmmodel.save(directory++"chromadiffppmmodel.scmirZ"); 
		
		a.writeItem(filestart); 
		a.writeItem(filedur); 
		
		a.writeItem(normdir); 
		  
		a.writeClose;  		      		
		
	}
	
	load {|filename|
		
		var a;       
		  
		filename = filename ?? {directory++"critic.scmirZ"};        
		  
		a = SCMIRZArchive.read(filename);      
		  
		name = a.readItem;     
		
		directory = PathName(filename).pathOnly; //basedirectory++name++"/";
		  
		corpus = a.readItem;       
		
		"loading timbre model".postln;
		
		timbrefeatures = a.readItem;   
		
		timbrekmeans = KMeans(1); 
		timbrekmeans.load(directory++"timbrekmeans.scmirZ");
		
		timbremarkovmodel = PPMC(1); 
		timbremarkovmodel.load(directory++"timbremarkovmodel.scmirZ");
		
		"loading rhythm model".postln;
		
		ioihistogrambounds = a.readItem;   
		npviref = a.readItem; 
		corpusnpvis = a.readItem; 
		corpustempi = a.readItem; 
		
		ioippmmodel= PPMC(1); 
		ioippmmodel.load(directory++"ioippmmodel.scmirZ");
		
		"loading pitch model".postln;
		
		pitchfeatures = a.readItem; 
		chromadiffhistogrambounds = a.readItem; 
		
		chromadiffppmmodel= PPMC(1); 
		chromadiffppmmodel.load(directory++"chromadiffppmmodel.scmirZ");
		 
		 
		filestart = a.readItem; 
		filedur = a.readItem; 	 
		 
		normdir = a.readItem;  
		 
		a.close;      

	}
	
	
	
}