{

	/*

	// Mode 1 et 2 controleurs
	// 2ème controleur MIDI Akai pour le controle des séquences de chaque piste
	// et non seulement de la piste sélectionnée comme sur le 1er controleur qui se focalise davantage sur les modes de lecture de la piste (lecture à 0 ou continue / montage x1 / x3)

	// 1er controleur :
	- (1) Espace sur la piste sélectionée // (actuellement sélection des 4 Big Families sur piste 1 & 3)
	- (8) Quantisation
	- (8) Lecture à 0
	- (8) Lecture continue
	- (8) Montage x 1
	- (8) Montage x 3
	- (8) Sélection de la piste
	- (1) Dossier Source sur la piste sélectionée
	- (8 Boutons) Mute // (actuellement sélection des séquences de la piste sélectionée)

	// 2eme controleur :
	// Les Big Families doivent changer avec les Beats (comment les organiser ?) -> Introduction d'une nouvelle famille Beat
	- (5 x 8) Big Families : Pieces / Douceur / Violence / Eléments + 1 Beat (rythmique)
	// - (8) Changement aléatoire de séquence (alt + M)
	- (8) Changement aléatoire de séquence du même type Small Family (M) XXX
	- (8) Changement vers la séquence -1 // (^¨) XXX
	- (8) Changement vers la séquence +1 // (*$) XXX
	- (8 Boutons) Redéclenchement du Preset sélectioné ou de toute la piste
	// serait intéressant d'avoir la séquence précédente et suivante ?
	// Usage des sliders ?

	*/



	/*

	Changement effectué dans la classe APCmini

	ligne 83 initiale -> MIDIClient.init;
	Changement -> if (MIDIClient.initialized.not, {MIDIClient.init; });

	ligne 90 initiale -> if (dest.device=="APC MINI-APC MINI MIDI 1") {
	Changement -> if (dest.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/) {

	ligne 94 initiale -> if ( thisProcess.platform.isKindOf(LinuxPlatform) ) {
	Changement -> if ( thisProcess.platform.name == \linux /*thisProcess.platform.isKindOf(LinuxPlatform)*/ ) {

	ligne 98 initiale -> sources.do{|d| if (d.device.split($-)[0]=="SuperCollider") { n = n+1 } };
	Changement -> sources.do{|d| if (d.device.split($-)[0]=="APC MINI"/*"SuperCollider"*/) { n = n+1 } };

	lignes 109 à 111 initiales ->
	if (sources.select{|d|d.device=="APC MINI-APC MINI MIDI 1"}.size!=0) {
	sources.do{|d|if (d.device=="APC MINI-APC MINI MIDI 1") {uid=d.uid}};
	if ( thisProcess.platform.isKindOf(LinuxPlatform) ) {
	Changement ->
	if (sources.select{|d|d.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/}.size!=0) {
	sources.do{|d|if (d.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/) {uid=d.uid}};
	if ( thisProcess.platform.name == \linux /*thisProcess.platform.isKindOf(LinuxPlatform)*/ ) {

	ligne 279 / 347 / 387 initiale -> });
	Changement -> }, srcID: uid /*1990386095*/);

	ligne 428 initiale -> horMode.put(num,mode);
	Changement -> /*hor*/verMode.put(num,mode); // Erreur à l'origine

	lignes 463 à 464 initiales ->
	array = array.collect{|e|if(e.isSymbol){colors.at(e)}{e}};
	padColorsOfStates.put(row,column,Dictionary.newFrom(array).postln);
	Changement ->
	array = array.collect{|e|if(e.class == Symbol/*isSymbol*/){colors.at(e)}{e}};
	padColorsOfStates.put(row,column,Dictionary.newFrom(array)/*.postln*/); // .postln retiré du Quark d'origine

	ligne 471 initiale -> array = array.collect{|e|if(e.isSymbol){colors.at(e)}{e}};
	Changement -> array = array.collect{|e|if(e.class == Symbol/*isSymbol*/){colors.at(e)}{e}};

	Implémentation des 2 fonctions suivantes (à la fin dans la section Private) :

	decrementState { |r,c|
	var state = padInternalState.at(r,c);
	var max = padSwitchNumStates.at(r,c);

	state = state - 1;
	if (state.isNegative) {	state = 0 };

	padInternalState.put(r,c,state);

	^state;
	}

	setState { |r,c,f|
	var state = f; // padInternalState.at(r,c);
	var max = padSwitchNumStates.at(r,c);

	// state = f;
	if (state == max) {	state = 0 };

	padInternalState.put(r,c,state);

	// set light
	out.noteOn(0,this.apcIndex(r,c);/*pad*/,padColorsOfStates.at(r,c).at(state));

	^state;
	}

	"5.do{ |j|" au lieu de "10.do{ |j|" dans PlayAnimation

	*/



	(

		MIDIClient.sources.do{ |d|

			if (d.device == "APC MINI" , {

				// create a new instance...
				~aController = APCmini.new;
				~akaiSwichSpeed = 0;
				~akaiSpeedTime = 0.2;
				~aControllerConnected = 1;

				~akaiRtm = 1 ! 16 /*~nbOfTracksX2*/; // Pour l'update rythmique de l'Akai APC mini
				~lastABPlaying = 0 ! 8; // Pour l'update rythmique de l'Akai APC mini pour savoir si la fonction Play doit être mis à jour

				0.1.wait;

				/*
				~aController.setState(2,0,1);
				~aController.setState(2,0,0);
				*/

				8.do { |i|


					// PADS


					// 1ère ligne -> Spatialisation -> définie plus bas car chaque pad appelle une fonction particulière
					~aController.setPadMode(0,i,\hold); // Mode
					~aController.setPadHoldColor(0,i,\green);


					// 2ème ligne -> contrôle de la quantisation et du Xfade
					~aController.setPadMode(1,i,\switch); // Mode
					~aController.setNumStates(1,i,2); // (row, column, nb of states)
					~aController.setColorsOfStates(1,i,[0,\orange,1,\red]);
					~aController.setPadFunction(1,i,0, {
						~xqViewG[i*2].valueAction_(0); ~xqViewG[i*2+1].valueAction_(0);
					});
					~aController.setPadFunction(1,i,1, {
						~xqViewG[i*2].valueAction_(1); ~xqViewG[i*2+1].valueAction_(1);
					});
					~aController.setState(1,i,0);


					// 3ème ligne -> contrôle de lecture de la piste avec remise à 0
					// ~playViewG
					~aController.setPadMode(2,i,\switch); // Mode
					~aController.setNumStates(2,i,3); // (row, column, nb of states)
					~aController.setColorsOfStates(2,i,[0,\black,1,\green,2,\blinkRed]);
					~aController.setPadFunction(2,i,0, { var t; // "bye".postln;
						// ~aController.padInternalState[2,i].postln;
						if (~aController.padInternalState[6,i] == 0, { t = (i*2) }, { t = (i*2)+1 } );
						{
							if (~playControlView[t/*~tracksValue*/].acceptsMouse == true, {
								if (~playViewValue[t] == 1, { ~playControlView[t].valueAction_(0); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) }, { ~playControlView[t].valueAction_(1); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) } );
							});
						}.defer;
						~aController.setState(2,i,0);
						~aController.setState(3,i,0);
					});
					~aController.setPadFunction(2,i,1, { var t; // "How".postln;
						// ~aController.padInternalState[2,i].postln;
						if (~aController.padInternalState[6,i] == 0, { t = (i*2) }, { t = (i*2)+1 } );
						{
							if (~playControlView[t].acceptsMouse == true, {
								if (~playViewValue[t] == 1, { ~playControlView[t].valueAction_(0); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) }, { ~playControlView[t].valueAction_(1); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) } );
							});
						}.defer;
						~aController.incrementState(2,i);
						~aController.setState(3,i,1);
						~aController.incrementState(3,i);
					});
					~aController.setPadFunction(2,i,2, {
						// ~aController.padInternalState[2,i].postln;
						// "Hi".postln;
						/*~aController.setState(2,i,0);
						~aController.setState(3,i,0);*/
					});
					~aController.setState(2,i,0);


					// 4ème ligne -> contrôle de lecture de la piste en continu
					~aController.setPadMode(3,i,\switch); // Mode
					~aController.setNumStates(3,i,3); // (row, column, nb of states)
					~aController.setColorsOfStates(3,i,[0,\black,1,\green,2,\blinkRed]);
					~aController.setPadFunction(3,i,0, { var t; // "bye".postln;
						// ~aController.padInternalState[2,i].postln;
						if (~aController.padInternalState[6,i] == 0, { t = (i*2) }, { t = (i*2)+1 } );
						{
							if (((t).even && /*~playViewValue[(t) +1] == 1*/ ~lastABPlaying[i] == 1) || ((t).odd && /*~playViewValue[(t) -1] == 1*/ ~lastABPlaying[i] == 0 ), {
								"test".postln;
								if (~playControlView[t/*~tracksValue*/].acceptsMouse == true, {
									if (~playViewValue[t] == 1, { ~playControlView[t].valueAction_(0); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) }, { ~playControlView[t].valueAction_(1); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) } );
								});
								/*if (~playViewValue[t] == 0, {
								if (~xqViewValue[t] == 0, {
								// arguments à vérifier ???
								/*playMSwitch*/~play.value(npdef: ~patterns2[t], track: ~tracks[t], nfade: ~nFade[t], pfade: ~pFade[t], quant: ~quant[t], stretchdur: 1/1)
								}, {
								/*playMSwitch*/~play.value(npdef: ~patterns2[t], track: ~tracks[t], nfade: ~nFade[t], pfade: 0, quant: 0, stretchdur: 1/1)
								});
								});*/
							},{

								if (Pdef(~patterns2[t]).isPlaying == false, {

									Pdef(~patterns2[t]).resume;
									// "Hey".postln;
									~playControlView[t].value_(1); // ~playControlView[3].value_(1);
									~playViewValue[t] = 1;

									// pour faire un update automatique du XQ Play du CompositeView - plus nécessaire
									// ~playView.value_(~playViewValue[~tracksValue]);
									// mais necessaire pour le global
									~playViewG[t].value_(~playViewValue[t]);

									~playViewFunction.((t), ~playViewValue[t]);
								},{
									if (~playViewValue[t] == 0, {
										Pdef(~patterns2[t]).resume;
										// "Hey2".postln;
										~playControlView[t].value_(1);
										~playViewValue[t] = 1;

										~playViewG[t].value_(~playViewValue[t]);
										~playViewFunction.((t), ~playViewValue[t]);
									},{
										// "Ho".postln;
										if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1});
										~playControlView[t].valueAction_(0);
									});
								});
							});
							/*
							if (~playControlView[i*2].acceptsMouse == true, {
							if (~playViewValue[i*2] == 0, {
							~play2ControlView[i*2].valueAction_(1);
							}, {

							if (~xqViewValue[i*2] == 0, {

							// Pour mettre à jour le visuel - meilleur manière d'updater le visuel ??????
							// x 4 car x2 puisque 0.5.wait; et encore x par 2 du fait de la quantisation
							fork({ block { |break| // pour stopper la boucle quand arrêt du pattern
							((~quant[~tracksValue] / ~toTempo).round(0.01) * 4).do {
							if (Pdef(~patterns2[i*2]).isPlaying == true,

							// Pour mettre à jour le controlleur AKAI
							if (~aControllerConnected == 1, {
							~aController.setState(2,i,2);
							~aController.setState(3,i,2);
							});

							// Pour mettre à jour le visuel
							{
							~playControlView[i*2].states_([["Stopping", Color.red, Color.yellow], ["Playing", Color.white, Color.red]]); {~playControlView[i*2].acceptsMouse_(false)}.defer;
							~playViewG[i*2].states_([["ping", Color.red, Color.yellow], ["ying", Color.white, Color.red]]); {~playViewG[i*2].acceptsMouse_(false)}.defer

							// pour faire un update automatique du XQ Play du CompositeView - plus nécessaire
							/* ~playView.states_([["Stopping", Color.red, Color.yellow], ["Playing", Color.white, Color.red]]); {~playView.acceptsMouse_(false)}.defer */
							},{
							break.value;
							});
							0.5.wait; // lié au tempo ??? -> NON à chaque demi-seconde
							// "ok".postln; // juste pour tester
							}};
							~playControlView[i*2].states_([["Play", Color.black, Color.green], ["Playing", Color.white, Color.red]]);
							{~playControlView[i*2].acceptsMouse_(true)}.defer;
							~playViewG[i*2].states_([["Play", Color.black, Color.green], ["ying", Color.white, Color.red]]);
							{~playViewG[i*2].acceptsMouse_(true)}.defer;
							// pour faire un update automatique du XQ Play du CompositeView - plus nécessaire
							/*~playView.states_([["Play", Color.black, Color.green], ["Playing", Color.white, Color.red]]);
							{~playView.acceptsMouse_(true)}.defer;*/

							// Pour mettre à jour le controlleur AKAI
							if (~aControllerConnected == 1, {
							~aController.setState(2,i,0);
							~aController.setState(3,i,0);
							});

							});

							Pdef(~patterns2[i*2]).quant_(~quant[i*2]); Pdef(~patterns2[i*2]).pause

							}, {

							Pdef(~patterns2[i*2]).quant_(0); Pdef(~patterns2[i*2]).pause
							// voir utilisation de mute -> différence vs CPU ???
							});

							/*Pdef(~patterns2[i*2]).quant_(~quant[i*2]/*0*/); Pdef(~patterns2[i*2]).pause;*/ ~playViewValue[i*2] = 0; ~playControlView[i*2].value_(0);

							~playViewFunction.(i*2, ~playViewValue[i*2]); ~playViewG[i*2].value_(~playViewValue[i*2]);

							});
							});
							*/
						}.defer;
						~aController.setState(2,i,0);
						~aController.setState(3,i,0);
					});
					~aController.setPadFunction(3,i,1, { var t; // "bye".postln;
						// ~aController.padInternalState[2,i].postln;
						if (~aController.padInternalState[6,i] == 0, { t = (i*2) }, { t = (i*2)+1 } );
						{
							if (((t).even && /*~playViewValue[(t) +1] == 1*/ ~lastABPlaying[i] == 1) || ((t).odd && /*~playViewValue[(t) -1] == 1*/ ~lastABPlaying[i] == 0 ), {
								"test".postln;
								if (~playControlView[t/*~tracksValue*/].acceptsMouse == true, {
									if (~playViewValue[t] == 1, { ~playControlView[t].valueAction_(0); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) }, { ~playControlView[t].valueAction_(1); if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1}) } );
								});
								/*if (~playViewValue[t] == 0, {
								if (~xqViewValue[t] == 0, {
								// arguments à vérifier ???
								/*playMSwitch*/~play.value(npdef: ~patterns2[t], track: ~tracks[t], nfade: ~nFade[t], pfade: ~pFade[t], quant: ~quant[t], stretchdur: 1/1)
								}, {
								/*playMSwitch*/~play.value(npdef: ~patterns2[t], track: ~tracks[t], nfade: ~nFade[t], pfade: 0, quant: 0, stretchdur: 1/1)
								});
								});*/
							}, {

								if (Pdef(~patterns2[t]).isPlaying == false, {

									Pdef(~patterns2[t]).resume;
									// "Hey".postln;
									~playControlView[t].value_(1); // ~playControlView[3].value_(1);
									~playViewValue[t] = 1;

									// pour faire un update automatique du XQ Play du CompositeView - plus nécessaire
									// ~playView.value_(~playViewValue[~tracksValue]);
									// mais necessaire pour le global
									~playViewG[t].value_(~playViewValue[t]);
									~playViewFunction.((t), ~playViewValue[t]);
								},{
									if (~playViewValue[t] == 0, {

										Pdef(~patterns2[t]).resume;
										// "Hey2".postln;
										~playControlView[t].value_(1);
										~playViewValue[t] = 1;

										~playViewG[t].value_(~playViewValue[t]);
										~playViewFunction.((t), ~playViewValue[t]);
									},{
										// "Ho".postln;
										if (t.even, {~lastABPlaying[i] = 0},{~lastABPlaying[i] = 1});
										~playControlView[t].valueAction_(0);
									});
								});

							});
						}.defer;
						~aController.incrementState(3,i);
						~aController.setState(2,i,1);
						~aController.incrementState(2,i);
					});
					~aController.setPadFunction(3,i,2, {
						// "Hi".postln;
					});
					~aController.setState(3,i,0);


					// 5ème ligne -> contrôle de lecture itérative d'un évènement / Montage ne se fait actuellement que sur la premeière piste
					~prevTrack = 0;

					~aController.setPadMode(4,i,\hold); // Mode
					~aController.setPadHoldColor(4,i,\red);
					~aController.setColorsOfStates(4,i,[0,\black,1,\red]);
					~aController.setPadFunction(4,i,0, { // var prevTrack;
						// ~seqCompGABIndex[(~tracksValue/2).asInteger].postln;
						// ~aController.padInternalState[2,0].postln;
						{
							if (~prevTrack != i, {
								~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); // Pour remmettre la piste sur A à chaque fois si une autre est sélectionnée
								// if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); }, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); });
								~aController.setState(4,~prevTrack,0); ~aController.setState(4,(~tracksValue/2).asInteger,1);
								~aController.setState(5,~prevTrack,0); ~aController.setState(5,(~tracksValue/2).asInteger,1);
								// ~aController.setState(7,~prevTrack,0); ~aController.setState(7,(~tracksValue/2).asInteger,1);

								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							});

							~prevTrack = (~tracksValue/2).asInteger;

							// "Helllo".postln;
							if (~akaiSwichSpeed == 0, {
								if (~tracksValue != (i*2), {
									~tracksView.valueAction_(i*2);
									/*8.do { |b| ~aController.setState(6,b,0); };
									~aController.setState(6,i,1);
									~aController.incrementState(6,i);
									~aController.incrementState(6,i);*/
								}); ~curEventTrigFunction.(0);
							},{
								if (~tracksValue != (i*2), {
									~tracksView.valueAction_(i*2);
								}); ~curEventTrigFunction.(0);
							});

						}.defer;
						{~aController.setState(0,i,0);}.defer(/*0.3*/);
						// Pour garder le visuel de la piste sélectionnée
						{ if (~aController.padInternalState[5,i] == 1, { ~aController.setState(4,i,1); /*(0.01)*/ }); }.defer;

					});


					// 6ème ligne -> contrôle de lecture itérative de X évènements (déterminé par la GUI (par défaut 3)
					~aController.setPadMode(5,i,\hold); // Mode
					~aController.setPadHoldColor(5,i,\red);
					~aController.setColorsOfStates(5,i,[0,\black,1,\red]);
					~aController.setPadFunction(5,i,0, {	// var prevTrack;
						{
							if (~prevTrack != i, {
								~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); // Pour remmettre la piste sur A à chaque fois si une autre est sélectionnée
								// if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); }, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); });
								~aController.setState(4,~prevTrack,0); ~aController.setState(4,(~tracksValue/2).asInteger,1);
								~aController.setState(5,~prevTrack,0); ~aController.setState(5,(~tracksValue/2).asInteger,1);
								// ~aController.setState(7,~prevTrack,0); ~aController.setState(7,(~tracksValue/2).asInteger,1);

								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							});

							~prevTrack = (~tracksValue/2).asInteger;

							// "Helllo 2".postln;
							if (~tracksValue != (i*2), { ~tracksView.valueAction_(i*2) });
							~curEventTrigFunction.(1);

						}.defer;
						{~aController.setState(0,i,0);}.defer(/*0.3*/);
						// Pour garder le visuel de la piste sélectionnée
						{ if (~aController.padInternalState[4,i] == 1, { ~aController.setState(5,i,1); /*(0.01)*/ }); }.defer;

					});


					// 7ème ligne -> contrôle de la piste sélectionnée
					~aController.setPadMode(6,i,\switch); // Mode
					~aController.setNumStates(6,i,2); // (row, column, nb of states)
					// ~aController.setColorsOfStates(6,i,[0,\black,1,\red,2,\orange]);
					~aController.setColorsOfStates(6,i,[0,\red,1,\orange]);
					~aController.setPadFunction(6,i,0, { var prevTrack;
						// ~seqCompGABIndex[(~tracksValue/2).asInteger].postln;
						// ~aController.padInternalState[2,0].postln;
						{
							if (prevTrack == i, {
								if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); }, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); });
								// 1 vert / 0 rien
								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							},{
								// ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); // Pour remmettre la piste sur A à chaque fois si une autre est sélectionnée
								if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); }, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); });
								~aController.setState(4,prevTrack,0); ~aController.setState(4,(~tracksValue/2).asInteger,1);
								~aController.setState(5,prevTrack,0); ~aController.setState(5,(~tracksValue/2).asInteger,1);
								// ~aController.setState(7,prevTrack,0); ~aController.setState(7,(~tracksValue/2).asInteger,1);

								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							});
						}.defer;
						prevTrack = (~tracksValue/2).asInteger;
					});
					~aController.setPadFunction(6,i,1, { var prevTrack;
						{
							if (prevTrack == i, {
								if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); }, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); });
								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							},{
								~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); // Pour remmettre la piste sur A à chaque fois si une autre est sélectionnée
								// if (~seqCompGABIndex[i] == 1, { ~tracksView.valueAction_((i*2)+1); ~aController.setState(6,i,1); }, { ~tracksView.valueAction_(i*2); ~aController.setState(6,i,0); });
								~aController.setState(4,prevTrack,0); ~aController.setState(4,(~tracksValue/2).asInteger,1);
								~aController.setState(5,prevTrack,0); ~aController.setState(5,(~tracksValue/2).asInteger,1);
								// ~aController.setState(7,prevTrack,0); ~aController.setState(7,(~tracksValue/2).asInteger,1);

								if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
									if (~aController.padInternalState[2,i] == 0, {
										~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
									});
								},{
									if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
										~aController.setState(2,i,0); ~aController.setState(3,i,0);
									});
								});
							});
						}.defer;
						prevTrack = (~tracksValue/2).asInteger;
					});
					~aController.setState(6,i,0);
					// ~aController.setState(5,0,1); ~aController.setState(7,0,1);


					// 8ème ligne -> contrôle des dossiers de buffers
					~aController.setPadMode(7,i,\hold); // Mode
					~aController.setPadHoldColor(7,i,\green);
					/*~aController.setPadFunction(7,i,0, {
					"Helllo 3".postln;
					});*/


					// BUTTONS


					// Ligne horizontale de boutons -> contrôle des séquences
					~aController.setButtonMode(\hor,i,\hold); // (type, num, mode) // Mode

					/*~aController.setButtonFunction(\hor,i,1, {
					"Wow".postln;
					});*/


					// SLIDERS

					~aController.setSliderFunction(i, { |i,v|
						{
							if (v== 0, { ~aController.setState(0,i,0) } ); // pour l'update rythmique de l'Akai
							~trackVolView[i].valueAction_(v/127.0)
						}.defer /*[\slider,i,\value,v].postln*/
					});


				};





				// PADS


				// 1ère ligne -> contrôle de la spatialisation / FX / presets ou autres

				~aController.setPadFunction(0,0,1, { // 1 Fix
					{ /*~spaRangePresetItemsLV1Buttons[0].valueAction_(1)*/ if ( ~sequenceSection == 1,  {var p = ~sectionPieces.choose; ~presetSeqRangeViewG[0].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[0].visibleOrigin = 0@( (~presetSeqStart[0]-10)*20).max(0) }) }.defer;
				});
				~aController.setPadFunction(0,1,1, { // 2 Del
					{ /*~spaRangePresetItemsLV1Buttons[1].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionDouceur.choose; ~presetSeqRangeViewG[0].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[0].visibleOrigin = 0@( (~presetSeqStart[0]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,2,1, { // 3 Lines
					{ /*~spaRangePresetItemsLV1Buttons[2].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionViolence.choose; ~presetSeqRangeViewG[0].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[0].visibleOrigin = 0@( (~presetSeqStart[0]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,3,1, { // 4 C 1
					{ /*~spaRangePresetItemsLV2Buttons[0].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionElements.choose; ~presetSeqRangeViewG[0].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[0].visibleOrigin = 0@( (~presetSeqStart[0]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,4,1, { // 5 C M
					{ /*~spaRangePresetItemsLV2Buttons[3].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionPieces.choose; ~presetSeqRangeViewG[4].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[4].visibleOrigin = 0@( (~presetSeqStart[4]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,5,1, { // 6 Traj SD
					{ /*~spaRangePresetItemsLV3Buttons[0].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionDouceur.choose; ~presetSeqRangeViewG[4].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[4].visibleOrigin = 0@( (~presetSeqStart[4]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,6,1, { // 7 Traj
					{ /*~spaRangePresetItemsLV3Buttons[1].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionViolence.choose; ~presetSeqRangeViewG[4].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[4].visibleOrigin = 0@( (~presetSeqStart[4]-10)*20).max(0)  }) }.defer;
				});
				~aController.setPadFunction(0,7,1, { // 9 All
					{ /*~spaRangePresetItemsLV4Buttons[3].valueAction_(1)*/ if ( ~sequenceSection == 1, {var p = ~sectionElements.choose; ~presetSeqRangeViewG[4].valueAction_(~presetSeqRangeSpec.unmap([p, p])); ~seqCompG1[4].visibleOrigin = 0@( (~presetSeqStart[4]-10)*20).max(0)  }) }.defer;
				});





				// 8ème ligne -> contrôle des dossiers de buffers

				~aController.setPadFunction(7,0,1, { // <> -> Changement aléatoire dans certains types de dossiers sons (du même type)
					var f = { if (~foldersStructure == 1, {
						{ ~bufFolderView.valueAction_(~folderStructureValues[~kindOfFoldersSymbol.indexOf(~kindOfFoldersStructure[~bufFolderView.value].asSymbol)].choose); }.defer;
					}) };
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,0] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,1,1, { // <> -> Changement aléatoire Total
					var f = {{
						~bufFolderView.valueAction_(rand(~bufFolderSize1));
						~bufRangeView/*.valueAction_([0, ~bufRangeSpec[~tracksValue][~seqsValue].unmap(~bufFolderM[~tracksValue][~seqsValue].size-1)])*/.doAction;
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,1] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,2,1, {  // -1
					var f = {{
						~bufFolderView.valueAction_((~bufFolderView.value - 1).wrap/*clip*/(0, ~bufFolderSize1)); // wrap permet un navigation ininterrompue vs clip
						// ~nbFolders = ~bufFolderView.items.size // pour accélérer le changement // benchmark à faire ?????????
						~bufRangeView./*valueAction_([0, ~bufRangeSpec[~tracksValue][~seqsValue].unmap(~bufFolderM[~tracksValue][~seqsValue].size-1)]).*/doAction;
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,2] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,3,1, { // +1
					var f = {{
						~bufFolderView.valueAction_((~bufFolderView.value + 1).wrap/*clip*/(0, ~bufFolderSize1));
						~bufRangeView./*valueAction_([0, ~bufRangeSpec[~tracksValue][~seqsValue].unmap(~bufFolderM[~tracksValue][~seqsValue].size-1)]).*/doAction;
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,3] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,4,1, { // <> + shift -> Changement aléatoire dans certains types de dossiers sons (AR/AS)
					var f = { if (~folderStructureAValues.notNil, {{
						~bufFolderView.valueAction_(~folderStructureAValues.choose);
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer} ) };
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,4] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,5,1, { // <> + W -> Changement aléatoire dans certains types de dossiers sons (DR/IP)
					var f = {{
						~bufFolderView.valueAction_(~folderStructureDValues.choose);
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,5] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,6,1, { // <> + X-> Changement aléatoire dans certains types de dossiers sons (PN/IT)
					var f = {{
						~bufFolderView.valueAction_(~folderStructureIValues.choose);
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,6] == 0) { break.value };
							};
						}}.fork;
					});
				});


				~aController.setPadFunction(7,7,1, { // <> + C-> Changement aléatoire dans certains types de dossiers sons (RC/PZ)
					var f = {{
						~bufFolderView.valueAction_(~folderStructureRValues.choose);
						if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, {}, {~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.red) });
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.padInternalState[7,7] == 0) { break.value };
							};
						}}.fork;
					});
				});





				// SLIDER Global

				~dbVolAKSpec = ControlSpec(0, 1, 0, 0.0001);
				~aController.setSliderFunction(8, { |i,v| {~trackAllVolView.valueAction_(v/127* ~maxMulVolControllers /*127.0*/)/*(~dbVolAKSpec.unmap(v/(127.0+ 23.9/*32*/)))*/ }.defer /*[\slider,i,\value,v].postln*/ } );
				// 24 pour bloquer à  2.99 db // 32 pour bloquer à - 2.1 db

				// Changement du 7ème slider de piste pour controler les FX en attenndant un autre controleur
				if (~akFXVol8 == 1, {
					~aController.setSliderFunction(7, { |i,v|
						{
							// if (v== 0, { ~aController.setState(0,i,0) } ); // pour l'update rythmique de l'Akai
							~trackFXVolView.valueAction_(ControlSpec(0.025, 0.6, 'lin', 0.001, 1).map(v/127.0))/*(v/127.0)*/;
						}.defer /*[\slider,i,\value,v].postln*/
					});
				});





				// BUTTONS Ligne Horizontale


				// Ligne Horizontale - 1er bouton -> ^¨ -> Preset Selection -1
				~aController.setButtonFunction(\hor,0,1, {
					var f = {{
						if (~currentTab == 0, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/0]).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/0]-1).clip(0, ~nbOfSeqs)  ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/0]-4)*20).max(0)
						},{
							~presetSeqRangeViewG[/*~tracksValue*/0].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/0]).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/0]-1).clip(0, ~nbOfSeqs)  ]));
							~seqCompG1[/*~tracksValue*/0].visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/0]-10)*20).max(0)
						});
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.horInternalState[0] == 0) { break.value };
							};
						}}.fork;
					});
				});


				// Ligne Horizontale - 2ème bouton -> $  -> Preset Selection + 1 (-1 dans key2 car pas d'unicode)
				~aController.setButtonFunction(\hor,1,1, {
					var f = {{
						if (~currentTab == 0, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/0]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/0]+2).clip(0, ~nbOfSeqs)  ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/0]-4)*20).max(0)
						},{
							~presetSeqRangeViewG[/*~tracksValue*/0].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/0]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/0]+2).clip(0, ~nbOfSeqs)  ]));
							~seqCompG1[/*~tracksValue*/0].visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/0]-10)*20).max(0)
						});
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.horInternalState[1] == 0) { break.value };
							};
						}}.fork;
					});
				});


				// Ligne Horizontale - 3ème bouton -> ^¨ + alt-> Preset Selection précédente de la piste
				~aController.setButtonFunction(\hor,2,1,
					{
						var f = {{
							if (~currentTab == 0, {
								~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/ 4]).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/ 4]-1).clip(0, ~nbOfSeqs)  ]));
								~seqComp5.visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/ 4]-4)*20).max(0)
							},{
								~presetSeqRangeViewG[/*~tracksValue*/ 4].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/ 4]).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/ 4]-1).clip(0, ~nbOfSeqs)  ]));
								~seqCompG1[/*~tracksValue*/ 4].visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/ 4]-10)*20).max(0)
							});
						}.defer};
						if (~akaiSwichSpeed == 0, {
							f.();
						},{
							{block {|break|
								inf.do { |i| // i.postln;
									f.();
									~akaiSpeedTime.wait;
									if (~aController.horInternalState[2] == 0) { break.value };
								};
							}}.fork;
						});
					}
					/*{
					var f = {{
					var curPreset, tr;
					case
					{ ~tracksValue == 0 } { tr = 0 }
					{ ~tracksValue == 2 } { tr = 1 }
					{ ~tracksValue == 4 } { tr = 2 }
					{ ~tracksValue != 4 } { tr = nil };
					if (tr.notNil, {
					~positionInPresetSel[tr] = max(0, ~positionInPresetSel[tr] - 1);
					curPreset = ~presetsSelCollection[tr][~positionInPresetSel[tr]];

					if (curPreset == 0 or: {~positionInPresetSel[tr] == 0}, {
					~positionInPresetSel[tr] = ~positionInPresetSel[tr]  + 1; "No previous Selection".postln; // pour annuler la dernière action
					}, {
					~presetSeqStart[~tracksValue] = curPreset; ~presetSeqStop[~tracksValue] = curPreset;

					// Pour la fabrication de la séquence aléatoire à chaque fois que le RangeSlider est modifié
					~presetSeqRangeRand[~tracksValue] = Pxrand(~seq2[~tracksValue].copyRange(~presetSeqStart[~tracksValue], ~presetSeqStop[~tracksValue]), inf).asStream;

					// Changement de séquence dès que le RangeSlider est modifié sans attendre la fin de la séquence
					if (~seqChange == 1, {
					~seqBlock[~tracksValue] = 1;
					[\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i][~tracksValue] = 1};
					});

					// Armer la séquence si changement du rangeslider
					if (~curSeqTrig == 1, {
					if (Pdef(~patterns2[~tracksValue]).isPlaying == false, {
					if (~seqChange == 0, {~seqChangeViewG[0].valueAction_(1)});
					// ~seqsView.valueAction_(~presetSeqStart[~tracksValue]);
					if (~presetSeqStart[~tracksValue] >= ~nbOfSeqs, { ~seqsView.valueAction_( ~presetSeqNbSelectValue[~tracksValue][~presetSeqStart[~tracksValue] - ~nbOfSeqs]-1 );}, {~seqsView.valueAction_(~presetSeqStart[~tracksValue]);} ); // pour lire la bonne séquence quand la sélection est supérieure au ~nbOfSeqs
					});
					});

					if (~currentTab == 0, {
					~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~presetSeqRangeViewG[~tracksValue].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~seqComp5.visibleOrigin = 0@( (curPreset /*~presetSeqStart[~tracksValue]*/-4)*20).max(0)
					},{
					~presetSeqRangeViewG[~tracksValue].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~seqCompG1[~tracksValue].visibleOrigin = 0@( (curPreset /*~presetSeqStart[~tracksValue]*/-10)*20).max(0)
					});
					/*if (~presetSelection[~tracksValue][curPreset] != 0, {
					~presetGetFunction.value(~presetSelection[~tracksValue][curPreset].asSymbol);
					// ~presetGetFunction.value(~presetSelection[~tracksValue][~presetsSelCollection[0][~positionInPresetSel[0]]].asSymbol)
					if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, { ~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.grey(0.3)) });
					},{
					"0 -> No Preset".postln;
					});*/
					("Preset Memory Nb : " + (~positionInPresetSel[tr]+1-~presetsSelListMemoryNb)).postln;
					});
					});
					}.defer};
					if (~akaiSwichSpeed == 0, {
					f.();
					},{
					{block {|break|
					inf.do { |i| // i.postln;
					f.();
					~akaiSpeedTime.wait;
					if (~aController.horInternalState[2] == 0) { break.value };
					};
					}}.fork;
					});
				}*/);


				// Ligne Horizontale - 4ème bouton -> *$ + alt-> PresetSelection suivante de la piste
				~aController.setButtonFunction(\hor,3,1,
					{
						var f = {{
							if (~currentTab == 0, {
								~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/4]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/4]+2).clip(0, ~nbOfSeqs)  ]));
								~seqComp5.visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/4]-4)*20).max(0)
							},{
								~presetSeqRangeViewG[/*~tracksValue*/4].valueAction_(~presetSeqRangeSpec.unmap([ (~presetSeqStart[/*~tracksValue*/4]+2).clip(0, ~nbOfSeqs), (~presetSeqStart[/*~tracksValue*/4]+2).clip(0, ~nbOfSeqs)  ]));
								~seqCompG1[/*~tracksValue*/4].visibleOrigin = 0@( (~presetSeqStart[/*~tracksValue*/4]-10)*20).max(0)
							});
						}.defer};
						if (~akaiSwichSpeed == 0, {
							f.();
						},{
							{block {|break|
								inf.do { |i| // i.postln;
									f.();
									~akaiSpeedTime.wait;
									if (~aController.horInternalState[3] == 0) { break.value };
								};
							}}.fork;
						});
					}
					/*{
					var f = {{
					var curPreset, tr;
					case
					{ ~tracksValue == 0 } { tr = 0 }
					{ ~tracksValue == 2 } { tr = 1 }
					{ ~tracksValue == 4 } { tr = 2 }
					{ ~tracksValue != 4 } { tr = nil };
					if (tr.notNil, {
					~positionInPresetSel[tr] = min(~presetsSelListMemoryNb, ~positionInPresetSel[tr] +1);
					curPreset = ~presetsSelCollection[tr][~positionInPresetSel[tr]];

					if (~positionInPresetSel[tr] == ~presetsSelListMemoryNb, {
					~positionInPresetSel[tr] = ~positionInPresetSel[tr]  - 1; "No next Selection".postln; // pour annuler la dernière action
					},{
					~presetSeqStart[~tracksValue] = curPreset; ~presetSeqStop[~tracksValue] = curPreset;

					// Pour la fabrication de la séquence aléatoire à chaque fois que le RangeSlider est modifié
					~presetSeqRangeRand[~tracksValue] = Pxrand(~seq2[~tracksValue].copyRange(~presetSeqStart[~tracksValue], ~presetSeqStop[~tracksValue]), inf).asStream;

					// Changement de séquence dès que le RangeSlider est modifié sans attendre la fin de la séquence
					if (~seqChange == 1, {
					~seqBlock[~tracksValue] = 1;
					[\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i][~tracksValue] = 1};
					});

					// Armer la séquence si changement du rangeslider
					if (~curSeqTrig == 1, {
					if (Pdef(~patterns2[~tracksValue]).isPlaying == false, {
					if (~seqChange == 0, {~seqChangeViewG[0].valueAction_(1)});
					// ~seqsView.valueAction_(~presetSeqStart[~tracksValue]);
					if (~presetSeqStart[~tracksValue] >= ~nbOfSeqs, { ~seqsView.valueAction_( ~presetSeqNbSelectValue[~tracksValue][~presetSeqStart[~tracksValue] - ~nbOfSeqs]-1 );}, {~seqsView.valueAction_(~presetSeqStart[~tracksValue]);} ); // pour lire la bonne séquence quand la sélection est supérieure au ~nbOfSeqs
					});
					});

					if (~currentTab == 0, {
					~presetSeqRangeView.value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~presetSeqRangeViewG[~tracksValue].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~seqComp5.visibleOrigin = 0@( (curPreset /*~presetSeqStart[~tracksValue]*/-4)*20).max(0)
					},{
					~presetSeqRangeViewG[~tracksValue].value_(~presetSeqRangeSpec.unmap([ curPreset, curPreset+1 ]));
					~seqCompG1[~tracksValue].visibleOrigin = 0@( (curPreset /*~presetSeqStart[~tracksValue]*/-10)*20).max(0)
					});
					/*if (~presetSelection[~tracksValue][curPreset] != 0, {
					~presetGetFunction.value(~presetSelection[~tracksValue][curPreset].asSymbol);
					// ~presetGetFunction.value(~presetSelection[~tracksValue][~presetsSelCollection[0][~positionInPresetSel[0]]]);
					if (~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background == Color.red, { ~presetSeqTextViewG[~tracksValue][~seqSeq[~tracksValue]].background_(Color.grey(0.3)) });
					},{
					"0 -> No Preset".postln;
					});*/
					("Preset Memory Nb : " + (~positionInPresetSel[tr]+1-~presetsSelListMemoryNb)).postln;
					});
					});
					}.defer};
					if (~akaiSwichSpeed == 0, {
					f.();
					},{
					{block {|break|
					inf.do { |i| // i.postln;
					f.();
					~akaiSpeedTime.wait;
					if (~aController.horInternalState[3] == 0) { break.value };
					};
					}}.fork;
					});
				}*/);


				// Ligne Horizontale - 5ème bouton -> // M  Preset aléatoire dans la présélection très définie d'une famille small
				~aController.setButtonFunction(\hor,4,1, {
					if (~akaiSwichSpeed == 0, {
						~tracksChooseSmallFamilyFunction.(~tracksValue);
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								~tracksChooseSmallFamilyFunction.(~tracksValue);
								~akaiSpeedTime.wait;
								if (~aController.horInternalState[4] == 0) { break.value };
							};
						}}.fork;
					});
				});


				// Ligne Horizontale - 6ème bouton -> M + alt -> Preset aléatoire dans la présélection si disponible
				~aController.setButtonFunction(\hor,5,1, {

					var f = {{ var rand = ~presetSeqRandList[~tracksValue].choose;
						if (~currentTab == 0, {
							~presetSeqRangeView.valueAction_(~presetSeqRangeSpec.unmap([ rand, rand ]));
							~seqComp5.visibleOrigin = 0@( (~presetSeqStart[~tracksValue]-4)*20).max(0)
						},{
							~presetSeqRangeViewG[~tracksValue].valueAction_(~presetSeqRangeSpec.unmap([ rand, rand ]));
							~seqCompG1[~tracksValue].visibleOrigin = 0@( (~presetSeqStart[~tracksValue]-10)*20).max(0)
						});
					}.defer};
					if (~akaiSwichSpeed == 0, {
						f.();
					},{
						{block {|break|
							inf.do { |i| // i.postln;
								f.();
								~akaiSpeedTime.wait;
								if (~aController.horInternalState[4] == 0) { break.value };
							};
						}}.fork;
					});

				});


				// Ligne Horizontale - 7ème bouton -> P + alt -> Retrigger tous les presets de la piste
				~aController.setButtonFunction(\hor,6,1, {
					{ ~retriggerPresetPreViewG[~tracksValue].valueAction_(1); }.defer;
				});


				// Ligne Horizontale - 8ème bouton -> ~trackFXVolView.valueAction_(0.12);
				~aController.setButtonFunction(\hor,7,1, {
					{
						if (~trackFXVolView.value == 0.06, {~trackFXVolView.valueAction_(0.12)}, {~trackFXVolView.valueAction_(0.06)} );
						if (~trackFXVolView.value != 0.12 and: {~trackFXVolView.value != 0.06}, {~trackFXVolView.valueAction_(0.06)} );
					}.defer;
				});





				// Ligne Verticale


				8.do { |i|
					// Ligne Verticale de boutons -> contrôle individuels ?
					~aController.setButtonMode(\ver,i,\hold); // (type, num, mode) // Mode
					~aController.setButtonFunction(\ver,i,1, {
						// "Wow 3".postln;
					});
				};

				// Ligne Verticale - 1er bouton -> Stop All Clips
				// Juste besoin de lancer l'action qu'une seule et non pas quand le bouton est enfoncé ou pas
				/*~aController.setButtonFunction(\ver,0,0, {
				{ ~playAllControlView.value_(1); }.defer;
				// ~tracks.do {|tr| if (~playViewValue[tr] == 1, { {~playControlView[tr].valueAction_(0); ~playViewG[tr].value_(0) }.defer } ) };
				// 8.do { |i| ~aController.setState(1,i,0); }
				});*/
				~aController.setButtonFunction(\ver,0,1, {
					{ ~playAllControlView.valueAction_(1); }.defer;
					// ~tracks.do {|tr| if (~playViewValue[tr] == 1, { {~playControlView[tr].valueAction_(0); ~playViewG[tr].value_(0) }.defer } ) };
					// 8.do { |i| ~aController.setState(1,i,1); }
				});

				// Ligne Verticale - 2ème bouton -> contrôle de la quantisation et du Xfade de toutes les pistes
				~aController.setButtonMode(\ver,1,\switch); // (type, num, mode) // Mode
				~aController.setButtonFunction(\ver,1,0, {
					~xqAllControlView.valueAction_(0);
					8.do { |i| ~aController.setState(1,i,0); }
				});
				~aController.setButtonFunction(\ver,1,1, {
					~xqAllControlView.valueAction_(1);
					8.do { |i| ~aController.setState(1,i,1); }
				});

				// Lance et arrête les pistes Rythmiques
				~aController.setButtonFunction(\ver,2,1, {
					~rhythmTracksX2.do { |tr|
						if (~playViewValue[tr] == 1, {
							{if (~playControlView[tr].acceptsMouse == true, {~playControlView[tr].valueAction_(0); ~playViewG[tr].value_(0)}) }.defer;
							}, {
							{if (~playControlView[tr].acceptsMouse == true, {~playControlView[tr].valueAction_(1); ~playViewG[tr].value_(1)}) }.defer;
						});
					};
				});


				// Ligne Verticale - 4ème bouton -> contrôle du débit pour le changement des presets / buffers ....
				~aController.setButtonMode(\ver,4,\switch); // (type, num, mode) // Mode
				~aController.setButtonFunction(\ver,4,0, {
					~akaiSwichSpeed = 0;
				});
				~aController.setButtonFunction(\ver,4,1, {
					~akaiSwichSpeed = 1;
				});


				// Ligne Verticale - 6ème bouton -> Backspace -> pour alterner entre le Tab séquence et le Tab global
				~aController.setButtonMode(\ver,5,\hold); // (type, num, mode) // Mode
				~aController.setButtonFunction(\ver,5,1, {
					{ if (~currentTab == 0, {~tabbedView.focus(1)}, {~tabbedView.focus(0)}) }.defer;
				});


				// Ligne Verticale - 7ème bouton -> Return -> switcher entre les différentes Tracks qui sont jouées
				~aController.setButtonMode(\ver,6,\hold); // (type, num, mode) // Mode
				~aController.setButtonFunction(\ver,6,1, { ~prevAkaiTrack = (~tracksValue/2).asInteger;

					if (~playViewValue.sum > 0, {
						{
							~switchTracksAllControlView.valueAction_(1);
							// ~tracksValue.postln;
							// ~tracksView.valueAction_(~tracksValue); ~aController.setState(6,(~tracksValue/2).asInteger,0); // Pour remmettre la piste sur A à chaque fois si une autre est sélectionnée
							if (~seqCompGABIndex[(~tracksValue/2).asInteger] == 1, { ~aController.setState(6,(~tracksValue/2).asInteger,1); }, { ~aController.setState(6,(~tracksValue/2).asInteger,0); });
							~aController.setState(4,~prevAkaiTrack,0); ~aController.setState(4,(~tracksValue/2).asInteger,1);
							~aController.setState(5,~prevAkaiTrack,0); ~aController.setState(5,(~tracksValue/2).asInteger,1);
							// ~aController.setState(7,~prevAkaiTrack,0); ~aController.setState(7,(~tracksValue/2).asInteger,1);

							if (~playViewValue[((~tracksValue/2).asInteger*2)+~seqCompGABIndex[(~tracksValue/2).asInteger]] == 1 , {
								if (~aController.padInternalState[2,(~tracksValue/2).asInteger] == 0 or: { ~aController.padInternalState[2,(~tracksValue/2).asInteger] == 2}, {
									~aController.setState(2,(~tracksValue/2).asInteger,1); ~aController.setState(3,(~tracksValue/2).asInteger,1); ~aController.incrementState(2,(~tracksValue/2).asInteger); ~aController.incrementState(3,(~tracksValue/2).asInteger);
								});
							},{
								if (~aController.padInternalState[2,(~tracksValue/2).asInteger] == 1 or: { ~aController.padInternalState[2,(~tracksValue/2).asInteger] == 2}, {
									~aController.setState(2,(~tracksValue/2).asInteger,0); ~aController.setState(3,(~tracksValue/2).asInteger,0);
								});
							});
							// 8.do { |b| ~aController.setState(6,b,0); };
							// ~aController.setState(6,(~tracksValue/2).asInteger,1);
						}.defer;
					},{
						{ if (~seqABVisibleAllViewG.value == 0, {
							~seqABVisibleAllViewG.valueAction_(1);
							8.do { |i| ~aController.setState(6,i,1) };  ~tracksView.valueAction_(((~tracksValue/2).asInteger * 2)+1);
						}, {
							~seqABVisibleAllViewG.valueAction_(0);
							8.do { |i| ~aController.setState(6,i,0) }; ~tracksView.valueAction_((~tracksValue/2).asInteger * 2);
						});
						}.defer;
					});
				});


				// Ligne Verticale - 8ème bouton -> SPL remplacé par Config par défaut avec Préparation des pistes rythmiques
				~aController.setButtonMode(\ver,7,\hold); // (type, num, mode) // Mode
				~aController.setButtonFunction(\ver,7,1, {

					// {(~rhythmTracksX2++0).do { |i|  ~tracksView.valueAction_(i) }}.defer(0.2);  // Préparation des pistes rythmiques

					{~tracksView.valueAction_(0)}.defer;

					/*if (~twister.notNil, {
						~twister.knobs[8..15].do { |i, id|
							if (id > 2, {i.ledColor_(Color.magenta)}, {i.ledColor_(Color.green)});
						};
						~twister.knobs[8+(~tracksValue/2).asInteger].ledColor_(Color.red);
					});*/

					// ~seqCompGABIndex // à placer
					/*{ if (~seqPlayingVisibleAllViewG[0].value == 0, {
					~seqPlayingVisibleAllViewG[0].valueAction_(1);
					~tracks.do { |tr| if ( ~playViewValue[tr] == 0, { ~seqABVisibleViewG[tr].value_(tr.wrap(0, 1)).doAction } ) };
					8.do { |i| ~aController.setState(6,i,~seqCompGABIndex[i]/*~seqABVisibleViewG[(i*2).asInteger].value*/) };
					if (Pdef(~patterns2[~tracksValue]).isPlaying == true, { ~tracksView.valueAction_((~tracksValue/2).asInteger * 2) });
					}, {
					~seqPlayingVisibleAllViewG[0].valueAction_(0);
					~tracks.do { |tr| if ( ~playViewValue[tr] == 1, {  ~seqABVisibleViewG[tr].value_(tr.wrap(0, 1)).doAction } ) };
					8.do { |i| ~aController.setState(6,i,~seqCompGABIndex[i]/*~seqABVisibleViewG[(i*2).asInteger].value*//*~lastABPlaying[i]*/) };
					if (Pdef(~patterns2[~tracksValue]).isPlaying == true, { ~tracksView.valueAction_(((~tracksValue/2).asInteger * 2)+1) });
					// ~seqABVisibleViewG[0].value
					});
					/*2.do { |a|
					if (a.even,
					{ ~seqPlayingVisibleAllViewG[a+1].value_(~seqPlayingVisibleAllViewG[a].value) },
					{ ~seqPlayingVisibleAllViewG[a-1].value_(~seqPlayingVisibleAllViewG[a].value) }
					);
					};*/

					8.do { |i|
					if (~playViewValue[(i*2)+~seqCompGABIndex[i]] == 1 , {
					if (~aController.padInternalState[2,i] == 0, {
					~aController.setState(2,i,1); ~aController.setState(3,i,1); ~aController.incrementState(2,i); ~aController.incrementState(3,i);
					});
					},{
					if (~aController.padInternalState[2,i] == 1 or: { ~aController.padInternalState[2,i] == 2}, {
					~aController.setState(2,i,0); ~aController.setState(3,i,0);
					});
					});
					};

					}.defer;*/

					/*{
					if (~controlBusSynth5FadeTime == 8, {~controlBusSynth5FadeTimeView.valueAction_(0)}, {~controlBusSynth5FadeTimeView.valueAction_(8)} );
					}.defer;*/

					// });
				});


				"Akai-APCmini connected".postln;

			},{

				/*"Akai-APCmini Not connected".postln;*/ if ( ~aControllerConnected != 1 /* ~aController.isNil*/, { ~aControllerConnected = 0; } );

			});

		};

	);

}.fork /*value*/;





