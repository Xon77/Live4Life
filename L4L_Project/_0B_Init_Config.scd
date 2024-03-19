( // Configuration Initialisation Live4Life XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

~viaJACK = 0; // 0 without Jack // 1 with Jack (only tested on OSX)
~inputBusChannelsNb = 2; ~soundIn = 0; // Sound Card Input Channel

~nbOfSeqs = 240 /*99*/; // Nb of sequences in a track
~foldersStructure = 1; // 1, if sound folders are formatted (e.g. IP Gong), otherwise 0
~defaultFolder = 0; // Buffer folder number by default at initialisation
~synthDefsBuild = 0; // 1 to rebuild synthDefs // automatic rebuild if no synthDefs in Application Support
~synthDefsManagementChoose = 1; // 0 -> add // 1 -> load // useful only if ~synthDefsBuild = 1
~buffersLoading = "quick"; // "quick" // "slow" if you have crashes during Buffer loading

~autoScaleGUI = 1; // 1 to scale GUI according to screen resolution, otherwise 0 for Manual Scaling by multiplying the GUI with ~mulsize below
~mulsize = 1; ~xSizeMul = ~mulsize; ~ySizeMul = ~mulsize; ~fontSizeMul = ~mulsize; // determines ~mulsize or specific multiplication of x / y and Font size
~mainWindowScroll = false; // For smaller screen sizes in height
~recordMontage = 0; // 1, if you want to record GUI action
~initSeqOrPerfMode = 0; // Initialisation Mode Séquence = 0 // Performance = 1
~mainServer1Window = 0; // 1 allows to get a server window for the main server in order to be able to boot some programmes like TidalCycles (see bug https://github.com/musikinformatik/SuperDirt/issues/265) // see below how to start SuperDirt if you also want to use TidalCycles on main Server s
~visualizeLevels = "ServerMeter" /*SpatioScope ServerMeter*/; // -> ServerMeter requires a little bit more CPU - but more precise on levels // ~visualizeSpatioScope.value; // But with a second server running, SpatioScope is less interesting because only on 1 server
~visualizeProcessing = 0; // Transfers data to Processing for visuals if 1

~ampLimiter = -7.dbamp; // Amplitude Limiter in dB for each server
~trackXFadeDefault = 20; // Default value for Xfade for tracks (in beats, divide by 2 in seconds: if 120 BPM, then 20 = 10 sec.)
~hpModulation = 1; // 1 allows effects with parameter modulation between the loudspeakers, otherwise 0
~mixAllFxDefault = 0; // Default value for mix of effects
~lagTimeAllFxDefault = 7 /*4*/; // Default value for parameter lag of effects
~fadeTimeSynthFxDefault = 6 /*5*/ /*3*/; // Default value for Xfade time of effects
~maxServerVolume = 3; // /*6*/ /*3*/ /*-3*/ Maximum volume in decibel for servers
~maxTextureTracksVolume = 0; /*6*/ /*1.9952.ampdb 6.dbamp*/ // Maximum volume in decibel for Texture Tracks (currently 1 to 3)
~fxMulVolume = 1.0; // For managing volumes when Xfading  effects in series or parallel - to tweak
~fxMul2Volume = 1.0; // Idem
~fxCPUCheck = 1; // 1 allows to avoid change of effects (see preset[\fxSynth]==1) when changing presets too quickly (below FX xfade time) (now not implemented on FX INOUT...)
~maxSynthTime = 30 /*60*/; // Max. Duration in seconds for synth events
~keyBoardPerfProtect = 0; // 1 avoids to trigger some shortcuts too dangerous or uncontrollable in performance
~keyBoardPerfProtectFX = 1; // 1 avoids to trigger other shortcuts too dangerous or uncontrollable in performance (shift + ?) for random FX
~rtmMulMinProtect = 4; // Multiples the minimum level of Mul Slider for rhythm (adapts according to the number of events) to reach a minimal onset of 0.004 sec. à x1 (2 pour 0.008...)
~rhythmTracks = [4,5,6,7,3] /*[4,5,3]*/; // Identifies rhythm tracks (begins with 0)

// Define the Absolute Path of Sound Folder XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~soundsFolder = "/Users/xon/Desktop/SoundFolder/";
// ~soundsFolder = "/home/<user>/SoundFolder/"; // For Linux, it may look like this
// ~soundsFolder = "C:/Users/<user>/Desktop/L4L/SoundFolder"; // For Windows, it may look like this

// Spatial configuration (Nb of outputs and spatial distribution) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~numChannelsConfig = "2-Performance"; // Stereo Mix and effects // This line chooses spatial configuration setup // Uncomment according your preferred setup
// ~numChannelsConfig = "2-MultiChannelSequencer"; // To get 8 seperated stereo tracks e.g. towards a sequencer - 16 mono effect channels ?
~numChannelsConfig = "4"; // Clockwise Quad - XXXXXXXXX
// ~numChannelsConfig = "5-Clock"; // Clockwise from Centre = 0
// ~numChannelsConfig = "5-Centre"; // Clockwise from Links (except Centre = 3) - XXXXXXXXX
// ~numChannelsConfig = "7"; // Clockwise from Centre
// ~numChannelsConfig = "8-Centre"; // Clockwise from Centre
// ~numChannelsConfig = "8-PairClock"; // Clockwise from Links - XXXXXXXXX
// ~numChannelsConfig = "8-PairPair"; // Pairwise Links / Right - XXXXXXXXX
// ~numChannelsConfig = "16-PairClock"; // Clockwise from Links
// ~numChannelsConfig = "16-Dome-8-6-2-Pair"; // Pairwise Links / Right - XXXXXXXXX
// ~numChannelsConfig = "16-Dome-8-6-2-Clock"; // Clockwise from Links - Dome Hexa Université de Montréal (+ 2 Subs) XXXXXXXXX
// ~numChannelsConfig = "16-Dome-8-6-2-Clock-CC"; // IDEM (+ 4 Subs)
// ~numChannelsConfig = "22-8+Dome-8-4-2-Pair"; // Hall Claude Champagne Université de Montréal with 8 additional speakers in the Hall
// ~numChannelsConfig = "16-UsineC-2Octo"; // 2 circles of 8 speakers + Subs
// ~numChannelsConfig = "24-UsineC-3Octo"; // 3 circles of 8 speakers + Subs
// ~numChannelsConfig = "32-Dome-12-10-8-2"; // Clockwise from Links (+ 2 Subs) XXXXXXXXX
// ~numChannelsConfig = "32-Dome-UQAM-11-11-9-1"; // Clockwise from Links XXXXXXXXX
// ~numChannelsConfig = "32-Dome-12-10-8-2-Motu"; // Clockwise from right - Old Config Motu deprecated
// ~numChannelsConfig = "64-CentreClock"; // Test - Clockwise from Centre - not tested in real context
// ~numChannelsConfig = "96-CentreClock"; // Test - Clockwise from Centre - not tested in real context
// ~numChannelsConfig = "128-CentreClock"; // Test - Clockwise from Centre - not tested in real context - Crash with ~initBuffersSynths.(\server1, 0); because some synths are not stored

// Sequence Preset file name XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetsFileName = "PresetFile-4.txt"; // For Preset file in Quadrophony - or e.g. "PresetFile-2.txt" for Stereo - "PresetFile-32-UQAM.txt"
// ~presetsFileName2 = "PresetFile2-4.txt"; if you have 2 presets files

// Ambisonic Spatialisation
// Keep ~ambATKConfig at "binaural" if you have a headphone, or "stereo" if you have 2 speakers, otherwise ~ambATKConfig is "multiChannel" if more than 2 channels
if (~numChannelsConfig.split($-)[0].asInteger == 2, { ~ambATKConfig = "binaural" /*"stereo" */}, { ~ambATKConfig = "multiChannel"});
~binauralDecoderName = "FoaDecoderKernel.newSpherical"; // newSpherical ou newCIPIC (44100.0 is not available for cipic kernel decoder)
~ambATKkFactor = 'velocity'; // 'dual' / 'velocity' - only for multiChannel

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

~windowsInDevice = "Windows WASAPI : Microphone Array (Realtek High Definition Audio)"; // ServerOptions.inDevices.collect({|m| m.postln}); // Select and evaluate the code before to get a list of input devices and replace it in the text within strings "Windows WASAPI..."
~windowsOutDevice = "Windows WASAPI : Speaker/HP (Realtek High Definition Audio)"; // ServerOptions.outDevices.collect({|m| m.postln}); // Select and evaluate the code before to get a list of output devices and replace it in the text within strings "Windows WASAPI..."
~setSampleRate = false /*true*/ /*false*/; // False chooses the default sample rate.
~sampleRate = 48000 /*44100*/; // Concat complains: sample rate not 44100, you have 48000
~hardwareBufferSize = 128 /*512*/ /*256*/; // 512 by default -> 128 to get less audio input latency and to avoid long clicks when the server is overloaded

// 3.do { Server.killAll }; // Wait RESULT = 1 before executing the following steps
fork { Server.killAll; /*0.1.wait;*/ s.waitForBoot({ /*0.1.wait;*/ 2.do { 0.1.wait; Server.killAll };
	0.1.wait; "".postln; ("Spatial Config ->" + ~numChannelsConfig).postln; ("Preset Filename ->" + ~presetsFileName).postln; if (~presetsFileName2.notNil, {("Preset Filename 2 ->" + ~presetsFileName2).postln}); "".postln; // Document.current.selectRange(103,118);
}); }; // Server.allRunningServers;
);



