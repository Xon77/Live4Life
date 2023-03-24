// Presets

( // Final Step 1 : Initialisation of some values XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// FX, Volume Sub, immediate change of sequences or type of action on keyboard, glissando times for playback speeds, CPU handling, etc.

// ~server1.latency = 0.2;  ~server2.latency = 0.2; // already by default
// ~server1.latency = 0.1; ~server2.latency = 0.1; // can cause late messages depending on actions

~nbOfServers.do { |s|
	~serverVolume[s].lag_(6); // 7 by default
	// ~limiter[s].set(\mulSub, 0.3 /*0.3*/ /*0.2*/); // 0.8 by default - only used with some spatial configurations like : "16-Dome-8-6-2-Clock-CC" or "32-Dome-12-10-8-2"
};

// ~trackFXVolView.valueAction_(0.12); // already by default
// ~cutSynthView.valueAction_(1); // already by default // if 0, stops synths with DetectSilence if over 0.1 sec. of silence detected, e.g. when the track volume is at 0 // if 1 does not stop synths
// ~keyControlView.valueAction_(1); // already by default // Keyboard Mapping (Montage (sound editing) = 0 / Spatialisation = 1 / Playback speeds = 2)
~trigAllView.valueAction_(3); // Selects where the action on playback speeds is // Track = 0 (only acts on current Track) / Other = 1 (acts on other tracks than current Track) / ALL = 2 (acts on all tracks / Tex13 = 3 (acts on texture tracks from 1 to 3)
~controlBusSynth5FadeTimeView.valueAction_(0); // already by default // Glissando times for playback sppeds // 7 for 30 secons

if (~serverFX == 1, { // ~serverFX = 1 indicates that FX are on an independent servers // old strategy
	~cpuStopView.valueAction_(3); ~aliveThreadPeriodView.valueAction_(3);
}, {
	~cpuStopView.valueAction_(3 /*2*/); // 60% = 3 / 55% = 2 // to adjust the CPU threshold where no more synths are triggerred on the server
	~aliveThreadPeriodView.valueAction_(3 /*2*/); // 0.01 sec. = 3 / 0.02 sec. = 4 // to adjust ask/answer times to get the CPU level of the servers
});

~updatePresetSelectionView.valueAction_(1); // already by default // 0 = to update the sequence preset of the track when selected if the track is not playing / 1 = the sequence is not updated

(0..5).do { |i| ~seqChangeViewG[i].valueAction_(1); }; (6..15).do { |i| ~seqChangeViewG[i].valueAction_(0); }; // if 1, changes the sequence immediately without waiting the end of the previous sequence
// ~nbOfTracksX2.do { |i| if (i.even, {~seqChangeViewG[i].valueAction_(1)}, {~seqChangeViewG[i].valueAction_(0)}); }; ~seqChangeViewG[7].valueAction_(1);

/* ~mixAllFxView2.value_(~mixAllFxViewSpec.unmap(~mixAllFxDefault)).doAction; // sets mix of FX to its default value = 0
~lagTimeAllFxView2.valueAction_(~lagTimeAllFxSpec.unmap(~lagTimeAllFxDefault)); // sets FX parameter lag time to its default value
~fadeTimeSynthFxView2.valueAction_(~fadeTimeSynthFxSpec.unmap(~fadeTimeSynthFxDefault)); // sets FX Xfade time to its default value */

// Desactivation by default of shortcuts for SmoothSliders during performances, but possibility to activate them again // ~disableFocusSmoothSlider.(false);

"Final Step 1 : Some Values Initialized";
)


