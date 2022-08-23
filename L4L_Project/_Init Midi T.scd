// Preset Associations

/*~globalDouxPresets = [ [ 1, 6, 7, 10, 20, 21, 143, 144, 149, 156 ], [ 143, 59, 16, 139, 160, 162, 189, 192, 194, 193 ] ];
~globalMixPresets = [ [ 52, 50, 63, 64, 66, 66, 67, 37, 37, 42 ], [ 115, 79, 86, 89, 92, 93, 107, 38, 68, 54 ] ];
~globalHardPresets = [ [ 89, 79, 92, 93, 40, 41, 132, 129, 129, 129 ], [ 90, 107, 121, 121, 80, 80, 133, 130, 135, 136 ] ];
~global7Presets = [ [ 157, 20, 24, 26, 139, 12, 68, 71, 157, 156 ], [ 193, 199, 200, 199, 200, 199, 200, 199, 59, 163 ] ];
~global8Presets = [ [ 89, 93, 94, 42, 47, 72, 72, 73, 74, 76 ], [ 107, 87, 95, 3, 125, 128, 124, 120, 118, 115 ] ];
~global9Presets = [ [ 6, 7, 8, 9, 23, 25, 12, 69, 8, 69 ], [ 21, 189, 193, 194, 198, 148, 71, 136, 70, 51 ] ];*/

/*~globalDouxPresets = { { { 200.rand } !10 } !2 } !10;
~globalMixPresets = { { { 200.rand } !10 } !2 } !10;
~globalHardPresets = { { { 200.rand } !10 } !2 } !10;
~global7Presets = { { { 200.rand } !10 } !2 } !10;
~global8Presets = { { { 200.rand } !10 } !2 } !10;
~global9Presets = { { { 200.rand } !10 } !2 } !10;*/





/*
MKtl.find; // ALL
MKtl.allAvailable;
MKtl.find(\midi); // MIDI
MKtl.allAvailable['midi'];

MKtl.openDescriptionFolder;

Post << MKtl.allDescriptions; // Return a Dictionary with all open loaded device descriptions
MKtl.postAllDescriptions; // Posts all descriptions found in the deviceDescriptionFolder

MKtl.loadMatching("gestionnaire-iac");
MKtl.loadAllDescs(true, verbose: true ); // reload them anyways and be verbose about it

MidiFunc
*/

/*
// For exploring the device
~midiTouchBar = MKtl('iac', 'midi_0_gestionnaire_iac');
~midiTouchBar = MKtl('MIDI Touchbar Surface', "gestionnaire-iac");

~midiTouchBar = MKtl('midi_0_gestio', "gestionnaire-iac");
~midiTouchBar = MKtl('iac', "gestionnaire-iac");

MKtl('iac').explore;
MKtl('iac').explore('false');
MKtl('iac').createDescriptionFile; // Peut être nécessaire de rouvrir l'application pour créer un DescriptionFile

MKtl('gstn0').explore;
MKtl(gstn0).explore(false);
MKtl(gstn0).createDescriptionFile;

// Test

~midiTouchBar = MKtl('gstn0'); // OK - gestionnaire-iac pas nécessaire
~midiTouchBar = MKtl('iac', "Gestionnaire IAC"); // OK
~midiTouchBar = MKtl('iac').rebuildFrom("Gestionnaire IAC"); // OK
~midiTouchBar = MKtl.newFromDevice(deviceInfo: "Gestionnaire IAC"); // OK - cree MKtl('gstn0')
~midiTouchBar = MKtl.newFromDevice('iac', "Gestionnaire IAC"); // OK

~midiTouchBar.gui;

~midiTouchBar.elements;
~midiTouchBar.elementAt(\cc_0_000);
*/

