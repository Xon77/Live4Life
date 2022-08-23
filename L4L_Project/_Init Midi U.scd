// MIDI CONNECTION UC-33



/*
"/Users/Xon/Desktop/SC London/Workshops/Modality/modalityTest.rtf".openDocument;
"/Users/Xon/Desktop/SC London/Workshops/Modality/Modality Workshop EventStreams and FPSignals.rtfd".openDocument;
"/Users/Xon/Library/Application Support/SuperCollider/Extensions/Modality/MKtlSpecs/_HowToMakeAKtlDescription_.scd".openDocument;
*/



// Modality - check help
/*
MIDIIn.connectAll;
MIDIFunc.cc({|val, num, chan, src|
["cc",\val,val,\num, num, \chan, chan, \src, src].postln
}); // match all ccs


MIDIFunc.noteOn({|val, num, chan, src|
["noteOn",\val,val,\num, num, \chan, chan, \src, src].postln
}); // match any noteOn

MIDIFunc.noteOff({|val, num, chan, src|
["noteOff",\val,val,\num, num, \chan, chan, \src, src].postln
}); // match any noteOff
*/



// Quarks.gui
// MIDIExplorer // Pour configurer le controller midi



/*
MKtl.all;
MKtl.find; // ALL with details
MIDIMKtlDevice.find; // MIDI

// Parfois besoin de renommer l'interface dans l'interface midi / audio
*/



/*
Preset 3 Config
kn3_0, kn3_1, kn3_2, kn3_3, kn3_4, kn3_5, kn3_6, kn3_7
kn2_0, kn2_1, kn2_2, kn2_3, kn2_4, kn2_5, kn2_6, kn2_7
kn1_0, kn1_1, kn1_2, kn1_3, kn1_4, kn1_5, kn1_6, kn1_7
sl_0, sl_1, sl_2, sl_3, sl_4, sl_5, sl_6, sl_7, sl_8
*/



// ~uController = MKtl('csbm330'/*, 'UC-33 USB MIDI Controller'*/);
// ~uController = MKtl( 'UC-33 USB MIDI Controller');
/*
~uController = MKtl('midi_1_uc_33_', 'midi_1_uc_33_usb_midi_controller_port_1');
~uController = MKtl('midi_2_uc_33_', 'midi_2_uc_33_usb_midi_controller_port_2');
~uController = MKtl('evolution-ucontrol-uc33');
MKtl('midi_2_uc_33_', 'midi_2_uc_33_usb_midi_controller_port_2');
MKtl('midi_2_uc_33_', 'midi_2_uc_33_usb_midi_controller_port_2').rebuild
*/
/*
~uController = MKtl('midi_1_uc_33_', 'midi_1_uc_33_usb_midi_controller_port_1');
~uController.explore
MKtl('midi_1_uc_33_').explore('false');
MKtl('midi_1_uc_33_').createDescriptionFile;
MIDIExplorer.verbose = true;
MIDIExplorer.verbose = false; // turn it off again
*/
/*
~uController.printElementNames
~uController.elements.printAll;
~uController.elements.keys;
~uController.trace(true);
~uController.trace(false);
*/



/*
~uController.elements;
~uController.postDeviceDescription;
~uController.verbose_(true);
~uController.at(\sl_1);
*/



// Assignation des controleurs dans des variables d'environnement
~slider1 = ~uController.elementAt(\sl, 0);
~slider2 = ~uController.elementAt(\sl, 1);
~slider3 = ~uController.elementAt(\sl, 2);
~slider4 = ~uController.elementAt(\sl, 3);
~slider5 = ~uController.elementAt(\sl, 4);
~slider6 = ~uController.elementAt(\sl, 5);
~slider7 = ~uController.elementAt(\sl, 6);
~slider8 = ~uController.elementAt(\sl, 7);
~slider9 = ~uController.elementAt(\sl, 8);

~knob1_1 = ~uController.elementAt(\kn, 0, 0);
~knob1_2 = ~uController.elementAt(\kn, 0, 1);
~knob1_3 = ~uController.elementAt(\kn, 0, 2);
~knob1_4 = ~uController.elementAt(\kn, 0, 3);
~knob1_5 = ~uController.elementAt(\kn, 0, 4);
~knob1_6 = ~uController.elementAt(\kn, 0, 5);
~knob1_7 = ~uController.elementAt(\kn, 0, 6);
~knob1_8 = ~uController.elementAt(\kn, 0, 7);

