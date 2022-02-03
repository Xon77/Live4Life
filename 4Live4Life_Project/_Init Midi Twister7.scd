{

	MIDIClient.sources.do { |i, id| /*i.device.postln;*/
		if (i.device == "Midi Fighter Twister 1", {~twisterIndex1 = id});
		if (i.device == "Midi Fighter Twister 2", {~twisterIndex2 = id});
		if (i.device == "Midi Fighter Twister 3", {~twisterIndex3 = id});
	};


	~bufFolColor = Color.red(0.9);
	~bufColor = Color.new255(/*255*/240, 75/*10*/, 110/*120*/);
	~offColor = Color.new255(148, 0, 211);
	~legColor = Color.blue;
	~rtmColor = Color.yellow(0.6);
	~proColor = Color.new255(139, 90, 0);
	~cenColor = Color.cyan(0.6)/*new255(0, 206, 209)*/ /*new255(34, 39, 34)*//*Color.green*/;
	~strColor = Color.green(0.6); // dark sea green


	if (~twisterIndex1.notNil, {

		if (~twisterIndex2.isNil, {
			~twister2 = Twister(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); // Création d'une deuxième instance // this one is now connected, because Twister objects are connected when they are constructed
			~twister3 = Twister(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1]));
			~twister4 = Twister(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1]));
			~twister5 = Twister(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1]));
		},{
			if (~twisterIndex3.isNil, {
				~twister3 = Twister(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2]));
				~twister4 = Twister(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2]));
				~twister5 = Twister(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2]));
				~twister2 = Twister(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2]));
			},{
				~twister2 = Twister(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2]));
				~twister4 = Twister(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3]));
				~twister5 = Twister(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3]));
				~twister3 = Twister(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3]));
			});
		});

		/*
		~twister.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); // Connexion avec la première instance
		~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1]));
		*/
		~twister = Twister(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); // Init XXXXXXXXX

		1.wait;


		// ~twister = Twister(\default);
		// ~twister = nil;

		/*~ratMulUpdate = { |slider, tr|
		var tra, val, seq;  tra= (tr*2)+~seqCompGABIndex[tr];
		if (tra == ~tracksValue and: {~curSeqTrig == 1}, { seq = ~seqsValue },{ seq = ~seqSeq[tra] }); val = ~ratMulSpec.map(slider.value);
		if (~twister.notNil, { var a=(tr/2).asInteger; ~ratValues[a].value_(~ratMulSpec.unmap(~ratMul[tr][seq])) }); "test".postln;
		~ratMul[tra][seq] = val; ~rat2Mul[tra][seq] = val;
		{slider.string = "Rat : %".format( val )}.defer;

		/*if (~lemurConnected1 == 1, {
		if (tr == ~tracksValue, {
		~lemurAdress1.sendMsg("/ParC/RatM/value", val); ~lemurAdress1.sendMsg("/ParC/RatLed/value", view.value );
		});
		if (~rhythmTracksX2.includes(tr), {
		~lemurAdress1.sendMsg(~lemurRatGTextValues[tr], val); ~lemurAdress1.sendMsg(~lemurRatGLedValues[tr], view.value );
		});
		});
		if (~lemurConnected2 == 1, {
		if (tr == ~secondLemurX2Track, {
		~lemurAdress2.sendMsg("/ParC/RatM/value", val); ~lemurAdress2.sendMsg("/ParC/RatLed/value", view.value );
		});
		if (~rhythmTracksX2.includes(tr), {
		~lemurAdress2.sendMsg(~lemurRatGTextValues[tr], val); ~lemurAdress2.sendMsg(~lemurRatGLedValues[tr], view.value );
		});
		});*/

		};*/





		(
			if (~seqCompGABIndex.isNil, {~seqCompGABIndex = 0 ! 8 /*~nbOfTracks*/}); // initialisé aussi après dans Init GUI
			if (~triggerAllSeqs.isNil, {~triggerAllSeqs = 0 ! 16 /*~nbOfTracksX2*/}); // initialisé aussi après dans Init GUI


			// Initialisation
			~ratValues = /*~nbOfTracksX2*/ 16.collect { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/ NumericControlValue(spec:[0, 1]) /*.value_(~ratMulSpec.unmap(~ratMul[a][~seqSeq[a]]))*/ };
			~ratButtons = /*~nbOfTracksX2*/ 8.collect { |i| OnOffControlValue(); };


			// Couleur
			~twister.knobs[8..10].do { |i, id| i.ledColor_(Color.green); }; // Distinction entre les pistes rythmiques & Texture
			~twister.knobs[11..15].do { |i, id| i.ledColor_(Color.magenta); };


			// Attribution
			~twister.knobs[8..15].do { |i, id|
				i.buttonCV = ~ratButtons[id]; // pour la sélection des séquences
				i.knobCV = ~ratValues[(id*2)+~seqCompGABIndex[id]]; // pour les vitesses de lecture
			};


			// Pour l'action en conséquence sur une seule séquence ou sur toute la sélection quand on appuie sur le bouton en fonction de ce qui est déjà en sélection
			/*~ratButtons[0..5].do { |i, id| i.signal(\on).connectToUnique({ {/*~retriggerPresetViewG*/~retriggerPresetPreViewG[id].valueAction_(1)}.defer; }) }; // mis sur le Preset - à voir si pas mieux sur la sélection ??? ~retriggerPresetViewG
			~ratButtons[0..5].do { |i, id| i.signal(\off).connectToUnique({ {/*~retriggerPresetViewG*/~retriggerPresetPreViewG[id].valueAction_(1)}.defer; }) };
			~ratButtons[6..15].do { |i, id| i.signal(\on).connectToUnique({ var a = id+6; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0},{~triggerAllSeqs[a] = 1}) }) };
			~ratButtons[6..15].do { |i, id| i.signal(\off).connectToUnique({ var a = id+6; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1},{~triggerAllSeqs[a] = 0}) }) };*/
			~ratButtons[0..7/*2*/].do { |i, id| i.signal(\on).connectToUnique({ {~retriggerPresetViewG/*~retriggerPresetPreViewG*/[(id*2)+~seqCompGABIndex[id]].valueAction_(1)}.defer; }) }; // mis sur le Preset - à voir si pas mieux sur la sélection ??? ~retriggerPresetViewG
			~ratButtons[0..7/*2*/].do { |i, id| i.signal(\off).connectToUnique({ {~retriggerPresetViewG/*~retriggerPresetPreViewG*/[(id*2)+~seqCompGABIndex[id]].valueAction_(1)}.defer; }) };

			// Pour la sélection - retiré pour la remise à 0 du preset
			/*~ratButtons[3..7].do { |i, id| i.signal(\on).connectToUnique({ var a = ((id+3)*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
			~ratButtons[3..7].do { |i, id| i.signal(\off).connectToUnique({ var a = ((id+3)*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };*/


			// ~fxVolume
			~fxValue = NumericControlValue(spec:[0.025, 0.7]);
			~twister.knobs[0].ledColor_(Color.red);
			~twister.knobs[0].knobCV = ~fxValue;
			~fxButton= OnOffControlValue();
			~twister.knobs[0].buttonCV = ~fxButton;
			~fxButton.signal(\on).connectToUnique({ if (~trackFXVolView.value == 0.06, {~fxValue.value_(0.12)}, {~fxValue.value_(0.06)} ); });


			// Connexion
			~connectionsRateMake = {

				if (~connectionsRate.notNil, { ~connectionsRate.free });

				~twister.knobs[8..15].do { |i, id|
					i.buttonCV = ~ratButtons[id]; // pour la sélection des séquences
					i.knobCV = ~ratValues[(id*2)+~seqCompGABIndex[id]]; // pour les vitesses de lecture
				};
				~twister.knobs[1].knobCV = ~rtmValues[~tracksValue];
				~twister.knobs[2].knobCV = ~proValues[~tracksValue];
				~twister.knobs[3].knobCV = ~cenValues[~tracksValue];
				~twister.knobs[5].knobCV = ~bufFolValues[~tracksValue];
				~twister.knobs[6].knobCV = ~legValues[~tracksValue];
				~twister.knobs[7].knobCV = ~strValues[~tracksValue];

				~nbOfTracksX2.do { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/
					~ratValues[i].value_(~ratMulSpec.unmap(~ratMul[i][~seqSeq[i]]));
				};

				// ~rtmValues[~tracksValue].value_(~rtmMulSpec[~tracksValue][~seqSeq[~tracksValue]].unmap(~rtmMul[~tracksValue][~seqSeq[~tracksValue]])); // Test

				~connectionsRate = ConnectionList.make {
					// ~ratValues.connectEach(\value, ~ratMulViewG, _.valueSlot);
					~ratValues.connectEach(\value, ~ratMulViewG, _.valueSlot(\valueAction));
					~ratMulViewG.connectEach(\value, ~ratValues, _.valueSlot);

					// ~ratValues.connectEach(\value, ~ratMulViewG, _.methodSlot("string_(value.round(0.01))"));
					// ~ratValues.connectEach(\value, ~ratMulViewG, _.methodSlot("doAction")); // necessary to update action from SmoothSliders
					// pour la séquence, comment faire ???
					// ~ratMulView.connectEach(\value, ~ratValues[\tracksValue.envirGet], _.valueSlot);
					// ~ratValues[\tracksValue.envirGet].connectEach(\value, ~ratMulView, _.valueSlot);
					// ~ratValues[\tracksValue.envirGet].connectEach(\value, ~ratMulView, _.methodSlot("doAction"));

					// ~ratValues.connectEach(\value, ~ratMulViewG, _.methodSlot("doAction")); // necessary to update action from SmoothSliders

					~ratMulViewG.do({ |slider, id|  // var a= (id*2)+~seqCompGABIndex[id];
						ViewActionUpdater.enable(slider);
					}); // necessary to update from SmoothSliders the values and so the Twister knobs

					// ~ratValues.connectAll({ |val, i, a| val.postln; a.postln; i.postln });
					/*~ratValues[\tracksValue.envirGet].signal(\value).connectToUnique({
					~ratMulView.value_(~ratValues[id].value.copy/*~ratMulSpec.unmap(~ratMul[tr][seq])*/).string_("%".format(~ratMul[~tracksValue][~seqSeq[~tracksValue]].round(0.01)));
					});*/

					[~ratValues[~tracksValue]].connectEach(\value, [~ratMulView], _.valueSlot); // Pour mettre à jour sliders à partir du Twister
					// [~ratValues[~tracksValue]].connectEach(\value, [~ratMulView], _.methodSlot("string_(value.round(0.01))"));
					[~ratValues[~tracksValue]].connectEach(\value, [~ratMulView], _.methodSlot("string_(~ratMulSpec.map(value))"));
					[~ratMulView].connectEach(\value, [~ratValues[~tracksValue]], _.valueSlot); // Pour mettre à jour le Twister à partir des Sliders
					ViewActionUpdater.enable(~ratMulView); // idem - necessary to update from SmoothSliders the values and so the Twister knobs


					[~rtmValues[~tracksValue]].connectEach(\value, [~rtmMulViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~rtmMulViewG[~tracksValue]].connectEach(\value, [~rtmValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~rtmMulViewG[~tracksValue]);
					[~rtmValues[~tracksValue]].connectEach(\value, [~rtmMulView], _.valueSlot);
					[~rtmValues[~tracksValue]].connectEach(\value, [~rtmMulView], _.methodSlot("string_(~rtmMulSpec[~tracksValue][~seqsValue].map(value))"));
					[~rtmMulView].connectEach(\value, [~rtmValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~rtmMulView);

					[~legValues[~tracksValue]].connectEach(\value, [~legMulViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~legMulViewG[~tracksValue]].connectEach(\value, [~legValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~legMulViewG[~tracksValue]);
					[~legValues[~tracksValue]].connectEach(\value, [~legMulView], _.valueSlot);
					[~legValues[~tracksValue]].connectEach(\value, [~legMulView], _.methodSlot("string_(~legMulSpec.map(value))"));
					[~legMulView].connectEach(\value, [~legValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~legMulView);

					[~strValues[~tracksValue]].connectEach(\value, [~strMulViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~strMulViewG[~tracksValue]].connectEach(\value, [~strValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~strMulViewG[~tracksValue]);
					[~strValues[~tracksValue]].connectEach(\value, [~strMulView], _.valueSlot);
					[~strValues[~tracksValue]].connectEach(\value, [~strMulView], _.methodSlot("string_(~strMulSpec.map(value))"));
					[~strMulView].connectEach(\value, [~strValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~strMulView);

					[~cenValues[~tracksValue]].connectEach(\value, [~cenMulViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~cenMulViewG[~tracksValue]].connectEach(\value, [~cenValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~cenMulViewG[~tracksValue]);
					[~cenValues[~tracksValue]].connectEach(\value, [~cenMulView], _.valueSlot);
					[~cenValues[~tracksValue]].connectEach(\value, [~cenMulView], _.methodSlot("string_(~cenMulSpec.map(value))"));
					[~cenMulView].connectEach(\value, [~cenValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~cenMulView);

					[~proValues[~tracksValue]].connectEach(\value, [~proMulViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~proMulViewG[~tracksValue]].connectEach(\value, [~proValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~proMulViewG[~tracksValue]);
					[~proValues[~tracksValue]].connectEach(\value, [~proMulView], _.valueSlot);
					[~proValues[~tracksValue]].connectEach(\value, [~proMulView], _.methodSlot("string_(~proMulSpec.map(value))"));
					[~proMulView].connectEach(\value, [~proValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~proMulView);

					[~bufFolValues[~tracksValue]].connectEach(\value,[~bufFolderViewG[~tracksValue]], _.valueSlot(\valueAction));
					[~bufFolderViewG[~tracksValue]].connectEach(\value, [~bufFolValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~bufFolderViewG[~tracksValue]);
					[~bufFolValues[~tracksValue]].connectEach(\value, [~bufFolderView], _.valueSlot);
					// [~bufFolValues[~tracksValue]].connectEach(\value, [~bufFolderView], _.methodSlot("string_(~bufMulSpec.map(value))"));
					[~bufFolderView].connectEach(\value, [~bufFolValues[~tracksValue]], _.valueSlot);
					ViewActionUpdater.enable(~bufFolderView);

					[~fxValue].connectEach(\value, [~trackFXVolView], _.valueSlot(\valueAction));
					[~trackFXVolView].connectEach(\value, [~fxValue], _.valueSlot);

				};
			};
		);

		/*
		Twister(\twister).free; // est déconnecté si on le réinitialise

		~ratValues[0].value
		~ratValues[0].value = 0.2

		~connectionsRateMake.();
		*/





		// Midi Twister
		// FX (red) / RTM (orange, yellow) / LEG (blue, cyan ->) / STR
		// RTM RY (magenta) / PRO  (blue, cyan ->) / OFF (blue, cyan ->) / CEN
		// Il faudrait aussi DEL, voire OUT ???

		~rtmValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister.knobs[1].ledColor_(Color.yellow);
		~twister.knobs[1].knobCV = ~rtmValues[0]; // ~rtmValues[0].value

		~proValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister.knobs[2].ledColor_(Color.blue);
		~twister.knobs[2].knobCV = ~proValues[0];

		~cenValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister.knobs[3].ledColor_(Color.blue);
		~twister.knobs[3].knobCV = ~cenValues[0];

		// if (~rtmMulRyInit.isNil, { ~rtmMulRyInit = 1 ! (~rhythmTracks*2).size }); // à initialiser au départ -> plus necessaire car intervention directe dans le pattern et non dans la GUI
		~rtmRyValue = NumericControlValue(spec:[0.1, 1]);
		~rtmRyValue.value = 1;
		~twister.knobs[4].ledColor_(Color.magenta);
		~twister.knobs[4].knobCV = ~rtmRyValue;
		/*~rtmRyValue.signal(\value).connectToUnique({ // ~rtmRyValue.value.postln;
		~rhythmTracksX2.do { |i, id| { var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][/*~seqsValue*/~seqSeq[i]].unmap(~rtmMulRyInit[id] * ~rtmRyValue.value /*0.75*/) ); ~triggerAllSeqs[i] = prev }.defer; };
		});*/

		~rtmMulRyInitButton = OnOffControlValue();
		~twister.knobs[4].buttonCV = ~rtmMulRyInitButton;
		~rtmMulRyInitButton.signal(\on).connectToUnique({ if (~rtmRyValue.value != 1, {~rtmRyValue.value_(1)},{~rtmRyValue.value_(0)}) });
		// ~rtmMulRyInitButton.signal(\on).connectToUnique({ if (~rtmRyValue.value != 1, {~rtmRyValue.value_(1)},{~rtmRyValue.value_(0)}) });
		/*
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 0.15) ); ~triggerAllSeqs[i] = 0; }; // 0.112 mini
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 0.2) ); ~triggerAllSeqs[i] = 0; }; // 0.15 mini
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 0.2) ); ~triggerAllSeqs[i] = 0; }; // 0.15 mini
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 0.5) ); ~triggerAllSeqs[i] = 0; };
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 0.75) ); ~triggerAllSeqs[i] = 0; };
		~rhythmTracksX2.do { |i, id| var prev = ~triggerAllSeqs[i]; ~triggerAllSeqs[i] = 1; ~rtmMulViewG[i].valueAction_( ~rtmMulSpec[i][~seqsValue].unmap(~rtmMulRyInit[id] * 1) ); ~triggerAllSeqs[i] = 0; }; // 0.75 default
		*/

		/* ~offValue */ ~bufFolValues = 16.collect { NumericControlValue(spec:[0, 70 /*~bufFolderSize1*/]) };
		~twister.knobs[5].ledColor_(Color.blue/*magenta(0.2)*/);
		~twister.knobs[5].knobCV = ~bufFolValues[0/*~tracksValue*/];

		~twisterButRy = OnOffControlValue(); // Resynchronisation
		~twister.knobs[5].buttonCV = ~twisterButRy;
		~twisterButRy.signal(\on).connectToUnique({
			~rhythmTracksX2.do { |tr|
				if (~playViewValue[tr].value == 1, {
					if (~xqViewValue[tr] == 0, {
						~play.value(npdef: ~patterns2[tr], track: ~tracks[tr], nfade: ~nFade[tr], pfade: ~pFade[tr], quant: ~quant[tr], stretchdur: 1/1)
					}, {
						~play.value(npdef: ~patterns2[tr], track: ~tracks[tr], nfade: ~nFade[tr], pfade: 0, quant: 0, stretchdur: 1/1)
					});
				})
			}; "Resynchro".postln;
		});

		~legValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister.knobs[6].ledColor_(Color.blue);
		~twister.knobs[6].knobCV = ~legValues[0];

		~strValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister.knobs[7].ledColor_(Color.blue);
		~twister.knobs[7].knobCV = ~strValues[0];





		~twisterBut1 = OnOffControlValue();
		~twister.buttons[0].cv = ~twisterBut1;
		~twisterBut1.signal(\on).connectToUnique({ ~retriggerPresetAllTracksView.valueAction_(1); }); // Pre
		~twisterBut1.signal(\off).connectToUnique({ ~retriggerPresetAllTracksView.valueAction_(1) });

		~twisterBut2 = OnOffControlValue();
		~twister.buttons[1].cv = ~twisterBut2;
		~twisterBut2.signal(\on).connectToUnique({ ~retriggerSelAllTracksView.valueAction_(1) }); // Sel Pl
		~twisterBut2.signal(\off).connectToUnique({ ~retriggerSelAllTracksView.valueAction_(1) });

		~twisterBut3 = OnOffControlValue();
		~twister.buttons[2].cv = ~twisterBut3;
		~twisterBut3.signal(\on).connectToUnique({ ~retriggerPresetViewRy.valueAction_(1) }); // Sel Ry
		~twisterBut3.signal(\off).connectToUnique({ ~retriggerPresetViewRy.valueAction_(1) });





		// Initialisation Twister 2

		// ~bufValues = /*~nbOfTracksX2*/ 16.collect { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/ NumericControlValue(spec:[0, 1]) /*.value_(~ratMulSpec.unmap(~ratMul[a][~seqSeq[a]]))*/ };
		~bufValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		~twister2Buttons = /*~nbOfTracksX2*/ 16.collect { |i| OnOffControlValue(); };


		// Couleur
		~twister2.knobs[0..7].do { |i, id| i.ledColor_(~bufFolColor); };
		~twister2.knobs[8..15].do { |i, id| i.ledColor_(~bufColor)}; // Violet Red


		// Attribution
		~twister2.knobs[0..7].do { |i, id|
			i.buttonCV = ~twister2Buttons[id];
			i.knobCV = ~bufFolValues[(id*2)+~seqCompGABIndex[id]];
		};
		~twister2.knobs[8..15].do { |i, id|
			i.buttonCV =  ~twister2Buttons[id+8];
			i.knobCV =  ~bufValues[(id*2)+~seqCompGABIndex[id]];
		};

		~twister2Buttons[0..7].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister2Buttons[0..7].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };
		~twister2Buttons[8..15].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister2Buttons[8..15].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };


		~connectionsBufMake = {

			if (~connectionsBuf.notNil, { ~connectionsBuf.free });

			~twister2.knobs[0..7].do { |i, id|
				i.buttonCV = ~twister2Buttons[id];
				i.knobCV = ~bufFolValues[(id*2)+~seqCompGABIndex[id]];
			};
			~twister2.knobs[8..15].do { |i, id|
				i.buttonCV =  ~twister2Buttons[id+8];
				i.knobCV =  ~bufValues[(id*2)+~seqCompGABIndex[id]];
			};

			~nbOfTracksX2.do { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/
				~bufFolValues[i].value_(~bufFolderValue[i][~seqSeq[i]]);
				~bufValues[i].value_(~bufMulSpec.unmap(~bufMul[i][~seqSeq[i]]))
			};

			~connectionsBuf = ConnectionList.make {
				~bufFolValues.connectEach(\value,~bufFolderViewG, _.valueSlot(\valueAction));
				~bufFolderViewG.connectEach(\value, ~bufFolValues, _.valueSlot);
				~bufFolderViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~bufFolValues[~tracksValue]].connectEach(\value, [~bufFolderView], _.valueSlot);
				[~bufFolderView].connectEach(\value, [~bufFolValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~bufFolderView);

				~bufValues.connectEach(\value,~bufMulViewG, _.valueSlot(\valueAction));
				~bufMulViewG.connectEach(\value, ~bufValues, _.valueSlot);
				~bufMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~bufValues[~tracksValue]].connectEach(\value, [~bufMulView], _.valueSlot);
				[~bufMulView].connectEach(\value, [~bufValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~bufMulView);
			};
		};
		// ~connectionsBufMake.();





		// Initialisation Twister 3

		// ~bufValues = /*~nbOfTracksX2*/ 16.collect { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/ NumericControlValue(spec:[0, 1]) /*.value_(~ratMulSpec.unmap(~ratMul[a][~seqSeq[a]]))*/ };
		~offValues = 16.collect { NumericControlValue(spec:[0, 1]) };
		// ~legValues = 16.collect { NumericControlValue(spec:[0, 1]) }; // déjà initialisé plus haut
		~twister3Buttons = /*~nbOfTracksX2*/ 16.collect { |i| OnOffControlValue(); };


		// Couleur
		~twister3.knobs[0..7].do { |i, id| i.ledColor_(~offColor); };  // Violet Red
		~twister3.knobs[8..15].do { |i, id| i.ledColor_(~legColor)};


		// Attribution
		~twister3.knobs[0..7].do { |i, id|
			i.buttonCV = ~twister3Buttons[id];
			i.knobCV = ~offValues[(id*2)+~seqCompGABIndex[id]];
		};
		~twister3.knobs[8..15].do { |i, id|
			i.buttonCV =  ~twister3Buttons[id+8];
			i.knobCV =  ~legValues[(id*2)+~seqCompGABIndex[id]];
		};

		~twister3Buttons[0..7].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister3Buttons[0..7].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };
		~twister3Buttons[8..15].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister3Buttons[8..15].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };


		~connectionsLegMake = {

			if (~connectionsLeg.notNil, { ~connectionsLeg.free });

			~twister3.knobs[0..7].do { |i, id|
				i.buttonCV = ~twister3Buttons[id];
				i.knobCV = ~offValues[(id*2)+~seqCompGABIndex[id]];
			};
			~twister3.knobs[8..15].do { |i, id|
				i.buttonCV =  ~twister3Buttons[id+8];
				i.knobCV =  ~legValues[(id*2)+~seqCompGABIndex[id]];
			};

			~nbOfTracksX2.do { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/
				~legValues[i].value_(~legMulSpec.unmap(~legMul[i][~seqSeq[i]]));
				~offValues[i].value_(~offMulSpec.unmap(~offMul[i][~seqSeq[i]]))
			};

			~connectionsLeg = ConnectionList.make {
				~legValues.connectEach(\value,~legMulViewG, _.valueSlot(\valueAction));
				~legMulViewG.connectEach(\value, ~legValues, _.valueSlot);
				~legMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~legValues[~tracksValue]].connectEach(\value, [~legMulView], _.valueSlot);
				[~legMulView].connectEach(\value, [~legValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~legMulView);

				~offValues.connectEach(\value,~offMulViewG, _.valueSlot(\valueAction));
				~offMulViewG.connectEach(\value, ~offValues, _.valueSlot);
				~offMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~offValues[~tracksValue]].connectEach(\value, [~offMulView], _.valueSlot);
				[~offMulView].connectEach(\value, [~offValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~offMulView);
			};

		};
		// ~connectionsLegMake.();





		// Initialisation Twister 4

		~twister4Buttons = /*~nbOfTracksX2*/ 16.collect { |i| OnOffControlValue(); };


		// Couleur
		~twister4.knobs[0..7].do { |i, id| i.ledColor_(~proColor); /*(Color.new255(255, 165, 0)*/ }; // Orange4
		~twister4.knobs[8..15].do { |i, id| i.ledColor_(~rtmColor)};


		// Attribution
		~twister4.knobs[0..7].do { |i, id|
			i.buttonCV = ~twister4Buttons[id];
			i.knobCV =  ~proValues[(id*2)+~seqCompGABIndex[id]];
		};
		~twister4.knobs[8..15].do { |i, id|
			i.buttonCV =  ~twister4Buttons[id+8];
			i.knobCV =  ~rtmValues[(id*2)+~seqCompGABIndex[id]];
		};

		~twister4Buttons[0..7].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister4Buttons[0..7].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };
		~twister4Buttons[8..15].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister4Buttons[8..15].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };


		~connectionsRtmMake = {

			if (~connectionsRtm.notNil, { ~connectionsRtm.free });

			~twister4.knobs[0..7].do { |i, id|
				i.buttonCV = ~twister4Buttons[id];
				i.knobCV =  ~proValues[(id*2)+~seqCompGABIndex[id]];
			};
			~twister4.knobs[8..15].do { |i, id|
				i.buttonCV =  ~twister4Buttons[id+8];
				i.knobCV = ~rtmValues[(id*2)+~seqCompGABIndex[id]];
			};

			~nbOfTracksX2.do { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/
				~proValues[i].value_(~proMulSpec.unmap(~proMul[i][~seqSeq[i]]));
				~rtmValues[i].value_(~rtmMulSpec[i][~seqSeq[i]].unmap(~rtmMul[i][~seqSeq[i]]));
			};

			~connectionsRtm = ConnectionList.make {
				~rtmValues.connectEach(\value,~rtmMulViewG, _.valueSlot(\valueAction));
				~rtmMulViewG.connectEach(\value, ~rtmValues, _.valueSlot);
				~rtmMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~rtmValues[~tracksValue]].connectEach(\value, [~rtmMulView], _.valueSlot);
				[~rtmMulView].connectEach(\value, [~rtmValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~rtmMulView);

				~proValues.connectEach(\value,~proMulViewG, _.valueSlot(\valueAction));
				~proMulViewG.connectEach(\value, ~proValues, _.valueSlot);
				~proMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~proValues[~tracksValue]].connectEach(\value, [~proMulView], _.valueSlot);
				[~proMulView].connectEach(\value, [~proValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~proMulView);
			};
		};
		// ~connectionsRtmMake.();





		// Initialisation Twister 5

		~twister5Buttons = /*~nbOfTracksX2*/ 16.collect { |i| OnOffControlValue(); };


		// Couleur
		~twister5.knobs[0..7].do { |i, id| i.ledColor_(~cenColor); };
		~twister5.knobs[8..15].do { |i, id| i.ledColor_(~strColor)/*(Color.new255(255, 165, 0)*/}; // Orange4


		// Attribution
		~twister5.knobs[0..7].do { |i, id|
			i.buttonCV = ~twister5Buttons[id];
			i.knobCV = ~cenValues[(id*2)+~seqCompGABIndex[id]];
		};
		~twister5.knobs[8..15].do { |i, id|
			i.buttonCV =  ~twister5Buttons[id+8];
			i.knobCV =  ~strValues[(id*2)+~seqCompGABIndex[id]];
		};

		~twister5Buttons[0..7].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister5Buttons[0..7].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };
		~twister5Buttons[8..15].do { |i, id| i.signal(\on).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 1, {~triggerAllSeqs[a] = 0;},{~triggerAllSeqs[a] = 1;}) }) };
		~twister5Buttons[8..15].do { |i, id| i.signal(\off).connectToUnique({ var a = (id*2)+~seqCompGABIndex[id]; if (~triggerAllSeqs[a] == 0, {~triggerAllSeqs[a] = 1;},{~triggerAllSeqs[a] = 0;}) }) };


		~connectionsStrMake = {

			if (~connectionsStr.notNil, { ~connectionsStr.free });

			~twister5.knobs[0..7].do { |i, id|
				i.buttonCV = ~twister5Buttons[id];
				i.knobCV = ~cenValues[(id*2)+~seqCompGABIndex[id]];
			};
			~twister5.knobs[8..15].do { |i, id|
				i.buttonCV =  ~twister5Buttons[id+8];
				i.knobCV = ~strValues[(id*2)+~seqCompGABIndex[id]];
			};

			~nbOfTracksX2.do { |i| /*var a= (i*2)+~seqCompGABIndex[i];*/
				~strValues[i].value_(~strMulSpec.unmap(~strMul[i][~seqSeq[i]]));
				~cenValues[i].value_(~cenMulSpec.unmap(~cenMul[i][~seqSeq[i]]));
			};

			~connectionsStr = ConnectionList.make {
				~strValues.connectEach(\value,~strMulViewG, _.valueSlot(\valueAction));
				~strMulViewG.connectEach(\value, ~strValues, _.valueSlot);
				~strMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~strValues[~tracksValue]].connectEach(\value, [~strMulView], _.valueSlot);
				[~strMulView].connectEach(\value, [~strValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~strMulView);

				~cenValues.connectEach(\value,~cenMulViewG, _.valueSlot(\valueAction));
				~cenMulViewG.connectEach(\value, ~cenValues, _.valueSlot);
				~cenMulViewG.do({ |slider, id| ViewActionUpdater.enable(slider) });
				[~cenValues[~tracksValue]].connectEach(\value, [~cenMulView], _.valueSlot);
				[~cenMulView].connectEach(\value, [~cenValues[~tracksValue]], _.valueSlot);
				ViewActionUpdater.enable(~cenMulView);
			};
		};
		// ~connectionsStrMake.();





		// Boutons sur le côté droit pour changer d'interface

		~twisterInterface = 0;
		~twisterInterface2 = 1;

		~twisterBut4 = OnOffControlValue();
		~twister.buttons[3].cv = ~twisterBut4;
		~twister2.buttons[3].cv = ~twisterBut4;
		~twister3.buttons[3].cv = ~twisterBut4;
		~twister4.buttons[3].cv = ~twisterBut4;
		~twister5.buttons[3].cv = ~twisterBut4;
		if (~twisterIndex2.isNil, {

			~twisterBut4.signal(\on).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect} // Necessaire pour que les 6 boutons de la 1ere interface se mettent à jour avec les sliders de l'interface graphique, lorsque d'autres interfaces ont été sélectionnés
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 0, { // switch
					{ ~twister.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 0;
						~connectionsRateMake.(); ~connectionsRate.connect;
					}.fork(AppClock);
				},{
					{ ~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				});
			});
			~twisterBut4.signal(\off).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect}
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 0, { // switch
					{ ~twister.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 0;
						~connectionsRateMake.(); ~connectionsRate.connect;
					}.fork(AppClock);
				},{
					{ ~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				});
			});
		},{
			if (~twisterIndex3.isNil, {
				~twisterBut4.signal(\on).connectToUnique({
					{ ~twister2.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				});
				~twisterBut4.signal(\off).connectToUnique({
					{ ~twister2.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				});
			},{
				~twisterBut4.signal(\on).connectToUnique({
					{ ~twister3.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
				~twisterBut4.signal(\off).connectToUnique({
					{ ~twister3.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
			});
		});


		~twisterBut5 = OnOffControlValue();
		~twister.buttons[4].cv = ~twisterBut5;
		~twister2.buttons[4].cv = ~twisterBut5;
		~twister3.buttons[4].cv = ~twisterBut5;
		~twister4.buttons[4].cv = ~twisterBut5;
		~twister5.buttons[4].cv = ~twisterBut5;
		if (~twisterIndex2.isNil, {
			~twisterBut5.signal(\on).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect}
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 1, { // switch
					{ ~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				},{
					{ ~twister3.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
			});
			~twisterBut5.signal(\off).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect}
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 1, { // switch
					{ ~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 1;
						~connectionsBufMake.(); ~connectionsBuf.connect;
					}.fork(AppClock);
				},{
					{ ~twister3.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
			});
		},{
			if (~twisterIndex3.isNil, {
				~twisterBut5.signal(\on).connectToUnique({
					{ ~twister3.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
				~twisterBut5.signal(\off).connectToUnique({
					{ ~twister3.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 2;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
			},{
				~twisterBut5.signal(\on).connectToUnique({
					{ ~twister4.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 3;
						~connectionsRtmMake.(); ~connectionsRtm.connect;
					}.fork(AppClock);
				});
				~twisterBut5.signal(\off).connectToUnique({
					{ ~twister4.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 3;
						~connectionsRtmMake.(); ~connectionsRtm.connect;
					}.fork(AppClock);
				});
			});
		});


		~twisterBut6 = OnOffControlValue();
		~twister.buttons[5].cv = ~twisterBut6;
		~twister2.buttons[5].cv = ~twisterBut6;
		~twister3.buttons[5].cv = ~twisterBut6;
		~twister4.buttons[5].cv = ~twisterBut6;
		~twister5.buttons[5].cv = ~twisterBut6;
		if (~twisterIndex2.isNil, {
			~twisterBut6.signal(\on).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect}
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 3, { // switch
					{ ~twister4.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 3;
						~connectionsRtmMake.(); ~connectionsRtm.connect;
					}.fork(AppClock);
				},{
					{ ~twister5.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 4;
						~connectionsStrMake.(); ~connectionsStr.connect;
					}.fork(AppClock);
				});
			});
			~twisterBut6.signal(\off).connectToUnique({
				case
				{ ~twisterInterface == 0} {~connectionsRate.disconnect}
				{ ~twisterInterface == 1} {~connectionsBuf.disconnect}
				{ ~twisterInterface == 2} {~connectionsLeg.disconnect}
				{ ~twisterInterface == 3} {~connectionsRtm.disconnect}
				{ ~twisterInterface == 4} {~connectionsStr.disconnect};
				if (~twisterInterface != 3, { // switch
					{ ~twister4.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 3;
						~connectionsRtmMake.(); ~connectionsRtm.connect;
					}.fork(AppClock);
				},{
					{ ~twister5.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); ~twisterInterface = 4;
						~connectionsStrMake.(); ~connectionsStr.connect;
					}.fork(AppClock);
				});
			});
		},{
			if (~twisterIndex3.isNil, {
				~twisterBut6.signal(\on).connectToUnique({
					if (~twisterInterface2 != 3, { // switch
						{ ~twister4.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 3;
							/*if (~connectionsRtm.notNil, {~connectionsRtm.disconnect});*/ ~connectionsRtmMake.(); ~connectionsRtm.connect;
						}.fork(AppClock);
					},{
						{ ~twister5.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 4;
							/*if (~connectionsStr.notNil, {~connectionsStr.disconnect});*/ ~connectionsStrMake.(); ~connectionsStr.connect;
						}.fork(AppClock);
					});
				});
				~twisterBut6.signal(\off).connectToUnique({
					if (~twisterInterface2 != 3, { // switch
						{ ~twister4.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 3;
							/*if (~connectionsRtm.notNil, {~connectionsRtm.disconnect});*/ ~connectionsRtmMake.(); ~connectionsRtm.connect;
						}.fork(AppClock);
					},{
						{ ~twister5.connect(TwisterDevice(\twister2, MIDIClient.sources[~twisterIndex2])); ~twisterInterface2 = 4;
							/*if (~connectionsStr.notNil, {~connectionsStr.disconnect});*/ ~connectionsStrMake.(); ~connectionsStr.connect;
						}.fork(AppClock);
					});
				});
			},{
				~twisterBut6.signal(\on).connectToUnique({
					{ ~twister5.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 4;
						~connectionsLegMake.(); ~connectionsLeg.connect;
					}.fork(AppClock);
				});
				~twisterBut6.signal(\off).connectToUnique({
					{ ~twister5.connect(TwisterDevice(\twister3, MIDIClient.sources[~twisterIndex3])); ~twisterInterface2 = 4;
						~connectionsStrMake.(); ~connectionsStr.connect;
					}.fork(AppClock);
				});
			});
		});



		/*
		~twister.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex1])); // Connexion avec la première instance
		~twister2.connect(TwisterDevice(\twister, MIDIClient.sources[~twisterIndex2]));
		*/

		"Twister connected".postln;

	});

}.fork;