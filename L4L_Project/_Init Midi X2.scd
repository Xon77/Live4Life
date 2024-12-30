~xController = MKtl('xoneK2', "xoneK2");

// To evaluate lines of code via OSC - To connect via MIDI with XoneK2 - DJ Livecoding
~tidalEvalAddr = NetAddr.new("127.0.0.1", 3333);

~tidalEvalFuncP = { |tr|
	~tidalEvalPos[tr] = ~tidalEvalPos[tr]+1; if (~tidalEvalPos[tr] >= (~tidalEvalLine[tr].size), {~tidalEvalPos[tr] = 0});
	{~tidalGuiElements[tr][\seqLine][\value].valueAction_(~tidalEvalLine[tr][~tidalEvalPos[tr]])}.defer;
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (0+tr), \row, ~tidalEvalLine[tr][~tidalEvalPos[tr]], \column, 1);
	// ~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", tr, ~tidalEvalLine[tr][~tidalEvalPos[tr]]);
	// ("Track" + (tr+1) + "-> Line" + ~tidalEvalLine[tr][~tidalEvalPos[tr]]).postln
};
~tidalEvalFuncM = { |tr|
	~tidalEvalPos[tr] = (~tidalEvalPos[tr]-1); if ((~tidalEvalPos[tr]) <= (-1), {~tidalEvalPos[tr] = (~tidalEvalLine[tr].size-1)});
	{~tidalGuiElements[tr][\seqLine][\value].valueAction_(~tidalEvalLine[tr][~tidalEvalPos[tr]])}.defer;
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (0+tr), \row, ~tidalEvalLine[tr][~tidalEvalPos[tr]], \column, 1);
	// ~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", tr, ~tidalEvalLine[tr][~tidalEvalPos[tr]]);
	// ("Track" + (tr+1) + "-> Line" + ~tidalEvalLine[tr][~tidalEvalPos[tr]]).postln
};


// All individual Controls

~xEnc1 = ~xController.elementAt(\Enc1);
~xEnc2 = ~xController.elementAt(\Enc2);
~xEnc3 = ~xController.elementAt(\Enc3);
~xEnc4 = ~xController.elementAt(\Enc4);
~xEnc5 = ~xController.elementAt(\Enc5);
~xEnc6 = ~xController.elementAt(\Enc6);
~xEnc1On = ~xController.elementAt(\Enc1On); ~xEnc1Off = ~xController.elementAt(\Enc1Off);
~xEnc2On = ~xController.elementAt(\Enc2On); ~xEnc2Off = ~xController.elementAt(\Enc2Off);
~xEnc3On = ~xController.elementAt(\Enc3On); ~xEnc3Off = ~xController.elementAt(\Enc3Off);
~xEnc4On = ~xController.elementAt(\Enc4On); ~xEnc4Off = ~xController.elementAt(\Enc4Off);
~xEnc5On = ~xController.elementAt(\Enc5On); ~xEnc5Off = ~xController.elementAt(\Enc5Off);
~xEnc6On = ~xController.elementAt(\Enc6On); ~xEnc6Off = ~xController.elementAt(\Enc5Off);
~xHi1 = ~xController.elementAt(\Hi1);
~xHi2 = ~xController.elementAt(\Hi2);
~xHi3 = ~xController.elementAt(\Hi3);
~xHi4 = ~xController.elementAt(\Hi4);
~xHi1On = ~xController.elementAt(\Hi1On);
~xHi2On = ~xController.elementAt(\Hi2On);
~xHi3On = ~xController.elementAt(\Hi3On);
~xHi4On = ~xController.elementAt(\Hi4On);
~xMi1 = ~xController.elementAt(\Mi1);
~xMi2 = ~xController.elementAt(\Mi2);
~xMi3 = ~xController.elementAt(\Mi3);
~xMi4 = ~xController.elementAt(\Mi4);
~xMi1On = ~xController.elementAt(\Mi1On); ~xMi1Off = ~xController.elementAt(\Mi1Off);
~xMi2On = ~xController.elementAt(\Mi2On); ~xMi2Off = ~xController.elementAt(\Mi2Off);
~xMi3On = ~xController.elementAt(\Mi3On); ~xMi3Off = ~xController.elementAt(\Mi3Off);
~xMi4On = ~xController.elementAt(\Mi4On); ~xMi4Off = ~xController.elementAt(\Mi4Off);
~xLo1 = ~xController.elementAt(\Lo1);
~xLo2 = ~xController.elementAt(\Lo2);
~xLo3 = ~xController.elementAt(\Lo3);
~xLo4 = ~xController.elementAt(\Lo4);
~xLo1On = ~xController.elementAt(\Lo1On); ~xLo1Off = ~xController.elementAt(\Lo1Off);
~xLo2On = ~xController.elementAt(\Lo2On); ~xLo2Off = ~xController.elementAt(\Lo2Off);
~xLo3On = ~xController.elementAt(\Lo3On); ~xLo3Off = ~xController.elementAt(\Lo3Off);
~xLo4On = ~xController.elementAt(\Lo4On); ~xLo4Off = ~xController.elementAt(\Lo4Off);

