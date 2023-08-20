// Adapted, modified and based on template code for sending lots of data (1024 fft values 61 times per second) from sc to processing. Sound function from an old sc-tweet.
// http://sccode.org/1-4Ty
// by Fredrik Oloffson

// There is also an extended version of http://sccode.org/1-4Ty this one sends 3 streams of spectral data at the same time - high, mid and low filtered. note: quite heavy on the cpu and sends a lot of data via osc (1024*3 values 61times/second).
// http://sccode.org/1-4Wt

// Look also at : // http://sccode.org/1-4UL
// by Luigi Tamagnini
// in SC it analyses audio data with some useful UGens: Onsets, SendTrig and SendPeakRMS; this data is then polled back to de client and dispatched to Processing via NetAddr and OSCFunc classes in Processing i receive the incoming messages and simple trig a draw function with the callback oscEvent (use oscP5 and netP5 libs





( // Only on 1st server XXXXXXXXX
// Code to evaluate to send spectral data FFT and Loudness, Pitch, Spectral Centroid & Flatness
// Envoi des données d'amplitude FFT & autres données high-level comme Loudness, Spectral Centroid & Flatness

~fftbuffersize= 2048;
~fftbuffersize2= ~fftbuffersize.div(2);

~processingAddress = NetAddr("127.0.0.1", 12000);

s.waitForBoot{

	~loudbus = Bus(\control, index: 230, numChannels: 1);
	~pitch1bus = Bus(\control, index: 231, numChannels: 1);
	~pitch2bus = Bus(\control, index: 232, numChannels: 1);
	~specCentroid = Bus(\control, index: 233, numChannels: 1);
	~specFlatness = Bus(\control, index: 234, numChannels: 1);
	~fftbus = Bus(\control, index: /*14@0*/ 235, numChannels: ~fftbuffersize2);
	// ~fftbuffer= Buffer.alloc(s, ~fftbuffersize, 1);

	// A relancer si ~numChannels change
	SynthDef(\avTrk, {|in= 0, t_trig= 0, amp= 1, bus|
		var input = In.ar(in, ~numChannels);
		var z= Mix(input*amp);
		// var chain= FFT(~fftbuffer, z);
		var chain= FFT(LocalBuf(~fftbuffersize), z);
		Array.fill(~fftbuffersize2, {|i|
			var a= Unpack1FFT(chain, ~fftbuffersize, i);
			var d= Demand.kr(chain>=0 /*Impulse.kr(31)*/ , 0, a); // ???
			Out.kr(bus+i, d.min(1));
		});
	}).add/*load*/;

	SynthDef(\avLoudPitchSpectre, {|in= 0, t_trig= 0, amp= 1, busA, busP1, busP2, busC, busF |
		var input = In.ar(in, ~numChannels);
		var z= Mix(input*amp);
		// var chain= FFT(~fftbuffer, z);
		var chain= FFT(LocalBuf(~fftbuffersize), z); // 1024 FFT for sampling rates of 44.1/48K -> Loudness
		var chain2= FFT(LocalBuf(~fftbuffersize), z); // 1024 or 2048 FFT for other analyses
		var qitch = Qitch.kr(z, ~qitchBuffer); // sur 2048 - PITCH // Différence avec Loudness
		Out.kr(busA, Loudness.kr(chain)); // LOUDNESS
		Out.kr(busP1, qitch[0]); // PITCH
		Out.kr(busP2, qitch[1]); // PITCH
		Out.kr(busC, SpecCentroid.kr(chain2)); // SPECTRAL CENTROID
		Out.kr(busF, SpecFlatness.kr(chain2)); // SPECTRAL FLATNESS
	}).add/*load*/;

	s.sync;

	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus]);
	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus], target: s.defaultGroup, addAction: \addAfter);
	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus], target: 1000, addAction: \addBefore);
	~ffttrk = Synth(\avTrk, [\in, 0, \amp, 0.3 /*1*/, \bus, ~fftbus], target: RootNode(Server.default), addAction: \addToTail); // Pourquoi amp de 0.3 ???

	// s.sendBundle(0.2, ["/s_new", "default", x = s.nextNodeID, 0, 1], ["/n_set", x, "freq", 500]);
	// s.sendMsg("/s_new", "default", -1, 0, 0);
	// a = play{var a=SinOsc;Splay.ar(a.ar(PulseCount.ar(f=InFeedback.ar(0,2).sum)%999+(60,63.0005..99)*a.ar(2**f)*2+[3,4],f>0*f*9)).tanh*MouseX.kr(0, 1)};

	~loudtrk = Synth(\avLoudPitchSpectre, [\in, 0, \amp, 1.0, \busA, ~loudbus, \busP1, ~pitch1bus, \busP2, ~pitch2bus, \busC, ~specCentroid, \busF, ~specFlatness], target: RootNode(Server.default), addAction: \addToTail);

	~fftroutine = Routine({
		inf.do{
			var fftArray = ~fftbus.getnSynchronous(~fftbuffersize2);
			var loudness = ~loudbus.getSynchronous;
			var pitch1 = ~pitch1bus.getSynchronous;
			var pitch2 = ~pitch2bus.getSynchronous.asInteger;
			var specCentroid = ~specCentroid.getSynchronous;
			var specFlatness = ~specFlatness.getSynchronous;
			~processingAddress.sendMsg(\fftArray, *fftArray);  //sending 1024 values
			~processingAddress.sendMsg(\loud, loudness);
			~processingAddress.sendMsg(\pitch, pitch1, pitch2);
			~processingAddress.sendMsg(\specCentroid, specCentroid);
			~processingAddress.sendMsg(\specFlatness, specFlatness);

			// ~loudbus.get; // Pourquoi donnéee de 0 à + de 100, alors que les données en sones ne devraient aller que jusqu'à 64 ???

			(1/61).wait;  // a tiny bit faster than framerate - pas d'impact CPU sur le server si réduit de moitié ????????? -> plutôt sur le CPU langage
		};
	});

	~fftroutine.play;

	CmdPeriod.doOnce({
		(
			// ~fftbuffer.free;
			~fftbus.free; ~loudbus.free; ~pitch1bus.free; ~pitch2bus.free; ~specCentroid.free; ~specFlatness.free; // Bus
			~ffttrk.free; ~loudtrk.free; // Synth
			~fftroutine.stop; // Routine
		)
	});

};
)

