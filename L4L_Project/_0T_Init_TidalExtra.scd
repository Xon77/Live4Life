// Extra TidalCycles Personal configuration - with SuperDirt / SuperDirtMixer / TidalLooper / mi-ugens synthDefs
// Example for loading SuperDirt TidalCycles if you also want to use TidalCycles on main Server s
// -> ~mainServer1Window sould be put at 0 in the file "_0B_Init_Config"
// Synchronization via Ableton Link

(if (~mainServer1Window == 1 or: {~server1.isNil}, {

	~tidalsoundsFolder = "/Users/xon/Documents/Projets/SC_LFL/Live4LifeProjects/TechnoMachineS/_Sounds2024A/";
	~tidalNumchannels = 32;

	SynthDef.synthDefDir = Platform.userAppSupportDir ++ "/synthdefs"; "SC_SYNTHDEF_PATH".setenv(SynthDef.synthDefDir.standardizePath);
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
	s.options.memSize = /*8192 * 256*/ (2.pow(20)); // increase this if you get "alloc failed" messages
	s.options.maxNodes = /*1024 * 256*/ (8192*500); // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numWireBufs = 2.pow(10);
	s.options.numOutputBusChannels = ~tidalNumchannels; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware input channel size, if necessary
	s.options.maxSynthDefs = 10000;
	s.options.hardwareBufferSize = 128 /*~hardwareBufferSize*/;

	(
		// Multiband compression (Soundgoodizer A copycat for SuperCollider)
		// https://club.tidalcycles.org/t/multiband-compression-soundgoodizer-a-copycat-for-supercollider/4167
		// "This SynthDef is highly inspired by Image-Line's Soundgoodizer from FL Studio, specifically the preset A. It's not a 1:1 replica at all. That would involve some soft saturation which SuperCollider doesn't provide. And I wanted to keep this as vanilla as possible. But it works quite well on a master bus.
		// It can be useful to have this kind of processes applied to SuperDirt's final output. For some genres it will work well, yet it will totally destroy dynamics the higher the wetness. This is why I'd only recommend using it when streaming or at a venue."

		~midside = {|in, msBalance=0|
			var sig = Balance2.ar(in[0] + in[1], in[0] - in[1], msBalance);
			[sig[0] + sig[1], sig[0] - sig[1]] * sqrt ( (msBalance.max(0)+1)/2 )
		};

		SynthDef.new(\soundgood, {
			| out=0, in=0, wet=0.35, makeup=0.98 |
			var lfreq = 250, hfreq = 3000, q = 1.1;
			var dry, low, mid, high, master;
			var att = 2/1000;
			var lrel = 137/1000, lpre = dbamp(5*wet), lpos = dbamp(5.9*wet), lexp = 0.07*wet, lstereo = -1*wet;
			var mrel = 85/1000, mpre = dbamp(6*wet), mpos = 1, mstereo = 0.38*wet;
			var hrel = 75/1000, hpre = dbamp(6.8*wet), hpos = dbamp(2.9*wet), hexp = 0.14*wet, hstereo = 0.2, hsat = 1/16*wet;
			var output;

			dry = In.ar(in,2);
			dry = BHiPass4.ar(dry,20);

			low = BLowPass4.ar(dry,lfreq,q);
			mid = BHiPass4.ar(dry,lfreq,q); mid = BLowPass4.ar(mid,hfreq,q);
			high = BHiPass4.ar(dry,hfreq,q);

			low = CompanderD.ar(low*lpre,1,1+lexp,10,att,lrel,lpos);
			low = ~midside.(low, lstereo);
			low = SineShaper.ar(low);

			mid = CompanderD.ar(mid*mpre,1,1,10,att,lrel,mpos);
			mid = ~midside.(mid, mstereo);

			high = CompanderD.ar(high*hpre,1,1+hexp,10,att,hrel,hpos);
			high = ~midside.(high, hstereo);
			high = SineShaper.ar(high,hpos-(hpos*hsat));

			master = Limiter.ar(Mix.new([low,mid,high]),0.99,0.01)*makeup;

			Out.ar(out, master);
		}).add;
	);

	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt = SuperDirt(~tidalNumchannels, s); // two output channels, increase if you want to pan across more channels

		// ~dirt.loadSoundFiles; // load samples (path containing a wildcard can be passed in)
		~dirt.loadSoundFiles("/Users/xon/Documents/Projets/SC_LFL/Live4LifeProjects/TechnoMachineS/_Sounds2024A/*");
		// ~drumMachinesDir = Quarks.all.detect({ |x| x.name == "tidal-drum-machines" }).localPath; // Quarks.install("https://github.com/geikha/tidal-drum-machines.git");
		// ~dirt.loadSoundFiles(~drumMachinesDir +/+ "machines" +/+ "*" +/+ "*", namingFunction: { |x| x.basename.replace("-","")});

		load("/Users/xon/Desktop/Livecoding/Tidal/TSamplesOfMachines/mi-ugens.scd"); // exception in GraphDef_Recv: UGen 'MiRipples' not installed ?
		s.sync; // wait for samples to be read

		/*~mainbus = Bus.audio(s,2);
		~compress = Synth(\soundgood,[\in, ~mainbus]);
		s.sync;*/ // need to wait again?

		~dirt.start(57120, 0 ! 8); // start listening on port 57120, create 8 orbits, each sending audio to channel 0. You can direct sounds to the orbits from tidal e.g. by: `# orbit "0 1 1"
		// in Live4Life // ~gblTempo = /*Tempo*/ LinkClock(2, queueSize: 8192).permanent_(true);
		// s.latency = 0.2;

		/*~dirt.orbits.do { |x|
		var clouds = GlobalDirtEffect(\global_mi_clouds, [\cloudspitch, \cloudspos, \cloudssize, \cloudsdens, \cloudstex, \cloudswet, \cloudsgain, \cloudsspread, \cloudsrvb, \cloudsfb, \cloudsfreeze, \cloudsmode, \cloudslofi]);
		var verb = GlobalDirtEffect(\global_mi_verb, [\verbwet, \verbtime, \verbdamp, \verbhp, \verbfreeze, \verbdiff, \verbgain]);
		x.globalEffects = x.globalEffects
		.addFirst(clouds)
		.addFirst(verb);
		x.initNodeTree;
		};*/

		/*
		~looper = TidalLooper(~dirt); // Initialize Tidal Looper // https://github.com/thgrund/tidal-looper for examples
		// You can adjust these parameter even in runtime
		~looper.rLevel = 1.5;
		~looper.pLevel = 0.8;
		~looper.linput = 0; // Set this to your main input port.
		~looper.lname = "mybuf";
		*/
		// Execute the following code in Tidal - to put in Boot.hs?
		// linput = pI "linput"
		// lname = pS "lname"

		// Initialize the SuperDirtMixer
		~tidalMixer = SuperDirtMixerCL(~dirt, 6010);
		// You can adjust parameters before you use the ui
		~tidalMixer.orbitLabels = ["one", "two", "3", "4", "5", "6", "7", "8"];
		// ["d1 - Lead", "d2 - Bass", "d3 - Key", "d4 - Pad", "d5 - Arp", "d6 - Drums", "d7 - Rhytm Git", "d8 - Lead Git", "d9 - Strings", "d10 - FX", "d11 - Kick", "d12 - Cymbals", "d13 - Snare", "d14 - Toms"];
		~tidalMixer.enableMasterPeakRMS(0);

		~superDirtOSC = NetAddr.new("127.0.0.1", 57120);
		~tidalNetAddr = ~tidalMixer.tidalNetAddr; // NetAddr.new("127.0.0.1", 6010);
		// ~tidalMixer.gui; // Opens Mixer GUI // Possible to resize the GUI a little bit to be able to reduce on the horizontal side ?

		if (~tidalNumchannels != 32, {

			( // Réverb Custom VST
				~dirtNumChannels = ~dirt.numChannels;

				// This is VST Plugin synthdef example for a global reverb fx
				SynthDef(\valhalla2, {|out|
					var size = 14; // This value needs to be hard coded and means that it works for 14 orbits.
					var dryBusses = NamedControl.kr(\dryBusses, (0 ! size ));
					var wetReverbs = NamedControl.kr(\wetReverbs, (0 ! size)); // Contains the amount of dry/wet for each orbit. Value is between 0 and 1.
					var fxSound = size.collect({arg i; In.ar(dryBusses[i], ~dirtNumChannels) * wetReverbs[i]}).sum;

					fxSound = VSTPlugin.ar(fxSound, numOut: ~dirtNumChannels, id: \valhalla);

					// out should be a global fx bus for reverb.
					// With this you could add more of these fx busses without affecting other audio busses.
					Out.ar(out ,fxSound);
				}).add;

				SynthDef(\masterSynth, { |out, fxBus|
					var size = 8; // This value needs to be hard coded and means that it works for 8 orbits.
					var wetSound = In.ar(fxBus, ~dirtNumChannels);
					var dryBusses = NamedControl.kr(\dryBusses, (0 ! size ));
					var wetSums = NamedControl.kr(\wetSums, (0 ! size));

					// Reduces the dry bus gain logarithmically for each orbit based on the
					// global fx amount.
					var drySound = size.collect({
						arg i;
						ReplaceOut.ar (dryBusses[i], In.ar(dryBusses[i], ~dirtNumChannels) * (1/(wetSums[i] +1) ));
					});

					// Route the global fx bus to i.e. hardware output
					Out.ar(out, wetSound);
				}).add;
			);

			s.sync;

			(
				~tidalMasterBus = Bus.new; // Usually this is the output of your sound card (it returns the first bus 0)
				~tidalGlobalReverbBus = Bus.audio(~dirt.server, ~dirtNumChannels);
				~tidalWetReverbs = Array.fill(~dirt.orbits.size, 0);
				~tidalWetSums = Array.fill(~dirt.orbits.size, 0);
				~tidalDryBusses = ~dirt.orbits.collect({arg item; item.dryBus});
				~tidalGlobalFXBusses = ~dirt.orbits.collect({arg item; item.globalEffectBus});

				// Initilaize the reverb synth
				// Ensure that this Synth be played at the end of the Synth group
				~valhallaSynth = Synth(\valhalla2, [
					\out, ~tidalGlobalReverbBus,
					id: \valhalla
				], addAction: 'addToTail');

				// Namedcontrol to set all the dryBusses for the global fx synth
				~valhallaSynth.set(\dryBusses, ~tidalDryBusses);

				// Link synth with vst plugin and load it
				~valhalla = VSTPluginController(~valhallaSynth, id: \valhalla);
				~valhalla.open("ValhallaSupermassive.vst3");

				// Test the settings and play around with them
				{~valhalla.editor}.defer(1);

				// The master synth routes the content of the fxBus to an out bus
				// i.e. the hardware output
				~masterSynth = Synth(\masterSynth, [
					\out, ~tidalMasterBus,
					\fxBus, ~tidalGlobalReverbBus,
				], addAction: 'addToTail');

				~masterSynth.set(\dryBusses, ~tidalDryBusses);
				~masterSynth.set(\globalFXBusses, ~tidalGlobalFXBusses);

				// Fix this to swich between VST and Native FX
				~dirt.receiveAction = { |event|
					var e = event.copy;
					var orbit = ~dirt.orbits[e.at(\orbit)];
					var reverb = e.at(\reverb) ?? orbit.defaultParentEvent.at(\reverb) ?? 0;
					var room = e.at(\room) ?? orbit.defaultParentEvent.at(\room) ?? 0;

					var wet = reverb + room;

					~tidalWetReverbs.put(orbit.orbitIndex, reverb);
					~tidalWetSums.put(orbit.orbitIndex, wet);

					~valhallaSynth.set(\wetReverbs, ~tidalWetReverbs);
					~masterSynth.set(\wetSums, ~tidalWetSums);
				};
			);
		});

		"_Init Midi X.scd".loadRelative;
		~tidalMixer.gui;
	};
})
)