( // Only if you have controllers - Initialisation MIDI with some Quarks (Modality APC Mini & Twister) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{ MKtl.find(\midi); MKtl.postLoadedDescs; MKtlDesc.writeCache; // necessary to load Akai APC Mini if alone ?
	// ~uController = MKtl('csbm330', "evolution-ucontrol-uc33"); "_Init Midi U.scd".loadRelative; // Midi Channel 0
	// ~qController = MKtl('qnxs0', "keith-mcmillen-qunexus_port1_AB"); "_Init Midi Q2.scd".loadRelative; // Preset B // Midi Channel 3
	// File "keith-mcmillen-qunexus_port1_AB.desc de Modality" -> change Midi Channel from 0 to 3, if Leith-mcmillen-qunexus controller is used
	// ~midiTouchBar = MKtl('iac', "gestionnaire-iac"); "_Init Midi T.scd".loadRelative; // Midi Channel 7
	~akFXVol8 = 1; "_Init Midi Ak.scd".loadRelative; // Akai APC Mini à partir du Quark hacké d'Andrés Pérez López // ~akController = MKtl('pcmn0', "APC MINI"); // Midi Channel 5
	// ~akFXVol8 = 1; to control FX volume on the 8th slider of Akai APC Mini instead of the volume of the 8th track
	1.wait;
	"_Init Midi Twister7.scd".loadRelative; // Encoder Midi - Midi Channel 1 // Switch Midi - Midi Channel 2 // Global settings for side buttons - Midi Channel 4
	// For Midi Fighter Twister, change Midi Encoder Type to "Enc 3FH/41H"
	0.2.wait;
	"_Init Midi Morph.scd".loadRelative; // Sensel Morph // Midi Channel 6
	"Controllers connected if available !".postln;
}.fork;
);



"_1_Init_BuffersSynths_132.scd".loadRelative; // Load server functions