~xAOn = ~xController.elementAt(\AOn);
~xBOn = ~xController.elementAt(\BOn);
~xCOn = ~xController.elementAt(\COn);
~xDOn = ~xController.elementAt(\DOn);
~xEOn = ~xController.elementAt(\EOn);
~xFOn = ~xController.elementAt(\FOn);
~xGOn = ~xController.elementAt(\GOn);
~xHOn = ~xController.elementAt(\HOn);
~xIOn = ~xController.elementAt(\IOn);
~xJOn = ~xController.elementAt(\JOn);
~xKOn = ~xController.elementAt(\KOn);
~xLOn = ~xController.elementAt(\LOn);
~xMOn = ~xController.elementAt(\MOn);
~xNOn = ~xController.elementAt(\NOn);
~xOOn = ~xController.elementAt(\OOn);
~xPOn = ~xController.elementAt(\POn);

// List of Controls

~xEncs = [~xEnc1, ~xEnc2, ~xEnc3, ~xEnc4];
~xEncsOn = [~xEnc1On, ~xEnc2On, ~xEnc3On, ~xEnc4On];
~xHis = [~xHi1, ~xHi2, ~xHi3, ~xHi4];
~xHisOn = [~xHi1On, ~xHi2On, ~xHi3On, ~xHi4On];
~xMis = [~xMi1, ~xMi2, ~xMi3, ~xMi4];
~xMisOn = [~xMi1On, ~xMi2On, ~xMi3On, ~xMi4On];
~xLos = [~xLo1, ~xLo2, ~xLo3, ~xLo4];
~xLosOn = [~xLo1On, ~xLo2On, ~xLo3On, ~xLo4On];


// Controller Actions

~xEnc1.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(0) /*"down1".postln*/}, { ~tidalEvalFuncP.(0) /*"up1".postln*/ }) });

~xEnc2.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(1) /*"down2".postln*/}, { ~tidalEvalFuncP.(1) /*"up2".postln*/}) });

~xEnc3.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(2) /*"down3".postln*/}, { ~tidalEvalFuncP.(2) /*"up3".postln*/}) });

~xEnc4.action_({ |v| if (v.value == 1, { ~tidalEvalFuncM.(3) /*"down4".postln*/}, { ~tidalEvalFuncP.(3) /*"up4".postln*/}) });

/*~xEncsOn.do { |c, i| c.action_({ |v|
{~tidalGuiElements[i][\eq][\element].valueAction_(1)}.defer;
}) };*/

~xEnc1On.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, ~tidalEvalLine[0].choose.postln, \column, 1);
	// ~superDirtOSC.sendMsg("/SuperDirtMixer/seqLine", 0, ~tidalEvalLine[0].choose); // "Enc1On".postln
	{~tidalGuiElements[0][\eq][\element].valueAction_(1)}.defer;
	~xEnc1On.value_(1); ~xEnc2On.value_(0); ~xEnc3On.value_(0); ~xEnc4On.value_(0);
});

~xEnc2On.action_({ |v|
	{~tidalGuiElements[1][\eq][\element].valueAction_(1)}.defer;
	~xEnc1On.value_(0); ~xEnc2On.value_(1); ~xEnc3On.value_(0); ~xEnc4On.value_(0);
});