/*
Post << HID.findAvailable;
HID.postAvailable;
HIDFunc.trace( true );
~myhid = HID.open( 1386, 211 );
~myhid = HID.open( 1452, 632 );
~myhid.elements[1].action = { |...args| args.postln; };
m = MKtl('wacom', 'hid_0_cth_661');
MKtl('wacom').explore
MKtl('hid_0_cth_66', 'hid_0_cth_661').createDescriptionFile;
MKtl('hid_0_cth_66', 'hid_0_cth_661').explore;
HIDExplorer.start(MKtl( 'hid_0_cth_66' ).device.source);
MKtl('hid_0_cth_66')
MKtl('hid_0_cth_66').explore
MKtl('hid_0_cth_66', 'hid_0_cth_661', multiIndex:0);
MKtl('hid_0_cth_66').rebuild
*/



~tBSlider1 = ~midiTouchBar.elementAt(\cc_6_000);
~tBSlider2 = ~midiTouchBar.elementAt(\cc_6_001);
~tBSlider3 = ~midiTouchBar.elementAt(\cc_6_002);
~tBSlider4 = ~midiTouchBar.elementAt(\cc_6_003);

~tBSlider5 = ~midiTouchBar.elementAt(\cc_6_004);
~tBSlider6 = ~midiTouchBar.elementAt(\cc_6_005);

~tBSlider7 = ~midiTouchBar.elementAt(\cc_6_006);
~tBSlider8 = ~midiTouchBar.elementAt(\cc_6_007);
~tBSlider9 = ~midiTouchBar.elementAt(\cc_6_008);
~tBSlider10 = ~midiTouchBar.elementAt(\cc_6_009);


~tBButtonA = ~midiTouchBar.elementAt(\nOn_6_000);
~tBButtonB = ~midiTouchBar.elementAt(\nOn_6_001);
~tBButtonCOn = ~midiTouchBar.elementAt(\nOn_6_002); // Mute Rythme
~tBButtonDOn = ~midiTouchBar.elementAt(\nOn_6_003); // Focus Rythme
~tBButtonCOff = ~midiTouchBar.elementAt(\nOff_6_002); // Mute Rythme
~tBButtonDOff = ~midiTouchBar.elementAt(\nOff_6_003); // Focus Rythme
~tBButtonPanic = ~midiTouchBar.elementAt(\nOn_6_004); // Bouton Panic


// A a été supprimé, mais de toute façon les boutons sont pas utilisés pour l'instant
/*~tBButtonB1 = ~midiTouchBar.elementAt(\nOn_6_036);
~tBButtonB2 = ~midiTouchBar.elementAt(\nOn_6_037);
~tBButtonB3 = ~midiTouchBar.elementAt(\nOn_6_038);
~tBButtonB4 = ~midiTouchBar.elementAt(\nOn_6_039);
~tBButtonB5 = ~midiTouchBar.elementAt(\nOn_6_040);
~tBButtonB6 = ~midiTouchBar.elementAt(\nOn_6_041);
~tBButtonB7 = ~midiTouchBar.elementAt(\nOn_6_042);
~tBButtonB8 = ~midiTouchBar.elementAt(\nOn_6_043);
~tBButtonB9 = ~midiTouchBar.elementAt(\nOn_6_044);
~tBButtonB10 = ~midiTouchBar.elementAt(\nOn_6_045);

~tBButtonC1 = ~midiTouchBar.elementAt(\nOn_6_048);
~tBButtonC2 = ~midiTouchBar.elementAt(\nOn_6_049);
~tBButtonC3 = ~midiTouchBar.elementAt(\nOn_6_050);
~tBButtonC4 = ~midiTouchBar.elementAt(\nOn_6_051);
~tBButtonC5 = ~midiTouchBar.elementAt(\nOn_6_052);
~tBButtonC6 = ~midiTouchBar.elementAt(\nOn_6_053);
~tBButtonC7 = ~midiTouchBar.elementAt(\nOn_6_054);
~tBButtonC8 = ~midiTouchBar.elementAt(\nOn_6_055);
~tBButtonC9 = ~midiTouchBar.elementAt(\nOn_6_056);
~tBButtonC10 = ~midiTouchBar.elementAt(\nOn_6_057);

~tBButtonD1 = ~midiTouchBar.elementAt(\nOn_6_060);
~tBButtonD2 = ~midiTouchBar.elementAt(\nOn_6_061);
~tBButtonD3 = ~midiTouchBar.elementAt(\nOn_6_062);
~tBButtonD4 = ~midiTouchBar.elementAt(\nOn_6_063);
~tBButtonD5 = ~midiTouchBar.elementAt(\nOn_6_064);
~tBButtonD6 = ~midiTouchBar.elementAt(\nOn_6_065);
~tBButtonD7 = ~midiTouchBar.elementAt(\nOn_6_066);
~tBButtonD8 = ~midiTouchBar.elementAt(\nOn_6_067);
~tBButtonD9 = ~midiTouchBar.elementAt(\nOn_6_068);
~tBButtonD10 = ~midiTouchBar.elementAt(\nOn_6_069);

~tBButtonE1 = ~midiTouchBar.elementAt(\nOn_6_072);
~tBButtonE2 = ~midiTouchBar.elementAt(\nOn_6_073);
~tBButtonE3 = ~midiTouchBar.elementAt(\nOn_6_074);
~tBButtonE4 = ~midiTouchBar.elementAt(\nOn_6_075);
~tBButtonE5 = ~midiTouchBar.elementAt(\nOn_6_076);
~tBButtonE6 = ~midiTouchBar.elementAt(\nOn_6_077);
~tBButtonE7 = ~midiTouchBar.elementAt(\nOn_6_078);
~tBButtonE8 = ~midiTouchBar.elementAt(\nOn_6_079);
~tBButtonE9 = ~midiTouchBar.elementAt(\nOn_6_080);
~tBButtonE10 = ~midiTouchBar.elementAt(\nOn_6_081);*/


