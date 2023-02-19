( // LEMUR NEW CONNEXION XXXXXXXXX

// 57120 Lang / 57110 Serv
// ~aControllerConnected
if (~lemurConnected1 == 1, { // 1 si Lemur connectée

	// ~lemurAdress1 = NetAddr( "192.168.0.186", 8000); // XXXXXXXXX Lemur Ipad sur port 8000
	// ~lemurAdress1 = NetAddr("169.254.5.133"/*"test.local"*/, 8000);
	// ~lemurAdress1 = NetAddr("169.254.127.191", 8000);
	// ~lemurAdress1 = NetAddr("10.226.231.235", 8000);

	// For each track
	~lemurOSCdefSwitchesNames = [\switches1, \switches1B, \switches2, \switches2B, \switches3, \switches3B, \switches4, \switches4B, \switches5, \switches5B, \switches6, \switches6B, \switches7, \switches7B, \switches8, \switches8B];

	~lemurOSCdefSwitchesNamesLemur2 = [\switches1Lemur2, \switches1BLemur2, \switches2Lemur2, \switches2BLemur2, \switches3Lemur2, \switches3BLemur2, \switches4Lemur2, \switches4BLemur2, \switches5Lemur2, \switches5BLemur2, \switches6Lemur2, \switches6BLemur2, \switches7Lemur2, \switches7BLemur2, \switches8Lemur2, \switches8BLemur2];

	~lemurOSCdefRadioSwitchesNames = [\switch1Radio, \switch1BRadio, \switch2Radio, \switch2BRadio, \switch3Radio, \switch3BRadio, \switch4radio, \switch4BRadio, \switch5Radio, \switch5BRadio, \switch6Radio, \switch6BRadio, \switch7Radio, \switch7BRadio, \switch8Radio, \switch8BRadio];

	~lemurRadioSwitchesValues = [ "/Tracks/Switch1Radio/x", "/Tracks/Switch1BRadio/x", "/Tracks/Switch2Radio/x", "/Tracks/Switch2BRadio/x", "/Tracks/Switch3Radio/x", "/Tracks/Switch3BRadio/x", "/Tracks/Switch4Radio/x", "/Tracks/Switch4BRadio/x", "/Tracks/Switch5Radio/x", "/Tracks/Switch5BRadio/x", "/Tracks/Switch6Radio/x", "/Tracks/Switch6BRadio/x", "/Tracks/Switch7Radio/x", "/Tracks/Switch7BRadio/x", "/Tracks/Switch8Radio/x", "/Tracks/Switch8BRadio/x", ];

	~lemurOSCdefPresetMenu1Names =  [ \PresetMenuP11, \PresetMenuP12, \PresetMenuP13, \PresetMenuP14, \PresetMenuP15, \PresetMenuP16, \PresetMenuP17, \PresetMenuP18, \PresetMenuP19, \PresetMenuP110 ];
	~lemurOSCdefPresetMenu1NamesLemur2 =  [ \PresetMenuP11Lemur2, \PresetMenuP12Lemur2, \PresetMenuP13Lemur2, \PresetMenuP14Lemur2, \PresetMenuP15Lemur2, \PresetMenuP16Lemur2, \PresetMenuP17Lemur2, \PresetMenuP18Lemur2, \PresetMenuP19Lemur2, \PresetMenuP110Lemur2 ];
	~lemurOSCdefPresetMenu2Names =  [ \PresetMenuP21, \PresetMenuP22, \PresetMenuP23, \PresetMenuP24, \PresetMenuP25, \PresetMenuP26, \PresetMenuP27, \PresetMenuP28, \PresetMenuP29, \PresetMenuP210 ];
	~lemurOSCdefPresetMenu2NamesLemur2 =  [ \PresetMenuP21Lemur2, \PresetMenuP22Lemur2, \PresetMenuP23Lemur2, \PresetMenuP24Lemur2, \PresetMenuP25Lemur2, \PresetMenuP26Lemur2, \PresetMenuP27Lemur2, \PresetMenuP28Lemur2, \PresetMenuP29Lemur2, \PresetMenuP210Lemur2 ];

	~lemurPresetMenu1Values = [ "/Presets1/PresetMenuP11/x", "/Presets1/PresetMenuP12/x", "/Presets1/PresetMenuP13/x", "/Presets1/PresetMenuP14/x", "/Presets1/PresetMenuP15/x", "/Presets1/PresetMenuP16/x", "/Presets1/PresetMenuP17/x", "/Presets1/PresetMenuP18/x", "/Presets1/PresetMenuP19/x", "/Presets1/PresetMenuP110/x" ];
	~lemurPresetMenu2Values = [ "/Presets2/PresetMenuP21/x", "/Presets2/PresetMenuP22/x", "/Presets2/PresetMenuP23/x", "/Presets2/PresetMenuP24/x", "/Presets2/PresetMenuP25/x", "/Presets2/PresetMenuP26/x", "/Presets2/PresetMenuP27/x", "/Presets2/PresetMenuP28/x", "/Presets2/PresetMenuP29/x", "/Presets2/PresetMenuP210/x" ];

	~lemurCurSeqNames  = ["/CurSeqT1/value", "/CurSeqT1B/value", "/CurSeqT2/value", "/CurSeqT2B/value", "/CurSeqT3/value", "/CurSeqT3B/value", "/CurSeqT4/value", "/CurSeqT4B/value", "/CurSeqT5/value", "/CurSeqT5B/value", "/CurSeqT6/value", "/CurSeqT6B/value", "/CurSeqT7/value", "/CurSeqT7B/value", "/CurSeqT8/value", "/CurSeqT8B/value"];

	~lemurCurSeqPlayViewNames = ["/CurSeqT1Led/value", "/CurSeqT1BLed/value", "/CurSeqT2Led/value", "/CurSeqT2BLed/value", "/CurSeqT3Led/value", "/CurSeqT3BLed/value", "/CurSeqT4Led/value", "/CurSeqT4BLed/value", "/CurSeqT5Led/value", "/CurSeqT5BLed/value", "/CurSeqT6Led/value", "/CurSeqT6BLed/value", "/CurSeqT7Led/value", "/CurSeqT7BLed/value", "/CurSeqT8Led/value", "/CurSeqT8BLed/value"];

	~lemurSwitchesContainerNames =  [ "/Tracks/Seqs1/CS1", "/Tracks/Seqs1B/CS1B", "/Tracks/Seqs2/CS2", "/Tracks/Seqs2B/CS2B", "/Tracks/Seqs3/CS3", "/Tracks/Seqs3B/CS3B", "/Tracks/Seqs4/CS4", "/Tracks/Seqs4B/CS4B", "/Tracks/Seqs5/CS5", "/Tracks/Seqs5B/CS5B", "/Tracks/Seqs6/CS6", "/Tracks/Seqs6B/CS6B", "/Tracks/Seqs7/CS7", "/Tracks/Seqs7B/CS7B", "/Tracks/Seqs8/CS8", "/Tracks/Seqs8B/CS8B" ];

	~lemurSwitchesNames =  [ "/Tracks/Seqs1/CS1/Switches1", "/Tracks/Seqs1B/CS1B/Switches1B", "/Tracks/Seqs2/CS2/Switches2", "/Tracks/Seqs2B/CS2B/Switches2B", "/Tracks/Seqs3/CS3/Switches3", "/Tracks/Seqs3B/CS3B/Switches3B", "/Tracks/Seqs4/CS4/Switches4", "/Tracks/Seqs4B/CS4B/Switches4B", "/Tracks/Seqs5/CS5/Switches5", "/Tracks/Seqs5B/CS5B/Switches5B", "/Tracks/Seqs6/CS6/Switches6", "/Tracks/Seqs6B/CS6B/Switches6B", "/Tracks/Seqs7/CS7/Switches7", "/Tracks/Seqs7B/CS7B/Switches7B", "/Tracks/Seqs8/CS8/Switches8", "/Tracks/Seqs8B/CS8B/Switches8B" ];

	~lemurSwitchesValues = [ "/Tracks/Seqs1/CS1/Switches1/x", "/Tracks/Seqs1B/CS1B/Switches1B/x", "/Tracks/Seqs2/CS2/Switches2/x", "/Tracks/Seqs2B/CS2B/Switches2B/x", "/Tracks/Seqs3/CS3/Switches3/x", "/Tracks/Seqs3B/CS3B/Switches3B/x", "/Tracks/Seqs4/CS4/Switches4/x", "/Tracks/Seqs4B/CS4B/Switches4B/x", "/Tracks/Seqs5/CS5/Switches5/x", "/Tracks/Seqs5B/CS5B/Switches5B/x", "/Tracks/Seqs6/CS6/Switches6/x", "/Tracks/Seqs6B/CS6B/Switches6B/x", "/Tracks/Seqs7/CS7/Switches7/x", "/Tracks/Seqs7B/CS7B/Switches7B/x", "/Tracks/Seqs8/CS8/Switches8/x", "/Tracks/Seqs8B/CS8B/Switches8B/x" ];

	~lemurFaderValues = [ "/Tracks/FTr1SelSeq/x", "/Tracks/FTr1BSelSeq/x", "/Tracks/FTr2SelSeq/x", "/Tracks/FTr2BSelSeq/x", "/Tracks/FTr3SelSeq/x", "/Tracks/FTr3BSelSeq/x", "/Tracks/FTr4SelSeq/x", "/Tracks/FTr4BSelSeq/x", "/Tracks/FTr5SelSeq/x", "/Tracks/FTr5BSelSeq/x", "/Tracks/FTr6SelSeq/x", "/Tracks/FTr6BSelSeq/x", "/Tracks/FTr7SelSeq/x", "/Tracks/FTr7BSelSeq/x", "/Tracks/FTr8SelSeq/x", "/Tracks/FTr8BSelSeq/x" ];

	~lemurBufSwitchesTextNames = /*70*/ /*~bufFolderSize*/ /*105*/ 70.collect { |i| "/ParC/BufMenuC/TBuf_" ++ (i+1).asString };
	~lemurBufSwitchesTextPos = (7.collect { |r| /*15*/ 10.collect { |c| var x,y; x=(-7); y=(-2); [(c* /*67*/ 101)+x, (r*48)+y, 100, 50] } }.flatten(1)) ++ (~lemurBufSwitchesTextPos.size - ~bufFolderSize).collect { [ 1000, 1000, 100, 50 ] };

	~lemurPreset11SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_11_" ++ (i+1).asString };
	~lemurPreset12SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_12_" ++ (i+1).asString };
	~lemurPreset13SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_13_" ++ (i+1).asString };
	~lemurPreset14SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_14_" ++ (i+1).asString };
	~lemurPreset15SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_15_" ++ (i+1).asString };
	~lemurPreset16SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_16_" ++ (i+1).asString };
	~lemurPreset17SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_17_" ++ (i+1).asString };
	~lemurPreset18SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_18_" ++ (i+1).asString };
	~lemurPreset19SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_19_" ++ (i+1).asString };
	~lemurPreset110SwitchesTextNames = 60.collect { |i| "/Presets1/TPres_110_" ++ (i+1).asString };

	~lemurPreset21SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_21_" ++ (i+1).asString };
	~lemurPreset22SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_22_" ++ (i+1).asString };
	~lemurPreset23SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_23_" ++ (i+1).asString };
	~lemurPreset24SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_24_" ++ (i+1).asString };
	~lemurPreset25SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_25_" ++ (i+1).asString };
	~lemurPreset26SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_26_" ++ (i+1).asString };
	~lemurPreset27SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_27_" ++ (i+1).asString };
	~lemurPreset28SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_28_" ++ (i+1).asString };
	~lemurPreset29SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_29_" ++ (i+1).asString };
	~lemurPreset210SwitchesTextNames = 60.collect { |i| "/Presets2/TPres_210_" ++ (i+1).asString };
	~lemurPresetSwitchesTextPos = 0 ! 2;
	~lemurPresetSwitchesTextPos[0] = 6.collect { |r| 10.collect { |c| var x,y; x=80; y=0; [(c*92.5)+x, (r*50.5)+y, 100, 50] } }.flatten(1);
	~lemurPresetSwitchesTextPos[1] = 6.collect { |r| 10.collect { |c| var x,y; x=170; y=0; [(c*83)+x, (r*50.5)+y, 100, 50] } }.flatten(1);



	~lemurSwitchesTextNames = [ 240.collect { |i| "/Tracks/Seqs1/CS1/TSeq1_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs1B/CS1B/TSeq1B_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs2/CS2/TSeq2_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs2B/CS2B/TSeq2B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs3/CS3/TSeq3_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs3B/CS3B/TSeq3B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs4/CS4/TSeq4_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs4B/CS4B/TSeq4B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs5/CS5/TSeq5_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs5B/CS5B/TSeq5B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs6/CS6/TSeq6_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs6B/CS6B/TSeq6B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs7/CS7/TSeq7_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs7B/CS7B/TSeq7B_" ++ (i+1).asString}, 240.collect { |i| "/Tracks/Seqs8/CS8/TSeq8_" ++ (i+1).asString }, 240.collect { |i| "/Tracks/Seqs8B/CS8B/TSeq8B_" ++ (i+1).asString } ] ;
	// ~lemurSwitchesTextNames.cs
	~lemurSwitchesTextPos = 16.collect { |r| 15.collect { |c| var x,y; x=0; y=2; [(c*183)+x, (r*54)+y, 178, 50] } }.flatten(1);
	// ~lemurSwitchesTextPos.cs

	// Matrice de 5 lignes x 4 colonnes, répété en 4 lignes x 3 colonnes
	// 16 lignes * 15 colonnes ou 12 taleaux de 20 valeurs = 240 valeurs
	~lemurSwitchesMaps = 4.collect { |i| var a = i*60; (((0..4)+a) ++ ((0..4)+20+a) ++ ((0..4)+40+a) ++ ((0..4)+5+a) ++ ((0..4)+25+a) ++ ((0..4)+45+a) ++ ((0..4)+10+a) ++ ((0..4)+30+a) ++ ((0..4)+50+a) ++ ((0..4)+15+a) ++ ((0..4)+35+a) ++ ((0..4)+55+a)) }.flatten(1);
	// ~lemurSwitchesMaps.size
	// ~lemurSwitchesMaps.cs

	// Attribution et envoi des couleurs des séquences au LEMUR
	// Note that the value of the color attribute can range from 0 to 8355711: ((R*127 x 2^16) + (G*127 x 2^8) + B*127), where R, G and B are values between 0.00 and 1.00.
	~blueLemurColor1 = ((0.337*127 * 2.pow(16)).asInteger + (0.7*127 * 2.pow(8)).asInteger + (0.4*127).asInteger); // Bleu
	~greenLemurColor = ((0.338*127 * 2.pow(16)).asInteger + (0.7*127 * 2.pow(8)).asInteger + (0.1*127).asInteger); // Vert
	~blueLemurColor2 = ((0.7*127 * 2.pow(16)).asInteger + (0.2*127 * 2.pow(8)).asInteger + (1.0*127).asInteger); // Violet
	~orangeLemurColor = ((1.0*127 * 2.pow(16)).asInteger + (0.4*127 * 2.pow(8)).asInteger + (0.7*127).asInteger); // Orange
	~yellowLemurColor = ((0.4*127 * 2.pow(16)).asInteger + (0.4*127 * 2.pow(8)).asInteger + (0.2*127).asInteger); // Yellow
	~redLemurColor = ((1*127 * 2.pow(16)).asInteger + (0.0*127 * 2.pow(8)).asInteger + (0.0*127).asInteger); // Red
	~redLemurColor2 = (( Color.red(0.5).red*127 * 2.pow(16)).asInteger + ( Color.red(0.5).green*127 * 2.pow(8)).asInteger + ( Color.red(0.5).blue*127).asInteger); // Red 2
	~redLemurColor3 = (( 052*127 * 2.pow(16)).asInteger + ( 0*127 * 2.pow(8)).asInteger + ( 0*127).asInteger); // Red 3
	~blackLemurColor = ((0*127 * 2.pow(16)).asInteger + (0*127 * 2.pow(8)).asInteger + (0*127).asInteger); // Black
	~whiteLemurColor = ((0.79*127 * 2.pow(16)).asInteger + (0.79*127 * 2.pow(8)).asInteger + (0.79*127).asInteger) /*8355711*/; // White green
	~greyLemurColor = ((0*127 * 2.pow(16)).asInteger + (0*127 * 2.pow(8)).asInteger + (0.5*127).asInteger); // Grey
	/*// Couleurs trop flashy
	~blueLemurColor1 = ( (0.4*127 * 2.pow(16)).asInteger + (0.5*127 * 2.pow(8)).asInteger + (1.0*127) ); // Bleu
	~blueLemurColor2 = ( (1.0*127 * 2.pow(16)).asInteger + (0.2*127 * 2.pow(8)).asInteger + (1.0*127) ); // Violet pétant
	~greenLemurColor = ( (0.33*127 * 2.pow(16)).asInteger + (0.9*127 * 2.pow(8)).asInteger + (0.0*127) );*/ // Vert

	~lemurColors = 0 ! ~nbOfSeqs;
	(0..29).do { |i| ~lemurColors[i] = ~blueLemurColor1 };
	(30..41).do { |i| ~lemurColors[i] = ~blueLemurColor2 };
	(42..70).do { |i| ~lemurColors[i] = ~blueLemurColor1 };
	(71..141).do { |i| ~lemurColors[i] = ~blueLemurColor2 };
	(142..187).do { |i| ~lemurColors[i] = ~greenLemurColor };
	(188..199).do { |i| ~lemurColors[i] = ~blueLemurColor1 };
	(200..233).do { |i| ~lemurColors[i] = ~redLemurColor3 };
	(234..239).do { |i| ~lemurColors[i] = ~blackLemurColor };

	// Envoi des couleurs des séquences au LEMUR sur la piste 1A dans des Switches XXXXXXXXX
	// et aussi aux Random Pads

	~lemurTracksColorizeFunction = { |lemurAdress, track| [track].do { |t|
		if (~tracksPresetColorModel1.includes(t), {
			lemurAdress.sendMsg( *[ [ ~lemurSwitchesNames[t] /*"/Track/Switches0"*/] ++ ["@colors"] ++ ( ~nbOfSeqs.collect { |p| ~lemurColors[~lemurSwitchesMaps[p]] }; ) ].flatten(1) );
			[4, 5, 6, 14, 19, 20, 25, 27, 28, 30, 63, 64, 75, 77, 81, 129, 130, 133, 143, 149, 150, 163, 194, 199, 200, 208, 209, 215, 216, 217, 218, 220, 221, 224, 228, 233, 234].do { |i| lemurAdress.sendMsg( *[ [ ~lemurSwitchesTextNames[track][i] ] ++ ["@color"] ++ [/*~orangeLemurColor*/~yellowLemurColor] ].flatten(1) ) }; // Colorisation du texte des séquneces les plus importantes
		},{
			lemurAdress.sendMsg( *[ [ ~lemurSwitchesNames[t] /*"/Track/Switches0"*/] ++ ["@colors"] ++
				if (~presetSeqRandList[t] == 0, { ~nbOfSeqs.collect { ~blackLemurColor };
				},{
					~nbOfSeqs.collect { |i| if (~presetSeqRandList[t][~lemurSwitchesMaps[i]].notNil, {~redLemurColor3 }, { ~blackLemurColor } ) };
				});
				// ~presetSeqRandList[~tracksValue].size
			].flatten(1) );
		})
	}};
	// ~lemurTracksColorizeFunction.(~lemurAdress1, 0);



	// Envoi des noms des séquences au LEMUR XXXXXXXXX

	// ~presetSelection[0][0+1].split($|)[0]
	// ~presetSelection[0][0+1].split($|)[1].stripWhiteSpace
	// ~presetSelection[0].size
	// ~lemurAdress1.sendMsg( *[ [ ~lemurSwitchesNames[0] ] ++ ["@labels"] ++ ( 240.collect { |p| var text = ~presetSelection[0][~lemurSwitchesMaps[p]]; (~lemurSwitchesMaps[p]+1).asString }; ) ].flatten(1) );
	// ~lemurAdress1.sendMsg( *[ [ ~lemurSwitchesNames[0] ] ++ ["@labels"] ++ ( 200.collect { |p| var text = ~presetSelection[0][p]; ([~lemurSwitchesMaps[p]]+1).asString + (" - ") + text.split($|).last.split($ )[1] + (" - ") + text.split($|)[0] + "s /" + text.split($|)[1].stripWhiteSpace + ("\n") + text.split($ ).last }; ) ].flatten(1) ); // impossile d'afficher autant de texte

	~lemurTracksSeqNamesFunction = { |lemurAdress, track| [track].do { |t|
		240.do { |i| var text = ~presetSelection[t][~lemurSwitchesMaps[i]]; if (text == 0, {text = " |" }); // text.postln; ~lemurSwitchesTextPos[i].postln;
			/*~lemurAdress1*/lemurAdress.sendMsg( *[ [ ~lemurSwitchesTextNames[t][~lemurSwitchesMaps[i]] ] ++ ["@content"] ++ [(~lemurSwitchesMaps[i]+1).asString + (" - ") + text.split($|).last.split($ )[1] + (" - ") + text.split($|)[0] + "s /" + text.split($|)[1].stripWhiteSpace + ("\n") + text.split($ ).last ]].flatten(1) );
			/*~lemurAdress1*/lemurAdress.sendMsg( *[ [ ~lemurSwitchesTextNames[t][~lemurSwitchesMaps[i]] ] ++ ["@rect"] ++ ~lemurSwitchesTextPos[i] ].flatten(1) ); // rect {X,Y,W,H}
			// ~lemurAdress1.sendMsg( *[ [ ~lemurSwitchesTextNames[0][i] ] ++ ["@rect"] ++ [10, 10, 200, 100] ].flatten(1) ); // rect {X,Y,W,H}
	}}};
	// ~lemurTracksSeqNamesFunction.(~lemurAdress1, 0);
	// ~lemurTracksSeqNamesFunction.(~lemurAdress1, 4);


	~lemurArrayOfFolderNames = ~arrayOfFolderNames2 /*++'Insultes'++'InsultesOMax'*/ /*++ 'Kik & Hit'*/ ++ ~kindOfFolders.collect{|item, i| (i+~arrayOfFolderNames2.size) +"-"+item} ++ ["ALL"];

	~lemurBufNamesFunction = { |lemurAdress|
		~lemurArrayOfFolderNames.do { |i, id|
			lemurAdress.sendMsg( *[ [ ~lemurBufSwitchesTextNames[id] ] ++ ["@content"] ++ [ (i.split($ )[0] + i.split($ )[1] + i.split($ )[2] + ("\n") + i.split($ )[3] + try {i.split($ )[4]}).replace(" nil","") ] ].flatten(1) );
		};
		/*70*/ /*~bufFolderSize*/ 105.do { |i|
			lemurAdress.sendMsg( *[ [ ~lemurBufSwitchesTextNames[i] ] ++ ["@rect"] ++ ~lemurBufSwitchesTextPos[i] ].flatten(1) ); // rect {X,Y,W,H}
		};
		// (70 - 70 /*~lemurArrayOfFolderNames.size*/).do { |i| i.postln };
		// ~lemurAdress1.sendMsg( *[ [ ~lemurBufSwitchesTextNames[0] ] ++ ["@content"] ++ [~lemurArrayOfFolderNames[0]] ].flatten(1) ); // rect {X,Y,W,H}
	};


	~lemurPresetNamesFunction = { |lemurAdress, textName, nb, nb2| 60.do { |i|
		var x, y; x = i %10; y = i.div(10);
		/*~lemurAdress1*/lemurAdress.sendMsg( *[ [ textName[i] ] ++ ["@content"] ++ [ ~presetVarsMatrices[nb].at(y@x).title; ] ].flatten(1) );
		/*~lemurAdress1*/lemurAdress.sendMsg( *[ [ textName[i] ] ++ ["@rect"] ++ ~lemurPresetSwitchesTextPos[nb2][i] ].flatten(1) ); // rect {X,Y,W,H}
		// ~lemurAdress1.sendMsg( *[ [ ~lemurBufSwitchesTextNames[0] ] ++ ["@content"] ++ [~lemurArrayOfFolderNames[0]] ].flatten(1) ); // rect {X,Y,W,H}
	}};



	// Receive Lemur Info and change selection in GUI XXXXXXXXX

	// OSCdef(\switches0, {|msg, time, addr, recvPort| ~test = msg.indexOfEqual(1).postln}, "/Track/Switches11/x", ~lemurAdress1);
	/*
	OSCdef(\switches0, {|msg, time, addr, recvPort| var a = msg.indexOfEqual(1);
	{~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
	~seqCompG1[~tracksValue].visibleOrigin = 0@( (a-10)*20).max(0)}.defer;
	}, "/Track/Switches0/x", ~lemurAdress1);
	*/

	// ~lemurSwitchesMaps2 = [ 0, 1, 2, 3, 4, 20, 21, 22, 23, 24, 40, 41, 42, 43, 44, 5, 6, 7, 8, 9, 25, 26, 27, 28, 29, 45, 46, 47, 48, 49, 10, 11, 12, 13, 14, 30, 31, 32, 33, 34, 50, 51, 52, 53, 54, 15, 16, 17, 18, 19, 35, 36, 37, 38, 39, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 80, 81, 82, 83, 84, 100, 101, 102, 103, 104, 65, 66, 67, 68, 69, 85, 86, 87, 88, 89, 105, 106, 107, 108, 109, 70, 71, 72, 73, 74, 90, 91, 92, 93, 94, 110, 111, 112, 113, 114, 75, 76, 77, 78, 79, 95, 96, 97, 98, 99, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 140, 141, 142, 143, 144, 160, 161, 162, 163, 164, 125, 126, 127, 128, 129, 145, 146, 147, 148, 149, 165, 166, 167, 168, 169, 130, 131, 132, 133, 134, 150, 151, 152, 153, 154, 170, 171, 172, 173, 174, 135, 136, 137, 138, 139, 155, 156, 157, 158, 159, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 200, 201, 202, 203, 204, 220, 221, 222, 223, 224, 185, 186, 187, 188, 189, 205, 206, 207, 208, 209, 225, 226, 227, 228, 229, 190, 191, 192, 193, 194, 210, 211, 212, 213, 214, 230, 231, 232, 233, 234, 195, 196, 197, 198, 199, 215, 216, 217, 218, 219, 235, 236, 237, 238, 239, 240 ];
	~lemurSwitchesMaps2 = [ 0, 1, 2, 3, 4, 5, 21, 22, 23, 24, 25, 41, 42, 43, 44, 45, 6, 7, 8, 9, 10, 26, 27, 28, 29, 30, 46, 47, 48, 49, 50, 11, 12, 13, 14, 15, 31, 32, 33, 34, 35, 51, 52, 53, 54, 55, 16, 17, 18, 19, 20, 36, 37, 38, 39, 40, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 81, 82, 83, 84, 85, 101, 102, 103, 104, 105, 66, 67, 68, 69, 70, 86, 87, 88, 89, 90, 106, 107, 108, 109, 110, 71, 72, 73, 74, 75, 91, 92, 93, 94, 95, 111, 112, 113, 114, 115, 76, 77, 78, 79, 80, 96, 97, 98, 99, 100, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 141, 142, 143, 144, 145, 161, 162, 163, 164, 165, 126, 127, 128, 129, 130, 146, 147, 148, 149, 150, 166, 167, 168, 169, 170, 131, 132, 133, 134, 135, 151, 152, 153, 154, 155, 171, 172, 173, 174, 175, 136, 137, 138, 139, 140, 156, 157, 158, 159, 160, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 201, 202, 203, 204, 205, 221, 222, 223, 224, 225, 186, 187, 188, 189, 190, 206, 207, 208, 209, 210, 226, 227, 228, 229, 230, 191, 192, 193, 194, 195, 211, 212, 213, 214, 215, 231, 232, 233, 234, 235, 196, 197, 198, 199, 200, 216, 217, 218, 219, 220, 236, 237, 238, 239, 240 ]; // Le 0 du départ n'est pas pris en compte car l'index recçu du Lemur est au minimum de 1

	~lemurSwitchesMapsPatch3 = [ 0, 1, 2, 3, 4, 15, 16, 17, 18, 19, 30, 31, 32, 33, 34, 45, 46, 47, 48, 49, 5, 6, 7, 8, 9, 20, 21, 22, 23, 24, 35, 36, 37, 38, 39, 50, 51, 52, 53, 54, 10, 11, 12, 13, 14, 25, 26, 27, 28, 29, 40, 41, 42, 43, 44, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 75, 76, 77, 78, 79, 90, 91, 92, 93, 94, 105, 106, 107, 108, 109, 65, 66, 67, 68, 69, 80, 81, 82, 83, 84, 95, 96, 97, 98, 99, 110, 111, 112, 113, 114, 70, 71, 72, 73, 74, 85, 86, 87, 88, 89, 100, 101, 102, 103, 104, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 135, 136, 137, 138, 139, 150, 151, 152, 153, 154, 165, 166, 167, 168, 169, 125, 126, 127, 128, 129, 140, 141, 142, 143, 144, 155, 156, 157, 158, 159, 170, 171, 172, 173, 174, 130, 131, 132, 133, 134, 145, 146, 147, 148, 149, 160, 161, 162, 163, 164, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 195, 196, 197, 198, 199, 210, 211, 212, 213, 214, 225, 226, 227, 228, 229, 185, 186, 187, 188, 189, 200, 201, 202, 203, 204, 215, 216, 217, 218, 219, 230, 231, 232, 233, 234, 190, 191, 192, 193, 194, 205, 206, 207, 208, 209, 220, 221, 222, 223, 224, 235, 236, 237, 238, 239 ];
	// ~lemurSwitchesMapsPatch4.size
	/*(
	var a = 52-1;
	a = ~lemurSwitchesMapsPatch3[a];
	// ~lemurAdress1.sendMsg( *[["/Tracks/Seqs1/CS1/Switches1/x"] ++ ((0 ! a) ++ 1 ++ (0 ! (240-a)))].flatten(1) );
	~lemurAdress1.sendMsg( *[[~lemurSwitchesValues[0]] ++ ((0 ! a) ++ 1 ++ (0 ! (240-a)))].flatten(1) );
	)*/
	// ~lemurAdress1.sendMsg( *[["/Tracks/Seqs1/CS1/Switches1/x"] ++ ({2.rand} ! 240)].flatten(1) );
	// ~lemurOSCdefSwitchesNames[0]
	~lemurSwitchesMapsPatch4 = [ 0, 1, 2, 3, 4, 5, 16, 17, 18, 19, 20, 31, 32, 33, 34, 35, 46, 47, 48, 49, 50, 6, 7, 8, 9, 10, 21, 21, 23, 24, 25, 36, 37, 38, 39, 40, 51, 52, 53, 54, 55, 11, 12, 13, 14, 15, 26, 27, 28, 29, 30, 41, 42, 43, 44, 45, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 76, 77, 78, 79, 80, 91, 92, 93, 94, 95, 106, 107, 108, 109, 110, 66, 67, 68, 69, 70, 81, 82, 83, 84, 85, 96, 97, 98, 99, 100, 111, 112, 113, 114, 115, 71, 72, 73, 74, 75, 86, 87, 88, 89, 90, 101, 102, 103, 104, 105, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 136, 137, 138, 139, 140, 151, 152, 153, 154, 155, 166, 167, 168, 169, 170, 126, 127, 128, 129, 130, 141, 142, 143, 144, 145, 156, 157, 158, 159, 160, 171, 172, 173, 174, 175, 131, 132, 133, 134, 135, 146, 147, 148, 149, 150, 161, 162, 163, 164, 165, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 196, 197, 198, 199, 200, 211, 212, 213, 214, 215, 226, 227, 228, 229, 230, 186, 187, 188, 189, 190, 201, 202, 203, 204, 205, 216, 217, 218, 219, 220, 231, 232, 233, 234, 235, 191, 192, 193, 194, 195, 206, 207, 208, 209, 210, 221, 222, 223, 224, 225, 236, 237, 238, 239, 240 ];





	// ~lemurNewSeqs = 0 ! ~nbOfTracksX2; // nécessaire de le déclarer au préalable avant dans la GUI
	// ~lemurPresetSeqLength  = 0 ! ~nbOfTracksX2; // nécessaire de le déclarer au préalable avant dans la GUI

	/*
	~lemurSilenceSeqs = 0 ! 19 ! ~nbOfTracksX2; // supprimé car trop compliqué
	~lemurSilenceGSeqs = 0 ! ~nbOfTracksX2;
	*/

	~lemurTracksReceiveSwitchesFunction = { |lemurAdress, track, switchName| [track].do { |t|
		OSCdef(switchName.envirGet[t]/*\switches0*/, {|msg, time, addr, recvPort|
			var a, b, c, m, test;

			// msg.cs; msg.indexOfEqual(1).postln; msg.indicesOfEqual(1).last.postln;

			a = msg.indexOfEqual(1); // a.postln;
			if (a.notNil, {

				a = ~lemurSwitchesMaps2[a]; // a.postln;

				{
					/*if (t == ~tracksValue, { ~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) ); ~seqComp5.visibleOrigin = 0@( (a-1-4)*20).max(0) } );
					~presetSeqRangeViewG[t].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
					~seqCompG1[t].visibleOrigin = 0@( (a-10)*20).max(0);*/

					// msg.indicesOfEqual(1).size.postln; // Message d'Erreur si aucune sélection quand sélection multiple -> normal

					if (~lemurTracksRadioSwitches[t] == 0 or: { msg.indicesOfEqual(1).size == 1 }, {

						~lemurNewSeqs[t] = 0;

						if (t == ~tracksValue, { ~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([a-1, a]) ).doAction; ~seqComp5.visibleOrigin = 0@( (a-1-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[t].value_(~presetSeqRangeSpec.unmap([a-1, a]) ).doAction; // .doAction necessaire pour que les infos de piste du Lemur1 se répercute sur le Lemur 2 ????????????
						});
						~seqCompG1[t].visibleOrigin = 0@( (a-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin);

						~lemurNewSeqs[t] = a;

					},{

						m = msg.indicesOfEqual(1)/*.postln*/;
						c = m.size;
						~lemurNewSeqs[t] = 0 ! c;

						m.do { |i, id| var e;
							e = ~lemurSwitchesMaps2[i];
							~lemurNewSeqs[t][id] = e;
						};

						a = ~lemurNewSeqs[t].minItem; // a.postln;
						b = ~lemurNewSeqs[t].maxItem; // b.postln;

						if (t == ~tracksValue, { ~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([a-1, b]) ).doAction; /*~seqComp5.visibleOrigin = 0@( (b-1-4)*20).max(0)*/
						},{
							~presetSeqRangeViewG[t].value_(~presetSeqRangeSpec.unmap([a-1, b]) ).doAction; // .doAction necessaire pour que les infos de piste du Lemur1 se répercute sur le Lemur 2 ????????????
						});
						~seqCompG1[t].visibleOrigin = 0@( (~lemurNewSeqs[t][0]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin);

						/*
						~lemurPresetSeqLength[1] = ~lemurNewSeqs[1].collect { |i| i.dup(~presetSeqNbSelectDurValue[1][i]) }.flat.differentiate;
						~lemurPresetSeqLength[t].removeAt(0);
						~lemurPresetSeqLength[t].addFirst(0);
						~lemurNewSeqs[1].collect { |i, id| Array.series(~presetSeqNbSelectDurValue[1][id], i, 0) }
						*/

						// ~lemurPresetSeqLength[t] = ~lemurNewSeqs[t].collect { |i, id| i ! ~presetSeqNbSelectDurValue[t][i-1] }.flat;

						// ~presetSeqNb2LemurValue[t]  = ~lemurNewSeqs[t].collect { |i, id| ~presetSeqNb2Value[t][i-1] };
						// ~lemurPresetSeqLength[t] = ~lemurNewSeqs[t][~presetSeqNb2LemurValue[t].order].collect { |i, id| i ! ~presetSeqNbSelectDurValue[t][i-1] }.flat;
						// Plus necessaire - déjà dans ~presetSeqRangeViewG et d'autres

						// supprimé car trop compliqué
						// Durées des silences // 0.125 / 0.25 / 0.5 / 0.75 / 1
						// 0.125 / 0.25 / 0.5 / 0.75 / 1
						// 1.5 / 2 / 2.5 / 3 / 3.5
						// 5 / 7
						// 4 / 5 / 6 / 7 / 10 // si plusieurs sélectionnée s'additionne ? non -> prend en compte le plus bas silence
						// Modéles // alternance entre silence et les séquences // 5 modéles
						// 1 Prise en compte du 1er silence sélectionné en alternance en boucle avec la séquence sonore / alternance en boucle entre les séquences silence et sonores
						// + séquences de silence spécifique dans la Track au delà de 20

						// si le modéle comprend la séquence 16, la retire
						// si la séquence inclut la séquence 1, le silence est de 1
						// marquage des séquence de silence avec includes pour création d'une liste globale


						/*if (t.odd and: {~lemurNewSeqs[t].includes(20)} and: {~lemurNewSeqs[t].maxItem > 20}, {

						if (~lemurNewSeqs[t].includes(1), { ~lemurSilenceSeqs[t][0] = 1},  { ~lemurSilenceSeqs[t][0] = 0});
						if (~lemurNewSeqs[t].includes(2), { ~lemurSilenceSeqs[t][1] = 1},  { ~lemurSilenceSeqs[t][1] = 0});
						if (~lemurNewSeqs[t].includes(3), { ~lemurSilenceSeqs[t][2] = 1},  { ~lemurSilenceSeqs[t][2] = 0});
						if (~lemurNewSeqs[t].includes(4), { ~lemurSilenceSeqs[t][3] = 1},  { ~lemurSilenceSeqs[t][3] = 0});
						if (~lemurNewSeqs[t].includes(5), { ~lemurSilenceSeqs[t][4] = 1},  { ~lemurSilenceSeqs[t][4] = 0});
						if (~lemurNewSeqs[t].includes(6), { ~lemurSilenceSeqs[t][5] = 1},  { ~lemurSilenceSeqs[t][5] = 0});
						if (~lemurNewSeqs[t].includes(7), { ~lemurSilenceSeqs[t][6] = 1},  { ~lemurSilenceSeqs[t][6] = 0});
						if (~lemurNewSeqs[t].includes(8), { ~lemurSilenceSeqs[t][7] = 1},  { ~lemurSilenceSeqs[t][7] = 0});
						if (~lemurNewSeqs[t].includes(9), { ~lemurSilenceSeqs[t][8] = 1},  { ~lemurSilenceSeqs[t][8] = 0});
						if (~lemurNewSeqs[t].includes(10), { ~lemurSilenceSeqs[t][9] = 1},  { ~lemurSilenceSeqs[t][9] = 0});
						if (~lemurNewSeqs[t].includes(11), { ~lemurSilenceSeqs[t][10] = 1},  { ~lemurSilenceSeqs[t][10] = 0});
						if (~lemurNewSeqs[t].includes(12), { ~lemurSilenceSeqs[t][11] = 1},  { ~lemurSilenceSeqs[t][11] = 0});
						if (~lemurNewSeqs[t].includes(13), { ~lemurSilenceSeqs[t][12] = 1},  { ~lemurSilenceSeqs[t][12] = 0});
						if (~lemurNewSeqs[t].includes(14), { ~lemurSilenceSeqs[t][13] = 1},  { ~lemurSilenceSeqs[t][13] = 0});
						if (~lemurNewSeqs[t].includes(15), { ~lemurSilenceSeqs[t][14] = 1},  { ~lemurSilenceSeqs[t][14] = 0});
						if (~lemurNewSeqs[t].includes(16), { ~lemurSilenceSeqs[t][15] = 1},  { ~lemurSilenceSeqs[t][15] = 0});
						if (~lemurNewSeqs[t].includes(17), { ~lemurSilenceSeqs[t][16] = 1},  { ~lemurSilenceSeqs[t][16] = 0});
						if (~lemurNewSeqs[t].includes(18), { ~lemurSilenceSeqs[t][17] = 1},  { ~lemurSilenceSeqs[t][17] = 0});
						if (~lemurNewSeqs[t].includes(19), { ~lemurSilenceSeqs[t][18] = 1},  { ~lemurSilenceSeqs[t][18] = 0});

						// ~lemurSilenceSeqs[5][2] = 0; ~lemurSilenceSeqs[5][4] = 0

						~lemurSilenceGSeqs[t] = 19.collect { |i| if (~lemurSilenceSeqs[t][i] == 1, { i+1 }) };
						~lemurSilenceGSeqs[t].removeEvery([nil]);
						~lemurPresetSeqLength[t].removeEvery((1..20));

						// ~lemurSilenceGSeqs = [0, 1, 2].wrapAt(3)

						if (~lemurSilenceGSeqs[t].size > 0 and: {~lemurNewSeqs[t].size > 0}, {
						~lemurPresetSeqLength[t] = [/*~lemurNewSeqs*/~lemurPresetSeqLength[t].collect { |i, id| i ! ~presetSeqNbSelectDurValue[t][i-1] }.flat, ~lemurNewSeqs[t].size.collect { |i, id| ~lemurSilenceGSeqs[t].wrapAt(i) }.flat /*1 /*liste globale*/ ! [ 1, 12, 15, 15].size*/].flop.flat;
						// ~lemurPresetSeqLength[t].collect { |i, id| i ! ~presetSeqNbSelectDurValue[t][i-1] }.flat.postln;
						// ~lemurNewSeqs[t].size.collect { |i, id| ~lemurSilenceGSeqs[t].wrapAt(i) }.flat.postln;
						});

						// ~lemurNewSeqs[1].size.collect { |i, id| ~lemurSilenceGSeqs[1].wrapAt(i) }.flat

						});*/


						/*[ 1, 12, 15, 15].collect { |i, id| i ! ~presetSeqNbSelectDurValue[5][i-1] }.flat;
						[[ 1, 12, 15, 15].collect { |i, id| i ! ~presetSeqNbSelectDurValue[5][i-1] }.flat, 1 /*liste globale*/ ! [ 1, 12, 15, 15].size].flop.flat;*/

						/*
						~lemurNewSeqs[5].collect { |i, id| i ! ~presetSeqNbSelectDurValue[5][i-1] }.flat;
						~presetSeqNbSelectDurValue[5]
						*/

					});

					if (~lemurNewSeqs[t].isInteger, {
						~presetSeqRangeViewG[t].background_(~sliderBackgroundColor).hilightColor_(Color.red); // ~presetSeqRangeViewG[(t*2)+1].background_(~sliderBackgroundColor).hilightColor_(Color.red);
					},{
						~presetSeqRangeViewG[t].background_(Color.magenta).hilightColor_(Color.blue); // ~presetSeqRangeViewG[(t*2)+1].background_(Color.magenta).hilightColor_(Color.blue)
					});


				}.defer;

			}, {
				("Aucune sélection dans piste"+ t.asString + "!!!").postln } ); // a.postln;

		}, ~lemurSwitchesValues[t], lemurAdress).fix; // .fix is a concise synonym for permanent = true
	}};



	OSCdef(\TrackNext, { |msg, time, addr, recvPort|
		var indicesOfTracks, indexOfTracks; // Pour switcher entre les pistes en train de jouer
		// var a = msg[1]; // .postln;
		if (msg[1] == 1, { // msg[1].postln;
			indicesOfTracks = ~playViewValue.indicesOfEqual(1);

			// ~playViewValue.indicesOfEqual(1).includes(~secondLemurX2Track)
			// {  0.01.wait;

			if (indicesOfTracks.notNil, {
				if (indicesOfTracks.includes(~secondLemurX2Track) and: {~lemurConnected2 == 1}, { indicesOfTracks.remove(~secondLemurX2Track) });
				indexOfTracks = indicesOfTracks.indexOfGreaterThan(~tracksValue);
				// indicesOfTracks.postln; indexOfTracks.postln;
				if (indexOfTracks.isNil, {
					// ~tracksView.valueAction_(indicesOfTracks[0])
					// ~lemurAdress1.sendMsg( "/TrackSwitch1/x", (indicesOfTracks[0]/2).asInteger);
					~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[0]/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-indicesOfTracks[0]/2-1).asInteger)) ++ 0) ].flatten(1) );
					{~tracksView.valueAction_(indicesOfTracks[0]);}.defer;
					// {~lemurConnected1 = 0; 0.1.wait; ~tracksView.valueAction_(indicesOfTracks[0]); ~lemurConnected1 = 1; }.fork(AppClock);
					// {~trackNextProtect = 1; ~tracksView.valueAction_(indicesOfTracks[0]); ~trackNextProtect = 0;}.defer;
					// [["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[0]/2).asInteger-1)) ++ 1 ++ (0 ! ((~nbOfTracks-(indicesOfTracks[0]/2).asInteger)))).flatten(1) ].postln; "a".postln;
					// ((0 ! ((indicesOfTracks[0]/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-indicesOfTracks[0]/2-1).asInteger))).postln;
				},{
					// ~tracksView.valueAction_(indicesOfTracks[indexOfTracks])
					// ~lemurAdress1.sendMsg( "/TrackSwitch1/x", (indicesOfTracks[indexOfTracks]/2).asInteger);
					// indexOfTracks.postln;

					~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[indexOfTracks]/2).asInteger)) ++ 1++ (0 ! (~nbOfTracksX2-indicesOfTracks[indexOfTracks]/2-1).asInteger) ++ 0) ].flatten(1) );
					{~tracksView.valueAction_(indicesOfTracks[indexOfTracks]);}.defer;

					// {~lemurConnected1 = 0; 0.2.wait; ~tracksView.valueAction_(indicesOfTracks[indexOfTracks]); ~lemurConnected1 = 1; }.fork(AppClock);
					// {~trackNextProtect = 1; ~tracksView.valueAction_(indicesOfTracks[indexOfTracks]); ~trackNextProtect = 0;}.defer;
					// ([["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[indexOfTracks]/2).asInteger-1)) ++ 1 ++ (0 ! ((~nbOfTracks-(indicesOfTracks[indexOfTracks]/2).asInteger)))) ].flatten(1)).postln;
					//  ~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ (0 ! 3-1) ++ 1 ++ (0 ! (8-3)) ].flatten(1)  );
					// ~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! (4.asInteger-1)) ++ 1++ (0 ! (4))) ].flatten(1) );
					// (0 ! (3-1)) ++ 1 ++ (0 ! (8-3))
					// ((0 ! ((indicesOfTracks[indexOfTracks]/2).asInteger)) ++ 1++ (0 ! ((~nbOfTracksX2-indicesOfTracks[indexOfTracks]/2).asInteger))).postln;
				});
			},{
				{~tracksView.valueAction_( ( ((0..~nbOfTracks-1)*2) + ~seqCompGABIndex)[((~tracksValue/2).asInteger+1).wrap(0,7)]);}.defer;
			});
		});
		//// }.fork(AppClock);
		// {~switchTrackssAllControlView.valueAction_(1)}.defer;
	}, "/TrackNext/x", ~lemurAdress1).fix;


	if (~lemurConnected2 == 1, {

		OSCdef(\TrackNextLemur2, { |msg, time, addr, recvPort|
			var indicesOfTracks, indexOfTracks, p; // Pour switcher entre les pistes en train de jouer

			if (msg[1] == 1, { // msg[1].postln;
				indicesOfTracks = ~playViewValue.indicesOfEqual(1);

				if (indicesOfTracks.notNil, {
					if (indicesOfTracks.includes(~tracksValue), { indicesOfTracks.remove(~tracksValue) });

					indexOfTracks = indicesOfTracks.indexOfGreaterThan(~secondLemurX2Track);

					// [ 0, 11 ].indexOfGreaterThan(~secondLemurX2Track);
					// indicesOfTracks.postln; indexOfTracks.postln;

					if (indexOfTracks.isNil, {

						~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[0]/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-indicesOfTracks[0]/2-1).asInteger)) ++ 0) ].flatten(1) );
						~secondLemurX2Track = indicesOfTracks[0];
						// {~tracksView.valueAction_(indicesOfTracks[0]);}.defer;

					},{
						~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((indicesOfTracks[indexOfTracks]/2).asInteger)) ++ 1++ (0 ! (~nbOfTracksX2-indicesOfTracks[indexOfTracks]/2-1).asInteger) ++ 0) ].flatten(1) );
						~secondLemurX2Track = indicesOfTracks[indexOfTracks];
						// {~tracksView.valueAction_(indicesOfTracks[indexOfTracks]);}.defer;
					});

					~secondLemurRawTrack = (~secondLemurX2Track/2).asInteger;

					{ ~updateSecondLemurTrack.(); }.defer; // Pourquoi besoin d'un defer sinon erreur d'un PopUpMenu ???

				},{ var tra = ~secondLemurRawTrack;
					if (~seqCompGABIndex[(tra+1).wrap(0,7)] == 0, { // possible de mettre a. idrectement (~nbOfTracks-1) ou ~nbOfTracksX2
						~secondLemurX2Track = ((tra+1)*2).wrap(0,15); tra = (tra+1).wrap(0,7); ~secondLemurRawTrack = tra;
						if (~tracksValue == ~secondLemurX2Track, { ~secondLemurX2Track = ((tra+1)*2).wrap(0,15); tra = (tra+1).wrap(0,7); ~secondLemurRawTrack = tra; });
					},{
						~secondLemurX2Track = (((tra+1)*2)+1).wrap(0,15); tra = (tra+1).wrap(0,7); ~secondLemurRawTrack = tra;
						if (~tracksValue == ~secondLemurX2Track, { ~secondLemurX2Track = (((tra+1)*2)+1).wrap(0,15); tra = (tra+1).wrap(0,7); ~secondLemurRawTrack = tra; });
					});
					~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! tra) ++ 1++ (0 ! (~nbOfTracks-tra-1)) ++ 0) ].flatten(1) ); // tra.postln;
				});
			});

		}, "/TrackNext/x", ~lemurAdress2).fix;

	});



	OSCdef(\TrackSwitch1, { |msg, time, addr, recvPort| var a;
		a = (msg.indexOfEqual(1)-1);
		b = a * 2;
		if (~seqCompGABIndex[a] == 1, { b = b +1});

		// if (~trackNextProtect == 0, {{~tracksView.valueAction_(a)}.defer;});
		// If (b != ~secondLemurX2Track, {
		// ~tracksValue = b; // Pourquoi necessaire ???
		{~tracksView.valueAction_(b);
			/*0.1.wait; ~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((b/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-b/2-1).asInteger)) ++ 0) ].flatten(1) ); 0.1.wait; ~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((b/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-b/2-1).asInteger)) ++ 0) ].flatten(1) );*/
		}.fork(AppClock)/*defer*/;
		// ~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((b/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-b/2-1).asInteger)) ++ 0) ].flatten(1) );
		// });

	}, "/TrackSwitch1/x", ~lemurAdress1).fix;
	// ~lemurAdress1.sendMsg( "/TrackSwitch1/x", 1, 0, 0, 0, 0, 0, 0, 0  );



	OSCdef(\PresetSwitch1, { |msg, time, addr, recvPort| var a;
		a = (msg.indexOfEqual(1)-1);

		~tabbedPresetVarsPageLemur11 = a;
		{~tabbedPresetVars.focus(a)}.defer; // Action sur la GUI

	}, "/PresetSwitch1/x", ~lemurAdress1).fix;

	OSCdef(\PresetSwitch2, { |msg, time, addr, recvPort| var a;
		a = (msg.indexOfEqual(1)-1);

		~tabbedPresetVarsPageLemur12 = a;

	}, "/PresetSwitch2/x", ~lemurAdress1).fix;



	if (~lemurConnected2 == 1, {

		~secondLemurRawTrack = 2; // nécessaire de le déclarer au préalable avant le pattern - et réinitialisé dans le Lemur et pattern aussi
		~secondLemurX2Track = 4; // nécessaire de le déclarer au préalable avant le pattern - et réinitialisé dans le Lemur et pattern aussi
		~prevLemur2Track = 4;

		OSCdef(\TrackSwitch1Lemur2, { |msg, time, addr, recvPort| var a, b;
			a = (msg.indexOfEqual(1)-1);
			~secondLemurRawTrack = a;
			b = a * 2;
			if (~seqCompGABIndex[a] == 1, { b = b +1});
			~secondLemurX2Track = b;
			if (~secondLemurX2Track == ~tracksValue, { ~secondLemurX2Track = ~prevLemur2Track; ~secondLemurRawTrack = (~secondLemurX2Track/2).asInteger }, { ~secondLemurRawTrack = (b/2).asInteger } );
			~prevLemur2Track = ~secondLemurX2Track;
			if (~seqCompGABIndex[a] == 1, { ~lemurAdress2.sendMsg( ~lemurABSwitchesValues[a],  1); }, { ~lemurAdress2.sendMsg( ~lemurABSwitchesValues[a],  0); });
			// Pour être sur la même piste AB que le 1er contrôleur Lemur - décommenter la dernière ligne pour rendre le second Lemur indépendant

			{ ~updateSecondLemurTrack.(); }.defer; // Pourquoi besoin d'un defer sinon erreur d'un PopUpMenu ???

			{0.3.wait; ~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((~secondLemurX2Track/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-(~secondLemurX2Track)/2-1).asInteger)) ++ 0) ].flatten(1) ); 0.3.wait; ~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((~secondLemurX2Track/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-(~secondLemurX2Track)/2-1).asInteger)) ++ 0) ].flatten(1) ); 0.3.wait; ~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((~secondLemurX2Track/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-(~secondLemurX2Track)/2-1).asInteger)) ++ 0) ].flatten(1) ); 0.6.wait; ~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ ((0 ! ((~secondLemurX2Track/2).asInteger)) ++ 1 ++ (0 ! ((~nbOfTracksX2-(~secondLemurX2Track)/2-1).asInteger)) ++ 0) ].flatten(1) ); }.fork(AppClock);

			// Afin de revenir tant que l'on n'appuie pas plus de 1 seconde sur la piste courante du second Lemur

		}, "/TrackSwitch1/x", ~lemurAdress2).fix;



		OSCdef(\PresetSwitch1Lemur2, { |msg, time, addr, recvPort| var a;
			a = (msg.indexOfEqual(1)-1);

			~tabbedPresetVarsPageLemur21 = a;
			{~tabbedPresetVars.focus(a)}.defer; // Action sur la GUI

		}, "/PresetSwitch1/x", ~lemurAdress2).fix;

		OSCdef(\PresetSwitch2Lemur2, { |msg, time, addr, recvPort| var a;
			a = (msg.indexOfEqual(1)-1);

			~tabbedPresetVarsPageLemur22 = a;

		}, "/PresetSwitch2/x", ~lemurAdress2).fix;
		// ~lemurAdress1.sendMsg( "/TrackSwitch1/x", 1, 0, 0, 0, 0, 0, 0, 0  );

	});



	// ~lemurTracksRadioSwitches = 0 ! ~nbOfTracksX2; // nécessaire de le déclarer au préalable dans la GUI avant ~presetSeqRangeViewG

	~lemurTracksRadioSwitchesFunction = { ~nbOfTracksX2.do { |t|
		OSCdef(~lemurOSCdefRadioSwitchesNames[t], {|msg, time, addr, recvPort|
			var a = msg[1]/*.postln*/;
			~lemurTracksRadioSwitches[t] = a;
			/*
			{
			if (a == 1, { ~presetSeqRangeViewG[t*2].background_(Color.magenta).hilightColor_(Color.blue); ~presetSeqRangeViewG[(t*2)+1].background_(Color.magenta).hilightColor_(Color.blue)
			},{
			~presetSeqRangeViewG[t*2].background_(~sliderBackgroundColor).hilightColor_(Color.red); ~presetSeqRangeViewG[(t*2)+1].background_(~sliderBackgroundColor).hilightColor_(Color.red);
			})
			}.defer;
			*/
		}, ~lemurRadioSwitchesValues[t], ~lemurAdress1).fix;
	}};
	// ~lemurTracksRadioSwitchesFunction.(); // seulement 8 pistes



	~lemurABSwitchesValues = [ "/Tracks/Switch1AB/x", "/Tracks/Switch2AB/x", "/Tracks/Switch3AB/x", "/Tracks/Switch4AB/x", "/Tracks/Switch5AB/x", "/Tracks/Switch6AB/x", "/Tracks/Switch7AB/x", "/Tracks/Switch8AB/x" ];

	OSCdef(\Switch1AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[0] == 1, {~tracksView.valueAction_(0)})}, {if (~seqCompGABIndex[0] == 0, {~tracksView.valueAction_(1)}) }) }.defer;
	}, "/Tracks/Switch1AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch2AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[1] == 1, {~tracksView.valueAction_(2)})}, {if (~seqCompGABIndex[1] == 0, {~tracksView.valueAction_(3)}) }) }.defer;
	}, "/Tracks/Switch2AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch3AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[2] == 1, {~tracksView.valueAction_(4)})}, {if (~seqCompGABIndex[2] == 0, {~tracksView.valueAction_(5)}) }) }.defer;
	}, "/Tracks/Switch3AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch4AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[3] == 1, {~tracksView.valueAction_(6)})}, {if (~seqCompGABIndex[3] == 0, {~tracksView.valueAction_(7)}) }) }.defer;
	}, "/Tracks/Switch4AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch5AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[4] == 1, {~tracksView.valueAction_(8)})}, {if (~seqCompGABIndex[4] == 0, {~tracksView.valueAction_(9)}) }) }.defer;
	}, "/Tracks/Switch5AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch6AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[5] == 1, {~tracksView.valueAction_(10)})}, {if (~seqCompGABIndex[5] == 0, {~tracksView.valueAction_(11)}) }) }.defer;
	}, "/Tracks/Switch6AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch7AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[6] == 1, {~tracksView.valueAction_(12)})}, {if (~seqCompGABIndex[6] == 0, {~tracksView.valueAction_(13)}) }) }.defer;
	}, "/Tracks/Switch7AB/x", ~lemurAdress1).fix;

	OSCdef(\Switch8AB, {|msg, time, addr, recvPort| var a = msg[1];
		{if (a== 0, {if (~seqCompGABIndex[7] == 1, {~tracksView.valueAction_(14)})}, {if (~seqCompGABIndex[7] == 0, {~tracksView.valueAction_(15)}) }) }.defer;
	}, "/Tracks/Switch8AB/x", ~lemurAdress1).fix;



	OSCdef(\RatR, {|msg, time, addr, recvPort| var a = msg[1]; // Différent du Rand de la GUI, qui n'agit que sur la sélection, apparemment ???
		// ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
		{ if (a == 1, {~ratRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/RatR/x", ~lemurAdress1).fix;

	OSCdef(\StrR, {|msg, time, addr, recvPort| var a = msg[1];
		{ if (a == 1, {~strRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/StrR/x", ~lemurAdress1).fix;

	OSCdef(\BufR, {|msg, time, addr, recvPort| var a = msg[1];
		{ if (a == 1, {~bufRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/BufR/x", ~lemurAdress1).fix;

	OSCdef(\OffR, {|msg, time, addr, recvPort| var a = msg[1];
		{ if (a == 1, {~offRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/OffR/x", ~lemurAdress1).fix;

	OSCdef(\SpaR, {|msg, time, addr, recvPort| var a = msg[1];
		{ if (a == 1, {~spaRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/SpaR/x", ~lemurAdress1).fix;

	OSCdef(\OutR, {|msg, time, addr, recvPort| var a = msg[1];
		{/*~outRandOnBothView*/ if (a == 1, {~outRandViewG[~tracksValue].valueAction_(1)}) }.defer;
	}, "/ParC/OutR/x", ~lemurAdress1).fix;

	// Ce bouton n'est pas updaté si la piste en cours n'est pas jouée ?????????
	OSCdef(\Cyc, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		if (~proPat[~tracksValue][~seqSeq[~tracksValue]] == 0, {b = 1}, {b = 0});
		{~proPatViewG[~tracksValue].valueAction_(b);
			if (~currentTab == 0, { ~proPatView.valueAction_(b) });
		}.defer;
	}, "/ParC/Cyc/x", ~lemurAdress1).fix;

	// Ce bouton n'est pas updaté si la piste en cours n'est pas jouée ?????????
	OSCdef(\Cyc2, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		if (~proSelect[~tracksValue][~seqSeq[~tracksValue]] == 0, {b = 1}, {b = 0});
		{~proSelectViewG[~tracksValue].valueAction_(b);
			if (~currentTab == 0, { ~proSelectView.valueAction_(b) });
		}.defer;
	}, "/ParC/Cyc2/x", ~lemurAdress1).fix;

	// ~seqSeq[~tracksValue] n'est peut être pas initialisé DANS LA gui ou LemurColors XXXXXXXXXXXX

	OSCdef(\Loop, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		if (~legLoop[~tracksValue][~seqSeq[~tracksValue]] == 0, {b = 1}, {b = 0});
		{~legLoopView.valueAction_(b);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
		}.defer;
	}, "/ParC/Loop/x", ~lemurAdress1).fix;

	OSCdef(\Gliss, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		if (~ratSynth[~tracksValue][~seqSeq[~tracksValue]] == 0, {b = 1}, {b = 0});
		{~ratSynthView.valueAction_(b);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
		}.defer;
	}, "/ParC/Gliss/x", ~lemurAdress1).fix;



	OSCdef(\Rtm, {|msg, time, addr, recvPort| var a = msg[1].max(0.15);
		// ~dur
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~rtmMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~rtmMulView.valueAction_(a) });
		}.defer;
	}, "/Rtm/x", ~lemurAdress1).fix;

	OSCdef(\RtmMenu, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~rtmMulPresetViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~rtmMulView.valueAction_(~rtmMulViewG[~tracksValue].value) });
	}.defer;}
	}, "/ParC/RtmMenuC/RtmMenuP/x", ~lemurAdress1).fix;

	OSCdef(\Pro, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~proMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~proMulView.valueAction_(a) });
		}.defer;
	}, "/Pro/x", ~lemurAdress1).fix;

	OSCdef(\Hit, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~proBjorViewG[~tracksValue].valueAction_(a); // vraiment nécessaire de marquer en rouge la séquence pour ce paramètre parfois non audible ??????
			if (~currentTab == 0, { ~proBjorView.valueAction_(a) });
		}.defer;
	}, "/Hit/x", ~lemurAdress1).fix;

	OSCdef(\Off, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~proBjor2ViewG[~tracksValue].valueAction_(a); // vraiment nécessaire de marquer en rouge la séquence pour ce paramètre parfois non audible ??????
			if (~currentTab == 0, { ~proBjor2View.valueAction_(a) });
		}.defer;
	}, "/Off/x", ~lemurAdress1).fix;

	OSCdef(\Leg, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~legMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~legMulView.valueAction_(a) });
		}.defer;
	}, "/Leg/x", ~lemurAdress1).fix;

	OSCdef(\LegMenu, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~legMulPresetViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~legMulView.valueAction_(~legMulViewG[~tracksValue].value) });
	}.defer;}
	}, "/ParC/LegMenuC/LegMenuP/x", ~lemurAdress1).fix;

	OSCdef(\Buf, {|msg, time, addr, recvPort| var a = msg[1] * (~bufFolderSize1);
		{ ~bufFolderView.valueAction_(a);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
		}.defer;
	}, "/Buf/x", ~lemurAdress1).fix;

	OSCdef(\BufMenu, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1).min(~lemurArrayOfFolderNames.size-1) /*.postln*/;
		// Mise en place d'une protection avec .min(~lemurArrayOfFolderNames.size-1) si tout le menu n'est pas rempli // A optimiser XXX
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		{ ~bufFolderView.valueAction_(a);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
	}.defer;}
	}, "/ParC/BufMenuC/BufMenuP/x", ~lemurAdress1).fix;



	OSCdef(\Rat, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~ratMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~ratMulView.valueAction_(a) });
		}.defer;
	}, "/Rat/x", ~lemurAdress1).fix;

	OSCdef(\Str, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~strMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~strMulView.valueAction_(a) });
		}.defer;
	}, "/Str/x", ~lemurAdress1).fix;

	OSCdef(\Cen, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~cenMulViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~cenMulView.valueAction_(a) });
		}.defer;
	}, "/Cen/x", ~lemurAdress1).fix;

	OSCdef(\PanMenu, {|msg, time, addr, recvPort| var a = msg[1]; /*(msg.indexOfEqual(1)-1).postln;*/
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~panRangePresetViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~panRangePresetView.valueAction_(a) });
		}.defer;
	}, "/ParC/PanMenu/selection", ~lemurAdress1).fix;

	OSCdef(\SpaMenu, {|msg, time, addr, recvPort| var a = msg[1];
		{~multiStereoControlView[(~tracksValue/2).asInteger].valueAction_(a) }.defer
	}, "/ParC/SpaMenu/x", ~lemurAdress1).fix;

	OSCdef(\SpaMenu2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{~spaRangePresetViewG[~tracksValue].valueAction_(a);
			if (~currentTab == 0, { ~spaRangePresetView.valueAction_(a) });
	}.defer;}
	}, "/ParC/SpaMenuC2/SpaMenuP2/x", ~lemurAdress1).fix;

	OSCdef(\Index, {|msg, time, addr, recvPort| var a = msg[1];
		{~gblSeqIndexView.valueAction_(a);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
		}.defer;
	}, "/Index/x", ~lemurAdress1).fix;

	OSCdef(\Range, {|msg, time, addr, recvPort| // var a = msg.postln;
		{~gblSeqView.valueAction_([msg[1], msg[2]]);
			if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
		}.defer;
	}, "/ParC/Range/x", ~lemurAdress1).fix;

	OSCdef(\RatPlus, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~controlBusTypeSignView.valueAction_(a);}.defer;
	}, "/ParC/RCont/RatPlus/x", ~lemurAdress1).fix;

	OSCdef(\RatStrCen, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~controlBusTypeArgView.valueAction_(a);}.defer;
	}, "/ParC/RCont/RatStrCen/selection", ~lemurAdress1).fix;

	OSCdef(\RatStrCenAlgo, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~controlRandFuncView.valueAction_(a);}.defer;
	}, "/ParC/RCont/RatStrCenAlgo/selection", ~lemurAdress1).fix;

	OSCdef(\TrackOtherAll, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~trigAllView.valueAction_(a);}.defer;
	}, "/ParC/RCont/TrackOtherAll/selection", ~lemurAdress1).fix;



	if (~lemurConnected2 == 1, {

		OSCdef(\RatRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, {~ratRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/RatR/x", ~lemurAdress2).fix;

		OSCdef(\StrRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, {~strRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/StrR/x", ~lemurAdress2).fix;

		OSCdef(\BufRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, {~bufRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/BufR/x", ~lemurAdress2).fix;

		OSCdef(\OffRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{if (a == 1, { ~offRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/OffR/x", ~lemurAdress2).fix;

		OSCdef(\SpaRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{if (a == 1, { ~spaRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/SpaR/x", ~lemurAdress2).fix;

		OSCdef(\OutRLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{/*~outRandOnBothView*/ if (a == 1, { ~outRandViewG[~secondLemurX2Track].valueAction_(1)}) }.defer;
		}, "/ParC/OutR/x", ~lemurAdress2).fix;

		// Ce bouton n'est pas updaté si la piste en cours n'est pas jouée ?????????
		OSCdef(\CycLemur2, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			if (~proPat[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {b = 1}, {b = 0});
			{~proPatViewG[~secondLemurX2Track].valueAction_(b);
				if (~secondLemurX2Track == ~tracksValue /*~currentTab == 0*/, { ~proPatView.valueAction_(b) });
			}.defer;
		}, "/ParC/Cyc/x", ~lemurAdress2).fix;

		// Ce bouton n'est pas updaté si la piste en cours n'est pas jouée ?????????
		OSCdef(\Cyc2Lemur2, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			if (~proSelect[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {b = 1}, {b = 0});
			{~proSelectViewG[~secondLemurX2Track].valueAction_(b);
				if (~secondLemurX2Track == ~tracksValue /*~currentTab == 0*/, { ~proSelectView.valueAction_(b) });
			}.defer;
		}, "/ParC/Cyc2/x", ~lemurAdress2).fix;

		// ~seqSeq[~tracksValue] n'est peut être pas initialisé DANS LA GUI ou LemurColors XXXXXXXXXXXX

		OSCdef(\LoopLemur2, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			if (~legLoop[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {b = 1}, {b = 0});
			{ if (~secondLemurX2Track == ~tracksValue, {~legLoopView.valueAction_(b)} );
				if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });
			}.defer;
		}, "/ParC/Loop/x", ~lemurAdress2).fix;

		OSCdef(\GlissLemur2, {|msg, time, addr, recvPort| var a = msg[1]/*.postln*/; var b;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			if (~ratSynth[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {b = 1}, {b = 0});
			{ if (~secondLemurX2Track == ~tracksValue, {~ratSynthView.valueAction_(b)} );
				if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });
			}.defer;
		}, "/ParC/Gliss/x", ~lemurAdress2).fix;



		OSCdef(\RtmLemur2, {|msg, time, addr, recvPort| var a = msg[1].max(0.15);
			// ~dur
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~rtmMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~rtmMulView.valueAction_(a) });
			}.defer;
		}, "/Rtm/x", ~lemurAdress2).fix;

		OSCdef(\RtmMenuLemur2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~rtmMulPresetViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~rtmMulView.valueAction_(~rtmMulViewG[~secondLemurX2Track].value) });
		}.defer;}
		}, "/ParC/RtmMenuC/RtmMenuP/x", ~lemurAdress2).fix;

		OSCdef(\ProLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~proMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~proMulView.valueAction_(a) });
			}.defer;
		}, "/Pro/x", ~lemurAdress2).fix;

		OSCdef(\HitLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~proBjorViewG[~secondLemurX2Track].valueAction_(a); // vraiment nécessaire de marquer en rouge la séquence pour ce paramètre parfois non audible ??????
				if (~secondLemurX2Track == ~tracksValue, { ~proBjorView.valueAction_(a) });
			}.defer;
		}, "/Hit/x", ~lemurAdress2).fix;

		OSCdef(\OffLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~proBjor2ViewG[~secondLemurX2Track].valueAction_(a); // vraiment nécessaire de marquer en rouge la séquence pour ce paramètre parfois non audible ??????
				if (~secondLemurX2Track == ~tracksValue, { ~proBjor2View.valueAction_(a) });
			}.defer;
		}, "/Off/x", ~lemurAdress2).fix;

		OSCdef(\LegLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~legMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~legMulView.valueAction_(a) });
			}.defer;
		}, "/Leg/x", ~lemurAdress2).fix;

		OSCdef(\LegMenuLemur2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~legMulPresetViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~legMulView.valueAction_(~legMulViewG[~secondLemurX2Track].value) });
		}.defer;}
		}, "/ParC/LegMenuC/LegMenuP/x", ~lemurAdress2).fix;

		OSCdef(\BufLemur2, {|msg, time, addr, recvPort| var a = msg[1] * (~bufFolderSize1); // fonctionne bien ??????
			{
				~bufFolderFunc.value(~secondLemurX2Track, ~seqSeq[~secondLemurX2Track], a /*~bufFolderValue[~secondLemurX2Track][~seqSeq[~tracksValue] ]*/, 1); // |tr, seq, bufFolderValue, server|
				if (~secondLemurX2Track == ~tracksValue, { ~bufFolderView.valueAction_(a) });
				if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });
			}.defer;
		}, "/Buf/x", ~lemurAdress2).fix;

		OSCdef(\BufMenuLemur2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1).min(~lemurArrayOfFolderNames.size-1) /*.postln*/; // fonctionne bien ??????

			// try pour éviter la redondance quand rien n'est sélectionné
			// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
			{
				~bufFolderFunc.value(~secondLemurX2Track, ~seqSeq[~secondLemurX2Track], a /*~bufFolderValue[~secondLemurX2Track][~seqSeq[~tracksValue] ]*/, 1); // |tr, seq, bufFolderValue, server|
				if (~secondLemurX2Track == ~tracksValue, { ~bufFolderView.valueAction_(a) });
				if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });

				// ci-dessous n'a pas l'air de marcher pour updater le Buffer du second Lemur
				~lemurAdress2.sendMsg( *["/ParC/BufM", "@content", ~bufFolderView.items[~bufFolderValue[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]/*~seqsValue*/]] ]);
				~lemurAdress2.sendMsg( *["/ParC/BufMenuL", "@content", ~bufFolderView.items[~bufFolderValue[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]/*~seqsValue*/]] ]);
				~lemurAdress2.sendMsg("/ParC/BufLed/value", ~bufFolderValue[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] /*a.value*/ * ~bufFolderSize.reciprocal); // à Optimiser ?????????

		}.defer;}
		}, "/ParC/BufMenuC/BufMenuP/x", ~lemurAdress2).fix;



		OSCdef(\RatLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~ratMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~ratMulView.valueAction_(a) });
			}.defer;
		}, "/Rat/x", ~lemurAdress2).fix;

		OSCdef(\StrLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~strMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~strMulView.valueAction_(a) });
			}.defer;
		}, "/Str/x", ~lemurAdress2).fix;

		OSCdef(\CenLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~cenMulViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~cenMulView.valueAction_(a) });
			}.defer;
		}, "/Cen/x", ~lemurAdress2).fix;

		OSCdef(\PanMenuLemur2, {|msg, time, addr, recvPort| var a = msg[1]; /*(msg.indexOfEqual(1)-1).postln;*/
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{ ~panRangePresetViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~panRangePresetView.valueAction_(a) });
			}.defer;
		}, "/ParC/PanMenu/selection", ~lemurAdress2).fix;

		OSCdef(\SpaMenuLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{~multiStereoControlView[(~secondLemurX2Track/2).asInteger].valueAction_(a) }.defer
		}, "/ParC/SpaMenu/x", ~lemurAdress2).fix;

		OSCdef(\SpaMenu2Lemur2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
			// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
			{~spaRangePresetViewG[~secondLemurX2Track].valueAction_(a);
				if (~secondLemurX2Track == ~tracksValue, { ~spaRangePresetView.valueAction_(a) });
		}.defer;}
		}, "/ParC/SpaMenuC2/SpaMenuP2/x", ~lemurAdress2).fix;

		// marche quand on est sur la piste sélectionnée - comment faire sinon ?????????
		/*OSCdef(\IndexLemur2, {|msg, time, addr, recvPort| var a = msg[1];
		{~gblSeqIndexView.valueAction_(a);
		if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });
		}.defer;
		}, "/Index/x", ~lemurAdress2).fix;

		OSCdef(\RangeLemur2, {|msg, time, addr, recvPort| // var a = msg.postln;
		{~gblSeqView.valueAction_([msg[1], msg[2]]);
		if (~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background == Color.red, {}, {~presetSeqTextViewG[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].background_(Color.red) });
		}.defer;
		}, "/ParC/Range/x", ~lemurAdress2).fix;*/

	});



	~randomPadLemurFunction = { |lemurAdress, track, lemurPadName1, lemurPadName2 |

		OSCdef(lemurPadName1, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1))/*.postln*/;
			{

				case
				{ a == 1} // M  Preset aléatoire dans la présélection très définie d'une famille small
				{
					if ( ~sequenceSection == 1 and: {~tracksPresetColorModel1.includes(track.envirGet)}, {
						~tracksChooseSmallFamilyFunction.(track.envirGet);
					});
				}

				{ a == 2} // M + alt -> Preset aléatoire dans la présélection si disponible
				{
					var rand; if (~presetSeqRandList[track.envirGet].size == 0, { }, { rand = ~presetSeqRandList[~tracksValue] } );
					if (rand.notNil, {
						rand = rand.choose;
						if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ rand, rand ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([ rand, rand ]));
							~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
						});
					},{
						"No Preset in this Track".postln;
					});
				}

				{ a == 3} // P -> Retrigger current Preset
				{ ~retriggerPresetViewG[track.envirGet].valueAction_(1); }

				{ a == 4} // Random Violence
				{
					if ( ~sequenceSection == 1 and: {~tracksPresetColorModel1.includes(track.envirGet)}, {var p = ~sectionViolence.choose;
						/*~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
						~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0) */
						if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ p, p ]));
							// ~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ p, p ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
							~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
						});
					})
				}

				{ a == 5} // Random Beats
				{
					//  if ( ~sequenceSection == 1, {var p = ~sectionDouceur.choose; ~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0)  })
				}

				{ a == 6}
				// 7ème bouton -> P + alt -> Retrigger tous les presets sélectionnées des pistes qui jouent ou de tout si rien ne joue (Bouton : Sel Pl)
				// voir peut etre ~retriggerPresetAllTracksView pour action sur toutes les postes en toutes circonstances
				{ ~retriggerSelAllTracksView.valueAction_(1) }

			}.defer;
		}, "/RPads11/x", lemurAdress).fix;


		OSCdef(lemurPadName2, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1))/*.postln*/;
			{
				case
				{ a == 1} // ^¨ + alt-> Preset Selection précédente de la piste
				{
					var curPreset, tr, a;
					case
					{ track.envirGet == 0 } { tr = 0 }
					{ track.envirGet == 2 } { tr = 1 }
					{ track.envirGet == 4 } { tr = 2 }
					{ track.envirGet != 4 } { tr = nil };
					if (tr.notNil, {
						~positionInPresetSel[tr] = max(0, ~positionInPresetSel[tr] - 1);
						curPreset = ~presetsSelCollection[tr][~positionInPresetSel[tr]];

						if (curPreset == 0 or: {~positionInPresetSel[tr] == 0}, {
							~positionInPresetSel[tr] = ~positionInPresetSel[tr]  + 1; "No previous Selection".postln; // pour annuler la dernière action
						}, {
							~presetSeqStart[track.envirGet] = curPreset; ~presetSeqStop[track.envirGet] = curPreset;

							~seq2[track.envirGet] = (1..~nbOfSeqs).copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])[~presetSeqNb2Value[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet]).order].collect { |i, id| i ! ~presetSeqNbSelectDurValue[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])[~presetSeqNb2Value[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet]).order][id] }.flat;

							// Pour la fabrication de la séquence aléatoire à chaque fois que le RangeSlider est modifié
							~presetSeqRangeRand[track.envirGet] = Pxrand(~seq2[track.envirGet]/*.copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])*/, inf).asStream;

							// Changement de séquence dès que le RangeSlider est modifié sans attendre la fin de la séquence
							if (~seqChange[track.envirGet] == 1, {
								~seqBlock[track.envirGet] = 1;
								[\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i][track.envirGet] = 1};
							});

							// Armer la séquence si changement du rangeslider
							if (~curSeqTrig == 1, {
								if (Pdef(~patterns2[track.envirGet]).isPlaying == false, {
									if (~seqChange[track.envirGet] == 0, {~seqChangeViewG[track.envirGet].valueAction_(1)});
									// ~seqsView.valueAction_(~presetSeqStart[track.envirGet]);
									~seqsView.valueAction_(~presetSeqStart[track.envirGet]);
								});
							});

							if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
								~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~seqComp5.visibleOrigin = 0@( (curPreset /*~presetSeqStart[track.envirGet]*/-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
							},{
								~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~seqCompG1[track.envirGet].visibleOrigin = 0@( (curPreset /*~presetSeqStart[track.envirGet]*/-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
							});
							/*if (~presetSelection[track.envirGet][curPreset] != 0, {
							~presetGetFunction.value(~presetSelection[track.envirGet][curPreset].asSymbol);
							// ~presetGetFunction.value(~presetSelection[track.envirGet][~presetsSelCollection[0][~positionInPresetSel[0]]].asSymbol)
							if (~presetSeqTextViewG[track.envirGet][~seqSeq[track.envirGet]].background == Color.red, { ~presetSeqTextViewG[track.envirGet][~seqSeq[track.envirGet]].background_(Color.grey(0.3)) });
							},{
							"0 -> No Preset".postln;
							});*/
							("Preset Memory Nb : " + (~positionInPresetSel[tr]+1-~presetsSelListMemoryNb)).postln;

							a = ~lemurSwitchesMapsPatch3[~presetSeqStart[track.envirGet]];
							lemurAdress.sendMsg( *[[~lemurSwitchesValues[track.envirGet]] ++ ((0 ! a) ++ 1 ++ (0 ! (240-a)))].flatten(1) );
							case
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(0,19) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 1); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -7, 2748, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(20,39) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.91); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -7, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(40,59) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.82); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -7, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(60,79) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.72); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -223, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(80,99) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.63); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -223, 2758 ,890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(100,119) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.54);lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -223, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(120,139) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.45); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(140,159) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.36); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(160,179) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.27); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(180,199) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.18); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -656, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(200,219) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.09); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -656, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(220,239) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -656, 2758, 890]].flatten(1) );  };

						});
					});

					/*if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
					~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[track.envirGet/*4*/]).clip(0, ~nbOfSeqs), (~presetSeqStart[track.envirGet/*4*/]-1).clip(0, ~nbOfSeqs)  ]));
					~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet/*4*/]-4)*20).max(0)
					},{
					~presetSeqRangeViewG[track.envirGet/*4*/].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[track.envirGet/*4*/]).clip(0, ~nbOfSeqs), (~presetSeqStart[track.envirGet/*4*/]-1).clip(0, ~nbOfSeqs)  ]));
					~seqCompG1[track.envirGet/*4*/].visibleOrigin = 0@( (~presetSeqStart[track.envirGet/*4*/]-10)*20).max(0)
					});*/
				}

				{ a == 2} // *$ + alt-> PresetSelection suivante de la piste
				{
					var curPreset, tr;
					case
					{ track.envirGet == 0 } { tr = 0 }
					{ track.envirGet == 2 } { tr = 1 }
					{ track.envirGet == 4 } { tr = 2 }
					{ track.envirGet != 4 } { tr = nil };
					if (tr.notNil, {
						~positionInPresetSel[tr] = min(~presetsSelListMemoryNb, ~positionInPresetSel[tr] +1);
						curPreset = ~presetsSelCollection[tr][~positionInPresetSel[tr]];

						if (~positionInPresetSel[tr] == ~presetsSelListMemoryNb, {
							~positionInPresetSel[tr] = ~positionInPresetSel[tr]  - 1; "No next Selection".postln; // pour annuler la dernière action
						},{
							~presetSeqStart[track.envirGet] = curPreset; ~presetSeqStop[track.envirGet] = curPreset;

							~seq2[track.envirGet] = (1..~nbOfSeqs).copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])[~presetSeqNb2Value[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet]).order].collect { |i, id| i ! ~presetSeqNbSelectDurValue[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])[~presetSeqNb2Value[track.envirGet].copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet]).order][id] }.flat;

							// Pour la fabrication de la séquence aléatoire à chaque fois que le RangeSlider est modifié
							~presetSeqRangeRand[track.envirGet] = Pxrand(~seq2[track.envirGet]/*.copyRange(~presetSeqStart[track.envirGet], ~presetSeqStop[track.envirGet])*/, inf).asStream;

							// Changement de séquence dès que le RangeSlider est modifié sans attendre la fin de la séquence
							if (~seqChange[track.envirGet] == 1, {
								~seqBlock[track.envirGet] = 1;
								[\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i][track.envirGet] = 1};
							});

							// Armer la séquence si changement du rangeslider
							if (~curSeqTrig == 1, {
								if (Pdef(~patterns2[track.envirGet]).isPlaying == false, {
									if (~seqChange[track.envirGet] == 0, {~seqChangeViewG[track.envirGet].valueAction_(1)});
									// ~seqsView.valueAction_(~presetSeqStart[track.envirGet]);
									~seqsView.valueAction_(~presetSeqStart[track.envirGet]);
								});
							});

							if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
								~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~seqComp5.visibleOrigin = 0@( (curPreset /*~presetSeqStart[track.envirGet]*/-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
							},{
								~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
								~seqCompG1[track.envirGet].visibleOrigin = 0@( (curPreset /*~presetSeqStart[track.envirGet]*/-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
							});
							/*if (~presetSelection[track.envirGet][curPreset] != 0, {
							~presetGetFunction.value(~presetSelection[track.envirGet][curPreset].asSymbol);
							// ~presetGetFunction.value(~presetSelection[track.envirGet][~presetsSelCollection[0][~positionInPresetSel[0]]]);
							if (~presetSeqTextViewG[track.envirGet][~seqSeq[track.envirGet]].background == Color.red, { ~presetSeqTextViewG[track.envirGet][~seqSeq[track.envirGet]].background_(Color.grey(0.3)) });
							},{
							"0 -> No Preset".postln;
							});*/
							("Preset Memory Nb : " + (~positionInPresetSel[tr]+1-~presetsSelListMemoryNb)).postln;

							a = ~lemurSwitchesMapsPatch3[~presetSeqStart[track.envirGet]];
							lemurAdress.sendMsg( *[[~lemurSwitchesValues[track.envirGet]] ++ ((0 ! a) ++ 1 ++ (0 ! (240-a)))].flatten(1) );
							case
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(0,19) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 1); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -7, 2748, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(20,39) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.91); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -7, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(40,59) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.82); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -7, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(60,79) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.72); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -223, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(80,99) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.63); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -223, 2758 ,890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(100,119) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.54);lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -223, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(120,139) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.45); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(140,159) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.36); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(160,179) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.27); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -440, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(180,199) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.18); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-6, -656, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(200,219) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0.09); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-919, -656, 2758, 890]].flatten(1) );  }
							{ ~presetSeqStart[track.envirGet].inclusivelyBetween(220,239) }
							{ lemurAdress.sendMsg( ~lemurFaderValues[track.envirGet], 0); lemurAdress.sendMsg( *[[~lemurSwitchesContainerNames[track.envirGet]], ["@rect"], [-1833, -656, 2758, 890]].flatten(1) );  };

						});
					});

					/*if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
					~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[track.envirGet]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[track.envirGet]+2).clip(0, ~nbOfSeqs)  ]));
					~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0)
					},{
					~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[track.envirGet]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[track.envirGet]+2).clip(0, ~nbOfSeqs)  ]));
					~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0)
					});*/
				}

				{ a == 3} // 7ème bouton -> P + alt -> Retrigger tous les presets de la piste
				{ ~retriggerPresetPreViewG[track.envirGet].valueAction_(1); }

				{ a == 4} // Random Pieces
				{
					if ( ~sequenceSection == 1 and: {~tracksPresetColorModel1.includes(track.envirGet)}, {var p = ~sectionPieces.choose;

						if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ p, p ]));
							// ~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ p, p ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
							~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
						});

					})
				}

				{ a == 5} // Random Douceur
				{
					if ( ~sequenceSection == 1 and: {~tracksPresetColorModel1.includes(track.envirGet)}, {var p = ~sectionDouceur.choose;

						/*~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
						~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0) */
						if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ p, p ]));
							// ~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ p, p ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
							~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
						});
					})
				}

				{ a == 6} // Random Elements
				{
					if ( ~sequenceSection == 1 and: {~tracksPresetColorModel1.includes(track.envirGet)}, {var p = ~sectionElements.choose;

						/*~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
						~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0)*/
						if (~currentTab == 0 and: {track.envirGet == \tracksValue.envirGet}, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ p, p ]));
							// ~presetSeqRangeViewG[track.envirGet].value_(~presetSeqRangeSpec.unmap([ p, p ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
						},{
							~presetSeqRangeViewG[track.envirGet].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
							~seqCompG1[track.envirGet].visibleOrigin = 0@( (~presetSeqStart[track.envirGet]-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin)
						});
					})
				}

			}.defer
		}, "/RPads12/x", lemurAdress).fix;

	};

	~randomPadLemurFunction.(~lemurAdress1, \tracksValue, \RPads11, \RPads12);
	if (~lemurConnected2 == 1, { ~randomPadLemurFunction.(~lemurAdress2, \secondLemurX2Track, \RPads11Lemur2, \RPads12Lemur2); } );





	~lemurPresetMenuFunction = { | lemurAdress, menuName, menuValues, nb, tabbedPresetVarsPageLemur |

		var id = nb%10;

		OSCdef(menuName[nb], {|msg, time, addr, recvPort| var a, b, p, x, y, prevX, prevY;
			{
				try { a = (msg.indexOfEqual(1)-1)/*.postln*/;
					// try pour éviter le message d'erreur quand rien n'est sélectionné
					// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch

					if (~presetVarsLastSelection[id] != 0, { // Pour n'avoir q'une sélection à la fois
						~presetVarsMatrices[id].at(~presetVarsLastSelection[id]).playing_(false); ~presetVarsMatrices[id].removeStyle(~presetVarsMatrices[id].at(~presetVarsLastSelection[id]), 'playing'); // ~presetVarsMatrices[0].refresh
					});
					// Hack lent pour éviter d'avoir des Preset Variations en rouge, quand action avec le Lemur
					// Plus nécessaire depuis que la ligne ci-dessus a été intégré dans.defer
					// { 60.do { |i| ~presetVarsSliderView.valueAction_(~presetVarsSliderSpec.unmap(60-i)); 0.02.wait;}; }.fork(AppClock);


					x = a %10; y = a.div(10);
					b = ~presetVarsMatrices[id].at(y@x); // b.postln;
					p = b.pattern/*.postln*/;
					~presetVarsLastSelection[id] = y@x;


					case
					{ p.class == Symbol /*!= Nil*/ }
					{
						// ~loadPresetTracksRanges.(p); ("Preset Ass :" + p).postln
						if (tabbedPresetVarsPageLemur.envirGet == 0 or: {tabbedPresetVarsPageLemur.envirGet == 1}, {
							~loadPresetTracksRanges.(tabbedPresetVarsPageLemur, p, ~sequenceAssociationTrackFormat[0]); ("Preset Ass :" + p).postln
						}, {
							~loadPresetTracksRanges.(tabbedPresetVarsPageLemur, p); ("Preset Ass :" + p).postln
						});
					}
					{ p.class == Array }
					// { ~randAssociationFunction.(~sequenceAssociationTrackFormat[id], p); ("Preset Ass Rand :" + ~sequenceAssociationTrackFormat[id].asString + p).postln }
					{
						if (tabbedPresetVarsPageLemur.envirGet > 4, {
							~randRyAssociationFunction.(~sequenceAssociationTrackFormat[tabbedPresetVarsPageLemur.envirGet], p); ("Preset Ass Rand :" + ~sequenceAssociationTrackFormat[tabbedPresetVarsPageLemur.envirGet].asString + p).postln
						},{
							~randAssociationFunction.(~sequenceAssociationTrackFormat[tabbedPresetVarsPageLemur.envirGet], p); ("Preset Ass Rand :" + ~sequenceAssociationTrackFormat[tabbedPresetVarsPageLemur.envirGet].asString + p).postln
						})
					}
					{ p == 0 }
					{ ~randRhythmSel1AssociationFunction.(9) }
					{ p == 1 }
					{ ~randRhythmSelMulAssociationFunction.(9,2) }
					{ p == 2 }
					{ ~randRhythmSelMulAssociationFunction.(9,5) }
					{ p == 3 }
					{ ~randRhythmDur1AssociationFunction.(9) }
					{ p == 4 }
					{ ~randRhythmDurAssociationFunction.(9,3) }
					{ p == 5 }
					{ ~randRhythmDurAssociationFunction.(9,6) }
					{ p == 6 }
					{ ~randRhythmOrderAssociationFunction.(9) }
					{ p == 7 }
					{ ~randRhythmReOrderAssociationFunction.(9) }
					{ p == 8 }
					{ ~randRhythmAssociationFunctionClear.([9,11,13]) }
					{ p == 10 }
					{ ~randRhythmSel1AssociationFunction.(11) }
					{ p == 11 }
					{ ~randRhythmSelMulAssociationFunction.(11,2) }
					{ p == 12 }
					{ ~randRhythmSelMulAssociationFunction.(11,5) }
					{ p == 13 }
					{ ~randRhythmDur1AssociationFunction.(11) }
					{ p == 14 }
					{ ~randRhythmDurAssociationFunction.(11,3) }
					{ p == 15 }
					{ ~randRhythmDurAssociationFunction.(11,6) }
					{ p == 16 }
					{ ~randRhythmOrderAssociationFunction.(11) }
					{ p == 17 }
					{ ~randRhythmReOrderAssociationFunction.(11) }
					{ p == 20 }
					{ ~randRhythmSel1AssociationFunction.(13) }
					{ p == 21 }
					{ ~randRhythmSelMulAssociationFunction.(13,2) }
					{ p == 22 }
					{ ~randRhythmSelMulAssociationFunction.(13,5) }
					{ p == 23 }
					{ ~randRhythmDur1AssociationFunction.(13) }
					{ p == 24 }
					{ ~randRhythmDurAssociationFunction.(13,3) }
					{ p == 25 }
					{ ~randRhythmDurAssociationFunction.(13,6) }
					{ p == 26 }
					{ ~randRhythmOrderAssociationFunction.(13) }
					{ p == 27 }
					{ ~randRhythmReOrderAssociationFunction.(13) }
					{ p == 30 }
					{ ~randRhythmSel1AssociationFunction.(15) }
					{ p == 31 }
					{ ~randRhythmSelMulAssociationFunction.(15,2) }
					{ p == 32 }
					{ ~randRhythmSelMulAssociationFunction.(15,5) }
					{ p == 33 }
					{ ~randRhythmDur1AssociationFunction.(15) }
					{ p == 34 }
					{ ~randRhythmDurAssociationFunction.(15,3) }
					{ p == 35 }
					{ ~randRhythmDurAssociationFunction.(15,6) }
					{ p == 36 }
					{ ~randRhythmOrderAssociationFunction.(15) }
					{ p == 37 }
					{ ~randRhythmReOrderAssociationFunction.(15) }
					{ p == 40 }
					{ [9,11,13].do { |a| ~randRhythmSel1AssociationFunction.(a) } }
					{ p == 41 }
					{ [9,11,13].do { |a| ~randRhythmSelMulAssociationFunction.(a,2) } }
					{ p == 42 }
					{ [9,11,13].do { |a| ~randRhythmSelMulAssociationFunction.(a,5) } }
					{ p == 43 }
					{ [9,11,13].do { |a| ~randRhythmDur1AssociationFunction.(a) } }
					{ p == 44 }
					{ [9,11,13].do { |a| ~randRhythmDurAssociationFunction.(a,3) } }
					{ p == 45 }
					{ [9,11,13].do { |a| ~randRhythmDurAssociationFunction.(a,6) } }
					{ p == 46 }
					{ [9,11,13].do { |a| ~randRhythmOrderAssociationFunction.(a) } }
					{ p == 47 }
					{ [9,11,13].do { |a| ~randRhythmReOrderAssociationFunction.(a) } }
					{ p == 50 }
					{ ~randRhythmAssociationFunctionClear.([9,11,13]) };

					~presetVarsMatrices[id].at(y@x).playing_(true); ~presetVarsMatrices[id].addStyle(~presetVarsMatrices[id].at(y@x), 'playing'); ~presetVarsMatrices[id].refresh;

				}
			}.defer;
		}, menuValues[nb], lemurAdress).fix;
	};


	OSCdef(\OpenPresetWindow, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ ~presetVarsOpenView.valueAction_(a) }.defer;
	}, "/OpenPresetWindow/x", ~lemurAdress1).fix;

	/*OSCdef(\ChangeGlobalRyWindow, {|msg, time, addr, recvPort| var a = msg[1];
	}, "/RyWinPresetVar/x", ~lemurAdress1).fix;*/

	OSCdef(\MultiStereoRandAllSwitch, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoView.valueAction_(a); }.defer;
	}, "/MultiStereoRandAllSwitch/x", ~lemurAdress1).fix;

	OSCdef(\MultiStereoRandRySwitch, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoRandRySwitchView.valueAction_(a); }.defer;
	}, "/MultiStereoRandRySwitch/x", ~lemurAdress1).fix;

	OSCdef(\MultiStereoRandShuf, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		{
			case
			{ a == 0 } // ALL R
			{ if (~multiStereoRandRyALLView.notNil, {~multiStereoRandRyALLView.valueAction_(1)}, {"only exists with Acous".postln}) } // n'existe qu'avec Acous
			{ a == 1 } // R +
			{~multiStereoRandRy4View.valueAction_(1)}
			{ a == 2 } // 3 E
			{ if (~multiStereoRandRy3EView.notNil, {~multiStereoRandRy3EView.valueAction_(1)}, {"only exists with Acous".postln}) } // n'existe qu'avec Acous
			{ a == 3 } // V +
			{~multiStereoRandRy6View.valueAction_(1)}
			{ a == 4 } // Mob
			{~multiStereoRandRyMView.valueAction_(1)}
			{ a == 5 } // Acous ALL / 4a
			{ if (~multiStereoRandRy11AcView.notNil, {~multiStereoRandRy11AcView.valueAction_(1)}, {"only exists with Acous".postln}) } // n'existe qu'avec Acous
			{ a == 6 } // Pan Def
			{~multiStereoPanDefView.valueAction_(1)}
			{ a == 7 } // Rand
			{~multiStereoRandRy16AcView.valueAction_(1)}
			{ a == 8 } // Swap
			{~multiStereoSwapView.valueAction_(1)}
			{ a == 9 } // X
			{ }
			{ a == 10 } // Acous R
			{ if (~multiStereoRandRyAcView.notNil, {~multiStereoRandRyAcView.valueAction_(1)}, {"only exists with Acous".postln}) } // n'existe qu'avec Acous
			{ a == 11 } // X
			{ }
			{ a == 12 } // Acous 1
			{ if (~multiStereoRandRyAc1View.notNil, {~multiStereoRandRyAc1View.valueAction_(1)}, {"only exists with Acous".postln}) } // n'existe qu'avec Acous
			{ a == 13 } // Action Switch
			{ if ( ~rySpaTypeTrack == 0, { ~rySpaTypeTrackView.valueAction_(1); },{ ~rySpaTypeTrackView.valueAction_(0); } );}
		}.defer;
	};
	}, "/MultiStereoRandShuf/x", ~lemurAdress1).fix;

	OSCdef(\RatPresetVar, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ ~presetRatSwitch2View.valueAction_(a) }.defer;
	}, "/RatPresetVar/x", ~lemurAdress1).fix;

	OSCdef(\RatRandAll, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ if (a == 1, {~rhythmTracksX2.do {|i| ~ratMulViewG[i].valueAction_( (0.6-(0.2.exprand(0.58))) /*0.6.rand*/); }}) }.defer;
		// .linrand
	}, "/RatRA1/x", ~lemurAdress1).fix;

	OSCdef(\RatRand2All, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ if (a == 1, {~rhythmTracksX2.do {|i| ~ratMulViewG[i].valueAction_( 0.1.rrand(0.7) ); }}) }.defer;
		// .linrand
	}, "/RatRA2/x", ~lemurAdress1).fix;

	OSCdef(\LegRandAll, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ if (a == 1, {~rhythmTracksX2.do {|i| ~legMulViewG[i].valueAction_( 0.3.rrand(0.6) ); }}) }.defer;
		// .linrand
	}, "/LegRA1/x", ~lemurAdress1).fix;

	OSCdef(\LegRand2All, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ if (a == 1, {~rhythmTracksX2.do {|i| ~legMulViewG[i].valueAction_( 0.4.rrand(1.0) ); }}) }.defer;
		// .linrand
	}, "/LegRA2/x", ~lemurAdress1).fix;

	OSCdef(\SPARout, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ ~multiStereoRandRyRoutView.valueAction_(a) }.defer;
	}, "/SPARout/x", ~lemurAdress1).fix;

	OSCdef(\RatRout, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		{ ~presetRatRoutView.valueAction_(a) }.defer;
	}, "/RatRout/x", ~lemurAdress1).fix;


	if (~lemurConnected2 == 1, {

		OSCdef(\OpenPresetWindowLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ ~presetVarsOpenView.valueAction_(a) }.defer;
		}, "/OpenPresetWindow/x", ~lemurAdress2).fix;

		/*OSCdef(\ChangeGlobalRyWindowLemur2, {|msg, time, addr, recvPort| var a = msg[1];
		}, "/RyWinPresetVar/x", ~lemurAdress2).fix;*/

		OSCdef(\MultiStereoRandAllSwitchLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{ ~multiStereoView.valueAction_(a); }.defer;
		}, "/MultiStereoRandAllSwitch/x", ~lemurAdress2).fix;

		OSCdef(\MultiStereoRandRySwitchLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{ ~multiStereoRandRySwitchView.valueAction_(a); }.defer;
		}, "/MultiStereoRandRySwitch/x", ~lemurAdress2).fix;

		OSCdef(\MultiStereoRandShufLemur2, {|msg, time, addr, recvPort| try {var a = (msg.indexOfEqual(1)-1)/*.postln*/;
			// try pour éviter la redondance quand rien n'est sélectionné
			// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
			{
				case
				{ a == 0 } // ALL R
				{~multiStereoRandRyALLView.valueAction_(1)}
				{ a == 1 } // R +
				{~multiStereoRandRy4View.valueAction_(1)}
				{ a == 2 } // 3 E
				{~multiStereoRandRy3EView.valueAction_(1)}
				{ a == 3 } // V +
				{~multiStereoRandRy6View.valueAction_(1)}
				{ a == 4 } // Mob
				{~multiStereoRandRyMView.valueAction_(1)}
				{ a == 5 } // Acous ALL / 4a
				{~multiStereoRandRy11AcView.valueAction_(1)}
				{ a == 6 } // Pan Def
				{~multiStereoPanDefView.valueAction_(1)}
				{ a == 7 } // Rand
				{~multiStereoRandRy16AcView.valueAction_(1)}
				{ a == 8 } // Swap
				{~multiStereoSwapView.valueAction_(1)}
				{ a == 9 } // X
				{ }
				{ a == 10 } // Acous R
				{~multiStereoRandRyAcView.valueAction_(1)}
				{ a == 11 } // X
				{ }
				{ a == 12 } // Acous 1
				{~multiStereoRandRyAc1View.valueAction_(1)}
				{ a == 13 } // Action Switch
				{ if ( ~rySpaTypeTrack == 0, { ~rySpaTypeTrackView.valueAction_(1); },{ ~rySpaTypeTrackView.valueAction_(0); } );}
			}.defer;
		};
		}, "/MultiStereoRandShuf/x", ~lemurAdress2).fix;

		OSCdef(\RatPresetVarLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ ~presetRatSwitch2View.valueAction_(a) }.defer;
		}, "/RatPresetVar/x", ~lemurAdress2).fix;

		OSCdef(\RatRandAllLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ if (a == 1, {~rhythmTracksX2.do {|i| ~ratMulViewG[i].valueAction_( (0.6-(0.2.exprand(0.58))) /*0.6.rand*/); }}) }.defer;
			// .linrand
		}, "/RatRA1/x", ~lemurAdress2).fix;

		OSCdef(\RatRand2AllLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ if (a == 1, {~rhythmTracksX2.do {|i| ~ratMulViewG[i].valueAction_( 0.1.rrand(0.7) ); }}) }.defer;
			// .linrand
		}, "/RatRA2/x", ~lemurAdress2).fix;

		OSCdef(\LegRandAllLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ if (a == 1, {~rhythmTracksX2.do {|i| ~legMulViewG[i].valueAction_( 0.3.rrand(0.6) ); }}) }.defer;
			// .linrand
		}, "/LegRA1/x", ~lemurAdress2).fix;

		OSCdef(\LegRand2AllLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ if (a == 1, {~rhythmTracksX2.do {|i| ~legMulViewG[i].valueAction_( 0.4.rrand(1.0) ); }}) }.defer;
			// .linrand
		}, "/LegRA2/x", ~lemurAdress2).fix;

		OSCdef(\SPARoutLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ ~multiStereoRandRyRoutView.valueAction_(a) }.defer;
		}, "/SPARout/x", ~lemurAdress2).fix;

		OSCdef(\RatRoutLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			{ ~presetRatRoutView.valueAction_(a) }.defer;
		}, "/RatRout/x", ~lemurAdress2).fix;

	});





	~folderRyGroupStruct = ["4", "5", "6", "7", "8", ""];
	// ~folderRyGroupItemsLemur = ~folderRyGroupStruct.collect { |a| ~folderRyGroupItems.collect { |b| a + b } }.flatten;
	~folderRyGroupItemsLemur = ~folderRyGroupStruct.collect { |a| (~folderRyGroupItems[(0..16)]).collect { |b| a + b } }.flatten; // modifié car liste de regroupements trop longue -changé depuis Parmegiani

	/*
	~folderRyGroupStruct = ["4-", "5-", "6-", "7-", "8-"];
	~folderRyGroupStruct.collect { |a|  [a] + [~folderRyGroupItems[1]] ++ (2..(~folderRyGroupItems.size/2)).collect { |i, id|  a ++ ~folderRyGroupItems[i] } }.flatten(1)
	~folderRyGroupStruct.collect { |a|  [a] + [~folderRyGroupItems[0]] ++ ((~folderRyGroupItems.size/2+1)..(~folderRyGroupItems.size-1)).collect { |i, id| a ++ ~folderRyGroupItems[i] } }.flatten(1).cs
	*/
	/*
	~folderRyGroupStruct = ["4-", "5-", "6-", "7-", "8-"];
	~folderRyGroupItemsLemur = ((~folderRyGroupStruct.collect { |a|  [a] + [~folderRyGroupItems[1]] ++ (2..(~folderRyGroupItems.size/2)).collect { |i, id|  a + ~folderRyGroupItems[i] } }.flatten(1) ++
		~folderRyGroupStruct.collect { |a|  [a] + [~folderRyGroupItems[0]] ++ ((~folderRyGroupItems.size/2+1)..(~folderRyGroupItems.size-1)).collect { |i, id| a + ~folderRyGroupItems[i] } }.flatten(1)) ++
	["Ts-"].collect { |a|  [a] + [~folderRyGroupItems[1]] ++ (2..(~folderRyGroupItems.size/2)).collect { |i, id| a + ~folderRyGroupItems[i] } }.flatten(1) ++
	["Ts-"].collect { |a|  [a] + [~folderRyGroupItems[0]] ++ ((~folderRyGroupItems.size/2+1)..(~folderRyGroupItems.size-1)).collect { |i, id| a + ~folderRyGroupItems[i] } }.flatten(1));
	*/

	~lemurFolderTextNames = (17* /*12*/ 6).collect { |i| "/Folder_T" ++ (i+1).asString };
	~lemurFolderTextPos = /*12*/ 6.collect { |r| 17.collect { |c| var x,y; x=152; y=( 0 /*-14*/); [(c*49.9)+x, (r* /*24*/ 44)+y, 100, 50] } }.flatten(1);

	~lemurFolderNamesFunction = { |lemurAdress|
		~lemurFolderTextNames.do { |i, id|
			lemurAdress.sendMsg( *[ [i] ++ ["@content"] ++ [ ~folderRyGroupItemsLemur[id] ] ].flatten(1) );
			lemurAdress.sendMsg( *[ [i] ++ ["@rect"] ++ ~lemurFolderTextPos[id] ].flatten(1) ); // rect {X,Y,W,H}
	}};
	// ~lemurFolderNamesFunction.( ~lemurAdress1);

	/*OSCdef(\FolderRandTypeSel, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		{ var a = (msg.indexOfEqual(1)-1);
			~folderRyRandView.valueAction_(a); }.defer;
	}
	}, "/FolderRandTypeSel/x", ~lemurAdress1).fix;*/


	OSCdef(\FolderRyMenu, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = (msg.indexOfEqual(1)); // avec Parme
		var x = (a % 16);
		var y = (a.div(16)+3);

		/* var a = (msg.indexOfEqual(1)-1); // après Parme
		var x = (a % 16)+2;
		var y = (a.div(16)%5)+3; */

		var track = (y*2)+~seqCompGABIndex[y];
		var prevRand = ~folderRyRand; // y.postln;
		{
			~folderRyRand = x;
			~folRandFunction.(track);
			~bufFolderViewG[track].value_(~bufFolderValue[track][~seqSeq[track]]); // Action que sur le global et non la séquence
			~folderRyRand = prevRand;
		}.defer;
	}
	}, "/FolderRyMenu/x", ~lemurAdress1).fix;

	OSCdef(\FolderRyMenuAllX, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = (msg.indexOfEqual(1)); // avec Parme
		var x = (a % 17);

		/* var a = (msg.indexOfEqual(1)-1); // après Parme
		var x = (a % 16)+2; */

		var prevRand = ~folderRyRand;
		{
			~folderRyRand = x;
			~rhythmTracksX2.do {|i| ~folRandFunction.(i); ~bufFolderViewG[i].value_(~bufFolderValue[i][~seqSeq[i]]); }; // Action que sur le global et non la séquence
			~folderRyRand = prevRand;
		}.defer;
	}
	}, "/FolderRyMenuAllX/x", ~lemurAdress1).fix;

	OSCdef(\FolderRyMenuA, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = if (msg.notNil, {(msg.indexOfEqual(1)+2)});
		var track = (a*2)+~seqCompGABIndex[a];
		var prevRand = ~folderRyRand;
		{
			~folderRyRand = /*x*/ 0; // avec Parme
			// ~folderRyRand = x /*0*/; // après Parme
			~folRandFunction.(track);
			~folderRyRand =prevRand;
		}.defer;
	}
	}, "/FolderRyMenuA/x", ~lemurAdress1).fix;

	OSCdef(\FolderRyMenuAAll, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var prevRand = ~folderRyRand; // "test".postln;
		{
			~folderRyRand = /*x*/ 0; // avec Parme
			// ~folderRyRand = x /*0*/; // après Parme
			~rhythmTracksX2.do {|i| ~folRandFunction.(i) };
			~folderRyRand =prevRand;
		}.defer;
	}
	}, "/FolderRyMenuAAll/x", ~lemurAdress1).fix;


	OSCdef(\VolRyLemur, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~presetVarsVol2SliderView.valueAction_(a) }.defer;
	}, "/VolRySlider/x", ~lemurAdress1).fix;

	OSCdef(\StereoRandAllSwitch, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoRyView.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/StereoRandAllSwitch/x", ~lemurAdress1).fix;

	OSCdef(\StereoRandAllSwitch2, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoRandRyRout2View.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/StereoRandAllSwitch2/x", ~lemurAdress1).fix;

	OSCdef(\SpaRoutType, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1)-1).min(2);
		{ ~spaRoutTypeView.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/SpaRoutType/x", ~lemurAdress1).fix;

	OSCdef(\SpaTimeRoutType, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1)-1).min(2);
		{ ~defaultPresetVarsMenu.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/SpaTimeRoutType/x", ~lemurAdress1).fix;

	// Lemur 2
	OSCdef(\FolderRyMenuLemur2, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = (msg.indexOfEqual(1)); // avec Parme
		var x = (a % 16); // avec Parme
		var y = (a.div(16)+3); // avec Parme
		var track = (y*2)+~seqCompGABIndex[y];
		var prevRand = ~folderRyRand;
		{
			~folderRyRand = x;
			~folRandFunction.(track);
			~folderRyRand =prevRand;
		}.defer;
	}
	}, "/FolderRyMenu/x", ~lemurAdress2).fix;

	OSCdef(\FolderRyMenuAllXLemur2, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = (msg.indexOfEqual(1)); // avec Parme
		var x = (a % 17); // avec Parme
		var prevRand = ~folderRyRand;
		{
			~folderRyRand = x;
			~rhythmTracksX2.do {|i| ~folRandFunction.(i) };
			~folderRyRand = prevRand;
		}.defer;
	}
	}, "/FolderRyMenuAllX/x", ~lemurAdress2).fix;

	OSCdef(\FolderRyMenuALemur2, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var a = (msg.indexOfEqual(1)+2);
		var track = (a*2)+~seqCompGABIndex[a];
		var prevRand = ~folderRyRand;
		{
			~folderRyRand = 0; // avec Parme
			~folRandFunction.(track);
			~folderRyRand =prevRand;
		}.defer;
	}
	}, "/FolderRyMenuA/x", ~lemurAdress2).fix;

	OSCdef(\FolderRyMenuAAllLemur2, {|msg, time, addr, recvPort| try {
		// try pour éviter la redondance quand rien n'est sélectionné
		// ai essayé de mettre un Switch à la place du Pad, mais le dernier objet sélectionnné ne ferme pas le Switch
		var prevRand = ~folderRyRand;
		{
			~folderRyRand = 0; // avec Parme
			~rhythmTracksX2.do {|i| ~folRandFunction.(i) };
			~folderRyRand =prevRand;
		}.defer;
	}
	}, "/FolderRyMenuAAll/x", ~lemurAdress2).fix;

	OSCdef(\VolRyLemur2, {|msg, time, addr, recvPort| var a = msg[1];
		// Pas d'action quand on est sur la vue séquence, obligé de basculer de la Global à la séquence pour updater OU de faire une action redondante // XXXXXXXXXXXXXXXXXXXXXXXXXXX
		{ ~presetVarsVol2SliderView.valueAction_(a) }.defer;
	}, "/VolRySlider/x", ~lemurAdress2).fix;

	OSCdef(\StereoRandAllSwitchLemur2, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoRyView.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/StereoRandAllSwitch/x", ~lemurAdress2).fix;

	OSCdef(\StereoRandAllSwitch2Lemur2, {|msg, time, addr, recvPort| var a = msg[1];
		{ ~multiStereoRandRyRout2View.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/StereoRandAllSwitch2/x", ~lemurAdress2).fix;

	OSCdef(\SpaRoutTypeLemur2, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1)-1).min(2);
		{ ~spaRoutTypeView.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/SpaRoutType/x", ~lemurAdress2).fix;

	OSCdef(\SpaTimeRoutTypeLemur2, {|msg, time, addr, recvPort| var a = (msg.indexOfEqual(1)-1).min(2);
		{ ~defaultPresetVarsMenu.valueAction_(a); }.defer;
	}, "/RyWinC/SpaC/SpaTimeRoutType/x", ~lemurAdress2).fix;



	~lemurOSCdefSelRyNames = [\Sel5G, \Sel6G, \Sel7G, \Sel8G, \Sel4G];
	~lemurOSCdefSelRyNamesLemur2 = [\Sel5GLemur2, \Sel6GLemur2, \Sel7GLemur2, \Sel8GLemur2, \Sel4GLemur2];
	~lemurSelRyValues = ["/RyWinC/Sel5/x", "/RyWinC/Sel6/x", "/RyWinC/Sel7/x", "/RyWinC/Sel8/x", "/RyWinC/Sel4/x"];

	~lemurOSCdefCurRyNames = [\Cur5G, \Cur6G, \Cur7G, \Cur8G, \Cur4G];
	~lemurOSCdefCurRyNamesLemur2 = [\Cur5GLemur2, \Cur6GLemur2, \Cur7GLemur2, \Cur8GLemur2, \Cur4GLemur2];
	~lemurCurRyValues = ["/RyWinC/Cur5/x", "/RyWinC/Cur6/x", "/RyWinC/Cur7/x", "/RyWinC/Cur8/x", "/RyWinC/Cur4/x"];

	~lemurOSCdefFolRyNames = [\FolR5G, \FolR6G, \FolR7G, \FolR8G, \FolR4G];
	~lemurOSCdefFolRyNamesLemur2 = [\FolR5GLemur2, \FolR6GLemur2, \FolR7GLemur2, \FolR8GLemur2, \FolR4GLemur2];
	~lemurFolRyValues = ["/RyWinC/FolR5/x", "/RyWinC/FolR6/x", "/RyWinC/FolR7/x", "/RyWinC/FolR8/x", "/RyWinC/FolR4/x"];

	~lemurOSCdefBufRyNames = [\BufR5G, \BufR6G, \BufR7G, \BufR8G, \BufR4G];
	~lemurOSCdefBufRyNamesLemur2 = [\BufR5GLemur2, \BufR6GLemur2, \BufR7GLemur2, \BufR8GLemur2, \BufR4GLemur2];
	~lemurBufRyValues = ["/RyWinC/BufR5/x", "/RyWinC/BufR6/x", "/RyWinC/BufR7/x", "/RyWinC/BufR8/x", "/RyWinC/BufR4/x"];

	~lemurOSCdefOffRyNames = [\OffR5G, \OffR6G, \OffR7G, \OffR8G, \OffR4G];
	~lemurOSCdefOffRyNamesLemur2 = [\OffR5GLemur2, \OffR6GLemur2, \OffR7GLemur2, \OffR8GLemur2, \OffR4GLemur2];
	~lemurOffRyValues = ["/RyWinC/OffR5/x", "/RyWinC/OffR6/x", "/RyWinC/OffR7/x", "/RyWinC/OffR8/x", "/RyWinC/OffR4/x"];

	~lemurOSCdefRatRyNames = [\RatR5G, \RatR6G, \RatR7G, \RatR8G, \RatR4G];
	~lemurOSCdefRatRyNamesLemur2 = [\RatR5GLemur2, \RatR6GLemur2, \RatR7GLemur2, \RatR8GLemur2, \RatR4GLemur2];
	~lemurRatRyValues = ["/RyWinC/RatR5/x", "/RyWinC/RatR6/x", "/RyWinC/RatR7/x", "/RyWinC/RatR8/x", "/RyWinC/RatR4/x"];

	~lemurOSCdefSpaRyNames = [\SpaR5G, \SpaR6G, \SpaR7G, \SpaR8G, \SpaR4G];
	~lemurOSCdefSpaRyNamesLemur2 = [\SpaR5GLemur2, \SpaR6GLemur2, \SpaR7GLemur2, \SpaR8GLemur2, \SpaR4GLemur2];
	~lemurSpaRyValues = ["/RyWinC/SpaR5/x", "/RyWinC/SpaR6/x", "/RyWinC/SpaR7/x", "/RyWinC/SpaR8/x", "/RyWinC/SpaR4/x"];

	~lemurOSCdefRyNames = [~lemurOSCdefSelRyNames, ~lemurOSCdefCurRyNames, ~lemurOSCdefFolRyNames, ~lemurOSCdefBufRyNames, ~lemurOSCdefOffRyNames, ~lemurOSCdefRatRyNames, ~lemurOSCdefSpaRyNames ];
	~lemurOSCdefRyNamesLemur2 = [~lemurOSCdefSelRyNamesLemur2, ~lemurOSCdefCurRyNamesLemur2, ~lemurOSCdefFolRyNamesLemur2, ~lemurOSCdefBufRyNamesLemur2, ~lemurOSCdefOffRyNamesLemur2, ~lemurOSCdefRatRyNamesLemur2, ~lemurOSCdefSpaRyNamesLemur2 ];
	~lemurOSCdefRyNamesALL = [~lemurOSCdefRyNames, ~lemurOSCdefRyNamesLemur2];
	~lemurRyValues = [~lemurSelRyValues, ~lemurCurRyValues, ~lemurFolRyValues, ~lemurBufRyValues, ~lemurOffRyValues, ~lemurRatRyValues, ~lemurSpaRyValues];


	~lemurOSCdefRatMulRyNames = [\Rat5G, \Rat6G, \Rat7G, \Rat8G, \Rat4G];
	~lemurOSCdefRatMulRyNamesLemur2 = [\Rat5GLemur2, \Rat6GLemur2, \Rat7GLemur2, \Rat8GLemur2, \Rat4GLemur2];
	~lemurOSCdefRatMulRyNamesALL = [~lemurOSCdefRatMulRyNames, ~lemurOSCdefRatMulRyNamesLemur2];
	~lemurRatMulGValues = ["/Rat5/x", "/Rat6/x", "/Rat7/x", "/Rat8/x", "/Rat4/x"];

	~lemurOSCdefLegMulRyNames = [\Leg5G, \Leg6G, \Leg7G, \Leg8G, \Leg4G];
	~lemurOSCdefLegMulRyNamesLemur2 = [\Leg5GLemur2, \Leg6GLemur2, \Leg7GLemur2, \Leg8GLemur2, \Leg4GLemur2];
	~lemurOSCdefLegMulRyNamesALL = [~lemurOSCdefLegMulRyNames, ~lemurOSCdefLegMulRyNamesLemur2];
	~lemurLegMulGValues = ["/Leg5/x", "/Leg6/x", "/Leg7/x", "/Leg8/x", "/Leg4/x"];


	~lemurOSCdefEQLNames = [\EQL5, \EQL6, \EQL7, \EQL8, \EQL4];
	~lemurOSCdefEQLNamesLemur2 = [\EQL5Lemur2, \EQL6Lemur2, \EQL7Lemur2, \EQL8Lemur2, \EQL4Lemur2];
	~lemurOSCdefEQLNamesALL = [~lemurOSCdefEQLNames, ~lemurOSCdefEQLNamesLemur2];
	~lemurEQLValues = ["/RyWinC/EQL5/x", "/RyWinC/EQL6/x", "/RyWinC/EQL7/x", "/RyWinC/EQL8/x", "/RyWinC/EQL4/x"];

	~lemurOSCdefEQMNames = [\EQM5, \EQM6, \EQM7, \EQM8, \EQM4];
	~lemurOSCdefEQMNamesLemur2 = [\EQM5Lemur2, \EQM6Lemur2, \EQM7Lemur2, \EQM8Lemur2, \EQM4Lemur2];
	~lemurOSCdefEQMNamesALL = [~lemurOSCdefEQMNames, ~lemurOSCdefEQMNamesLemur2];
	~lemurEQMValues = ["/RyWinC/EQM5/x", "/RyWinC/EQM6/x", "/RyWinC/EQM7/x", "/RyWinC/EQM8/x", "/RyWinC/EQM4/x"];

	~lemurOSCdefEQHNames = [\EQH5, \EQH6, \EQH7, \EQH8, \EQH4];
	~lemurOSCdefEQHNamesLemur2 = [\EQH5Lemur2, \EQH6Lemur2, \EQH7Lemur2, \EQH8Lemur2, \EQH4Lemur2];
	~lemurOSCdefEQHNamesALL = [~lemurOSCdefEQHNames, ~lemurOSCdefEQHNamesLemur2];
	~lemurEQHValues = ["/RyWinC/EQH5/x", "/RyWinC/EQH6/x", "/RyWinC/EQH7/x", "/RyWinC/EQH8/x", "/RyWinC/EQH4/x"];

	~lemurOSCdefSelALL = [\Sel, \SelLemur2];
	~lemurOSCdefFolSelALL = [\FolSel, \FolSelLemur2];
	~lemurOSCdefFolALL = [\FolA, \FolALemur2];
	~lemurOSCdefBufALL = [\BufA, \BufALemur2];
	~lemurOSCdefOffALL = [\OffA, \OffALemur2];
	~lemurOSCdefAllALL = [\AllA, \AllALemur2];
	~lemurOSCdefCurALL = [\CurA, \CurALemur2];
	~lemurOSCdefEQActALL = [\EQAct2, \EQAct2Lemur2];

	~lemurRatGLedValues = ["/RyWinC/RatLed1/value", "/RyWinC/RatLed1/value", "/RyWinC/RatLed2/value", "/RyWinC/RatLed2/value", "/RyWinC/RatLed3/value", "/RyWinC/RatLed3/value", "/RyWinC/RatLed4/value", "/RyWinC/RatLed4/value", "/RyWinC/RatLed5/value", "/RyWinC/RatLed5/value", "/RyWinC/RatLed6/value", "/RyWinC/RatLed6/value", "/RyWinC/RatLed7/value", "/RyWinC/RatLed7/value", "/RyWinC/RatLed8/value", "/RyWinC/RatLed8/value"];
	~lemurRatGTextValues = ["/RyWinC/RatM1/value", "/RyWinC/RatM1/value", "/RyWinC/RatM2/value", "/RyWinC/RatM2/value", "/RyWinC/RatM3/value", "/RyWinC/RatM3/value", "/RyWinC/RatM4/value", "/RyWinC/RatM4/value", "/RyWinC/RatM5/value", "/RyWinC/RatM5/value", "/RyWinC/RatM6/value", "/RyWinC/RatM6/value", "/RyWinC/RatM7/value", "/RyWinC/RatM7/value", "/RyWinC/RatM8/value", "/RyWinC/RatM8/value" ];

	~lemurLegGLedValues = ["/RyWinC/LegLed1/value", "/RyWinC/LegLed1/value", "/RyWinC/LegLed2/value", "/RyWinC/LegLed2/value", "/RyWinC/LegLed3/value", "/RyWinC/LegLed3/value", "/RyWinC/LegLed4/value", "/RyWinC/LegLed4/value", "/RyWinC/LegLed5/value", "/RyWinC/LegLed5/value", "/RyWinC/LegLed6/value", "/RyWinC/LegLed6/value", "/RyWinC/LegLed7/value", "/RyWinC/LegLed7/value", "/RyWinC/LegLed8/value", "/RyWinC/LegLed8/value"];
	~lemurLegGTextValues = ["/RyWinC/LegM1/value", "/RyWinC/LegM1/value", "/RyWinC/LegM2/value", "/RyWinC/LegM2/value", "/RyWinC/LegM3/value", "/RyWinC/LegM3/value", "/RyWinC/LegM4/value", "/RyWinC/LegM4/value", "/RyWinC/LegM5/value", "/RyWinC/LegM5/value", "/RyWinC/LegM6/value", "/RyWinC/LegM6/value", "/RyWinC/LegM7/value", "/RyWinC/LegM7/value", "/RyWinC/LegM8/value", "/RyWinC/LegM8/value" ];


	~lemurGlobalTracksFunction = { |lemurNb, lemurAdress|

		OSCdef(~lemurOSCdefSelALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, {~triggerAllSeqsAllTracksView.valueAction_(1)},{~triggerAllSeqsAllTracksView.valueAction_(0)}) }.defer;
		}, "/SelAll/x", lemurAdress).fix;

		OSCdef(~lemurOSCdefFolSelALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ ~folderRyRandView.valueAction_(a); }.defer;
		}, "/FolderRandType/selection", lemurAdress).fix;

		OSCdef(~lemurOSCdefFolALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, { ~folRandViewRy.valueAction_(1) }) }.defer;
		}, "/FolRA/x", lemurAdress).fix;

		OSCdef(~lemurOSCdefBufALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, { ~rhythmTracksX2.do {|i| ~bufRandViewG[i].valueAction_(1) } }) }.defer;
		}, "/BufRA/x", lemurAdress).fix;

		OSCdef(~lemurOSCdefOffALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, { ~rhythmTracksX2.do {|i| ~offRandViewG[i].valueAction_(1) } }) }.defer;
		}, "/OffRA/x", lemurAdress).fix;

		OSCdef(~lemurOSCdefAllALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, { ~folRandViewRy.valueAction_(1); ~rhythmTracksX2.do {|i| ~bufRandViewG[i].valueAction_(1); /*~offRandViewG[i].valueAction_(1)*/ } }) }.defer;
		}, "/AllRA/x", lemurAdress).fix;

		OSCdef(~lemurOSCdefCurALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ if (a == 1, { ~retriggerPresetViewRy.valueAction_(1) }) }.defer;
		}, "/CurA/x", lemurAdress).fix;

		// ~eqChaDefAllView ~eqChaRandAllView ~eqChaActivateView ~eqChaAll2ActivateView
		OSCdef(~lemurOSCdefEQActALL[lemurNb], {|msg, time, addr, recvPort| var a = msg[1];
			{ ~eqChaAll2ActivateView.valueAction_(a) }.defer;
		}, "/RyWinC/EQAct/x", lemurAdress).fix;


		~rhythmTracksX2.do { |i, id|

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][0][id], {|msg, time, addr, recvPort| var a = msg[1]; // a.postln;
				{ if (a == 1, {~triggerAllSeqsViewG[~rhythmTracksX2[id]].valueAction_(1)},{~triggerAllSeqsViewG[~rhythmTracksX2[id]].valueAction_(0)}) }.defer;
			}, ~lemurRyValues[0][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][1][id], {|msg, time, addr, recvPort| var a = msg[1]; // a.postln;
				{ if (a == 1, {~retriggerPresetViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[1][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][2][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ if (a == 1, {~folRandViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[2][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][3][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ if (a == 1, {~bufRandViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[3][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][4][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ if (a == 1, {~offRandViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[4][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][5][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ if (a == 1, {~ratRandViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[5][id], lemurAdress).fix;

			OSCdef(~lemurOSCdefRyNamesALL[lemurNb][6][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ if (a == 1, {~spaRandViewG[~rhythmTracksX2[id]].valueAction_(1)}) }.defer;
			}, ~lemurRyValues[6][id], lemurAdress).fix;

			// ~eqChaLoView ~eqChaMiView ~eqChaHiView

			OSCdef(~lemurOSCdefEQLNamesALL[lemurNb][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ ~eqChaLoView[~rhythmTracksX[id]].valueAction_(a) }.defer;
			}, ~lemurEQLValues[id], lemurAdress).fix;

			OSCdef(~lemurOSCdefEQMNamesALL[lemurNb][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ ~eqChaMiView[~rhythmTracksX[id]].valueAction_(a) }.defer;
			}, ~lemurEQMValues[id], lemurAdress).fix;

			OSCdef(~lemurOSCdefEQHNamesALL[lemurNb][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ ~eqChaHiView[~rhythmTracksX[id]].valueAction_(a) }.defer;
			}, ~lemurEQHValues[id], lemurAdress).fix;


			OSCdef(~lemurOSCdefRatMulRyNamesALL[lemurNb][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ ~ratMulViewG[~rhythmTracksX2[id]].valueAction_(a) }.defer;
			}, ~lemurRatMulGValues[id], lemurAdress).fix;

			OSCdef(~lemurOSCdefLegMulRyNamesALL[lemurNb][id], {|msg, time, addr, recvPort| var a = msg[1];
				{ ~legMulViewG[~rhythmTracksX2[id]].valueAction_(a) }.defer;
			}, ~lemurLegMulGValues[id], lemurAdress).fix;

	}};

	~lemurGlobalTracksFunction.(0, ~lemurAdress1);
	if (~lemurConnected2 == 1, { ~lemurGlobalTracksFunction.(1, ~lemurAdress2); });







	OSCdef(\VolG, {|msg, time, addr, recvPort| var a = msg[1];
		{~trackAllVolView.valueAction_(a)}.defer;
	}, "/Vol_G/x", ~lemurAdress1).fix;
	// ~trackAllVolView.valueAction_(1);

	// Fonction ci-dessous dans TrackvolAll View ne marche pas car Feedback, mais utilisation de LEDs pour feedback et éviter le MVC paradigm
	/*if (~lemurConnected1 == 1, {
	~lemurAdress1.sendMsg("/VolC/Vol_G/x", i.value );
	// ~lemurAdress1.sendMsg("/VolC/Vol_G/x", 0.1);
	});*/

	OSCdef(\VolFX, {|msg, time, addr, recvPort| var a = msg[1];
		// ~trackFXVolView.valueAction_(0.12);
		{~trackFXVolView.valueAction_(a/2)}.defer;
	}, "/Vol_FX/x", ~lemurAdress1).fix;
	// ~~trackFXVolView.valueAction_(1);
	/*if (~lemurConnected1 == 1, {
	~lemurAdress1.sendMsg("/VolC/Vol_FX2/value", 1- (~fxVolume*2));
	~lemurAdress1.sendMsg("/VolC/Vol_FXM/value", ~fxVolume);
	});*/



	// Données Accéléromètre

	OSCdef(\accXT, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		~lemurAccXA = a;
	}, "/ParC/AccXT/x", ~lemurAdress1).fix;

	OSCdef(\accX, {|msg, time, addr, recvPort| var a = msg[1];
		/*{~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
		~seqCompG1[~tracksValue].visibleOrigin = 0@( (a-10)*20).max(0)}.defer;*/
		if (~lemurAccXA == 1, { ("Acc X -> " ++ (~ratMulView.value.round(0.001)).asString).postln; {~ratMulView.valueAction_(a)}.defer; });
	}, "/FaderAcc_Gauche_Droite/x", ~lemurAdress1).fix;

	OSCdef(\accYT, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
		~lemurAccYA = a;
	}, "/ParC/AccYT/x", ~lemurAdress1).fix;

	OSCdef(\accY, {|msg, time, addr, recvPort| var a = msg[1];
		/*{~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
		~seqCompG1[~tracksValue].visibleOrigin = 0@( (a-10)*20).max(0)}.defer;*/
		if (~lemurAccYA == 1, { ("Acc Y -> " ++ (~strMulView.value.round(0.001)).asString).postln; {~strMulView.valueAction_(a)}.defer; });
	}, "/FaderAcc_Bas_Haut/x", ~lemurAdress1).fix;



	if (~lemurConnected2 == 1, {

		OSCdef(\VolGLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			{~trackAllVolView.valueAction_(a)}.defer;
		}, "/Vol_G/x", ~lemurAdress2).fix;

		OSCdef(\VolFXLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			// ~trackFXVolView.valueAction_(0.12);
			{~trackFXVolView.valueAction_(a/2)}.defer;
		}, "/Vol_FX/x", ~lemurAdress2).fix;


		OSCdef(\accXTLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			~lemurAccXALemur2 = a;
		}, "/ParC/AccXT/x", ~lemurAdress2).fix;

		OSCdef(\accXLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			/*{~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
			~seqCompG1[~tracksValue].visibleOrigin = 0@( (a-10)*20).max(0)}.defer;*/
			if (~lemurAccXALemur2 == 1, { ("Acc X -> " ++ (~ratMulView.value.round(0.001)).asString).postln; {~ratMulView.valueAction_(a)}.defer; });
		}, "/FaderAcc_Gauche_Droite/x", ~lemurAdress2).fix;

		OSCdef(\accYTLemur2, {|msg, time, addr, recvPort| var a = msg[1]; // .postln;
			~lemurAccYALemur2 = a;
		}, "/ParC/AccYT/x", ~lemurAdress2).fix;

		OSCdef(\accYLemur2, {|msg, time, addr, recvPort| var a = msg[1];
			/*{~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([a-1, a]) );
			~seqCompG1[~tracksValue].visibleOrigin = 0@( (a-10)*20).max(0)}.defer;*/
			if (~lemurAccYALemur2 == 1, { ("Acc Y -> " ++ (~strMulView.value.round(0.001)).asString).postln; {~strMulView.valueAction_(a)}.defer; });
		}, "/FaderAcc_Bas_Haut/x", ~lemurAdress2).fix;

	});



	// Faire aussi un monitoring pour le nom des pistes

	{

		"Please wait for data transmission !".postln;

		/*~lemurAdress1.sendMsg( *[ ["/TrackSwitch1"]  ++ ["@labels"] ++ ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"] ].flatten(1) );
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[ ["/TrackSwitch1"]  ++ ["@labels"] ++ ["I", "II", "III", "IV", "V", "VI", "VII", "VIII"] ].flatten(1) ); });*/
		~lemurAdress1.sendMsg( *[ ["/TrackSwitch1"]  ++ ["@labels"] ++ ["1", "2", "3", "4", "5", "6", "7", "8"] ].flatten(1) );
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[ ["/TrackSwitch1"]  ++ ["@labels"] ++  ["1", "2", "3", "4", "5", "6", "7", "8"] ].flatten(1) ) });
		// ~lemurAdress1.sendMsg( *[ ["/TrackSwitch1"]  ++ ["@labels"] ++ ["", "", "", "", "", "", "", ""] ].flatten(1) );

		~lemurAdress1.sendMsg( *[ ["/PresetSwitch1"]  ++ ["@labels"] ++ ~sequenceAssociationTrackFormat.collect { |i| i.asString } ++ ["X"]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/PresetSwitch1"] ++ ["@colors"] ++ [~blueLemurColor1, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor, ~greenLemurColor, ~orangeLemurColor, ~redLemurColor, ~redLemurColor, ~redLemurColor, ~blackLemurColor, ~blackLemurColor]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/PresetSwitch2"]  ++ ["@labels"] ++ ~sequenceAssociationTrackFormat.collect { |i| i.asString } ++ ["X"]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/PresetSwitch2"] ++ ["@colors"] ++ [~blueLemurColor1, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor, ~greenLemurColor, ~orangeLemurColor, ~redLemurColor, ~redLemurColor, ~redLemurColor, ~blackLemurColor, ~blackLemurColor]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP11"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP12"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP13"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP14"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP15"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP16"] ++ ["@color"] ++ [~orangeLemurColor, ~orangeLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP17"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP18"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP19"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets1/PresetMenuP110"] ++ ["@color"] ++ [~blackLemurColor, ~blackLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP21"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP22"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP23"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP24"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP25"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP26"] ++ ["@color"] ++ [~orangeLemurColor, ~orangeLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP27"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP28"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP29"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/Presets2/PresetMenuP210"] ++ ["@color"] ++ [~blackLemurColor, ~blackLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/MultiStereoRandShuf"] ++ ["@colors"] ++ [ ~greenLemurColor, ~whiteLemurColor, ~greenLemurColor, ~whiteLemurColor, ~redLemurColor, ~whiteLemurColor, ~orangeLemurColor, ~whiteLemurColor, ~blueLemurColor2, ~whiteLemurColor ]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/RyWinC/SpaC/MultiStereoRandShuf2"] ++ ["@colors"] ++ [ ~greenLemurColor, ~whiteLemurColor, ~greenLemurColor, ~whiteLemurColor, ~redLemurColor, ~whiteLemurColor, ~orangeLemurColor, ~whiteLemurColor, ~blueLemurColor2, ~whiteLemurColor ]  ].flatten(1) );

		if (~lemurConnected2 == 1, {
			~lemurAdress2.sendMsg( *[ ["/PresetSwitch1"]  ++ ["@labels"] ++  ~sequenceAssociationTrackFormat.collect { |i| i.asString } ++ ["X"] ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/PresetSwitch1"] ++ ["@colors"] ++ [~blueLemurColor1, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor, ~greenLemurColor, ~orangeLemurColor, ~redLemurColor, ~redLemurColor, ~redLemurColor, ~blackLemurColor, ~blackLemurColor]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/PresetSwitch2"]  ++ ["@labels"] ++  ~sequenceAssociationTrackFormat.collect { |i| i.asString } ++ ["X"] ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/PresetSwitch2"] ++ ["@colors"] ++ [~blueLemurColor1, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor, ~greenLemurColor, ~orangeLemurColor, ~redLemurColor, ~redLemurColor, ~redLemurColor, ~blackLemurColor, ~blackLemurColor]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP11"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP12"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP13"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP14"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP15"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP16"] ++ ["@color"] ++ [~orangeLemurColor, ~orangeLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP17"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP18"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP19"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets1/PresetMenuP110"] ++ ["@color"] ++ [~blackLemurColor, ~blackLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP21"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP22"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP23"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1 ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP24"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP25"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP26"] ++ ["@color"] ++ [~orangeLemurColor, ~orangeLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP27"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP28"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP29"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/Presets2/PresetMenuP210"] ++ ["@color"] ++ [~blackLemurColor, ~blackLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/MultiStereoRandShuf"] ++ ["@colors"] ++ [ ~greenLemurColor, ~whiteLemurColor, ~greenLemurColor, ~whiteLemurColor, ~redLemurColor, ~whiteLemurColor, ~orangeLemurColor, ~whiteLemurColor, ~blueLemurColor2, ~whiteLemurColor ]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/RyWinC/SpaC/MultiStereoRandShuf2"] ++ ["@colors"] ++ [ ~greenLemurColor, ~whiteLemurColor, ~greenLemurColor, ~whiteLemurColor, ~redLemurColor, ~whiteLemurColor, ~orangeLemurColor, ~whiteLemurColor, ~blueLemurColor2, ~whiteLemurColor ]  ].flatten(1) );
		});

		~lemurAdress1.sendMsg( *[ ["/TrackNext"]  ++ ["@labels"] ++ ["<->"] ].flatten(1) );
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[ ["/TrackNext"]  ++ ["@labels"] ++ ["<->"] ].flatten(1) ) });

		// ~lemurAdress1.sendMsg( *[ ["/ParC/RtmMP"]  ++ ["@items"] ++ ["0.1", "0.25", "0.5", "0.75", "1", "1.5", "2", "3", "5", "10"] ].flatten(1) ); // Agit sur quoi ??? rien apparemment à supprimer ???
		// Besoin de le dupliquer pour ~lemurAdress2 ???

		~lemurAdress1.sendMsg( *[ ["/RPads12"] ++ ["@colors"] ++ [~greenLemurColor, ~greenLemurColor, ~blackLemurColor, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor]  ].flatten(1) );
		~lemurAdress1.sendMsg( *[ ["/RPads11"] ++ ["@colors"] ++ [~orangeLemurColor, ~redLemurColor, ~greyLemurColor, ~blueLemurColor2, ~redLemurColor, ~blackLemurColor]  ].flatten(1) );
		if (~rySpaTypeTrack == 0, { ~lemurAdress1.sendMsg( *["/Ry14", "@content", "ALL" ]); ~lemurAdress1.sendMsg( *["/RyWinC/SpaC/Ry14b", "@content", "ALL" ]); },{ ~lemurAdress1.sendMsg( *["/Ry14", "@content", "Follow" ]); ~lemurAdress1.sendMsg( *["/RyWinC/SpaC/Ry14b", "@content", "Follow" ]); });
		if (~lemurConnected2 == 1, {
			~lemurAdress2.sendMsg( *[ ["/RPads12"] ++ ["@colors"] ++ [~greenLemurColor, ~greenLemurColor, ~blackLemurColor, ~blueLemurColor1, ~blueLemurColor1, ~greenLemurColor]  ].flatten(1) );
			~lemurAdress2.sendMsg( *[ ["/RPads11"] ++ ["@colors"] ++ [~orangeLemurColor, ~redLemurColor, ~greyLemurColor, ~blueLemurColor2, ~redLemurColor, ~blackLemurColor]  ].flatten(1) );
			if (~rySpaTypeTrack == 0, { ~lemurAdress2.sendMsg( *["/Ry14", "@content", "ALL" ]); ~lemurAdress2.sendMsg( *["/RyWinC/SpaC/Ry14b", "@content", "ALL" ]); },{ ~lemurAdress2.sendMsg( *["/Ry14", "@content", "Follow" ]); ~lemurAdress2.sendMsg( *["/RyWinC/SpaC/Ry14b", "@content", "Follow" ]); });
		});

		0.1.wait;

		// ~tracksColorizeFunction.(0); ~tracksColorizeFunction.(2); ~tracksColorizeFunction.(4); ~tracksColorizeFunction.(6); / Découpage & Colorisation des Séquences des Pistes devrait être déjà fait

		// ~tracksPresetColorModel1.do { |i| ~lemurTracksColorizeFunction.(~lemurAdress1, i); };
		~nbOfTracksX2.do { |i|  ~lemurTracksColorizeFunction.(~lemurAdress1, i); }; // ~tracksPresetColorModel1 déja intégré dans ~lemurTracksColorizeFunction
		// if (~lemurConnected2 == 1, { ~tracksPresetColorModel1.do { |i| ~lemurTracksColorizeFunction.(~lemurAdress2, i); } });
		if (~lemurConnected2 == 1, { ~nbOfTracksX2.do { |i|  ~lemurTracksColorizeFunction.(~lemurAdress2, i); }});


		~lemurBufNamesFunction.(~lemurAdress1);
		if (~lemurConnected2 == 1, { ~lemurBufNamesFunction.(~lemurAdress2) } );


		0.2.wait;

		~lemurFolderNamesFunction.( ~lemurAdress1);

		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset11SwitchesTextNames, 0, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset12SwitchesTextNames, 1, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset13SwitchesTextNames, 2, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset14SwitchesTextNames, 3, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset15SwitchesTextNames, 4, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset16SwitchesTextNames, 5, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset17SwitchesTextNames, 6, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset18SwitchesTextNames, 7, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset19SwitchesTextNames, 8, 0 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset110SwitchesTextNames, 9, 0 ); 0.01.wait;

		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset21SwitchesTextNames, 0, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset22SwitchesTextNames, 1, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset23SwitchesTextNames, 2, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset24SwitchesTextNames, 3, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset25SwitchesTextNames, 4, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset26SwitchesTextNames, 5, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset27SwitchesTextNames, 6, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset28SwitchesTextNames, 7, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset29SwitchesTextNames, 8, 1 ); 0.01.wait;
		~lemurPresetNamesFunction.( ~lemurAdress1, ~lemurPreset210SwitchesTextNames, 9, 1 ); 0.01.wait;

		if (~lemurConnected2 == 1, {
			~lemurFolderNamesFunction.( ~lemurAdress2);
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset11SwitchesTextNames, 0, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset12SwitchesTextNames, 1, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset13SwitchesTextNames, 2, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset14SwitchesTextNames, 3, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset15SwitchesTextNames, 4, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset16SwitchesTextNames, 5, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset17SwitchesTextNames, 6, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset18SwitchesTextNames, 7, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset19SwitchesTextNames, 8, 0 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset110SwitchesTextNames, 9, 0 ); 0.01.wait;

			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset21SwitchesTextNames, 0, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset22SwitchesTextNames, 1, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset23SwitchesTextNames, 2, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset24SwitchesTextNames, 3, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset25SwitchesTextNames, 4, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset26SwitchesTextNames, 5, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset27SwitchesTextNames, 6, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset28SwitchesTextNames, 7, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset29SwitchesTextNames, 8, 1 ); 0.01.wait;
			~lemurPresetNamesFunction.( ~lemurAdress2, ~lemurPreset210SwitchesTextNames, 9, 1 ); 0.01.wait;
		});

		10. do { |i|
			~lemurPresetMenuFunction.(~lemurAdress1, ~lemurOSCdefPresetMenu1Names, ~lemurPresetMenu1Values, i, \tabbedPresetVarsPageLemur11);
			if (~lemurConnected2 == 1, { ~lemurPresetMenuFunction.(~lemurAdress2, ~lemurOSCdefPresetMenu1NamesLemur2, ~lemurPresetMenu1Values, i, \tabbedPresetVarsPageLemur21) });
		};

		/*
		~tabbedPresetVarsPageLemur11
		~tabbedPresetVarsPageLemur12
		~tabbedPresetVarsPageLemur21
		~tabbedPresetVarsPageLemur22
		*/

		10. do { |i|
			~lemurPresetMenuFunction.(~lemurAdress1, ~lemurOSCdefPresetMenu2Names, ~lemurPresetMenu2Values, i, \tabbedPresetVarsPageLemur12);
			if (~lemurConnected2 == 1, { ~lemurPresetMenuFunction.(~lemurAdress2, ~lemurOSCdefPresetMenu2NamesLemur2, ~lemurPresetMenu2Values, i, \tabbedPresetVarsPageLemur22) });
		};

		0.2.wait;

		16. do { |i| ~lemurTracksSeqNamesFunction.(~lemurAdress1, i); 0.02.wait; if (~lemurConnected2 == 1, { ~lemurTracksSeqNamesFunction.(~lemurAdress2, i); 0.02.wait; 0.01.wait; } ) };

		16. do { |i|
			~lemurTracksReceiveSwitchesFunction.(~lemurAdress1, i, \lemurOSCdefSwitchesNames);
			if (~lemurConnected2 == 1, { ~lemurTracksReceiveSwitchesFunction.(~lemurAdress2, i, \lemurOSCdefSwitchesNamesLemur2); });  /*0.1.wait;*/
		};

		0.2.wait;

		~lemurTracksRadioSwitchesFunction.();


		~lemurAdress1.sendMsg( *[["/TrackSwitch1/x"] ++  ((0 ! (~tracksValue/2).asInteger) ++ [1] ++ (0 ! (~nbOfTracks - (~tracksValue/2).asInteger-1))) /*[[ 1, 0, 0, 0, 0, 0, 0, 0, 0 ]*/ ].flatten(1) );
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[["/TrackSwitch1/x"] ++ [ 0, 0, 1, 0, 0, 0, 0, 0, 0 ] ].flatten(1) ) });

		~lemurAdress1.sendMsg( *[["/PresetSwitch1/x"] ++ [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ] ].flatten(1) ); ~tabbedPresetVarsPageLemur11 = 5;
		~lemurAdress1.sendMsg( *[["/PresetSwitch2/x"] ++ [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ].flatten(1) ); ~tabbedPresetVarsPageLemur12 = 0;
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[["/PresetSwitch1/x"] ++ [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ] ].flatten(1) ) }); ~tabbedPresetVarsPageLemur21 = 6;
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[["/PresetSwitch2/x"] ++ [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ].flatten(1) ) }); ~tabbedPresetVarsPageLemur22 = 0;


		// Avant -> Mise à jour des données du Lemur au départ, mais seulement validé quand le range n'est pas une sélection non consécutive, cad sans Array dans ~lemurNewSeqs
		~nbOfTracksX2.do { |i|
			if (~lemurConnected1 == 1, { ~updateLemurTrackSeq.(~lemurAdress1, i, ~presetSeqStart[i], 0) });
			if (~lemurConnected2 == 1, { ~updateLemurTrackSeq.(~lemurAdress2, i, ~presetSeqStart[i], 0) });
		};

		// Pour mettre à jour les sliders du 1er tab du Lemur si le Lemur est lancée après la GUI
		~rtmMulView.value_(~rtmMulSpec[~tracksValue][~seqsValue].unmap(/*1*/~rtmMul[~tracksValue][~seqsValue])).doAction; ~proMulView.value_(~proMulSpec.unmap(/*1*/~proMul[~tracksValue][~seqsValue])).doAction; ~legMulView.value_(~legMulSpec.unmap(/*1*/~legMul[~tracksValue][~seqsValue])).doAction;
		~strMulView.value_(~strMulSpec.unmap(/*1*/~strMul[~tracksValue][~seqsValue])).doAction; ~cenMulView.value_(~cenMulSpec.unmap(/*1*/~cenMul[~tracksValue][~seqsValue])).doAction;
		~proBjorView.value_(/*1*/~proBjor[~tracksValue][~seqsValue]).doAction; ~proBjor2View.value_(/*1*/~proBjor2[~tracksValue][~seqsValue]).doAction; ~bufFolderView.value_(~bufFolderValue[~tracksValue][~seqsValue]/*~defaultFolder*/.min(/*0*/ ~arrayOfFolderNames.size-1)).doAction;
		~seqsColorizeFunction.(~tracksValue,~seqsValue);


		// ~rhythmTracksX2.do { |i| ~triggerAllSeqsViewG[i].valueAction_(~triggerAllSeqs[i]) }; // Pour mettre à jour si le Lemur a été relancé par rapport à la GUI - vraiment necessaire ?... mais ne marche pas


		if (~twister.notNil, {
			// Pour mise à jour du Twister, besoin de donner une valeur différente (Hack en utilisant .round)
			~ratValues[~tracksValue].value_(~ratMulSpec.unmap(~ratMul[~tracksValue][~seqsValue]).round(0.001));
			~rhythmTracksX2.do { |tr|
				~ratValues[tr].value_(~ratMulSpec.unmap(~ratMul[tr][~seqSeq[tr]]).round(0.001) ); // ~ratMulSpec.unmap(~ratMul[tr][~seqSeq[tr]]).postln;
				// Obligé de mettre round pour rappeler le preset sinon rien ???
				/*
				~ratValues[7].value_( 0.8 ) // Pourquoi doit être appelé 2 x ??? ok maintenant
				~ratValues[4].value_(~ratMulSpec.unmap(~ratMul[9][~seqSeq[9]].round(0.1)) );
				*/
				~legMulViewG[tr].value_(~legMulSpec.unmap(/*1*/~legMul[tr][~seqSeq[tr]])).doAction;
				~seqsColorizeFunction.(tr,~seqsValue);
			};
		},{ // Pour mise à jour du Twister
			~ratMulView.value_(~ratMulSpec.unmap(/*1*/~ratMul[~tracksValue][~seqsValue])).doAction;
			// Pour mettre à jour les sliders du 3ème tab du Lemur
			~rhythmTracksX2.do { |tr|
				~ratMulViewG[tr].value_(~ratMulSpec.unmap(/*1*/~ratMul[tr][~seqSeq[tr]])).doAction; ~legMulViewG[tr].value_(~legMulSpec.unmap(/*1*/~legMul[tr][~seqSeq[tr]])).doAction;
				~seqsColorizeFunction.(tr,~seqsValue);
			};
		});

		// Mise à jour de certains paramètres du Tab de Preset Variations du Lemur pour qu'elles correspondent à la GUI
		~presetRatSwitchView.value_(0).doAction; // SRat S1 à off par défaut, car pas d'action sur les séquences trames quand modif des séquences rythmiques
		~multiStereoView.value_(0).doAction; // Stereo par défaut au départ
		if ( ~presetVarsWindowStatus == 1, { ~presetVarsOpenView.valueAction_(1); }, { ~presetVarsOpenView.valueAction_(0); } );

		"Lemur connected and data shared".postln;

	}.fork(AppClock);

},{
	"No Lemur connected".postln;
});