~xEnc3On.action_({ |v|
	{~tidalGuiElements[2][\eq][\element].valueAction_(1)}.defer;
	~xEnc1On.value_(0); ~xEnc2On.value_(0); ~xEnc3On.value_(1); ~xEnc4On.value_(0);
});

~xEnc4On.action_({ |v|
	{~tidalGuiElements[3][\eq][\element].valueAction_(1)}.defer;
	~xEnc1On.value_(0); ~xEnc2On.value_(0); ~xEnc3On.value_(0); ~xEnc4On.value_(1);
});

// {~xEnc1On.doAction}.defer;
~xEnc1On.value_(1); ~xEnc2On.value_(0); ~xEnc3On.value_(0); ~xEnc4On.value_(0);


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

~xEnc5On.action_({ |v| if (~tidalReverbType == 0, { ~tidalMixer.setReverbVariableName(\reverb); "Custom VST".postln; ~tidalReverbType = 1}, { ~tidalMixer.setReverbVariableName(\room); "Native Reverb".postln; ~tidalReverbType = 0 }) });

~xEnc5.action_({ |v| if (v.value == 1, { ~tidalReverbM.() /*"down1".postln*/}, { ~tidalReverbP.() /*"up1".postln*/}) });


// Pattern Speed Multiplier for each Track
// ~patternSpeeds = [4, 8, 16, 24, 32];
// ~patternSpeeds = [0, 1, 2, 4, 8, 16, 32, 64];
// ~patternSpeeds = [0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64];
// ~patternSpeeds = (0..64) ! 8;
// ~patternSpeedsSize = (~patternSpeeds.size-1) ! 8;

~xHis.do { |c, i| c.action_({ |v|
	~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", i, (~patternSpeeds[i][~patternSpeedsSize[i]*v.value]));
	// Ligne ci-dessous à retirer au besoin pour avoir un réel mute
	{if (~tidalGuiElements[i][\mute][\value].value == 1, { ~tidalGuiElements[i][\mute][\value].valueAction_(0); ~xHisOn[i].value_(0) })}.defer;
}) };

/*~xHi1.action_({ |v|
// ("Track 1 pat speed -> "+~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]).postln;
// ~tidalNetAddr.sendMsg("/ctrl", "pattern1Speed", ~patternSpeeds[(v.value*~patternSpeedsSize).asInteger]);
// if (~patternSpeedSwitch[0] == 1, {~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 0, (~patternSpeeds[0][v.value*(~patternSpeeds[0].size-1)]))},{~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 0, v.value*64)});
~superDirtOSC.sendMsg("/SuperDirtMixer/ryt", 0, (~patternSpeeds[0][~patternSpeedsSize[0]*v.value]));
{if (~tidalGuiElements[0][\mute][\value].value == 1, { ~tidalGuiElements[0][\mute][\value].valueAction_(0); ~xHi1On.value_(0) })}.defer;
});*/


// Mute for each Track
// ~tidalMute1 = 0; ~tidalMute2 = 0; ~tidalMute3 = 0; ~tidalMute4 = 0;
// Same as Pattern Speed Multiplier == 0 -> NO besoin de de demuter et d'appuyer sur le bouton, ce qui permet de configurer la nouvelle vitesse, mais donc moins rapide pour redéclencher le son imméditement en manipulant le bouton rotatif
// ~xHi1On.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "pattern1Speed", 0); ~xHi1On.value_(1); "Track 1 Pat Speed -> 0".postln });

~xHisOn.do { |c, i| c.action_({ |v|
	// if (~tidalMute1 == 0, {~tidalNetAddr.sendMsg("/mute", 1); ~xHi1On.value_(1); ~tidalMute1 = 1; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 1); /*"Mute Track 1".postln*/}, {~tidalNetAddr.sendMsg("/unmute", 1); ~xHi1On.value_(0); ~tidalMute1 = 0; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 0); /*"Unmute Track 1".postln*/});
	// Action via OSC au dessus et via GUI ci-dessous
	{if (~tidalGuiElements[i][\mute][\value].value == 0, { ~tidalGuiElements[i][\mute][\value].valueAction_(1); ~xHisOn[i].value_(1) }, { ~tidalGuiElements[i][\mute][\value].valueAction_(0); ~xHisOn[i].value_(0) })}.defer;
}) };

