// Configuration Initialisation Live4Life XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
"_0B_Init_Config.scd".loadRelative;


// INIT BUFFERS & SYNTHS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ~loadPhrases.(\serverP, \LocalP, 57114); ~fx16Split = 0; // Just for my performance setup to launch a specific server for specific synths and sentences

// 1st Server
~loadServer.(\server1, \Local1, 0, 57111); // Server name -> ~server1 // tested in real context with 32 loudspeakers, but multichannel FX or synths may lack CPU above 16 channels
~initBuffersSynths.(\server1, 0); // Initialisation check when the server is loaded with synths and buffers

// 2nd Server
~loadServer.(\server2, \Local2, 1, 57112); // Server name -> ~server2
~initBuffersSynths.(\server2, 1); // I observed in the past errors and probable crash from the second server if the computer is not plugged into an AC power source

// Another model with 2 main and 2 FX servers with Jack - currently abandonned
// ~loadServer.(\server1, \Local1, 0, 57110, \serverFX1, \LocalFX1, 57111); // Server names -> [~server1, ~serverFX1] // limited to 32 output channels via Jack ?
// ~loadServer.(\server2, \Local2, 1, 57112, \serverFX2, \LocalFX2, 57113); // Server names -> [~server2, ~serverFX2]


// Lemur OSC Connection - if you have the Lemur App, set the Lemur IP provided in the settings of the Lemur App - you can use up to 2 tactile tablets
~lemurConnected1 = 1; ~lemurAdress1 = NetAddr( "192.168.2.2", 8000);
~lemurConnected2 = 1; ~lemurAdress2 = NetAddr( "192.168.1.11", 8000);
~lemurConnected1 = 0; ~lemurAdress1 = nil; ~lemurConnected2 = 0; ~lemurAdress2 = nil;


// INIT GUI (Server 1 until track 2 and Server 2 from track 3) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~nbOfControlBus = 6; ~serverTrackSwitch = 2; /*"_2_Init_GUI_224.scd".loadRelative;*/ "_2_Init_GUI_225.scd".loadRelative;


// Initialisation check of FX synths - not compulsory
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server1, 0) }, { ~initFXSynthDefs.(\serverFX1, 0) } );
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server2, 1) }, { ~initFXSynthDefs.(\serverFX2, 1) } );





// Info on SCsynth servers
~server1.queryAllNodes;
~server2.queryAllNodes;
~server1.numSynthDefs.postln; ~server2.numSynthDefs;
~serverVolume[0].freeSynth;

// Info on size of sound folders
~listingSoundFolders = ("du -m -L" + ~soundsFolder +" | sort -nr").unixCmdGetStdOut; // lists the size of sound folders
("open" + ~soundsFolder).unixCmdGetStdOut; // opens the sound folder in Finder
("open" + PathName(thisProcess.nowExecutingPath).pathOnly).unixCmdGetStdOut; // opens the folder to execute the files and presets in Finder





// Prepare the recordings for each of both servers on your Desktop - Change the recording file name and path accordingly
(
~recordingFileName = "Record"; // Change accordingly your recording file name
~recordingPath = "/Users/xon/Desktop"; // Change accordingly your recording path
// If you want to record in the SuperCollider specific recording folder, put instead of the string this code in your recording path: thisProcess.platform.recordingsDir

~recordingDate = Date.getDate; ~recordingDate = ~recordingDate.stamp;
~recordingPathFile1 = ~recordingPath ++ "/" ++ ~recordingFileName ++ "_" ++ ~recordingDate ++ "-S1" ++ ".wav";
if (File.exists(~recordingPathFile1), { ~recordingPathFile1 = ~recordingPath ++ "/" ++ ~recordingFileName ++ "_" ++ ~recordingDate ++ "-S1" ++ ".wav"; });
currentEnvironment[\server1].prepareForRecord(~recordingPathFile1); ~recordingPathFile1.postln;
if (~server2.notNil, {
	~recordingPathFile2 = ~recordingPath ++ "/" ++ ~recordingFileName ++ "_" ++ ~recordingDate ++ "-S2" ++ ".wav";
	if (File.exists(~recordingPathFile2), { ~recordingPathFile2 = ~recordingPath ++ "/" ++ ~recordingFileName ++ "_" ++ ~recordingDate ++ "-S2" ++ ".wav"; });
	currentEnvironment[\server2].prepareForRecord(~recordingPathFile2);
});
)

// Start the recordings
Server.default = currentEnvironment[\server1]; currentEnvironment[\server1].record; Server.default = currentEnvironment[\server2]; currentEnvironment[\server2].record;

// Stop the recordings
currentEnvironment[\server1].stopRecording; currentEnvironment[\server2].stopRecording; Server.default = currentEnvironment[\server1];

// If you want to change the maximum amplitude of the limiter
~ampLimiter = -7.dbamp; ~nbOfServers.do { |s| ~limiter[s].set(\ampLimit, ~ampLimiter); }










// Extra Tidal TO DO AND TEST
// Example for loading SuperDirt TidalCycles if you also want to use TidalCycles on main Server s - To synchronise
(if (~mainServer1Window == 1, {
	SynthDef.synthDefDir = Platform.userAppSupportDir ++ "/synthdefs"; "SC_SYNTHDEF_PATH".setenv(SynthDef.synthDefDir.standardizePath);
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
	s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware input channel size, if necessary
	s.options.maxSynthDefs = 1000;
	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
		~dirt.loadSoundFiles; // load samples (path containing a wildcard can be passed in)
		s.sync; // wait for samples to be read
		~dirt.start(57120, [0, 0]); // start listening on port 57120, create two orbits, each sending audio to channel 0. You can direct sounds to the orbits from tidal e.g. by: `# orbit "0 1 1"
		// ~toTempo = 2; // in Live4Life
		// ~gblTempo = TempoClock(2, queueSize: 8192).permanent_(true);
	};
})
)

// To synchronise TidalCycles with SC
// https://club.tidalcycles.org/t/synchronising-tidal-with-volca-sequencer/2680/6
(
var quant = /*1.0*/ 2; // ~quant;
~dirt.receiveAction = { |e|
	var cycle = e[\cycle];
	var cps = e[\cps];
	var latency = e[\latency];
	cycle !? {
		if(cycle % quant == 0) { // set clock only quant in cycle
			/*TempoClock.default*/ ~gblTempo.beats = cycle; // ~gblTempo.beats
		};
	};
	cps !? {
		/*TempoClock.default*/ ~gblTempo.tempo = cps;
	};
	latency !? {
		// ~server1.latency
		/*Server.default*/ s.latency = latency;
		~server1.latency = latency;
		if (~server2.notNil, {~server2.latency = latency});
	}
}
);

~dirt.receiveAction = { |e| e.postln; };

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