~fftbus.get;
~fftbus.get({ |i| a = i.postcs; a.minItem.postln; a.maxItem.postln }); // To get FFT data





( // On both servers XXXXXXXXX
// Code to evaluate to send spectral data FFT and Loudness, Pitch, Spectral Centroid & Flatness - on both servers XXXXXXXXX
// Envoi des données d'amplitude FFT & autres données high-level comme Loudness, Spectral Centroid & Flatness

~fftbuffersize= 2048;
~fftbuffersize2= ~fftbuffersize.div(2);

~processingAddress = NetAddr("127.0.0.1", 12000);

~server1.waitForBoot{

	~loudbus = Bus(\control, index: 230, numChannels: 1, server: ~server1);
	~pitch1bus = Bus(\control, index: 231, numChannels: 1, server: ~server1);
	~pitch2bus = Bus(\control, index: 232, numChannels: 1, server: ~server1);
	~specCentroid = Bus(\control, index: 233, numChannels: 1, server: ~server1);
	~specFlatness = Bus(\control, index: 234, numChannels: 1, server: ~server1);
	~fftbus = Bus(\control, index: /*14@0*/ 235, numChannels: ~fftbuffersize2, server: ~server1);
	// ~fftbuffer= Buffer.alloc(s, ~fftbuffersize, 1);

	if (~server2.notNil, {
		~loudbus2 = Bus(\control, index: 330, numChannels: 1, server: ~server2);
		~pitch1bus2 = Bus(\control, index: 331, numChannels: 1, server: ~server2);
		~pitch2bus2 = Bus(\control, index: 332, numChannels: 1, server: ~server2);
		~specCentroid2 = Bus(\control, index: 333, numChannels: 1, server: ~server2);
		~specFlatness2 = Bus(\control, index: 334, numChannels: 1, server: ~server2);
		~fftbus2 = Bus(\control, index: 335, numChannels: ~fftbuffersize2, server: ~server2);
	});

	// A relancer si ~numChannels change
	SynthDef(\avTrk, {|in= 0, t_trig= 0, amp= 1, bus|
		var input = In.ar(in, ~numChannels);
		var z= Mix(input*amp);
		// var chain= FFT(~fftbuffer, z);
		var chain= FFT(LocalBuf(~fftbuffersize), z);
		Array.fill(~fftbuffersize2, {|i|
			var a= Unpack1FFT(chain, ~fftbuffersize, i);
			var d= Demand.kr(chain>=0 /*Impulse.kr(31)*/ , 0, a); // ???
			Out.kr(bus+i, d.min(1));
		});
	}).add/*load*/;

	SynthDef(\avLoudPitchSpectre, {|in= 0, t_trig= 0, amp= 1, busA, busP1, busP2, busC, busF |
		var input = In.ar(in, ~numChannels);
		var z= Mix(input*amp);
		// var chain= FFT(~fftbuffer, z);
		var chain= FFT(LocalBuf(~fftbuffersize), z); // 1024 FFT for sampling rates of 44.1/48K -> Loudness
		var chain2= FFT(LocalBuf(~fftbuffersize), z); // 1024 or 2048 FFT for other analyses
		var qitch = Qitch.kr(z, ~qitchBuffer); // sur 2048 - PITCH // Différence avec Loudness
		Out.kr(busA, Loudness.kr(chain)); // LOUDNESS
		Out.kr(busP1, qitch[0]); // PITCH
		Out.kr(busP2, qitch[1]); // PITCH
		Out.kr(busC, SpecCentroid.kr(chain2)); // SPECTRAL CENTROID
		Out.kr(busF, SpecFlatness.kr(chain2)); // SPECTRAL FLATNESS
	}).add/*load*/;

	s.sync;

	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus]);
	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus], target: s.defaultGroup, addAction: \addAfter);
	//~ffttrk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, ~fftbus], target: 1000, addAction: \addBefore);
	~ffttrk = Synth(\avTrk, [\in, 0, \amp, 0.3 /*1*/, \bus, ~fftbus], target: RootNode(~server1), addAction: \addToTail); // Pourquoi amp de 0.3 ???

	// s.sendBundle(0.2, ["/s_new", "default", x = s.nextNodeID, 0, 1], ["/n_set", x, "freq", 500]);
	// s.sendMsg("/s_new", "default", -1, 0, 0);
	// a = play{var a=SinOsc;Splay.ar(a.ar(PulseCount.ar(f=InFeedback.ar(0,2).sum)%999+(60,63.0005..99)*a.ar(2**f)*2+[3,4],f>0*f*9)).tanh*MouseX.kr(0, 1)};

	~loudtrk = Synth(\avLoudPitchSpectre, [\in, 0, \amp, 1.0, \busA, ~loudbus, \busP1, ~pitch1bus, \busP2, ~pitch2bus, \busC, ~specCentroid, \busF, ~specFlatness], target: RootNode(~server1), addAction: \addToTail);

	if (~server2.notNil, {
		~ffttrk2 = Synth(\avTrk, [\in, 0, \amp, 0.3 /*1*/, \bus, ~fftbus2], target: RootNode(~server2), addAction: \addToTail);
		~loudtrk2 = Synth(\avLoudPitchSpectre, [\in, 0, \amp, 1.0, \busA, ~loudbus2, \busP1, ~pitch1bus2, \busP2, ~pitch2bus2, \busC, ~specCentroid2, \busF, ~specFlatness2], target: RootNode(~server2), addAction: \addToTail);
	});

	~fftroutine = Routine({
		inf.do{

			var fftArray = ~fftbus.getnSynchronous(~fftbuffersize2);
			var loudness = ~loudbus.getSynchronous;
			var pitch1 = ~pitch1bus.getSynchronous;
			var pitch2 = ~pitch2bus.getSynchronous.asInteger;
			var specCentroid = ~specCentroid.getSynchronous;
			var specFlatness = ~specFlatness.getSynchronous;

			if (~server2.notNil, {
				var fftArray2 = ~fftbus2.getnSynchronous(~fftbuffersize2);
				var loudness2 = ~loudbus2.getSynchronous;
				var pitch12 = ~pitch1bus2.getSynchronous;
				var pitch22 = ~pitch2bus2.getSynchronous.asInteger;
				var specCentroid2 = ~specCentroid2.getSynchronous;
				var specFlatness2 = ~specFlatness2.getSynchronous;

				~processingAddress.sendMsg(\fftArray2, *fftArray2);  //sending 1024 values
				~processingAddress.sendMsg(\loud2, loudness2);
				~processingAddress.sendMsg(\pitch2, pitch12, pitch22);
				~processingAddress.sendMsg(\specCentroid2, specCentroid2);
				~processingAddress.sendMsg(\specFlatness2, specFlatness2);
			});

			~processingAddress.sendMsg(\fftArray, *fftArray);  //sending 1024 values
			~processingAddress.sendMsg(\loud, loudness);
			~processingAddress.sendMsg(\pitch, pitch1, pitch2);
			~processingAddress.sendMsg(\specCentroid, specCentroid);
			~processingAddress.sendMsg(\specFlatness, specFlatness);

			// ~loudbus.get; // Pourquoi donnéee de 0 à + de 100, alors que les données en sones ne devraient aller que jusqu'à 64 ???

			(1/61).wait;  // a tiny bit faster than framerate - pas d'impact CPU sur le server si réduit de moitié ????????? -> plutôt sur le CPU langage
		};
	});

	~fftroutine.play;

	CmdPeriod.doOnce({
		(
			// ~fftbuffer.free;
			~fftbus.free; ~loudbus.free; ~pitch1bus.free; ~pitch2bus.free; ~specCentroid.free; ~specFlatness.free; // Bus
			~ffttrk.free; ~loudtrk.free; // Synth
			~fftroutine.stop; // Routine
			if (~server2.notNil, {
				~fftbus2.free; ~loudbus2.free; ~pitch1bus2.free; ~pitch2bus2.free; ~specCentroid2.free; ~specFlatness2.free; // Bus
				~ffttrk2.free; ~loudtrk2.free; // Synth
			});
		)
	});

};
)





