( // To change some values in all Presets
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
		/*item[\outLView] = item[\outLView].size.collect {1.0.rand}; // équivalent au ~outLRandView -> à chaque changement de config spatiale, il y a une légère différence dans le preset spatial (pointilliste / circulaire / ... )
		item[\outRView] = item[\outRView].size.collect {1.0.rand};*/
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