( // Final Step 2 : Lecture du TracksPreset (associé à un fichier de presets) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// TracksPreset File organising presets in tracks and the selection of the rangeslider of tracks
~presetsTracksFileName = "L4LT_Mar2023_240_SpatialWorkshop.txt";

~aControllerConnectedValue = ~aControllerConnected; ~lemurConnectedValue = ~lemurConnected1; ~lemurConnectedValue2 = ~lemurConnected2;
~aControllerConnected = 0;  ~lemurConnected1 = 0;  ~lemurConnected2 = 0;
~presetTracksPath = (PathName.new(~currentPath).pathOnly ++ ~presetsTracksFileName);
~presetsTracksFileW = ZArchive.read(~presetTracksPath);
~presetsTracks = ~presetsTracksFileW.readItem;
~presetsTracksFileW.close;
~presetsDontTriggerFX = 1; // Protection to not trigger FX of presets when loading presets in tracks

~presetTrackGetFunction.value('test', ~nbOfSeqs, [ 2, 4, 6, 8, 10, 12, 14, 0 ]);
)


( // Store the TracksPreset File XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetsTracksFileName = "L4LT_Mar2023_240_SpatialWorkshop.txt";
~presetTracksPath = (PathName.new(~currentPath).pathOnly ++ ~presetsTracksFileName);
~presetsTracksFile = ZArchive.write(~presetTracksPath);
~presetsTracksFile.writeItem(~presetsTracks.put(~presetTrackSetFunction.value('test')));
~presetsTracksFile.writeClose;
"Presets saved";
)





// TO DO

( // Final Step 3 : Example to define sections (to quickly randomise within sections) and colorise the sequences in Global View XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

/*
OSCdef.freeAll; // Si "_init Lemur2" a déjà été lancé et que l'application Lemur ou programme doit être réouvert, -> le Lemur initialise certains GUI (Sliders) selon les valeurs par défaut du Lemur
// donc besoin d'initialiser le Lemur selon les données des sliders de la GUI SI Preset sélectionné, remplacer le .fix par permanent pour annuler les OSCDef ou juste besoin de rappeler P sur la piste en cours...*/

~sequenceSection = 1;

// Small Families
~sectionPB = (0..4); // PB
~sectionPBD = (5..29); // PBD
~sectionPBN = (30..41); // PBN
~sectionPL = (42..46); // PL
~sectionPLD = (47..70); // PLD
~sectionPLN = (71..127); // PLN
~sectionTNM = (128..140); // TNM - pas de prise en compte de TNO
~sectionTE = (142..163); // TE
~sectionTF = (164..168); // TF
~sectionTV = (169..187); // TV
~sectionTS = (188..199); // TS

// Big Families
~sectionPieces = ~sectionPB ++ ~sectionPL;
~sectionDouceur = ~sectionPBD ++ ~sectionPLD ++ ~sectionTS;
~sectionViolence = ~sectionPBN ++ ~sectionPLN ++ ~sectionTNM;
~sectionElements = ~sectionTE ++ ~sectionTF ++ ~sectionTV;
// (0..8)

~tracksChooseSmallFamilyFunction = { |track|
	{ var p, pr;
		case
		{~sectionPB.includes(~presetSeqStart[track])} {p = ~sectionPB.choose+1}
		{~sectionPBD.includes(~presetSeqStart[track])} {p = ~sectionPBD.choose+1}
		{~sectionPBN.includes(~presetSeqStart[track])} {p = ~sectionPBN.choose+1}
		{~sectionPL.includes(~presetSeqStart[track])} {p = ~sectionPL.choose+1}
		{~sectionPLD.includes(~presetSeqStart[track])} {p = ~sectionPLD.choose+1}
		{~sectionPLN.includes(~presetSeqStart[track])} {p = ~sectionPLN.choose+1}
		{~sectionTNM.includes(~presetSeqStart[track])} {p = ~sectionTNM.choose+1}
		{~sectionTE.includes(~presetSeqStart[track])} {p = ~sectionTE.choose+1}
		{~sectionTF.includes(~presetSeqStart[track])} {p = ~sectionTF.choose+1}
		{~sectionTV.includes(~presetSeqStart[track])} {p = ~sectionTV.choose+1}
		{~sectionTS.includes(~presetSeqStart[track])} {p = ~sectionTS.choose+1};
		// p.postln;
		pr = ~presetSeqStart[track];
		if (~currentTab == 0 and: {track == ~tracksValue}, {
			~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([p, p]));
			if ((p-2..p+2).includes(pr), { }, {~seqComp5.visibleOrigin = 0@( (~presetSeqStart[track]-4)*20).max(0) });
		},{
			~presetSeqRangeViewG[track].valueAction_(~presetSeqRangeSpec.unmap([p, p]));
			if ((p-2..p+2).includes(pr), { }, {~seqCompG1[track].visibleOrigin = 0@( (~presetSeqStart[track]-10)*20).max(0) });
		});
	}.defer;
};

