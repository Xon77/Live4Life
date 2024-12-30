~xController = MKtl('xoneK2', "xoneK2");

// To evaluate lines of code via OSC - To connect via MIDI with XoneK2 - DJ Livecoding
~tidalEvalAddr = NetAddr.new("127.0.0.1", 3333);
~tidalEvalPos = 0 ! 8;
~tidalEvalLine = (73..121) ! 8; // XXXXXXXXXXXX

~tidalEvalFuncP = { |tr|
	~tidalEvalPos[tr] = ~tidalEvalPos[tr]+1; if (~tidalEvalPos[tr] >= (~tidalEvalLine[tr].size), {~tidalEvalPos[tr] = 0});
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4+tr), \row, ~tidalEvalLine[tr][~tidalEvalPos[tr]], \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", tr, ~tidalEvalLine[tr][~tidalEvalPos[tr]]);
	// ("Track" + (tr+1) + "-> Line" + ~tidalEvalLine[tr][~tidalEvalPos[tr]]).postln
};
~tidalEvalFuncM = { |tr|
	~tidalEvalPos[tr] = (~tidalEvalPos[tr]-1); if ((~tidalEvalPos[tr]) <= (-1), {~tidalEvalPos[tr] = (~tidalEvalLine[tr].size-1)});
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4+tr), \row, ~tidalEvalLine[tr][~tidalEvalPos[tr]], \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", tr, ~tidalEvalLine[tr][~tidalEvalPos[tr]]);
	// ("Track" + (tr+1) + "-> Line" + ~tidalEvalLine[tr][~tidalEvalPos[tr]]).postln
};

// Encodeur for each track
~xEnc1 = ~xController.elementAt(\Enc1); ~xEnc1.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(0) /*"down1".postln*/}, { ~tidalEvalFuncP.(0) /*"up1".postln*/}) });
~xEnc2 = ~xController.elementAt(\Enc2); ~xEnc2.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(1) /*"down2".postln*/}, { ~tidalEvalFuncP.(1) /*"up2".postln*/}) });
~xEnc3 = ~xController.elementAt(\Enc3); ~xEnc3.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(2) /*"down3".postln*/}, { ~tidalEvalFuncP.(2) /*"up3".postln*/}) });
~xEnc4 = ~xController.elementAt(\Enc4); ~xEnc4.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(3) /*"down4".postln*/}, { ~tidalEvalFuncP.(3) /*"up4".postln*/}) });

~xEnc1On = ~xController.elementAt(\Enc1On); ~xEnc1Off = ~xController.elementAt(\Enc1Off); ~xEnc1On.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, ~tidalEvalLine[0].choose.postln, \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 0, ~tidalEvalLine[0].choose);
/*"Enc1On".postln*/ });
~xEnc2On = ~xController.elementAt(\Enc2On); ~xEnc2Off = ~xController.elementAt(\Enc2Off); ~xEnc2On.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, ~tidalEvalLine[1].choose.postln, \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 1, ~tidalEvalLine[1].choose);
/*"Enc2On".postln*/ });
~xEnc3On = ~xController.elementAt(\Enc3On); ~xEnc3Off = ~xController.elementAt(\Enc3Off); ~xEnc3On.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, ~tidalEvalLine[2].choose.postln, \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 2, ~tidalEvalLine[2].choose);
/*"Enc3On".postln*/ });
~xEnc4On = ~xController.elementAt(\Enc4On); ~xEnc4Off = ~xController.elementAt(\Enc4Off); ~xEnc4On.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (7), \row, ~tidalEvalLine[3].choose.postln, \column, 1);
	~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 3, ~tidalEvalLine[3].choose);
/*"Enc4On".postln*/ });


~tidalReverbType = 0;
~tidalReverbVST = ["V_Vger", "V_16NoteSentry", "V_LibraNebula", "V_LibraRising", "V_LibraHall", "V_DarkLibraPlate", "V_LibraBloom", "V_LostSaucer", "V_SlowAttackEnsemble", "V_ScorpioRising", "V_DarkHorse", "V_HorseHead", "V_Dotted8Orbits", "V_Reverse8Note", "V_CirrusMajorSynthEchoes", "V_Planetarium", "V_TheVoid", "V_WeAreStardust"];
~tidalReverbVSTSize = ~tidalReverbVST.size;
~tidalReverbPos = 0;

