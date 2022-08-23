//Demonstrates getting an overall file comparison score


//frame rate will be about 86Hz
SCMIR.setFrameHop(512); 



//trying naively to match up all file pairs via similarity matrix 

(  
var featurelist = [[MFCC, 10],[Loudness],[SpecCentroid],[SpecPcile, 0.95],[SpecPcile, 0.8],[SpecFlatness],[FFTCrest],[FFTCrest, 0, 2000], [FFTCrest, 2000, 10000],[FFTSpread],[FFTSlope],[SensoryDissonance],[Onsets,\rcomplex]];    
  
var files = ["/data/audio/mirdata/pixiesivebeentired.wav","/data/audio/mirdata/Yellow Submarine.wav"];   
  
var comparisonmatrix;   
var audioanalysis;   

{  
audioanalysis = files.collect{|filename,i|	   
	  
	e = SCMIRAudioFile(filename,featurelist);  
	e.extractFeatures();  
	e  
};	  
  
//check all pairings	  
  
comparisonmatrix = Array.fill(files.size-1,{|i|   
	var comparisons = List[];   
	var audio1 = audioanalysis[i];   
	  
	if((i+1) < (files.size)	) { 
		for(i+1,files.size-1,{|j,count|  
			  
			var audio2 = audioanalysis[j];	  
			  
			m = audio1.similarityMatrix(40,0,other:audio2);  
			  
			comparisons.add(m);  
		}); 	  
	}; 
	  
	comparisons	  
}); 	  
  
  
c = comparisonmatrix;  
  
}.fork; 
)


c

d= c[0][0].dtw(40) //leeway of 40 either side, 1 frame is around 0.5 seconds, so allows up to  20 seconds ahead or behind 
				 

//use DTW, get best path match score:

d[0]; //match score

c[0][0].plot(2,2, path:d)	//show path on the similarity matrix plot







//this next calculation takes a while; could speed up by reducing search area

// by testing one file against another, one ten second block at a time, finding closest block in other file; trying to get overall DTW based comparison score
//in general need normalisation by duration of audio1.duration of all distances between audio1 and others
(  
var featurelist = [[MFCC, 10],[Loudness],[SpecCentroid],[SpecPcile, 0.95],[SpecPcile, 0.8],[SpecFlatness],[FFTCrest],[FFTCrest, 0, 2000], [FFTCrest, 2000, 10000],[FFTSpread],[FFTSlope],[SensoryDissonance],[Onsets,\rcomplex]];     
  
var files = ["/data/audio/mirdata/pixiesivebeentired.wav","/data/audio/mirdata/Yellow Submarine.wav","/data/audio/mirdata/synthpopexclude/buggles/10 Technopop.wav"];    
  
var comparisonmatrix;    
var audioanalysis;    
var score= 0.0;    
var numfit;    
var temp;    
var segmentsize= 10.0;   //Short Term Memory size
  
{   
	  
	audioanalysis = files.collect{|filename,i|	    
		  
		e = SCMIRAudioFile(filename,featurelist);   
		  
		e.extractFeatures();   
		  
	};	   
	  
	  
	numfit= audioanalysis.collect{|val| val.duration};   
	  
	numfit = (numfit/segmentsize).asInteger;  
	  
	numfit.postln;  //number of segments within each  
	  
	//check all pairings	   
	  
	comparisonmatrix = Array.fill(files.size-1,{|i|    
		  
		var comparisons = List[];    
		var audio1 = audioanalysis[i];    
		var numfit1 = numfit[i];   
		  
		if((i+1) < (files.size)	) {  
			for(i+1,files.size-1,{|j,count|   
				  
				var audio2 = audioanalysis[j];	   
				var numfit2 = numfit[j];   
				  
				("comparing"+i+"to"+j).postln;   
				  
				score= 0.0;	  
				  
				numfit1.do{|segment1|   
					  
					var minval = 999999999999.9;    
					//var minindex=0;    
					var excerpt1,excerpt2,matrix;   
					  
					[\segment1, segment1].postln;    
					  
					excerpt1 = SCMIRAudioFile.newFromRange(audio1,segment1*segmentsize,(segment1+1)*segmentsize);    
					  
					numfit2.do{|segment2|    
						  
						[\segment2, segment2].postln;	   
						  
						excerpt2 = SCMIRAudioFile.newFromRange(audio2,segment2*segmentsize,(segment2+1)*segmentsize);    
						  
						0.01.wait;   
						  
						matrix = excerpt1.similarityMatrix(2, 2, other:excerpt2);    
						  
						0.01.wait;   
						  
						//actually 6 either side in original frame terms    
						d = matrix.dtw(3);   
						  
						//d.postln;  
						  
						if(d[0]<minval) {   
							  
							minval = d[0];    
							//minindex = j;    
							  
						};   
						  
					};   
					  
					score = score + minval;    
					  
					//score.postln;   
				};    
				  
				comparisons.add(score/numfit1); // /(audio1.duration) //normalize scores relative to audio1 currently being compared to others, to get a similarity per block
			}); 	   
		};  
		  
		comparisons	   
	}); 	   
	  
	  
	c = comparisonmatrix;   
	d = numfit; 
	  
}.fork(SystemClock, stackSize:16384); //wait for me to finish   
  
  
 
)



c
//[ List[ 155.33421660256, 158.85525181972 ], List[ 122.95233852859 ] ]


d
//[ 18, 16, 23 ]


c.flatten/[18,18,16]

//[ 8.6296787001423, 8.8252917677624, 7.6845211580367 ]
//closest is B to C, second A to B, last A to C