~knob2_1 = ~uController.elementAt(\kn, 1, 0);
~knob2_2 = ~uController.elementAt(\kn, 1, 1);
~knob2_3 = ~uController.elementAt(\kn, 1, 2);
~knob2_4 = ~uController.elementAt(\kn, 1, 3);
~knob2_5 = ~uController.elementAt(\kn, 1, 4);
~knob2_6 = ~uController.elementAt(\kn, 1, 5);
~knob2_7 = ~uController.elementAt(\kn, 1, 6);
~knob2_8 = ~uController.elementAt(\kn, 1, 7);

~knob3_1 = ~uController.elementAt(\kn, 2, 0);
~knob3_2 = ~uController.elementAt(\kn, 2, 1);
~knob3_3 = ~uController.elementAt(\kn, 2, 2);
~knob3_4 = ~uController.elementAt(\kn, 2, 3);
~knob3_5 = ~uController.elementAt(\kn, 2, 4);
~knob3_6 = ~uController.elementAt(\kn, 2, 5);
~knob3_7 = ~uController.elementAt(\kn, 2, 6);
~knob3_8 = ~uController.elementAt(\kn, 2, 7);

~button0 = ~uController.elementAt(\bt, 0).action_({ |el| { ~fxDefaultAll2View.valueAction_(1) }.defer; /*pour arrêter les effets*/ /*el.postln; el.value.postln*/ }); // uniquement les boutons de 0 à 5 fonctionnent
~button1 = ~uController.elementAt(\bt, 1).action_({ |el| { ~fxRandAllView.valueAction_(1); "Effect Randomizer".postln }.defer; /*pour randomizer les effets*/ /*el.postln; el.value.postln*/ });
~button2 = ~uController.elementAt(\bt, 2).action_({ |el| { ~fxRandParametersAllView.valueAction_(1); "Parameter Effect Randomizer".postln }.defer; /*pour randomizer les paramètres d'effets*/ /*el.postln; el.value.postln*/ });

/*~button3 = ~uController.elementAt(\bt, 3).action_({ |el| { if (~fxInSerieChooseAllButtonView.value == 0, {~fxInSerieChooseAllButtonView .valueAction_(1)}, {~fxInSerieChooseAllButtonView .valueAction_(0)} ) }.defer;
/*Switch effets en série / parallèle */ /*el.postln; el.value.postln*/
});*/

~button4 = ~uController.elementAt(\bt, 4).action_({ |el| { ~lastPresetView.valueAction_(1) }.defer; /*el.postln; el.value.postln*/ });
~button5 = ~uController.elementAt(\bt, 5).action_({ |el| { ~nextPresetView.valueAction_(1) }.defer; /*el.postln; el.value.postln*/ });

~button6 = ~uController.elementAt(\bt, 6)/*.action_({ |el| el.postln; el.value.postln })*/;
~button7 = ~uController.elementAt(\bt, 7)/*.action_({ |el| el.postln; el.value.postln })*/;
~button8 = ~uController.elementAt(\bt, 8)/*.action_({ |el| el.postln; el.value.postln })*/;
~button9 = ~uController.elementAt(\bt, 9)/*.action_({ |el| el.postln; el.value.postln })*/;










// Utilisation de 1 tranche pour chacune des 8 Tracks

~slider1.action_({ |v| {~trackVolView[0].valueAction_(v.value); }.defer });
/*
~slider1.reset;
~slider1.action_({ |el| el.value.postln; });
(0, 0.1..1).sqrt
~dbSpec = ControlSpec(0.ampdb, 1.5.ampdb, \db, units: " dB");
~ampSpec = ControlSpec(0, 1, -4);
~ampSpec.map((0, 0.1..1));
*/
~slider2.action_({ |v| {~trackVolView[1].valueAction_(v.value); }.defer });
~slider3.action_({ |v| {~trackVolView[2].valueAction_(v.value); }.defer });
~slider4.action_({ |v| {~trackVolView[3].valueAction_(v.value); }.defer });
~slider5.action_({ |v| {~trackVolView[4].valueAction_(v.value); }.defer });
~slider6.action_({ |v| {~trackVolView[5].valueAction_(v.value); }.defer });
~slider7.action_({ |v| {~trackVolView[6].valueAction_(v.value); }.defer });
~slider8.action_({ |v| {~trackVolView[7].valueAction_(v.value); }.defer });
~slider9.action_({ |v| {~trackAllVolView.valueAction_(v.value); }.defer }); // La valeur 90 en midi correspond à peu près au 0db