~tidalReverbP = {
	~tidalReverbPos = ~tidalReverbPos+1; if (~tidalReverbPos >= ~tidalReverbVSTSize, {~tidalReverbPos = 0});
	~valhalla.loadPreset(~tidalReverbVST[~tidalReverbPos]);
	(~tidalReverbPos + ~tidalReverbVST[~tidalReverbPos]).postln
};
~tidalReverbM = {
	~tidalReverbPos = (~tidalReverbPos-1); if ((~tidalReverbPos) <= (-1), {~tidalReverbPos = ~tidalReverbVSTSize-1});
	~valhalla.loadPreset(~tidalReverbVST[~tidalReverbPos]);
	(~tidalReverbPos + ~tidalReverbVST[~tidalReverbPos]).postln
};

~xEnc5On = ~xController.elementAt(\Enc5On); ~xEnc5On.action_({ |v| if (~tidalReverbType == 0, { ~tidalMixer.setReverbVariableName(\reverb); "Custom VST".postln; ~tidalReverbType = 1}, { ~tidalMixer.setReverbVariableName(\room); "Native Reverb".postln; ~tidalReverbType = 0 }) });

~xEnc5 = ~xController.elementAt(\Enc5); ~xEnc5.action_({ |v| if (v.value == 1, { ~tidalReverbM.() /*"down1".postln*/}, { ~tidalReverbP.() /*"up1".postln*/}) });


// Mute for each Track
~tidalMute1 = 0; ~tidalMute2 = 0; ~tidalMute3 = 0; ~tidalMute4 = 0;
~xHi1On = ~xController.elementAt(\Hi1On);
~xHi2On = ~xController.elementAt(\Hi2On);
~xHi3On = ~xController.elementAt(\Hi3On);
~xHi4On = ~xController.elementAt(\Hi4On);


// Pattern Speed Multiplier for each Track
// ~patternSpeeds = [4, 8, 16, 24, 32];
// ~patternSpeeds = [0, 1, 2, 4, 8, 16, 32, 64];
// ~patternSpeeds = [0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64];
// ~patternSpeeds = (0..64) ! 8;
// ~patternSpeedsSize = (~patternSpeeds.size-1) ! 8;

~xHi1 = ~xController.elementAt(\Hi1); ~xHi1.action_({ |v|
	// ("Track 1 pat speed -> "+~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "pattern1Speed", ~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]);
	if (~patternSpeedSwitch[0] == 1, {~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 0, (~patternSpeeds[0][v.value*(~patternSpeeds[0].size-1)]))},{~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 0, v.value*64)});
});

~xHi2 = ~xController.elementAt(\Hi2); ~xHi2.action_({ |v|
	// ("Track 2 pat speed -> "+~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "pattern2Speed", ~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]);
		if (~patternSpeedSwitch[1] == 1, {~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 1, (~patternSpeeds[1][v.value*(~patternSpeeds[1].size-1)]))},{~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 1, v.value*64)});
});

~xHi3 = ~xController.elementAt(\Hi3); ~xHi3.action_({ |v|
	// ("Track 3 pat speed -> "+~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "pattern3Speed", ~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]);
		if (~patternSpeedSwitch[2] == 1, {~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 2, (~patternSpeeds[2][v.value*(~patternSpeeds[2].size-1)]))},{~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 2, v.value*64)});
});

~xHi4 = ~xController.elementAt(\Hi4); ~xHi4.action_({ |v|
	// ("Track 4 pat speed -> "+~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "pattern4Speed", ~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]);
		if (~patternSpeedSwitch[3] == 1, {~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 3, (~patternSpeeds[3][v.value*(~patternSpeeds[3].size-1)]))},{~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 3, v.value*64)});
});