/*~xHi1On.action_({ |v|
// if (~tidalMute1 == 0, {~tidalNetAddr.sendMsg("/mute", 1); ~xHi1On.value_(1); ~tidalMute1 = 1; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 1); /*"Mute Track 1".postln*/}, {~tidalNetAddr.sendMsg("/unmute", 1); ~xHi1On.value_(0); ~tidalMute1 = 0; ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", 0, 0); /*"Unmute Track 1".postln*/});
// Action via OSC au dessus et via GUI ci-dessous
{if (~tidalGuiElements[0][\mute][\value].value == 0, { ~tidalGuiElements[0][\mute][\value].valueAction_(1); ~xHi1On.value_(1) }, { ~tidalGuiElements[0][\mute][\value].valueAction_(0); ~xHi1On.value_(0) })}.defer;
});*/


~xMis.do { |c, i| c.action_({ |v|
	// ("Track 1 Buf Folder -> " ++ (v.value*~arrayOfFolderNames4TidalSize[0]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]).postln;
	// ~tidalNetAddr.sendMsg("/ctrl", "1Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]);
	~superDirtOSC.sendMsg("/SuperDirtMixer/buf", i, (v.value*~arrayOfFolderNames4TidalSize[i]).asInteger)
}) };

/*~xMi1.action_({ |v|
// ("Track 1 Buf Folder -> " ++ (v.value*~arrayOfFolderNames4TidalSize[0]).asInteger + ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]).postln;
// ~tidalNetAddr.sendMsg("/ctrl", "1Fol", ~arrayOfFolderNames4Tidal[(v.value*~arrayOfFolderNames4TidalSize[0]).asInteger]);
~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 0, (v.value*~arrayOfFolderNames4TidalSize[0]).asInteger)
});*/


// Selection Buf Folder Plage for each Track

~xMi1On.action_({ |v|
	// ~arrayOfFolderNames4TidalSize[0] = 17; ~arrayOfFolderNames4TidalSize[1] = 17; ~arrayOfFolderNames4TidalSize[2] = 17; ~arrayOfFolderNames4TidalSize[3] = 17;
	{4.do { |i| ~tidalGuiElements[i][\bufS][\value].valueAction_(0/*v.value*/) }}.defer;
	~xMi1On.value_(1); ~xMi2Off.value_(1); ~xMi3Off.value_(1); ~xMi4Off.value_(1);
});

~xMi2On.action_({ |v|
	// ~arrayOfFolderNames4TidalSize[0] = 28; ~arrayOfFolderNames4TidalSize[1] = 28; ~arrayOfFolderNames4TidalSize[2] = 28; ~arrayOfFolderNames4TidalSize[3] = 28;
	{4.do { |i| ~tidalGuiElements[i][\bufS][\value].valueAction_(1/*v.value*/) }}.defer;
	~xMi1Off.value_(1); ~xMi2On.value_(1); ~xMi3Off.value_(1); ~xMi4Off.value_(1)
});

~xMi3On.action_({ |v|
	// ~arrayOfFolderNames4TidalSize[0] = 65; ~arrayOfFolderNames4TidalSize[1] = 75; ~arrayOfFolderNames4TidalSize[2] = 75; ~arrayOfFolderNames4TidalSize[3] = 75;
	{4.do { |i| ~tidalGuiElements[i][\bufS][\value].valueAction_(2/*v.value*/) }}.defer;
	~xMi1Off.value_(1); ~xMi2Off.value_(1); ~xMi3On.value_(1); ~xMi4Off.value_(1)
});

~xMi4On.action_({ |v|
	// ~arrayOfFolderNames4TidalSize[0] = 97; ~arrayOfFolderNames4TidalSize[1] = 97; ~arrayOfFolderNames4TidalSize[2] = 97; ~arrayOfFolderNames4TidalSize[3] = 97;
	{4.do { |i| if ( ~tidalGuiElements[i][\bufS][\value].value == 3, { ~tidalGuiElements[i][\bufS][\value].valueAction_(4/*v.value*/)}, {~tidalGuiElements[i][\bufS][\value].valueAction_(3/*v.value*/)} ) }}.defer;
	~xMi1Off.value_(1); ~xMi2Off.value_(1); ~xMi3Off.value_(1); ~xMi4On.value_(1)
});

