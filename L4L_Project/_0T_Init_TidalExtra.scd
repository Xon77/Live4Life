// Extra TidalCycles Personal configuration - with SuperSirt / SuperDirtMixer / TidalLooper / mi-ugens synthDefs
// Example for loading SuperDirt TidalCycles if you also want to use TidalCycles on main Server s
// ~mainServer1Window sould be put at 0 in the file "_0B_Init_Config"
// Synchronization via Ableton Link

(if (~mainServer1Window == 1 or: {~server1.isNil}, {

	SynthDef.synthDefDir = Platform.userAppSupportDir ++ "/synthdefs"; "SC_SYNTHDEF_PATH".setenv(SynthDef.synthDefDir.standardizePath);
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
	s.options.memSize = /*8192 * 256*/ (2.pow(21)); // increase this if you get "alloc failed" messages
	s.options.maxNodes = /*1024 * 256*/ (8192*5000); // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numWireBufs = 2.pow(10);
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware input channel size, if necessary
	s.options.maxSynthDefs = 10000;
	s.options.hardwareBufferSize = ~hardwareBufferSize;

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
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels

		~dirt.loadSoundFiles; // load samples (path containing a wildcard can be passed in)
		~dirt.loadSoundFiles("/Users/xon/Documents/Projets/SC_LFL/Live4LifeProjects/TechnoMachineS/_Sounds2024A/*");
		// ~drumMachinesDir = Quarks.all.detect({ |x| x.name == "tidal-drum-machines" }).localPath; // Quarks.install("https://github.com/geikha/tidal-drum-machines.git");
		// ~dirt.loadSoundFiles(~drumMachinesDir +/+ "machines" +/+ "*" +/+ "*", namingFunction: { |x| x.basename.replace("-","")});

		load("/Users/xon/Desktop/Livecoding/Tidal/TSamplesOfMachines/mi-ugens.scd"); // exception in GraphDef_Recv: UGen 'MiRipples' not installed?
		s.sync; // wait for samples to be read

		~mainbus = Bus.audio(s,2);
		~compress = Synth(\soundgood,[\in, ~mainbus]);
		s.sync;	// need to wait again?

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

		~looper = TidalLooper(~dirt); // Initialize Tidal Looper // https://github.com/thgrund/tidal-looper for examples
		 // You can adjust these parameter even in runtime
        ~looper.rLevel = 1.5;
        ~looper.pLevel = 0.8;
        ~looper.linput = 0; // Set this to your main input port.
        ~looper.lname = "mybuf";
		// Execute the following code in Tidal - to put in Boot.hs?
		// linput = pI "linput"
		// lname = pS "lname"

		// Initialize the SuperDirtMixer
		~mixer = SuperDirtMixer(~dirt, 6010);
		// You can adjust parameters before you use the ui
		~mixer.orbitLabels = ["d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8"];
		// ["d1 - Lead", "d2 - Bass", "d3 - Key", "d4 - Pad", "d5 - Arp", "d6 - Drums", "d7 - Rhytm Git", "d8 - Lead Git", "d9 - Strings", "d10 - FX", "d11 - Kick", "d12 - Cymbals", "d13 - Snare", "d14 - Toms"];
		~mixer.enableMasterPeakRMS(0);
	};
})
)

~mixer.gui; // Opens Mixer GUI // Possible to resize the GUI a little bit to be able to reduce on the horizontal side?

s.quit;

~compress.free; // Compressor deleted
~compress = Synth.tail(s, \soundgood); // Compressor ON
~compress.set(\wet, 0.5);





// To evaluate lines of code via OSC - To connect via MIDI with XoneK2 - DJ Livecoding
t = NetAddr.new("127.0.0.1", 3333);
t.sendMsg("/pulsar/eval", \type, 'multi_line', 'tab', 3, 'row', 17, \column, 1);
t.sendMsg("/pulsar/eval", \type, 'line', 'tab', 3, \row, 64, \column, 1);
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





SuperDirt.predefinedSynthParameters
SuperDirt.tidalParameterString

SuperDirt.postTidalParameters([\default, \supercomparator]);
~dirt.postSampleInfo;





~dirt.orbits[0].set(\amp, 0.1); // reduce the amplitude of one orbit

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