// Mute for each Track
// Same as Pattern Speed Multiplier == 0 -> NO besoin de de demuter et d'appuyer sur le bouton, ce qui permet de configurer la nouvelle vitesse, mais donc moins rapide pour redéclencher le son imméditement en manipulant le bouton rotatif
// ~xHi1On.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "pattern1Speed", 0); ~xHi1On.value_(1); "Track 1 Pat Speed -> 0".postln });
~xHi1On.action_({ |v| if (~tidalMute1 == 0, {~tidalNetAddr.sendMsg("/mute", 1); ~xHi1On.value_(1); ~tidalMute1 = 1; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 1); /*"Mute Track 1".postln*/}, {~tidalNetAddr.sendMsg("/unmute", 1); ~xHi1On.value_(0); ~tidalMute1 = 0; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 0); /*"Unmute Track 1".postln*/}); });

~xHi2On.action_({ |v| if (~tidalMute2 == 0, {~tidalNetAddr.sendMsg("/mute", 2); ~xHi2On.value_(1); ~tidalMute2 = 1; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 1, 1); /*"Mute Track 2".postln*/}, {~tidalNetAddr.sendMsg("/unmute", 2); ~xHi2On.value_(0); ~tidalMute2 = 0; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 1, 0); /*"Unmute Track 2".postln*/}); });

~xHi3On.action_({ |v| if (~tidalMute3 == 0, {~tidalNetAddr.sendMsg("/mute", 3); ~xHi3On.value_(1); ~tidalMute3 = 1; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 2, 1); /*"Mute Track 3".postln*/}, {~tidalNetAddr.sendMsg("/unmute", 3); ~xHi3On.value_(0); ~tidalMute3 = 0; /*"Unmute Track 3".postln*/ ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 2, 0);}); });

~xHi4On.action_({ |v| if (~tidalMute4 == 0, {~tidalNetAddr.sendMsg("/mute", 4); ~xHi4On.value_(1); ~tidalMute4 = 1; /*"Mute Track 4".postln*/ ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 3, 1);}, {~tidalNetAddr.sendMsg("/unmute", 4); ~xHi4On.value_(0); ~tidalMute4 = 0; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 3, 0); /*"Unmute Track 4".postln*/}); });

~xAOn = ~xController.elementAt(\AOn); ~xAOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_A0KikCE"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_MoOKick"); "DB_A0KikCE".postln });
~xBOn = ~xController.elementAt(\BOn); ~xBOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_MoOKick"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_PulsarB"); "DB_MoOKick".postln });
~xCOn = ~xController.elementAt(\COn); ~xCOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_PulsarB"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_TechGab"); "DB_PulsarB".postln });
~xDOn = ~xController.elementAt(\DOn); ~xDOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_TechGab"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_A0KikCE"); "DB_TechGab".postln });

~xEOn = ~xController.elementAt(\EOn); ~xEOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (7), \row, 73, \column, 1); [73, 73, 73, 73].postln });
~xFOn = ~xController.elementAt(\FOn); ~xFOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 92, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [92, 117, 81].postln });
~xGOn = ~xController.elementAt(\GOn); ~xGOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 93, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 102, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [93, 102, 81].postln });
~xHOn = ~xController.elementAt(\HOn); ~xHOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 102, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [102, 117, 81].postln });
~xIOn = ~xController.elementAt(\IOn); ~xIOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 103, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [103, 117, 81].postln });
~xJOn = ~xController.elementAt(\JOn); ~xJOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 120, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [118, 120, 81].postln });
~xKOn = ~xController.elementAt(\KOn); ~xKOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 120, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1);  ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [120, 117, 81].postln});
~xLOn = ~xController.elementAt(\LOn); ~xLOn.action_({ |v| ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 121, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [93, 117, 81].postln});