// {~xMi1On.doAction}.defer; // Pas possible car la GUI n'est pas initialialisée - TO DO
~xMi1On.value_(1); ~xMi2Off.value_(1); ~xMi3Off.value_(1); ~xMi4Off.value_(1);

// Reverb SC Amount for each Track
/*~xLo1On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, 0); ~xLo1On.value_(1) });
~xLo2On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 1, 0); ~xLo2On.value_(1) });
~xLo3On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 2, 0); ~xLo3On.value_(1) });
~xLo4On.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 3, 0); ~xLo4On.value_(1) });*/

~xloSelectKnob = 0; ~xLo1On.value_(1); ~xLo2On.value_(0); ~xLo3On.value_(0); ~xLo4On.value_(0);
~xLo1On.action_({ |v| ~xloSelectKnob = 0; ~xLo1On.value_(1); ~xLo2On.value_(0); ~xLo3On.value_(0); ~xLo4On.value_(0); });
~xLo2On.action_({ |v| ~xloSelectKnob = 1; ~xLo1On.value_(0); ~xLo2On.value_(1); ~xLo3On.value_(0); ~xLo4On.value_(0); });
~xLo3On.action_({ |v| ~xloSelectKnob = 2; ~xLo1On.value_(0); ~xLo2On.value_(0); ~xLo3On.value_(1); ~xLo4On.value_(0); });
~xLo4On.action_({ |v| ~xloSelectKnob = 3; ~xLo1On.value_(0); ~xLo2On.value_(0); ~xLo3On.value_(0); ~xLo4On.value_(1); });

~xLos.do { |c, i| c.action_({ |v|
	/*~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, v.value);
	if (v.value > 0, {~xLo1Off.value_(1)}, {~xLo1On.value_(1)});*/
	// {~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 0, v.value * ~tidalFolderSizes[~tidalGuiElements[0][\buf][\value].value])}.defer;
	case
	{~xloSelectKnob == 0}
	{{~tidalGuiElements[i][\buf2][\element].valueAction_(v.value)}.defer}
	{~xloSelectKnob == 1}
	{{~tidalGuiElements[i][\legS][\value].valueAction_(v.value*7)}.defer}
	{~xloSelectKnob == 2}
	{{~tidalGuiElements[i][\leg][\element].valueAction_(v.value)}.defer}
	{~xloSelectKnob == 3}
	{~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", i, v.value);};
}) };

/*~xLo1.action_({ |v|
/*~superDirtOSC.sendMsg("/SuperDirtMixer/reverb", 0, v.value);
if (v.value > 0, {~xLo1Off.value_(1)}, {~xLo1On.value_(1)});*/
// {~superDirtOSC.sendMsg("/SuperDirtMixer/buf", 0, v.value * ~tidalFolderSizes[~tidalGuiElements[0][\buf][\value].value])}.defer;
{~tidalGuiElements[0][\buf2][\element].valueAction_(v.value)}.defer;
});*/

//

~xAOn.action_({ |v|
	~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_A0KikCE"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_MoOKick"); "DB_A0KikCE".postln
});
~xBOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_MoOKick"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_PulsarB"); "DB_MoOKick".postln
});
~xCOn.action_({ |v|
	~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_PulsarB"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_TechGab"); "DB_PulsarB".postln
});
~xDOn.action_({ |v| ~tidalNetAddr.sendMsg("/ctrl", "1Fol", "DB_TechGab"); ~tidalNetAddr.sendMsg("/ctrl", "2Fol", "DB_A0KikCE"); "DB_TechGab".postln
});
~xEOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 73, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (7), \row, 73, \column, 1); [73, 73, 73, 73].postln
});
~xFOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 92, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [92, 117, 81].postln
});
~xGOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 93, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 102, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [93, 102, 81].postln
});
~xHOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 102, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [102, 117, 81].postln
});
~xIOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 103, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [103, 117, 81].postln
});
~xJOn.action_({ |v|
	~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 120, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [118, 120, 81].postln
});

~xKOn.action_({ |v|
	{if (~tidalGuiElements[0][\legS][\value].value != 2, { 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\legS][\value].valueAction_(2)}; ~xKOn.value_(1)}, { 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\legS][\value].valueAction_(3)}; ~xKOn.value_(1)} )}.defer;
});

