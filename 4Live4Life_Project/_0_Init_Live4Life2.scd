
( // Initialisation Configuration Live4Life XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

~viaJACK = 0; // 0 without Jack - 1 with Jack

~soundIn = 0; // Sound Card Input Channel
~nbOfSeqs = 240 /*99*/ ; // Nb of sequences in a track
~foldersStructure = 1; // 1, if sound folders are formatted (e.g. IP Gong), otherwise 0
~defaultFolder = 0; // Buffer folder by default at initialisation

~recordMontage = 0; // 1 if you want to record GUI action

~synthDefsBuild = 0; // 1 to rebuild synthDefs - automatic rebuild if no synthDefs in Application Supprt
~synthDefsManagementChoose = 1; // 0 -> add - 1 -> load --- useful only if ~synthDefsBuild = 1

~initSeqOrPerfMode = 0; // Initialisation Mode Séquence = 0 - Performance = 1
~visualizeLevels = "ServerMeter"; /*"SpatioScope";*/ // "ServerMeter"; // -> ServerMeter requires a little bit more CPU - but more precise on levels // ~visualizeSpatioScope.value;
// But with a second server running, SpatioScope is less interesting because only on 1 server
~visualizeProcessing = 0; // Transfers data to Processing for visuals
~mainWindowScroll = false; // For smaller screen sizes in height

~trackXFadeDefault = 20; // Default value for Xfade for tracks (in beats, divide by 2 in seconds: if 120 BPM, then 20 = 10 sec.)
~hpModulation = 1; // Allows effects with parameter modulation between the loudspeakers
~mixAllFxDefault = 0; // Default value for mix of effects
~lagTimeAllFxDefault = 7 /* 4 */; // Default value for parameter lag of effects
~fadeTimeSynthFxDefault = 6 /*5*/ /*3*/; // Default value for Xfade time of effects
~fxMulVolume = 1.0; // For managing volumes when Xfading  effects in series or parallel - to tweak
~fxMul2Volume = 1.0; // Idem
~maxMulVolControllers = 0.7945 /*7*/ /*0.57*/ /*957*/; // for max main volume ~trackAllVolView -> à 1 = + 6dB / 0.5957 = -3dB
~fxCPUCheck = 1; // 1 -> allows to avoid change of effects (see preset[\fxSynth]==)" when changing presets too quickly (below FX xfade time) (now not implemented on FX INOUT...)
~maxSynthTime = 30 /*60*/; // Max. Duration in seconds for synth events
~keyBoardPerfProtect = 0; // 1 -> avoids to trigger some shortcuts too dangerous or uncontrollable in performance
~keyBoardPerfProtectFX = 1; // 1 -> avoids to trigger other shortcuts too dangerous or uncontrollable in performance (shift + ?) for random FX
~rtmMulMinProtect = 4; // Multiples the minimum level of Mul Slider for rhythm (adapts according to the number of events) to reach a minimal onset of 0.004 sec. à x1 (2 pour 0.008...)
~rhythmTracks = [4,5,6,7,3] /*[4,5,3]*/; // Identifies rhyhthm tracks (begins with 0)

// Path of Sound Folder XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~soundsFolder = "/Users/xon/Desktop/SoundFolder/";

// Spatial configuration (Nb of outputs and spatial distribution) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~numChannelsConfig = "2-MultiChannelSequencer"; // To get 8 seperated stereo tracks e.g. towards a sequencer - effets multi-canaux 16 pistes mono ?
~numChannelsConfig = "2-Performance"; // Mixage global donc utilisation d'effets stéréo seulement // ~ambATKConfig = "binaural" // "stereo"
~numChannelsConfig = "4";
~numChannelsConfig = "5-Clock"; // Clockwise from Centre = 0
~numChannelsConfig = "5-Centre"; // Clockwise from Links (except Centre = 3) - XXXXXXXXX
~numChannelsConfig = "7"; // Clockwise from Centre
~numChannelsConfig = "8-Centre"; // Clockwise from Centre
~numChannelsConfig = "8-PairClock"; // Clockwise from Links - XXXXXXXXX
~numChannelsConfig = "8-PairPair"; // Pairwise Links / Right - XXXXXXXXX
~numChannelsConfig = "16-PairClock"; // Clockwise from Links
~numChannelsConfig = "16-Dome-8-6-2-Pair"; // Pairwise Links / Right - XXXXXXXXX
~numChannelsConfig = "16-Dome-8-6-2-Clock"; // Clockwise from Links - Dome Hexa Université de Montréal (+ 2 Subs) XXXXXXXXX
~numChannelsConfig = "16-Dome-8-6-2-Clock-CC"; // IDEM (+ 4 Subs)
~numChannelsConfig = "22-8+Dome-8-4-2-Pair"; // Hall Claude Champagne Université de Montréal with 8 additional speakers in the Hall
~numChannelsConfig = "24-UsineC-3Octo"; // 3 circles of 8 speakers + Subs
~numChannelsConfig = "32-Dome-12-10-8-2"; // Clockwise from Links (+ 2 Subs) XXXXXXXXX
// ~numChannelsConfig = "32-Dome-12-10-8-2-Motu"; // Clockwise from right - Old Config Motu deprecated
// ~numChannelsConfig = "64-CentreClock"; // Test - Clockwise from Centre - not tested in real context
// ~numChannelsConfig = "96-CentreClock"; // Test - Clockwise from Centre - not tested in real context
// ~numChannelsConfig = "128-CentreClock"; // Test - Clockwise from Centre - not tested in real context

~numChannelsConfig = "16-Dome-8-6-2-Clock"; // This last line chooses spatial configuration form
~numChannelsConfig = "2-Performance";

// Sequence Preset file name XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetsFileName = "MyPresetFile.txt";
// ~presetsFileName2 = "MyPresetFile2.txt"; if you have 2 presets files

// Ambisonic Spatialisation
// Keep ~ambATKConfig at "binaural" if you have a headphone, or "stereo" if you have 2 speakers, otherwise ~ambATKConfig is "multiChannel" if more than 2 channels
if (~numChannelsConfig[0].digit == 2, { ~ambATKConfig = "stereo" /*"stereo" */}, { ~ambATKConfig = "multiChannel"});
~binauralDecoderName = "FoaDecoderKernel.newSpherical"; // newSpherical ou newCIPIC (44100.0 is not available for cipic kernel decoder)
~ambATKkFactor = 'velocity'; // 'dual' / 'velocity' - uniquement pour multicanal

/*
The default k ( 'single' ), for decoders accepting k as an argument, returns an 'energy' optimised (aka "max rE") decoder (see FoaDecoderMatrix).
'single' is suitable for larger, mid-scale environments.
'dual' returns a dual-band psychoacoustically optimised decoder.5 The 'dual' decoder is the optimum choice for small scale studio or domestic settings.
'velocity' returns "strict soundfield" (aka "basic") decoding, and is not preferred for first order Ambisonics in most circumstances.
'controlled' returns "controlled opposites" decoding (aka "in phase"), which is often preferred in large-scale, concert environments.
May be specified as a float: 0.5 to 1.0. Or more conviently by name :
'velocity'     1
'energy'       1/sqrt(2) = 0.70710678118655
'controlled'   1/2
For large-scale concert presentation, the authors advise auditioning values of k between 1/2 and 1/sqrt(2).
*/
// ~renderEncode.() & ~renderDecode.() // to execute again when changing decoder settings (e.g. binaural) and do not forget: FoaDecoderKernel.free; if binaural or stereo

~presetsTrajectoryFileName = "L4LPresetTrajectoryZArchive-1.txt"; // Name of the preset file for trajectories (the file is created if not present)

~automationInitRecTime = 0; // Allows to automate the GUI if 1 // ~automationLoad.(); // Quark Automation GUI

~setSampleRate = false /*true*/ /*false*/; // False chooses the default sample rate.
~sampleRate = 48000 /*44100*/; // Concat complains: sample rate not 44100, you have 48000
~hardwareBufferSize = 128 /*512*/ /*256*/; // 512 by default -> 128 to get less audio input latency and to avoid long clicks when the server is overloaded

// 3.do { Server.killAll }; // Attendre RESULT = 1 avant d'exécuter la suite
fork { Server.killAll; /*0.1.wait;*/ s.waitForBoot({ /*0.1.wait;*/ 2.do { 0.1.wait; Server.killAll };
	0.1.wait; "".postln; ("Spatial Config ->" + ~numChannelsConfig).postln; ("Preset Filename ->" + ~presetsFileName).postln; if (~presetsFileName2.notNil, {("Preset Filename 2 ->" + ~presetsFileName2).postln}); "".postln;
}); }; // Server.allRunningServers;
)



