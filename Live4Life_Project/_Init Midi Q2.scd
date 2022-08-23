/*
~qController =MKtl('qnxs0', "keith-mcmillen-qunexus_port1_AB");
~qController = MKtl('qnxs0');
~qController.gui;
*/



/*
~qController.elements;
~qController.elements.printAll;
~qController.trace(true);
~qController.trace(false);

~qController.elementsDict.size;
~qController.postElements;

~qkey_24 = ~qController.elementAt(\keyOn, 24)
~qkey_24 = ~qController.elements.at(\keyOn_24) // ?
~qkey_24.action_({ |v| v.rawValue.postln; }); // donne la vélocité
~qkey_24.action_({ |v| v.value.postln; }); // donne le tilt
*/



(
// KEYS à droite 2
/*
~qkeyOn_48 = ~qController.elementAt(\keyOn, 48);
~qkeyOn_50 = ~qController.elementAt(\keyOn, 50);
~qkeyOn_52 = ~qController.elementAt(\keyOn, 52);
~qkeyOn_53 = ~qController.elementAt(\keyOn, 53);
~qkeyOn_55 = ~qController.elementAt(\keyOn, 55);
~qkeyOn_57 = ~qController.elementAt(\keyOn, 57);
~qkeyOn_59 = ~qController.elementAt(\keyOn, 59);
~qkeyOn_60 = ~qController.elementAt(\keyOn, 60);
~qkeyOn_62 = ~qController.elementAt(\keyOn, 62);
~qkeyOn_64 = ~qController.elementAt(\keyOn, 64);
~qkeyOn_65 = ~qController.elementAt(\keyOn, 65);
~qkeyOn_67 = ~qController.elementAt(\keyOn, 67);
~qkeyOn_69 = ~qController.elementAt(\keyOn, 69);
~qkeyOn_71 = ~qController.elementAt(\keyOn, 71);
~qkeyOn_72 = ~qController.elementAt(\keyOn, 72); // en bas à droite
~qkeyOn_49 = ~qController.elementAt(\keyOn, 49);
~qkeyOn_51 = ~qController.elementAt(\keyOn, 51);
~qkeyOn_54 = ~qController.elementAt(\keyOn, 54);
~qkeyOn_56 = ~qController.elementAt(\keyOn, 56);
~qkeyOn_58 = ~qController.elementAt(\keyOn, 58);
~qkeyOn_61 = ~qController.elementAt(\keyOn, 61);
~qkeyOn_63 = ~qController.elementAt(\keyOn, 63);
~qkeyOn_66 = ~qController.elementAt(\keyOn, 66);
~qkeyOn_68 = ~qController.elementAt(\keyOn, 68);
~qkeyOn_70 = ~qController.elementAt(\keyOn, 70);

~qkeyOff_48 = ~qController.elementAt(\keyOff, 48);
~qkeyOff_50 = ~qController.elementAt(\keyOff, 50);
~qkeyOff_52 = ~qController.elementAt(\keyOff, 52);
~qkeyOff_53 = ~qController.elementAt(\keyOff, 53);
~qkeyOff_55 = ~qController.elementAt(\keyOff, 55);
~qkeyOff_57 = ~qController.elementAt(\keyOff, 57);
~qkeyOff_59 = ~qController.elementAt(\keyOff, 59);
~qkeyOff_60 = ~qController.elementAt(\keyOff, 60);
~qkeyOff_62 = ~qController.elementAt(\keyOff, 62);
~qkeyOff_64 = ~qController.elementAt(\keyOff, 64);
~qkeyOff_65 = ~qController.elementAt(\keyOff, 65);
~qkeyOff_67 = ~qController.elementAt(\keyOff, 67);
~qkeyOff_69 = ~qController.elementAt(\keyOff, 69);
~qkeyOff_71 = ~qController.elementAt(\keyOff, 71);
~qkeyOff_72 = ~qController.elementAt(\keyOff, 72); // en bas à droite
~qkeyOff_49 = ~qController.elementAt(\keyOff, 49);
~qkeyOff_51 = ~qController.elementAt(\keyOff, 51);
~qkeyOff_54 = ~qController.elementAt(\keyOff, 54);
~qkeyOff_56 = ~qController.elementAt(\keyOff, 56);
~qkeyOff_58 = ~qController.elementAt(\keyOff, 58);
~qkeyOff_61 = ~qController.elementAt(\keyOff, 61);
~qkeyOff_63 = ~qController.elementAt(\keyOff, 63);
~qkeyOff_66 = ~qController.elementAt(\keyOff, 66);
~qkeyOff_68 = ~qController.elementAt(\keyOff, 68);
~qkeyOff_70 = ~qController.elementAt(\keyOff, 70);
*/



// Initialisation des touches (code ci-dessous remplace le code ci-dessus)

~nbQKeys = 85;
~qkeysOn = 0 ! ~nbQKeys;
~qkeysOff = 0 ! ~nbQKeys;
~nbQKeys.do { |i| ~qkeysOn[i] = ~qController.elementAt(\pk, i, 0); };
~nbQKeys.do { |i| ~qkeysOff[i] = ~qController.elementAt(\pk, i, 1); };
/*~nbQKeys.do { |i| ~qkeysOn[i] = ~qController.elAt(\pk, i)[0]; };
~nbQKeys.do { |i| ~qkeysOff[i] = ~qController.elAt(\pk, i)[1] };
// ~qController.elAt(\pk, 0)[1]*/

/*
~qController.gui
~qController.elAt.action = { |el| [el.name, el.value].postln };

~qController.elementGroup[\pk][0].action { |v| v.value.postln };
~qController.elAt(\pk, 0)
~qkeysOn[0].action_({ |v| v.postln; });
*/

~qmonotouch = ~qController.elementAt(\monotouch); // ???




// Initialisation des valeurs pour les fonctions

~qBus = 5;
~qkeyMinRtm = 0.077; // 2
~qkeyMaxRtm = 0.066; // 0.01
~qkeysVal = 0 ! ~nbQKeys;



// Fonctions de contrôle

// ~qControlTask = Task ({ 1.do { ~controlBusFunc.(\rate, ~qRate, ~qBus); /*~qRtm.wait*/ }; });
~qControlTask = Task ({ inf.do { ~nbOfServers.do { |s| ~controlBusFunc.(\rater, ~qRate, ~qBus, s) }; (~qRtm/*+0.001*/).wait }; });

~qControlOnFunction = { | nb, rate | ~qkeysVal[nb] = 1; ~qRate = rate; [~qRate + "@" + ~qRtm.round(0.01) + "sec"].postln; if (~qControlTask.isPlaying, {/*~qControlTask.reset*/}, { ~qControlTask.play; "~qControlTask playing".postln}); };

~qControlOffFunction = { | nb | ~qkeysVal[nb] = 0; if ( ~qkeysVal.includes(1), {}, { ~qControlTask.stop; "~qControlTask stopped".postln }); };

/*
~qControlOnFunction = { | nb, rate | ~qRate = rate; [~qRtm, ~qRate].postln; ~qkeysOn[nb] = 1; if (~qControlTask.isPlaying, {~qControlTask.stop; ~qControlTask.play;}, { ~qControlTask.play; }); };
~qControlOffFunction = { | nb | ~qkeysOn[nb] = 0; if ( ~qkeysOn.includes(1), {}, { ~qControlTask.stop; "~qControlTask stopped".postln }); };
*/



// ~qkeyOn_48.action_({ |v| ~qRtm = v.rawValue.postln; })
// 1.reciprocal
// 127.reciprocal
// 127.linlin(1, 127, 1, 0.05)




// ~qkeysOn[0].action_({ |v| fork { inf.do { v.value.postln; v.rawValue.postln; 0.1.wait} }; });
// ~qkeysOn[0].class
~qkeysOn[0].action_({ |v| /*fork {v.value.postln; 0.01.wait};*/ ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(0, 0.000000001); });
~qkeysOn[2].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(2, 0.00000001); });
~qkeysOn[4].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(4, 0.0000001); });
~qkeysOn[5].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(5, 0.000001); });
~qkeysOn[7].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(7, 0.00001); });
~qkeysOn[9].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(9, 0.0001); });
~qkeysOn[11].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(11, 0.0002); });
~qkeysOn[12].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(12, 0.0003); });
~qkeysOn[14].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(14, 0.0004); });
~qkeysOn[16].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(16, 0.0005); });
~qkeysOn[17].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(17, 0.0006); });
~qkeysOn[19].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(19, 0.0007); });
~qkeysOn[21].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(21, 0.0008); });
~qkeysOn[23].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(23, 0.0009); });
// ~qkeysOn[24]