~tBSlider4.action_({ |v| /*v.value.postln;*/ {~trackAllVolView.valueAction_(v.value*~maxMulVolControllers); }.defer }); // La valeur 90 en midi correspond à peu près au 0db
~tBSlider3.action_({ |v| { ~trackFXVolView.valueAction_(ControlSpec(0.025, 0.6, 'lin', 0.001, 1).map(v.value)) /*~fadeTimeSynthFxView.valueAction_(ControlSpec(0.01, 30, 'lin', 0.01, 1).map(v.value))*/ }.defer });
~tBSlider2.action_({ |v| { ~nbOfServers.do { |i| ~mixAllFxView2[i].valueAction_(/*ControlSpec(-1, 1, 'lin', 0.01, -1).map(*/v.value/*)*/); }; }.defer });
~tBSlider1.action_({ |v| { ~ratMulView.valueAction_(ControlSpec(0.01, 1, 0, 0.01, 1).map(v.value)); /*v.value.postln*/ }.defer });
// { { ~ratMulView.valueAction_(ControlSpec(0, 127, 4, 0.01, 10).map(v.value)); /* et juste pour le marquage rouge */ ~ratMulViewG[trackA].valueAction_(v.value) }.defer; }

~tBSlider6.action_({ |v| /*v.value.postln;*/ {~trackAllVolView.valueAction_(v.value*~maxMulVolControllers); }.defer }); // La valeur 90 en midi correspond à peu près au 0db
~tBSlider5.action_({ |v| { ~trackFXVolView.valueAction_(ControlSpec(0.025, 0.6, 'lin', 0.001, 1).map(v.value)) /*~fadeTimeSynthFxView.valueAction_(ControlSpec(0.01, 30, 'lin', 0.01, 1).map(v.value))*/ }.defer });

~tBButtonB.action_({ |v| ~trackAllVolControl1View.valueAction_(1); });
~tBButtonA.action_({ |v|
	if (~trackFXVolView.value == 0.06, {~trackFXVolView.valueAction_(0.12)}, {~trackFXVolView.valueAction_(0.06)} );
	if (~trackFXVolView.value != 0.12 and: {~trackFXVolView.value != 0.06}, {~trackFXVolView.valueAction_(0.06)} );
});