/*
MIDIClient.sources.do{|d| d.device.split($-)[0].postln };
MIDIClient.sources.do{|d| d.device.postln };
MIDIClient.sources.do{|d| d.uid.postln };
*/



/*

// create a new instance...
a=APCmini.new;
// a.redrawInternalState;
a.playAnimation

// PADS

// HOLD Mode
// pad counting starts from left top (row, column)
a.setPadMode(0,0,\hold); // Mode
a.setPadHoldColor(0,0,\red); // and change the hold color
a.setPadHoldColor(0,0,\blinkGreen)

// we can check that the internal state is 1 while pressing
a.padInternalState

// SWITCH Mode
// in switch mode, by default there are 4 states: black, green, red and orange
a.setPadMode(0,0,\switch); // Mode
a.setNumStates(0,0,3); // (row, column, nb of states)
a.setColorsOfStates(0,0,[0,\black,1,\orange,2,\red]) // (row, column, array) // NE MARCHE PAS ???
a.setColorsOfStates(0,0,[0,\orange,1,\red,2,\red])
a.setColorsOfStatesAll([0,\black,1,\green,2,\red])

// also change the state->color association
([\black, \green, \blinkGreen, \red, \blinkRed, \orange, \blinkOrange]); // 0 Black / 1 Green / 3 Red / 5 Orange
colors = Dictionary.newFrom([\black,black, \green,green, \blinkGreen, blinkGreen, \red,red, \blinkRed,blinkRed, \orange,orange, \blinkOrange,blinkOrange]);
var <black = 0;
var <green = 1;
var <blinkGreen = 2;
var <red = 3;
var <blinkRed = 4;
var <orange = 5;
var <blinkOrange = 6;
defaultColorsOfStates = Dictionary.newFrom([0,black, 1,green, 2,red, 3,orange]);

// MIDI Out
MIDIOut.new(portNumber);
b = MIDIOut.new(1); b.latency_(0.001);
// MIDIOut.connect(1,1 /* portNumber */ ); // Linux only. OS X does not need to connect. On Linux it is an optional feature
b.noteOn(0,56,1);

// Changement de l'état de valeurs des Pads
a.incrementState(6,0);
a.setState(6,0,3);

// and retrieve that information
a.padSwitchNumStates
a.padColorsOfStates.cs

// of course, we can assign functions to states, which will be evaluated when current state changes
a.setPadFunction(0,0,0,{"bye".postln});
a.setPadFunction(0,0,1,{"hi".postln});
// they work the same in the two modes...

// Buttons
a.setButtonMode(\hor,0,\hold) // (type, num, mode) // Mode
a.horInternalState //  check  the internal state
a.verInternalState

// the slider function will have access to the slider index and value info
a.setSliderFunction(0, { |i,v| [\slider,i,\value,v].postln } );

// slider mode: press Shift pad or execute following, and enjoy!
a.sliderMode_(true) // pad actions won't have effect

*/