// Assignation du volume général
// \db -> ControlSpec(0.ampdb, 1.ampdb, \db, units: " dB")
// ~dbSpec = \db.asSpec; // pas approprié car ne va pas au delà de 0 -> + 6 db
// ~dbSpec = ControlSpec(0.ampdb, 1.5.ampdb, \db, units: " dB");
// ~slider9.do{ |v| s.volume = ~dbSpec.map(v) };



/*
~seqSeq[0];
~seqsValue;
~currentSeq;
switch();
~playViewValue[0] == 1;
Pdef(\a_one).isPlaying;
*/



/*
~knob1_1.do{ |v| {~rtmMulView.valueAction_(v) }.defer };
~knob2_1.do{ |v| {~ratMulView.valueAction_(v) }.defer };
~knob3_1.do{ |v| {~legMulView.valueAction_(v) }.defer };
*/



/*~knob1_1.do{ |v| var trackA = 0, trackB = 1;
case
{ ~tracksValue.inclusivelyBetween(trackA, trackB) }
{ { ~rtmMulView.valueAction_(v) }.defer }

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
{ ~rtmMul[trackA][~seqSeq[trackA]] = ~rtmMulSpec.map(v) } // rtmMulSpec est spécifique à la piste et à la séquence dorénavant

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
{ ~rtmMul[trackB][~seqSeq[trackB]] = ~rtmMulSpec.map(v) }
};

~knob1_2.do{ |v| var trackA = 2, trackB = 3;
case
{ ~tracksValue.inclusivelyBetween(trackA, trackB) }
{ { ~rtmMulView.valueAction_(v) }.defer }

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
{ ~rtmMul[trackA][~seqSeq[trackA]] = ~rtmMulSpec.map(v) }

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
{ ~rtmMul[trackB][~seqSeq[trackB]] = ~rtmMulSpec.map(v) }
};*/



// Attribution automatique des boutons - chaque tranche à une piste

~knobs1 = [~knob1_1, ~knob1_2, ~knob1_3, ~knob1_4, ~knob1_5, ~knob1_6, ~knob1_7, ~knob1_8];
~knobs2 = [~knob2_1, ~knob2_2, ~knob2_3, ~knob2_4, ~knob2_5, ~knob2_6, ~knob2_7, ~knob2_8];
~knobs3 = [~knob3_1, ~knob3_2, ~knob3_3, ~knob3_4, ~knob3_5, ~knob3_6, ~knob3_7, ~knob3_8];
~knobsTracks = (0..15).clump(2);



~knobs1.do { |item, i| // Attribution de la ligne de boutons 3 au RAT
	item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
		case
		/*{ ~tracksValue.inclusivelyBetween(trackA, trackB) }
		{ { ~ratMulView.valueAction_(v.value) }.defer }*/
		{ ~tracksValue == trackA }
		{ { ~ratMulView.valueAction_(v.value); /* et juste pour le marquage rouge */ ~ratMulViewG[trackA].valueAction_(v.value) }.defer; }
		{ ~tracksValue == trackB }
		{ { ~ratMulView.valueAction_(v.value); ~ratMulViewG[trackB].valueAction_(v.value) }.defer; }

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} } // Seulement quand la piste est jouée
		{
			// ~ratMul[trackA][~seqSeq[trackA]] = ~ratMulSpec.map(v.value) // Action seulement sur la valeur
			{~ratMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
		{
			// ~ratMul[trackB][~seqSeq[trackB]] = ~ratMulSpec.map(v.value) // Action seulement sur la valeur
			{~ratMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}
	});
};



