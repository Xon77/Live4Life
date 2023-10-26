
(
{
e = SCMIRAudioFile(Platform.resourceDir +/+ "sounds/a11wlk01.wav", [[\CustomFeature,{arg input; RunningSum.ar(BLowPass.ar(input,100,1),1024)}]]);

e.extractFeatures(normalize:true);

//e.featuredata.size
//e.plotFeatureTrail(0);

e.extractOnsets();

//e.onsetdata.size

e.gatherFeaturesByOnsets(summarytype:1); //take max in texture window, replaces existing feature data

//e.featuredata.size
//e.plotFeatureTrail(0)

~lowpoweronsets = List[];

//threshold 0.85 here for you to modify
e.getFeatureTrail(0).do{|val,i|  if(val>0.85){~lowpoweronsets.add(e.onsetdata[i])}; };

~lowpoweronsets.postln; //times, multiply by 44100 for samples

}.fork;
)