~tracksPresetColorModel1 = [0, 2, 4 /*, 6*/]; // Pistes concernées par les couleurs des séquences de trame ci-dessous // initialisé dans la GUI à toutes les pistes
~blueColor1= Color.new255(74, 59, 255); // Intérêt normal (~blueColorRoyal)
~blueColor2 = Color.new255(152, 56, 255); // Intérêt moyen (~purpleColor1)
// ~blueColor3 = Color.new255(255, 50, 250); // Intérêt important (~purpleColor2)
// ~yellowColor1 = Color.new255(255, 137, 0); // Intérêt normal (~orangeColor1)
~yellowColor1 = Color.new255(255, 198, 0); // Intérêt moyen (~orangeColor2)
~yellowColor2 = Color.new255(252, 255, 0); // Intérêt important (~yellowColor)

// Colorisation à reporter a. dans _Init Lemur3 pour ~lemurColors
(0..29).do { |i| ~trameSequencesColors[i] = ~blueColor1 }; // ~trameSequencesColors est initialisée dans la GUI
(30..41).do { |i| ~trameSequencesColors[i] = ~blueColor2 };
(42..70).do { |i| ~trameSequencesColors[i] = ~blueColor1 };
(71..124).do { |i| ~trameSequencesColors[i] = ~blueColor2 };
/*(142..187).do { |i| ~trameSequencesColors[i] = Color.green(0.4) };
(188..199).do { |i| ~trameSequencesColors[i] = ~blueColor1 };
(200..233).do { |i| ~trameSequencesColors[i] = Color.red(0.5) }; // les pistes ryhtmiques en Bordeaux
(234..239).do { |i| ~trameSequencesColors[i] = Color.grey(0.3) };*/

~tracksPresetColorModel1.do { |i| ~tracksColorizeFunction.(i) }; // Initialisation de ~tracksColorizeFunction & ~seqsColorizeFunction dans la GUI
// ~tracksColorizeFunction.(0); ~tracksColorizeFunction.(2); ~tracksColorizeFunction.(4); ~tracksColorizeFunction.(6); ~tracksColorizeFunction.(8);
// [9,11,13].do { |tr| ~presetSeqRandList[tr].do { |seq| ~presetSeqTextViewG[tr][seq].background_(Color.red(0.5)); }}; // Mettre les pistes ryhtmiques en Bordeaux

// Marquage des zones Essentielles XXX
// /*~tracksPresetColorModel1*/[0, 2, 4/*, 6*/].do { |t| ([4,5,9,12,15,26,32,33,34,34,36,37,38,39,40,41,42,43,44,48,49,68,69,70,71,76,79,87,94,104,105,107,109,111,112,114,118,119,120,121]-1).do { |i| ~presetSeqTextViewG[t][i].stringColor_(Color.green); ~presetSeqNbViewG[t][i].stringColor_(Color.green); } };
~tracksPresetColorModel1.do { |t| ([1, 2, 9, 19, 105]-1).do { |i| ~presetSeqTextViewG[t][i].stringColor_(Color.green); ~presetSeqNbViewG[t][i].stringColor_(Color.green); } };

// Marquage des zones importantes XXX
~tracksPresetColorModel1/*[0, 2, 4/*, 6*/]*/.do { |t| ([4, 5, 6, 14, 20, 25, 27, 28, 30, 63, 64, 75, 77, 81 /*, 129, 130, 133, 143, 149, 150, 163, 194, 199, 200, 208, 209, 215, 216, 217, 218, 220, 221, 224, 228, 233, 234*/ ]-1).do { |i| ~presetSeqTextViewG[t][i].stringColor_(Color.yellow(0.8))/*.font_(Font("Helvetica-Bold", 12))*/; ~presetSeqNbViewG[t][i].stringColor_(Color.yellow); } };