~knobs2.do { |item, i| // Attribution de la ligne de boutons 2 au PRO
	item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
		case
		{ ~tracksValue == trackA }
		{ { ~proMulView.valueAction_(v.value); ~proMulViewG[trackA].valueAction_(v.value) }.defer; }
		{ ~tracksValue == trackB }
		{ { ~proMulView.valueAction_(v.value); ~proMulViewG[trackB].valueAction_(v.value) }.defer; }

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
		{
			// ~proMul[trackA][~seqSeq[trackA]] = ~proMulSpec.map(v.value) // Action seulement sur la valeur
			{~proMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
		{
			// ~proMul[trackB][~seqSeq[trackB]] = ~proMulSpec.map(v.value) // Action seulement sur la valeur
			{~proMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}
	});
};



~knobs3.do { |item, i| // Attribution de la ligne de boutons 1 au RTM
	item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
		case
		{ ~tracksValue == trackA }
		{ { ~rtmMulView.valueAction_(v.value); ~rtmMulViewG[trackA].valueAction_(v.value) }.defer; }
		{ ~tracksValue == trackB }
		{ { ~rtmMulView.valueAction_(v.value); ~rtmMulViewG[trackB].valueAction_(v.value) }.defer; }

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
		{
			// ~rtmMul[trackA][~seqSeq[trackA]] = ~rtmMulSpec.map(v.value)  // Action seulement sur la valeur
			{~rtmMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}

		{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
		{
			// ~rtmMul[trackB][~seqSeq[trackB]] = ~rtmMulSpec.map(v.value)  // Action seulement sur la valeur
			{~rtmMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
		}
	});
};



// ~knobs1.do { |item, i| item.reset };
// [~knobs1, ~knobs2, ~knobs3].do { |i| i.do { |a| a.reset } }; // remove all listeners
// ou stopDoing sur l'EventSource pour arrêter le déclenchement de la fonction



// Possibilité ci-dessous de changer l'attribution du RTM et du LEG
// à la PRO et au BUF respectivement

/*
[~knobs1, ~knobs3].do { |i| i.do { |a| a.reset } }; // remove all listeners

~knobs1.do { |item, i| // Attribution de la ligne de boutons 1 au RTM
item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
case
{ ~tracksValue == trackA }
{ { ~rtmMulViewG[trackA].valueAction_(v.value); ~rtmMulViewG[trackA].valueAction_(v.value) }.defer; }
{ ~tracksValue == trackB }
{ { ~rtmMulViewG[trackB].valueAction_(v.value); ~rtmMulViewG[trackB].valueAction_(v.value) }.defer; }

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
{
// ~rtmMul[trackA][~seqSeq[trackA]] = ~rtmMulSpec.map(v.value) // Action seulement sur la valeur
{~rtmMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
}

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
{
// ~rtmMul[trackB][~seqSeq[trackB]] = ~rtmMulSpec.map(v.value) // Action seulement sur la valeur
{~rtmMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
}
});
};

~knobs3.do { |item, i| // Attribution de la ligne de boutons 3 au LEG
item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
case
{ ~tracksValue == trackA }
{ { ~legMulViewG[trackA].valueAction_(v.value); ~legMulViewG[trackA].valueAction_(v.value) }.defer; }
{ ~tracksValue == trackB }
{ { ~legMulViewG[trackB].valueAction_(v.value); ~legMulViewG[trackB].valueAction_(v.value) }.defer; }

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
{
// ~legMul[trackA][~seqSeq[trackA]] = ~legMulSpec.map(v.value)  // Action seulement sur la valeur
{~legMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
}

{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
{
// ~legMul[trackB][~seqSeq[trackB]] = ~legMulSpec.map(v.value)  // Action seulement sur la valeur
{~legMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
}
});
};
*/



~knob3_8.action_({ |v|
	{
		// var lagTime = ~lagTimeAllFx; // comment mettre le lag xfade à 0.5 temporairement lors du changement du mix et remettre le lag global précédent par la suite ???
		/*~lagTimeAllFxView.valueAction_(0.5);
		// ~mixAllFxView.valueAction_(ControlSpec(-1, 1, 'lin', 0.01, -1).map(v.value));
		~mixAllFxView2.valueAction_(/*ControlSpec(-1, 1, 'lin', 0.01, -1).map(*/v.value/*)*/);
		// ~lagTimeAllFxView.valueAction_(lagTime);*/
		~mixAllFxView2.valueAction_(/*ControlSpec(-1, 1, 'lin', 0.01, -1).map(*/v.value/*)*/);
	}.defer
});
~knob2_8.action_({ |v| { ~lagTimeAllFxView.valueAction_(ControlSpec(0, 30, 'lin', 0.01, 1).map(v.value)) }.defer });
~knob1_8.action_({ |v| { ~trackFXVolView.valueAction_(ControlSpec(0, 1, 'lin', 0.001, 1).map(v.value)) /*~fadeTimeSynthFxView.valueAction_(ControlSpec(0.01, 30, 'lin', 0.01, 1).map(v.value))*/ }.defer });

~knob1_7.action_({ |v| { ~eqChaLoView[8].valueAction_(v.value) }.defer });
~knob2_7.action_({ |v| { ~eqChaMiView[8].valueAction_(v.value) }.defer });
~knob3_7.action_({ |v| { ~eqChaHiView[8].valueAction_(v.value) }.defer });





~button3 = ~uController.elementAt(\bt, 3).action_({ |el|

	[~knobs1, ~knobs2, ~knobs3].do { |i| i.do { |a| a.reset } };

	if (el.value == 1, {

		"UC33 -> 6 Modulators triggered".postln;

		~knobs1.do { |item, i| // Attribution de la ligne de boutons 3 au RAT
			item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
				case
				/*{ ~tracksValue.inclusivelyBetween(trackA, trackB) }
				{ { ~ratMulView.valueAction_(v.value) }.defer }*/
				{ ~tracksValue == trackA }
				{ { ~ratMulView.valueAction_(v.value); /* et juste pour le marquage rouge */ ~ratMulViewG[trackA].valueAction_(v.value) }.defer; }
				{ ~tracksValue == trackB }
				{ { ~ratMulView.valueAction_(v.value); ~ratMulViewG[trackB].valueAction_(v.value) }.defer; }

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} } // Seulement quand la piste est jouée
				{
					// ~ratMul[trackA][~seqSeq[trackA]] = ~ratMulSpec.map(v.value) // Action seulement sur la valeur
					{~ratMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
				{
					// ~ratMul[trackB][~seqSeq[trackB]] = ~ratMulSpec.map(v.value) // Action seulement sur la valeur
					{~ratMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}
			});
		};

		~knobs2.do { |item, i| // Attribution de la ligne de boutons 2 au PRO
			item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
				case
				{ ~tracksValue == trackA }
				{ { ~proMulView.valueAction_(v.value); ~proMulViewG[trackA].valueAction_(v.value) }.defer; }
				{ ~tracksValue == trackB }
				{ { ~proMulView.valueAction_(v.value); ~proMulViewG[trackB].valueAction_(v.value) }.defer; }

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
				{
					// ~proMul[trackA][~seqSeq[trackA]] = ~proMulSpec.map(v.value) // Action seulement sur la valeur
					{~proMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
				{
					// ~proMul[trackB][~seqSeq[trackB]] = ~proMulSpec.map(v.value) // Action seulement sur la valeur
					{~proMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}
			});
		};

		~knobs3.do { |item, i| // Attribution de la ligne de boutons 1 au RTM
			item.action_({ |v| var trackA = ~knobsTracks[i][0], trackB = ~knobsTracks[i][1];
				case
				{ ~tracksValue == trackA }
				{ { ~rtmMulView.valueAction_(v.value); ~rtmMulViewG[trackA].valueAction_(v.value) }.defer; }
				{ ~tracksValue == trackB }
				{ { ~rtmMulView.valueAction_(v.value); ~rtmMulViewG[trackB].valueAction_(v.value) }.defer; }

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackA] == 1} }
				{
					// ~rtmMul[trackA][~seqSeq[trackA]] = ~rtmMulSpec.map(v.value)  // Action seulement sur la valeur
					{~rtmMulViewG[trackA].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}

				{~tracksValue != trackA or: {~tracksValue != trackB} and: {~playViewValue[trackB] == 1} }
				{
					// ~rtmMul[trackB][~seqSeq[trackB]] = ~rtmMulSpec.map(v.value)  // Action seulement sur la valeur
					{~rtmMulViewG[trackB].valueAction_(v.value) }.defer; // Action sur les sliders de la vue globale
				}
			});
		};

	}, {

		"UC33 -> 6 EQ triggered".postln;

		~knob1_1.action_({ |v| { ~eqChaLoView[0].valueAction_(v.value) }.defer });
		~knob2_1.action_({ |v| { ~eqChaMiView[0].valueAction_(v.value) }.defer });
		~knob3_1.action_({ |v| { ~eqChaHiView[0].valueAction_(v.value) }.defer });

		~knob1_2.action_({ |v| { ~eqChaLoView[1].valueAction_(v.value) }.defer });
		~knob2_2.action_({ |v| { ~eqChaMiView[1].valueAction_(v.value) }.defer });
		~knob3_2.action_({ |v| { ~eqChaHiView[1].valueAction_(v.value) }.defer });

		~knob1_3.action_({ |v| { ~eqChaLoView[2].valueAction_(v.value) }.defer });
		~knob2_3.action_({ |v| { ~eqChaMiView[2].valueAction_(v.value) }.defer });
		~knob3_3.action_({ |v| { ~eqChaHiView[2].valueAction_(v.value) }.defer });

		~knob1_4.action_({ |v| { ~eqChaLoView[3].valueAction_(v.value) }.defer });
		~knob2_4.action_({ |v| { ~eqChaMiView[3].valueAction_(v.value) }.defer });
		~knob3_4.action_({ |v| { ~eqChaHiView[3].valueAction_(v.value) }.defer });

		~knob1_5.action_({ |v| { ~eqChaLoView[4].valueAction_(v.value) }.defer });
		~knob2_5.action_({ |v| { ~eqChaMiView[4].valueAction_(v.value) }.defer });
		~knob3_5.action_({ |v| { ~eqChaHiView[4].valueAction_(v.value) }.defer });

		~knob1_6.action_({ |v| { ~eqChaLoView[5].valueAction_(v.value) }.defer });
		~knob2_6.action_({ |v| { ~eqChaMiView[5].valueAction_(v.value) }.defer });
		~knob3_6.action_({ |v| { ~eqChaHiView[5].valueAction_(v.value) }.defer });

	});

	~knob3_8.action_({ |v|
		{
			// var lagTime = ~lagTimeAllFx; // comment mettre le lag xfade à 0.5 temporairement lors du changement du mix et remettre le lag global précédent par la suite ???
			/*~lagTimeAllFxView.valueAction_(0.5);
			// ~mixAllFxView.valueAction_(ControlSpec(-1, 1, 'lin', 0.01, -1).map(v.value));
			~mixAllFxView2.valueAction_(/*ControlSpec(-1, 1, 'lin', 0.01, -1).map(*/v.value/*)*/);
			// ~lagTimeAllFxView.valueAction_(lagTime);*/
			~mixAllFxView2.valueAction_(/*ControlSpec(-1, 1, 'lin', 0.01, -1).map(*/v.value/*)*/);
		}.defer
	});
	~knob2_8.action_({ |v| { ~lagTimeAllFxView.valueAction_(ControlSpec(0, 30, 'lin', 0.01, 1).map(v.value)) }.defer });
	~knob1_8.action_({ |v| { ~trackFXVolView.valueAction_(ControlSpec(0, 1, 5, 0.001, 1).map(v.value)) /*~fadeTimeSynthFxView.valueAction_(ControlSpec(0.01, 30, 'lin', 0.01, 1).map(v.value))*/ }.defer });

	~knob1_7.action_({ |v| { ~eqChaLoView[8].valueAction_(v.value) }.defer });
	~knob2_7.action_({ |v| { ~eqChaMiView[8].valueAction_(v.value) }.defer });
	~knob3_7.action_({ |v| { ~eqChaHiView[8].valueAction_(v.value) }.defer });

});