// Pour les Toggles, penser à mettre un NoteOff
~tBButtonCOff.action_({ |v| /* v.value.postln;*/ { ~presetVarsVolSliderView.valueAction_(1) }.defer });
~tBButtonCOn.action_({ |v| /* v.value.postln;*/ { ~presetVarsVolSliderView.valueAction_(0) }.defer });
~tBButtonDOff.action_({ |v| /* v.value.postln;*/ { ~presetVarsVolFocusView.valueAction_(0) }.defer });
~tBButtonDOn.action_({ |v| /* v.value.postln;*/ { ~presetVarsVolFocusView.valueAction_(1) }.defer });

~tBButtonPanic.action_({ |v| ~trackAllVolControl1View.valueAction_(1); ~trackFXVolView.valueAction_(0) });


~tBSlider7.action_({ |v| {~gblSeqIndexView.value_( v.value /*~gblSeqIndexSpec[~tracksValue][~seqsValue].unmap(v)*/ ).doAction }.defer  });

~tBSlider8.action_({ |v| {~gblSeqView.lo_( v.value ).doAction }.defer; });
~tBSlider9.action_({ |v| {~gblSeqView.hi_( v.value ).doAction }.defer; });
// ~tBSlider8.action_({ |v| if (v.value > ~gblSeqView.hi, { ~gblSeqView.hi_( v.value ).doAction; }, { ~gblSeqView.lo_( v.value ).doAction; }) });
// ~tBSlider9.action_({ |v| if (v.value > ~gblSeqView.lo, { ~gblSeqView.hi_( v.value ).doAction; }, { ~gblSeqView.lo_( v.value ).doAction; }) });
// ~gblSeqView.value_( ~gblSeqSpec[~tracksValue][~seqsValue].unmap([~presets[index][\gblSeqStart], ~presets[index][\gblSeqStop]+1]) ).doAction;

// ~tBSlider10.action_({ |v| var prev; if (prev != v.value, {~presetVarsSliderView.valueAction_( v.value )}); prev = v.value });
~tBSlider10.action_({ |v| {~presetVarsSliderView.valueAction_( v.value )}.defer }); // ou voir ~presetVarsSliderViewFunction
// Hack lent pour éviter d'avoir des Preset Variations en rouge, quand action avec le Lemur
// Plus nécessaire depuis que la ligne ci-dessus a été intégré dans.defer
// { 60.do { |i| ~presetVarsSliderView.valueAction_(~presetVarsSliderSpec.unmap(60-i)); 0.02.wait;}; }.fork(AppClock);


"TouchBar connected".postln;



/*
MIDIIn.connectAll;
MIDIFunc.cc({|val, num, chan, src| ["cc",\val,val,\num, num, \chan, chan, \src, src].postln });
MIDIFunc.cc({|...args| args.postln; }); // [ 90, 3, 1, -63353900 ]
MIDIdef.cc(\cc, { |...args| args.postln; })
MIDIdef.cc(\cc, { |...args| args.postln; }, srcID: -63353900)
*/

/*
MIDIIn.connectAll;
MIDIdef.cc(\a, { |...args| args[0].postln; {~trackAllVolView.valueAction_(args[0]/127.0) }.defer }, 3, 1, -63353900);
MIDIdef.cc(\b, { |...args| args[0].postln; {~trackFXVolView.valueAction_(ControlSpec(0.025, 0.5, 'lin', 0.001, 1).map(args[0]/127.0)) }.defer  }, 2, 1, -63353900);
MIDIdef.cc(\c, { |...args| args[0].postln; {~mixAllFxView2.valueAction_(args[0]/127.0) }.defer }, 1, 1, -63353900);
MIDIdef.cc(\d, { |...args| args[0].postln; { ~ratMulView.valueAction_(ControlSpec(0.01, 1, 0, 0.01, 1).map(args[0]/127.0)); }.defer }, 0, 1, -63353900);
*/