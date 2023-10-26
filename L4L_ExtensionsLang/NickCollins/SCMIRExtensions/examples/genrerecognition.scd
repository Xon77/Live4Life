//Creating ARFF file mixing instances from multiple audio file feature extractions

//make sure you are using the post 3.4 MFCC UGen fix

(
var featureinfo = [[MFCC,13]];
var arff; 
var sources; 

//array of arrays, one array for each genre class/category 
sources = [
["/data/audio/mirdata/synthpop/Speak & Spell/01 New Life.wav", "/data/audio/mirdata/synthpop/Speak & Spell/02 I Sometimes Wish I Was Dead (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/03 Puppets (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/04 Boys Say Go! (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/05 Nodisco (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/06 What's Your Name_.wav", "/data/audio/mirdata/synthpop/Speak & Spell/07 Photographic (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/08 Tora! Tora! Tora! (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/09 Big Muff (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/10 Any Second Now (Voices) (2006 Digital Remaster).wav"],
//10 David Bowie tracks 
["/data/audio/mirdata/synthpop/Lodger/01 Fantastic Voyage.wav", "/data/audio/mirdata/synthpop/Lodger/02 African Night Flight.wav", "/data/audio/mirdata/synthpop/Lodger/03 Move On.wav", "/data/audio/mirdata/synthpop/Lodger/04 Yassassin (Long Live).wav", "/data/audio/mirdata/synthpop/Lodger/05 Red Sails.wav", "/data/audio/mirdata/synthpop/Lodger/06 D.J..wav", "/data/audio/mirdata/synthpop/Lodger/07 Look Back In Anger.wav", "/data/audio/mirdata/synthpop/Lodger/08 Boys Keep Swinging.wav", "/data/audio/mirdata/synthpop/Lodger/09 Repetition.wav", "/data/audio/mirdata/synthpop/Lodger/10 Red Money.wav"]
];

//two types
arff = SCMIR.createARFF("/tmp/genre.arff",13,(0..(sources.size-1))); 

{
sources.collect{|array,i|  
	
	array.collect{|filename| 
	var file; 
	
	file = SCMIRAudioFile(filename,featureinfo);

	file.extractFeatures(); 

	//take average features over whole files   
	file.gatherFeaturesBySegments([0.0]);	
	
	file.exportARFFInstances(arff,i);
	
	0.1.wait;		
	}; 
	
	};
	
	arff.close;
}.fork; 

)



//now train using weka
(
//change for your machine 
~wekapath = "/Applications/weka-3-6-1/"; 

~jarpath = ~wekapath ++ "weka.jar"; 

//SuperCollider application folder location
~templocation = "/tmp/"; // /Applications/SuperCollider/SuperCollider3.4/";

~callstart = "java -classpath"+ ~jarpath; 

~arffname = ~templocation++"genre.arff"; 

(~callstart+"weka.classifiers.bayes.NaiveBayes -t"+~arffname+"-d bayes.wekamodel").unixCmd

)
//80% correct, 20% misclassified when I test



//test a novel entry
(
var featureinfo = [[MFCC,13]];
var arff; 
var sources; 

//array of arrays, one array for each genre class/category 
sources = [["/data/audio/mirdata/synthpop/Yellow Magic Orchestra/01 Computer Game _Theme From The Circus_.wav"]];

//two types as before
arff = SCMIR.createARFF(~arffname,13,[0,1]); 

{
sources.collect{|array,i|  
	
	array.collect{|filename| 
	var file; 
	
	file = SCMIRAudioFile(filename,featureinfo);

	file.extractFeatures(); 

	//take average features over whole files   
	file.gatherFeaturesBySegments([0.0]);	
	
	file.exportARFFInstances(arff,1);	//FORCE IT TO BE CLASS 1 RATHER THAN 0
	
	0.1.wait;		
	}; 
	
	};
	
	arff.close;
}.fork; 
)

//all wrong; was closer to DM than Bowie
(~callstart+"weka.classifiers.bayes.NaiveBayes -p 0 -T"+~arffname+"-l bayes.wekamodel").unixCmd




