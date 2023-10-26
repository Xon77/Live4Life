//\CustomFeature


//write your own custom feature extractor (this must be a closed function if you expect saving to work!)

//format: [\CustomFeature,{arg input; /*insert feature extraction here operating on input*/},numberofoutputs]
//e.g.  [\CustomFeature,{arg input; [RunningSum.ar(input,1024), (input.abs)>0.5]},2]
//numberofoutputs defaults to 1; if your function returns a different number of outputs you'll get into trouble and SCMIR will likely crash on array processing
//note that the output will be re-sampled to the SCMIR frame rate (SCMIR.framerate), so you will lose finer detailed variation and potentially get aliasing; it is suggested you apply your own window based processing via FFT, RunningSum etc

//control periods per second/frames per second = control periods per frame
//(s.sampleRate/s.options.blockSize)/SCMIR.framerate = 16 (1024/64)

//one custom feature
e = SCMIRAudioFile(Platform.resourceDir +/+ "sounds/a11wlk01.wav", [[\CustomFeature,{arg input; Median.kr(16,Pitch.kr(input)[0].cpsmidi)}]]);

{e.extractFeatures(normalize:true)}.fork

e.plotFeatures(400,600,40, true); //line based plot



(
//4 features extracted + MFCCs
e = SCMIRAudioFile(Platform.resourceDir +/+ "sounds/a11wlk01.wav", [
	 [MFCC, 13], //MFCCs standard
	[\CustomFeature,
	{arg input;

		[
			input, //input is audio rate, so output will be like a downsampling with aliasing (no low pass filtering applied, could add some; you can do what you like inside a CustomFeature function!)
			SinOsc.kr(10), //you can synthesise and ignore analysis...
			RunningSum.rms(input,1024),
			if(input.abs>0.5,DC.kr(1),DC.kr(0))
		]
	}
	,4]]
);
)

{e.extractFeatures(normalize:true)}.fork

e.plotFeatures(400,600,40, true); //line based plot

m = e.similarityMatrix();  //m is an SCMIRSimilarityMatrix object

m.plot(4,5) //oscillation over image is the synthesized sine's effect, most likely

//shortcut
e.plotSelfSimilarity(1,4); //unit = 1, stretch = 4, params as above





//check equivalence: same parameters for in built Loudness feature extractor and via custom function

e = SCMIRAudioFile(Platform.resourceDir +/+ "sounds/a11wlk01.wav", [\Loudness, [\CustomFeature,{arg input; Loudness.kr(FFT(LocalBuf(1024),input,1,wintype:1),0.25,1)},1]]);

{e.extractFeatures(normalize:true)}.fork

//exactly same results
e.plotFeatures(300,300,40);
e.plotFeatures(400,600,40, true); //line based plot

e.featuredata
e.numfeatures

//test save/load
e.save("/tmp/a11wlk01.scmirZ")    //save .scmirZ files using ZArchive; binary storage of feature data and other instance variables

e.load("/tmp/a11wlk01.scmirZ")
//if no filenames are provided, will be placed in temp directory

e.featureinfo




//check SCMIRLive

(
e = SCMIRAudioFile(Platform.resourceDir +/+ "sounds/a11wlk01.wav", [
	[\CustomFeature,
	{arg input;

		[
			LPF.ar(input,20), //low pass this time
			SinOsc.kr(10), //you can synthesise and ignore analysis...
			RunningSum.rms(input,1024),
			if(input.abs>0.25,DC.kr(1),DC.kr(0))
		]
	}
	,4]]
);
)


//if need proper normalizing need to have not already normalized!
{e.extractFeatures(normalize:false)}.fork

l = SCMIRLive(e)

l.dump
l.featureinfo
l.normalizationinfo
[ [ -0.010306200943887, -0.99988812208176, 0.018318351358175, 0 ], [ 0.016430662944913, 0.9999874830246, 0.54670751094818, 1 ] ]

s.boot; //ready to go live

//create SynthDef for this feature set with normalization
l.createSynthDef.add

l.createResponder({arg input; input.postln }); //create a language side responder for this feature extractor

//run Synth with the SynthDef already added, input bus is 8, which is first audio input on machine
a = l.run(8)

l.synth

l.removeResponder


//store for future use (assumes saved SynthDef as well, or at least will createSynthDef on reload before live use
l.save("/tmp/scmirlive1.scmirZ");

l.load("/tmp/scmirlive1.scmirZ");

l.createSynthDef.add

a = l.run(8)

//set up responder again to print outputs; note that normalisation was from previous file and this is now operating on general live input so you may see output values outside of the [0,1] normed range
l.createResponder({arg input; input.postln }); //create a language side responder for this feature extractor


//short cut creation
l = SCMIRLive.newFromFile("/tmp/scmirlive1.scmirZ");