~qkeysOn[1].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(1, 0.001); });
~qkeysOn[3].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(3, 0.002); });
~qkeysOn[6].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(6, 0.003); });
~qkeysOn[8].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(8, 0.004); });
~qkeysOn[10].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(10, 0.005); });
~qkeysOn[13].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(13, 0.006); });
~qkeysOn[15].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(15, 0.007); });
~qkeysOn[18].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(18, 0.008); });
~qkeysOn[20].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(20, 0.009); });
~qkeysOn[22].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(22, 0.01); });


// 1
~qkeysOn[24].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(24, 0.001); });
~qkeysOn[26].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(26, 0.01); });
~qkeysOn[28].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(28, 0.02); });
~qkeysOn[29].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(29, 0.03); });
~qkeysOn[31].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(31, 0.04); });
~qkeysOn[33].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(33, 0.05); });
~qkeysOn[35].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(35, 0.06); });
~qkeysOn[36].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(36, 0.07); });
~qkeysOn[38].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(38, 0.08); });
~qkeysOn[40].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(40, 0.09); });
~qkeysOn[41].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(41, 0.1); });
~qkeysOn[43].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(43, 0.25); });
~qkeysOn[45].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(45, 0.5); });
~qkeysOn[47].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(47, 1); });
// ~qkeysOn[48]