~tidalFreqScope.kill; ~tidalMixer.stopEQEffect; ~tidalWindow.close; ~dirt.free; s.quit;

~dirt.orbits[0].globalEffects[0].synth



~dirt.orbits[0].group
Group
Node
queryTree


(
s.options.memSize = /*8192 * 256*/ (2.pow(20));
s.waitForBoot {
	~dirt = SuperDirt(2, s);
	~dirt.start(57120, 0 ! 14);
	// More SuperDirt ...
	~dirt.loadSoundFiles;
	// Initialize the SuperDirtMixer
	~mixer = SuperDirtMixer(~dirt, 6010);

	// You can adjust parameters before you use the ui
	// ~mixer.orbitLabels = ["d1 - Lead", "d2 - Bass", "d3 - Key", "d4 - Pad"];
	~mixer.enableMasterPeakRMS(0)
}
)
~mixer.gui


(
s.options.memSize = /*8192 * 256*/ (2.pow(20));
s.waitForBoot {
	~dirt = SuperDirt(2, s);
	~dirt.start(57120, 0 ! 8);
	// More SuperDirt ...

	// Initialize the SuperDirtMixer
	~tidalMixer = SuperDirtMixer(~dirt, 6010);

	// You can adjust parameters before you use the ui
	~tidalMixer.orbitLabels = ["d1 - Lead", "d2 - Bass", "d3 - Key", "d4 - Pad", "d5 - Arp", "d6 - Drums", "d7 - Rhytm Git", "d8 - Lead Git", "d9 - Strings", "d10 - FX", "d11 - Kick", "d12 - Cymbals", "d13 - Snare", "d14 - Toms"];
	~tidalMixer.enableMasterPeakRMS(0)
}
)

