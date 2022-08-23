{

	/*
	MIDIIn.connectAll
	MIDIFunc.trace(true)
	*/





	// Unique to the Morph, the Pressure button control sends repeated keystrokes with the repetition speed varying by pressure.





	/*
	We can currently offer 14 bit MIDI (16.384 valeurs) directly from the Morph or OSC using our SenselAPI.
	To use 14 bit midi, just select an area on the Overlay and then choose XYZ pad (or MPE if interested in MPE). Then you can choose what CC/Pitchbend/Aftertouch is sent for X, Y, and Pressure. If you choose a CC event and select 14-bit midi, you will send the higher 7 bits on the CC value and then the lower 7 bits on the CC value+32.
	To use OSC, you can use a GitHub project created by one of our customers that generates OSC based on the 16-bit data from the Morph. https://github.com/nosuchtim/MorphOsc. This, however, will not work with the Overlays and the Morph needs to be plugged into the computer where the code is being run.

	With 14 bit, the highest 7 bits are stored at the CC value and the lower 7 bits are stored at CC+32. So, in one example, CC 76 would still go between 0 and 127 but CC 108 will contain the sub divided values between each number. In other words, a CC76 value of 1 and CC108 value of 10 would be 138 (128*1+10). You could also think of the value as 1.078 (1+10/128).

	Some DAWs do not support 14 bit MIDI. We currently do not have a list of applications that support 14 bit MIDI and we have not tried it with SuperCollider.
	*/





	/*
	[20,21,22]+32
	[ 52, 53, 54 ]
	NoteOn/NoteOff 60

	MIDI Message Received:
	type: control
	src: 418047287
	chan: 0
	num: 20
	val: 94

	To use 14 bit midi, just select an area on the Overlay and then choose XYZ pad (or MPE if interested in MPE). Then you can choose what CC/Pitchbend/Aftertouch is sent for X, Y, and Pressure. If you choose a CC event and select 14-bit midi, you will send the higher 7 bits on the CC value and then the lower 7 bits on the CC value+32.

	The Morph's sensor area is 240 mm x 138.5 mm
	In default, Full Resolution Mode, it detects at 125 Hz (8 ms latency) and in High Speed Mode it detects at 500 Hs (2ms latency).
	The Morph has a 1.25mm sensor pitch with ~0.1mm tracking accuracy (6502 dpi) and ~20,000 sensors.
	The Morph can detect over 16,000 levels of pressure with anything weighing from 5g - 5kg.*/






	/*
	MIDIIn.connectAll;

	(

	~mx1a=0;
	~mx1b=0;
	~my1a=0;
	~my1b=0;
	~mz1a=0;
	~mz1b=0;

	~mx2a=0;
	~mx2b=0;
	~my2a=0;
	~my2b=0;
	~mz2a=0;
	~mz2b=0;

	a = MIDIFunc.cc({arg ...args;

	// args.postln;
	// args[0].postln;

	case
	{ args[1] == 20 }
	{ ~mx1a = args[0] }
	{ args[1] == 21 }
	{ ~my1a = args[0] }
	{ args[1] == 22 }
	{ ~mz1a = args[0] }
	{ args[1] == 52 }
	{ ~mx1b = args[0] }
	{ args[1] == 53 }
	{ ~my1b = args[0] }
	{ args[1] == 54 }
	{ ~mz1b = args[0] }

	{ args[1] == 23 }
	{ ~mx2a = args[0] }
	{ args[1] == 24 }
	{ ~my2a = args[0] }
	{ args[1] == 25 }
	{ ~mz2a = args[0] }
	{ args[1] == 55 }
	{ ~mx2b = args[0] }
	{ args[1] == 56 }
	{ ~my2b = args[0] }
	{ args[1] == 57 }
	{ ~mz2b = args[0] };

	/*if(~x1a.isNil, {~x1a=0});
	if(~x1b.isNil, {~x1b=0});
	if(~y1a.isNil, {~y1a=0});
	if(~y1b.isNil, {~y1b=0});
	if(~z1a.isNil, {~z1a=0});
	if(~z1b.isNil, {~z1b=0});

	if(~x2a.isNil, {~x2a=0});
	if(~x2b.isNil, {~x2b=0});
	if(~y2a.isNil, {~y2a=0});
	if(~y2b.isNil, {~y2b=0});
	if(~z2a.isNil, {~z2a=0});
	if(~z2b.isNil, {~z2b=0});*/

	~mx1 = (  ~mx1a + ( ~mx1b / 128) ).round(0.001);
	~my1 = (  ~my1a + ( ~my1b / 128) ).round(0.001);
	~mz1 = (  ~mz1a + ( ~mz1b / 128) ).round(0.001);
	~rect1 = [~mx1, ~my1, ~mz1];
	if  ( ~rect1 != ~prevRect1, { "rect1".postln; ~mOn1 = 1; "on1".postln; [~mx1, ~my1, ~mz1].postln; /*~nbOfServers.do { |s| ~controlBusFunc.(~controlBusTypeArg, ~x1.midicps, 5, s) };*/ } );
	if  ( ~mz1 == 0, { ~mOn1 = 0; "off1".postln; } );
	~prevRect1 = [~mx1, ~my1, ~mz1];


	~mx2 = (  ~mx2a + ( ~mx2b / 128) ).round(0.001);
	~my2 = (  ~my2a + ( ~my2b / 128) ).round(0.001);
	~mz2 = (  ~mz2a + ( ~mz2b / 128) ).round(0.001);
	~rect2 = [~mx2, ~my2, ~mz2];
	if  ( ~rect2 != ~prevRect2, { "rect2".postln; "on2".postln; [~mx2, ~my2, ~mz2].postln } );
	~prevRect2 = [~mx2, ~my2, ~mz2];

	});
	)

	a.free;
	*/





	(
		// MIDIIn.connectAll;

		MIDIClient.sources.do{ |d|

			if (d.device == "Sensel Morph" , {

				// Fonctions de contrôle repris du QNexus (_Init Midi Q2) ->

				~morphChannel = 5;

				~mBus = 5;
				~mZone = 1; // A l'initialisation par défaut, sinon nil au tout début lorsqu'on appuie sur le Morph
				~mZone2 = 1;

				~mFadeTime = 0.01; // Quelles sont les valeurs musicalement idéales pour ces paramètres ?

				~mkeyMinFadeTime = 0.0001;
				~mkeyMaxFadeTime = 0.07;

				/*~mFadeTime = 0;
				~mkeyMinFadeTime = 0;
				~mkeyMaxFadeTime = 0;*/

				/*
				~mkeyMinFadeTime = 0.0001;
				~mkeyMaxFadeTime = 0.0001;
				*/

				~mRtm = 0.077; // Plus vraiment utilisé car mappé en y avec les Min & Max ci-dessus

				~mkeyMinRtm = 0.2; // 2
				~mkeyMaxRtm = 0.09; // 0.01

				/*
				~mkeyMinRtm = 0.08; // 2
				~mkeyMaxRtm = 0.07; // 0.01
				*/

				// Variation d'1 centième de seconde

				/*
				~mRtm = 0.02;
				~mRtm = 0.06;
				~mRtm = 0.07;
				~mRtm = 0.077;
				~mRtm = 0.08;
				~mRtm = 0.09;
				*/

				// En deçà de 0.06 et au delà de 0.1, génération d'erreurs ->
				// *** ERROR: SynthDef temp__0-636440789_0 not found
				// FAILURE IN SERVER /s_new SynthDef not found


				// Faire un ~controlBusMFunc = { |argType = \rater, rate = 1, bus = 5, server = 0| avec piste en plus ou toutes ou séléction de serveurs (8 + 1 + 2 choix = 11 choix - par défaut respectivement sur les 2 serveurs)
				// Le fait que ~mRate soit identique pour les 2 macro-bandes, cela cree t-il des effets intéressants quand on agit sur les 2 bandes en même temps ??? à tester ???
				// It's not as good as a real controller, of course -- there's no tactile feedback


				// https://fr.wikipedia.org/wiki/Couleur_du_Web // -> // pour avoir les références des couleurs hexadécimales pour le Morph

				// ~controlMBusFunc.(\rater, 1, 5, 0)

				~controlMBusFunc = { |argType = \rater, rate = 1, server = 0, track|
					var bus; if ( server == 0, { bus = 0 }, { bus = 1 } );

					if ( track.isNil, { // "a".postln;

						~controlBusSynth[server][bus].source = { DC.kr(rate) }; // ~groups[~tracksValue].map(\rate, ~controlBus[5]);
						// Amélioration en agissant directement sur tout le groupe et pas de requête sur le numéro du Node
						~groups[server].select({ |i, index| index.even}).do { |i| i.map(argType /*~controlBusTypeArg*/ /*\rate*/ /*"rate"*/, ~controlBus[server][bus]) };

					});

					 ("Server" + server + "Speed Range:" + rate.asString).postln;

					/*{~trigAll == 0} // Track
					{
						~controlBusSynth[server][bus].source = { DC.kr(rate) }; // ~groups[~tracksValue].map(\rate, ~controlBus[5]);
						~groups[server][~tracksValue].map(argType /*~controlBusTypeArg*/ /*\rate*/, ~controlBus[server][bus]);
					}
					{~trigAll == 2} // ALL
					{
						~controlBusSynth[server][bus].source = { DC.kr(rate) }; // ~groups[~tracksValue].map(\rate, ~controlBus[5]);
						// Amélioration en agissant directement sur tout le groupe et pas de requête sur le numéro du Node
						~groups[server].select({ |i, index| index.even}).do { |i| i.map(argType /*~controlBusTypeArg*/ /*\rate*/ /*"rate"*/, ~controlBus[server][bus]) };
						~groups[0][]
					}
					{~trigAll == 1} // Other
					{
						var list;
						~controlBusSynth[server][4].source = { DC.kr(rate) }; // ~groups[~tracksValue].map(\rate, ~controlBus[5]);
						list = ~groups[server].select({ |i, index| index.even}); list.remove(~groups[server][~tracksValue]); /*list.postln;*/
						list.do { |i| i.map(argType /*~controlBusTypeArg*/ /*\rate*/, ~controlBus[server][bus]) };
					};*/
					// if (server == 0 and: {~printControlBusFunc == 1}, { (/*"Server" + server + */ "Speed Range:" + rate.asString).postln });

				};


				~mControlTask0 = Task ({
					~nbOfServers.do { |s| ~nbOfControlBus.do { |i| ~controlBusSynth[s][i].fadeTime_(~mFadeTime); } }; // A distinguer pour les 2 serveurs !!!
					inf.do {
						~mRate = ~mZone /*~mx1*/;
						~nbOfServers.do { |s| ~controlMBusFunc.(\rater, ~mRate, s) };
						// [~mRate + "@" + ~mRtm.round(0.01) + "sec"].postln;
						(~mRtm /*+0.001*/ ).wait;
					};
				});

				~mControlTask1 = Task ({
					~nbOfControlBus.do { |i| ~controlBusSynth[0][i].fadeTime_(~mFadeTime); }; // A distinguer pour les 2 serveurs !!!
					inf.do {
						~mRate = ~mZone /*~mx1*/;
						~controlMBusFunc.(\rater, ~mRate, 0);
						// [~mRate + "@" + ~mRtm.round(0.01) + "sec"].postln;
						(~mRtm /*+0.001*/ ).wait;
					};
				});

				~mControlTask2 = Task ({
					~nbOfControlBus.do { |i| ~controlBusSynth[1][i].fadeTime_(~mFadeTime); }; // A distinguer pour les 2 serveurs !!!
					inf.do {
						~mRate = ~mZone2 /*~mx1*/;
						~controlMBusFunc.(\rater, ~mRate, 1);
						// [~mRate + "@" + ~mRtm.round(0.01) + "sec"].postln;
						(~mRtm /*+0.001*/ ).wait;
					};
				});


				~nbOfMorphBands = 10 /*7*/;

				~rect= 0 ! ~nbOfMorphBands;
				~mOn = 0 ! ~nbOfMorphBands;
				~mx= 0 ! ~nbOfMorphBands;
				~mxa= 0 ! ~nbOfMorphBands;
				~mxb= 0 ! ~nbOfMorphBands;
				~my= 0 ! ~nbOfMorphBands;
				~mya= 0 ! ~nbOfMorphBands;
				~myb= 0 ! ~nbOfMorphBands;
				~mz= 0 ! ~nbOfMorphBands;
				~mza= 0 ! ~nbOfMorphBands;
				~mzb= 0 ! ~nbOfMorphBands;

				// MIDIIn.connectAll;
				// ~controlBusSynthFunc

				MIDIdef.noteOn(\noteOnM1, { /*arg ...args; args.postln*/
					~mOn[0] = 1; "mOn1".postln;
					if (~mControlTask1.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask1.reset; ~mControlTask1.play; "~mControlTask1 playing".postln});
				}, 60, ~morphChannel);

				MIDIdef.noteOff(\noteOffM1, { /*arg ...args; args.postln*/
					~mOn[0] = 0; "mOff1".postln;
					~mControlTask1.stop; "~mControlTask1 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 60, ~morphChannel);

				MIDIdef.noteOn(\noteOnM2, { /*arg ...args; args.postln*/
					~mOn[1] = 1; "mOn2".postln;
					if (~mControlTask1.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask1.reset; ~mControlTask1.play; "~mControlTask1 playing".postln});
				}, 61, ~morphChannel);

				MIDIdef.noteOff(\noteOffM2, { /*arg ...args; args.postln*/
					~mOn[1] = 0; "mOff2".postln;
					// ~mControlTask0.stop; "~mControlTask0 stopped".postln;
					~mControlTask1.stop; "~mControlTask1 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 61, ~morphChannel);

				MIDIdef.noteOn(\noteOnM3, { /*arg ...args; args.postln*/
					~mOn[2] = 1; "mOn3".postln;
					if (~mControlTask1.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask1.reset; ~mControlTask1.play; "~mControlTask1 playing".postln});
				}, 62, ~morphChannel);

				MIDIdef.noteOff(\noteOffM3, { /*arg ...args; args.postln*/
					~mOn[2] = 0; "mOff3".postln;
					// ~mControlTask0.stop; "~mControlTask0 stopped".postln;
					~mControlTask1.stop; "~mControlTask1 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 62, ~morphChannel);

				MIDIdef.noteOn(\noteOnM4, { /*arg ...args; args.postln*/
					~mOn[3] = 1; "mOn3".postln;
					if (~mControlTask2.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask2.reset; ~mControlTask2.play; "~mControlTask2 playing".postln});
				}, 63, ~morphChannel);

				MIDIdef.noteOff(\noteOffM4, { /*arg ...args; args.postln*/
					~mOn[3] = 0; "mOff3".postln;
					// ~mControlTask0.stop; "~mControlTask0 stopped".postln;
					~mControlTask2.stop; "~mControlTask2 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 63, ~morphChannel);

				MIDIdef.noteOn(\noteOnM5, { /*arg ...args; args.postln*/
					~mOn[4] = 1; "mOn3".postln;
					if (~mControlTask2.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask2.reset; ~mControlTask2.play; "~mControlTask2 playing".postln});
				}, 64, ~morphChannel);

				MIDIdef.noteOff(\noteOffM5, { /*arg ...args; args.postln*/
					~mOn[4] = 0; "mOff3".postln;
					// ~mControlTask0.stop; "~mControlTask0 stopped".postln;
					~mControlTask2.stop; "~mControlTask2 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 64, ~morphChannel);

				MIDIdef.noteOn(\noteOnM6, { /*arg ...args; args.postln*/
					~mOn[5] = 1; "mOn3".postln;
					if (~mControlTask2.isPlaying, {/*~mControlTask0.reset*/}, { ~mControlTask2.reset; ~mControlTask2.play; "~mControlTask2 playing".postln});
				}, 65, ~morphChannel);

				MIDIdef.noteOff(\noteOffM6, { /*arg ...args; args.postln*/
					~mOn[5] = 0; "mOff3".postln;
					// ~mControlTask0.stop; "~mControlTask0 stopped".postln;
					~mControlTask2.stop; "~mControlTask2 stopped".postln;
					// ~nbOfServers.do{ |s| ~controlBusSynthFunc[~controlBusSynth5FadeTime].value(s) }; // A distinguer pour les 2 serveurs !!!
					~controlBusSynthFunc[~controlBusSynth5FadeTime].value(0);
				}, 65, ~morphChannel);

				MIDIdef.noteOn(\noteOnM7, { /*arg ...args; args.postln*/
					~mOn[6] = 1; "mIndexOn1".postln; {~tracksView.valueAction_(0)}.defer;
				}, 66, ~morphChannel);

				MIDIdef.noteOff(\noteOffM7, { /*arg ...args; args.postln*/
					~mOn[6] = 0; "mIndexOff1".postln;
				}, 66, ~morphChannel);

				MIDIdef.noteOn(\noteOnM8, { /*arg ...args; args.postln*/
					~mOn[7] = 1; "mIndexOn2".postln; {~tracksView.valueAction_(4)}.defer;
				}, 67, ~morphChannel);

				MIDIdef.noteOff(\noteOffM8, { /*arg ...args; args.postln*/
					~mOn[7] = 0; "mIndexOff2".postln;
				}, 67, ~morphChannel);

				MIDIdef.noteOn(\noteOnM9, { /*arg ...args; args.postln*/
					~mOn[8] = 1; "mIndexOn3".postln;  {~tracksView.valueAction_(0)}.defer;
				}, 68, ~morphChannel);

				MIDIdef.noteOff(\noteOffM9, { /*arg ...args; args.postln*/
					~mOn[8] = 0; "mIndexOff3".postln;
				}, 68, ~morphChannel);

				MIDIdef.noteOn(\noteOnM10, { /*arg ...args; args.postln*/
					~mOn[9] = 1; "mIndexOn4".postln; {~tracksView.valueAction_(4)}.defer;
				}, 69, ~morphChannel);

				MIDIdef.noteOff(\noteOffM10, { /*arg ...args; args.postln*/
					~mOn[9] = 0; "mIndexOff4".postln;
				}, 69, ~morphChannel);


				MIDIdef.cc(\morph1, {arg ...args;

					// args.postln;

					case
					{~mOn[0] == 1}

					{
						case
						{ args[1] == 20 }
						{ ~mxa[0] = args[0] }
						{ args[1] == 21 }
						{ ~mya[0] = args[0] }
						{ args[1] == 22 }
						{ ~mza[0] = args[0] }
						{ args[1] == 52 }
						{ ~mxb[0] = args[0] }
						{ args[1] == 53 }
						{ ~myb[0] = args[0] }
						{ args[1] == 54 }
						{ ~mzb[0] = args[0] };

						~mx[0] = (  ~mxa[0] + ( ~mxb[0] / 128) ).round(0.001);
						~my[0] = (  ~mya[0] + ( ~myb[0] / 128) ).round(0.001);
						~mz[0] = (  ~mza[0] + ( ~mzb[0] / 128) ).round(0.001);
						~rect[0] = [~mx[0], ~my[0], ~mz[0]];
						~mZone = ~mx[0].lincurve(0, 128, 0, 10/*10000*/, 3);
						// ~mZone = ~mx[0] / 48.0;
						~mRtm = ~my[0].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[0].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect1 ->" + [~mx[0], ~my[0], ~mz[0]]).postln;

					}

					{~mOn[1] == 1}

					{
						case
						{ args[1] == 23 }
						{ ~mxa[1] = args[0] }
						{ args[1] == 24 }
						{ ~mya[1] = args[0] }
						{ args[1] == 25 }
						{ ~mza[1] = args[0] }
						{ args[1] == 55 }
						{ ~mxb[1] = args[0] }
						{ args[1] == 56 }
						{ ~myb[1] = args[0] }
						{ args[1] == 57 }
						{ ~mzb[1] = args[0] };

						~mx[1] = (  ~mxa[1] + ( ~mxb[1] / 128) ).round(0.001);
						~my[1] = (  ~mya[1] + ( ~myb[1] / 128) ).round(0.001);
						~mz[1] = (  ~mza[1] + ( ~mzb[1] / 128) ).round(0.001);
						~rect[1] = [~mx[1], ~my[1], ~mz[1]];
						// ~mZone =  ~mx[1].lincurve(0, 128, 0, 60/*10000*/, 3); // Tester
						// ~mZone =  (~mx[1].lincurve(0, 128, 0, 60/*10000*/, 3)).neg; // Tester
						~mZone = ~mx[1] / 3.0;
						~mRtm = ~my[1].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[1].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect2 ->" + [~mx[1], ~my[1], ~mz[1]]).postln;

					}

					{~mOn[2] == 1}

					{
						case
						{ args[1] == 26 }
						{ ~mxa[2] = args[0] }
						{ args[1] == 27 }
						{ ~mya[2] = args[0] }
						{ args[1] == 28 }
						{ ~mza[2] = args[0] }
						{ args[1] == 58 }
						{ ~mxb[2] = args[0] }
						{ args[1] == 59 }
						{ ~myb[2] = args[0] }
						{ args[1] == 60 }
						{ ~mzb[2] = args[0] };

						~mx[2] = (  ~mxa[2] + ( ~mxb[2] / 128) ).round(0.001);
						~my[2] = (  ~mya[2] + ( ~myb[2] / 128) ).round(0.001);
						~mz[2] = (  ~mza[2] + ( ~mzb[2] / 128) ).round(0.001);
						~rect[2] = [~mx[2], ~my[2], ~mz[2]];
						~mZone = ~mx[2].lincurve(0, 128, 0, 6000/*10000*/, 7);
						// ~mZone = ~mx[2] / 0.1;
						// 10.lincurve(0, 128, 0, 10000, 7)
						~mRtm = ~my[2].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[2].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect3 ->" + [~mx[2], ~my[2], ~mz[2]]).postln;

					}

					{~mOn[3] == 1}

					{
						case
						{ args[1] == 29 }
						{ ~mxa[3] = args[0] }
						{ args[1] == 30 }
						{ ~mya[3] = args[0] }
						{ args[1] == 31 }
						{ ~mza[3] = args[0] }
						{ args[1] == 61 }
						{ ~mxb[3] = args[0] }
						{ args[1] == 62 }
						{ ~myb[3] = args[0] }
						{ args[1] == 63 }
						{ ~mzb[3] = args[0] };

						~mx[3] = (  ~mxa[3] + ( ~mxb[3] / 128) ).round(0.001);
						~my[3] = (  ~mya[3] + ( ~myb[3] / 128) ).round(0.001);
						~mz[3] = (  ~mza[3] + ( ~mzb[3] / 128) ).round(0.001);
						~rect[3] = [~mx[3], ~my[3], ~mz[3]];
						~mZone2 = ~mx[3].lincurve(0, 128, 0, 1/*10000*/, -1);
						~mRtm = ~my[3].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[3].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect4 ->" + [~mx[3], ~my[3], ~mz[3]]).postln;

					}

					{~mOn[4] == 1}

					{
						case
						{ args[1] == 32 }
						{ ~mxa[4] = args[0] }
						{ args[1] == 33 }
						{ ~mya[4] = args[0] }
						{ args[1] == 34 }
						{ ~mza[4] = args[0] }
						{ args[1] == 64 }
						{ ~mxb[4] = args[0] }
						{ args[1] == 65 }
						{ ~myb[4] = args[0] }
						{ args[1] == 66 }
						{ ~mzb[4] = args[0] };

						~mx[4] = (  ~mxa[4] + ( ~mxb[4] / 128) ).round(0.001);
						~my[4] = (  ~mya[4] + ( ~myb[4] / 128) ).round(0.001);
						~mz[4] = (  ~mza[4] + ( ~mzb[4] / 128) ).round(0.001);
						~rect[4] = [~mx[4], ~my[4], ~mz[4]];
						// ~mZone2 = ~mx[4] / 3.0;
						~mZone2 = ~mx[4].lincurve(0, 128, 0, 3/*10000*/, -1);
						~mRtm = ~my[4].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[4].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect5 ->" + [~mx[4], ~my[4], ~mz[4]]).postln;

					}

					{~mOn[5] == 1}

					{
						case
						{ args[1] == 35 }
						{ ~mxa[5] = args[0] }
						{ args[1] == 36 }
						{ ~mya[5] = args[0] }
						{ args[1] == 37 }
						{ ~mza[5] = args[0] }
						{ args[1] == 67 }
						{ ~mxb[5] = args[0] }
						{ args[1] == 68 }
						{ ~myb[5] = args[0] }
						{ args[1] == 69 }
						{ ~mzb[5] = args[0] };

						~mx[5] = (  ~mxa[5] + ( ~mxb[5] / 128) ).round(0.001);
						~my[5] = (  ~mya[5] + ( ~myb[5] / 128) ).round(0.001);
						~mz[5] = (  ~mza[5] + ( ~mzb[5] / 128) ).round(0.001);
						~rect[5] = [~mx[5], ~my[5], ~mz[5]];
						~mZone2 = ~mx[5].lincurve(0, 128, 0, 6/*10000*/, -2);
						~mRtm = ~my[5].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						~mFadeTime = ~mz[5].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect6 ->" + [~mx[5], ~my[5], ~mz[5]]).postln;

					}

					{~mOn[6] == 1} // Index

					{
						case
						{ args[1] == 38 }
						{ ~mxa[6] = args[0] }
						{ args[1] == 39 }
						{ ~mya[6] = args[0] }
						{ args[1] == 40 }
						{ ~mza[6] = args[0] }
						{ args[1] == 70 }
						{ ~mxb[6] = args[0] }
						{ args[1] == 71 }
						{ ~myb[6] = args[0] }
						{ args[1] == 72 }
						{ ~mzb[6] = args[0] };

						~mx[6] = (  ~mxa[6] + ( ~mxb[6] / 128) ).round(0.001);
						~my[6] = (  ~mya[6] + ( ~myb[6] / 128) ).round(0.001);
						~mz[6] = (  ~mza[6] + ( ~mzb[6] / 128) ).round(0.001);
						~rect[6] = [~mx[6], ~my[6], ~mz[6]];
						~mZoneIndex1 = ~mx[6] / 128.0;
						{ ~gblSeqIndexView.valueAction_(~mZoneIndex1);
							if (~presetSeqTextViewG[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]].background == Color.red, {}, {~presetSeqTextViewG[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]].background_(Color.red) });
						}.defer;
						// ~mRtm = ~my[6].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						// ~mFadeTime = ~mz[6].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect7 ->" + [~mx[6], ~my[6], ~mz[6]]).postln;
						("mZoneIndex1 -> " +~gblSeqIndex[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]]).postln;

					}

					{~mOn[7] == 1} // Index

					{
						case
						{ args[1] == 41 }
						{ ~mxa[7] = args[0] }
						{ args[1] == 42 }
						{ ~mya[7] = args[0] }
						{ args[1] == 43 }
						{ ~mza[7] = args[0] }
						{ args[1] == 73 }
						{ ~mxb[7] = args[0] }
						{ args[1] == 74 }
						{ ~myb[7] = args[0] }
						{ args[1] == 75 }
						{ ~mzb[7] = args[0] };

						~mx[7] = (  ~mxa[7] + ( ~mxb[7] / 128) ).round(0.001);
						~my[7] = (  ~mya[7] + ( ~myb[7] / 128) ).round(0.001);
						~mz[7] = (  ~mza[7] + ( ~mzb[7] / 128) ).round(0.001);
						~rect[7] = [~mx[7], ~my[7], ~mz[7]];
						~mZoneIndex2 = ~mx[7] / 128.0;
						{ ~gblSeqIndexView.valueAction_(~mZoneIndex2);
							if (~presetSeqTextViewG[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]].background == Color.red, {}, {~presetSeqTextViewG[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]].background_(Color.red) });
						}.defer;
						// ~mRtm = ~my[7].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						// ~mFadeTime = ~mz[7].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect8 ->" + [~mx[7], ~my[7], ~mz[7]]).postln;
						("mZoneIndex2 -> " +~gblSeqIndex[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]]).postln;

					}

					{~mOn[8] == 1} // Index

					{
						case
						{ args[1] == 44 }
						{ ~mxa[8] = args[0] }
						{ args[1] == 45 }
						{ ~mya[8] = args[0] }
						{ args[1] == 46 }
						{ ~mza[8] = args[0] }
						{ args[1] == 76 }
						{ ~mxb[8] = args[0] }
						{ args[1] == 77 }
						{ ~myb[8] = args[0] }
						{ args[1] == 78 }
						{ ~mzb[8] = args[0] };

						~mx[8] = (  ~mxa[8] + ( ~mxb[8] / 128) ).round(0.001);
						~my[8] = (  ~mya[8] + ( ~myb[8] / 128) ).round(0.001);
						~mz[8] = (  ~mza[8] + ( ~mzb[8] / 128) ).round(0.001);
						~rect[8] = [~mx[8], ~my[8], ~mz[8]];
						~mZoneIndex3 = ~mx[8] / 128.0;
						{~gblSeqView.valueAction_([~mZoneIndex1, ~mZoneIndex3]);
							if (~presetSeqTextViewG[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]].background == Color.red, {}, {~presetSeqTextViewG[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]].background_(Color.red) });
						}.defer;
						// ~mRtm = ~my[8].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						// ~mFadeTime = ~mz[8].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect8 ->" + [~mx[8], ~my[8], ~mz[8]]).postln;
						("mZoneIndex3 -> " + ~gblSeqStart[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]] + ~gblSeqStop[0/*~tracksValue*/][~seqSeq[0/*~tracksValue*/]] ).postln;
						// utiliser ~seqsValue ou [~seqSeq[~tracksValue]] ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????

					}

					{~mOn[9] == 1} // Index

					{
						case
						{ args[1] == 47 }
						{ ~mxa[9] = args[0] }
						{ args[1] == 48 }
						{ ~mya[9] = args[0] }
						{ args[1] == 49 }
						{ ~mza[9] = args[0] }
						{ args[1] == 79 }
						{ ~mxb[9] = args[0] }
						{ args[1] == 80 }
						{ ~myb[9] = args[0] }
						{ args[1] == 81 }
						{ ~mzb[9] = args[0] };

						~mx[9] = (  ~mxa[9] + ( ~mxb[9] / 128) ).round(0.001);
						~my[9] = (  ~mya[9] + ( ~myb[9] / 128) ).round(0.001);
						~mz[9] = (  ~mza[9] + ( ~mzb[9] / 128) ).round(0.001);
						~rect[9] = [~mx[9], ~my[9], ~mz[9]];
						~mZoneIndex4 = ~mx[9] / 128.0;
						{~gblSeqView.valueAction_([~mZoneIndex2, ~mZoneIndex4]);
							if (~presetSeqTextViewG[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]].background == Color.red, {}, {~presetSeqTextViewG[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]].background_(Color.red) });
						}.defer;
						// ~mRtm = ~my[9].linlin(0, 128, ~mkeyMinRtm, ~mkeyMaxRtm);
						// ~mFadeTime = ~mz[9].linlin(0, 128, ~mkeyMinFadeTime, ~mkeyMaxFadeTime);

						// ("rect7 ->" + [~mx[9], ~my[9], ~mz[9]]).postln;
						("mZoneIndex4 -> " + ~gblSeqStart[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]] + ~gblSeqStop[4/*~tracksValue*/][~seqSeq[4/*~tracksValue*/]] ).postln;
						// utiliser ~seqsValue ou [~seqSeq[~tracksValue]] ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????

					}

				}, chan: ~morphChannel );

				"Sensel Morph connected".postln;

			});
		};

	);

}.value;