(
~lemurNewSeqsUpdate = { | track, lemurNewSeqs |

	// ~lemurNewSeqs[track] = lemurNewSeqs;

	if (~currentTab == 0 and: { track == ~tracksValue }, {
		~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ ( lemurNewSeqs.minItem-1).clip(0, ~nbOfSeqs), ( lemurNewSeqs.maxItem).clip(0, ~nbOfSeqs)  ]));
		~seqComp5.visibleOrigin = 0@( ( lemurNewSeqs.minItem-4)*20).max(0).min(~seqComp5MaxVisibleOrigin)
	},{
		~presetSeqRangeViewG[track].valueAction_(~presetSeqRangeSpec.unmap([ ( lemurNewSeqs.minItem-1).clip(0, ~nbOfSeqs), ( lemurNewSeqs.maxItem).clip(0, ~nbOfSeqs)  ]));
		~seqCompG1[track].visibleOrigin = 0@( ( lemurNewSeqs.minItem-10)*20).max(0).min(~seqCompG1MaxVisibleOrigin);
		~presetSeqRangeViewG[track].background_(Color.magenta).hilightColor_(Color.blue);
	});

	// ~lemurNewSeqs[track] = 0;
	~lemurNewSeqs[track] = lemurNewSeqs;

	// ~lemurPresetSeqLength[track] = lemurNewSeqs.collect { |i, id| i ! ~presetSeqNbSelectDurValue[track][i-1] }.flat;

	// Après
	~presetSeqNb2LemurValue[track]  = lemurNewSeqs.collect { |i, id| ~presetSeqNb2Value[track][i-1] };
	~lemurPresetSeqLength[track] = lemurNewSeqs[~presetSeqNb2LemurValue[track].order].collect { |i, id| i ! ~presetSeqNbSelectDurValue[track][i-1] }.flat;
	// Plus necessaire - déjà dans ~presetSeqRangeViewG et d'autres - apparemment non ? car au dessus, juste pour indiquer la zone des séquences sélectionnées


	if (~lemurConnected1 == 1, {
		~lemurNewSeqsPatch = lemurNewSeqs.collect { |i| ~lemurSwitchesMapsPatch4[i] }.sort;
		~lemurSeqDif = ~lemurNewSeqsPatch.differentiate;

		~lemurAdress1.sendMsg( *[[~lemurSwitchesValues[track]] ++ ~lemurSeqDif.collect { |i| [0 ! (i-1), 1] }.flat ++ (0 ! (240 - ~lemurSeqDif.sum)) ].flatten(1) );
	});
	if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( *[[~lemurSwitchesValues[track]] ++ ~lemurSeqDif.collect { |i| [0 ! (i-1), 1] }.flat ++ (0 ! (240 - ~lemurSeqDif.sum)) ].flatten(1) ) });

	if (~lemurConnected1 == 1 and: {track == ~tracksValue}, {
		~lemurAdress1.sendMsg( *[ ["/CurSeq2/value"], [~lemurNewSeqs[~tracksValue].asString] ].flatten(1) );
		~lemurAdress1.sendMsg( *["/CurSeqText2", "@content", ""/*~presetSelection[tr][~lemurNewSeqs[tr][0]+1]*/ ]);
	});
	if (~lemurConnected2 == 1 and: {track == ~secondLemurX2Track}, {
		~lemurAdress2.sendMsg( *[ ["/CurSeq2/value"], [~lemurNewSeqs[~tracksValue].asString] ].flatten(1) );
		~lemurAdress2.sendMsg( *["/CurSeqText2", "@content", ""/*~presetSelection[tr][~lemurNewSeqs[tr][0]+1]*/ ]);
	});

	case
	{ lemurNewSeqs.minItem.inclusivelyBetween(0,19) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 1); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -7, 2748, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 1); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -7, 2748, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(20,39) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.91); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -7, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.91); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -7, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(40,59) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.82); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -7, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, {  ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.82); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -7, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(60,79) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.72); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -223, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.72); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -223, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(80,99) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.63); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -223, 2758 ,890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.63); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -223, 2758 ,890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(100,119) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.54);~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -223, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.54);~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -223, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(120,139) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.45); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -440, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.45); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -440, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(140,159) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.36); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -440, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.36); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -440, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(160,179) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.27); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -440, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.27); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -440, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(180,199) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.18); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -656, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.18); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-6, -656, 2758, 890]].flatten(1) ) });
	}

	{ lemurNewSeqs.minItem.inclusivelyBetween(200,219) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0.09); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -656, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0.09); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-919, -656, 2758, 890]].flatten(1) ) });
	}
	{ lemurNewSeqs.minItem.inclusivelyBetween(220,239) }
	{ if (~lemurConnected1 == 1, { ~lemurAdress1.sendMsg( ~lemurFaderValues[track], 0); ~lemurAdress1.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -656, 2758, 890]].flatten(1) ) });
		if (~lemurConnected2 == 1, { ~lemurAdress2.sendMsg( ~lemurFaderValues[track], 0); ~lemurAdress2.sendMsg( *[[~lemurSwitchesContainerNames[track]], ["@rect"], [-1833, -656, 2758, 890]].flatten(1) ) });
	}

};

)


)

