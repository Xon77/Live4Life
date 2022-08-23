(
~filenames =
[
"/data/audio/percussion/linndrum/cabasa.wav",
"/data/audio/percussion/linndrum/chh.wav",
"/data/audio/percussion/linndrum/chhl.wav",
"/data/audio/percussion/linndrum/chhs.wav",
"/data/audio/percussion/linndrum/clap.wav",
"/data/audio/percussion/linndrum/conga.wav",
"/data/audio/percussion/linndrum/congah.wav",
"/data/audio/percussion/linndrum/congahh.wav",
"/data/audio/percussion/linndrum/congal.wav",
"/data/audio/percussion/linndrum/congall.wav",
"/data/audio/percussion/linndrum/congalll.wav",
"/data/audio/percussion/linndrum/cowb.wav",
"/data/audio/percussion/linndrum/crash.wav",
"/data/audio/percussion/linndrum/kick.wav",
"/data/audio/percussion/linndrum/kickme.wav",
"/data/audio/percussion/linndrum/ohh.wav",
"/data/audio/percussion/linndrum/reallinn.wav",
"/data/audio/percussion/linndrum/ride.wav",
"/data/audio/percussion/linndrum/sd.wav",
"/data/audio/percussion/linndrum/sdh.wav",
"/data/audio/percussion/linndrum/sdl.wav",
"/data/audio/percussion/linndrum/sst.wav",
"/data/audio/percussion/linndrum/ssth.wav",
"/data/audio/percussion/linndrum/sstl.wav",
"/data/audio/percussion/linndrum/tamb.wav",
"/data/audio/percussion/linndrum/tom.wav",
"/data/audio/percussion/linndrum/tomh.wav",
"/data/audio/percussion/linndrum/tomhh.wav",
"/data/audio/percussion/linndrum/toml.wav",
"/data/audio/percussion/linndrum/tomll.wav"
];

//could add \Transient if have WT_Transient UGen from Wavelets
~features = [Loudness, SensoryDissonance, SpectralEntropy, SpecCentroid, [FFTCrest,10000], [SpecPcile,0.75], [FFTCrest,5000], [SpecPcile,0.25],\ZCR];  //,[MFCC,10] avoid making space too high dimensional; probably only need 2-4 features really

)


//not necessarily needed but helps; get global max and min for all features for normalization
(
{
SCMIR.findGlobalFeatureNorms(~filenames,~features);

SCMIR.saveGlobalFeatureNorms("/Users/nickcollins/Desktop/clusterdemonormalization.scmirZ");
}.fork;
)

SCMIR.globalfeaturenorms.postcs
//[ [ 1.2942938804626, 0, 0.50518840551376, 231.87857055664, 4.5598764419556, 21.512195587158, 6.4267835617065, 21.512195587158, 42.15869140625 ], [ 63.035041809082, 1, 195.57659912109, 9162.2685546875, 188.20750427246, 12541.610351562, 193.12126159668, 6260.048828125, 10718.27734375 ] ]


(
SCMIR.loadGlobalFeatureNorms("/Users/nickcollins/Desktop/clusterdemonormalization.scmirZ");

{
	~featuredata = ~filenames.collect{|filename|

		a = SCMIRAudioFile(filename,~features);

		a.extractFeatures();

		//will average feature values over whole sound file, dropping each sound file's representation to a single mean feature vector
		a.gatherFeaturesBySegments([0.0],false);
	}

}.fork;

)

~featuredata.size //30 files in this case so 30 output points
~featuredata[0].size //9 features per file
//note that only 30 points in 9D space pretty sparse! Should really use less features but working with demo

//requires KMeans quark, get via Quarks.gui if necessary
k = KMeans(3) //assume 3 clusters

~featuredata.do{|featurevector| k.add(featurevector)};

k.update

k.centroids

//what cluster is each file sent to?
k.assignments

//more explicit
~featuredata.do{|featurevector,i| [~filenames[i],k.classify(featurevector)].postln};

//can now use trained kMeans classifier on new sound files too, including in live situations via SCMIRLive etc

//my result, not meant to be definitive!:
[ /data/audio/percussion/linndrum/cabasa.wav, 2 ]
[ /data/audio/percussion/linndrum/chh.wav, 2 ]
[ /data/audio/percussion/linndrum/chhl.wav, 2 ]
[ /data/audio/percussion/linndrum/chhs.wav, 0 ]
[ /data/audio/percussion/linndrum/clap.wav, 2 ]
[ /data/audio/percussion/linndrum/conga.wav, 1 ]
[ /data/audio/percussion/linndrum/congah.wav, 1 ]
[ /data/audio/percussion/linndrum/congahh.wav, 0 ]
[ /data/audio/percussion/linndrum/congal.wav, 1 ]
[ /data/audio/percussion/linndrum/congall.wav, 1 ]
[ /data/audio/percussion/linndrum/congalll.wav, 1 ]
[ /data/audio/percussion/linndrum/cowb.wav, 0 ]
[ /data/audio/percussion/linndrum/crash.wav, 2 ]
[ /data/audio/percussion/linndrum/kick.wav, 1 ]
[ /data/audio/percussion/linndrum/kickme.wav, 1 ]
[ /data/audio/percussion/linndrum/ohh.wav, 2 ]
[ /data/audio/percussion/linndrum/reallinn.wav, 0 ]
[ /data/audio/percussion/linndrum/ride.wav, 0 ]
[ /data/audio/percussion/linndrum/sd.wav, 2 ]
[ /data/audio/percussion/linndrum/sdh.wav, 0 ]
[ /data/audio/percussion/linndrum/sdl.wav, 2 ]
[ /data/audio/percussion/linndrum/sst.wav, 0 ]
[ /data/audio/percussion/linndrum/ssth.wav, 0 ]
[ /data/audio/percussion/linndrum/sstl.wav, 0 ]
[ /data/audio/percussion/linndrum/tamb.wav, 2 ]
[ /data/audio/percussion/linndrum/tom.wav, 1 ]
[ /data/audio/percussion/linndrum/tomh.wav, 1 ]
[ /data/audio/percussion/linndrum/tomhh.wav, 1 ]
[ /data/audio/percussion/linndrum/toml.wav, 1 ]
[ /data/audio/percussion/linndrum/tomll.wav, 1 ]


