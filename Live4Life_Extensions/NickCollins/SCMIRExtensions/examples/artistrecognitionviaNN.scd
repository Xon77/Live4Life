//small scale demo of artist recognition (using tracks from late 70s/early 80s synth pop project); requires SC Neural Net class


(
//10 Depeche Mode tracks
~dm = ["/data/audio/mirdata/synthpop/Speak & Spell/01 New Life.wav", "/data/audio/mirdata/synthpop/Speak & Spell/02 I Sometimes Wish I Was Dead (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/03 Puppets (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/04 Boys Say Go! (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/05 Nodisco (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/06 What's Your Name_.wav", "/data/audio/mirdata/synthpop/Speak & Spell/07 Photographic (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/08 Tora! Tora! Tora! (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/09 Big Muff (2006 Digital Remaster).wav", "/data/audio/mirdata/synthpop/Speak & Spell/10 Any Second Now (Voices) (2006 Digital Remaster).wav"];

//10 David Bowie tracks 
~bowie = ["/data/audio/mirdata/synthpop/Lodger/01 Fantastic Voyage.wav", "/data/audio/mirdata/synthpop/Lodger/02 African Night Flight.wav", "/data/audio/mirdata/synthpop/Lodger/03 Move On.wav", "/data/audio/mirdata/synthpop/Lodger/04 Yassassin (Long Live).wav", "/data/audio/mirdata/synthpop/Lodger/05 Red Sails.wav", "/data/audio/mirdata/synthpop/Lodger/06 D.J..wav", "/data/audio/mirdata/synthpop/Lodger/07 Look Back In Anger.wav", "/data/audio/mirdata/synthpop/Lodger/08 Boys Keep Swinging.wav", "/data/audio/mirdata/synthpop/Lodger/09 Repetition.wav", "/data/audio/mirdata/synthpop/Lodger/10 Red Money.wav"];

//10 Yellow Magic Orchestra tracks 
~ymo = ["/data/audio/mirdata/synthpop/Yellow Magic Orchestra/01 Computer Game _Theme From The Circus_.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/02 Firecracker.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/03 Simoon.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/04 COSMIC SURFIN'.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/05 Computer Game _Theme From The Invader_.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/06 tong poo.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/07 la femme chinoise.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/08 Bridge Over Troubled Music.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/09 Mad Pierrot.wav", "/data/audio/mirdata/synthpop/Yellow Magic Orchestra/10 Acrobat.wav"];
)


//extract features and summarise whole tracks by feature means (crude, but let's just try)
(
{
~featuredata = [~dm,~bowie,~ymo].collect{|array,i|  
	
	array.collect{|filename| 
	var file; 
	
	file = SCMIRAudioFile(filename, [[MFCC, 20],SpecCentroid]);

//shortcut versions also work, defaults will be applied for MFCC (10 coeffs) and Chromagram (12TET)
//e = SCMIRAudioFile("/Applications/SuperCollider/SuperCollider3.4/sounds/a11wlk01.wav",[MFCC,Chromagram]);

	file.extractFeatures(); 

	file.gatherFeaturesBySegments([0.0]);	
	
	file.featuredata; 
			
	}; 
	
	}
}.fork
)


~featuredata[0][0].size //21 

~featuredata.size //3 artists



//training based on 7 from each class, test on 10

//use binary with 
NeuralNet.pathToNeuralNetBinary = "/data/sussex/code/SC/sclangextensions/neuralnetSCtoC/NeuralNet/build/Release/"; 

n = NeuralNet(21,21,3); //fast learning rate and initial weights -1.0 to 1.0

d= ~featuredata.collect{|array,i| var output = 0.0!(~featuredata.size); output[i]= 1.0; array[0..6].collect{|instance|   [instance.asArray,output]} }.flatten; 

n.trainExt(d,0.01,10000); //train up, with status updates, max of 1000 epochs or total error 

d.size

//testing
n.calculate(~featuredata[0][0]); 


//confusion matrix
~featuredata.collect{|array| array.collect{|song| n.calculate(song).maxIndex; }}

//result:
[ [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 2 ], [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 ], [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 0 ] ]
//for example, any second now by DM 1981 confused with yellow magic orchestra; last three in each weren't seen before, and that's where errors arise, so not generalising very well. And this only from one fold. 