// Mute All Tracks
~xMOn = ~xController.elementAt(\MOn);
~xMOn.action_({ |v| if (~tidalMute1 == 0, {~tidalNetAddr.sendMsg("/muteAll"); ~xHi1On.value_(1); ~xHi2On.value_(1); ~xHi3On.value_(1); ~xHi4On.value_(1); ~xMOn.value_(1); ~tidalMute1 = 1; ~tidalMute2 = 1; ~tidalMute3 = 1; ~tidalMute4 = 1; 4.do { |i|~superDirtOSC.sendMsg("/SuperDirtMixer/mute", i, 1) }; /*"Mute All Tracks".postln*/}, {~tidalNetAddr.sendMsg("/unmuteAll"); ~xHi1On.value_(0); ~xHi2On.value_(0); ~xHi3On.value_(0); ~xHi4On.value_(0); ~xMOn.value_(0); ~tidalMute1 = 0; ~tidalMute2 = 0; ~tidalMute3 = 0; ~tidalMute4 = 0; 4.do { |i| ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", i, 0) } /*"Unmute All Tracks".postln*/}); });

~xNOn = ~xController.elementAt(\NOn); ~xNOn.action_({ |v| "n".postln});
~xOOn = ~xController.elementAt(\OOn); ~xOOn.action_({ |v| "o".postln});

// Quantize
~xPOn = ~xController.elementAt(\POn); ~xPOn.action_({ |v| if (~patternSpeedSwitch[0] == 0, {~patternSpeeds[0] = [0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64]; ~xPOn.value_(1); "Pattern Speed Quantize ON".postln; ~patternSpeedSwitch[0] = 1 }, {~patternSpeeds[0] = (0..64); ~xPOn.value_(0); "Pattern Speed Quantize OFF".postln;  ~patternSpeedSwitch[0] = 0 }); ~patternSpeedsSize[0] = ~patternSpeeds[0].size-1;});

// Volume for each Track
~xSli1 = ~xController.elementAt(\Sli1); ~xSli1.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 0, v.value*2); /*v.value.postln;*/ });
~xSli2 = ~xController.elementAt(\Sli2); ~xSli2.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 1, v.value*2); });
~xSli3 = ~xController.elementAt(\Sli3); ~xSli3.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 2, v.value*2); });
~xSli4 = ~xController.elementAt(\Sli4); ~xSli4.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 3, v.value*2); });

// Reverb SC Amount for each Track
~xLo1On = ~xController.elementAt(\Lo1On); ~xLo1Off = ~xController.elementAt(\Lo1Off); ~xLo1On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, 0); ~xLo1On.value_(1) });
~xLo2On = ~xController.elementAt(\Lo2On); ~xLo2Off = ~xController.elementAt(\Lo2Off); ~xLo2On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 1, 0); ~xLo2On.value_(1) });
~xLo3On = ~xController.elementAt(\Lo3On); ~xLo3Off = ~xController.elementAt(\Lo3Off); ~xLo3On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 2, 0); ~xLo3On.value_(1) });
~xLo4On = ~xController.elementAt(\Lo4On); ~xLo4Off = ~xController.elementAt(\Lo4Off); ~xLo4On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 3, 0); ~xLo4On.value_(1) });

~xLo1 = ~xController.elementAt(\Lo1); ~xLo1.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, v.value); if (v.value > 0, {~xLo1Off.value_(1)}, {~xLo1On.value_(1)}) });
~xLo2 = ~xController.elementAt(\Lo2); ~xLo2.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 1, v.value); if (v.value > 0, {~xLo2Off.value_(1)}, {~xLo2On.value_(1)}) });
~xLo3 = ~xController.elementAt(\Lo3); ~xLo3.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 2, v.value); if (v.value > 0, {~xLo3Off.value_(1)}, {~xLo3On.value_(1)}) });
~xLo4 = ~xController.elementAt(\Lo4); ~xLo4.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 3, v.value); if (v.value > 0, {~xLo4Off.value_(1)}, {~xLo4On.value_(1)})});

~xMi1 = ~xController.elementAt(\Mi1); ~xMi1.action_({ |v|
	// ("Track 1 Buf Folder -> " ++ (v.value*~arrayOfFolderNames4TidalSize[0]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "1Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]);
	~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 0, (v.value*~arrayOfFolderNames4TidalSize[0]).asInteger) });