~tidalMixer.gui;
~tidalWindow
Server.killAll

~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 0, 1); // Orbit + 0 // Track 1
~superDirtOSC.sendMsg("/SuperDirtMixer/pan", 0, 1.0.rand);
~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, 1.0.rand);
~superDirtOSC.sendMsg("/SuperDirtMixer/loadPreset", "Default.json");
~superDirtOSC.sendMsg("/SuperDirtMixer/loadPreset", "Preset2.json");
~superDirtOSC.sendMsg("/SuperDirtMixer/loadPreset", "Preset3.json");
~superDirtOSC.sendMsg("/SuperDirtMixer/loadPreset", "Preset4.json");

~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 0, 73+50.rand);

~superDirtOSC.sendMsg("/SuperDirtMixer/trackS", "1");
~superDirtOSC.sendMsg("/SuperDirtMixer/trackI", 0);
~superDirtOSC.sendMsg("/SuperDirtMixer/trackS", "2");
~superDirtOSC.sendMsg("/SuperDirtMixer/trackI", 1);

~tidalMixer.setEQuiValues(\loShelfGain, 10);
~tidalMixer.presetPath
~tidalMixer.savePreset("Preset5.json");

~tidalNetAddr.sendMsg("/mute", 1); // Orbit + 1 // Track 1
~tidalNetAddr.sendMsg("/unmute", 1);
~tidalNetAddr.sendMsg("/solo", 1);
~tidalNetAddr.sendMsg("/unsolo", 1);
~tidalNetAddr.sendMsg("/muteAll");
~tidalNetAddr.sendMsg("/unmuteAll");

