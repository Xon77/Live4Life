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
~nbOfControlBus = 6; ~serverTrackSwitch = 2; "_2_Init_GUI_225.scd".loadRelative;


// Initialisation check of FX synths - not compulsory
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server1, 0) }, { ~initFXSynthDefs.(\serverFX1, 0) } );
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server2, 1) }, { ~initFXSynthDefs.(\serverFX2, 1) } );

// INIT PATTERN -> inserted in GUI - useful if you have stopped the language with Comd+.
// ~updateTime = 0.2 /*0.1*/; "_3_Init_Pattern_185.scd".loadRelative;





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
Server.default = currentEnvironment[\server1]; currentEnvironment[\server1].record; if (~server2.notNil, {Server.default = currentEnvironment[\server2]; currentEnvironment[\server2].record});

// Stop the recordings
currentEnvironment[\server1].stopRecording; if (~server2.notNil, {currentEnvironment[\server2].stopRecording; Server.default = currentEnvironment[\server1]});

// If you want to change the maximum amplitude of the limiter
~ampLimiter = -7.dbamp; ~nbOfServers.do { |s| ~limiter[s].set(\ampLimit, ~ampLimiter); }