~xMi2 = ~xController.elementAt(\Mi2); ~xMi2.action_({ |v|
	// ("Track 2 Buf Folder -> "++ (v.value*~arrayOfFolderNames4TidalSize[1]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[1]).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "2Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[1]).asInteger]);
	~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 1, (v.value*~arrayOfFolderNames4TidalSize[1]).asInteger) });

~xMi3 = ~xController.elementAt(\Mi3); ~xMi3.action_({ |v|
	// ("Track 3 Buf Folder -> "++ (v.value*~arrayOfFolderNames4TidalSize[2]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[2]).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "3Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[2]).asInteger]);
	~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 2, (v.value*~arrayOfFolderNames4TidalSize[2]).asInteger) });

~xMi4 = ~xController.elementAt(\Mi4); ~xMi4.action_({ |v|
	// ("Track 4 Buf Folder -> "++ (v.value*~arrayOfFolderNames4TidalSize[3]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[3]).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "4Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[3]).asInteger]);
	~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 3, (v.value*~arrayOfFolderNames4TidalSize[3]).asInteger)
});


// Selection Buf Folder Plage for each Track
~xMi1On = ~xController.elementAt(\Mi1On); ~xMi1Off = ~xController.elementAt(\Mi1Off); ~xMi1On.action_({ |v| ~arrayOfFolderNames4TidalSize[0] = 17; ~arrayOfFolderNames4TidalSize[1] = 17; ~arrayOfFolderNames4TidalSize[2] = 17; ~arrayOfFolderNames4TidalSize[3] = 17; ~xMi1On.value_(1); ~xMi2Off.value_(1); ~xMi3Off.value_(1); ~xMi4Off.value_(1) });
~xMi2On = ~xController.elementAt(\Mi2On); ~xMi2Off = ~xController.elementAt(\Mi2Off); ~xMi2On.action_({ |v| ~arrayOfFolderNames4TidalSize[0] = 28; ~arrayOfFolderNames4TidalSize[1] = 28; ~arrayOfFolderNames4TidalSize[2] = 28; ~arrayOfFolderNames4TidalSize[3] = 28; ~xMi1Off.value_(1); ~xMi2On.value_(1); ~xMi3Off.value_(1); ~xMi4Off.value_(1) });
~xMi3On = ~xController.elementAt(\Mi3On); ~xMi3Off = ~xController.elementAt(\Mi3Off); ~xMi3On.action_({ |v| ~arrayOfFolderNames4TidalSize[0] = 65; ~arrayOfFolderNames4TidalSize[1] = 75; ~arrayOfFolderNames4TidalSize[2] = 75; ~arrayOfFolderNames4TidalSize[3] = 75; ~xMi1Off.value_(1); ~xMi2Off.value_(1); ~xMi3On.value_(1); ~xMi4Off.value_(1) });
~xMi4On = ~xController.elementAt(\Mi4On); ~xMi4Off = ~xController.elementAt(\Mi4Off); ~xMi4On.action_({ |v| ~arrayOfFolderNames4TidalSize[0] = 97; ~arrayOfFolderNames4TidalSize[1] = 97; ~arrayOfFolderNames4TidalSize[2] = 97; ~arrayOfFolderNames4TidalSize[3] = 97; ~xMi1Off.value_(1); ~xMi2Off.value_(1); ~xMi3Off.value_(1); ~xMi4On.value_(1) });

~xExitOn = ~xController.elementAt(\ExitOn); ~xExitOn.action_({ |v| 4.do { |tr| ~dirt.orbits[tr].freeSynths /*.release(0)*//*cmdPeriod*//*initNodeTree*//*freeSynths*/ }; "Free Synths".postln; });
// 4.do { |tr| ~dirt.orbits[tr].initNoteTree };
// ~dirt.orbits[0].group.free
// g = ~dirt.orbits[0].group.class.postln
// g.queryTree

/*
~xMi1OnO = ~xController.elementAt(\Mi1OnO);
~xMi1OnG = ~xController.elementAt(\Mi1OnG);

~xMi1On.value_(1);
~xMi1OnO.value_(1);
~xMi1OnG.value_(1);
*/