( // Initialisation MIDI avec la librairie Modality & Quark APC Mini & Twister XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{ // MKtl.find(\midi); MKtl.postLoadedDescs; MKtlDesc.writeCache;
	// ~uController = MKtl('csbm330', "evolution-ucontrol-uc33"); "_Init Midi U.scd".loadRelative; // Midi Channel 0
	// ~qController = MKtl('qnxs0', "keith-mcmillen-qunexus_port1_AB"); "_Init Midi Q2.scd".loadRelative; // Preset B // Midi Channel 3
	// File "keith-mcmillen-qunexus_port1_AB.desc de Modality" -> change Midi Channel from 0 to 3, if Leith-mcmillen-qunexus controller is used
	// ~midiTouchBar = MKtl('iac', "gestionnaire-iac"); "_Init Midi T.scd".loadRelative; // Midi Channel 7
	~akFXVol8 = 1; "_Init Midi Ak.scd".loadRelative; // Akai APC Mini à partir du Quark hacké d'Andrés Pérez López // ~akController = MKtl('pcmn0', "APC MINI"); // Midi Channel 1
	// ~akFXVol8 = 1; to control FX volume on the 8th slider of Akai APC Mini instead of the volume of the 8th track
	1.wait;
	"_Init Midi Twister7.scd".loadRelative; // Encoder Midi - Midi Channel 1 // Switch Midi - Midi Channel 2 // Global settings for side buttons - Midi Channel 4
	// For Midi Fighter Twister, change Midi Encoder Type to "Enc 3FH/41H"
	0.2.wait;
	"_Init Midi Morph.scd".loadRelative; // Sensel Morph // Midi Channel 6
	"Controllers connected if available !".postln;
}.fork;
)



