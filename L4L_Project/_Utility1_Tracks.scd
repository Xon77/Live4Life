

( // To copy sequences of a track to another track
~trackFromCopy = ~tracksValue;
~trackToCopy = 6;

~presetsDontTriggerFX = 1; // Protection pour ne pas déclencher les effets des presets lors du chargement de tous les presets dans les pistes
// ~tracksView.valueAction_(~trackToCopy);

~nbOfSeqs.do { |i|

	~presetSeqNbSelectDurViewG[~trackToCopy][i].valueAction_(~presetSeqNbSelectDurValue[~trackFromCopy][i]);

	if (~presetSelection[~trackFromCopy][i].asInteger/*~presetsTracks[index][1][x][y].asInteger*/ != 0, {
		~presetGetFunctionQuick.value(/*~presetsTracks[index][1][x][y]*/ ~presetSelection[~trackFromCopy][i].asSymbol, ~trackToCopy, i) });

	~presetSelection[~trackToCopy][i] = ~presetSelection[~trackFromCopy][i];
	~presetSeqTextView[i].string_(~presetSelection[~trackFromCopy][i]); // Apparemment pas nécessaire - Pourquoi ?????????
	~presetSeqTextViewG[~trackToCopy][i].string_(~presetSelection[~trackFromCopy][i]);
};
~presetsDontTriggerFX = 0;
)