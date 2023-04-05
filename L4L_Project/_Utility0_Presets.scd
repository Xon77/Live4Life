~presets.keys.size; // Nb de presets dans la ListView
~presets.asCompileString; // Données de tous les presets - prend plusieurs secondes à se générer et incomplet car String trop long


// Liste des Presets
Post << ~presets.keys; // Liste de tous les noms de presets pour les séquences (dans le désordre)
~presets.keys.size.do { |i| ~presets.keys.asArray[i].asString.postln }; // Liste de tous les noms de presets pour les séquences (dans le désordre)
~presets.keys.size.do { |i| ~presetSelectionView.items[i + 0].postln}; // Liste de tous les noms de presets pour les séquences (trié) XXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetList.do { |it, in| (in +" -> " + it).postln }; // Liste de tous les noms de presets pour les séquences (trié) XXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetList.choose.asSymbol; // Choix aléatoire d'un nom de preset dans la Liste
~presetList.size;
~presets.cs;


// Nom du Preset sélectionné
~presetSelectionView.item.asSymbol; // Preset sélectionné dans la ListView
~presetSelection[0][~seqSeq[0]].asSymbol; // Preset en cours de lecture de la 1ère piste
~presetSelection[~tracksValue][~seqsValue].asSymbol; // Preset sélectionné de la piste et de la séquence sélectionnée XXXXXXXXXXXXXXXXXXXXXXXXXXX


// Liste de paramètres du Preset sélectionné
~presets[~presetSelectionView.item.asSymbol].cs; // Liste des paramètres du preset sélectionné dans la ListView
~presets[~presetSelection[0][~seqSeq[0]].asSymbol]; // Liste des paramètres du preset en cours de lecture
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol].cs; // // Liste des paramètres du Preset sélectionné de la piste et de la séquence sélectionnée XXXXXXXXXXXXXXXXXXXXXXXXXXX


// Accès à certaines données spécifiques
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\outLMin];
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\outLMax];
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\outLView];

~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\rtmView].size;
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\delView]
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\spaView];
~spaView.valueAction_(~presets[index][\spaView]);

~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\fxSynth]
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\fxSynthNum]
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\fxSynthData]

~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\bufFolderView]
~presets[~presetSelection[~tracksValue][~seqsValue].asSymbol][\bufMax].min(~foldersSize[~presets[~presetSelectionView.item.asSymbol][\bufFolderView]]-1)


// Attribution aléatoire de presets à des séquences SANS mise à jour graphique totale
~presetGetFunction.(~presetList.choose.asSymbol.postln); // Mise à jour visuelle des valeurs dans l'interface graphique, mais pas du nom du preset dans les ~presetSeqTextView
~presetGetFunctionQuick.value(~presetList.choose.asSymbol.postln, ~tracksValue, ~seqsValue); // Mise à jour des valeurs, mais pas dans l'interface graphique et ni du nom du preset dans les ~presetSeqTextView
~updateALLView.value; // Mise à jour dans l'interface graphique à partir des données d'un preset déjà attribué, mais pas du nom du preset dans les ~presetSeqTextView





(
// To change some values in all Presets, except the preset which is currently selected.
// For the current preset, you have to change it directly with the GUI and save it with the store Button.
// In this case, the lines, which are decommented, ...
{
	~presets.do { |item, i|

		// ~presetSelectionView.valueAction_(i);

		/*~outLRangePresetView.valueAction_(10); // 4 pour le 5 Sorties & 7 pour le 8 Sorties & 9 pour le 16 sorties
		~outRRangePresetView.valueAction_(10);
		~outLRandView.valueAction_(1); // Pour randomizer le multislider
		~outRRandView.valueAction_(1);*/

		/*~presets[~presets.keys.as(Array)[i].asSymbol][\outLMin] = 0 /*16*/;
		~presets[~presets.keys.as(Array)[i].asSymbol][\outRMin] = 0 /*16*/;
		~presets[~presets.keys.as(Array)[i].asSymbol][\outLMax] = 32 /*16*/;
		~presets[~presets.keys.as(Array)[i].asSymbol][\outRMax] = 32 /*16*/;*/

		/*
		~presets[~presets.keys.as(Array)[1].asSymbol][\outLMax];
		~presets[~presets.keys.as(Array)[1].asSymbol][\outLView]; // Accès aux données du MultiSlider
		~presets[~presets.keys.as(Array)[1].asSymbol][\outLView].size.collect {1.0.rand}; // Modif des données du MultiSlider
		*/

		// Modif de la configuration spatiale
		item[\outLMin] = 1; // 1 est le minimum
		item[\outRMin] = 1;
		item[\outLMax] = 32 /*16*/;
		item[\outRMax] = 32 /*16*/;
		item[\outLView] = item[\outLView].size.collect {1.0.rand}; // équivalent au ~outLRandView -> à chaque changement de config spatiale, il y a une légère différence dans le preset spatial (pointilliste / circulaire / ... )
		item[\outRView] = item[\outRView].size.collect {1.0.rand};
		// ~presets[~presets.keys.asArray[0]][\outLView]


		/*if (item[\outLPatSelView] == 45, {item[\outLPatSelView] = 49});
		if (item[\outRPatSelView] == 45, {item[\outRPatSelView] = 49});*/
		/*item[\outLPatSelView] = 49;
		item[\outRPatSelView] = 49;*/
		/*~outRPatSelView.valueAction_(49)
		~presets[~presets.keys.asArray[0]][\outLPatSelView]*/



		// ~presetSelectionView.valueAction_(i*2); // pour dupliquer un preset

		/*~presetStoringNameView.string_(~presetStoringNameView.string++"_x1"); // Pour changer le multiplicateur de la durée
		~legMulPresetView.valueAction_(10);*/ // \legMul

		/*~presetStoringNameView.string_(~presetStoringNameView.string++"_PanF"); // Pour changer l'algo du Pan
		~panPatSelView.valueAction_(4); // \panPatSelView
		~panPatView.valueAction_(1);*/ // \panPatView



		/*
		~synRangePresetView.valueAction_(4); // Pour resélectionner les RangeViews de certains modules et tout sélectionner  \synMin \synMax
		~spaRangePresetView.valueAction_(13); //  \spaMin \spaMax
		~envRangePresetView.valueAction_(6); //  \envMin \envMax

		~panRoundView.valueAction_(0); // Pour charger le format d'arrondissement des valeurs de Pan (0.01 -> 0 / 0.1 -> 1)  \panRoundView
		~panRandView.valueAction_(1);

		~proRoundView.valueAction_(0); // \proRoundView
		~rtmRandView.valueAction_(1); // Pour récupérer le nouveau format ~displayRythm \displayRhythm
		*/

	}; "fini".postln;

}.fork /*(AppClock)*/
)

// Evaluate this last line to save Presets file with the new values XXXXXXXXXXXXXXXXXXXXXXXXXXX
~savePresetFileView.valueAction_(0); ~savePresetFileView.valueAction_(1); ~savePresetFileView.valueAction_(0);

// And to see the modified presets, You need to relaod the GUI with...