// INIT BUFFERS & SYNTHS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
"_1_Init_BuffersSynths_128.scd".loadRelative; // Load server functions
// ~loadPhrases.(\serverP, \LocalP, 57114); ~fx16Split = 0; // Just for my performance setup to launch a specific server for specific synths and sentences

// 1st Server
~loadServer.(\server1, \Local1, 0, 57110); // Server name -> ~server1 // tested in real context with 32 loudspeakers, but multichnnal FX or synths may lack CPU above 16 channels
~initBuffersSynths.(\server1, 0); // Initialisation chack when the server is loaded with synths and buffers

// 2nd Server
~loadServer.(\server2, \Local2, 1, 57112); // Server name -> ~server2
~initBuffersSynths.(\server2, 1); // Error and probable crash from the second server if the computer is not plugged into an AC power source

// Another model with 2 main and 2 FX servers with Jack - currently abandonned
// ~loadServer.(\server1, \Local1, 0, 57110, \serverFX1, \LocalFX1, 57111); // Noms des servers -> [~server1, ~serverFX1] // limité à 32 canaux via Jack ?
// ~loadServer.(\server2, \Local2, 1, 57112, \serverFX2, \LocalFX2, 57113); // Noms des servers -> [~server2,  ~serverFX2]



// INIT GUI (Server 1 until track 2 and Server 2 from track 3) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~nbOfControlBus = 6; ~serverTrackSwitch = 2; "_2_Init_GUI_221.scd".loadRelative;

// Lemur Connection
~lemurConnected1 = 1; ~lemurAdress1 = NetAddr( "192.168.0.109", 8000);
~lemurConnected2 = 1; ~lemurAdress2 = NetAddr( "192.168.1.11", 8000);
~lemurConnected1 = 0; ~lemurAdress1 = nil; ~lemurConnected2 = 0; ~lemurAdress2 = nil;



// INIT PATTERN XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~updateTime = 0.2 /*0.1*/; "_3_Init_Pattern_181.scd".loadRelative;

if ( ~serverFX == 0, { ~initFXSynthDefs.(\server1, 0) }, { ~initFXSynthDefs.(\serverFX1, 0) } );
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server2, 1) }, { ~initFXSynthDefs.(\serverFX2, 1) } );



// Info on SCsynth servers
~server1.queryAllNodes;
~server2.queryAllNodes;
~server1.numSynthDefs.postln; ~server2.numSynthDefs;
~serverVolume[0].freeSynth;

// Info on size of sound folders
~listingSoundFolders = ("du -m -L" + ~soundsFolder +" | sort -nr").unixCmdGetStdOut; // Listing de la taille des dossiers sons
("open" + ~soundsFolder).unixCmdGetStdOut; // Ouverture du dossier son dans le Finder
("open" + PathName(thisProcess.nowExecutingPath).pathOnly).unixCmdGetStdOut; // Ouverture du dossier des fichiers texte et de presets
