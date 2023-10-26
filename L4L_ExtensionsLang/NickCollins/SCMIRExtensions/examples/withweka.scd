//for weka command line help, see 
//http://weka.wikispaces.com/How+to+run+WEKA+schemes+from+commandline
//http://weka.wikispaces.com/Primer
//http://weka.wikispaces.com/Using+cluster+algorithms


(
//change for your machine 
~wekapath = "/Applications/weka-3-6-1/"; 

~jarpath = ~wekapath ++ "weka.jar"; 

//SuperCollider application folder location
~templocation = "/tmp/"; // "/data/gitprojects/supercollider/common/build/";

~callstart = "java -classpath"+ ~jarpath; 

~arffname = ~templocation++"testfile.arff"; 

)


//test can call weka; ask for help. you may need to view messages in the Console app on OS X
(~callstart+"weka.classifiers.trees.J48 -h").unixCmd


//analyze file and create ARFF output


f = SCMIRAudioFile("sounds/a11wlk01.wav", [[MFCC, 13], [Chromagram, 12]]);

{f.extractFeatures(); }.fork(SystemClock); 

f.exportARFF(~arffname); 


//validate ARFF
(~callstart+"weka.core.Instances"+~arffname).unixCmd



//train with basic classifiers; will be perfect here, since no class to predict
(~callstart+"weka.classifiers.rules.ZeroR -t"+~arffname).unixCmd

//can't handle numeric class, nothing to predict
(~callstart+"weka.classifiers.trees.J48 -t"+~arffname).unixCmd

//test on existing data set from weka package
(~callstart+"weka.classifiers.trees.J48 -t"+(~wekapath++"data/soybean.arff")).unixCmd

//-d save model, -l load model
(~callstart+"weka.classifiers.bayes.NaiveBayes -t"+(~wekapath++"data/soybean.arff")+"-d bayes.wekamodel").unixCmd

//test using saved model
(~callstart+"weka.classifiers.bayes.NaiveBayes -T"+(~wekapath++"data/soybean.arff")+"-l bayes.wekamodel").unixCmd





//run clustering on instances

(~callstart+"weka.clusterers.SimpleKMeans -h").unixCmd

//find 5 clusters -N option is for number of desired clusters
(~callstart+"weka.clusterers.SimpleKMeans -N 5 -t"+~arffname).unixCmd


//find 10 clusters and save
(~callstart+"weka.clusterers.SimpleKMeans -N 10 -t"+~arffname+"-d kmeans.wekamodel").unixCmd


//use cluster model on novel input

//MUST have same features extracted in same order
g = SCMIRAudioFile("sounds/yourmum.wav", [[MFCC, 13], [Chromagram, 12]]);

{g.extractFeatures(); }.fork(SystemClock); 

~arffname2 = ~templocation++"testfile2.arff"; 

g.exportARFF(~arffname2); 

(~callstart+"weka.clusterers.SimpleKMeans -T"+~arffname2+"-l kmeans.wekamodel").unixCmd



//next challenge; how to get a specific instance clustered and get data back into SC; via piped output from weka, or at least scan of text file out?
(~callstart+"weka.clusterers.SimpleKMeans -T"+~arffname2+"-p 0 -l kmeans.wekamodel").unixCmd

//using Pipe to get data a line at a time
(
var p, l;
var count = 0; 
p = Pipe.new((~callstart+"weka.clusterers.SimpleKMeans -T"+~arffname2+"-p 0 -l kmeans.wekamodel"), "r");						// list directory contents in long format
l = p.getLine;								// get the first line
while({l.notNil}, {
	//[count,l].postln; 
	if (l.size>0,{(l.split($  )[1]).postln;}); //post cluster assignment decision
	count = count +1; 
	l = p.getLine; 
	});	// post until l = nil
p.close;										// close the pipe to avoid that nasty buildup
)

//if getting a single cluster result, just put one feature instance in the output file. 

//another way may be to write an OSC based java program making weka calls, or link in to Rebecca Fiebrink's wekinator (though SC's feature extraction required)




//classify onset-cued segments 
g = SCMIRAudioFile("/data/audio/mirdata/pixiesivebeentired.wav", [[MFCC, 20]]);

(
{
g.extractFeatures(); 
g.extractOnsets();
}.fork(SystemClock);
) 

(
g.gatherFeaturesByOnsets;

~arffname3 = ~templocation++"testfile3.arff"; 

//output onset collected features as instances in an ARFF file
g.exportARFF(~arffname3); 
)

//train clusterer, 3 clusters
(~callstart+"weka.clusterers.SimpleKMeans -N 3 -t"+~arffname3+"-d kmeansonsets.wekamodel").unixCmd

//could now compare on another file, or just use these clusters in selective resynthesis, etc

(
var p, l;
var count = 0; 
var onsetclassification = List[]; 

p = Pipe.new((~callstart+"weka.clusterers.SimpleKMeans -T"+~arffname3+"-p 0 -l kmeansonsets.wekamodel"), "r");						// list directory contents in long format
l = p.getLine;								// get the first line
while({l.notNil}, {
	//[count,l].postln; 
	if (l.size>0,{onsetclassification.add( (l.split($  )[1]).asInteger);}); //post cluster assignment decision
	count = count +1; 
	l = p.getLine; 
	});	// post until l = nil
p.close;										// close the pipe to avoid that nasty buildup
~solution = onsetclassification.postcs
)


s.boot;

(
b = Buffer.read(s,"/data/audio/mirdata/pixiesivebeentired.wav"); //load whole thing for ease of use

SynthDef(\scmirplaybacksegment,{arg bufnum, pos= 0.0, duration=1.0;
	
	Out.ar(0, PlayBuf.ar(2,bufnum,BufRateScale.ir(bufnum),startPos:pos*BufSampleRate.ir(bufnum))*EnvGen.ar(Env([0,1,1,0],[0.01,duration-0.02,0.01]),doneAction:2)); 
	
}).add
)

//play back only those events tagged in cluster 0; misses out chorus parts, mainly verse! 
(
{
~solution.do{|cluster, i| 
	var onsettime, endtime, duration; 
	
	if (cluster==0){ 
	
	onsettime = g.onsetdata[i]; 
	
	endtime = if(i<(g.numframes-1)){g.onsetdata[i+1]-0.001}{g.duration}; 
	
	duration = (endtime-onsettime).max(0.0);
	
	Synth(\scmirplaybacksegment,[\pos,onsettime,\duration,duration]);
	
	duration.wait; 
	
	//0.1.wait; //short silence between each segment 
	
	}; }

}.fork;
)