// Synth examples for sound data and feature extraction

( // tracking amplitude
{   var sound = SinOsc.ar(mul:LFNoise2.kr(1).range(0,1)); // source
	RunningSum.rms(sound,100).poll(label:'rms'); // rms
	Amplitude.kr(sound).poll(label:'peak'); // peak
	Peak.kr(sound, Impulse.kr(1)).poll(label:'peak_trig'); // peak when triggered
	PeakFollower.kr(sound).poll(label:'peak_dec'); // peak with decay
	RunningMin.kr(sound).poll(label:'min'); // minimum
	RunningMax.kr(sound).poll(label:'max'); // maximum
	Out.ar(0,sound); // write to output
}.play;
)

( // track loudness
{   var sound, loudness;
	sound = SinOsc.ar(LFNoise2.ar(1).range(100,10000), mul:LFNoise0.ar(1).range(0,1)); // source
	loudness = FFT(LocalBuf(1024),sound); // sampling rates of 44.1/48K
	// loudness = FFT(LocalBuf(1024),sound); // sampling rates of 88.2/96K
	loudness = Loudness.kr(loudness).poll(label:\loudness);
	Out.ar(0, sound);
}.play;
)

( // frequency tracking
var qitchBuffer = Buffer.read(Server.default,/*"/Users/Xon77/Library/Application Support/SuperCollider/Extensions/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav"*/ "/Users/Xon77/sc3-plugins/build36/build_osx/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav"); // path to auxiliary wav file for Qitch
{   // a complex signal
	var sound = Saw.ar(LFNoise2.ar(1).range(500,1000).poll(label:\ActualFrequency)) + WhiteNoise.ar(0.4);
	ZeroCrossing.ar(sound).poll(label:\ZeroCross);
	Pitch.kr(sound).poll(label:\Pitch);
	Tartini.kr(sound).poll(label:\Tartini);
	Qitch.kr(sound,qitchBuffer).poll(label:\Qitch);
	Out.ar(0,sound!2);
}.play;
)

( // feature extraction
{   var sound = SinOsc.ar(240,mul:0.5)
	+ Resonz.ar(ClipNoise.ar,2000,0.6,mul:SinOsc.kr(0.05).range(0,0.5))
	+ Saw.ar(2000,mul:SinOsc.kr(0.1).range(0,0.3));
	var fft = FFT(LocalBuf(2048),sound);  // a complex signal
	SpecCentroid.kr(fft).poll(label:\Centroid);
	SpecFlatness.kr(fft).poll(label:\Flatness);
	SpecPcile.kr(fft,0.8).poll(label:\Percentile);
	FFTCrest.kr(fft,1800,2200).poll(label:\Crest);
	SensoryDissonance.kr(fft).poll(label:\Dissonance);
	Out.ar(0,sound!2);
}.play;
)

// see also FFTSpread