~tidalMixer.setReverbNativeSize(0);
~tidalMixer.setReverbNativeSize(0.8);
~tidalMixer.setReverbNativeSize(0.95); // reverbNativeSize Default = 0.95
~tidalMixer.setReverbVariableName(\reverb); // Custom VST XXX
~tidalMixer.setReverbVariableName(\room); // Native Reverb



/*
~valhalla.numPrograms; // 0 ?
~valhalla.program;
~valhalla.preset; // nil ?
~valhalla.loadPreset((\name: "Vger", \path: "/SFX/Pulsars/Vger", \type: \userFactory)); // ?
~valhalla.getProgramData({ arg data; ~d = data.cs.postln;}); // ?
*/

~valhalla.numParameters; // 18
~valhalla.set(0, 1.0.rand.postln); // 0 - Mix
~valhalla.set(1, 1); // 1 - Tempo subdivision (0.3: Msec - 0.5: Note - 0.8: Dotted - 1: Dotted)
~valhalla.set(2, 1.0.rand.postln); // 2 - Delay
~valhalla.set(3, 1.0.rand.postln); // 3 Delay ???
~valhalla.set(4, 1.0.rand.postln); // 4 - Warp
~valhalla.set(5, 1); // 5 - Clear (1 ou 0)
~valhalla.set(6, 1.0.rand.postln); // 6 - Feedback
~valhalla.set(7, 1.0.rand.postln); // 7 - Density
~valhalla.set(8, 1.0.rand.postln); // 8 - Width
~valhalla.set(9, 1.0.rand.postln); // 9 - Low
~valhalla.set(10, 1.0.rand.postln); // 10 - High
~valhalla.set(11, 1.0.rand.postln); // 11 - Mod Rate
~valhalla.set(12, 1.0.rand.postln); // 12 - Mod Depth
~valhalla.set(13, 1.0.rand.postln); // 13 - Mode (to define...)

