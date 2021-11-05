//SCMIRAudioFile beat tracking  
 
+  SCMIRAudioFile { 
		 
	  
	//for batch processing, needs to be forked outside;      
	extractBeats {    
		  
		var fftsize=1024;    	//ASSUMES SR of 44100 or 48000   
		var analysisfilename;      
		var serveroptions;      
		var score;     
		var temp;      
		var normdata;      
		var ugenindex;    
		var file;    
		var def; 
		
		"Extracting beats".postln;
		  
		//mono input only      
		def = SynthDef(\SCMIRAudioBeatTrack,{arg playbufnum, length;        
			var env, input;      
			var fft, trig;       
			var featuresave;    
			var beattrackoutput;  
			  
			env=EnvGen.ar(Env([1,1],[length]),doneAction:2);		      
			//stereo made mono      
			input= if(numChannels==1,{     
				PlayBuf.ar(1, playbufnum, BufRateScale.kr(playbufnum), 1, 0, 0);     
				},{     
				Mix(PlayBuf.ar(numChannels, playbufnum, BufRateScale.kr(playbufnum), 1, 0, 0))/numChannels;       
			});     
			  
			fft = FFT(LocalBuf(fftsize,1),input,wintype:1);      
			 
			beattrackoutput = BeatTrack.kr(fft); 
				 
			trig=((beattrackoutput[0])>0.5)-0.1; //beat locations      
			  
			//Sweep will time over course of playback 
			//[beat time, tempo] 
			featuresave = FeatureSave.kr([Sweep.kr(Impulse.kr(0),1.0),beattrackoutput[3]], trig);     
			  
			//ugenindex =  featuresave.synthIndex;        
			  
		});      
		
		def.children.do{|val,i| if(val.class==FeatureSave,{ugenindex = val.synthIndex})};

		def.writeDefFile;     
		  
		  
		//wait for SynthDef sorting just in case      
		//0.1.wait;      
		//SCMIR.waitIfRoutine(0.1);    
		  
		analysisfilename= analysispath++basename++"beats.data";    
		//analysisfilename.postln;      
		  
		score = [       
		//[0.0, [\b_allocRead, 0, sourcepath, 0, 0]],    
		[0.0, [\b_allocRead, 0, sourcepath, loadstart, loadframes]],   
		[0.0, [ \s_new, \SCMIRAudioBeatTrack, 1000, 0, 0,\playbufnum,0,\length, duration]], //plus any params for fine tuning     
		[0.005,[\u_cmd, 1000, ugenindex, "createfile",analysisfilename]], //can't be at 0.0, needs allocation time for synth before calling u_cmd on it   
		[duration,[\u_cmd, 1000, ugenindex, "closefile"]],      
		[duration, [\c_set, 0, 0]]       
		];      
		  
		serveroptions = ServerOptions.new;     
		serveroptions.numOutputBusChannels = 1; // mono output      
		  
		Score.recordNRTSCMIR(score,SCMIR.nrtanalysisfilename,SCMIR.nrtoutputfilename, nil,44100, "WAV", "int16", serveroptions); // synthesize      
		//SCMIR.processWait("scsynth");     
		  
		//LOAD FEATURES   
		//Have to be careful; Little Endian is standard for Intel processors   
		file = SCMIRFile(analysisfilename,"rb");   
		  
		numbeats = file.getInt32LE;    
		  
		temp = file.getInt32LE;   
		if (temp!= 2) {   
			"extract beats: mixmatch of expectations in number of features ".postln;   
			[2, temp].postln;    
		};    
		  
		//[beattime, localtempo] interleaved  
		temp = numbeats*2; //*numfeatures;   
		beatdata= FloatArray.newClear(temp);      
		  
		 
		//faster implementation?  
		file.readLE(beatdata);  
		  		  
		if((beatdata.size) != temp) {

			file.close; 
			
			beatdata=nil; 
			
			SCMIR.clearResources; 
							
			file = SCMIRFile(analysisfilename,"rb");   
			file.getInt32LE;
			file.getInt32LE;
			  
			beatdata= FloatArray.newClear(temp);  
			file.readLE(beatdata);  
		};    
    
		file.close;    
		  
		  
		("rm "++ (analysisfilename.asUnixPath)).systemCmd;       
		  
		
		this.rationaliseBeats; 	 
		
		"Beats extracted".postln;
		 
	} 
	 
	 
	//to do; call through to command line app 
	extractBeatsViaBeatRoot {|beatrootlocation|    
		 
		var beatlist, temp;  
		var now, prev; 
		var outputfilename; 
		
		"Extracting beats using BeatRoot".postln;
		   
		beatrootlocation = beatrootlocation ?? {"/Users/nickcollins/Desktop/tosort/beatroot/beatroot-0.5.7.jar"};  
		 
		//("java -cp"+beatrootlocation+"at.ofai.music.beatroot.BeatRoot -o output.txt"+sourcepath).postln; 
		 
		//("java -cp"+beatrootlocation+"at.ofai.music.beatroot.BeatRoot -o output.txt"+sourcepath).unixCmd; 
		//0.1.wait;  		
		//assumes no other java process underway?  
		//SCMIR.processWait("java");     
		
		outputfilename = SCMIR.getTempDir ++ "output.txt"; 
	
		//extra quote marks to avoid issue with spaces in file path
		//output.txt	
		SCMIR.external("java -cp"+beatrootlocation+"at.ofai.music.beatroot.BeatRoot -o"+outputfilename+("\""++sourcepath++"\""));
		 
		//reconstruct tempo as local estimate from IBI at every point 
		 
		beatlist = FileReader.read(outputfilename); 
		
		("rm output.txt").systemCmd;      
		
		temp = 2*(beatlist.size); 
		
		beatdata= FloatArray.newClear(temp);      
		
		beatlist = beatlist.collect{|val| val[0].asFloat}; 
		
		if(beatlist.size<2,{
			"SCMIRAudioFile:extractbeatsviaBeatRoot: no useful beat data extracted".postln;  ^nil 
			 }); 
		
		now = (-0.5); //dummy start value
		  
		 //[i,now,now.class].postln;
		beatlist.size.do{|i| prev= now;  now = beatlist[i];  beatdata[2*i]= now; beatdata[2*i+1]= (now-prev).reciprocal; };    
		
		beatdata[1]=beatdata[3]; //so reasonable value here
		
		this.rationaliseBeats; 
		
		
		"Beats extracted".postln;
	} 
	 
	 
	 
	//look for weird phase swaps, make sure extend beats to cover whole track for fade ins, lower volume segments. 
	//for BeatTrack UGen, first ten or so seconds of track assumed wrong while beat tracker was establishing itself.  
	//majority vote over track  
	rationaliseBeats { 
		
		var beattimes; 
		var calc; 
		
		if(beatdata.isNil,{ 
			"SCMIRAudioFile:rationalisebeats: this file has no beat data".postln;  ^nil 	 
		});  
		
		calc = beatdata.unlace(2);
		beatdata = calc[0]; 
		tempi = calc[1]; //tempocurve
		
		tempo = tempi.median; //most representative of track
		
		//to redress more later; make sure beats cover any missing areas of track
		//also supports manual tracking of a portion of a track 
		
		
	} 
		
	setBeatData{|inputbeatdata| 
	
		beatdata = inputbeatdata; 
		numbeats = beatdata.size; 
	}	
		
	gatherFeaturesByBeats {|replace=true, meanormax=0|
	
		if (featuredata.notNil) {
		
		if (beatdata.notNil) {
	
		^this.gatherFeaturesBySegments(beatdata, replace, meanormax, true); //marks flag as beat extraction, will use tempi as necessary? 
		} {
		
		"SCMIRAudioFile:gatherFeaturesByBeats - no beats extracted to act as segmentation guide".postln;	
		};
		
		} {
			
		"SCMIRAudioFile:gatherFeaturesByBeats - no feature extraction carried out yet!".postln;		
		}
	}	
		
	//convert featuredata to match up to beats 	
	gatherFeaturesByBeatsOld {|replace=true|
		 
		var pos = 0.0; 
		//var numbeats = beatdata.size; 
		var timeperframe= SCMIR.hoptime; //0.023219954648526; 
		var framenow=0, framenext; 
		var averagevector; 
		var newfeaturedata = FloatArray.newClear(numfeatures*numbeats); //one vector per beat 
		var temp; 
		
		//for each beat location, take max or average of featuredata featurewise following it and up to next beat or track end
		//
		beatdata.do{|beat, i|
			var starttime, endtime; 
			
			starttime= beat;
			
			endtime = if (i< (numbeats-1)) 
			{beatdata[i+1];}
			{
				if(tempi.notNil){min(starttime+tempi[i],duration)}{duration}; 
			}; 
			
			//how many frames fit in? 
			framenow = (starttime/timeperframe).roundUp; 
			framenext =  (endtime/timeperframe).asInteger; //rounds down 
			
			if(framenext<framenow) {framenext= framenow;}; 
			
			if((framenow >= numframes) || (framenext >= numframes)) {
				framenow = numframes - 1; 
				framenext = numframes - 1; 
			};
			
			averagevector = 0.0.dup(numfeatures); 
				
			pos = numfeatures*framenow;
				
			for(framenow, framenext, {|j|

				numfeatures.do{|k|
					
					averagevector[k] = averagevector[k] + featuredata[pos+k]; 
				};
				
				pos = pos + numfeatures; 
				
			}); 
			
			averagevector = averagevector/(framenext-framenow+1); 
			
			
			pos = numfeatures*i; 
			
			numfeatures.do{|k|
					
			newfeaturedata[pos+k] = averagevector[k]; 
			
			}
			
			//while({(pos<endtime) || },{
//				
//				pos = pos + timeperframe; 
//			});
//			
			
		};
		
		if(replace) {
		temp = featuredata; 
		featuredata = newfeaturedata; 
		numframes = beatdata.size; 
		//featuresforbeats = true; 
		featuresbysegments = true; 
		segmenttimes = beatdata; 
		numsegments = numbeats; 
		^temp; //return old
		} {
			
		^newfeaturedata	
		}
		
		
	}	
	 
		 
} 