~tracksPresetColorModel1.do { |t| ~nbOfSeqs.do { |i| // Afficher les BufSequence avec une couleur de fond différentes
	if (~bufSequence[t][i] != [0,0], { ~presetSeqNbViewG[t][i].stringColor_(Color.red) /*~presetSeqNbViewG[0][i].background_(Color.blue)*/ });// trouver une meilleure couleur ???
} };

"Final Step 3 : Random Sections defined & Sequences Colorized";
)


( // Final Step 4 : (Modification de ~randAssociationFunction)
// TracksPreset Variations (associated to a trackspreset file, but not compulsory since it is based on the nb of the sequence and not the name) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// & Initialisation du Lemur


~presetTracksVariationsFileName = ~presetsTracksFileName.split($.)[0]+"_Vars1.txt";

~presetTracksVariationsPath = (PathName.new(thisProcess.nowExecutingPath/*~currentPath*/).pathOnly ++ ~presetTracksVariationsFileName);
~presetTracksVariationsFileW = ZArchive.read(~presetTracksVariationsPath);
~presetTracksVariations = ~presetTracksVariationsFileW.readItem;
~presetTracksVariationsFileW.close;

// NEW format remplacant ~sequenceAssociationPageFormat et celui ci-dessus [track, track] [preset N°, preset N°]
~sequenceAssociationTrackFormat = [ [0,2,4], [0,2,4], [0,2,4], [0,2,4], [0,2,4], [8,10,12], [8,10,12], [8,10,12], [8,10,12], [0,2,4] ]; // déjà initialisé dans la GUI ...

~ryRatRange = 0.3; ~ryRatBase = 0.4; // ~ryRatRand = ~ryRatRange.rand2; if (~ryRatRand > 0, { ~ryRatRand = ~ryRatRand+~ryRatBase }, { ~ryRatRand = ~ryRatRand-~ryRatBase })

// Change the colors de Preset Association Tabs
~tabbedPresetVars.tabAt(5).unfocusedColor_(Color.yellow).labelColor_(Color.magenta/*red*/);
~tabbedPresetVars.tabAt(6).unfocusedColor_(Color.yellow).labelColor_(Color.magenta/*blue*/);
~tabbedPresetVars.tabAt(7).unfocusedColor_(Color.yellow).labelColor_(Color.magenta/*red*/);
~tabbedPresetVars.tabAt(8).unfocusedColor_(Color.yellow).labelColor_(Color.magenta/*red*/);
~tabbedPresetVars.tabAt(9).unfocusedColor_(Color.red/*yellow*/).labelColor_(Color.magenta/*red*/);

~presetAssociationNames = 0 ! 10;
// ~presetAssociationNames[0] = ~presetTracksVariations.keys.asArray.sort; // Ci-dessous, préférable pour éviter un classement tel que 1, 10, 11, 2....
~presetAssociationNames[0] = ~presetTracksVariations.keys.asArray.reject({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 1ère page
if (~presetTracksVariations.keys.size > 60, { ~presetAssociationNames[1] = ~presetAssociationNames[0].copyRange(60,120) }); // 2eme page
// ~presetAssociationNames[3] = ~presetTracksVariations.keys.asArray.reject({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 3ère page
// if (~presetTracksVariations.keys.size > 60, { ~presetAssociationNames[4] = ~presetAssociationNames[0].copyRange(60,120) }); // 4eme page

~presetAssociationNames[5] = ~presetTracksVariations.keys.asArray.select({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 5ème page
// if (~presetTracksVariations.keys.size > 60, { ~presetAssociationNames[4] = ~presetAssociationNames[0].copyRange(60,120) }); // 6ème page

// Réarrangement de la liste rythmique
// ~presetAssociationNames[6] = [ 'Ry A 5 - Dou', 'Ry A 6 ];

// ~presetAssociationNames[7] = ~presetTracksVariations.keys.asArray.select({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 6ème page avec les rhytmiques commencant par Ry

~globalRandAssPresets = [0,0] ! 60 ! ~nbOfpresetVarsPages; // à associer à la variable du nombre de pages de presets (~nbOfpresetVarsPages) ?
~sequenceAssociationTrackFormat.do { |i, id| ~globalRandAssPresets[id] = {0 ! i.size} ! 60  ! ~nbOfpresetVarsPages };

// ~presetSeqRandList[~sequenceAssociationTrackFormat[id][i]/*~tracksValue*/].choose

~globalRandAssPresets.do { |i, id|
	if (i[0][0].size == 2, { // i[0][0].size.postln;
		~globalRandAssPresets[id] =
		// ~sequenceAssociationTrackFormat[id][0].size.do { |a, ad| ~presetSeqRandList[~sequenceAssociationTrackFormat[id][a]/*~tracksValue*/].choose ! ~presetSeqRandList[~sequenceAssociationTrackFormat[id][0]/*~tracksValue*/].size } ! 60;
		{ [ ~presetSeqRandList[~sequenceAssociationTrackFormat[id][0]/*~tracksValue*/].choose, ~presetSeqRandList[~sequenceAssociationTrackFormat[id][1]/*~tracksValue*/].choose ] } ! 60;
	},{ ~globalRandAssPresets[id] =
		{ [ ~presetSeqRandList[~sequenceAssociationTrackFormat[id][0]/*~tracksValue*/].choose, ~presetSeqRandList[~sequenceAssociationTrackFormat[id][1]/*~tracksValue*/].choose , ~presetSeqRandList[~sequenceAssociationTrackFormat[id][2]/*~tracksValue*/].choose /*, ~presetSeqRandList[~sequenceAssociationTrackFormat[id][3]/*~tracksValue*/].choose , ~presetSeqRandList[~sequenceAssociationTrackFormat[id][4]/*~tracksValue*/].choose*/ ] } ! 60;
	});
};

~nbOfpresetVarsPages.do {|i|
	~presetVarsAssociationRefresh.(i); // Update des BoxMatrix
	// Update des TabbedView Names - Comment l'updater en moins de code plus efficacement ???
	~tabbedPresetVars.add(~sequenceAssociationTrackFormat[i].asString.replace(" ", "") );
	~tabbedPresetVarsPages[i].label_( [[0,2,4],[0,2,4],[0,2,4],[0,2,4],[0,2,4],5,6,7,8,9][i].asString.replace(" ", "") /*~sequenceAssociationTrackFormat[i].asString.replace(" ", "")*/ );
};

// ~presetVarsOpenView.valueAction_(1)/*.valueAction_(0)*/; // necessaire d'ouvrir et d'initialiser la fenêtre de Preset Associations pour pouvoir écrire dans le Lemur les ~lemurPresetNamesFunction -> déjà ouvert ....
// {~presetVarsOpenView.valueAction_(0)}.defer(0.2); // peut-être laisser ouvert la fenêtre de Preset Associations & necessaire de mettre un defer, sinon message d'erreur

// "/Users/xon/Live4Life/L4L_Project/_Init Lemur53.scd".load;
"_Init Lemur53.scd".loadRelative; // Mise en place du Twister 2

/*(~presetAssociationNames[0] ++ ~presetAssociationNames[5]).do { |i| i.postln };*/
// Listing des keys de la 1ère page & 6ème page
"Final Step 4 : TracksPreset Variations loaded";
)


// Pour le réarrangement de la liste de Preset Ass Variations :
~listPresetAssociationNewSort.(5); // Postln les new ~presetAssociationNames[0] swapés
~listPresetAssociationNewSortA.(5); // Post l'Array des new ~presetAssociationNames[0] swapés


( // Ecriture du TracksPreset Variations
~presetTracksVariationsPath = (PathName.new(~currentPath).pathOnly ++ ~presetTracksVariationsFileName);
~presetTracksVariationsFile = ZArchive.write(~presetTracksVariationsPath);
~presetTracksVariationsFile.writeItem(~presetTracksVariations);
~presetTracksVariationsFile.writeClose;
)