~xLOn.action_({ |v|
	// ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (4), \row, 121, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (5), \row, 117, \column, 1); ~tidalEvalAddr.sendMsg("/pulsar/eval", \type, 'line', 'tab', (6), \row, 81, \column, 1); [93, 117, 81].postln
	{if (~tidalGuiElements[0][\legS][\value].value == 0, { 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\legS][\value].valueAction_(1)}; ~xLOn.value_(1)}, { 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\legS][\value].valueAction_(0)}; ~xLOn.value_(0); ~xKOn.value_(0)} )}.defer;
});

// Mute All Tracks
~xMOn.action_({ |v|
	{if (~tidalMuteAllButton.value == 0, {~tidalMuteAllButton.valueAction_(1); ~xHi1On.value_(1); ~xHi2On.value_(1); ~xHi3On.value_(1); ~xHi4On.value_(1); ~xMOn.value_(1)},{~tidalMuteAllButton.valueAction_(0); ~xHi1On.value_(0); ~xHi2On.value_(0); ~xHi3On.value_(0); ~xHi4On.value_(0); ~xMOn.value_(0)})}.defer;
	// if (~tidalMute1 == 0, {~tidalNetAddr.sendMsg("/muteAll"); ~xHi1On.value_(1); ~xHi2On.value_(1); ~xHi3On.value_(1); ~xHi4On.value_(1); ~xMOn.value_(1); ~tidalMute1 = 1; ~tidalMute2 = 1; ~tidalMute3 = 1; ~tidalMute4 = 1; 4.do { |i|~superDirtOSC.sendMsg("/SuperDirtMixer/mute", i, 1) }; /*"Mute All Tracks".postln*/}, {~tidalNetAddr.sendMsg("/unmuteAll"); ~xHi1On.value_(0); ~xHi2On.value_(0); ~xHi3On.value_(0); ~xHi4On.value_(0); ~xMOn.value_(0); ~tidalMute1 = 0; ~tidalMute2 = 0; ~tidalMute3 = 0; ~tidalMute4 = 0; 4.do { |i| ~superDirtOSC.sendMsg("/SuperDirtMixer/mute", i, 0) } /*"Unmute All Tracks".postln*/});
});

~xNOn.action_({ |v| "n".postln});
~xOOn.action_({ |v| "o".postln});

// Quantize
~xPOn.action_({ |v|
	{ case
		{~tidalGuiElements[0/*orbit.orbitIndex*/][\rytS][\value].value == 0}
		{ 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\rytS][\value].valueAction_(1)}; ~xPOn.value_(1) }
		{~tidalGuiElements[0/*orbit.orbitIndex*/][\rytS][\value].value == 1}
		{ 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\rytS][\value].valueAction_(2)}; ~xPOn.value_(1) }
		{~tidalGuiElements[0/*orbit.orbitIndex*/][\rytS][\value].value == 2}
		{ 8.do { |i| ~tidalGuiElements[i/*orbit.orbitIndex*/][\rytS][\value].valueAction_(0)}; ~xPOn.value_(0) }
	}.defer;
	// if (~patternSpeedSwitch[0] == 0, {~patternSpeeds[0] = [0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64]; ~xPOn.value_(1); "Pattern Speed Quantize ON".postln; ~patternSpeedSwitch[0] = 1 }, {~patternSpeeds[0] = (0..64); ~xPOn.value_(0); "Pattern Speed Quantize OFF".postln;  ~patternSpeedSwitch[0] = 0 }); ~patternSpeedsSize[0] = ~patternSpeeds[0].size-1;
});

// Volume for each Track
~xSli1 = ~xController.elementAt(\Sli1); ~xSli1.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 0, v.value*2); /*v.value.postln;*/ });
~xSli2 = ~xController.elementAt(\Sli2); ~xSli2.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 1, v.value*2); });
~xSli3 = ~xController.elementAt(\Sli3); ~xSli3.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 2, v.value*2); });
~xSli4 = ~xController.elementAt(\Sli4); ~xSli4.action_({ |v| ~superDirtOSC.sendMsg("/SuperDirtMixer/masterGain", 3, v.value*2); });


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