~qkeysOn[25].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(25, 2); });
~qkeysOn[27].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(27, 4); });
~qkeysOn[30].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(30, 6); });
~qkeysOn[32].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(32, 8); });
~qkeysOn[34].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(34, 10); });
~qkeysOn[37].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(37, 20); });
~qkeysOn[39].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(39, 40); });
~qkeysOn[42].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(42, 80); });
~qkeysOn[44].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(44, 160); });
~qkeysOn[46].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(46, 1000); });


// 2
~qkeysOn[48].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(48, 0.001); });
~qkeysOn[50].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(50, 0.01); });
~qkeysOn[52].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(52, 0.1); });
~qkeysOn[53].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(53, 0.2); });
~qkeysOn[55].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(55, 0.4); });
~qkeysOn[57].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(57, 0.6); });
~qkeysOn[59].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(59, 0.8); });
~qkeysOn[60].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(60, 1); });
~qkeysOn[62].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(62, 1.5); });
~qkeysOn[64].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(64, 2); });
~qkeysOn[65].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(65, 3); });
~qkeysOn[67].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(67, 4); });
~qkeysOn[69].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(69, 5); });
~qkeysOn[71].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(71, 10); });
~qkeysOn[72].action_({ |v| /*~qRtm = v.rawValue.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(14, 0.01);*/ if ( ~legLoop[~tracksValue][~seqsValue] == 1, { "No Loop".postln; ~legLoopView.valueAction_(0) }, {"Loop activated".postln; ~legLoopView.valueAction_(1) }); }); // ???

~qkeysOn[49].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(49, 20); });
~qkeysOn[51].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(51, 40); });
~qkeysOn[54].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(54, 60); });
~qkeysOn[56].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(56, 80); });
~qkeysOn[58].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(58, 100); });
~qkeysOn[61].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(61, 200); });
~qkeysOn[63].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(63, 400); });
~qkeysOn[66].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(66, 800); });
~qkeysOn[68].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(68, 1000); });
~qkeysOn[70].action_({ |v| ~qRtm = v.deviceValue/*rawValue*/.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); ~qControlOnFunction.(70, 10000); });

