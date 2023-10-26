SCMIRLive {

	classvar <>livecount;

	var <numfeatures;
	var <featureinfo, <normalizationinfo, <normtype;
	var <latestfeatures;
	var <featurehop; //must be on a per live feature extractor basis
	var <whichlive; //unique ID for responder; if saved though, could come back to bite, so can set own names
	var <>synthdefname;
	var <>oscname;

	//not saved or loaded since dynamic server state
	var <controlbusses, <synth, <responder;

	*initClass {

		livecount = 0;

	}

	*new {|scmiraudiofile, featurenorms|

		if( (scmiraudiofile.featuredata.isNil) && (featurenorms.isNil)) {
			postln("SCMIRLive error: SCMIRAudioFile passed in has no feature data; call extractFeatures method on it first, or pass in precalculated global feature norms array from SCMIR.globalfeaturenorms"); 		^nil;
		}

		^super.new.initSCMIRLive(scmiraudiofile, featurenorms);

	}

	*newFromFile {|filename|

		^super.new.load(filename);

	}


	initSCMIRLive {|scmiraudiofile,featurenorms|

		featurehop = SCMIR.framehop;

		featureinfo = scmiraudiofile.featureinfo;

		numfeatures = scmiraudiofile.numfeatures;

		livecount = livecount + 1;

		whichlive = livecount;

		synthdefname = (\SCMIRLiveFeatures++whichlive).asSymbol; //can be changed
		oscname = synthdefname;

		//prepare normalization

		if(featurenorms.isNil) {
		normalizationinfo = scmiraudiofile.normalize(scmiraudiofile.featuredata, true);
		} {
		normalizationinfo = featurenorms;
		};

		normtype = scmiraudiofile.normalizationtype;

	}


	changewhichlive {|newwhichlive|

		whichlive = newwhichlive;

		//need to update
		synthdefname = (\SCMIRLiveFeatures++whichlive).asSymbol; //can be changed


	}


	createSynthDef {|synthdefcalled, normalize=true, sendosc=true, controlbusses=true, clip=false|
		var fftsizetimbre = 1024;
		var fftsizepitch = 4096; //for chromagram, pitch detection
		var fftsizespec = 2048;
		var fftsizeonset = featurehop;
		var def;

		if(synthdefcalled.notNil) {synthdefname = synthdefcalled; oscname = synthdefname; };

		def = SynthDef(synthdefname,{arg in=8, out=0;
			var env, input, features, trig;
			//var env, input, trig, chain, centroid, features;
//			var mfccfft, chromafft, specfft, onsetfft;
			var featuresave;

			input= In.ar(in,1); //mono only


			#features, trig = SCMIRAudioFile.resolveFeatures(input,featurehop,featureinfo);


			//if (featurehop == 1024) {
//				mfccfft = FFT(LocalBuf(fftsizetimbre,1),input,1, wintype:1);
//				chromafft = FFT(LocalBuf(fftsizepitch,1),input,0.25, wintype:1);
//				//for certain spectral features
//				specfft = FFT(LocalBuf(fftsizespec,1),input,0.5, wintype:1);
//				onsetfft = FFT(LocalBuf(fftsizeonset,1),input,1);
//				} {
//				//else it should be 512
//				mfccfft = FFT(LocalBuf(fftsizetimbre,1),input,0.5, wintype:1);
//				chromafft = FFT(LocalBuf(fftsizepitch,1),input,0.125, wintype:1);
//				//for certain spectral features
//				specfft = FFT(LocalBuf(fftsizespec,1),input,0.25, wintype:1);
//				onsetfft = FFT(LocalBuf(fftsizeonset,1),input,1); //will be smaller to start with
//			};
//
//			trig=chromafft;
//
//			features= [];
//
//			featureinfo.do{|featuregroup|
//
//				features = features ++ (switch(featuregroup[0].asSymbol,
//				\MFCC,{
//					MFCC.kr(mfccfft,featuregroup[1]);
//				},
//				\Chromagram,{
//
//					Chromagram.kr(chromafft,4096,featuregroup[1]);
//				},
//				\Tartini, {Tartini.kr(input, 0.93, 2048, 0, 2048-featurehop) },
//				\Loudness, {Loudness.kr(mfccfft) },
//				\SensoryDissonance,{SensoryDissonance.kr(specfft, 2048)},
//				\SpecCentroid,{SpecCentroid.kr(specfft)},
//				\SpecPcile,{SpecPcile.kr(specfft,featuregroup[1] ? 0.5)},
//				\SpecFlatness,{SpecFlatness.kr(specfft)},
//				\FFTCrest,{FFTCrest.kr(specfft,featuregroup[1] ? 0, featuregroup[2] ? 50000)},
//				\FFTSpread,{FFTSpread.kr(specfft)},
//				\FFTSlope,{FFTSlope.kr(specfft)},
//				//always raw detection function in this feature extraction context
//				\Onsets,{Onsets.kr(onsetfft, odftype: (featuregroup[1] ?  \rcomplex), rawodf:1)},
//				//more to add: FFTRumble (in combination with pitch detection, energy under f0)
//				\RMS,{Latch.kr(RunningSum.rms(input,1024),mfccfft)},
//				\ZCR,{Latch.kr(ZeroCrossing.ar(input),mfccfft)}
//				));
//
//			};

			//normalization

			//normalizationinfo

			if(normalize) {

				if(normtype==0) {

					features = features.collect{|val,j|

						var minval = normalizationinfo[0][j];
						var maxval = normalizationinfo[1][j];
						var diff = 1.0/(maxval-minval);

						//[j,minval,maxval,diff].postln;

						var normed = ((val-minval)*diff); //.clip2(0.0,1.0); //make sure doesn't go outside this range?

						if(clip,{normed.clip(0.0,1.0)},{normed});

					};

					} {

					features = features.collect{|val,j|

						var meanval = normalizationinfo[0][j];
						var stddev = normalizationinfo[1][j];
						var diff = 1.0/stddev;

						(val-meanval)*diff;
					};


				}

			};

			//features.poll;

			//'SCMIRLive'
			if (sendosc) {
				//["sendosc",oscname,whichlive].postln;

				//[\sanitycheck,features.size].postln;

			SendReply.kr(trig,oscname,features,whichlive);
			};

			if (controlbusses) {
			Out.kr(out,features);
			};

		});

		^def;

	}


	createResponder {|function|

		responder.remove;
		responder = OSCresponderNode(nil,oscname,{|t, r, msg|

			//to support multiple SCMIRLive responders at once
			if(msg[2]==whichlive) {
				function.value(msg);
			};

		}).add;

		^responder;

	}


	removeResponder {|function|

		responder.remove;

	}

	//default live input 1 in 8 channel output system
	run {|inputbus=8, group|

		synth.free; //in case already started?

		if(controlbusses.isNil) {
			controlbusses = Bus.control(Server.default,numfeatures);
		};

		group = group ?? {Group.basicNew(Server.default,1)};

		synth = Synth.head(group,synthdefname,[\in, inputbus, \out, controlbusses.index]);

		^synth;
	}


	save { |filename|
		//Archive- ascii
		//ZArchive - binary, better for this data
		var a;
		var instancevars;

		filename = filename?? {SCMIR.tempdir++synthdefname++".scmirZ"};

		a = SCMIRZArchive.write(filename);

		a.writeItem(numfeatures);
		a.writeItem(featureinfo);
		a.writeItem(normalizationinfo);
		a.writeItem(normtype);
		a.writeItem(featurehop);
		a.writeItem(whichlive);
		a.writeItem(synthdefname);
		a.writeItem(oscname);

		a.writeClose;
	}


	load { |filename|
		var a;
		var instancevars;

		filename = filename?? {SCMIR.tempdir++synthdefname++".scmirZ"};

		a = SCMIRZArchive.read(filename);

		numfeatures = a.readItem;
		featureinfo = a.readItem;
		normalizationinfo = a.readItem;
		normtype = a.readItem;
		featurehop = a.readItem;
		whichlive = a.readItem;
		synthdefname= a.readItem;
		oscname = a.readItem;

		//ignore saved whichlives, need to avoid duplicates over multiple sessions
		livecount = livecount + 1;
		whichlive = livecount;
		synthdefname = (\SCMIRLiveFeatures++whichlive).asSymbol; //can be changed
		oscname = synthdefname;

		a.close;

	}



}