~valhalla.info.printPresets;
~valhalla.set(0, 1.0.rand.postln);
~valhalla.getn(action: {arg p; ~valhallaPreset = p.postln;});
~valhalla.setn(0, ~valhallaPreset);
~valhalla.setn(0, Array.fill(18, {1.0.rand}) );

/*
~valhalla.savePreset("V_Vger");
~valhalla.savePreset("V_TheVoid");
~valhalla.savePreset("V_WeAreStardust");
~valhalla.savePreset("V_HorseHead");
~valhalla.savePreset("V_16NoteSentry");
~valhalla.savePreset("V_16NoteSentry2");
~valhalla.savePreset("V_Planetarium");
~valhalla.savePreset("V_DarkHorse");
~valhalla.savePreset("V_Dotted8Orbits");
~valhalla.savePreset("V_CirrusMajorSynthEchoes");
~valhalla.savePreset("V_Reverse8Note");
~valhalla.savePreset("V_LibraRising");
~valhalla.savePreset("V_LibraNebula");
~valhalla.savePreset("V_LibraHall");
~valhalla.savePreset("V_LibraBloom");
~valhalla.savePreset("V_DarkLibraPlate");
~valhalla.savePreset("V_LostSaucer");
~valhalla.savePreset("V_SlowAttackEnsemble");
~valhalla.savePreset("V_ScorpioRising");
*/
~valhalla.loadPreset("V_Vger");
~valhalla.loadPreset("V_16NoteSentry");
~valhalla.loadPreset("V_Vger");
~valhalla.loadPreset("V_16NoteSentry");
~valhalla.loadPreset("V_Vger");
~valhalla.loadPreset("V_16NoteSentry2");

~valhalla.loadPreset("V_LibraNebula");
~valhalla.loadPreset("V_LibraRising");
~valhalla.loadPreset("V_LibraHall");
~valhalla.loadPreset("V_DarkLibraPlate");
~valhalla.loadPreset("V_LibraBloom");
~valhalla.loadPreset("V_LostSaucer");
~valhalla.loadPreset("V_SlowAttackEnsemble");
~valhalla.loadPreset("V_ScorpioRising");

~valhalla.loadPreset("V_DarkHorse");
~valhalla.loadPreset("V_HorseHead");

~valhalla.loadPreset("V_Dotted8Orbits");
~valhalla.loadPreset("V_Reverse8Note");
~valhalla.loadPreset("V_CirrusMajorSynthEchoes");
~valhalla.loadPreset("V_Planetarium");
~valhalla.loadPreset("V_TheVoid");
~valhalla.loadPreset("V_WeAreStardust");







~compress.free; // Compressor deleted
~compress = Synth.tail(s, \soundgood); // Compressor ON
~compress.set(\wet, 0.8);
~compress.set(\wet, 0.34);
~compress.set(\wet, 0.1);
~compress.set(\makeup, 0.98);





// To evaluate lines of code via OSC - To connect via MIDI with XoneK2 - DJ Livecoding
t = NetAddr.new("127.0.0.1", 3333);
t.sendMsg("/pulsar/eval", \type, 'multi_line', 'tab', 3, 'row', 17, \column, 1);
t.sendMsg("/pulsar/eval", \type, 'line', 'tab', 4, \row, 69, \column, 1);
t.sendMsg("/pulsar/eval", \type, 'line', 'tab', 4, \row, 31, \column, 1);





// To post info about event arguments
(
~dirt.addModule('post',
	{ |dirtEvent|
		"\n------------\n".post;
		dirtEvent.event.pairsDo { |key, val, i|
			"%: % ".format(key, val).post;
			if(i % 4 == 0) { "\n".post };
		}
});
)

// remove it again:
~dirt.removeModule(\post);





SuperDirt.predefinedSynthParameters;
SuperDirt.tidalParameterString;

SuperDirt.postTidalParameters([\default, \supercomparator]);
~dirt.postSampleInfo;





~dirt.orbits[0].set(\amp, 0.1); // reduce the amplitude of one orbit
~dirt.orbits[0].freeSynths


// make a mixer for the orbits, using dB scaling
(
var w, spec;
spec = \db.asSpec;
w = Window("orbital volume", Rect(240, 240, 300, 500)).front;

w.view.layout = HLayout(*~dirt.orbits.collect { |x|
	var val = spec.unmap(x.get(\amp).ampdb);
	Slider().value_(val).action_({ |v| x.set(\amp, spec.map(v.value).dbamp.postln) })
});
)