// ~qMonotouch.action_({ |v| ~qRtm = v.rawValue.linlin(1, 127, ~qkeyMinRtm, ~qkeyMaxRtm); /* ~qControlOnFunction.(70, 10000);*/ v.value.postln }); // To arrange


~nbQKeys.do { |i| ~qkeysOff[i].action_({ |v| if (i == 72, {}, {~qControlOffFunction.(i) }); });};

"QuNexus connected".postln;



/*
~qkeyOff_25.action_({ |v| ~qControlOffFunction.(25); });
~qkeyOff_27.action_({ |v| ~qControlOffFunction.(26); });
~qkeyOff_30.action_({ |v| ~qControlOffFunction.(27); });
~qkeyOff_32.action_({ |v| ~qControlOffFunction.(28); });
~qkeyOff_34.action_({ |v| ~qControlOffFunction.(29); });
~qkeyOff_37.action_({ |v| ~qControlOffFunction.(30); });
~qkeyOff_39.action_({ |v| ~qControlOffFunction.(31); });
~qkeyOff_42.action_({ |v| ~qControlOffFunction.(32); });
~qkeyOff_44.action_({ |v| ~qControlOffFunction.(33); });
~qkeyOff_46.action_({ |v| ~qControlOffFunction.(34); });

~qkeyOff_48.action_({ |v| ~qControlOffFunction.(0); });
~qkeyOff_50.action_({ |v| ~qControlOffFunction.(1); });
~qkeyOff_52.action_({ |v| ~qControlOffFunction.(2); });
~qkeyOff_53.action_({ |v| ~qControlOffFunction.(3); });
~qkeyOff_55.action_({ |v| ~qControlOffFunction.(4); });
~qkeyOff_57.action_({ |v| ~qControlOffFunction.(5); });
~qkeyOff_59.action_({ |v| ~qControlOffFunction.(6); });
~qkeyOff_60.action_({ |v| ~qControlOffFunction.(7); });
~qkeyOff_62.action_({ |v| ~qControlOffFunction.(8); });
~qkeyOff_64.action_({ |v| ~qControlOffFunction.(9); });
~qkeyOff_65.action_({ |v| ~qControlOffFunction.(10); });
~qkeyOff_67.action_({ |v| ~qControlOffFunction.(11); });
~qkeyOff_69.action_({ |v| ~qControlOffFunction.(12); });
~qkeyOff_71.action_({ |v| ~qControlOffFunction.(13); });
// ~qkeyOff_72.action_({ |v| /*~qControlOffFunction.(14);*/ });
~qkeyOff_49.action_({ |v| ~qControlOffFunction.(15); });
~qkeyOff_51.action_({ |v| ~qControlOffFunction.(16); });
~qkeyOff_54.action_({ |v| ~qControlOffFunction.(17); });
~qkeyOff_56.action_({ |v| ~qControlOffFunction.(18); });
~qkeyOff_58.action_({ |v| ~qControlOffFunction.(19); });
~qkeyOff_61.action_({ |v| ~qControlOffFunction.(20); });
~qkeyOff_63.action_({ |v| ~qControlOffFunction.(21); });
~qkeyOff_66.action_({ |v| ~qControlOffFunction.(22); });
~qkeyOff_68.action_({ |v| ~qControlOffFunction.(23); });
~qkeyOff_70.action_({ |v| ~qControlOffFunction.(24); });*/
);






// add a global noteOn function
/*~qController.global.put(\noteOn, MFunc([ \debug, { |...args| [\noteOnGlob, args].postln }]));
~qController.global[\noteOn].add(\note1, { |chan, note, vel|
	v.put(note, [\freq, note.midicps, \amp, (vel/127) ].postln);
});

// and a global noteOff function
~qController.global[\noteOff] = MFunc();
~qController.global[\noteOff].add(\note1, { |chan, note| v.release(note); });

~qController[\cc] = MFunc();
z.global[\cc].add(\mod, { |chan, ccnum, val|
	if (ccnum == 1) { v.setAt(chan, \amp, val/127) };
});*/