"UC-33 connected".postln;










/*( // à mettre dans UC-33.desc.scd
/*idInfo:*/ device: "UC-33 USB MIDI Controller",
protocol: \midi,
// preset 3
description: (
	sl: #[105, 106, 107, 108, 110, 111, 112, 116, 26].collect {|num, i|
		(/*\midiType*/midiMsgType: \cc, \type: \slider, \midiChan: 0, \midiNum: num, \spec: \midiCC/*, \ioType: \in*/)
	},

	kn: #[[45, 46, 47, 5, 80, 81, 82, 83], [50, 51, 55, 87, 75, 76, 77, 78], [20, 21, 40, 43, 70, 71, 72, 73]].collect{|row| row.collect {|num, i|
		(/*\midiType*/midiMsgType: \cc, \type: \knob, \midiChan: 0, \midiNum: num, \spec: \midiCC/*, \ioType: \in*/)
	}},
	bt: #[57, 22, 23, 24, 41, 42, 44, 52, 53, 54].collect {|num, i|
		(/*\midiType*/midiMsgType: \cc, \type: \button, \midiChan: 0, \midiNum: num, \spec: \midiBut/*, \mode: \toggle, \ioType: \in*/)
	}

)
)*/










/*

~seqCompG1[0].visibleOrigin = Point( 0, 1461 )
~seqCompG1[0].visibleOrigin = Point( 0, 2732 )
~seqCompG1[tr].visibleOrigin = ~seqCompG1[tr].visibleOrigin

*/


