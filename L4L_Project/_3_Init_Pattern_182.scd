(

~seqComp2.visibleOrigin_(0@78);

~lagTime = 0 /*.05*/; // voire lag & SynthDef dans Rates - voire l'utilisation des lag dans les synthés principaux comme les lecteurs de fichiers sons - plus utilisé

if (~updateTime.isNil, {~updateTime = 0.1} ); // Update time de la GUI si non donné

if (~lemurAdress1.isNil, {~lemurConnected1 = 0});
if (~lemurAdress2.isNil, {~lemurConnected2 = 0});



// ~lemurNewSeqs = 0 ! ~nbOfTracksX2; // déjà déclaré dans la GUI

if (~lemurConnected2 == 1, {
	~secondLemurRawTrack = 2; // nécessaire de le déclarer au préalable avant le pattern - et réinitialisé dans le Lemur et pattern aussi
	~secondLemurX2Track = 4; // nécessaire de le déclarer au préalable avant le pattern - et réinitialisé dans le Lemur et pattern aussi
	~prevLemur2Track = 4;
});





// TempoClock.default.tempo = 1;
// ~gblTempo ? ~gblTempo = TempoClock(1);
// permet d'éviter d'utiliser ~gblTempo.permanent_(1); car provoque une erreur avec arrêt brutal P+shift+.

~gblTempo = TempoClock(2, queueSize: 8192).permanent_(true); // semble avoir une incidence de quelques points sur le cpu ??? Checker valeur idéale ??????????????????????
// permanent sets whether the clock will survive cmd-period // false by default

// TempoClock.default_(TempoClock.new(queueSize: 8192).permanent_(true))
// Put Into your startup.rtf file. // check Post on setting queue size





// Préparation des données pour la position de OutR dans le Pattern
// Réduction de 1 car ajout de 1 dans le pattern
case
{~numChannels == 2}
{~unQuart = 0; ~oppo = 0}
{~numChannels == 4}
{~unQuart = 1; ~oppo = 2}
{~numChannels == 5}
{~unQuart = 1; ~oppo = 2}
{~numChannels == 7}
{~unQuart = 2; ~oppo = 3}
{~numChannels == 8}
{~unQuart = 2; ~oppo = 4}
{~numChannels == 16}
{~unQuart = 3; ~oppo = 5}
{~numChannels == 24}
{~unQuart = 2; ~oppo = 4}
{~numChannels == 32}
{~unQuart = 3; ~oppo = 6} // très arbitraire car dépend de la couronne utilisée - l'attribuer en fonction du nb de HP et de la couronne utilisée ??????
{~numChannels == 64} // ???
{~unQuart = 3; ~oppo = 6}
{~numChannels == 96} // ???
{~unQuart = 3; ~oppo = 6}
{~numChannels == 128} // ???
{~unQuart = 3; ~oppo = 6};

~outList = (1..~numChannels);





// Réattribution des sorties exclusivement pour le dôme de 32 HP avec la carte MOTU non modifiable
/*
case
{~numChannels == 2}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 4}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 5}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 7}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 8}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 16}
{~outsOrganization = (0..~numChannels)}
{~numChannels == 22}
{~outsOrganization = (0..~numChannels)}
{~numChannelsConfig == "32-Dome-12-10-8-2"}
{~outsOrganization = (0..~numChannels)}
{~numChannelsConfig == "32-Dome-12-10-8-2-Motu"}
{~outsOrganization = // (0..~numChannels)
[ 0, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22, 13, 14, 15, 16, 17, 18, 19, 20, 25, 26, 27, 28, 29, 30, 31, 32, 23, 24 ]
}
{~numChannelsConfig == "64-CentreClock"}
{~outsOrganization = (0..~numChannels)}
{~numChannelsConfig == "128-CentreClock"}
{~outsOrganization = (0..~numChannels)};
*/

if (~numChannelsConfig == "32-Dome-12-10-8-2-Motu", {
	~outsOrganization = // (0..~numChannels)
	[ 0, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22, 13, 14, 15, 16, 17, 18, 19, 20, 25, 26, 27, 28, 29, 30, 31, 32, 23, 24 ];
},{
	~outsOrganization = (0..~numChannels);
});







// Préparation des données pour la position des séquences OutL dans le Pattern - à améliorer
~prevNb = 0 ! ~nbOfTracksX2; // à réinitialiser à 0 au lancement de la piste ???

// Préparation des données pour la position des séquences Spa dans le Pattern - à améliorer
~prevNb2 = 0 ! ~nbOfTracksX2;

// Préparation des données pour prepseq -> switch entre lecture continue et remise à 0 - mis dans la GUI dans ~playControlView - necessaire de le garder ?
// ~infini = 0 ! ~nbOfTracksX2;





/*
~foaBus = Bus.audio(s, 4); // allocate four channels for routing
~decoderNote = ~foaDecoder.note(addAction: \addToTail).inBus_(~foaBus).play;
~foaBus.free
~foaBus.rate
*/





// peut engendrer un supplément de CPU d'environ 10% si fichier Pattern lancé plusieurs fois ?????????
// -> ok si lancé correctement à partir du starter ci-dessus et non du fichier "Pattern" à cause du SkipJack.stopAll; z.start;
/*{*/

SkipJack.stopAll; /*0.2.wait;*/
if (~visualizeLevels == "SpatioScope" and: { ~numChannelsConfig != "2" } /*and: {~numChannelsFX != 16}*/, {~spatioScopePlayer.stop; ~spatioScopePlayer.start});
/*}.fork(AppClock);*/



~nbOfTracks.do { |tr| ~volControlSetRout[tr].play; }; // Routine pour changement de SynthDef (NodeProxy) pour le volume des pistes





// lancé dans le pattern pour ne pas avoir besoin de relancer la GUI si P+shift+.
// ~fxNb.do { |i, pos| ~fxSynth2[i] = Synth.tail(s, \inout, [\in, ~fxbNb[pos], \out, ~fxOut[pos]]) };
// Mise en place d'effets multi-canaux et non multi-monos
// ~numEffects.do { |i| ~fxSynth2[i] = Synth.tail(s, \inout, [\in, (i+1)*10, \out, 0]) };
// Utilisation de register (NodeWatcher) pour empêcher de relancer le synthé si .isRunnnig == true
if ( ~fxSynth2[0][0] == 0 or: {try {~fxSynth2[0][0].isRunning} == false}, {
	if ( ~serverFX == 0, {
		~numEffects.do { |i| ~fxSynth2[0][i] = Synth.tail(~server1, \inout, [\in, ((i+1)*~fxMulChannel)+~fxSeverChannelAdd, \out, 0]).register };
	},{
		~numEffects.do { |i| ~fxSynth2[0][i] = Synth.tail(~serverFX1, \inout, [\in, ((i+1)*~fxMulChannel)+~fxSeverChannelAdd, \out, 0]).register };
	});
});

if (~nbOfServers == 2, {
	if ( ~fxSynth2[1][0] == 0 or: {try {~fxSynth2[1][0].isRunning} == false}, {
		if ( ~serverFX == 0, {
			~numEffects.do { |i| ~fxSynth2[1][i] = Synth.tail(~server2, \inout, [\in, ((i+1)*~fxMulChannel)+~fxSeverChannelAdd, \out, 0]).register };
		},{
			~numEffects.do { |i| ~fxSynth2[1][i] = Synth.tail(~serverFX2, \inout, [\in, ((i+1)*~fxMulChannel)+~fxSeverChannelAdd, \out, 0]).register };
		});
	});
});

if (~serverFX == 1, {
	~fxSynthINOUT1 = Synth.tail(~serverFX1, \inout2, [\in, 0, \out, 0]);
	if (~nbOfServers == 2, {
		~fxSynthINOUT2 = Synth.tail(~serverFX2, \inout2, [\in, 0, \out, 0]);
	});
});






~busses = ((0..~nbOfTracks-1)!2).flop.flat; // Pour le création des busVolume qui gérent le volume de chaque piste dans le pattern
// Création des bus de volume déjà créées dans la GUI mais au cas ou CmdPeriod soit déclenché - pas nécessaire -> bus conservé malgré le CmdPeriod ??? - à supprimer OK
/*~tracksList.collect {|tr| ~volumeBus[tr] = Bus(\control, index: (100+tr), numChannels: 1)};
~tracksList.collect {|tr| ~volumeBus2[tr] = Bus(\control, index: (110+tr), numChannels: 1)};
~globalBus = Bus(\control, index: 10, numChannels: 1);*/ // PLus utilisé ???





// Numéro des bus de contrôle Rat...
~controlBus0 = 49 /*45*/;
~controlBus1 = 50 /*46*/;
~controlBus2 = 51 /*47*/;
~controlBus3 = 52 /*48*/;
~controlBus4 = 53 /*49*/;
~controlBus5 = 54 /*50*/;





// Création des bus de controle pour modifier dynamiquement les séquences des modules
/*
~bus1 = Bus(\control, index: 120, numChannels: 1);
~bus1Synth = NodeProxy.for(~bus1); // pas besoin de référence au control & nb de canaux car celle-ci car reprend les infos du bus
~bus1Synth.fadeTime = 5;
~bus1Synth.source = { SinOsc.kr(5, 0, 0.2, 5) };
*/
// manière adaptée pour la création de multiples bus - modifier en conséquence les bus de volume ci-dessus XXXXXXXXX

// Ne lance les bus et NodeProxys ci-dessous que s'ils n'existent pas déjà
// Les bus audio et control sont différenciés même avec le même index ??????????????????
if ( ~controlBusSynth.isNil or: {/*~controlBusSynth[0].source*/ try {~controlBusSynth[0][0].isPlaying } == false }, {

	~controlBus = 0 ! 2;
	~controlBusSynth = 0 ! 2;

	if (~server2.notNil, {
		~controlBus[0] = ~nbOfControlBus.collect {|i| Bus(\control, server: ~server1, index: (120+i), numChannels: 1) }; // n'a rien à voir avec les Bus Audio - refaire l'allocation des bus XXXXXXXXXXXXXXXXXX
		~controlBus[1] = ~nbOfControlBus.collect {|i| Bus(\control, server: ~server2, index: (120+i), numChannels: 1) };
		~nbOfServers.do { |s|
			try { ~nbOfControlBus.collect {|i| ~controlBusSynth[s][i].clear } };
			~controlBusSynth[s] = ~nbOfControlBus.collect {|i| NodeProxy.for(~controlBus[s][i]).fadeTime_(0).source = { DC.kr(1.0) } };
		};
		// A positionner à un autre endroit ???
		// ~currentControlBusSynthPreset = NdefPreset(Ndef(\a));
		// obligé de le dissocier pour permettre un update des sliders de la NdefGui
		~currentControlBusSynthPreset1 = NodeProxyPreset(~controlBusSynth[0][5]);
		~currentControlBusSynthPreset2 = NodeProxyPreset(~controlBusSynth[0][5]);
		~currentControlBusSynthPreset3 = NodeProxyPreset(~controlBusSynth[0][5]);
		/*
		~controlBusSynth[5].clear;
		*/
	},{
		~controlBus[0] = ~nbOfControlBus.collect {|i| Bus(\control, server: ~server1, index: (120+i), numChannels: 1) };
		try { ~nbOfControlBus.collect {|i| ~controlBusSynth[0][i].clear } };
		~controlBusSynth[0] = ~nbOfControlBus.collect {|i| NodeProxy.for(~controlBus[0][i]).fadeTime_(0).source = { DC.kr(1.0) } };
	});
});
// Pourquoi le nb de "synthé ajoutés" augmente à chaque fois que celà est lancé -> voire d dans le server qui augmente de 6 ??? -> car Nodeproxy jamais libéré
// Nécessité de libérer les bus et Nodeproxy lorsque la GUI est fermée avec le free du Nodeproxy -> OK
// ~controlBus[0].get;
// ~controlBusSynth[0].bus;
// ~controlBus[0].free; ~controlBusSynth[0].clear;





// Pour regrouper tous les synthés d'une track dans un groupe
// Les groupes ne survivent pas à CmdPeriod -> plus présent dans le NodeTree
// ~tracksGroup = Group.new;
// Ne lance les groupes ci-dessous que s'ils n'existent pas déjà
if (Server.program.split($/).last == "supernova", {

	// ~groups = {Group.new} ! ~nbOfTracks;
	~parGroup = ParGroup.new;
	if ( ~groups.isNil or: {/*~controlBusSynth[0].source*/ try {~groups[0].isPlaying } == false }, {
		~groups = {Group.new(~parGroup).register} ! ~nbOfTracks;
		~groups = (~groups !2).flop.flat;
	});

},{

	if (~server2.notNil, {

		if ( ~groups.isNil or: {/*~controlBusSynth[0].source*/ try {~groups[0][0].isPlaying } == false }, {
			~groups = 0 ! 2;
			~groups[0] = {Group.new(~server1).register} ! ~nbOfTracks;
			~groups[1] = {Group.new(~server2).register} ! ~nbOfTracks;
			~groups[0] = (~groups[0] !2).flop.flat;
			~groups[1] = (~groups[1] !2).flop.flat;
		});

	},{

		if ( ~groups.isNil or: {/*~controlBusSynth[0].source*/ try {~groups[0][0].isPlaying } == false }, {
			~groups = 0 ! 2;
			~groups[0] = {Group.new(~server1).register} ! ~nbOfTracks;
			~groups[0] = (~groups[0] !2).flop.flat;
		});

	});

});


/*
~groups = nil
~groups = {Group.new(~server1).register} ! ~nbOfTracks
~groups = (~groups ! 2).flop.flat;

(
~groups[0].as(Set).do {|i| i.free }; // libération des groupes
~groups[1].as(Set).do {|i| i.free }; // libération des groupes
)*/









// Pour collecter les ID plus utilisé - NEW
/*~listID = List() ! ~nbOfTracksX2; // Bookkeeping des NodeID dans le langage sans avoir besoin d'interroger le serveur
// constructor for Function to be used in Pattern
// Notification must be on of course
~getID = { |list|
{ |event|
thisThread.clock.sched(0, {
event[\id].do { |id|
OSCFunc({ list.add(id) },
'/n_go', s.addr, nil, [id]).oneShot;
OSCFunc({ list.remove(id) },
'/n_end', s.addr, nil, [id]).oneShot;
};
})
}
};*/

// plus utilisé - OLD
/*~getID = { |list|
{ |event|
thisThread.clock.sched(0, {
event[\id].do { |id|
list.add(event[\id][0]);
// OSCdef(\removeListID, { list.remove(id) }, '/n_end', s.addr, nil, [id]).oneShot;
OSCFunc({ list.remove(id) }, '/n_end', s.addr, nil, [id]).oneShot;
// if(s.serverRunning/*.not*/,{list.add(event[\id][0]); OSCFunc({ list.remove(id) }, '/n_end', s.addr, nil, [id]).oneShot});
// ne change pas le blocage de l'OSC même si performances un peu améliorées
};
})
}
};
// setter Function
~setID = { |list, key, func|
list.do { |id,i| s.sendMsg(\n_set, id, key, func.(i)) }
};*/










// see Mail : Changing the value of an environment variable by passing it as an argument within a function
// Pour pouvoir lire et assigner des variables à tout moment et pas seulement à la lecture de la fonction

/*
( // pas utilisé
~getV = { |key, track, seq, envir|
// envir = envir ?? { currentEnvironment };
envir = currentEnvironment;
envir[key][track][seq];
}
);

~getV.(\rat, 0, 0);

( // test
~getV2 = { |key, track, seq|
// envir = envir ?? { currentEnvironment };
key.envirGet[track][seq];
}
);

{10000.do{~getV.(\rat, 0, 0)}}.bench; // 2x + de CPU
{10000.do{~getV2.(\rat, 0, 0)}}.bench; // 2x + de CPU
{10000.do{\rat.envirGet[0][0]}.value}.bench;
{10000.do{~rat[0][0]}.value}.bench;
{10000.do{ |envir| currentEnvironment[\rat][0][0]}.value}.bench;

key.envirGet[track][seq] // + rapide XXXXXXXXXXXXXXXXXX - à modifier à la place des ~getV
// voire si retirer les parenthèses ne met pas à jour les valeurs -> peut être utile dans le cas de dur XXXXXXXXXXXXXXXXX -> OK
*/



/*
(
~setV = { |key, track, seq, value, envir|
// envir = envir ?? { currentEnvironment };
envir = currentEnvironment;
envir[key][track][seq] = value;
}
);

~setV.(\posRat, 0, 0, 12);
~posRat

{100000.do{~setV.(\posRat, 0, 0, 12)}}.bench; // 2x + de CPU
{100000.do{~posRat[0][0] = 12}.value}.bench; // le + rapide
{100000.do{currentEnvironment[\posRat][0][0] = 12}.value}.bench; // légèrement plus loin
*/

/*
{100000.do{ \amp.envirGet[0][0] }.value }.bench; // légèrement plus rapide - Pourquoi ??????????????????
{100000.do{ currentEnvironment[\amp][0][0] }.value }.bench;
*/

/*
{100000.do{ ~seqSeq[0]; ~seqSeq[0]; }}.bench;
{100000.do{ var seq = ~seqSeq[0]; seq; seq; }}.bench; // réduction du CPU de 1/3 voire la moitié
*/










// Initialisation des variables pour casser une routine d'une séquence en cours (particulièrement celles qui sont aléatoires) lorsqu'on en sélectionne une autre - les valeurs sont tout le temps mis à jour / mais le mode de lecture de lecture de la séquence peut être différent (par ex. lecture en avant ou en arrière)

// [\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i].postln};
// [\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i] = 0 ! ~nbOfTracksX2}; // initialisé dans la GUI // ~ampBlock

~seqGlobalIndex  = 0 ! ~nbOfTracksX2; // Loop de 0 à 3
~seqGlobalRemainingSize = 0 ! ~nbOfTracksX2; // Loop de 4 à 1



~patternKeyRand0ElementFunction = { | envir, track, seq, key, pos, block, stream |
	block{|break|
		key.envirGet[track][seq].size.do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
				r = stream.next;
				envir[pos][track][seq] = 0;
				r.yield;
			})
		}
	}
};

~patternKeyRand0ElementCutLoopFunction = { | envir, track, seq, key, pos, block, stream |
	envir[block][track] = 0; block{|break|
		~seqGlobalRemainingSize[track].do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
				r = stream.next;
				envir[pos][track][seq] = 0;
				r.yield;
			})
		}
	}
};

~patternKeyRand1ElementFunction = { | envir, track, seq, key, pos, block, selection, stream |
	block{|break|
		key.envirGet[track][seq].size.do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
				r = stream.next;
				envir[pos][track][seq] = selection.indexOf(r);
				r.yield;
			})
		}
	}
};

~patternKeyRand1ElementCutLoopFunction = { | envir, track, seq, key, pos, block, selection, stream |
	envir[block][track] = 0; block{|break|
		~seqGlobalRemainingSize[track].do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
				r = stream.next;
				envir[pos][track][seq] = selection.indexOf(r);
				r.yield;
			})
		}
	}
};

~patternKeyRand2ElementFunction = { | envir, track, seq, key, pos, block, view, stream, inv |
	// envir.postln; track.postln; key.postln; key.envirGet.postln; pos.postln; block.postln; stream.postln; view.postln;
	if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
		{{view.valueAction_(stream)}.defer;
			block{|break|
				key.envirGet[track][seq].size.do{|i|
					if (block.envirGet[track] == 1, {break.value}, {
						envir[pos][track][seq] = i;
						// stream.wrapAt(i).yield;
						if (inv == 0, { stream.wrapAt(i).yield; }, { (1 - stream.wrapAt(i)).yield; });
					})
				}
			}
		},
		{ // version avec aucun changement du visuel
			block{|break|
				envir[pos][track][seq] = 0;
				key.envirGet[track][seq].size.do{|i|
					if (block.envirGet[track] == 1, {break.value}, {
						// stream.wrapAt(i).yield;
						if (inv == 0, { stream.wrapAt(i).yield; }, { (1 - stream.wrapAt(i)).yield; });
					})
				}
			}
		}
	)
};

~patternKeyRand2ElementCutLoopFunction = { | envir, track, seq, key, pos, block, view, stream, inv |
	envir[block][track] = 0;
	if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
		{{view.valueAction_(stream)}.defer;
			block{|break|
				~seqGlobalRemainingSize[track].do{|i|
					if (block.envirGet[track] == 1, {break.value}, {
						envir[pos][track][seq] = ~seqGlobalIndex[track];
						// stream.wrapAt(~seqGlobalIndex[track]).yield;
						if (inv == 0, { stream.wrapAt(~seqGlobalIndex[track]).yield; }, { (1-stream.wrapAt(~seqGlobalIndex[track])).yield; });
					})
				}
			}
		},
		{ // version avec aucun changement du visuel
			block{|break|
				envir[pos][track][seq] = 0;
				~seqGlobalRemainingSize[track].do{|i|
					if (block.envirGet[track] == 1, {break.value}, {
						// r = stream.wrapAt(~seqGlobalIndex[track]).yield;
						if (inv == 0, { r = stream.wrapAt(~seqGlobalIndex[track]).yield; }, { r = (1 - stream.wrapAt(~seqGlobalIndex[track])).yield; });
					})
				}
			}
		}
	)
};

~proT2 = 0 ! ~nbOfTracksX2; // pour le Lehmer avec note

// Essayer de mettre en place le changement de visuel pour le Lehmer avec note - mais comment ?
~patternKeyElementLehmerFunction = { | envir, track, seq, key, pos, block, view, stream, inv |
	// envir.postln; track.postln; key.postln; key.envirGet.postln; pos.postln; block.postln; stream.postln; view.postln;
	/*if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
	// {{view.valueAction_(stream)}.defer;
	{ // { if (~proT[track] == (key.envirGet[track][seq].size-1), { view.valueAction_(stream) }) }.defer;
	if (~proT[track] == (key.envirGet[track][seq].size-1) or: {stream.size != key.envirGet[track][seq].size}, { view.valueAction_(stream) });
	block{|break|
	key.envirGet[track][seq].size.do{|i|
	if (block.envirGet[track] == 1, {break.value}, {
	envir[pos][track][seq] = ~proT[track] /*i*/;
	stream.wrapAt(~proT[track] /*i*/).yield;
	})
	}
	} while
	},
	{*/ // version avec aucun changement du visuel
	block{|break|
		envir[pos][track][seq] = 0;
		key.envirGet[track][seq].size.do {|i|
			if (block.envirGet[track] == 1, {break.value}, {
				// stream.wrapAt(~proT2[track] /*i*/).yield
				if (inv == 0, {stream.wrapAt(~proT2[track] /*i*/).yield}, {(1-stream.wrapAt(~proT2[track]) /*i*/).yield}); // stream.next;
			})
		}
	}
};

// Essayer de mettre en place le changement de visuel pour le Lehmer avec note - mais comment ?
~patternKeyElementCutLoopLehmerFunction = { | envir, track, seq, key, pos, block, view, stream, inv |
	envir[block][track] = 0;
	/*if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
	// {{view.valueAction_(stream)}.defer;
	{ // { if (~proT[track] == (key.envirGet[track][seq].size-1), { view.valueAction_(stream) }) }.defer;
	if (~proT[track] == (key.envirGet[track][seq].size-1) or: {stream.size != key.envirGet[track][seq].size}, { view.valueAction_(stream) });
	block{|break|
	~seqGlobalRemainingSize[track].do{|i|
	if (block.envirGet[track] == 1, {break.value}, {
	envir[pos][track][seq] = ~proT[track]; // ~seqGlobalIndex[track];
	stream.wrapAt(~proT[track] /*~seqGlobalIndex[track]*/).yield;
	})
	}
	}
	},
	{*/ // version avec aucun changement du visuel
	block{|break|
		envir[pos][track][seq] = 0;
		~seqGlobalRemainingSize[track].do {|i|
			// ~proTX[track] = ~proT[track]+ ~proTX[track]; ~proTX[track].postln;
			if (block.envirGet[track] == 1, {break.value}, {
				// r = stream.wrapAt(~proT2[track] /*~seqGlobalIndex[track]*/).yield; // r.next;
				if (inv == 0, {r = stream.wrapAt(~proT2[track] /*i*/).yield}, {r = (1-(stream.wrapAt(~proT2[track])) /*i*/).yield}); // r.next;
			})
		}
	}
};





/*
\legX, (Pfunc({ |ev| var seq = ~seqSeq[track];
~patternSwitchParametersFunction.( currentEnvironment, track, \legU, \legPatSel, \legPat, \posLeg, ev);
})),
*/

~patternSwitchParametersFunction = { | envir, track, key, patSel, pat, pos, ev |
	var seq = ~seqSeq[track];
	case
	{pat.envirGet[track][seq] == 0 or: { patSel.envirGet[track][seq] < 17 }} { ev[key] }
	{patSel.envirGet[track][seq] == 17 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.durU } // ~posRat[track][seq] = 0; // nécessaire sinon décalage ??? Au moins pour le Repérage
	{patSel.envirGet[track][seq] == 18 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.durU }
	{patSel.envirGet[track][seq] == 19 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.prepproU }
	{patSel.envirGet[track][seq] == 20 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.prepproU }
	{patSel.envirGet[track][seq] == 21 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.legU }
	{patSel.envirGet[track][seq] == 22 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.legU }
	{patSel.envirGet[track][seq] == 23 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.ampU }
	{patSel.envirGet[track][seq] == 24 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.ampU }
	{patSel.envirGet[track][seq] == 25 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.preprateU }
	{patSel.envirGet[track][seq] == 26 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.preprateU }
	{patSel.envirGet[track][seq] == 27 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.stretcherU }
	{patSel.envirGet[track][seq] == 28 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.stretcherU }
	{patSel.envirGet[track][seq] == 29 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.centerU }
	{patSel.envirGet[track][seq] == 30 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.centerU }
	{patSel.envirGet[track][seq] == 31 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.preprate2U }
	{patSel.envirGet[track][seq] == 32 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.preprate2U }
	{patSel.envirGet[track][seq] == 33 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.stretcher2U }
	{patSel.envirGet[track][seq] == 34 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.stretcher2U }
	{patSel.envirGet[track][seq] == 35 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.center2U }
	{patSel.envirGet[track][seq] == 36 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.center2U }
	{patSel.envirGet[track][seq] == 37 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.prepbufU }
	{patSel.envirGet[track][seq] == 38 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.prepbufU }
	{patSel.envirGet[track][seq] == 39 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.offsetU }
	{patSel.envirGet[track][seq] == 40 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.offsetU }
	{patSel.envirGet[track][seq] == 41 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.panU }
	{patSel.envirGet[track][seq] == 42 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.panU }
	{patSel.envirGet[track][seq] == 43 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.delayU }
	{patSel.envirGet[track][seq] == 44 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.delayU }
	{patSel.envirGet[track][seq] == 45 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.prepoutLU }
	{patSel.envirGet[track][seq] == 46 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.prepoutLU }
	{patSel.envirGet[track][seq] == 47 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; ev.prepoutRU }
	{patSel.envirGet[track][seq] == 48 and: { pat.envirGet[track][seq] == 1 }} { envir[pos][track][seq] = 1000; 1-ev.prepoutRU }
	{patSel.envirGet[track][seq] > 48 /*and: { ~legPat[track][seq] == 1 }*/} { envir[pos][track][seq] = 100000; }
};





// Rajouter Pbjorklund à la fonction ~patternKeyFunction même si n'est utile qu'au module Proba (ou utile pour pan...), mais pour standardisation -> à faire
// Mais besoin de différencier modules Dur et Pro -> ok fait
// Module Dur -> changement de ~dur seulement à la fin de la séquence afin que la durée de la séquence soit respectée (fait avec ~rtmFix) et pas d'avancement seulement si note
// Module Pro -> pas d'avancement seulement si note
// Voire comment faire des Random visuels constants qui ne sont pas générés à chaque séquence si la même XXX ???

(
~patternKeyFunction = /*Routine.new*/ { | envir, track, key, dir, pat, patSel, pos, seqDur, seqStart, seqStop, block, view |
	var x, x2, r, seq, lehmer; /*envir[block][track] = 0;*/
	loop {
		seq = ~seqSeq[track];
		case

		// Test en intégrant le Bloc dans la lecture principale - voire si ne génère pas trop de CPU - apparemment très léger ou insignifiant
		// Seq en avant
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{block{|break|
			key.envirGet[track][seq].size.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((i % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(i).yield;
				})
			}
		}}
		// Seq en avant (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~seqGlobalIndex[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
				})
			}
		}}
		// Seq en avant seulement si note
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{~proT[track] = 0; /*if (~readType == 0, {~proT[track] = ~seqGlobalIndex[track]}, {~proT[track] = 0});*/ block{|break|
			key.envirGet[track][seq].size.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield;
				})
			}
		}}
		// Seq en avant seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{~proT[track] = 0; envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield;
				})
			}
		}}
		// Seq en arrière
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{block{|break|
			key.envirGet[track][seq].size.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (i % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~seqGlobalIndex[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière seulement si note
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{~proT[track] = 0; block{|break|
			key.envirGet[track][seq].size.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{~proT[track] = 0; envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}

		// Loop sans Bloc
		// Seq en avant
		/*{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{/*if (key == \buf, {"trig1".postln;});*/ key.envirGet[track][seq].size.do{|i|
		envir[pos][track][seq] = ((i % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(i).yield};
		}
		// Seq en avant (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; ~seqGlobalRemainingSize[track].do{|i|
		envir[pos][track][seq] = ((~seqGlobalIndex[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~seqGlobalIndex[track]).yield};
		}
		// Seq en avant seulement si note
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{~proT[track] = 0; key.envirGet[track][seq].size.do{|i|
		envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield};
		}
		// Seq en avant seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{~proT[track] = 0; envir[block][track] = 0; ~seqGlobalRemainingSize[track].do{|i|
		envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield};
		}
		// Seq en arrière
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{key.envirGet[track][seq].size.do{|i|
		envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (i % seqDur.envirGet[track][seq]));
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield};
		}
		// Seq en arrière (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; ~seqGlobalRemainingSize[track].do{|i|
		envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~seqGlobalIndex[track] % seqDur.envirGet[track][seq]));
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield};
		}
		// Seq en arrière seulement si note
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{~proT[track] = 0; key.envirGet[track][seq].size.do{|i|
		envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield};
		}
		// Seq en arrière seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{~proT[track] = 0; envir[block][track] = 0; ~seqGlobalRemainingSize[track].do{|i|
		envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
		key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield};
		}*/

		// Seq en avant loopée
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{block{|break|
			inf.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((i % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(i).yield;
				})
			}
		}}
		// Seq en avant loopée (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~seqGlobalIndex[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
				})
			}
		}}
		// Seq en avant loopée seulement si note
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{block{|break|
			inf.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield;
				})
			}
		}}
		// Seq en avant loopée seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = ((~proT[track] % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq]);
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(~proT[track]).yield;
				})
			}
		}}
		// Seq en arrière loopée
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 0}}
		{block{|break|
			inf.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (i % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière loopée (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 0} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~seqGlobalIndex[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière loopée seulement si note
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 0}}
		{block{|break|
			inf.do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}
		// Seq en arrière loopée seulement si note (quand boucle cassée)
		{dir.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: {~proSelect[track][seq] == 1} and: {block.envirGet[track] == 1}}
		{envir[block][track] = 0; block{|break|
			~seqGlobalRemainingSize[track].do{|i|
				if (block.envirGet[track] == 1, {break.value}, {
					envir[pos][track][seq] = (seqStop.envirGet[track][seq] - (~proT[track] % seqDur.envirGet[track][seq]));
					key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(pos.envirGet[track][seq]).yield;
				})
			}
		}}



		{patSel.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Prand
		// visu faussé, sélectionne seulement le 1er élément avec une valeur donnée dans une array, pb quand de nombreuses valeurs identiques - mais pas important
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Prand(x, inf).asStream;
			~patternKeyRand1ElementFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 0 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Prand (quand boucle cassée)
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Prand(x, inf).asStream;
			~patternKeyRand1ElementCutLoopFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pxrand
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pxrand(x, inf).asStream;
			~patternKeyRand1ElementFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 1 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pxrand (quand boucle cassée)
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pxrand(x, inf).asStream;
			~patternKeyRand1ElementCutLoopFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 2 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pshuf
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pn(Pshuf(x, inf)).asStream;
			~patternKeyRand1ElementFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 2 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pshuf (quand boucle cassée)
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pn(Pshuf(x, inf)).asStream;
			~patternKeyRand1ElementCutLoopFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 3 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pwalk
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf), 1).asStream;
			~patternKeyRand1ElementFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		{patSel.envirGet[track][seq] == 3 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pwalk (quand boucle cassée)
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
			x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf), 1).asStream;
			~patternKeyRand1ElementCutLoopFunction.(envir, track, seq, key, pos, block, x, x2);
		}
		/* // effet intéressant -> se fige au fur et à mesure car les données visuelles sont réutilisées à chaque fois
		{patSel.envirGet[track][seq] == 3 and: { pat.envirGet[track][seq] == 1 }} // Pwalk
		{x = key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]);
		x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
		x2 = x2.asStream.nextN(key.envirGet[track][seq].size);
		if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue},
		{{view.valueAction_(x2)}.defer;
		key.envirGet[track][seq].size.do{|i|
		r = x2.wrapAt(i);
		~setV.(pos,track,seq,i); // ~posRat[track][seq] = i;
		r.yield;
		};
		},
		{ // version avec aucun changement du visuel
		key.envirGet[track][seq].size.do{|i|
		r = x2.wrapAt(i);
		~setV.(pos,track,seq,0); // ~posRat[track][seq] = 0;
		r.yield;
		};
		})}*/
		{patSel.envirGet[track][seq] == 4 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pwhite
		{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			/*if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
			{{view.valueAction_(x2)}.defer;
			block{|break|
			key.envirGet[track][seq].size.do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
			r = x2.wrapAt(i);
			envir[pos][track][seq] = i;
			r.yield;
			})}}},
			{ // version avec aucun changement du visuel
			block{|break|
			key.envirGet[track][seq].size.do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
			r = x2.wrapAt(i);
			envir[pos][track][seq] = 0;
			r.yield;
			})}}})*/
		}
		{patSel.envirGet[track][seq] == 4 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pwhite (quand boucle cassée)
		{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			/*if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue} and: {~updateVisualRand == 0},
			{{view.valueAction_(x2)}.defer;
			block{|break|
			~seqGlobalRemainingSize[track].do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
			r = x2.wrapAt(~seqGlobalIndex[track]);
			envir[pos][track][seq] = ~seqGlobalIndex[track];
			r.yield;
			})}}},
			{ // version avec aucun changement du visuel
			block{|break|
			~seqGlobalRemainingSize[track].do{|i|
			if (block.envirGet[track] == 1, {break.value}, {
			r = x2.wrapAt(~seqGlobalIndex[track]);
			envir[pos][track][seq] = 0;
			r.yield;
			})}}})*/
		}
		{patSel.envirGet[track][seq] == 5 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pexprand
		{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 5 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pexprand (quand boucle cassée)
		{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 6 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Plprand
		{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 6 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Plprand (quand boucle cassée)
		{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 7 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pmeanrand
		{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 7 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pmeanrand (quand boucle cassée)
		{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 8 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Phprand
		{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 8 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Phprand (quand boucle cassée)
		{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 9 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pgauss
		// This pattern uses the Box-Muller transform to generate a gaussian distribution from uniformly distributed values: sqrt(-2 * log(1.0.rand)) * sin(2pi.rand)
		// args -> mean (The mean of the distribution), dev (The spread of values around the mean -> standard deviation)
		/*
		~nbPoints = 500
		~a = Pgauss(0.0, 1.0, inf);
		~b = ~a.asStream.nextN(~nbPoints);
		~c = ~b.minItem;
		~d = ~b.maxItem;
		~e = ~b.linlin(~c, ~d, 0, 1);
		~f = [~b, ~e, ~e.histo(~nbPoints)].plot(discrete: false);
		*/
		{x2 = Pgauss(0.0, 1.0, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 9 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pgauss (quand boucle cassée)
		{x2 = Pgauss(0.0, 1.0, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 10 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pbrown
		// Returns a stream that behaves like a brownian motion
		// args -> lo : 0, hi : 1, step : 0.125 (maximum change per step - the distribution is xrand2)
		// see helpfile for making parallel brownian motions
		/*
		~nbPoints = 500
		~a = Pbrown(0.0, 1.0, 0.125, inf);
		~b = ~a.asStream.nextN(~nbPoints);
		~c = ~b.minItem;
		~d = ~b.maxItem;
		~e = ~b.linlin(~c, ~d, 0, 1);
		~f = [~b, ~e, ~e.histo(~nbPoints)].plot(discrete: false);
		*/
		{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 10 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pbrown (quand boucle cassée)
		{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 11 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pgbrown
		// apparemment mouvement plus lent que Pbrown
		// args -> lo : 0, hi : 1, step : 0.125 (maximum multiplication factor per step (omega) - the distribution is xrand2)
		/*
		~nbPoints = 500
		~a = Pgbrown(0.0, 1.0, 0.125, inf);
		~b = ~a.asStream.nextN(~nbPoints);
		~c = ~b.minItem;
		~d = ~b.maxItem;
		~e = ~b.linlin(~c, ~d, 0, 1);
		~f = [~b, ~e, ~e.histo(~nbPoints)].plot(discrete: false);
		*/
		{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 11 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pgbrown (quand boucle cassée)
		{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 12 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0}} // Pcauchy
		// données stables qui provoquent des explosions
		// args -> mean (The mean of the distribution), spread (The horizontal dispersion of the random values. The distribution is unbounded)
		/*
		~nbPoints = 50
		~a = Pcauchy(0.0, 1.0, inf);
		~b = ~a.asStream.nextN(~nbPoints);
		~c = ~b.minItem;
		~d = ~b.maxItem;
		~e = ~b.linlin(~c, ~d, 0, 1);
		~f = [~b, ~e, ~e.histo(~nbPoints)].plot(discrete: false);
		*/
		{x2 = Pcauchy(0.0, 1.0, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}
		{patSel.envirGet[track][seq] == 12 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1}} // Pcauchy (quand boucle cassée)
		{x2 = Pcauchy(0.0, 1.0, inf).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
		}

		// voir aussi les Random Patterns XXXXXX
		// Pbeta -> random values that follow a Eulerian Beta Distribution (lo, hi, prob1, prob2 -> The probability that a value will occur near lo. <1, probability of a value near lo increases. =1, uniform dist. >1 will create a bounded Gaussian-like distribution)
		// Plorenz -> Returns 3 streams that behaves like a strange attractor (x, y, z)
		// Ppoisson -> random values that follow a Poisson Distribution (poitive integer values)
		// Pprob -> random values with arbitrary probability distribution - Creates an integral table on instantiation (cpu intensive) which is then used by the streams to generate random values efficiently
		// voire les UgenPatterns de RedFrik - générateurs et modifiers XXXXXXXXXXX
		// PFSinOsc, PSinOsc, PSaw, PDealyN, PWarp, Pintegrator


		{patSel.envirGet[track][seq] == 13 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 0}} // Lehmer’s Linear Congruence Formula 1
		{x2 = Pfuncn({/*~lehmerInit = 0.5;*/ lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			// ~lehmerInit = 0.1; ~lehmerA = 2.1; ~lehmerB = 0;
			// Pfuncn({~lehmerInit = (~lehmerInit * ~lehmerA + ~lehmerB) % 1}, 100).asStream.nextN(100).plot;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			// x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1); // pas besoin car déjà % 1
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 13 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 1 (quand boucle cassée)
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 14 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 0}} // Lehmer’s Linear Congruence Formula 1 INV
		{x2 = Pfuncn({/*~lehmerInit = 0.5;*/ lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			// ~lehmerInit = 0.1; ~lehmerA = 2.1; ~lehmerB = 0;
			// Pfuncn({~lehmerInit = (~lehmerInit * ~lehmerA + ~lehmerB) % 1}, 100).asStream.nextN(100).plot;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			// x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1); // pas besoin car déjà % 1
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 14 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 1 (quand boucle cassée) INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}

		{patSel.envirGet[track][seq] == 13 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 1 si note
		{x2 = Pfuncn({/*~lehmerInit = 0.5;*/ lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			// ~lehmerInit = 0.1; ~lehmerA = 2.1; ~lehmerB = 0;
			// Pfuncn({~lehmerInit = (~lehmerInit * ~lehmerA + ~lehmerB) % 1}, 100).asStream.nextN(100).plot;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			// x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1); // pas besoin car déjà % 1
			~patternKeyElementLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 13 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 1 (quand boucle cassée) si note
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			// if (~proT2[track] == key.envirGet[track][seq].size or: {x2.class == Routine}, { x2 = x2.nextN(key.envirGet[track][seq].size); 1.postln; ~proT2[track] = 0; });
			~patternKeyElementCutLoopLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 14 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 1 si note INV
		{x2 = Pfuncn({/*~lehmerInit = 0.5;*/ lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			// ~lehmerInit = 0.1; ~lehmerA = 2.1; ~lehmerB = 0;
			// Pfuncn({~lehmerInit = (~lehmerInit * ~lehmerA + ~lehmerB) % 1}, 100).asStream.nextN(100).plot;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			// x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1); // pas besoin car déjà % 1
			~patternKeyElementLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 14 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 1 (quand boucle cassée) si note INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit1.envirGet[track][seq]) * \lehmerA1.envirGet[track][seq] + \lehmerB1.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			// if (~proT2[track] == key.envirGet[track][seq].size or: {x2.class == Routine}, { x2 = x2.nextN(key.envirGet[track][seq].size); 1.postln; ~proT2[track] = 0; });
			~patternKeyElementCutLoopLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit1.envirGet[track][seq] == 0, { lehmer = \lehmerInit1.envirGet[track][seq] } );
		}

		{patSel.envirGet[track][seq] == 15 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 2
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 15 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 2 (quand boucle cassée)
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 16 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 2 INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 16 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 0} } // Lehmer’s Linear Congruence Formula 2 (quand boucle cassée) INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(key.envirGet[track][seq].size);
			~patternKeyRand2ElementCutLoopFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}

		{patSel.envirGet[track][seq] == 15 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 2 si note
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			~patternKeyElementLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 15 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 2 (quand boucle cassée) si note
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			~patternKeyElementCutLoopLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 0);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 16 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 0} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 2 si note INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			~patternKeyElementLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}
		{patSel.envirGet[track][seq] == 16 and: { pat.envirGet[track][seq] == 1 } and: {block.envirGet[track] == 1} and: {~proSelect[track][seq] == 1} } // Lehmer’s Linear Congruence Formula 2 (quand boucle cassée) si note INV
		{x2 = Pfuncn({lehmer = ((lehmer ? \lehmerInit2.envirGet[track][seq]) * \lehmerA2.envirGet[track][seq] + \lehmerB2.envirGet[track][seq]) % 1}, key.envirGet[track][seq].size).asStream;
			x2 = x2.nextN(\pro.envirGet[track][seq].sum.max(1) /*key.envirGet[track][seq].size*/);
			~patternKeyElementCutLoopLehmerFunction.(envir, track, seq, key, pos, block, view, x2, 1);
			if ( \lehmerReInit2.envirGet[track][seq] == 0, { lehmer = \lehmerInit2.envirGet[track][seq] } );
		}

		{patSel.envirGet[track][seq] > 16 and: { pat.envirGet[track][seq] == 1 }} // Seq en avant utile pour calculer la durée et donner rate2
		{key.envirGet[track][seq].size.do{|i|
			envir[pos][track][seq] = (i % seqDur.envirGet[track][seq]) + seqStart.envirGet[track][seq];
			key.envirGet[track][seq].copyRange(seqStart.envirGet[track][seq], seqStop.envirGet[track][seq]).wrapAt(i).yield};
		};

		// Pour le legato -> but ???
		/*
		{~legPatSel[track][seq] == 13 and: { ~legPat[track][seq] == 1 }} // Inverse de la durée
		{~posLeg[track][seq] = 0; (1 - ev.durU).yield; ev.durU.postln;
		}
		*/

	}
});



















// Pattern Function


~patternSyn = { |track|


	Psym1(Pkey(\prepsynExt), (

		// Réintégration partielle des paramètres comme RAT2/STR2/CEN2 dans le coeur du pattern sinon décalage entre les modules

		a: Pbind( // avec RAT2 sans ps

			\rate2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~rat2PatSel[track][seq] < ~controlBus0  or:  { ~rat2Pat[track][seq] == 0 }}
				{if (~harTrig[track][seq] == 1, {
					[~rat2Spec[track][seq].map(ev.rate2X) * ~rat2Mul[track][seq]] * ~ratHarSeq[track][seq]
				},{
					[~rat2Spec[track][seq].map(ev.rate2X) * ~rat2Mul[track][seq]]
				}) }
				{~rat2PatSel[track][seq] == ~controlBus0 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~rat2PatSel[track][seq] == ~controlBus1 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~rat2PatSel[track][seq] == ~controlBus2 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~rat2PatSel[track][seq] == ~controlBus3 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~rat2PatSel[track][seq] == ~controlBus4 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~rat2PatSel[track][seq] == ~controlBus5 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "ratet20 -> ")*/,

			// \rate20, (Pfunc({ |ev| ev.rate2[0] }) ) /*.trace(prefix: "rate20 -> ")*/, // juste pour visualisation
			\rate20, (Pfunc({ |ev| if (ev.rate2.isArray, {ev.rate2[0]}, {1}) }) ) /*.trace(prefix: "rate20 -> ")*/, // juste pour visualisation

			\stretcher2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~str2PatSel[track][seq] < ~controlBus0  or:  { ~str2Pat[track][seq] == 0 }} {~str2Spec[track][seq].map(ev.stretcher2X) * ~str2Mul[track][seq]}
				{~str2PatSel[track][seq] == ~controlBus0 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~str2PatSel[track][seq] == ~controlBus1 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~str2PatSel[track][seq] == ~controlBus2 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~str2PatSel[track][seq] == ~controlBus3 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~str2PatSel[track][seq] == ~controlBus4 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~str2PatSel[track][seq] == ~controlBus5 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "str2test -> ")*/,

			\center2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~cen2PatSel[track][seq] < ~controlBus0  or:  { ~cen2Pat[track][seq] == 0 }}
				{if (~harTrig[track][seq] == 1, {
					[~cen2Spec[track][seq].map(ev.center2X) * ~cen2Mul[track][seq]] + ~cenHarSeq[track][seq]
				},{
					[~cen2Spec[track][seq].map(ev.center2X) * ~cen2Mul[track][seq]]
				}) }
				{~cen2PatSel[track][seq] == ~controlBus0 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~cen2PatSel[track][seq] == ~controlBus1 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~cen2PatSel[track][seq] == ~controlBus2 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~cen2PatSel[track][seq] == ~controlBus3 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~cen2PatSel[track][seq] == ~controlBus4 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~cen2PatSel[track][seq] == ~controlBus5 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "cen2test -> ")*/,

			// \center20, (Pfunc({ |ev| ev.center2[0] }) ) /*.trace(prefix: "center20 -> ")*/, // juste pour visualisation
			\center20, (Pfunc({ |ev| if (ev.center2.isArray, {ev.center2[0]}, {1}) }) ) /*.trace(prefix: "center20 -> ")*/, // juste pour visualisation

		),

		b: Pbind( // avec RAT2 & ps

			\rate2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~rat2PatSel[track][seq] < ~controlBus0  or:  { ~rat2Pat[track][seq] == 0 }}
				{if (~harTrig[track][seq] == 1, {
					[~rat2Spec[track][seq].map(ev.rate2X) * ~rat2Mul[track][seq]] * ~ratHarSeq[track][seq]
				},{
					[~rat2Spec[track][seq].map(ev.rate2X) * ~rat2Mul[track][seq]]
				}) }
				{~rat2PatSel[track][seq] == ~controlBus0 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~rat2PatSel[track][seq] == ~controlBus1 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~rat2PatSel[track][seq] == ~controlBus2 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~rat2PatSel[track][seq] == ~controlBus3 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~rat2PatSel[track][seq] == ~controlBus4 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~rat2PatSel[track][seq] == ~controlBus5 and: { ~rat2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "ratet20 -> ")*/,

			// \rate20, (Pfunc({ |ev| ev.rate2[0] }) ) /*.trace(prefix: "rate20 -> ")*/, // juste pour visualisation
			\rate20, (Pfunc({ |ev| if (ev.rate2.isArray, {ev.rate2[0]}, {1}) }) ) /*.trace(prefix: "rate20 -> ")*/, // juste pour visualisation

			\stretcher2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~str2PatSel[track][seq] < ~controlBus0  or:  { ~str2Pat[track][seq] == 0 }} {~str2Spec[track][seq].map(ev.stretcher2X) * ~str2Mul[track][seq]}
				{~str2PatSel[track][seq] == ~controlBus0 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~str2PatSel[track][seq] == ~controlBus1 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~str2PatSel[track][seq] == ~controlBus2 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~str2PatSel[track][seq] == ~controlBus3 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~str2PatSel[track][seq] == ~controlBus4 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~str2PatSel[track][seq] == ~controlBus5 and: { ~str2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "str2test -> ")*/,

			\center2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~cen2PatSel[track][seq] < ~controlBus0  or:  { ~cen2Pat[track][seq] == 0 }}
				{if (~harTrig[track][seq] == 1, {
					[~cen2Spec[track][seq].map(ev.center2X) * ~cen2Mul[track][seq]] + ~cenHarSeq[track][seq]
				},{
					[~cen2Spec[track][seq].map(ev.center2X) * ~cen2Mul[track][seq]]
				}) }
				{~cen2PatSel[track][seq] == ~controlBus0 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~cen2PatSel[track][seq] == ~controlBus1 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~cen2PatSel[track][seq] == ~controlBus2 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~cen2PatSel[track][seq] == ~controlBus3 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~cen2PatSel[track][seq] == ~controlBus4 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~cen2PatSel[track][seq] == ~controlBus5 and: { ~cen2Pat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "cen2test -> ")*/,

			// \center20, (Pfunc({ |ev| ev.center2[0] }) ) /*.trace(prefix: "center20 -> ")*/, // juste pour visualisation
			\center20, (Pfunc({ |ev| if (ev.center2.isArray, {ev.center2[0]}, {1}) }) ) /*.trace(prefix: "center20 -> ")*/, // juste pour visualisation

			\psPitchDispers, Pfunc({~psPitchDispers[track][~seqSeq[track]]}),
			\psTimeDispers, Pfunc({~psTimeDispers[track][~seqSeq[track]]}),
			\psWindowSize, Pfunc({~psWindowSize[track][~seqSeq[track]]})

		),

		c: Pbind( // avec var sans ps

			\freqrate, Pfunc({~freqRat[track][~seqSeq[track]]}),
			\famp, Pfunc({~fAmp[track][~seqSeq[track]]}),
			\amprate, Pfunc({~ampRat[track][~seqSeq[track]]}),
			\aamp, Pfunc({~aAmp[track][~seqSeq[track]]}),
			\panrate, Pfunc({~panRat[track][~seqSeq[track]]}),
			\pamp, Pfunc({~pAmp[track][~seqSeq[track]]})

		),

		d: Pbind( // avec ps sans var

			\psPitchDispers, Pfunc({~psPitchDispers[track][~seqSeq[track]]}),
			\psTimeDispers, Pfunc({~psTimeDispers[track][~seqSeq[track]]}),
			\psWindowSize, Pfunc({~psWindowSize[track][~seqSeq[track]]})

		),

		e: Pbind( // avec var & ps

			\freqrate, Pfunc({~freqRat[track][~seqSeq[track]]}),
			\famp, Pfunc({~fAmp[track][~seqSeq[track]]}),
			\amprate, Pfunc({~ampRat[track][~seqSeq[track]]}),
			\aamp, Pfunc({~aAmp[track][~seqSeq[track]]}),
			\panrate, Pfunc({~panRat[track][~seqSeq[track]]}),
			\pamp, Pfunc({~pAmp[track][~seqSeq[track]]}),

			\psPitchDispers, Pfunc({~psPitchDispers[track][~seqSeq[track]]}),
			\psTimeDispers, Pfunc({~psTimeDispers[track][~seqSeq[track]]}),
			\psWindowSize, Pfunc({~psWindowSize[track][~seqSeq[track]]})

		),

		f: Pbind( ) // tout autre synthé

	))

};





~patternEnv = { |track|

	Psym1(Pkey(\prepenvExt), (

		line1: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][0] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][0] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "relCurve -> ")*/

		),

		line2: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][1] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][1] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "relCurve -> ")*/

		),

		gauss: Pbind(

			\width, Pfunc({ |ev| if (ev.prepenv == 2, {~w1[track][~seqSeq[track]]}, {~w2[track][~seqSeq[track]]}) })

		),

		perc1: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][0] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][0] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][1] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][1] }) /*.trace(prefix: "relCurve -> ")*/,

			\atkPerc, Pfunc({ |ev| if (ev.prepenv.inclusivelyBetween(4,5), {ev.atk}, {1 - ev.rel}) }),
			\relPerc, Pfunc({ |ev| if (ev.prepenv.inclusivelyBetween(6,7), {ev.rel}, {1 - ev.atk}) })

		),

		perc2: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][1] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][1] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][1] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][1] }) /*.trace(prefix: "relCurve -> ")*/,

			\atkPerc, Pfunc({ |ev| if (ev.prepenv.inclusivelyBetween(4,5), {ev.atk}, {1 - ev.rel}) }),
			\relPerc, Pfunc({ |ev| if (ev.prepenv.inclusivelyBetween(6,7), {ev.rel}, {1 - ev.atk}) })

		),

		spec1: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][0] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][0] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "relCurve -> ")*/,
			\bufSpec, (Pfunc({ |ev| case
				{ev.prepenv == 8 or: {ev.prepenv == 11}} { ~bufEnv[ev.serverNb][0] }
				{ev.prepenv == 9 or: {ev.prepenv == 12}} { ~bufEnv[ev.serverNb][1] }
				{ev.prepenv == 10 or: {ev.prepenv == 13}} { ~bufEnv[ev.serverNb][2] }
				// {ev.prepenv != 5 || {ev.prepenv != 6} || {ev.prepenv != 7} } { ~bufEnv[0] }
				{ev.prepenv >= 0} { ~bufEnv[ev.serverNb][0] } // juste pour envoyer un buffer si les conditions préalables n'ont pas été réuni
				// Voir si préférable de mettre les conditions qui sont les plus fréquentes en 1er pour générer moins de CPU (par ex dans ce cas la dernière en 1er) ?????????
				// cette dernière ligne ne serait pas nécessaire si une variable d'environnment pouvait être intégrée dans les arg des synthés ?????????
			}))

		),

		spec2: Pbind(

			\atk, Pfunc({ ~atk[track][~seqSeq[track]][1] }) /*.trace(prefix: "atk -> ")*/,
			\rel, Pfunc({ ~rel[track][~seqSeq[track]][1] }) /*.trace(prefix: "rel -> ")*/,
			\atkCurve, Pfunc({ ~atkCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "atkCurve -> ")*/,
			\relCurve, Pfunc({ ~relCurve[track][~seqSeq[track]][0] }) /*.trace(prefix: "relCurve -> ")*/,
			\bufSpec, (Pfunc({ |ev| case
				{ev.prepenv == 8 or: {ev.prepenv == 11}} { ~bufEnv[ev.serverNb][0] }
				{ev.prepenv == 9 or: {ev.prepenv == 12}} { ~bufEnv[ev.serverNb][1] }
				{ev.prepenv == 10 or: {ev.prepenv == 13}} { ~bufEnv[ev.serverNb][2] }
				// {ev.prepenv != 5 || {ev.prepenv != 6} || {ev.prepenv != 7} } { ~bufEnv[0] }
				{ev.prepenv >= 0} { ~bufEnv[ev.serverNb][0] } // juste pour envoyer un buffer si les conditions préalables n'ont pas été réuni
				// Voir si préférable de mettre les conditions qui sont les plus fréquentes en 1er pour générer moins de CPU (par ex dans ce cas la dernière en 1er) ?????????
				// cette dernière ligne ne serait pas nécessaire si une variable d'environnment pouvait être intégrée dans les arg des synthés ?????????
			}))

		),

		exp: Pbind(

			\envexp1, Pfunc({ |ev| if (ev.prepenv == 14, {1}, {0.001}) }) /*.trace(prefix: "envexp1 -> ")*/,
			\envexp2, Pfunc({ |ev| if (ev.prepenv == 15, {1}, {0.001}) }) /*.trace(prefix: "envexp2 -> ")*/

		)

	))

};





~patternSpa = { |track|
	Psym1(Pkey(\prepspaExt), (

		/*
		stLine: Pbind(

		// Pour effectuer les trajectoires Gauche / Droite
		\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
		\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

		// pour les lines Aller ou Aller/retour
		\spaSpeed, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.inclusivelyBetween(2,3), {0}, {1} ) } }) ),

		),
		*/

		circ: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel)/*.trace(prefix: "outSpa -> ")*/,

			// ci-dessous pas forcément nécessaire / seulement utile pour visualisation si pas trop gourmand en CPU XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - apparemment non
			// à retirer du synthé et rajouter les arguments pour éviter doublon
			\panCircMReg, (Pfunc({ |ev| /*ev.pan.lincurve(-1, 1, 20, 0.1, -4)*/ ev.pan.abs.linexp(0, 1, 0.01, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Reg -> ")*/,
			/*
			0.5.lincurve(0, 1, 0.1, 66, 6)
			0.5.linexp(0, 1, 0.1, 66)
			*/

			// obligé de mettre 0.001 ci-dessous car panCircMVarMax utilise une fonction exponentielle et ne peut pas recevoir 0
			// Place dans le coeur du Pbind car generetion dune erreur avec le retour visuel
			\panCircMVarMin, (Pfunc({ |ev| (ev.prepoutRU * ~circSpeedRangeMin[track][~seqSeq[track]]) + 0.001 })) /*.trace(prefix: "pannning CircM Var min -> ")*/,
			\panCircMVarMax, (Pfunc({ |ev| /*ev.panU.range(ev.prepoutRU*3, 20)*/ /*ev.pan.lincurve(-1, 1, 20, ev.panCircMVarMin, -4)*/ ev.pan.abs.linexp(0, 1, ev.panCircMVarMin, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Var max -> ")*/,

			// Avec le ControlSpec - impact CPU ???
			/*
			~panCircMVarMinSpec = ControlSpec(30, 2, -3, 0.1)
			{10000.do {0.5.lincurve(0, 1, 30, 2, -3)}}.bench
			{10000.do {~panCircMVarMinSpec.map(0.5)}}.bench // apparemment CPU un peu plus important et variable avec le ControlSpec
			*/

			// ci-dessous pour le circulaire selon données spectrales
			\freqMin, Pfunc({ ~sdFreqRangeMin[track][~seqSeq[track]] }),
			\freqMax, Pfunc({ ~sdFreqRangeMax[track][~seqSeq[track]] }),
			\freqCurve, Pfunc({ ~spaLagCurve[track][~seqSeq[track]] }),
			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }), // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité

			\circWidth, Pfunc({ ~circSpread[track][~seqSeq[track]] })

			/*
			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			// panning circulaire multiple - permet de sélectionner si panning circulaire régulier ou accélérant ou déccélérant - pas utile pour circ unique
			// aussi utilisé pour les lignes aller / retour :
			// \spaSpeed, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.inclusivelyBetween(2,3), {0}, {1} ) } }) ),
			\spaSpeed, (Pfunc({ |ev|
			ev.prepspa.collect { |i|
			case
			/*{i.inclusivelyBetween(2,3)} // pour les lines Aller ou Aller/retour
			{0}*/
			{i.inclusivelyBetween(4,5)} // pour les lines Aller ou Aller/retour
			{1}
			/*{i.inclusivelyBetween(8,9)} // Circ multiple régulier
			{0}*/
			{i.inclusivelyBetween(10,11)} // Circ multiple Acc
			{1}
			{i.inclusivelyBetween(12,13)} // Circ multiple Decc
			{2}
			{i >= 0 /*.inclusivelyBetween(6,7)*/} // Circ unique & autres
			{0}
			}
			})) /*.trace(prefix: "spaSpeed -> ")*/,
			*/

		),

		circVBAP: Pbind( // Reste à inclure délayU pour la position ?????????

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel)/*.trace(prefix: "outSpa -> ")*/,

			\panCircMReg, (Pfunc({ |ev| /*ev.pan.lincurve(-1, 1, 20, 0.1, -4)*/ ev.pan.abs.linexp(0, 1, 0.01, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Reg -> ")*/,

			// obligé de mettre 0.001 ci-dessous car panCircMVarMax utilise une fonction exponentielle et ne peut pas recevoir 0
			// Place dans le coeur du Pbind car generetion dune erreur avec le retour visuel
			\panCircMVarMin, (Pfunc({ |ev| (ev.prepoutRU * ~circSpeedRangeMin[track][~seqSeq[track]]) + 0.001 })) /*.trace(prefix: "pannning CircM Var min -> ")*/,
			\panCircMVarMax, (Pfunc({ |ev| /*ev.panU.range(ev.prepoutRU*3, 20)*/ /*ev.pan.lincurve(-1, 1, 20, ev.panCircMVarMin, -4)*/ ev.pan.abs.linexp(0, 1, ev.panCircMVarMin, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Var max -> ")*/,

			// ci-dessous pour le circulaire selon données spectrales
			\freqMin, Pfunc({ ~sdFreqRangeMin[track][~seqSeq[track]] }),
			\freqMax, Pfunc({ ~sdFreqRangeMax[track][~seqSeq[track]] }),
			\freqCurve, Pfunc({ ~spaLagCurve[track][~seqSeq[track]] }),
			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }), // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité

			\spread, Pfunc({ ~vbapSpread[track][~seqSeq[track]] }),
			\x2Off, Pfunc({ ~vbapX2Off[track][~seqSeq[track]] }),

			\delayUElev, (Pfunc({ |ev| ev.delayX.range(0, 90) })),
			\selElev, (Pfunc({ |ev| case
				{ev.delayUElev == 0} { 1 }
				{ev.delayUElev == 90} { 2 }
				{ev.delayUElev != 90} { 0 }
			}))

			/*
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			// panning circulaire multiple - permet de sélectionner si panning circulaire régulier ou accélérant ou déccélérant - pas utile pour circ unique
			\spaSpeed, (Pfunc({ |ev|
			ev.prepspa.collect { |i|
			case
			/*{i.inclusivelyBetween(2,3)} // pour les lines Aller ou Aller/retour
			{0}*/
			{i.inclusivelyBetween(4,5)} // pour les lines Aller ou Aller/retour
			{1}
			/*{i.inclusivelyBetween(8,9)} // Circ multiple régulier
			{0}*/
			{i.inclusivelyBetween(10,11)} // Circ multiple Acc
			{1}
			{i.inclusivelyBetween(12,13)} // Circ multiple Decc
			{2}
			{i >= 0 /*.inclusivelyBetween(6,7)*/} // Circ unique & autres
			{0}
			}
			})) /*.trace(prefix: "spaSpeed -> ")*/,
			*/

		),

		vmSt: Pbind(

			\dbRollOff, (Pfunc({ ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\speakerRadius, (Pfunc({ ~speakRad[track][~seqSeq[track]] }) ) /*.trace(prefix: "speakerRadius -> ")*/,
			\pointScale, (Pfunc({ ~vmPointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			/*
			// Pour effectuer les trajectoires Gauche / Droite - seulement utile pour les lines
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			// seulement utile pour les lines Aller ou Aller/retour
			\spaSpeed, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.inclusivelyBetween(2,3), {0}, {1} ) } }) ),
			*/

		),

		vmSD: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel) /*.trace(prefix: "outSpa -> ")*/,

			\dbRollOff, (Pfunc({ ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\speakerRadius, (Pfunc({ ~speakRad[track][~seqSeq[track]] }) ) /*.trace(prefix: "speakerRadius -> ")*/,
			\pointScale, (Pfunc({ ~vmPointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,
			\orientation, (Pfunc({ ~orientation[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			// ci-dessous pour le circulaire selon données spectrales
			\freqMin, Pfunc({ ~sdFreqRangeMin[track][~seqSeq[track]] }),
			\freqMax, Pfunc({ ~sdFreqRangeMax[track][~seqSeq[track]] }),
			\freqCurve, Pfunc({ ~spaLagCurve[track][~seqSeq[track]] }),
			\dbMin, Pfunc({ ~sdDbRangeMin[track][~seqSeq[track]] }),
			\dbMax, Pfunc({ ~sdDbRangeMax[track][~seqSeq[track]] }),

			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }) // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité

			/*
			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,
			*/

		),

		vmTraj: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel) /*.trace(prefix: "outSpa -> ")*/,

			\dbRollOff, (Pfunc({ ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\speakerRadius, (Pfunc({ ~speakRad[track][~seqSeq[track]] }) ) /*.trace(prefix: "speakerRadius -> ")*/,
			\pointScale, (Pfunc({ ~vmPointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,
			\orientation, (Pfunc({ ~orientation[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			\trajBufLoop, Pfunc({ ~trajSpatLoop[track][~seqSeq[track]] }) /*.trace(prefix: "trajBufLoop -> ")*/,

			/*
			\prepspa3, (Pfunc({ |ev| ev.prepspa.collect { |i| i - 18 } })) /*.trace(prefix: "prepspa3 -> ")*/,
			\trajBuf, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][0] }, { ~trajectoryBuffers[i][0] }) } })) /*.trace(prefix: "trajBuf -> ")*/,
			// Durée réelle de la trajectoire du buffer
			\trajBufDur, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][1] }, { ~trajectoryBuffers[i][1] }) } })) /*.trace(prefix: "trajBufDur -> ")*/,
			*/

			// avant ev.trajBufDur et non ev.trajBufDur[0]
			// -> Comment faire ??????
			\trajBufRatio, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~trajSpatTimeType[track][seq] == 0} // Adapt Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ > ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ <= ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ 1 }
				{~trajSpatTimeType[track][seq] == 2 } // Slider Time
				{ /*ev.trajBufRat*/ ~trajSpatRate[track][seq] }
			})) /*.trace(prefix: "trajBufRatio -> ")*/

		),

		vbSD: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel)/*.trace(prefix: "outSpa -> ")*/,

			\spread, Pfunc({ ~vbapSpread[track][~seqSeq[track]] }), // Spread du VBAP
			\x2Off, Pfunc({ ~vbapX2Off[track][~seqSeq[track]] }),

			// ci-dessous pour VBAP Distance
			\dbRollOff, (Pfunc({ ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\pointScale, (Pfunc({ ~vbPointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			\delayUElev, (Pfunc({ |ev| ev.delayX.range(0, 90) })),
			\selElev, (Pfunc({ |ev| case
				{ev.delayUElev == 0} { 1 }
				{ev.delayUElev == 90} { 2 }
				{ev.delayUElev != 90} { 0 }
			})),

			// ci-dessous pour le circulaire selon données spectrales
			\freqMin, Pfunc({ ~sdFreqRangeMin[track][~seqSeq[track]] }),
			\freqMax, Pfunc({ ~sdFreqRangeMax[track][~seqSeq[track]] }),
			\freqCurve, Pfunc({ ~spaLagCurve[track][~seqSeq[track]] }),
			\dbMin, Pfunc({ ~sdDbRangeMin[track][~seqSeq[track]] }),
			\dbMax, Pfunc({ ~sdDbRangeMax[track][~seqSeq[track]] }),

			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }) // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité

			/*
			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,
			*/

		),

		vbTraj: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel) /*.trace(prefix: "outSpa -> ")*/,

			\spread, Pfunc({ ~vbapSpread[track][~seqSeq[track]] }), // Spread du VBAP

			\dbRollOff, (Pfunc({ ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\pointScale, (Pfunc({ ~vbPointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			\trajBufLoop, Pfunc({ ~trajSpatLoop[track][~seqSeq[track]] }) /*.trace(prefix: "trajBufLoop -> ")*/,

			/*
			\prepspa3, (Pfunc({ |ev| ev.prepspa.collect { |i| i - 18 } })) /*.trace(prefix: "prepspa3 -> ")*/,
			\trajBuf, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][0] }, { ~trajectoryBuffers[i][0] }) } })) /*.trace(prefix: "trajBuf -> ")*/,
			// Durée réelle de la trajectoire du buffer
			\trajBufDur, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][1] }, { ~trajectoryBuffers[i][1] }) } })) /*.trace(prefix: "trajBufDur -> ")*/,
			*/

			\trajBufRatio, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~trajSpatTimeType[track][seq] == 0} // Adapt Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ > ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ <= ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ 1 }
				{~trajSpatTimeType[track][seq] == 2 } // Slider Time
				{ /*ev.trajBufRat*/ ~trajSpatRate[track][seq] }
			})), /*.trace(prefix: "trajBufRatio -> ")*/

			\delayUElev, (Pfunc({ |ev| ev.delayX.range(0.1, 90) })),
			\selElev, (Pfunc({ |ev| case
				{ev.delayUElev == 0.1} { 1 }
				{ev.delayUElev == 90} { 2 }
				{ev.delayUElev != 90} { 0 }
			})),

		),

		ambSD: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel)/*.trace(prefix: "outSpa -> ")*/,

			\pointScale, (Pfunc({ ~ambPointScale[track][~seqSeq[track]] })) /*.trace(prefix: "trajLevelScale -> ")*/,
			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }), // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité

			\delayUElev, (Pfunc({ |ev| ev.delayX.range(-0.5pi, 0.5pi) })),
			\selElev, (Pfunc({ |ev| case
				{ev.delayUElev == (-0.5pi)} { 1 }
				{ev.delayUElev == 0.5pi} { 2 }
				{ev.delayUElev != 0.5pi} { 0 }
			})),

			// ci-dessous pour le circulaire selon données spectrales
			\freqMin, Pfunc({ ~sdFreqRangeMin[track][~seqSeq[track]] }),
			\freqMax, Pfunc({ ~sdFreqRangeMax[track][~seqSeq[track]] }),
			\freqCurve, Pfunc({ ~spaLagCurve[track][~seqSeq[track]] }),
			\dbMin, Pfunc({ ~sdDbRangeMin[track][~seqSeq[track]] }),
			\dbMax, Pfunc({ ~sdDbRangeMax[track][~seqSeq[track]] })

			/*
			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,
			*/

		),

		ambTraj: Pbind(

			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel) /*.trace(prefix: "outSpa -> ")*/,

			\pointScale, (Pfunc({ ~ambPointScale[track][~seqSeq[track]] })) /*.trace(prefix: "trajLevelScale -> ")*/,

			\trajBufLoop, Pfunc({ ~trajSpatLoop[track][~seqSeq[track]] }) /*.trace(prefix: "trajBufLoop -> ")*/,

			/*
			\prepspa3, (Pfunc({ |ev| ev.prepspa.collect { |i| i - 18 } })) /*.trace(prefix: "prepspa3 -> ")*/,
			\trajBuf, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][0] }, { ~trajectoryBuffers[i][0] }) } })) /*.trace(prefix: "trajBuf -> ")*/,
			// Durée réelle de la trajectoire du buffer
			\trajBufDur, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[0][1] }, { ~trajectoryBuffers[i][1] }) } })) /*.trace(prefix: "trajBufDur -> ")*/,
			*/

			\trajBufRatio, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~trajSpatTimeType[track][seq] == 0} // Adapt Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ > ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ (ev.durenv / ev.trajBufDur).reciprocal }
				{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv0/*[0]*/ <= ev.trajBufDur0/*[0]*/}} // Trajectory Time
				{ 1 }
				{~trajSpatTimeType[track][seq] == 2 } // Slider Time
				{ /*ev.trajBufRat*/ ~trajSpatRate[track][seq] }
			})) /*.trace(prefix: "trajBufRatio -> ")*/,

			\delayUElev, (Pfunc({ |ev| ev.delayX.range(-0.5pi, 0.5pi) })),
			\selElev, (Pfunc({ |ev| case
				{ev.delayUElev == (-0.5pi)} { 1 }
				{ev.delayUElev == 0.5pi} { 2 }
				{ev.delayUElev != 0.5pi} { 0 }
			}))

		),

		spec: Pbind(

			\panSpectralCurve, (Pfunc({ ~spec2spaCurve[track][~seqSeq[track]] })) /*.trace(prefix: "panSpectralCurve -> ")*/

			/*
			// Pour effectuer les trajectoires Gauche / Droite - seulement utile pour les lines
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			// seulement utile pour les lines Aller ou Aller/retour
			\spaSpeed, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.inclusivelyBetween(2,3), {0}, {1} ) } }) ),
			*/

		),

		acous: Pbind(

			// \outsL, (Pfunc({ |ev| [~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][0]] })) /*.trace(prefix: "Outs L -> ")*/,
			// Le fait de ne pas mettre une Array autour provoque le déclenchement de 2 synthés au lieu d'1, l'un avec les arguments par défaut et l'autre avec les argument de \outsL

			// Pour prendre en compte les FX
			/*\outL, Pif((Pkey(\prepfxL) <= 0),
			(Pkey(\prepoutL) - 1),
			(Pkey(\prepoutL) - 1) + (Pkey(\prepfxL) * ~fxMulChannel)) /*.trace(prefix: "L -> ")*/,*/

			\outsL, (Pfunc({ |ev|
				if ( ev.prepfxL <= 0, {
					[~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][0]]
				},{
					[~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][0] + (ev.prepfxL * ~fxMulChannel)]
				});
			})) /*.trace(prefix: "Outs L -> ")*/,

			// \outsR, (Pfunc({ |ev| [~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][1]] })) /*.trace(prefix: "Outs R -> ")*/,
			// ~bigStereoOuts[31-(18+~allSpasGUIAmbi.size)][1]

			\outsR, (Pfunc({ |ev| if ( ev.prepfxR <= 0, {
				[~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][1]]
			},{
				[~bigStereoOuts[ev.prepspa0-(18+~allSpasGUIAmbi.size)][1] + (ev.prepfxR * ~fxMulChannel)]
			});
			})) /*.trace(prefix: "Outs R -> ")*/,

		),

		others: Pbind(

			/*// ci-dessous pas forcément nécessaire / seulement utile pour visualisation si pas trop gourmand en CPU XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - apparemment non
			// à retirer du synthé et rajouter les arguments pour éviter doublon
			\panCircMReg, (Pfunc({ |ev| /*ev.pan.lincurve(-1, 1, 20, 0.1, -4)*/ ev.pan.abs.linexp(0, 1, 0.01, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Reg -> ")*/,
			/*
			0.5.lincurve(0, 1, 0.1, 66, 6)
			0.5.linexp(0, 1, 0.1, 66)
			*/

			// obligé de mettre 0.001 ci-dessous car panCircMVarMax utilise une fonction exponentielle et ne peut pas recevoir 0
			// Place dans le coeur du Pbind car generetion dune erreur avec le retour visuel
			\panCircMVarMin, (Pfunc({ |ev| (ev.prepoutRU * ~circSpeedRangeMin[track][~seqSeq[track]]) + 0.001 })) /*.trace(prefix: "pannning CircM Var min -> ")*/,
			\panCircMVarMax, (Pfunc({ |ev| /*ev.panU.range(ev.prepoutRU*3, 20)*/ /*ev.pan.lincurve(-1, 1, 20, ev.panCircMVarMin, -4)*/ ev.pan.abs.linexp(0, 1, ev.panCircMVarMin, ~circSpeedRangeMax[track][~seqSeq[track]]) })) /*.trace(prefix: "pannning CircM Var max -> ")*/,*/

		)

	))

};








~patternCore = { |track, stretchdur|

	PexpandInstr(

		Pbind(

			\server, Pfunc({ if (~server2.isNil or: {(track/2).asInteger < ~serverTrackSwitch}, {~server1}, {~server2}) }),
			\serverNb, Pfunc({ if (~server2.isNil or: {(track/2).asInteger < ~serverTrackSwitch}, {0}, {1}) }),

			// \group, (~groups[0][track]) /*.trace*/, // Affichage du groupe
			\group, Pfunc({ |ev| ~groups[ev.serverNb][track] }),

			\busVolume, (Pfunc({100 + ~busses[track]})) /*.trace(prefix: "bus -> ")*/,

			\silenceTime, Pfunc({ ~silenceTime }),

			// \lagTime, Pfunc({ ~lagTime }), // supprimé - plus utilisé

			/*
			// Pour les enveloppes - plus utilisé car utilisation de buffers pour les enveloppes chaotiques
			\segs, Pfunc({~segs[track][~seqSeq[track]]}),
			\endphase, Pfunc({~endphase[track][~seqSeq[track]]}),
			*/





			\prepseq, (Prout({ // intérêt d'utiliser une var locale vs d'environnement ? Est-elle recréée à chaque fois que l'on stoppe, relance, xfade le pattern ???
				var seq, durSeq, infini, test /*, prevSeqType = 0*/;
				inf.do {|i| // Pourquoi avec loop ne marche pas alors que OK avec inf.do ? -> à cause de i ?

					if (~switchSeqValue[track] == 1, {
						seq = ~seqSpec.map(~seq[track].copyRange(~seqSeqStart[track], ~seqSeqStop[track]).wrapAt(i)) - 1;
						~posSeq[track] = (i % ~seqDurSeq[track]) + ~seqSeqStart[track];
					},{
						if (~positionRandSeq[track] == 0, {

							if (~lemurNewSeqs[track].class == Integer /*~lemurTracksRadioSwitches[track] == 0*/, {
								// seq = ~seq2[track].copyRange(~presetSeqStart[track], ~presetSeqStop[track]).wrapAt(i) - 1; seq.postln;
								seq = ~seq2[track].wrapAt(i) - 1; // seq.postln;

								// ci-dessous plus necessaire depuis la lecture ordonnée de multiples séquences (~presetSeqNb2ViewG)
								// ~posSeq2[track] = /*~posSeq2[track]*/ ~presetSeqLength[track].reduce({ |a, b| var c = a.asArray; c ++ (c.last+b) }).asArray;
								// [10, 25, 30, 15].reduce({ |a, b| var c = a.asArray; c ++ (c.last+b) });
								// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/accumulator-td7581515.html#a7581758
								// code pour [10, 25, 30, 15].injectCollect('+', 0)

								// ~posSeq2[track] = ~presetSeqStart[track] + (~posSeq2[track].wrapAt(i));
								~posSeq2[track] = seq; // ~posSeq2[track] .postln;

							},{
								seq = ~lemurPresetSeqLength/*~lemurNewSeqs*/[track].wrapAt(i) -1;
								~posSeq2[track] = seq;
								/*
								~lemurNewSeqs[5]
								*/
							});

						},{
							seq = ~presetSeqRangeRand[track].next -1; // Fabrication de la séquence aléatoire à chaque fois que le RangeSlider est modifié
							~posSeq2[track] = seq;
						})
					});

					// Relancement des routines quand Mode Looping change
					// Prérable de retirer la première condition et d'avoir la seconde -> relancement des routines, quand la seq change et ne plus considérer seulement le Mode Looping avec ~sequenceType car ne prend pas en compte le relancement des routines quand plusieurs seqs avec Looping s'enchainent dans une même piste
					if (/*~sequenceType[track][seq] != prevSeqType or: {*/ ~seqSeq[track] != seq /*}*/, {
						[\rtmBlock, \proBlock, \synBlock, \spaBlock, \legBlock, \envBlock, \bufBlock, \ampBlock, \ratBlock, \rat2Block, \offBlock, \strBlock, \str2Block, \cenBlock, \cen2Block, \panBlock, \delBlock, \outLBlock, \outRBlock, \fxLBlock, \fxRBlock].do {|i| currentEnvironment[i][track] = 1}; // "changed".postln;
						test = 1;
					},{ test = 0});

					// prevSeqType = ~sequenceType[track][seq];

					~seqSeq[track] = seq;

					~seqBlock[track] = 0;

					/*
					block { |break|
					~dur/*~seqDurRtm*/[track][seq].size.do{ |i|
					if (~seqBlock[track] == 1, { break.value;
					}, {
					~seqGlobalIndex[track] = (i % ~pro[track][seq].size);
					~seqGlobalRemainingSize[track] = (~pro[track][seq].size - ~seqGlobalIndex[track])/*.min(~pro[track][seq].size)*/; // ~seqGlobalIndex[track].postln;
					// ~seqGlobalRemainingSize[track].postln;
					seq.yield;
					})
					}
					};
					*/

					// ci-dessous code pour switcher entre lecture continue ou remise à 0 quand changement de séquence / ci-dessus seulement remise à 0
					block { |break|
						~dur/*~seqDurRtm*/[track][seq].size.do{ |i|
							var inc = ~infini[track] + i;
							if (~seqBlock[track] == 1, {
								~infini[track] = inc; /*("inf"+infini).postln;*/ break.value;
							},{
								if (~readType == 0, {~seqGlobalIndex[track] = (inc % ~pro[track][seq].size)}, {~seqGlobalIndex[track] = (i % ~pro[track][seq].size)} );
								// ~seqGlobalIndex[track] = (inc % ~pro[track][seq].size);
								~seqGlobalRemainingSize[track] = (~pro[track][seq].size - ~seqGlobalIndex[track])/*.min(~pro[track][seq].size)*/; // ~seqGlobalIndex[track].postln;
								// ~seqGlobalRemainingSize[track].postln;
								// inc.postln; i.postln;
								seq.yield;
							})
						}
					};

					/*if (/*~sequenceType[track][seq] != prevSeqType or: {*/ /*~seqSeq[track] != seq*/ test == 1 /*}*/, {
					"change of seq in track".postln; ~seqSeq[track].postln;
					// { ~presetSelectionView.doAction/*valueAction_(/*~presetSelectionView.selection[0]*/ ~presetSelectionView.items.indexOfEqual(~presetSelection[track][seq]/*[~seqSeq[track]]*/) )*/; }.defer;
					// {~presetGetFunction.value(~presetSelection[track][~seqSeq[track]].asSymbol, track, ~seqSeq[track])}.defer;
					{~presetGetFunction.value(~presetSelection[track][seq].asSymbol, track, seq)}.defer;
					});*/

			}})) /*.trace(prefix: "seq -> ")*/,


			/*
			\prepseq, (Prout({ // intérêt d'utiliser une var locale vs d'environnement ? Est-elle recréée à chaque fois que l'on stoppe, relance, xfade le pattern ???
			inf.do {|i| // Pourquoi avec loop ne marche pas alors que OK avec inf.do ? -> à cause de i ?
			if (~sequenceType == 0 or: { ~seqSeqStart[track] != ~seqSeqStop[track] }, {
			~seqSeq[track] = ~seqSpec.map(~seq[track].copyRange(~seqSeqStart[track], ~seqSeqStop[track]).wrapAt(i)) - 1;
			~posSeq[track] = (i % ~seqDurSeq[track]) + ~seqSeqStart[track];
			~dur[track][~seqSeq[track]].size.do{
			~seqSeq[track].yield};
			}, { /*~seqSeq[track] = ~seqSpec.map(~seq[track][~seqSeqStart[track]]); ~seqSeq[track].yield;*/
			~seqSeq[track] = ~seqSpec.map(~seq[track].copyRange(~seqSeqStart[track], ~seqSeqStop[track]).wrapAt(i)) - 1;
			~posSeq[track] = (i % ~seqDurSeq[track]) + ~seqSeqStart[track];
			~dur[track][~seqSeq[track]].size.do{
			~seqSeq[track].yield};
			~remiseaezro = 0 })

			}})),
			*/

			/*
			(
			var i;
			i = 0;

			block({|break|
			100.do({
			if(i > 10, {break.value}, {i = i + 1; i.postln})
			})
			})
			)
			*/





			// \loop, 0,
			\loop, Pfunc({~legLoop[track][~seqSeq[track]]}) /*.trace*/,
			\loop2, Pkey(\loop)/*.trace*/, // Pourquoi utilisation initiale de \loop2 & \loop aussi ???
			// \loop2, Pfunc({ |ev| ev.loop })/*.trace*/,
			// Pourquoi Pkey renvoie bien la valeur 0 ou 1 alors que Pfunc renvoie a Routine ???

			\grainSize, Pfunc({~grainSize[track][~seqSeq[track]]}) /*.trace*/,
			\grain2Size, Pfunc({~grain2Size[track][~seqSeq[track]]}) /*.trace*/,


			// \timingOffset, 0.1
			// \lag, 0.1
			\lag, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~harTrig[track][seq] == 1 /*or: {~delHarSeq[track][seq].isArray}*/, { ~delHarSeq[track][seq] /*~delHarSpec[track][seq].map(~delHarSeq[track][seq])*/ }, { 0 /*[ ~delHarSpec[track][seq].map(~delHarSeq[track][seq]/*[0]*/)]*/ })
			})) /*.trace(prefix: "Lag -> ")*/ ,





			/*\prepproU, (Prout({
			loop {
			~dur[track][~seqSeq[track]].size.do{|i|
			~posPro[track][~seqSeq[track]] = (i % ~seqDurPro[track][~seqSeq[track]]) + ~proSeqStart[track][~seqSeq[track]];
			~pro[track][~seqSeq[track]].copyRange(~proSeqStart[track][~seqSeq[track]], ~proSeqStop[track][~seqSeq[track]]).wrapAt(i).yield};
			}})) /*.trace(prefix: "probU -> ")*/,
			\preppro,	(Pfunc({ |ev| ~proSpec[track][~seqSeq[track]].map(ev.prepproU) * ~proMul[track][~seqSeq[track]]})) /*.trace(prefix: "prob -> ")*/,*/

			\prepproU, (Prout({ var x, x2, r, seq, prev; /*~proBlock[track] = 0;*/
				loop {
					seq = ~seqSeq[track];
					case

					// Test en intégrant le Bloc dans la lecture principale - voire si ne génère pas trop de CPU - apparemment très léger
					// Seq en avant
					{~proDir[track][seq] == 0 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~proBlock[track] == 0 }}
					{block{|break|
						~pro[track][seq].size.do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = (i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq];
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(i).yield;
							})
						}
					}}
					// Seq en avant (quand boucle cassée)
					{~proDir[track][seq] == 0 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~proBlock[track] == 1 }}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = (~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq];
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
							})
						}
					}}
					// Seq en arrière
					{~proDir[track][seq] == 1 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~proBlock[track] == 0 }}
					{block{|break|
						~pro[track][seq].size.do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ~proSeqStop[track][seq] - (i % (~seqDurPro[track][seq]));
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~posPro[track][seq]).yield;
							})
						}
					}}
					// Seq en arrière (quand boucle cassée)
					{~proDir[track][seq] == 1 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~proBlock[track] == 1 }}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ~proSeqStop[track][seq] - (~seqGlobalIndex[track] % (~seqDurPro[track][seq]));
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~posPro[track][seq]).yield;
							})
						}
					}}

					// Loop sans Bloc
					// Seq en avant
					/*{~proDir[track][seq] == 0 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 }}
					{~pro[track][seq].size.do{|i|
					~posPro[track][seq] = (i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq];
					~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(i).yield};
					}
					// Seq en arrière
					{~proDir[track][seq] == 1 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 }}
					{~pro[track][seq].size.do{|i|
					~posPro[track][seq] = ~proSeqStop[track][seq] - (i % (~seqDurPro[track][seq]));
					~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~posPro[track][seq]).yield};
					}*/

					// Seq en avant loopée
					{~proDir[track][seq] == 0 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~proBlock[track] == 0 }}
					{block{|break|
						inf.do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = (i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq];
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(i).yield;
							})
						}
					}}
					// Seq en avant loopée (quand boucle cassée)
					{~proDir[track][seq] == 0 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~proBlock[track] == 1 }}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = (~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq];
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
							})
						}
					}}
					// Seq en arrière loopée
					{~proDir[track][seq] == 1 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~proBlock[track] == 0 }}
					{block{|break|
						inf.do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ~proSeqStop[track][seq] - (i % (~seqDurPro[track][seq]));
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~posPro[track][seq]).yield;
							})
						}
					}}
					// Seq en arrière loopée (quand boucle cassée)
					{~proDir[track][seq] == 1 and: { ~proPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~proBlock[track] == 1 }}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i|
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ~proSeqStop[track][seq] - (~seqGlobalIndex[track] % (~seqDurPro[track][seq]));
								~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]).wrapAt(~posPro[track][seq]).yield;
							})
						}
					}}

					{~proPatSel[track][seq] == 0 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Prand
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Prand(x, inf).asStream;
						~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 0 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Prand (quand boucle cassée)
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Prand(x, inf).asStream;
						~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 1 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track]== 0}} // Pxrand
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pxrand(x, inf).asStream;
						~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 1 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pxrand (quand boucle cassée)
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pxrand(x, inf).asStream;
						~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 2 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pshuf
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pn(Pshuf(x, inf)).asStream;
						~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 2 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pshuf (quand boucle cassée)
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pn(Pshuf(x, inf)).asStream;
						~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 3 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pwalk
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
						~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					{~proPatSel[track][seq] == 3 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pwalk (quand boucle cassée)
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
						x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
						~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
					}
					/* // effet intéressant -> se fige au fur et à mesure car les données visuelles sont réutilisées à chaque fois
					{~proPatSel[track][seq] == 3 and: { ~proPat[track][seq] == 1 }} // Pwalk
					{x = ~pro[track][seq].copyRange(~proSeqStart[track][seq], ~proSeqStop[track][seq]);
					x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
					x2 = x2.asStream.nextN(~pro[track][seq].size);
					if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue},
					{{~proView.valueAction_(x2)}.defer;
					~pro[track][seq].size.do{|i|
					r = x2.wrapAt(i);
					~posPro[track][seq] = i;
					r.yield;
					};
					},
					{ // version avec aucun changement du visuel
					~pro[track][seq].size.do{|i|
					r = x2.wrapAt(i);
					~posPro[track][seq] = 0;
					r.yield;
					};
					})}*/
					{~proPatSel[track][seq] == 4 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pwhite
					{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 4 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pwhite (quand boucle cassée)
					{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 5 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pexprand
					{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 5 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pexprand (quand boucle cassée)
					{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 6 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Plprand
					{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 6 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Plprand (quand boucle cassée)
					{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 7 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pmeanrand
					{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 7 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pmeanrand (quand boucle cassée)
					{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 8 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Phprand
					{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 8 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Phprand (quand boucle cassée)
					{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 9 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pgauss
					{x2 = Pgauss(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 9 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pgauss (quand boucle cassée)
					{x2 = Pgauss(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 10 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pbrown
					{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 10 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pbrown (quand boucle cassée)
					{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 11 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pgbrown
					{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 11 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pgbrown (quand boucle cassée)
					{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 12 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pcauchy
					{x2 = Pcauchy(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 12 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pcauchy (quand boucle cassée)
					{x2 = Pcauchy(0.0, 1.0, inf).asStream.nextN(~pro[track][seq].size);
						x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}

					/*// a = Pwrand([1,Pbjorklund2(5,16,1)/4],[0.8,0.2],inf).asStream; a.next // implémenté
					// Pwrand([1, Pbjorklund(1, 2, 1, 0)],[0.6,0.1],inf).asStream.nextN(100) // XXXXXXXXXXXXXXXXXXXXX
					Pwrand([1, Pbjorklund(1, 3, 1, 0)],[0.6,0.1],inf).asStream.nextN(100) // XXXXXXXXXXXXXXXXXXXXX
					Pbjorklund(1, 2, 1, 0).asStream.nextN(100);
					Pbjorklund(1, 3, 1, 0).asStream.nextN(100);
					Pbjorklund(Pseq([1,2,3], inf), 4, inf).asStream.nextN(100)
					{~proPatSel[track][seq] == 13 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pbjorklund
					// Euclidean Algorithm for generating traditional musical rhythms
					// args -> k (The number of hits), n (The total array size)
					{x2 = Pwrand([1, Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, inf, ~proBjor2[track][seq]) ],[~test,1-~test],inf).asStream.nextN(~pro[track][seq].size);
					~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 13 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pbjorklund (quand boucle cassée)
					{x2 = Pwrand([1, Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, inf, ~proBjor2[track][seq]) ],[~test,1-~test],inf).asStream.nextN(~pro[track][seq].size);
					~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}*/
					{~proPatSel[track][seq] == 13 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Pbjorklund
					// Euclidean Algorithm for generating traditional musical rhythms
					// args -> k (The number of hits), n (The total array size)
					{x2 = Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, inf, ~proBjor2[track][seq]).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					{~proPatSel[track][seq] == 13 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Pbjorklund (quand boucle cassée)
					{x2 = Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, inf, ~proBjor2[track][seq]).asStream.nextN(~pro[track][seq].size);
						~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, ~proView, x2, 0);
					}
					// Euclidean Algorithm with probability to alternate with 1 - the duration of the Euclidean sequence is determined by ~proBjor3
					{~proPatSel[track][seq] == 14 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // EuWe
					{x2 = Pwrand([1, Pbjorklund(~proBjor[track][seq], ~proBjor3[track][seq], 1, ~proBjor2[track][seq])], [~proWeight[track][seq], 1-~proWeight[track][seq]], inf).asStream;
						~patternKeyRand0ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					{~proPatSel[track][seq] == 14 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // EuWe (quand boucle cassée)
					{x2 = Pwrand([1, Pbjorklund(~proBjor[track][seq], ~proBjor3[track][seq], 1, ~proBjor2[track][seq])], [~proWeight[track][seq], 1-~proWeight[track][seq]], inf).asStream;
						~patternKeyRand0ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					// 2 Euclidean Algorithms with alternance Pxrand
					{~proPatSel[track][seq] == 15 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Eu2X
					{x2 = Pxrand([Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, 1, ~proBjor2[track][seq]), Pbjorklund(~proBjor3[track][seq], ~pro[track][seq].size, 1, ~proBjor4[track][seq])], inf).asStream;
						~patternKeyRand0ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					{~proPatSel[track][seq] == 15 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Eu2X (quand boucle cassée)
					{x2 = Pxrand([Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, 1, ~proBjor2[track][seq]), Pbjorklund(~proBjor3[track][seq], ~pro[track][seq].size, 1, ~proBjor4[track][seq])], inf).asStream;
						~patternKeyRand0ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					// 2 Euclidean Algorithms with random Pwhite
					{~proPatSel[track][seq] == 16 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Eu2R
					{x2 = Pbjorklund(Pwhite(~proBjor[track][seq], ~proBjor3[track][seq]), ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pwhite(~proBjor2[track][seq], ~proBjor4[track][seq])*/).asStream;
						~patternKeyRand0ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					{~proPatSel[track][seq] == 16 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Eu2R (quand boucle cassée)
					{x2 = Pbjorklund(Pwhite(~proBjor[track][seq], ~proBjor3[track][seq]), ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pwhite(~proBjor2[track][seq], ~proBjor4[track][seq])*/).asStream;
						~patternKeyRand0ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					// 2 Euclidean Algorithms in sequence with PShuf - Pseq does not work
					/*
					a = Pbjorklund(Pseq((~proBjor[~tracksValue][~seqsValue]..~proBjor3[~tracksValue][~seqsValue]), inf), ~pro[~tracksValue][~seqsValue].size, inf, Pseq((~proBjor[~tracksValue][~seqsValue]..~proBjor3[~tracksValue][~seqsValue]), inf) /*~proBjor2[~tracksValue][~seqsValue]*/ /*Pseq((~proBjor2[~tracksValue][~seqsValue]..~proBjor4[~tracksValue][~seqsValue]), inf)*/).asStream;
					a.next;
					*/
					// Pourquoi le Pseq ou Pseries ne marche pas même sur le nb de Hits et pourquoi l'offset doit être fixe, sinon bug ?????????????????????
					{~proPatSel[track][seq] == 17 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Eu2S
					{// x2 = Pbjorklund(/*Pseq*/ Pseries(~proBjor[track][seq], 1, ~proBjor3[track][seq]).asStream, ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pseq((~proBjor2[track][seq]..~proBjor4[track][seq]), inf)*/).asStream;
						x2 = Pbjorklund(/*Pseq*/ Pshuf((~proBjor[track][seq]..~proBjor3[track][seq]), inf), ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pseq((~proBjor2[track][seq]..~proBjor4[track][seq]), inf)*/).asStream;
						~patternKeyRand0ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					{~proPatSel[track][seq] == 17 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Eu2S (quand boucle cassée)
					{// x2 = Pbjorklund(/*Pseq*/ Pseries(~proBjor[track][seq], 1, ~proBjor3[track][seq]).asStream, ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pseq((~proBjor2[track][seq]..~proBjor4[track][seq]), inf)*/).asStream;
						x2 = Pbjorklund(/*Pseq*/ Pshuf((~proBjor[track][seq].copy..~proBjor3[track][seq]), inf), ~pro[track][seq].size, inf, ~proBjor2[track][seq] /*Pseq((~proBjor2[track][seq]..~proBjor4[track][seq]), inf)*/).asStream; // Pn Plazy
						~patternKeyRand0ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					// 2 Euclidean Algorithms with probability for the 1st one
					{~proPatSel[track][seq] == 18 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}} // Eu2W
					{x2 = Pwrand([Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, 1, ~proBjor2[track][seq]), Pbjorklund(~proBjor3[track][seq], ~pro[track][seq].size, 1, ~proBjor4[track][seq])], [~proWeight[track][seq], 1-~proWeight[track][seq]], inf).asStream;
						~patternKeyRand0ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}
					{~proPatSel[track][seq] == 18 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}} // Eu2W (quand boucle cassée)
					{x2 = Pwrand([Pbjorklund(~proBjor[track][seq], ~pro[track][seq].size, 1, ~proBjor2[track][seq]), Pbjorklund(~proBjor3[track][seq], ~pro[track][seq].size, 1, ~proBjor4[track][seq])], [~proWeight[track][seq], 1-~proWeight[track][seq]], inf).asStream;
						~patternKeyRand0ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x2);
					}

					// "Grids is a topographic drum sequencer and allows you to sequence up to six different sounds. Three in its basic mode, six with use of accent" ???
					// Hacking Mutable Instruments Grids - Getting Started:
					// https://www.youtube.com/watch?v=Eex-iLuUdiw
					// https://goodtohear.co.uk/tools/grids-sequencer
					// "Noise Engineering has Numeric Repetitor and Zularic Repetitor which operate similar to Grids."
					// "Coupled with Doepfer quad switches and an Alesis DM-Pro is my percussive backbone."

					// Mise en place de multiples sliders pour contrôler ScGrids et les variations Euclidiennes : ~proBjorGridsX, ~proBjorGridsY, ~gridsDens, ~proBjor3, ~proGridsBias, ~proBjor4, ~proWeight, ~proDrumType
					// Still To Do : XXXXXXXXXXXXXXXXXX
					// Faire un bouton random sur certains sliders du Grid comme GX et GY ou drumType
					// Intégrer un LFO directement dans les paramètres du pattern comme X, Y ou chaos (voire ceux de Fredrik Oloffson) XXX
					// Il serait bien d'ajouter le proWeight & proDrumType dans le Global
					// Mettre à jour les valeurs dans les controleurs (notamment le Lemur)

					// SC Grids modifié
					// avec ornementation avec un % d'aléatoire sur des notes supplémentaires où le RangeView détermine le range du volume aléatoire
					{~proPatSel[track][seq] == 19 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}}
					{block{|break|
						~pro[track][seq].size.do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq], y: ~proBjorGridsY[track][seq], bias: ~proGridsBias[track][seq]);
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}
					{~proPatSel[track][seq] == 19 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq], y: ~proBjorGridsY[track][seq], bias: ~proGridsBias[track][seq]);
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}

					// SC Grids prenant en compte la valeur précédente
					// avec ornementation avec un % d'aléatoire sur des notes supplémentaires où le RangeView détermine le range du volume aléatoire
					{~proPatSel[track][seq] == 20 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}}
					{block{|break|
						~pro[track][seq].size.do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq], y: ~proBjorGridsY[track][seq], bias: ~proGridsBias[track][seq]);
								// if (gridsLevel > (1-~gridsDens[track][seq]), {gridsLevel = 1- gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield; // inverse de la valeur de gridsLevel, mais ne marche pas bien
								if (gridsLevel >= (1-~gridsDens[track][seq]), {
									gridsLevel = gridsLevel; prev = gridsLevel;
								},{
									if (~proWeight[track][seq].coin, {
										gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq]); prev = 0;
									},{
										if (prev.notNil and: {prev > 0}, {gridsLevel = prev * ~proGridsBias2[track][seq]; prev = gridsLevel; /*gridsLevel.postln*/}, {gridsLevel = 0; prev = 0});
									});
								}); gridsLevel.yield; // "a".postln
							})
						}
					}}
					{~proPatSel[track][seq] == 20 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq], y: ~proBjorGridsY[track][seq], bias: ~proGridsBias[track][seq]);
								// if (gridsLevel > (1-~gridsDens[track][seq]), {gridsLevel = 1- gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield; // inverse de la valeur de gridsLevel, mais ne marche pas bien
								if (gridsLevel >= (1-~gridsDens[track][seq]), {
									gridsLevel = gridsLevel; prev = gridsLevel;
								},{
									if (~proWeight[track][seq].coin, {
										gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq]); prev = 0;
									},{
										if (prev.notNil and: {prev > 0}, {gridsLevel = prev * ~proGridsBias2[track][seq]; prev = gridsLevel; /*gridsLevel.postln*/}, {gridsLevel = 0; prev = 0});
									});
								}); gridsLevel.yield; // "b".postln
							})
						}
					}}

					// SC Grids aléatoire dans un range pour GX et GY (afin d'utiliser ~proGridsBias)
					// avec ornementation avec un % d'aléatoire sur des notes supplémentaires où le RangeView détermine le range du volume aléatoire
					{~proPatSel[track][seq] == 21 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}}
					{block{|break|
						~pro[track][seq].size.do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: (~proBjorGridsX[track][seq] + ~proGridsBias2[track][seq].rand2).clip(0,1), y: (~proBjorGridsY[track][seq] + ~proGridsBias2[track][seq].rand2).clip(0,1), bias: ~proGridsBias[track][seq]);
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}
					{~proPatSel[track][seq] == 21 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: (~proBjorGridsX[track][seq] + ~proGridsBias2[track][seq].rand2).clip(0,1), y: (~proBjorGridsY[track][seq] + ~proGridsBias2[track][seq].rand2).clip(0,1), bias: ~proGridsBias[track][seq]);
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}

					// SC Grids aléatoire entre 2 valeurs (pas d'utilisation de ~proGridsBias car pas assez de sliders pour random à la fois de GX et GY)
					// avec ornementation avec un % d'aléatoire sur des notes supplémentaires où le RangeView détermine le range du volume aléatoire
					{~proPatSel[track][seq] == 22 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 0}}
					{block{|break|
						~pro[track][seq].size.do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((i % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq].rrand(~proGridsBias[track][seq]), y: ~proBjorGridsY[track][seq].rrand(~proGridsBias2[track][seq]));
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}
					{~proPatSel[track][seq] == 22 and: { ~proPat[track][seq] == 1 } and: {~proBlock[track] == 1}}
					{~proBlock[track] = 0; block{|break|
						~seqGlobalRemainingSize[track].do{|i| var gridsLevel;
							if (~proBlock[track] == 1, {break.value}, {
								~posPro[track][seq] = ((~seqGlobalIndex[track] % ~seqDurPro[track][seq]) + ~proSeqStart[track][seq])/*.postln*/; // necessary to get position ???
								gridsLevel = ScGrids.calculateLevel(instrument: ~proDrumType[track][seq], curBeat: i, x: ~proBjorGridsX[track][seq].rrand(~proGridsBias[track][seq]), y: ~proBjorGridsY[track][seq].rrand(~proGridsBias2[track][seq]));
								if (gridsLevel >= (1-~gridsDens[track][seq]), {gridsLevel = gridsLevel}, { if (~proWeight[track][seq].coin, {gridsLevel = ~proMin[track][seq].rrand(~proMax[track][seq])}, {gridsLevel = 0}); /*gridsLevel = 0*/}); gridsLevel.yield;
							})
						}
					}}

			}})) /*.trace(prefix: "prepproU -> ")*/,

			\preppro, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~proSpec[track][seq].map(ev.prepproU * ~proMul[track][seq])})) /*.trace(prefix: "preppro -> ")*/,

			// \typePro, Pfunc({|ev| ev.preppro.coin })/*.trace(prefix: "typePro -> ")*/,
			\typePro, Pfunc({|ev| var seq = ~seqSeq[track]; if (~proPatSel[track][seq] > 18 and: {~proPat[track][seq] == 1}, { if (/*~gridsLevel*/ ev.prepproU > 0, {true}, {false}) }, {ev.preppro.coin}) }) /*.trace(prefix: "typePro -> ")*/,

			\typePro2, Pfunc({|ev| if (ev.typePro == true, {~proT[track] = ~proT[track]+1}, {~proT[track]} ); ~proT[track] }) /*.trace(prefix: "typePro2 -> ")*/, // Pour ne faire avancer les autres modules comme Buf ou Rat seulement quand une note est déclenchée // 0 redéclenché au début de chaque pattern
			\typePro3, Pfunc({|ev| if (ev.typePro == true, {~proT2[track] = ~proT2[track]+1 }, {~proT2[track]} ); ~proT2[track] }) /*.trace(prefix: "typePro3 -> ")*/, // pour le Lehmer avec note
			// voir à éliminer \typePro3 et remplacer ~proT2 par ~proT puisqu'il s'agit de toute façon de la même valeur ??? to check ???





			// \dur, Pn(Plazy(Pseq(~dur[track][~seq1].scramble, inf)), inf),
			// \dur, Plazy(Pseq(~dur[track][~seq1], inf)),
			// \dur, Pseq(~dur[track][~seq1], inf), // déclenchement du son // si on laisse dur pour la durée de l'enveloppe -> prise en compte en sec alors que le dur est en rapport avec le tempo et varie avec le stretch // si tempo = 1 et stretch= 1/1 pas besoin de durenv sinon besoin de recalculer la durée de l'enveloppe selon ces 2 paramètres XXXXXX

			\durU, (Prout(

				/*{ ~patternKeyFunction.( track, \dur, \rtmDir, \rtmPat, \rtmPatSel, \posRtm, \seqDurRtm, \rtmSeqStart, \rtmSeqStop, ~rtmView) }*/
				// Module Dur -> changement de ~dur seulement à la fin de la séquence afin que la durée de la séquence soit respectée
				// (Ok fait en partie -> avec une variable seulement pour les séquences en avant et en arrière) XXXXXXXXXXX
				// Ajout de ~rtmFix pour conserver le rythme de la séquence jusqu'à sa fin ou modifiable au cours de la séquence à tout moment
				// et pas d'avancement seulement si note (Ok)

				{ var x, x2, r, rtm, seq; /*~rtmBlock[track] = 0;*/
					loop {
						seq = ~seqSeq[track];
						case

						// Test en intégrant le Bloc dans la lecture principale - voire si ne génère pas trop de CPU - apparemment très léger
						// Seq en avant Fixe
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); rtm.size.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield;
								})
							}
						}}
						// Seq en avant Fixe (quand boucle cassée)
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); ~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (~seqGlobalIndex[track] % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
								})
							}
						}}
						// Seq en arrière Fixe
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); rtm.size.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (i % (~seqDurRtm[track][seq]));
									rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}
						// Seq en arrière Fixe (quand boucle cassée)
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); ~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (~seqGlobalIndex[track] % (~seqDurRtm[track][seq]));
									rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}
						// Seq en avant Var
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							~dur[track][seq].size.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield;
								})
							}
						}}
						// Seq en avant Var (quand boucle cassée)
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (~seqGlobalIndex[track] % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
								})
							}
						}}
						// Seq en arrière Var
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							~dur[track][seq].size.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (i % (~seqDurRtm[track][seq]));
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}
						// Seq en arrière Var (quand boucle cassée)
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (~seqGlobalIndex[track] % (~seqDurRtm[track][seq]));
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}

						// Loop sans Bloc
						// Seq en avant Fixe
						/*{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 }}
						{rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); rtm.size.do{|i|
						~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
						rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield};
						}
						// Seq en arrière Fixe
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 0 }}
						{rtm = ~rtmSpec[track][seq].map(~dur[track][seq]); rtm.size.do{|i|
						~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (i % (~seqDurRtm[track][seq]));
						rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield};
						}
						// Seq en avant Var
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 }}
						{~dur[track][seq].size.do{|i|
						~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
						~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield};
						}
						// Seq en arrière Var
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 0 } and: { ~rtmFix == 1 }}
						{~dur[track][seq].size.do{|i|
						~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (i % (~seqDurRtm[track][seq]));
						~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield};
						}*/

						// Seq en avant loopée
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							inf.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield;
								})
							}
						}}
						// Seq en avant loopée (quand boucle cassée)
						{~rtmDir[track][seq] == 0 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = (~seqGlobalIndex[track] % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~seqGlobalIndex[track]).yield;
								})
							}
						}}
						// Seq en arrière loopée
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~rtmBlock[track] == 0 }}
						{block{|break|
							inf.do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (i % (~seqDurRtm[track][seq]));
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}
						// Seq en arrière loopée (quand boucle cassée)
						{~rtmDir[track][seq] == 1 and: { ~rtmPat[track][seq] == 0 } and: { ~sequenceType[track][seq] == 1 } and: { ~rtmBlock[track] == 1 }}
						{~rtmBlock[track] = 0; block{|break|
							~seqGlobalRemainingSize[track].do{|i|
								if (~rtmBlock[track] == 1, {break.value}, {
									~posRtm[track][seq] = ~rtmSeqStop[track][seq] - (~seqGlobalIndex[track] % (~seqDurRtm[track][seq]));
									~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(~posRtm[track][seq]).yield;
								})
							}
						}}

						{~rtmPatSel[track][seq] == 0 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Prand
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Prand(x, inf).asStream;
							~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 0 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Prand (quand boucle cassée)
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Prand(x, inf).asStream;
							~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 1 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pxrand
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pxrand(x, inf).asStream;
							~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 1 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pxrand (quand boucle cassée)
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pxrand(x, inf).asStream;
							~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 2 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pshuf
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pn(Pshuf(x, inf)).asStream;
							~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 2 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pshuf (quand boucle cassée)
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pn(Pshuf(x, inf)).asStream;
							~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 3 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pwalk
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
							~patternKeyRand1ElementFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
						}
						{~rtmPatSel[track][seq] == 3 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pwalk (quand boucle cassée)
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
							x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
							~patternKeyRand1ElementCutLoopFunction.(currentEnvironment, track, seq, \pro, \posPro, \proBlock, x, x2);
						}
						/* // effet intéressant -> se fige au fur et à mesure car les données visuelles sont réutilisées à chaque fois
						{~rtmPatSel[track][seq] == 3 and: { ~rtmPat[track][seq] == 1 }} // Pwalk
						{x = ~dur[track][seq].copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]);
						x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
						x2 = x2.asStream.nextN(~dur[track][seq].size);
						if (~currentTab == 0 and: {track == ~tracksValue} and: {seq == ~seqsValue},
						{{~rtmView.valueAction_(x2)}.defer;
						~dur[track][seq].size.do{|i|
						r = x2.wrapAt(i);
						~posRtm[track][seq] = i;
						r.yield;
						};
						},
						{ // version avec aucun changement du visuel
						~dur[track][seq].size.do{|i|
						r = x2.wrapAt(i);
						~posRtm[track][seq] = 0;
						r.yield;
						};
						})}*/
						{~rtmPatSel[track][seq] == 4 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pwhite
						{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 4 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pwhite (quand boucle cassée)
						{x2 = Pwhite(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 5 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pexprand
						{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 5 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pexprand (quand boucle cassée)
						{x2 = Pexprand(0.0001, 1, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 6 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Plprand
						{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 6 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Plprand (quand boucle cassée)
						{x2 = Plprand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 7 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pmeanrand
						{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 7 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pmeanrand (quand boucle cassée)
						{x2 = Pmeanrand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 8 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Phprand
						{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 8 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Phprand (quand boucle cassée)
						{x2 = Phprand(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 9 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pgauss
						{x2 = Pgauss(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 9 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pgauss (quand boucle cassée)
						{x2 = Pgauss(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 10 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pbrown
						{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 10 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pbrown (quand boucle cassée)
						{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 11 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pgbrown
						{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 11 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pgbrown (quand boucle cassée)
						{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 12 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 0}} // Pcauchy
						{x2 = Pcauchy(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] == 12 and: { ~rtmPat[track][seq] == 1 } and: {~rtmBlock[track] == 1}} // Pcauchy (quand boucle cassée)
						{x2 = Pcauchy(0.0, 1.0, inf).asStream.nextN(~dur[track][seq].size);
							x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
							~patternKeyRand2ElementCutLoopFunction.(currentEnvironment, track, seq, \dur, \posRtm, \rtmBlock, ~rtmView, x2, 0);
						}
						{~rtmPatSel[track][seq] > 12 and: { ~rtmPat[track][seq] == 1 }} // Seq en avant utile pour ???
						{
							rtm = ~rtmSpec[track][seq].map(~dur[track][seq]);
							rtm.size.do{|i|
								~posRtm[track][seq] = (i % ~seqDurRtm[track][seq]) + ~rtmSeqStart[track][seq];
								rtm.copyRange(~rtmSeqStart[track][seq], ~rtmSeqStop[track][seq]).wrapAt(i).yield;
							}
						}
				}}

			)) /*.trace(prefix: "durU -> ")*/,





			\preprateU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \rat, \ratDir, \ratPat, \ratPatSel, \posRat, \seqDurRat, \ratSeqStart, \ratSeqStop, \ratBlock, ~ratView) }

				/*{ var x, x2, r;
				loop {
				case
				{~ratDir[track][~seqSeq[track]] == 0 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 0 } and: {~proSelect[track][~seqSeq[track]] == 0}} // Seq en avant
				{~rat[track][~seqSeq[track]].size.do{|i|
				~posRat[track][~seqSeq[track]] = (i % ~seqDurRat[track][~seqSeq[track]]) + ~ratSeqStart[track][~seqSeq[track]];
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(i).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 0 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 0 } and: {~proSelect[track][~seqSeq[track]] == 1}} // Seq en avant seulement si note
				{~proT[track] = 0; ~rat[track][~seqSeq[track]].size.do{|i|
				~posRat[track][~seqSeq[track]] = (~proT[track] % ~seqDurRat[track][~seqSeq[track]]) + ~ratSeqStart[track][~seqSeq[track]];
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~proT[track]).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 1 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 0 } and: {~proSelect[track][~seqSeq[track]] == 0}} // Seq en arrière
				{~rat[track][~seqSeq[track]].size.do{|i|
				~posRat[track][~seqSeq[track]] = ~ratSeqStop[track][~seqSeq[track]] - (i % (~seqDurRat[track][~seqSeq[track]]));
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~posRat[track][~seqSeq[track]]).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 1 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 0 } and: {~proSelect[track][~seqSeq[track]] == 1}} // Seq en arrière seulement si note
				{~proT[track] = 0; ~rat[track][~seqSeq[track]].size.do{|i|
				~posRat[track][~seqSeq[track]] = ~ratSeqStop[track][~seqSeq[track]] - (~proT[track] % (~seqDurRat[track][~seqSeq[track]]));
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~posRat[track][~seqSeq[track]]).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 0 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 1 } and: {~proSelect[track][~seqSeq[track]] == 0}} // Seq en avant loopée
				{/*~rat[track][~seqSeq[track]].size*/inf.do{|i|
				~posRat[track][~seqSeq[track]] = (i % ~seqDurRat[track][~seqSeq[track]]) + ~ratSeqStart[track][~seqSeq[track]];
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(i).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 0 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 1 } and: {~proSelect[track][~seqSeq[track]] == 1}} // Seq en avant loopée seulement si note
				{/*~rat[track][~seqSeq[track]].size*/inf.do{|i|
				~posRat[track][~seqSeq[track]] = (~proT[track] % ~seqDurRat[track][~seqSeq[track]]) + ~ratSeqStart[track][~seqSeq[track]];
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~proT[track]).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 1 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 1 } and: {~proSelect[track][~seqSeq[track]] == 0}} // Seq en arrière loopée
				{/*~rat[track][~seqSeq[track]].size*/inf.do{|i|
				~posRat[track][~seqSeq[track]] = ~ratSeqStop[track][~seqSeq[track]] - (i % (~seqDurRat[track][~seqSeq[track]]));
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~posRat[track][~seqSeq[track]]).yield};
				}
				{~ratDir[track][~seqSeq[track]] == 1 and: { ~ratPat[track][~seqSeq[track]] == 0 } and: { ~sequenceType[track][~seqSeq[track]] == 1 } and: {~proSelect[track][~seqSeq[track]] == 1}} // Seq en arrière loopée seulement si note
				{/*~rat[track][~seqSeq[track]].size*/inf.do{|i|
				~posRat[track][~seqSeq[track]] = ~ratSeqStop[track][~seqSeq[track]] - (~proT[track] % (~seqDurRat[track][~seqSeq[track]]));
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(~posRat[track][~seqSeq[track]]).yield};
				}

				{~ratPatSel[track][~seqSeq[track]] == 0 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Prand
				{x = ~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]);
				x2 = Prand(x, inf).asStream;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.next;
				// visu faussé, sélectionne seulement le 1er élément avec une valeur donnée dans une array, pb quand de nombreuses valeurs identiques
				~posRat[track][~seqSeq[track]] = x.indexOf(r);
				r.yield;
				};
				}
				{~ratPatSel[track][~seqSeq[track]] == 1 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pxrand
				{x = ~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]);
				x2 = Pxrand(x, inf).asStream;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.next;
				~posRat[track][~seqSeq[track]] = x.indexOf(r);
				r.yield;
				};
				}
				{~ratPatSel[track][~seqSeq[track]] == 2 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pshuf
				{x = ~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]);
				x2 = Pn(Pshuf(x, inf)).asStream;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.next;
				~posRat[track][~seqSeq[track]] = x.indexOf(r);
				r.yield;
				};
				}
				{~ratPatSel[track][~seqSeq[track]] == 3 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pwalk
				{x = ~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]);
				x2 = Pwalk(x, Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),  1).asStream;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.next;
				~posRat[track][~seqSeq[track]] = x.indexOf(r);
				r.yield;
				};
				}
				{~ratPatSel[track][~seqSeq[track]] == 4 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pwhite
				{x2 = Pwhite(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 5 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pexprand
				{x2 = Pexprand(0.0001, 1, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 6 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Plprand
				{x2 = Plprand(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 7 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pmeanrand
				{x2 = Pmeanrand(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 8 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Phprand
				{x2 = Phprand(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 9 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pgauss
				{x2 = Pgauss(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
				// version avec changement du visuel
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 10 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pbrown - Returns a stream that behaves like a brownian motion
				{x2 = Pbrown(0.0, 1.0, 0.125, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
				// version avec changement du visuel
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 11 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pgbrown - apparemment mouvement plus lent que Pbrown
				{x2 = Pgbrown(0.0, 1.0, 0.125, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
				// version avec changement du visuel
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}
				{~ratPatSel[track][~seqSeq[track]] == 12 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Pcauchy - // données stables qui provoquent des explosions
				{x2 = Pcauchy(0.0, 1.0, inf).asStream;
				x2 = x2.asStream.nextN(~rat[track][~seqSeq[track]].size);
				x2 = x2.linlin(x2.minItem, x2.maxItem, 0, 1);
				// version avec changement du visuel
				if (~currentTab == 0 and: {track == ~tracksValue} and: {~seqSeq[track] == ~seqsValue} and: {~updateVisualRand == 0},
				{{~ratView.valueAction_(x2)}.defer;
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = i;
				r.yield;
				};
				},
				{ // version avec aucun changement du visuel
				~rat[track][~seqSeq[track]].size.do{|i|
				r = x2.wrapAt(i);
				~posRat[track][~seqSeq[track]] = 0;
				r.yield;
				};
				})}

				{~ratPatSel[track][~seqSeq[track]] > 12 and: { ~ratPat[track][~seqSeq[track]] == 1 }} // Seq en avant utile pour calculer la durée et donner rate2
				{~rat[track][~seqSeq[track]].size.do{|i|
				~posRat[track][~seqSeq[track]] = (i % ~seqDurRat[track][~seqSeq[track]]) + ~ratSeqStart[track][~seqSeq[track]];
				~rat[track][~seqSeq[track]].copyRange(~ratSeqStart[track][~seqSeq[track]], ~ratSeqStop[track][~seqSeq[track]]).wrapAt(i).yield};
				}
				}}*/

			)) /*.trace(prefix: "preprateU -> ")*/,





			\legU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \leg, \legDir, \legPat, \legPatSel, \posLeg, \seqDurLeg, \legSeqStart, \legSeqStop, \legBlock, ~legView) })) /*.trace(prefix: "legatoU -> ")*/,

			\ampU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \amp, \ampDir, \ampPat, \ampPatSel, \posAmp, \seqDurAmp, \ampSeqStart, \ampSeqStop, \ampBlock, ~ampView) }))/*.trace(prefix: "ampU -> ")*/,

			\stretcherU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \str, \strDir, \strPat, \strPatSel, \posStr, \seqDurStr, \strSeqStart, \strSeqStop, \strBlock, ~strView) })) /*.trace(prefix: "stretch -> ")*/,

			\centerU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \cen, \cenDir, \cenPat, \cenPatSel, \posCen, \seqDurCen, \cenSeqStart, \cenSeqStop, \cenBlock, ~cenView) })) /*.trace(prefix: "centerU -> ")*/,

			\preprate2U, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \rat2, \rat2Dir, \rat2Pat, \rat2PatSel, \posRat2, \seqDurRat2, \rat2SeqStart, \rat2SeqStop, \rat2Block, ~rat2View) })) /*.trace(prefix: "preprateU -> ")*/,

			\stretcher2U, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \str2, \str2Dir, \str2Pat, \str2PatSel, \posStr2, \seqDurStr2, \str2SeqStart, \str2SeqStop, \str2Block, ~str2View) })) /*.trace(prefix: "stretch -> ")*/,

			\center2U, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \cen2, \cen2Dir, \cen2Pat, \cen2PatSel, \posCen2, \seqDurCen2, \cen2SeqStart, \cen2SeqStop, \cen2Block, ~cen2View) })) /*.trace(prefix: "centerU -> ")*/,

			\prepbufU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \buf, \bufDir, \bufPat, \bufPatSel, \posBuf, \seqDurBuf, \bufSeqStart, \bufSeqStop, \bufBlock, ~bufView) })) /*.trace(prefix: "prepbufU -> ")*/,

			\offsetU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \off, \offDir, \offPat, \offPatSel, \posOff, \seqDurOff, \offSeqStart, \offSeqStop, \offBlock, ~offView) })) /*.trace(prefix: "offsetU -> ")*/,

			\panU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \pan, \panDir, \panPat, \panPatSel, \posPan, \seqDurPan, \panSeqStart, \panSeqStop, \panBlock, ~panView) })) /*.trace(prefix: "panU -> ")*/,

			\delayU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \del, \delDir, \delPat, \delPatSel, \posDel, \seqDurDel, \delSeqStart, \delSeqStop, \delBlock, ~delView) })) /*.trace(prefix: "delayU -> ")*/,

			\prepoutLU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \outL, \outLDir, \outLPat, \outLPatSel, \posOutL, \seqDurOutL, \outLSeqStart, \outLSeqStop, \outLBlock, ~outLView) })) /*.trace(prefix: "prepoutLU -> ")*/,

			\prepoutRU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \outR, \outRDir, \outRPat, \outRPatSel, \posOutR, \seqDurOutR, \outRSeqStart, \outRSeqStop, \outRBlock, ~outRView) })) /*.trace(prefix: "prepoutRU -> ")*/,





			\ampX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \ampU, \ampPatSel, \ampPat, \posAmp, ev);
			})) /*.trace(prefix: "ampX -> ")*/,

			// \amp2, (Pfunc({ |ev| ~ampSpec[track][~seqSeq[track]].map(ev.ampU) * ~ampMul[track][~seqSeq[track]]})), /*.trace(prefix: "amplitude -> ")*/
			// \volume, (Pfunc({ |ev| ~vol})).trace(prefix: "amplitude -> "),
			// \amp, (Pfunc({ |ev| ev.amp2 * ev.volume})) /*.trace(prefix: "amplitude -> ")*/,

			\ampH, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~harTrig[track][seq] == 1, {
					// ([~ampSpec[track][seq].map(ev.ampX) * ~ampMul[track][seq]] + /*x*/ ~ampHarSeq[track][seq]).normalizeSum.sqrt
					// Problème de l'amplitude multipliée, c'est qu'elle reste tout le temps fixe, mais le range de variation est plus grand
					// Lorsque l'amplitude est additionée, elle est variable, mais le range de variation est plus petit
					(([~ampSpec[track][seq].map(ev.ampX)] + /*x*/ (~ampHarSeq[track][seq])).normalizeSum/*.sqrt*/)  * ~ampMul[track][seq]
				}, {
					([~ampSpec[track][seq].map(ev.ampX) * ~ampMul[track][seq]] /** ~ampHarSeq[track][seq][0]*/) }) }))/*.trace(prefix: "ampH -> ")*/,
			/*
			([ 0.5, 0.1, 0.41428568959236, 0.81999999284744 ] + 1).normalizeSum.sqrt
			~ampHarSeq[0][0].normalizeSum.sqrt
			[0, 0, 1, 1].normalizeSum.sqrt
			(0.9 * [0.5, 0.8, 0.86, 0.9]).normalizeSum.sqrt
			[ 0.05, 0.08, 0.086, 0.09 ].normalizeSum
			[ 0.45, 0.72, 0.774, 0.81 ].normalizeSum
			*/

			\amp, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~proPatSel[track][seq] > 18 and: { ~proPat[track][seq] == 1 }} { ev.ampH * /*~gridsLevel*/ ev.prepproU } // Special case SC Grids
				{~ampPatSel[track][seq] < ~controlBus0  or:  { ~ampPat[track][seq] == 0 }} { ev.ampH }
				{~ampPatSel[track][seq] == ~controlBus0 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap} // à normaliser de 0 à 1 ???
				{~ampPatSel[track][seq] == ~controlBus1 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~ampPatSel[track][seq] == ~controlBus2 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~ampPatSel[track][seq] == ~controlBus3 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~ampPatSel[track][seq] == ~controlBus4 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~ampPatSel[track][seq] == ~controlBus5 and: { ~ampPat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap}
				{~trigBusAmp == 1} {~controlBus[ev.serverNb][5].asMap}
			})) /*.trace(prefix: "amptest -> ")*/,

			// obligé de faire amp0 pour récuperer la 1ere valeur de amp qu il y ait des multiples ou pas
			// car ~lastEvent[~tab][\amp][0]; ne renvoie pas la bonne valeur lorsqu il y a des multiples -> renvoie la dernière valeur du chorus et non la première -> l'original
			\amp0, (Pfunc({ |ev| if (ev.amp.isArray, {ev.ampH[0]}, {1}) }) ) /*.trace(prefix: "amp0 -> ")*/, // juste pour visualisation

			// pour économiser du CPU
			// essai de remplacer note par grain pour économiser du CPU (voire Event tyes), mais ne marche pas ????????????????????
			// \type, Pif(Pkey(\amp) > 0, \note, \rest), // pour économiser du CPU lorsque amp = 0
			// \type, Pwrand([\note, \rest], [0.25, 0.75], inf) /*.trace(prefix: "type -> ")*/,
			// \type, Pif((Pkey(\preppro)).coin, \note, \rest) /*.trace(prefix: "type -> ")*/,
			// \type, Pfunc({|ev| if (ev.preppro.coin and: {ev.amp != 0} , {\note}, {\rest}) }) /*.trace(prefix: "type -> ")*/,
			// and: {} - à changer la structure conditionnelle pour améliorer les performances CPU XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			// \type, Pfunc({|ev| if (ev.preppro.coin && (ev.amp != 0) && ~cpuServer == 0, {\note}, {\rest}) })/*.trace(prefix: "type -> ")*/,
			// see Post control bus problems in patterns XXX - meilleur de récupérer la valeur du bus mais asynchrone - voire GenericGlobalControl XXXXXXXXXXXXXXXXXXXXXXXX
			// \cutSynth2, Pfunc({|ev| ~bus[track].asMap }).trace,
			// \cutSynth2b, Pfunc({|ev| ~bus[track].subBus(0).asMap }).trace,
			// \cutSynth3, Pfunc({|ev| ~trackVol[(track/2).floor] }).trace,
			// \cutSynth3b, Pfunc({|ev| ~trackVol[~busses[track]] }).trace,
			\cutSynth, Pfunc({ if (~trackVol[~busses[track]] == 0 and: {~cutSynth == 0}, {0}, {1} ) }) /*.trace(prefix: "cutSynth -> ")*/,

			\cpuServer, Pfunc({ |ev| ~cpuServer[ev.serverNb] }),

			\type, Pfunc({ |ev| if ( ev.cutSynth == 1 and: {ev.typePro == true} and: {ev.amp != 0} and: {ev.cpuServer == 0}, {\note}, {\rest}) })/*.trace(prefix: "type -> ")*/,

			// Test avec harmonisation
			// Mais apparemment calculé qu'une fois au moment du déclenchement de l'event global et non de chaque event en prenant en considération le delay s'il y a, ou le ~cpuServer peut avoir changé ????????
			// \type, Pfunc({ |ev| ev.ampH.collect { |i| if ( ev.cutSynth == 1 and: {ev.typePro == true} and: {ev.amp[0] != 0} and: {~cpuServer == 0}, {\note}, {\rest}) } })/*.trace(prefix: "type -> ")*/,





			\prepsynU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \syn, \synDir, \synPat, \synPatSel, \posSyn, \seqDurSyn, \synSeqStart, \synSeqStop, \synBlock, ~synView) })) /*.trace(prefix: "prepsynU -> ")*/,

			\prepenvU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \env, \envDir, \envPat, \envPatSel, \posEnv, \seqDurEnv, \envSeqStart, \envSeqStop, \envBlock, ~envView) })) /*.trace(prefix: "envU -> ")*/,

			\prepspaU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \spa, \spaDir, \spaPat, \spaPatSel, \posSpa, \seqDurSpa, \spaSeqStart, \spaSeqStop, \spaBlock, ~spaView) })) /*.trace(prefix: "spaU -> ")*/,

			\prepfxLU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \fxL, \fxLDir, \fxLPat, \fxLPatSel, \posFxL, \seqDurFxL, \fxLSeqStart, \fxLSeqStop, \fxLBlock, ~fxLView) })) /*.trace(prefix: "prepfxLU -> ")*/,

			\prepfxRU, (Prout({ ~patternKeyFunction.( currentEnvironment, track, \fxR, \fxRDir, \fxRPat, \fxRPatSel, \posFxR, \seqDurFxR, \fxRSeqStart, \fxRSeqStop, \fxRBlock, ~fxRView) })) /*.trace(prefix: "prepfxRU -> ")*/,





			\durX, (Pfunc({ |ev| var seq = ~seqSeq[track]; // Question pratique : Plus rapide de mettre des var à la place de 1000 ou 0.05 en termes de code OK, mais en termes de CPU ???
				var maxV = 0.15; // 0.1 / 0.15 fait pour qu'il soit à 0.002 / 0.003 sec si random sur 200 valeurs -> rangeSpec de 0 à 0.04 - voire même 0.2 pour être prudent
				/*
				// Méthode pas très flexible car devrait s'adapter selon de RangeSpec XXX
				// Pas utilisé car rtmSpec pourrait être lourd - mais à tester en le multipliant par ~rtmSpec[~tracksValue][~seqsValue].clipHi.reciprocal
				~rtmSpec[~tracksValue][~seqsValue].clipHi
				~rtmSpec[~tracksValue][~seqsValue].clipHi.reciprocal
				2.reciprocal
				0.003*25
				*/
				case
				{ ~rtmPat[track][seq] == 0  or: {~rtmPatSel[track][seq] < 13}} { ev.durU }
				{~rtmPatSel[track][seq] == 13 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.durU.max(maxV) }
				{~rtmPatSel[track][seq] == 14 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.durU.max(maxV) }
				{~rtmPatSel[track][seq] == 15 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.prepproU.max(maxV) }
				{~rtmPatSel[track][seq] == 16 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.prepproU.max(maxV) }
				{~rtmPatSel[track][seq] == 17 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.legU.max(maxV) }
				{~rtmPatSel[track][seq] == 18 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.legU.max(maxV) }
				{~rtmPatSel[track][seq] == 19 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.ampU.max(maxV) }
				{~rtmPatSel[track][seq] == 20 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.ampU.max(maxV) }
				{~rtmPatSel[track][seq] == 21 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.preprateU.max(maxV) }
				{~rtmPatSel[track][seq] == 22 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.preprateU.max(maxV) }
				{~rtmPatSel[track][seq] == 23 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.stretcherU.max(maxV) }
				{~rtmPatSel[track][seq] == 24 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.stretcherU.max(maxV) }
				{~rtmPatSel[track][seq] == 25 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.centerU.max(maxV) }
				{~rtmPatSel[track][seq] == 26 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.centerU.max(maxV) }
				{~rtmPatSel[track][seq] == 27 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.preprate2U.max(maxV) }
				{~rtmPatSel[track][seq] == 28 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.preprate2U.max(maxV) }
				{~rtmPatSel[track][seq] == 29 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.stretcher2U.max(maxV) }
				{~rtmPatSel[track][seq] == 30 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.stretcher2U.max(maxV) }
				{~rtmPatSel[track][seq] == 31 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.center2U.max(maxV) }
				{~rtmPatSel[track][seq] == 32 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.center2U.max(maxV) }
				{~rtmPatSel[track][seq] == 33 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.prepbufU.max(maxV) }
				{~rtmPatSel[track][seq] == 34 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.prepbufU.max(maxV) }
				{~rtmPatSel[track][seq] == 35 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.offsetU.max(maxV) }
				{~rtmPatSel[track][seq] == 36 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.offsetU.max(maxV) }
				{~rtmPatSel[track][seq] == 37 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.panU.max(maxV) }
				{~rtmPatSel[track][seq] == 39 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.panU.max(maxV) }
				{~rtmPatSel[track][seq] == 39 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.delayU.max(maxV) }
				{~rtmPatSel[track][seq] == 40 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.delayU.max(maxV) }
				{~rtmPatSel[track][seq] == 41 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.prepoutLU.max(maxV) }
				{~rtmPatSel[track][seq] == 42 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.prepoutLU.max(maxV) }
				{~rtmPatSel[track][seq] == 43 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; ev.prepoutRU.max(maxV) }
				{~rtmPatSel[track][seq] == 44 and: { ~rtmPat[track][seq] == 1 }} { ~posRtm[track][seq] = 1000; 1-ev.prepoutRU.max(maxV) }
				{~rtmPatSel[track][seq] > 44 /*and: { ~rtmPat[track][seq] == 1 }*/} { ~posRtm[track][seq] = 100000; }
			})) /*.trace(prefix: "durX -> ")*/,

			/*\durX, (Pfunc({ |ev| var seq = ~seqSeq[track]; // Version sans mini comme ci-dessus
			~patternSwitchParametersFunction.( currentEnvironment, track, \durU, \rtmPatSel, \rtmPat, \posRtm, ev);
			})) /*.trace(prefix: "durX -> ")*/,*/

			\legX, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \legU, \legPatSel, \legPat, \posLeg, ev);
			})) /*.trace(prefix: "legX -> ")*/,



			\preprateX, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \preprateU, \ratPatSel, \ratPat, \posRat, ev);
			})) /*.trace(prefix: "preprateX -> ")*/,

			\stretcherX, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \stretcherU, \strPatSel, \strPat, \posStr, ev);
			})) /*.trace(prefix: "stretcherX -> ")*/,

			\centerX, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \centerU, \cenPatSel, \cenPat, \posCen, ev);
			})) /*.trace(prefix: "centerX -> ")*/,

			\rate2X, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \preprate2U, \rat2PatSel, \rat2Pat, \posRat2, ev);
			})) /*.trace(prefix: "rate2X -> ")*/,

			\stretcher2X, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \stretcher2U, \str2PatSel, \str2Pat, \posStr2, ev);
			})) /*.trace(prefix: "stretcher2X -> ")*/,

			\center2X, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \center2U, \cen2PatSel, \cen2Pat, \posCen2, ev);
			})) /*.trace(prefix: "center2X -> ")*/,



			\preprateXU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.preprateX * ~ratMul[track][seq]).min(1) })) /*.trace(prefix: "preprateXU -> ")*/,
			\stretcherXU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.stretcherX * ~strMul[track][seq]).min(1) })) /*.trace(prefix: "stretcherXU -> ")*/,
			\centerXU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.centerX * ~cenMul[track][seq]).min(1) })) /*.trace(prefix: "centerXU -> ")*/,
			\rate2XU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.rate2X * ~rat2Mul[track][seq]).min(1) })) /*.trace(prefix: "rate2XU -> ")*/,
			\stretcher2XU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.stretcher2X * ~str2Mul[track][seq]).min(1) })) /*.trace(prefix: "stretcher2XU -> ")*/,
			\center2XU, (Pfunc({ |ev| var seq = ~seqSeq[track]; (ev.center2X * ~cen2Mul[track][seq]).min(1) })) /*.trace(prefix: "center2XU -> ")*/,



			\prepbufX, (Pfunc({ |ev| // var seq = ~seqSeq[track];
				~patternSwitchParametersFunction.( currentEnvironment, track, \prepbufU, \bufPatSel, \bufPat, \posBuf, ev);
			})) /*.trace(prefix: "prepbufX -> ")*/,

			\offsetX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				(~patternSwitchParametersFunction.( currentEnvironment, track, \offsetU, \offPatSel, \offPat, \posOff, ev) * ~offMul[track][seq]).min(1);
			})) /*.trace(prefix: "offsetX -> ")*/,

			\panX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				(~patternSwitchParametersFunction.( currentEnvironment, track, \panU, \panPatSel, \panPat, \posPan, ev) * ~panMul[track][seq]).min(1);
			})) /*.trace(prefix: "panX -> ")*/,

			\delayX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				(~patternSwitchParametersFunction.( currentEnvironment, track, \delayU, \delPatSel, \delPat, \posDel, ev) * ~delMul[track][seq]).min(1);
			}))/*.trace(prefix: "delX -> ")*/,

			\prepoutLX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				(~patternSwitchParametersFunction.( currentEnvironment, track, \prepoutLU, \outLPatSel, \outLPat, \posOutL, ev) * ~outLMul[track][seq]).min(1);
			})) /*.trace(prefix: "prepoutLX -> ")*/,

			\prepoutRX, (Pfunc({ |ev| var seq = ~seqSeq[track];
				(~patternSwitchParametersFunction.( currentEnvironment, track, \prepoutRU, \outRPatSel, \outRPat, \posOutR, ev) * ~outRMul[track][seq]).min(1);
			})) /*.trace(prefix: "prepoutRX -> ")*/,





			\offset, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~offSpec[track][seq].map(ev.offsetX) /* intégré dans offsetX * ~offMul[track][seq]*/})) /*.trace(prefix: "offset -> ")*/,





			\preprate, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~ratSpec[track][seq].map(ev.preprateX) * ~ratMul[track][seq]})) /*.trace(prefix: "preprate -> ")*/,

			\preprateH, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~harTrig[track][seq] == 1, {[ev.preprate] * ~ratHarSeq[track][seq]}, {[ev.preprate] /** ~ratHarSeq[track][seq][0]*/}) })) /*.trace(prefix: "preprateH -> ")*/,

			// Pourquoi rate ne marche pas ???
			\preprate2, (Pfunc({ |ev| if (ev.offset >= ~offThresh[track][~seqSeq[track]],
				{ev.preprateH * (-1)},
				{ev.preprateH})
			})) /*.trace(prefix: "preprate2 -> ")*/,

			// Pourquoi rate donne noncontrol ???
			/*\rate, (Pfunc({ |ev| if (ev.offset > ~offThresh[track][~seqSeq[track]],
			{ev.preprate * (-1)},
			{ev.preprate})
			})).trace(prefix: "rate -> "),

			\rate2, (Pfunc({ |ev| if (ev.offset > ~offThresh[track][~seqSeq[track]],
			{ev.preprate * (-1)},
			{ev.preprate})
			})).trace(prefix: "rate2 -> "),
			\test, Pfunc({ |ev| ev.rate}).trace(prefix: "ratetest -> "),
			\test2, Pfunc({ |ev| ev.rate2}).trace(prefix: "rate2test -> "),*/

			// \rate, Pfunc({ |ev| ev.rate2}) /*.trace(prefix: "ratetest -> ")*/,
			// \rate, Pfunc({ |ev| if (~ratPatSel[track][~seqSeq[track]] == 13 and: { ~ratPat[track][~seqSeq[track]] == 1 }, {~controlBus[0].asMap}, {ev.rate2}) }) /*.trace(prefix: "ratetest -> ")*/,

			// si le rate est de 0 -> coupure du synthé (durenv) mais pas prise en compte du remplacement par ampU ???

			// obligé de changer le nom de rate à rater car rate retourne un Symbol et non une Array comme prévu
			\rater, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~ratPatSel[track][seq] < ~controlBus0  or: { ~ratPat[track][seq] == 0 }} {ev.preprate2}
				{~ratPatSel[track][seq] == ~controlBus0 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~ratPatSel[track][seq] == ~controlBus1 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~ratPatSel[track][seq] == ~controlBus2 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~ratPatSel[track][seq] == ~controlBus3 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~ratPatSel[track][seq] == ~controlBus4 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~ratPatSel[track][seq] == ~controlBus5 and: { ~ratPat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap}
				{~trigBusRat == 1} {~controlBus[ev.serverNb][5].asMap}
				/*{~ratPatSel[track][~seqSeq[track]] == 19 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[0].asMap} //
				{~ratPatSel[track][~seqSeq[track]] == 20 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[1].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 21 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[2].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 22 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[3].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 23 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[4].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 24 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[5].asMap.linlin(-1, 1, 0, 1)}
				{~ratPatSel[track][~seqSeq[track]] == 25 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[0].asMap} //
				{~ratPatSel[track][~seqSeq[track]] == 26 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[1].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 27 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[2].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 28 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[3].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 29 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[4].asMap}
				{~ratPatSel[track][~seqSeq[track]] == 30 and: { ~ratPat[track][~seqSeq[track]] == 1 }} {~controlBus[5].asMap.linlin(-1, 1, 0, 2000)}*/
			})) /*.trace(prefix: "rate -> ")*/,

			/*
			~controlBus[0].asMap.class
			.isSymbol
			.round(0.01)
			*/

			// obligé de faire rate0 pour récuperer la 1ere valeur de spaSpeed qu il y ait des multiples ou pas
			// car ~lastEvent[~tab][\rate][0]; ne renvoie pas la bonne valeur lorsqu il y a des multiples -> renvoie la dernière valeur du chorus et non la première -> l'original
			\rate0, (Pfunc({ |ev| if (ev.rater.isArray, {ev.preprate2[0]}, { ev.preprate2 /*1*/ }) }) ) /*.trace(prefix: "rate0 -> ")*/,





			// La variation de vitesse sur le 2nd buffer est soit + rapide ou moins rapide à chaque fois
			// préférable de faire l'étendue de la variation dans un sens positif ou négatif ???
			\offRateSecondBuf, Pfunc({ var seq = ~seqSeq[track]; if (~offRateRandSecondBuf[track][seq] == 1, { 1 + (~offRateSecondBuf[track][seq] - 1.0).rand }, {~offRateSecondBuf[track][seq]}) }) /*.trace(prefix: "offRateSecondBuf -> ")*/,
			// 1 + (0.8 - 1.0).rand





			// \stretcher, (Pfunc({ |ev| ~strSpec[track][~seqSeq[track]].map(ev.stretcherU) * ~strMul[track][~seqSeq[track]]})) /*.trace(prefix: "stretch -> ")*/,

			\stretcher, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~strPatSel[track][seq] < ~controlBus0  or: { ~strPat[track][seq] == 0 }} { ~strSpec[track][seq].map(ev.stretcherX) * ~strMul[track][seq] }
				{~strPatSel[track][seq] == ~controlBus0 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~strPatSel[track][seq] == ~controlBus1 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~strPatSel[track][seq] == ~controlBus2 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~strPatSel[track][seq] == ~controlBus3 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~strPatSel[track][seq] == ~controlBus4 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~strPatSel[track][seq] == ~controlBus5 and: { ~strPat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap}
				{~trigBusStr == 1} {~controlBus[ev.serverNb][5].asMap}
			})) /*.trace(prefix: "stretcher -> ")*/,





			// \center, (Pfunc({ |ev| ~cenSpec[track][~seqSeq[track]].map(ev.centerU) * ~cenMul[track][~seqSeq[track]]}))/*.trace(prefix: "center -> ")*/,

			/*
			\center, (Pfunc({ |ev| var seq = ~seqSeq[track];
			case
			{~trigBusCen == 1} {~controlBus[5].asMap}
			{~cenPatSel[track][seq] < 13  or:  { ~cenPat[track][seq] == 0 }}
			// {~cenSpec[track][seq].map(ev.centerU) * ~cenMul[track][seq]}
			{if (~harTrig[track][seq] == 1, {
			[~cenSpec[track][seq].map(ev.centerU) * ~cenMul[track][seq]] + ~cenHarSeq[track][seq]
			},{
			[~cenSpec[track][seq].map(ev.centerU) * ~cenMul[track][seq]]
			}) }
			{~cenPatSel[track][seq] == 13 and: { ~cenPat[track][seq] == 1 }} {~controlBus[0].asMap}
			{~cenPatSel[track][seq] == 14 and: { ~cenPat[track][seq] == 1 }} {~controlBus[1].asMap}
			{~cenPatSel[track][seq] == 15 and: { ~cenPat[track][seq] == 1 }} {~controlBus[2].asMap}
			{~cenPatSel[track][seq] == 16 and: { ~cenPat[track][seq] == 1 }} {~controlBus[3].asMap}
			{~cenPatSel[track][seq] == 17 and: { ~cenPat[track][seq] == 1 }} {~controlBus[4].asMap}
			{~cenPatSel[track][seq] == 18 and: { ~cenPat[track][seq] == 1 }} {~controlBus[5].asMap} })).trace(prefix: "center -> "),
			*/

			\centerH, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~harTrig[track][seq] == 1, {
					[~cenSpec[track][seq].map(ev.centerX) * ~cenMul[track][seq]] + ~cenHarSeq[track][seq]
				},{
					[~cenSpec[track][seq].map(ev.centerX) * ~cenMul[track][seq]] }) })) /*.trace(prefix: "centerH -> ")*/,

			\center, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~cenPatSel[track][seq] < ~controlBus0  or:  { ~cenPat[track][seq] == 0 }} { ev.centerH }
				{~cenPatSel[track][seq] == ~controlBus0 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~cenPatSel[track][seq] == ~controlBus1 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~cenPatSel[track][seq] == ~controlBus2 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~cenPatSel[track][seq] == ~controlBus3 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~cenPatSel[track][seq] == ~controlBus4 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~cenPatSel[track][seq] == ~controlBus5 and: { ~cenPat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap}
				{~trigBusCen == 1} {~controlBus[ev.serverNb][5].asMap}
			})) /*.trace(prefix: "center -> ")*/,

			// obligé de faire center0 pour récuperer la 1ere valeur de spaSpeed qu il y ait des multiples ou pas
			// car ~lastEvent[~tab][\center][0]; ne renvoie pas la bonne valeur lorsqu il y a des multiples -> renvoie la dernière valeur du chorus et non la première -> l'original
			\center0, (Pfunc({ |ev| if (ev.center.isArray, {ev.centerH[0]}, {1}) }) ) /*.trace(prefix: "center0 -> ")*/, // juste pour visualisation





			// \dur, (Pfunc({ |ev| ~rtmSpec[track][~seqSeq[track]].map(ev.durU) * ~rtmMul[track][~seqSeq[track]]})), /*.trace(prefix: "dur -> ")*/
			// A modifier et à intégrer le ~rtmSpec selon si durée en Absolu ou relatif - XXXXXXXXXXXXXXXX
			// idéal si ~rtmFix serait déclenché seulement qu'à la fin d'une séquence XXXXXXXXXXXXXXXX
			\dur, (Pfunc({ |ev| var seq = ~seqSeq[track];
				// Intégration du ~rtmSpec dans les 2 premiers cas de durU pour respecter le rythme (nb de temps)
				if (/*~sequenceType[track][~seqSeq[track]] != 1 or: { ~rtmPat[track][~seqSeq[track]] != 1 } or: {*/ ~rtmFix == 0 /*}*/,
					{ /*"1".postln;*/ ev.durX * ~rtmMul[track][seq] },
					// { /*"2".postln;*/ ~rtmSpec[track][seq].map( ev.durX ) * ~rtmMul[track][seq] }
					{ /*"2".postln;*/ if (track > 5, { ( ~rtmSpec[track][seq].map( ev.durX ) * ~rtmMul[track][seq] * ( if (~twisterIndex1.notNil, { ~rtmRyValue.value * 2 }, { 1 })) ).max(0.016) }, // avec une protection sur la durée minimale pour le ryhtme
						{ ~rtmSpec[track][seq].map( ev.durX ) * ~rtmMul[track][seq] } ) }
				)
			})) /*.trace(prefix: "dur -> ")*/,





			// \stretch, (Pfunc({ stretchdur * ( if (~twisterIndex1.notNil, { ~rtmRyValue.value }, { 1 })) })),
			\stretch, stretchdur,
			// \stretch, Pn(Plazy({1/(rrand(4, 64))}), inf).trace, // faire que les chiffres + bas soient + représentés XXX // mais dans ce cas le légato, rate et TS doivent l'être aussi XXX
			// \stretch, Prout( { loop { ~nbEle[track][~seq1].do{(1/2).yield} ; ~nbEle[track][~seq1].do{(1/64).yield}; ~nbEle[track][~seq1].do{(1/128).yield}; ~nbEle[track][~seq1].do{(1/256).yield} } }).trace,
			// \stretch, p ( { loop { (~nbEle[track][~seq1]*5.rand).do{(1/4).yield} ; (~nbEle[track][~seq1]*5.rand).do{(1/64).yield}; (~nbEle[track][~seq1]*2.rand).do{(1/128).yield}; (~nbEle[track][~seq1]*2.rand).do{(1/256).yield} } }).trace, // voir la différence avec Proutine ???





			\leg, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~legSpec[track][seq].map(ev.legX) * ~legMul[track][seq]})) /*.trace(prefix: "legato -> ")*/,

			\sustain2, (Pfunc({ |ev| if (~legType[track][~seqSeq[track]] == 1, { ev.leg }, { ev.leg * ev.dur * ev.stretch / ~toTempo }) })) /*.trace(prefix: "sustain2 -> ")*/,
			\sustain, (Pfunc({ |ev| if (~envType[track][~seqSeq[track]] == 0, { max(ev.sustain2, 0.1) }, { ev.sustain2 }) })) /*.trace(prefix: "sustain -> ")*/,





			\prepsyn, (Pfunc({ |ev| var seq = ~seqSeq[track]; (~synSpec[track][seq].map(ev.prepsynU * ~synMul[track][seq])).asInteger })) /*.trace(prefix: "prepsyn -> ")*/,
			// nécessité de .asInteger pour être répéré pour faire le dispatch dans \prepsyn2

			/*
			\prepsyn1, (Pfunc({ |ev| case
			{~synType[track][~seqSeq[track]] == 0 and: {ev.prepsyn < 8}}
			{ev.prepsyn}
			{~synType[track][~seqSeq[track]] == 0 and: {ev.prepsyn > 7}}
			{ev.prepsyn + 8}
			{~synType[track][~seqSeq[track]] == 1}
			{ev.prepsyn + 8}
			})
			) /*.trace(prefix: "syn1 -> ")*/,

			\prepsyn2, (Pfunc({ |ev| case
			{~ratSynth[track][~seqSeq[track]] == 0}
			{ev.prepsyn1}
			{~ratSynth[track][~seqSeq[track]] == 1 and: {ev.prepsyn1 == 0}}
			{ev.prepsyn1 + 34}
			{~ratSynth[track][~seqSeq[track]] == 1 /*and: {ev.prepsyn1 != 0}*/}
			{ev.prepsyn1}
			})
			) /*.trace(prefix: "syn2 -> ")*/,
			*/

			\prepsyn2, (Pfunc({ |ev| var seq = ~seqSeq[track];

				case
				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 0} and: {ev.prepsyn <= ~nbSynthBuf}} // Mono / sans Gliss / Buf
				{ev.prepsyn}
				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 0} and: {ev.prepsyn > ~nbSynthBuf}} // Mono / sans Gliss / sans Buf
				{ev.prepsyn + ~nbSynthBuf + 1}

				// {~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {[0, 4].includes(ev.prepsyn)}} // Mono / Gliss / certains synth

				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 0}} // Mono / Gliss / certains synth -> BufMGliss
				{37}
				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 3}} // Mono / Gliss / certains synth -> BufMPitchGliss
				{38}
				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 8}} // Mono / Gliss / certains synth -> WarpMGliss
				{39}
				{~ratSynth[track][seq] == 1 and: {ev.prepsyn == 9}} // Mono ou stéréo / Gliss / GrainBufGliss
				{43}
				{~ratSynth[track][seq] == 1 and: {ev.prepsyn == 17}} // Mono ou stéréo / Gliss / PMOscGliss
				{44}

				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn <= ~nbSynthBuf}} // Mono / Gliss / Autres - version sans Gliss inchangée
				{ev.prepsyn}
				{~synType[track][seq] == 0 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn > ~nbSynthBuf}} // Mono / Gliss / Autres - version sans Gliss inchangée
				{ev.prepsyn + ~nbSynthBuf + 1}

				// {~synType[track][seq] == 1 and: {~ratSynth[track][seq] == 1} and: {[0, 4].includes(ev.prepsyn)}} // Stéréo / Gliss / certains synth

				{~synType[track][seq] == 1 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 0}} // Stéréo / Gliss / certains synth -> BufSGliss
				{40}
				{~synType[track][seq] == 1 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 3}} // Stéréo / Gliss / certains synth  -> BufSPitchGliss
				{41}
				{~synType[track][seq] == 1 and: {~ratSynth[track][seq] == 1} and: {ev.prepsyn == 8}} // Stéréo / Gliss / certains synth  -> WarpSGliss
				{42}

				{~synType[track][seq] == 1 /*and: {~ratSynth[track][seq] == 0}*/} // Stéréo / Autres
				{ev.prepsyn + ~nbSynthBuf + 1}
			})
			) /*.trace(prefix: "syn2 -> ")*/,

			/*
			~allSynthsGUI[43]
			*/





			// Réintégration partielle des paramètres comme RAT2/STR2/CEN2 dans le coeur du pattern sinon décalage entre les modules XXXXXXXXX
			/*
			// Synthés incluant RAT2 / STR2 / CEN2
			"GrainBuf", "GrainFM", "Electribe", // 16 / 26 / 34
			"BufMGliss", "BufMPitchGliss", "WarpMGliss", // Glissando Mono // 35 -> 42
			"BufSGliss", "BufSPitchGliss", "WarpSGliss", // Glissando Stereo
			"GrainBufGliss", "PMOscGliss" // Glissando Autres

			{ 10000.do {[16, 26, 34, 35, 36, 37, 38, 39, 40, 41, 42].includes(42) } }.bench
			{ 10000.do {#[16, 26, 34, 35, 36, 37, 38, 39, 40, 41, 42].includes(42) } }.bench // -> 5 x + rapide XXXXXXXXXXXXXXXXXXXXXXXXXXX - importance des literal arrays #
			{ 10000.do {#[16, 26, 34, 35, 36, 37, 38, 39, 40, 41, 42].matchItem(42) } }.bench
			{ 10000.do {16 == 42 or: {26 == 42} or: {42 >= 34} } }.bench // apparemment légèrement plus rapide // -> 10 x + rapide
			*/

			// \prepinst, (Pfunc({ |ev| if (ev.prepsyn2 == 16 or: {ev.prepsyn2 == 26} or: {ev.prepsyn2.asInteger >= 34}, {\a}, {\b} ) }) )/*.trace(prefix: "prepinst -> ")*/,

			\prepsynExt, (Pfunc({ |ev|
				case
				// [ BufMRoll, BufSRoll, GrainBuf, GrainFM, Electribe, BufMGliss, BufSGliss, GrainBufGliss, PMOscGliss ]
				{ #[7, 16, 18, 28, 36, 37, 40, 43, 44].includes(ev.prepsyn2) } // avec RAT2 sans ps
				{\a}
				// [ BufMPitchGliss, WarpMGliss, BufSPitchGliss, WarpSGliss ]
				{ #[38, 39, 41, 42].includes(ev.prepsyn2) } // avec RAT2 & ps
				{\b}
				// [ BufMVar, BufMVar2, BufSVar, BufSVar2 ]
				{ #[1, 2, 10, 11].includes(ev.prepsyn2) } // avec var sans ps
				{\c}
				// [ BufMPitch, WarpM, BufSPitch, WarpS, WarpIn ]
				{ #[3, 8, 12, 17, 23].includes(ev.prepsyn2) } // avec ps sans var
				{\d}
				// [ BufMPitchVar, BufMPitchVar2, BufSPitchVar, BufSPitchVar2 ]
				{ #[4, 5, 13, 14].includes(ev.prepsyn2) } // avec var & ps
				{\e}
				{ ev.prepsyn2 >= 0 } // tout autre synthé
				{\f}
			}) ) /*.trace(prefix: "prepinst -> ")*/, // manque 0, 6, 9, 15, 19, 20...
			/*
			~allSynthsGUI[28]
			*/

			/*
			// Pour récupérer le nom des synthés
			[4, 5, 13, 14].collect { |i| ~allSynthsGUI[i] }
			*/





			\prepenv, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~envSpec[track][seq].map(ev.prepenvU * ~envMul[track][seq])})) /*.trace(prefix: "env -> ")*/,

			\prepenv2, (Pfunc({ |ev| case
				{ev.prepenv.inclusivelyBetween(0,1)} // Line
				{0}
				/*{ev.prepenv == 1} // Sine supprimé
				{1}*/
				{ev.prepenv.inclusivelyBetween(2,3)} // Gauss
				{1}
				{ev.prepenv.inclusivelyBetween(4,7)} // Perc
				{2}
				{ev.prepenv.inclusivelyBetween(8,13)} // Spec
				{3}
				{ev.prepenv.inclusivelyBetween(14,15)} // Exp
				{4}
			})),

			// Pour l'externalisation des paramètres d'enveloppe avec Pchain
			\prepenvExt, (Pfunc({ |ev|
				var prepenvInt = ev.prepenv.asInteger;
				case
				{prepenvInt == 0}
				{\line1}
				{prepenvInt == 1}
				{\line2}
				{ev.prepenv2 == 1}
				{\gauss}
				{prepenvInt == 4}
				{\perc1}
				{prepenvInt == 6}
				{\perc1}
				{prepenvInt == 5}
				{\perc2}
				{prepenvInt == 7}
				{\perc2}
				{prepenvInt.inclusivelyBetween(8, 10)}
				{\spec1}
				{prepenvInt.inclusivelyBetween(11, 13)}
				{\spec2}
				{ev.prepenv2 == 4}
				{\exp}
			})),





			// \prepspa, (Pfunc({ |ev| (~spaSpec[track][~seqSeq[track]].map(ev.prepspaU) * ~spaMul[track][~seqSeq[track]]).asInteger })) /*.trace(prefix: "spa -> ")*/,

			// Réduction du spaRange de 0 à 5 si stéréo enclenché pour éviter les mouvements circulaires et ambisoniques
			/*\prepspa, (Pfunc({ |ev| var seq = ~seqSeq[track];
			if (~multiStereo[track/2][seq] == 1,
			{ (~spaSpec[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger },
			{ (~spaSpecStereo[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger }
			)})) /*.trace(prefix: "prepspa -> ")*/,
			*/

			\mulCopies, (Pfunc({ ~harTrig[track][~seqSeq[track]] }) ) /*.trace(prefix: "test -> ")*/, // Pour afficher ou non les Indications des vitesses de rotation pour les spatialisations circulaires, sinon erroné -> donc pas d'affichage quand multiples

			/*\prepspa, (Pfunc({ |ev| var seq = ~seqSeq[track]; // Avant la spatialisation Acousmonium
			if (~multiStereo[track/*/2*/][seq] == 0, {
			if (~harTrig[track][seq] == 1, { [(~spaSpec[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] ++ ~spaHarSeq[track][seq] }, { [(~spaSpec[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] })
			},{
			if (~harTrig[track][seq] == 1, { (~spaSpecStereo[track][seq].map([ev.prepspaU] ++ ~spaHarSeq[track][seq]) * ~spaMul[track][seq]).asInteger }, { [(~spaSpecStereo[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] })}
			)})).trace(prefix: "prepspa -> "),*/

			\prepspaA, (Pfunc({ |ev| var prevSpa, seq = ~seqSeq[track]; // Pour le traitement de la spatialisation Acousmonium
				case

				{~multiStereo[track/*/2*/][seq] == 0}
				{ [(~spaSpecStereo[track][seq].map(ev.prepspaU * ~spaMul[track][seq])).asInteger] } // .asInteger necessaire pour avoir un entier sinon erreur plus loin avec \panL et la fonction { |i| if (i.odd, {1}, {-1} ) }

				{~spaPatSel[track][seq] < 17 /*~controlBus0*/  or:  { ~spaPat[track][seq] == 0 }}
				{ [(~spaSpec[track][seq].map(ev.prepspaU * ~spaMul[track][seq])).asInteger] }

				// préférable de doubler le nombre de conditions avec une variable qui réinitialise les données à chaque changement XXXXXX
				{~spaPatSel[track][seq] == 17 /*~controlBus0*/  and:  { ~spaPat[track][seq] == 1 }} // Range +1
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, { prevSpa = ~lastEvent[track][\prepspaA] });
					if (ev[\type] == 'note', { [(prevSpa+1).wrap(~spaMin[track][seq], ~spaMax[track][seq])] }, { [(prevSpa).wrap(~spaMin[track][seq], ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 18 and:  { ~spaPat[track][seq] == 1 }} // Range -1
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, { prevSpa = ~lastEvent[track][\prepspaA] });
					if (ev[\type] == 'note', { [(prevSpa-1).wrap(~spaMin[track][seq], ~spaMax[track][seq])] }, { [(prevSpa).wrap(~spaMin[track][seq], ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 19 and:  { ~spaPat[track][seq] == 1 }} // Range +2 // necessaire de relancer le bouton Pat pour que cela soit effectif et réinitialisé
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, { prevSpa = ~lastEvent[track][\prepspaA] });
					if (ev[\type] == 'note', { [(prevSpa+2).wrap(~spaMin[track][seq], ~spaMax[track][seq])] }, { [(prevSpa).wrap(~spaMin[track][seq], ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 20 and:  { ~spaPat[track][seq] == 1 }} // Range +2b // necessaire de relancer le bouton Pat pour que cela soit effectif et réinitialisé
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq]+1 }, { prevSpa = ~lastEvent[track][\prepspaA].max(~spaMin[track][seq]/*+1*/) });
					if (ev[\type] == 'note', { [(prevSpa+2).wrap(~spaMin[track][seq]+1, ~spaMax[track][seq])] }, { [(prevSpa).wrap(~spaMin[track][seq]+1, ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 21 and:  { ~spaPat[track][seq] == 1 }} // Range -2a
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, { prevSpa = ~lastEvent[track][\prepspaA] });
					if (ev[\type] == 'note', { [(prevSpa-2).wrap(~spaMin[track][seq], ~spaMax[track][seq])] }, { [(prevSpa).wrap(~spaMin[track][seq], ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 22 and:  { ~spaPat[track][seq] == 1 }} // Range -2b
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq]+1 }, { prevSpa = ~lastEvent[track][\prepspaA].max(~spaMin[track][seq]+1) });
					if (ev[\type] == 'note', { [(prevSpa-2).wrap(~spaMin[track][seq]+1, ~spaMax[track][seq]/*+1*/)] }, { [(prevSpa).wrap(~spaMin[track][seq]+1, ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 23 and:  { ~spaPat[track][seq] == 1 }} // Mir 1
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, {  /*~lastEvent[track][\prepspaA]*/ });
					if (ev[\type] == 'note', {~prevNb2[track] = ~prevNb2[track]+1; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq], ~spaMax[track][seq])] }, {~prevNb2[track] = ~prevNb2[track]; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq], ~spaMax[track][seq])] } ) }

				{~spaPatSel[track][seq] == 24 and:  { ~spaPat[track][seq] == 1 }} // Mir 2a
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq] }, {  /*~lastEvent[track][\prepspaA]*/ });
					if (ev[\type] == 'note', {~prevNb2[track] = ~prevNb2[track]+2; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq], ~spaMax[track][seq]-1)] }, {~prevNb2[track] = ~prevNb2[track]; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq], ~spaMax[track][seq]-1)] } ) }

				{~spaPatSel[track][seq] == 25 and:  { ~spaPat[track][seq] == 1 }} // Mir 2b
				{ if ( ~lastEvent[track] == 0, { prevSpa = ~spaMin[track][seq]+1 }, {  /*~lastEvent[track][\prepspaA]*/ });
					if (ev[\type] == 'note', {~prevNb2[track] = ~prevNb2[track]+2; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq]+1, ~spaMax[track][seq])] }, {~prevNb2[track] = ~prevNb2[track]; prevSpa = ~prevNb2[track]; [(prevSpa).fold(~spaMin[track][seq]+1, ~spaMax[track][seq])] } ) }

			})) /*.trace(prefix: "prepspaA -> ")*/,


			\prepspa, (Pfunc({ |ev| var seq = ~seqSeq[track];

				if (~harTrig[track][seq] == 1, {
					if (~multiStereo[track/*/2*/][seq] == 0, {
						ev.prepspaA ++ ~spaHarSpecStereo[track][seq].map( ~spaHarSeq[track][seq] ).asInteger
					},{
						ev.prepspaA ++ ~spaHarSpec[track][seq].map( ~spaHarSeq[track][seq] ).asInteger
					})
				},{
					ev.prepspaA
				})

				/*if (~harTrig[track][seq] == 1, {
				if (~multiStereo[track/*/2*/][seq] == 0, {
				ev.prepspaA ++ (0 ! ~spaHarSeq[track][seq].size)
				},{
				ev.prepspaA ++ ~spaHarSeq[track][seq]
				},{
				ev.prepspaA
				})
				})*/

			})) /*.trace(prefix: "prepspa -> ")*/,


			/*
			// Ci-dessous Mise en place de multiples chorus seulement dans le cas multiphonique - ci-dessus -> chorus aussi pour la version stéréo
			\prepspa, (Pfunc({ |ev| var seq = ~seqSeq[track];
			if (~multiStereo[track/2][seq] == 1,
			{ if (~harTrig[track][seq] == 1, { [(~spaSpec[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] ++ ~spaHarSeq[track][seq] }, { [(~spaSpec[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] }) },
			{ if (~harTrig[track][seq] == 1, { [(~spaSpecStereo[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] /*++ ~spaHarSeq[track][seq]*/ }, { [(~spaSpecStereo[track][seq].map(ev.prepspaU) * ~spaMul[track][seq]).asInteger] })}
			)})) /*.trace(prefix: "prepspa -> ")*/,
			*/

			\prepspa0, (Pfunc({ |ev| ev.prepspa[0] }) )/*.trace(prefix: "test -> ")*/,

			/*\prepspaH, (Pfunc({ |ev| var seq = ~seqSeq[track];
			if (~harTrig[track][seq] == 1, {[ev.prepspa] ++ ~spaHarSeq[track][seq]}, {[ev.prepspa]}) })) /*.trace(prefix: "prepspaH -> ")*/,*/

			/*
			// Test sans regroupement de la spatialisation Line Aller et Aller / retour en 1 seul synthé pour générer moins de synthés, mais un peu plus de CPU sur server
			\prepspa2, (Pfunc({ |ev| case
			{ev.prepspa == 0 and: {~stereoSpatType[track][~seqSeq[track]] == 0}} // panning stéréo d'intensité fixe
			{0}
			{ev.prepspa == 1} // panning stéréo d'intensité fixe avec délai
			{1}
			{ev.prepspa.inclusivelyBetween(2,3) and: {~stereoSpatType[track][~seqSeq[track]] == 0}} // panning stéréo d'intensité trajectoire
			{2}
			{ev.prepspa.inclusivelyBetween(4,5) and: {~stereoSpatType[track][~seqSeq[track]] == 0}} // panning stéréo d'intensité trajectoire Aller / Retour
			{3}
			{ev.prepspa == 0 and: {~stereoSpatType[track][~seqSeq[track]] == 1}} // panning stéréo VirtualMics
			{4}
			{ev.prepspa.inclusivelyBetween(2,3) and: {~stereoSpatType[track][~seqSeq[track]] == 1}} // panning stéréo VirtualMics trajectoire
			{5}
			{ev.prepspa.inclusivelyBetween(4,5) and: {~stereoSpatType[track][~seqSeq[track]] == 1}} // panning stéréo VirtualMics trajectoire Aller / Retour
			{6}
			{ev.prepspa == 0 and: {~stereoSpatType[track][~seqSeq[track]] == 2}} // panning stéréo spectral fixe
			{7}
			{ev.prepspa.inclusivelyBetween(2,3) and: {~stereoSpatType[track][~seqSeq[track]] == 2}} // panning stéréo spectral trajectoire
			{8}
			{ev.prepspa.inclusivelyBetween(4,5) and: {~stereoSpatType[track][~seqSeq[track]] == 2}} // panning stéréo spectral trajectoire Aller / Retour
			{9}
			{ev.prepspa.inclusivelyBetween(6,7)} // panning circulaire 1 tour
			{10}
			{ev.prepspa.inclusivelyBetween(8,13)} // panning circulaire multiple
			{11}
			{ev.prepspa.inclusivelyBetween(14,15)} // panning circulaire selon données sonores (centre spectral)
			{12}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~trajSpatType[track][~seqSeq[track]] == 0}} // panning VirtualMics selon données sonores
			{13}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~trajSpatType[track][~seqSeq[track]] == 1}} // panning Ambi selon données sonores
			{14}
			{ev.prepspa > 17 and: {~trajSpatType[track][~seqSeq[track]] == 0}} // panning VirtualMics selon trajectoires
			{15}
			{ev.prepspa > 17 and: {~trajSpatType[track][~seqSeq[track]] == 1}} // panning Ambi selon trajectoires
			{16}
			})),
			*/

			/*
			// Avant la mise en place d'une collection avec les chorus
			\prepspa2, (Pfunc({ |ev| var seq = ~seqSeq[track];
			case
			{ev.prepspa == 0 and: {~stereoSpatType[track][seq] == 0}} // panning stéréo d'intensité fixe
			{0}
			{ev.prepspa == 1} // panning stéréo d'intensité fixe avec délai
			{1}
			{ev.prepspa.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 0}} // panning stéréo d'intensité trajectoire
			{2}
			{ev.prepspa == 0 and: {~stereoSpatType[track][seq] == 1}} // panning stéréo VirtualMics
			{3}
			{ev.prepspa.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 1}} // panning stéréo VirtualMics trajectoire
			{4}
			{ev.prepspa == 0 and: {~stereoSpatType[track][seq] == 2}} // panning stéréo spectral fixe
			{5}
			{ev.prepspa.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 2}} // panning stéréo spectral trajectoire
			{6}
			{ev.prepspa.inclusivelyBetween(6,7) and: {~circSpatType[track][seq] == 0}} // panning circulaire 1 tour
			{7}
			{ev.prepspa.inclusivelyBetween(8,13) and: {~circSpatType[track][seq] == 0}} // panning circulaire multiple
			{8}
			{ev.prepspa.inclusivelyBetween(14,15)} // panning circulaire selon données sonores (centre spectral)
			{9}
			{ev.prepspa.inclusivelyBetween(6,7) and: {~circSpatType[track][seq] == 1}} // panning circulaire VBAP 1 tour max
			{10}
			{ev.prepspa.inclusivelyBetween(8,13) and: {~circSpatType[track][seq] == 1}} // panning circulaire VBAP multiple
			{11}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 0}} // panning VirtualMics selon données sonores
			{12}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 1}} // panning VBAP selon données sonores
			{13}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 2}} // panning VBAP Distance selon données sonores
			{14}
			{ev.prepspa.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 3}} // panning Ambi selon données sonores
			{15}
			{ev.prepspa > 17 and: {~trajSpatType[track][seq] == 0}} // panning VirtualMics selon trajectoires
			{16}
			{ev.prepspa > 17 and: {~trajSpatType[track][seq] == 1}} // panning Ambi selon trajectoires
			{17}
			{ev.prepspa > 17 and: {~trajSpatType[track][seq] == 2}} // panning Ambi selon trajectoires
			{18}
			})) /*.trace(prefix: "prepspa2 -> ")*/,

			\prepspaExt, (Pfunc({ |ev|
			case
			{ ev.prepspa2 == 2 } // panning Intensité Lines
			{ \stLine }
			{ ev.prepspa2.inclusivelyBetween(7, 9) } // panning circ
			{ \circ }
			{ ev.prepspa2.inclusivelyBetween(10, 11) } // panning circ VBAP
			{ \circVBAP }
			{ ev.prepspa2.inclusivelyBetween(3, 4) } // panning VirtualMics stéréo
			{ \vmSt }
			{ ev.prepspa2 == 12 } // panning VirtualMics SD
			{ \vmSD }
			{ ev.prepspa2 == 16 } // panning VirtualMics Traj
			{ \vmTraj }
			{ ev.prepspa2.inclusivelyBetween(13, 14) } // panning VBAP SD (polaire et cartésien)
			{ \vbSD }
			{ ev.prepspa2 == 17 } // panning VBAP Traj
			{ \vbTraj }
			{ ev.prepspa2 == 15 } // panning amb SD
			{ \ambSD }
			{ ev.prepspa2 == 18 } // panning amb Traj
			{ \ambTraj }
			{ ev.prepspa2.inclusivelyBetween(5, 6) } // panning spectral
			{ \spec }
			{ ev.prepspa2 >= 0 } // tout autre panning
			{ \others }
			})) /*.trace(prefix: "prepspaExt -> ")*/,
			*/

			\prepspa2, (Pfunc({ |ev| var seq = ~seqSeq[track];
				ev.prepspa.collect { |i|
					case
					{i == 0 and: {~stereoSpatType[track][seq] == 0}} // panning stéréo d'intensité fixe
					{0}
					{i == 1} // panning stéréo d'intensité fixe avec délai
					{1}
					{i.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 0}} // panning stéréo d'intensité trajectoire
					{2}
					{i == 0 and: {~stereoSpatType[track][seq] == 1}} // panning stéréo VirtualMics
					{3}
					{i.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 1}} // panning stéréo VirtualMics trajectoire
					{4}
					{i == 0 and: {~stereoSpatType[track][seq] == 2}} // panning stéréo spectral fixe
					{5}
					{i.inclusivelyBetween(2,5) and: {~stereoSpatType[track][seq] == 2}} // panning stéréo spectral trajectoire
					{6}
					{i.inclusivelyBetween(6,7) and: {~circSpatType[track][seq] == 0}} // panning circulaire 1 tour
					{7}
					{i.inclusivelyBetween(8,13) and: {~circSpatType[track][seq] == 0}} // panning circulaire multiple
					{8}
					{i.inclusivelyBetween(14,15)} // panning circulaire selon données sonores (centre spectral)
					{9}
					{i.inclusivelyBetween(6,7) and: {~circSpatType[track][seq] == 1}} // panning circulaire VBAP 1 tour max
					{10}
					{i.inclusivelyBetween(8,13) and: {~circSpatType[track][seq] == 1}} // panning circulaire VBAP multiple
					{11}
					{i.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 0}} // panning VirtualMics selon données sonores
					{12}
					{i.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 1}} // panning VBAP selon données sonores
					{13}
					{i.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 2}} // panning VBAP Distance selon données sonores
					{14}
					{i.inclusivelyBetween(16,17) and: {~sdSpatType[track][seq] == 3}} // panning Ambi selon données sonores
					{15}
					{i.inclusivelyBetween(18, 17+~allSpasGUIAmbi.size) and: {~trajSpatType[track][seq] == 0}} // panning VirtualMics selon trajectoires
					{16}
					{i.inclusivelyBetween(18, 17+~allSpasGUIAmbi.size) and: {~trajSpatType[track][seq] == 1}} // panning VBAP Distance selon trajectoires
					{17}
					{i.inclusivelyBetween(18, 17+~allSpasGUIAmbi.size) and: {~trajSpatType[track][seq] == 2}} // panning Ambi selon trajectoires
					{18}
					{i.inclusivelyBetween((18+~allSpasGUIAmbi.size), (17+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[0]))} // Acous 1
					{19}
					{i.inclusivelyBetween((18+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[0]), (17+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[1]))} // Acous 2
					{20}
					{i.inclusivelyBetween((18+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[1]), (17+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[2]))} // Acous 3
					{21}
					{i.inclusivelyBetween((18+~allSpasGUIAmbi.size+~bigStereoOutsSizes2[2]), (~allSpasGUIFinal.size -1))} // Acous 4
					{22}
				}
			})) /*.trace(prefix: "prepspa2 -> ")*/,

			// Pour l'externalisation des paramètres d'enveloppe avec Pchain

			\prepspaExt, (Pfunc({ |ev| var seq = ~seqSeq[track];
				ev.prepspa2.collect { |i, ind|
					case
					/*{ i == 2 } // panning Intensité Lines - plus utilisé puisque paramètres réintégrés dans le pattern global
					{ \stLine }*/
					{ i.inclusivelyBetween(7, 9) } // panning circ
					{ \circ }
					{ i.inclusivelyBetween(10, 11) } // panning circ VBAP
					{ \circVBAP }
					{ i.inclusivelyBetween(3, 4) } // panning VirtualMics stéréo
					{ \vmSt }
					{ i == 12 } // panning VirtualMics SD
					{ \vmSD }
					{ i == 16 } // panning VirtualMics Traj
					{ \vmTraj }
					{ i.inclusivelyBetween(13, 14) } // panning VBAP SD (polaire et cartésien)
					{ \vbSD }
					{ i == 17 } // panning VBAP Traj
					{ \vbTraj }
					{ i == 15 } // panning amb SD
					{ \ambSD }
					{ i == 18 } // panning amb Traj
					{ \ambTraj }
					{ i.inclusivelyBetween(5, 6) } // panning spectral
					{ \spec }
					{ i.inclusivelyBetween(19, 22) } // Acous
					{ ev.prepspa0 = ev.prepspa[ind]; /*ev.prepspa0.postln;*/ \acous } // Réécriture de ev.prepspa0 pour donner la bonne information à Acous
					{ i >= 0 } // tout autre panning
					{ \others }
				}
			})) /*.trace(prefix: "prepspaExt -> ")*/,





			// Liste des paramètres de spatialisation globalisés et externalisés selon le synthé de spatialisation

			// \panL (\panR) \spaSpeed (\spaSpeed0) \prepspa3 \trajBuf \trajBufDur -> globalisés

			// nil -> Stéréo Intensité Line

			// \outSpa \panCircMReg \panCircMVarMin \panCircMVarMax \freqMin \freqMax \freqCurve \circWidth -> spa circ
			// \outSpa \panCircMReg \panCircMVarMin \panCircMVarMax \freqMin \freqMax \freqCurve \spread \x2Off \delayUElev -> spa circVBAP

			// \dbRollOff \speakerRadius \pointScale -> spa VM Stéréo

			// \outSpa \dbRollOff \speakerRadius \pointScale \orientation \freqMin \freqMax \freqCurve \dbMin \dbMax \spaLagTime -> spa VM SD
			// \outSpa \dbRollOff \speakerRadius \pointScale \orientation \trajBufLoop \trajBufRatio -> spa VM Traj

			// \outSpa \spread \x2Off \dbRollOff \pointScale \delayUElev \freqMin \freqMax \freqCurve \dbMin \dbMax \spaLagTime -> spa VB SD
			// \outSpa \spread \dbRollOff \pointScale \trajBufLoop \trajBufRatio \delayUElev -> spa VB Traj

			// \outSpa \pointScale \spaLagTime \delayUElev \freqMin \freqMax \freqCurve \dbMin \dbMax -> spa ambisonique SD
			// \outSpa \pointScale \trajBufLoop \trajBufRatio delayUElev -> spa ambisonique Traj

			// \panSpectralCurve -> spa spectrale





			// Ci-dessous -> paramètres réintégrés dans le pattern global et non pas externalisé avec Pchain :
			// en raison du collect -> nécessaire de renvoyer un paramètre pour tous les multiples (bien que panR & spaSpeed0 pourraient être externalisés)

			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.odd, {1}, {-1} ) } })) /*.trace(prefix: "panL -> ")*/,
			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			// panning circulaire multiple - permet de sélectionner si panning circulaire régulier ou accélérant ou déccélérant - pas utile pour circ unique
			// aussi utilisé pour les lignes aller / retour :
			// \spaSpeed, (Pfunc({ |ev| ev.prepspa.collect { |i| if (i.inclusivelyBetween(2,3), {0}, {1} ) } }) ),
			\spaSpeed, (Pfunc({ |ev|
				ev.prepspa.collect { |i|
					case
					/*{i.inclusivelyBetween(2,3)} // pour les lines Aller ou Aller/retour
					{0}*/
					{i.inclusivelyBetween(4,5)} // pour les lines Aller ou Aller/retour
					{1}
					/*{i.inclusivelyBetween(8,9)} // Circ multiple régulier
					{0}*/
					{i.inclusivelyBetween(10,11)} // Circ multiple Acc
					{1}
					{i.inclusivelyBetween(12,13)} // Circ multiple Decc
					{2}
					{i >= 0 /*.inclusivelyBetween(6,7)*/} // Circ unique & autres
					{0}
				}
			})) /*.trace(prefix: "spaSpeed -> ")*/,

			// obligé de faire spaSpeed0 pour récuperer la 1ere valeur de spaSpeed qu il y ait des multiples ou pas
			// car ~lastEvent[~tab][\spaSpeed][0]; ne renvoie pas la bonne valeur lorsqu il y a des multiples -> renvoie la dernière valeur du chorus et non la première -> l'original
			\spaSpeed0, (Pfunc({ |ev| ev.spaSpeed[0] })) /*.trace(prefix: "spaSpeed0 -> ")*/,

			\prepspa3, (Pfunc({ |ev| ev.prepspa.collect { |i| i - 18 } })) /*.trace(prefix: "prepspa3 -> ")*/,
			\trajBuf, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[ev.serverNb][0][0] }, { ~trajectoryBuffers[ev.serverNb][i][0] }) } })) /*.trace(prefix: "trajBuf -> ")*/,
			// Pas besoin de \trajBuf0 ?????????
			// Durée réelle de la trajectoire du buffer
			\trajBufDur, (Pfunc({ |ev| ev.prepspa3.collect { |i| if (i < 0, { ~trajectoryBuffers[ev.serverNb][0][1] }, { ~trajectoryBuffers[ev.serverNb][i][1] }) } })) /*.trace(prefix: "trajBufDur -> ")*/,
			\trajBufDur0, (Pfunc({ |ev| ev.trajBufDur[0] })) /*.trace(prefix: "trajBufDur0 -> ")*/,




			// Supprimé car externalisation des paramètres d'enveloppe avec Pchain XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			/*
			\dbRollOff, (Pfunc({ |ev| ~dbRollOff[track][~seqSeq[track]] }) ) /*.trace(prefix: "dbRollOff -> ")*/,
			\speakerRadius, (Pfunc({ |ev| ~speakRad[track][~seqSeq[track]] }) ) /*.trace(prefix: "speakerRadius -> ")*/,
			\pointScale, (Pfunc({ |ev| ~pointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,
			\orientation, (Pfunc({ |ev| ~pointScale[track][~seqSeq[track]] }) ) /*.trace(prefix: "pointScale -> ")*/,

			\panSpectralMin, (Pfunc({ |ev| ~panSpectralMin }) ) /*.trace(prefix: "panSpectralMin -> ")*/,
			\panSpectralMax, (Pfunc({ |ev| ~panSpectralMax }) ) /*.trace(prefix: "panSpectralMax -> ")*/,

			\pointScale, (Pfunc({ ~ambPointScale[track][~seqSeq[track]] })) /*.trace(prefix: "trajLevelScale -> ")*/,
			\spaLagTime, Pfunc({ ~spaLagTime[track][~seqSeq[track]] }), // juste pour le lissage des spatialisations liées à l'analyse des paramètres spectraux ou d'intensité
			\outSpa, (Pkey(\prepfxL) * ~fxMulChannel)/*.trace(prefix: "outSpa -> ")*/,

			// Pour effectuer les trajectoires Gauche / Droite
			\panL, (Pfunc({ |ev|
			/*
			case
			{ev.prepspa.odd } // impair
			{1}
			{ev.prepspa.even } // pair
			{-1}
			*/
			if (ev.prepspa.odd, {1}, {-1} )
			})) /*.trace(prefix: "panL -> ")*/,

			\panR, (Pfunc({ |ev| ev.panL * (-1)	})) /*.trace(prefix: "panR -> ")*/,

			\trajBufLoop, Pfunc({ ~trajSpatLoop[track][~seqSeq[track]] }) /*.trace(prefix: "trajBufLoop -> ")*/,

			\prepspa3, (Pfunc({ |ev| ev.prepspa - 18 })) /*.trace(prefix: "prepspa3 -> ")*/,

			\trajBuf, (Pfunc({ |ev| if (ev.prepspa3 < 0, { ~trajectoryBuffers[0][0] }, { ~trajectoryBuffers[ev.prepspa3][0] }) })) /*.trace(prefix: "trajBuf -> ")*/,

			// Durée réelle de la trajectoire du buffer
			\trajBufDur, (Pfunc({ |ev| if (ev.prepspa3 < 0, { ~trajectoryBuffers[0][1] }, { ~trajectoryBuffers[ev.prepspa3][1] }) })) /*.trace(prefix: "trajBufDur -> ")*/,

			// indique la vistesse / ratio de lecture de la trajectoire (OLD)
			// \trajBufRatio, (Pfunc({ |ev| if (~spaTrajTime[track][~seqSeq[track]] == 0 or: {ev.durenv > ev.trajBufDur}, { (ev.durenv / ev.trajBufDur).reciprocal }, { 1 }) })) /*.trace(prefix: "trajBufDur -> ")*/,

			// \trajBufRat, Pfunc({ /*|ev|*/ ~trajRatio[track][~seqSeq[track]] }).trace(prefix: "trajBufRat -> "), // pas pris en compte ci-dessous avec ev.trajBufRat car manquait |ev| dans \trajBufRat XXX

			\trajBufRatio, (Pfunc({ |ev| var seq = ~seqSeq[track];
			case
			{~trajSpatTimeType[track][seq] == 0} // Adapt Time
			{ (ev.durenv / ev.trajBufDur).reciprocal }
			{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv > ev.trajBufDur}} // Trajectory Time
			{ (ev.durenv / ev.trajBufDur).reciprocal }
			{~trajSpatTimeType[track][seq] == 1 and: {ev.durenv <= ev.trajBufDur}} // Trajectory Time
			{ 1 }
			{~trajSpatTimeType[track][seq] == 2 } // Slider Time
			{ /*ev.trajBufRat*/ ~trajSpatRate[track][seq] }
			})) /*.trace(prefix: "trajBufRatio -> ")*/,

			// panning circulaire multiple - permet de sélectionner si panning circulaire régulier ou accélérant ou déccélérant / et si Aller ou Aller/retour
			\spaSpeed, (Pfunc({ |ev|
			case
			{ev.prepspa.inclusivelyBetween(0,1)} // ne sert à rien / juste pour produire une valeur
			{0}
			{ev.prepspa.inclusivelyBetween(2,3)} // Lines Aller
			{0}
			{ev.prepspa.inclusivelyBetween(4,5)} // Lines Aller / Retour
			{1}
			{ev.prepspa.inclusivelyBetween(6,7)} // Circ unique
			{0}
			{ev.prepspa.inclusivelyBetween(8,9)} // Circ multiple régulier
			{0}
			{ev.prepspa.inclusivelyBetween(10,11)} // Circ multiple Acc
			{1}
			{ev.prepspa.inclusivelyBetween(12,13)} // Circ multiple Decc
			{2}
			{ev.prepspa > 13}  // ne sert à rien / juste pour produire une valeur
			{0}
			})),
			*/





			// (Num de synthèse * Nb d'env * Nb de spat) +	Num d'enveloppe + (Num de spat * Nb d'env)
			\prepinstrument, ((Pkey(\prepsyn2) * ~allEnvsSize * ~allSpasSize) + Pkey(\prepenv2) + (Pkey(\prepspa2) * ~allEnvsSize)) /*.trace(prefix: "prepInstrument -> ")*/,

			\instrument, Pfunc({ |ev| ~instruments[ev[\prepinstrument]]}) /*.trace(prefix: "Instrument -> ")*/,
			// \instrument, ins,
			// \instrument, Ptuple([ins, ins2], inf), // voir le doublement du son avec 2 synthés ????????





			// \folder, folder,  // enables to to a crossfade since the Pdef is triggered thanks to fadeTime
			// \folder, ['kik', 'arma', 'hit', 'spec', 'froz', 'tram'].choose,
			/*\bufIndex1, 0,
			\bufIndex1, Pwhite(0, (~soundm[folder].size - 1), inf),
			\bufIndex2, Pwhite(0, (~soundm[folder].size - 1), inf),*/

			// \prepbuf,	(Pfunc({ |ev| var seq = ~seqSeq[track]; (~bufSpec[track][seq].map(ev.prepbufX) * ~bufMul[track][seq]) }))/*.trace(prefix: "buf Nb -> ")*/,
			\prepbuf,	(Pfunc({ |ev| var seq = ~seqSeq[track]; ((~bufSpec[track][seq].map(ev.prepbufX * ~bufMul[track][seq])).min(~bufFolderM[0][track][seq].size-1)).asInteger })) /*.trace(prefix: "buf Nb -> ")*/,
			// juste pour avoir le chiffre en visu -> peut être faux ???

			/*\buf, Pswitch([ Pfunc({ |ev| ~soundm[folder][ev[\bufIndex1]] }),  // 0 take each time 2 mono files L & R
			Pfunc({ |ev| ~soundm[ev[\folder]].choose }), // 1 simpler structure - take each time 2 mono files L & R
			Ptuple([ Pfunc({ |ev| ~soundm[folder][ev[\bufIndex1]][0] }), Pfunc({ |ev| ~soundm[folder][ev[\bufIndex2]][0] }) ], inf),  // 2 take each time 2 ≠ mono files L
			p {var buf; loop {buf = ~soundm[folder].choose; (~dur[track][0].size*4).do { buf.yield }}}, // 3 change the randomly chosen buffer each n times
			Pn(Pser(~soundm[folder].scramble, ~dur[track][0].size), inf), // 4 loop the randomly chosen buffers within a sequence comme le 6 Multislider
			Ptuple( [Pn(Pser(~soundm[folder].scramble, ~dur[track][0].size), inf), Pn(Pser(~soundm[folder].scramble, ~dur[track][0].size), inf)], inf), // 5 => 4 en doublé ???
			Pfunc({ |ev| ~soundm[folder][ev[\prepbuf]]}), // 6 pour MultiSlider
			], ~bufchoose[track][~seq1] ),*/
			// \buf, Pstutter((~nbEle[track][0]*4), Pfunc(~soundm[folder].choose)).trace, // change simply & efficiently the randomly chosen buffer each n times - not working ???????

			// Comment relancer le buffer seulement à la fin de la séquence ???
			// \buf, Pfunc({ |ev| ~bufFolder[track][~seqSeq[track]].flat[ev[\prepbuf]]}), // flat nécessaire pour obtenir la durée

			/*\bufs, Prout({ |ev| loop {
			~dur[track][~seqSeq[track]].size.do{|i|
			(~bufFolder[track][~seqSeq[track]].flat[ev[\prepbuf]]).yield;
			}}}), // flat nécessaire pour obtenir la durée
			// pour chargement des fichiers monos
			\bufm, Prout({ |ev| loop {
			~dur[track][~seqSeq[track]].size.do{|i|
			(~bufFolderM[track][~seqSeq[track]].flat[ev[\prepbuf]]).yield;
			}}}), // flat nécessaire pour obtenir la durée

			\bufs, Pfunc({ |ev| ~bufFolder[track][~seqSeq[track]].flat[ev[\prepbuf]] }),
			\bufm, Pfunc({ |ev| ~bufFolderM[track][~seqSeq[track]].flat[ev[\prepbuf]] }),*/

			/*\bufm, Pfunc({ |ev| ~bufFolderM[track][~seqSeq[track]].flat[ev.prepbuf * 2] }) /*.trace(prefix: "buf Name -> ")*/,
			\bufm2, Pfunc({ |ev| ~bufFolderM[track][~seqSeq[track]].flat[(ev.prepbuf * 2) + 1] }).trace(prefix: "buf Name -> "),*/

			\bufm, Pfunc({ |ev| ~bufFolderM[0][track][~seqSeq[track]][ev.prepbuf][0] }) /*.trace(prefix: "buf Name1 -> ")*/,
			\bufm2, Pfunc({ |ev| var seq = ~seqSeq[track]; ~bufFolderM[0][track][seq][ev.prepbuf][1] ? ~bufFolderM[0][track][seq][ev.prepbuf][0] }) /*.trace(prefix: "buf Name2 -> ")*/,

			// \bufm, Pfunc({ |ev| ~bufFolderM[track][~seqSeq[track]].flat[~bufSpec[track][~seqSeq[track]].map(ev.prepbufU) * ~bufMul[track][~seqSeq[track]] * 2] }) /*.trace(prefix: "buf Name -> ")*/,
			// \bufm2, Pfunc({ |ev| ~bufFolderM[track][~seqSeq[track]].flat[(~bufSpec[track][~seqSeq[track]].map(ev.prepbufU) * ~bufMul[track][~seqSeq[track]] * 2) + 1] }) /*.trace(prefix: "buf Name -> ")*/,
			// \bufm2, Pfunc({ |ev| ev.bufm.bufnum +1 }) /*.trace(prefix: "buf Num 2 -> ")*/,

			// \buflength, Pfunc({ |ev| ev.buf.numFrames}),
			\buflength, Pfunc({ |ev| ev.bufm.duration}),
			// \bufnumChannels, Pfunc({ |ev| ev.bufm.numChannels}).trace,

			// \bufdata, Pfunc({ |ev| ~soundData2[~arrayOfFolderPaths[~bufFolderValue[track][~seqSeq[track]]].folderName.asSymbol][~typeOfSorting][ev.prepbuf] }).trace,
			// ~soundm[~arrayOfFolderPaths[~bufFolderView.value].folderName.asSymbol]





			// Pour transfert des données vers Processing XXX
			\bufFolderValue, Pfunc({ ~bufFolderValue[track][~seqSeq[track]] }) /*.trace(prefix: "bufFolderValue -> ")*/,
			// Protection avec notNil au cas ou il n'y ait pas de structure de dossier défini
			\bufType, Pfunc({ |ev| if (~kindOfFoldersStructure.notNil, {~kindOfFoldersStructure[ev.bufFolderValue]}, {0} ) }) /*.trace(prefix: "bufType -> ")*/,





			// Pour récupérer le nom du buffer pour le PatternPlotter
			// "Buffer(3161, 6912, 1, 44100, /Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/knocker1.wav)".asString.split($ ).last.split($/).last.split($.)[0]
			// \bufm2, Pfunc({ |ev| ev.bufm.class }).trace,
			// \bufm2, Pfunc({ |ev| ev.bufm.filename.splitext[0].basename }).trace,
			// \bufm3, Pfunc({ |ev| ev.bufm.asString.split($ ).last.split($/).last.split($.)[0] }) /*.trace*/,





			// \durenv, Pkey(\dur) * Pkey(\stretch) * Pkey(\legato), // durée de l'enveloppe du son par rapport à la durée de déclenchement - si 1 pas de superposition de son
			// Pourquoi .isNegative ne marche pas sur ev.rate ???
			// peut-être parce que ev.rate.postln donne noncontrol ???
			// Attention : durée de synthèse bloquée à 30 sec max
			// if(msg[1].exclusivelyBetween(1.0, 10.0)) {...}

			/*\durenv, Pfunc({ |ev| if (ev.prepsyn < 8, {
			min(30, min((ev.dur * ev.stretch * ev.legato),
			(if ((ev.rate2/*.asFloat.postln*/ < 0), {((ev.buflength * ev.offset) / ev.preprate)}, {(ev.buflength * (1 - ev.offset) / ev.preprate;)})) ))},
			{min (5, (ev.dur * ev.legato))} ) }) /*.trace*/,*/

			/*
			1 * (1 - 0.8) / (2)
			1 * (0.8) / (2)
			*/





			// Pour la péparation des chorus ?????????
			/*
			\test2, Pfunc({ |ev| (ev.preprate2.every ({ |item, i| (item < 0)/*.postln*/ }) ) })/*.trace*/,
			\test, Pfunc({ |ev| (ev.preprate2.every ({ |item, i| (item == 0)/*.postln*/ }) ) })/*.trace*/,
			*/





			// Actuellement pas de calcul de durée pour chacun des multiples chorus, mais seulement une seule durée qui est dupliquée
			// (comme pour preprate2 qui détermine si la vitesse de lecture est négative ou non)

			\durenv, Pfunc({ |ev| case

				// or: {ev.rater.isFloat == false} // protection si bus de controle sur rate
				{ev.prepsyn2 == 6 or: { ev.prepsyn2 == 15 } or: {ev.rater.isArray == false}} { min(~maxSynthTime, ev.sustain) } // pour BufMR & SR

				/*
				~allSynthsGUI[16]
				*/

				{ev.prepsyn2 == 8 /*or: { ev.prepsyn2 == 17 }*/ or: { ev.prepsyn2 == 39 } /*or: { ev.prepsyn2 == 42 }*/ and: { ev.loop2 == 0 } } // Pour WarpM / WarpS / WarpMGliss / WarpSGliss
				// WarpS & WarpSGliss sont des Ugen Warp0 et non un granulateur fait maison comme dans la version mono

				/*
				Quel algo est le + efficace ? Apparemment équivalent ...
				bench {100000.do {if (a == 8 or: { a == 17 } or: { a == 39 } or: { a == 42 } and: { b == 0 }, {x = 1}, {x = 1} )} } // Pour WarpM / WarpS / WarpMGliss / WarpSGliss
				bench {100000.do {if ([8, 17, 39, 42].includes(a) and: { b == 0 }, {x = 1}, {x = 1} )} } // Pour WarpM / WarpS / WarpMGliss / WarpSGliss
				*/

				{
					min(~maxSynthTime, min((ev.sustain),
						// (if (ev.preprate2 < 0, {(ev.buflength * ev.offset) / ev.preprate}, {(ev.buflength * (1/*1.01*/ - ev.offset) / ev.preprate)})) )) }
						(if (ev.rate0 < 0,
							{if (ev.rate0.abs /*preprateH[0]*/ == 0, {0}, {(ev.buflength * ev.offset) / ev.preprateH * ev.stretcher}) },
							{if ( (ev.buflength * (1 - ev.offset) / ev.rate0.abs /*preprateH[0]*/).isNaN or: {ev.rate0.abs /*preprateH[0]*/ == 0}, {0}, {(ev.buflength * (1 - ev.offset) / ev.preprateH * ev.stretcher)}) })
				) )) }

				{ev.prepsyn2.inclusivelyBetween(0, 17) and: { ev.loop2 == 0 } }
				// BufM, BufMVar, BufMVar2, BufMPitch, BufMPitchVar, BufMPitchVar2, BufMR, BufMRoll, (WarpM) -> de 0 à 7 & stéréo de 9 à 16
				// Buffer -> max 30s / 15 secondes ????????? sinon durée du buffer à l'endroit ou à l'envers

				/*
				{
				min(30, min((ev.sustain),
				// (if (ev.preprate2 < 0, {(ev.buflength * ev.offset) / ev.preprate}, {(ev.buflength * (1/*1.01*/ - ev.offset) / ev.preprate)})) )) }
				(if (ev.preprate2 < 0,
				{if (ev.preprate == 0, {0}, {(ev.buflength * ev.offset) / ev.preprate}) },
				{if ( (ev.buflength * (1 - ev.offset) / ev.preprate).isNaN or: {ev.preprate == 0}, {0}, {(ev.buflength * (1 - ev.offset) / ev.preprate)}) })
				) )) }
				*/
				// Le offset en random peut provoquer l'arrêt du pattern -> mise en place de 1.01 au cas ou pour éviter nan ou d'une condition XXXXXXXXXXXXXXXXXXXXXXXXXXX
				// ((1 - 1) / 0) ou si preprate = 0
				// ((1 - 1) / 0).isNaN

				/*
				{ 100000.do { [-2, 1, 2, 3][0] } }.bench
				{ 100000.do { -2.abs } }.bench
				*/
				{
					min(~maxSynthTime, min((ev.sustain),
						// (if (ev.preprate2 < 0, {(ev.buflength * ev.offset) / ev.preprate}, {(ev.buflength * (1/*1.01*/ - ev.offset) / ev.preprate)})) )) }
						(if (ev.rate0 < 0,
							{if (ev.rate0.abs /*preprateH[0]*/ == 0, {0}, {(ev.buflength * ev.offset) / ev.preprateH}) },
							{if ( (ev.buflength * (1 - ev.offset) / ev.rate0.abs /*preprateH[0]*/).isNaN or: {ev.rate0.abs /*preprateH[0]*/ == 0}, {0}, {(ev.buflength * (1 - ev.offset) / ev.preprateH)}) })
				) )) }

				{ev.prepsyn2.inclusivelyBetween(0, 17) and: { ev.loop2 == 1 } } {
					// BufM, BufMVar, BufMVar2, BufMPitch, BufMPitchVar, BufMPitchVar2, BufMR, BufMRoll, (WarpM) -> de 0 à 7 & stéréo de 9 à 16
					// Buffer -> max 30s / 15 secondes ?????????
					min(~maxSynthTime, ev.sustain) }

				{ev.prepsyn2.inclusivelyBetween(18, 23)} {
					// Gran & In : GrainBuf, ConcatBufSig, ConcatBufIn, ConcatInSig, GrainIn, WarpIn -> max 10s
					min(10, (ev.sustain)) }

				{ev.prepsyn2.inclusivelyBetween(24, 28)} {
					// Synth : SineFB, Blip, PMOsc, GrainSin, GrainFM -> max 10s
					min(10, (ev.sustain)) }

				{ev.prepsyn2.inclusivelyBetween(29, 31)} {
					// Synth (note) : UpPiano, Acid_Oto, String_Oto, (Guit_Oto) -> max 10s
					min(10, (ev.sustain)) }

				{ev.prepsyn2.inclusivelyBetween(32, 36)} {
					// Synth Oto : Kik_Oto, Snare_Oto, Clap_Oto, Hat_Oto, Electribe -> max 5s
					min(5, (ev.sustain)) }

				{ev.prepsyn2.inclusivelyBetween(37, 42)} {
					// Glissando : BufMGliss, BufMPitchGliss, (WarpMGliss), BufSGliss, BufSPitchGliss, (WarpSGliss)
					min(~maxSynthTime, min((ev.sustain),
						(if (ev.rate0 /*preprate2[0]*/ < 0, // avant l'externalisation de RAT2 -> rate2 était utilisé -> à vérifier ??????????????????????????????????????????????????????
							// {(ev.buflength * ev.offset) / ev.preprate},
							{if (ev.rate0.abs /*preprateH[0]*/ == 0, {0}, {(ev.buflength * ev.offset) / ev.preprateH}) },
							// {(ev.buflength * (1 - ev.offset) / ev.preprate)}
							{if ( (ev.buflength * (1 - ev.offset) / ev.rate0.abs /*preprateH[0]*/).isNaN or: {ev.rate0.abs /*preprateH[0]*/ == 0}, {0}, {(ev.buflength * (1 - ev.offset) / ev.preprateH)}) })
				) )) }

				{ev.prepsyn2 > 42} {
					// les 2 derniers Glissando : GrainBufGliss & PMOscGliss
					min(10, (ev.sustain)) }

			}) /*.trace(prefix: "durenv -> ")*/,
			// pour économiser du `CPU serveur lorsque la durée d'envelope est trop longue par rapport à la durée du son
			/*
			~allSynthsGUI[37] // pour check de l'intitulé des synthés
			*/

			// obligé de faire durenv0 pour récuperer la 1ere valeur de durenv qu'il y ait des multiples ou pas
			// car ~lastEvent[~tab][\durenv][0]; ne renvoie pas la bonne valeur lorsqu il y a des multiples -> renvoie la dernière valeur du chorus et non la première -> l'original

			// \durenv0, (Pfunc({ |ev| ev.durenv[0] }) ) /*.trace(prefix: "durenv0 -> ")*/, // juste pour visualisation
			\durenv0, (Pfunc({ |ev| if (ev.durenv.isArray, { ev.durenv[0] }, {ev.durenv} ) })) /*.trace(prefix: "durenv0 -> ")*/, // juste pour visualisation





			\delayTime, (Pfunc({ |ev| var seq = ~seqSeq[track]; ~delSpec[track][seq].map(ev.delayX /** ~delMul[track][seq] intégré dans delayX*/ )})) /*.trace(prefix: "delay -> ")*/,





			// \pan2, (Pfunc({ |ev| ~panSpec[track][~seqSeq[track]].map(ev.panU) * ~panMul[track][~seqSeq[track]]})) /*.trace(prefix: "panning -> ")*/,

			\pan, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				{~panPatSel[track][seq] < ~controlBus0  or:  { ~panPat[track][seq] == 0 }} {~panSpec[track][seq].map(ev.panX)}
				{~panPatSel[track][seq] == ~controlBus0 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][0].asMap}
				{~panPatSel[track][seq] == ~controlBus1 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][1].asMap}
				{~panPatSel[track][seq] == ~controlBus2 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][2].asMap}
				{~panPatSel[track][seq] == ~controlBus3 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][3].asMap}
				{~panPatSel[track][seq] == ~controlBus4 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][4].asMap}
				{~panPatSel[track][seq] == ~controlBus5 and: { ~panPat[track][seq] == 1 }} {~controlBus[ev.serverNb][5].asMap} })) /*.trace(prefix: "panning -> ")*/,





			/*\prepoutL, (Pfunc({ |ev| if (~multiStereo[track][~seqSeq[track]] == 0, {~outLRound[track/2][~seqSeq[track]]}, {~outLSpec[track][~seqSeq[track]].map(ev.prepoutLU) * ~outLMul[track][~seqSeq[track]]})})) /*.trace(prefix: "prepOutL -> ")*/,*/

			// \prepoutLtest, (Pfunc({ |ev| ev.prepoutL.class.postln })).trace, // On obtient à la sortie un float

			\prepoutL2, (Pfunc({ |ev| var prevOutL, seq = ~seqSeq[track] /*, prevNb*/;
				case

				{ ~multiStereo[track][seq] == 0 } // Stereo
				{ /*[*/~outLRound[track/*/2*/][seq]/*]*/ /*[ev.prepoutL2]*/ }

				{~outLPatSel[track][seq] < ~controlBus0  or:  { ~outLPat[track][seq] == 0 }}
				{~outsOrganization[~outLSpec[track][seq].map(ev.prepoutLX)]}

				{~outLPatSel[track][seq] == ~controlBus0 and: { ~outLPat[track][seq] == 1 }} // Seq +1
				{ if ( ~lastEvent[track] == 0, { prevOutL = 1 }, { prevOutL = ~lastEvent[track][\prepoutL2] }); /*prevOutL = ~lastEvent[track][\prepoutL2] ? 1*/ /*prevOutL.postln;*/
					if (ev[\type] == 'note', { (prevOutL).mod(~numChannels)+1 }, { (prevOutL).mod(~numChannels) } ) }
				// {if (~multiStereo[track][seq] == 0, {~outLRound[track/2][seq]}, {~outL[track][seq].size.do{|i| ~outList.wrapAt(i) } })} // autre méthode de faire Seq +1 mais pour fonctionner routine nécessaire ou alors utlisation de ~prevNb qui est toujours incrémenté de 1 - voire plus bas miroir - mais pas terrible car nécessaire d'ajouter une variable d'environnement - à optimiser - mais l'intérêt vs une routine est qu'il peut être arrêté à tout moment ?????????

				{~outLPatSel[track][seq] == ~controlBus1 and: { ~outLPat[track][seq] == 1 }} // Seq -1
				{ /*prevOutL = ~lastEvent[track][\prepoutL2] ? 0;*/ if ( ~lastEvent[track] == 0, { prevOutL = 1 }, {prevOutL = ~lastEvent[track][\prepoutL2] });
					if (ev[\type] == 'note', { (prevOutL-1).asInteger.wrap(1,~numChannels) }, { (prevOutL).asInteger.wrap(1,~numChannels) } ) }

				{~outLPatSel[track][seq] == ~controlBus2 and: { ~outLPat[track][seq] == 1 }} // Seq +2
				{ /*prevOutL = ~lastEvent[track][\prepoutL2] ? 0;*/ if ( ~lastEvent[track] == 0, { prevOutL = 1 }, {prevOutL = ~lastEvent[track][\prepoutL2] });
					if (ev[\type] == 'note', { (prevOutL+2).asInteger.wrap(1,~numChannels) }, { (prevOutL).asInteger.wrap(1,~numChannels) } ) }

				{~outLPatSel[track][seq] == ~controlBus3 and: { ~outLPat[track][seq] == 1 }} // Seq -2
				{ /*prevOutL = ~lastEvent[track][\prepoutL2] ? 0;*/ if ( ~lastEvent[track] == 0, { prevOutL = 1 }, {prevOutL = ~lastEvent[track][\prepoutL2] });
					if (ev[\type] == 'note', { (prevOutL-2).asInteger.wrap(1,~numChannels) }, { (prevOutL).asInteger.wrap(1,~numChannels) } ) }

				{~outLPatSel[track][seq] == ~controlBus4 and: { ~outLPat[track][seq] == 1 }} // Seq +1 & -1 (en miroir)
				{ if (ev[\type] == 'note', { ~prevNb[track] = ~prevNb[track]+1 }, { ~prevNb[track] = ~prevNb[track] } ); /*~prevNb[track].postln;*/ ~outList.foldAt(~prevNb[track]) }
			})) /*.trace(prefix: "prepOutL2 -> ")*/,

			\prepoutL3, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				/*{ ~multiStereo[track][seq] == 0 } // Stereo
				{ [~outLRound[track/*/2*/][seq]] /*[ev.prepoutL2]*/ }*/

				{ ~harTrig[track][seq] == 0 } // Pas de chorus
				{ [ev.prepoutL2] }
				{ ~harTrig[track][seq] == 1  and: { ~outLHarSpatType[track][seq] == 0 }} // Tous les chorus sur la même sortie
				{ [ev.prepoutL2] }
				{ ~harTrig[track][seq] == 1  and: { ~outLHarSpatType[track][seq] == 1 }} // Tous les chorus sur les sorties suivantes
				{ (ev.prepoutL2..ev.prepoutL2 + ~seqDurRatHar[track][seq]).wrap(~outLMin[track][seq], ~outLMax[track][seq]/*+1*/ /*0, ~numChannelsChorus-1*/) }
				{ ~harTrig[track][seq] == 1  and: { ~outLHarSpatType[track][seq] == 2 }} // Tous les chorus sur les sorties aléatoires
				{ [ev.prepoutL2] ++ ({/*~numChannelsChorus*/ ~outLMax[track][seq].asInteger.rand} ! ~seqDurRatHar[track][seq]).wrap(~outLMin[track][seq], ~outLMax[track][seq]/*+1*/ /*0, ~numChannelsChorus-1*/) }
			})) /*.trace(prefix: "prepoutL3 -> ")*/,
			/*
			(5..5+~ratHar[0][0].size).wrap(0, ~numChannels-1) // pour succession
			[5]++({~numChannels.rand} ! ~ratHar[0][0].size).wrap(0, ~numChannels-1) // // pour aléatoire
			*/





			// \prepoutR, (Pfunc({ |ev| if (~multiStereo[track][~seqSeq[track]] == 0, {~outRRound[track/2][~seqSeq[track]]}, {~outRSpec[track][~seqSeq[track]].map(ev.prepoutRU) * ~outRMul[track][~seqSeq[track]]})})) /*.trace(prefix: "prepOutR -> ")*/,

			\prepoutR2, (Pfunc({ |ev| var outList, seq = ~seqSeq[track];
				case
				{ ~multiStereo[track][seq] == 0 } // Stereo
				{ /*[*/~outRRound[track/2][seq]/*]*/ /*[ev.prepoutR2]*/ }
				{~outRPatSel[track][seq] < ~controlBus0  or:  { ~outRPat[track][seq] == 0 }}
				{ ~outsOrganization[~outRSpec[track][seq].map(ev.prepoutRX)] }
				{~outRPatSel[track][seq] == ~controlBus0 and: { ~outRPat[track][seq] == 1 }} // +1
				{ ev[\prepoutL2].mod(~numChannels)+1 }
				{~outRPatSel[track][seq] == ~controlBus1 and: { ~outRPat[track][seq] == 1 }} // -1
				{ (ev[\prepoutL2]-1).asInteger.wrap(1,~numChannels) }
				{~outRPatSel[track][seq] == ~controlBus2 and: { ~outRPat[track][seq] == 1 }} // +1/4
				{ (ev[\prepoutL2]+~unQuart).asInteger.wrap(1,~numChannels) }
				{~outRPatSel[track][seq] == ~controlBus3 and: { ~outRPat[track][seq] == 1 }} // -1/4
				{ (ev[\prepoutL2]-~unQuart).asInteger.wrap(1,~numChannels) }
				{~outRPatSel[track][seq] == ~controlBus4 and: { ~outRPat[track][seq] == 1 }} // opposé
				{ (ev[\prepoutL2]+~oppo).asInteger.wrap(1,~numChannels) }
				{~outRPatSel[track][seq] == ~controlBus5 and: { ~outRPat[track][seq] == 1 }} // différent de OutL
				{ outList = ~outList.copy; outList.remove(ev[\prepoutL2].asInteger); outList.choose }
			})) /*.trace(prefix: "prepOutR2 -> ")*/,

			// \test, (Prout({ |ev| loop{ ev = (ev[\prepoutL]+1)/*.debug("\ngot number from event")*/.yield } } )).trace,
			// \test, (Prout({ |ev| loop{ if (~multiStereo[track][~seqSeq[track]] == 0, {~outLRound[track/2][~seqSeq[track]].yield}, {ev = ((ev[\prepoutL]+1).mod(~numChannels)).yield }) } })).trace,

			// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/How-to-access-to-event-in-Prout-td6546757.html
			// incorrect ??????????????????????????????????????????
			/*
			p = Pbind(
			\type, \rest,
			\number, Pseries(0, 1, 5),
			\rout, Prout({ |ev|
			loop {
			ev[\number].debug("\ngot number from event");
			(ev[\number] * 2).yield
			}
			}),
			\dur, 0.1
			).trace.play;
			*/
			// correct
			/*
			p = Pbind(
			\type, \rest,
			\number, Pseries(0, 1, 5),
			\rout, Prout({ |ev|
			loop {
			ev[\number].debug("\ngot number from event");

			// don't forget "ev = " for the yield
			ev = (ev[\number] * 2).yield
			}
			}),
			\dur, 0.1
			).trace.play;
			*/

			\prepoutR3, (Pfunc({ |ev| var seq = ~seqSeq[track];
				case
				/*{ ~multiStereo[track][seq] == 0 } // Stereo
				{ [~outRRound[track/2][seq]] /*[ev.prepoutR2]*/ }*/

				{ ~harTrig[track][seq] == 0 } // Pas de chorus
				{ [ev.prepoutR2] }
				{ ~harTrig[track][seq] == 1  and: { ~outRHarSpatType[track][seq] == 0 }} // Tous les chorus sur la même sortie
				{ [ev.prepoutR2] }
				{ ~harTrig[track][seq] == 1  and: { ~outRHarSpatType[track][seq] == 1 }} // Tous les chorus sur les sorties suivantes
				{ (ev.prepoutR2..ev.prepoutR2 + ~seqDurRatHar[track][seq]).wrap(~outRMin[track][seq], ~outRMax[track][seq]/*+1*/ /*0, ~numChannelsChorus-1*/) }
				{ ~harTrig[track][seq] == 1  and: { ~outRHarSpatType[track][seq] == 2 }} // Tous les chorus sur les sorties aléatoires
				{ [ev.prepoutR2] ++ ({/*~numChannelsChorus*/ ~outRMax[track][seq].asInteger.rand} ! ~seqDurRatHar[track][seq]).wrap(~outRMin[track][seq], ~outRMax[track][seq]/*+1*/ /*0, ~numChannelsChorus-1*/) }
			})) /*.trace(prefix: "prepoutR3 -> ")*/,





			\prepoutL, (Pfunc({ |ev|
				if (~outRevCompChoose[track][~seqSeq[track]] == 0,
					{ev.prepoutL3}, {ev.prepoutR3})
			})) /*.trace(prefix: "L -> ")*/,

			\prepoutR, (Pfunc({ |ev|
				if (~outRevCompChoose[track][~seqSeq[track]] == 0,
					{ev.prepoutR3}, {ev.prepoutL3})
			})) /*.trace(prefix: "R -> ")*/,





			// \prepfxL, (Pfunc({ |ev| ~fxLSpec[track][~seqSeq[track]].map(ev.prepfxLU) * ~fxLMul[track][~seqSeq[track]]})), /*.trace(prefix: "prepfxL -> ")*/

			\prepfxL, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~fxSelControlValue[track/2] == 0, {
					~fxLSpec[track][seq].map(ev.prepfxLU * ~fxLMul[track][seq])},
				{~fxSelControlValue[track/2]-1} )
			})) /*.trace(prefix: "prepfxL -> ")*/,



			// \prepfxR, (Pfunc({ |ev| ~fxRSpec[track][~seqSeq[track]].map(ev.prepfxRU) * ~fxRMul[track][~seqSeq[track]]})), /*.trace(prefix: "prepfxR -> ")*/

			\prepfxR, (Pfunc({ |ev| var seq = ~seqSeq[track];
				if (~fxSelControlValue[track/2] == 0, {
					~fxRSpec[track][seq].map(ev.prepfxRU * ~fxRMul[track][seq])},
				{~fxSelControlValue[track/2]-1} )
			})) /*.trace(prefix: "prepfxR -> ")*/,





			/*\outL, Pif((Pkey(\prepfxL) <= 0),
			(Pkey(\prepoutL) - 1),
			// (Pkey(\prepoutL) * 10 + 4),
			(Pkey(\prepoutL) * 10) + (Pkey(\prepfxL) - 1))/*.trace(prefix: "L -> ")*/,*/
			// Changement de l'ordre des effets pour intégrer des effets dans spatialisations multicanales - plus seulement stéréo

			\outL, Pif((Pkey(\prepfxL) <= 0),
				(Pkey(\prepoutL) - 1),
				(Pkey(\prepoutL) - 1) + (Pkey(\prepfxL) * ~fxMulChannel)) /*.trace(prefix: "L -> ")*/,

			\outR, Pif((Pkey(\prepfxR) <= 0),
				(Pkey(\prepoutR) - 1),
				(Pkey(\prepoutR) - 1) + (Pkey(\prepfxR) * ~fxMulChannel)) /*.trace(prefix: "R -> ")*/,





			// stéréo
			/*
			\out, Ptuple([
			Pseq([0, 1, 10, 11, 12, 13], inf),
			Pseq([1, 0, 23, 22, 21, 20], inf)
			], inf),
			\out, Ptuple([
			Pseq([0, 1], inf),
			Pseq([1, 0], inf)
			], inf)*/
			// 5.1
			/*\out, Ptuple([
			Pseq([0, 1, 2, 3, 4, 10, 11, 12, 13, 20, 21, 22, 23, 30, 31, 32, 33, 40, 41, 42, 43, 50, 51, 52, 53], inf),
			Prand([0, 1, 2, 3, 4, 10, 11, 12, 13, 20, 21, 22, 23, 30, 31, 32, 33, 40, 41, 42, 43, 50, 51, 52, 53], inf)
			], inf),
			\out, Ptuple([
			Pfin(~dur[track][~seq1].size, Pseq([0, 1, 2, 3, 4], inf)),
			Pfin(~dur[track][~seq1].size, Pxrand([0, 1, 2, 3, 4], inf))
			], inf)
			*/





			// Retrait du Bookkeeping des NodeID car blocage des OSC quand rupture de la communication entre le langage et le server
			// \do, (Pfunc(~getID.(~listID[track])) )/*.trace*/,





			// à décommenter la 2ème ligne pour Visualisation Graphique avec RedUniverseParticles
			// \finish, Pfunc{|ev| ~createObj.value}
			// \finish, Pfunc({|ev| if (ev.dur >= ~minTimeParticlesVisual and: {ev.type == 'note'}, { ~createObj.value(dur: min(~maxTimeParticlesVisual*25, ev.durenv*25), y: ev.preprateU.linlin(0, 1, 1, 0), x: ev.prepbufU.linlin(0, 1, 0, 1) /*, size: ev.dur*20*/ ) }, {1}); })





	))
};




















// Play Function

~play = { | npdef, track, nfade, pfade, quant, stretchdur, collect |


	// Mailing list -> Pif and strings XXXXXX
	/*
	I often need to run one pattern for basic parameters (e.g. timing or pitch), where events may use different SynthDefs.
	Then I want to add other parameters that are specific to each SynthDef. Usually I do it like this:

	p = Pchain(
	Psym1(Pkey(\instrument), ( // It should be Pnsym1 ?
	defname1: Pbind(...),
	defname2: Pbind(...),
	etc...
	)),
	Pbind(
	\instrument, ... pattern returning names as Symbols ...,
	\dur, ... etc...
	)
	);

	Note that synthdef names should be \symbols in this case, not "strings."
	I'd say, if you have more than 2 or 3 Pifs, consider this approach because it scales up easily to dozens of synthdefs and parameters.
	hjh
	*/


	// Pdef(npdef).envir_(npdef); // ???

	Pdef(npdef).fadeTime = pfade;
	Pdef(npdef).quant_(quant);

	// Pdef(npdef, ~pattern.(track, stretchdur)).play(~gblTempo);

	Pdef(npdef, Pchain(

		~patternSyn.(track),
		~patternEnv.(track),
		~patternSpa.(track),
		~patternCore.(track, stretchdur)

	).collect({ |event| ~lastEvent[track] = event; /*NodeWatcher.register(~lastEvent[track][\id][0].asNodeID);*/


		// Pour l'update rythmique de l'Akai APC mini
		if (~aControllerConnected == 1, {
			// if (Pdef(~patterns2[track]).isPlaying, {
			// if ((~akaiRtm[track] != ~posRtm[track][~seqSeq[track]/*~currentSeq*/] and: {~lastEvent[track][\type] == 'note'} )/*.postln*/, {
			if (~lastEvent[track][\type] == 'note' and: { ~akaiRtm[track] != ~posRtm[track][~seqSeq[track]/*~currentSeq*/] }, {
				var akTrack = (track/2).asInteger;
				/*
				/*~lastEvent[track]*/event[\dur] .postln;
				~lastEvent[track][\mulCopies].postln; // ~akaiRtm necessaire pour ne pas prendre en compte les multiples
				~lastEvent[track][\prepspa].postln;
				*/
				if ( ~lastEvent[track][\dur] < 0.02, {
					if (~aController.padInternalState[0,akTrack] == 0, { ~aController.setState(0,akTrack,1); /*"yeh".postln;*/ })
				},{
					if ( ~aController.padInternalState[0,akTrack] == 0, { ~aController.setState(0,akTrack,1) }, { ~aController.setState(0,akTrack,0) });
					/*
					if ( ~aController.padInternalState[0,~tab] == 0, { ~aController.setState(0,~tab,0); ~aController.setPadHoldColor(0,~tab,\green); ~aController.setState(0,~tab,1) }, { ~aController.setState(0,~tab,0); ~aController.setPadHoldColor(0,~tab,\red); ~aController.setState(0,~tab,1) });
					*/
				});
			});
			~akaiRtm[track] = ~posRtm[track][~seqSeq[track]/*~currentSeq*/];
			// });
			/*
			~aController.padColorsOfStates[0,2]
			*/
		});


		// ~lastEvent[~tab][\offset].postln;
		// Pour envoi vers Processing
		// ~processingAddress.sendMsg(\test, ~lastEvent[0]); // transfert de données illisible dans Processing ?????????
		// ~processingAddress.sendMsg(\test, ~lastEvent[~tab][\type], ~lastEvent[~tab][\rater]); // transfert de tous les évenèements générés
		// faire qqch des évènements qui ne génèrent pas de son -> visualisation de potentiels avortés ?????????
		// Pourquoi pas d'envoi de données quand utilisation d'un dossier test ?????????

		// ~processingAddress = NetAddr("127.0.0.1", 12000); // A décommenter pour Processing  XXXXXXXX

		if (~visualizeProcessing == 1 and: {~lastEvent[track][\type] == 'note'},
			{
				~processingAddress.sendMsg(\event,
					~lastEvent[track][\durenv] /*[\durenv0]*/,
					track,
					~lastEvent[track][\prepsyn].asInteger,
					~lastEvent[track][\amp], // Utilisation de \amp pour données des bus
					~lastEvent[track][\prepenv].asInteger,
					~lastEvent[track][\preprateU],
					~lastEvent[track][\preprate], // Utilisation de \rate2 pour valeurs négatives selon offset & \rater pour données des bus // [\rate0]
					~lastEvent[track][\bufType].asString,
					~lastEvent[track][\bufFolderValue],
					~lastEvent[track][\prepbufU],
					~lastEvent[track][\prepbuf],
					~lastEvent[track][\offset],
					~lastEvent[track][\stretcherU],
					~lastEvent[track][\centerU],
					~lastEvent[track][\prepspa].asInteger, // [\prepspa0]
					~lastEvent[track][\panU],
					~lastEvent[track][\prepoutL].asInteger,
					~lastEvent[track][\prepoutR].asInteger,
					~lastEvent[track][\prepfxL].asInteger,
					~lastEvent[track][\prepfxR].asInteger,
				);

				/*[
				~lastEvent[track][\durenv] /*[\durenv0]*/,
				track,
				~lastEvent[track][\prepsyn].asInteger,
				~lastEvent[track][\amp], // Utilisation de \amp pour données des bus
				~lastEvent[track][\prepenv].asInteger,
				~lastEvent[track][\preprateU].round(0.01), // car peut envoyer des valeurs des entiers de 0 et 1 et Processing recoit des floats - mais de toute façon float - aucun intérêt du round ???
				~lastEvent[track][\preprate], // Utilisation de \rate2 pour valeurs négatives selon offset & \rater pour données des bus // [\rate0]
				~lastEvent[track][\bufType].asString,
				~lastEvent[track][\bufFolderValue],
				~lastEvent[track][\prepbufU].round(0.01), // car peut envoyer des valeurs des entiers de 0 et 1 et Processing reçoit des floats - mais de toute façon float - aucun intérêt du round ???
				~lastEvent[track][\prepbuf],
				~lastEvent[track][\offset],
				~lastEvent[track][\stretcherU],
				~lastEvent[track][\centerU],
				~lastEvent[track][\prepspa].asInteger, // [\prepspa0]
				~lastEvent[track][\panU],
				~lastEvent[track][\prepoutL].asInteger,
				~lastEvent[track][\prepoutR].asInteger,
				~lastEvent[track][\prepfxL].asInteger,
				~lastEvent[track][\prepfxR].asInteger,
				].postln;*/

				// [\event, 0.3072, 0, 0, 1, 0, 0.18, 0.4375, D, 28, 0.2, 5, 0, 0.5, 0.46875, 0, 0.5, 1, 2, 0, 0 ]
				// [\event, dur(float), track(int), syn(int), amp(float), env(int), rateU(float), rate(float), bufType(string), bufFolder(int), bufU(float), buf(float), offset(float), stretcherU(float), centerU(float), spa(int), panU(float), outL(int), outR(int), fxL(int), fxR(int) ]
				// I have got a collection of 2000 videos (of different durations and formats) or images organized within a folder structure (70 folders containing dozens of images or videos)
				// I would like that Touch Designer triggers a specific image or plays a video, when receiving a specific OSC message, where the list of arguments of the OSC message would determine the kind of media, the way of playing it or the kind of effect (shader) applied to a media.

		});
		// Voire impact CPU ?????????
		// A décommenter pour Processing  XXXXXXXX

		// Post << event;
		event; // Post << ~lastEvent[0]


	}) /*.trace*/;


	).play(~gblTempo);

};






/*
f = { |x| x.removeAllSuchThat { |y| y.isPlaying.not } };
z = Routine { inf.do { 8.do { |i| f.(~listID[i]) }; 0.1.wait } };
z.play;
*/
// Post << ~lastEvent[0][\id].class
// ~listID[0]



















// Visuel Task

// ~updateTime = 0.1; // déjà configuré dans les paramètres d'initialisation
// réduit de 10% le CPU vs pattern visuel
// Check à faire du TimingOffset pour le .wait si le changement du Tempo ne l'affecte pas pour l'update des données visuelles ???
// problème lorsque le tab code est sélectionné - à retirer le tab et ouvrir un doc dans un bouton ?

// Pour visualisation du Buffer
~curSoundFile = 0;
~curOffSoundFile = 0;
~curLegSoundFile = 0;
~curRatSoundFile = 1;

// 2 types de sélection de preset selon ~switchSeqValue entre le multislider et le texte
~lastPosSeq;
~lastPosSeq2;

// pour le global
~lastPosSeqs2 = 0 ! ~nbOfTracksX2;





~updateModuleSliderFunction = {


	if (~zoomMultiSlider == 0, {

		~rtmReadView.value_(~rtmSeqVSpec[~tab][~currentSeq].unmap(~posRtm[~tab][~currentSeq]));
		~proReadView.value_(~proSeqVSpec[~tab][~currentSeq].unmap(~posPro[~tab][~currentSeq]));
		~synReadView.value_(~synSeqVSpec[~tab][~currentSeq].unmap(~posSyn[~tab][~currentSeq]));
		~spaReadView.value_(~spaSeqVSpec[~tab][~currentSeq].unmap(~posSpa[~tab][~currentSeq]));
		~legReadView.value_(~legSeqVSpec[~tab][~currentSeq].unmap(~posLeg[~tab][~currentSeq]));
		~envReadView.value_(~envSeqVSpec[~tab][~currentSeq].unmap(~posEnv[~tab][~currentSeq]));
		~bufReadView.value_(~bufSeqVSpec[~tab][~currentSeq].unmap(~posBuf[~tab][~currentSeq]));
		~ampReadView.value_(~ampSeqVSpec[~tab][~currentSeq].unmap(~posAmp[~tab][~currentSeq]));
		~offReadView.value_(~offSeqVSpec[~tab][~currentSeq].unmap(~posOff[~tab][~currentSeq]));
		~panReadView.value_(~panSeqVSpec[~tab][~currentSeq].unmap(~posPan[~tab][~currentSeq]));
		~delReadView.value_(~delSeqVSpec[~tab][~currentSeq].unmap(~posDel[~tab][~currentSeq]));

		// voire si prise en compte constante ou alternée à faire des paramètres comme rat2 ??? -> Actuellement alternée
		// Economie de CPU entre l'ajout d'un if et le retrait d'un slider à updater ???
		if (~ratCompChoose == 0,
			{~ratReadView.value_(~ratSeqVSpec[~tab][~currentSeq].unmap(~posRat[~tab][~currentSeq]));
			},{~rat2ReadView.value_(~rat2SeqVSpec[~tab][~currentSeq].unmap(~posRat2[~tab][~currentSeq]));
		});
		if (~strCompChoose == 0,
			{~strReadView.value_(~strSeqVSpec[~tab][~currentSeq].unmap(~posStr[~tab][~currentSeq]));
			},{~str2ReadView.value_(~str2SeqVSpec[~tab][~currentSeq].unmap(~posStr2[~tab][~currentSeq]));
		});
		if (~cenCompChoose == 0,
			{~cenReadView.value_(~cenSeqVSpec[~tab][~currentSeq].unmap(~posCen[~tab][~currentSeq]));
			},{~cen2ReadView.value_(~cen2SeqVSpec[~tab][~currentSeq].unmap(~posCen2[~tab][~currentSeq]));
		});
		if (~outCompChoose == 0,
			{~fxLReadView.value_(~fxLSeqVSpec[~tab][~currentSeq].unmap(~posFxL[~tab][~currentSeq]));
				~outLReadView.value_(~outLSeqVSpec[~tab][~currentSeq].unmap(~posOutL[~tab][~currentSeq]));
			},{~fxRReadView.value_(~fxRSeqVSpec[~tab][~currentSeq].unmap(~posFxR[~tab][~currentSeq]));
				~outRReadView.value_(~outRSeqVSpec[~tab][~currentSeq].unmap(~posOutR[~tab][~currentSeq]));
		});

	},{

		// Pour zoom MultiSlider -> Le zoom peut causer de légers lates avec un rand continu sur les presets du aux fonctions supplémentaires dans les GUI

		// Pb du ReadView quant Pat (pattern aléatoire) est déclenché -> range de sélection de la SeqView du module ????????? -> meilleure solution ?????????
		if (~rtmPat[~tracksValue][~seqsValue] == 0,
			{~rtmReadView.value_(~rtmSeqVSpec2[~tab][~currentSeq].unmap(~posRtm[~tab][~currentSeq] - ~rtmSeqStart[~tab][~currentSeq]))
			},{ ~rtmReadView.value_(~rtmSeqVSpec[~tab][~currentSeq].unmap(~posRtm[~tab][~currentSeq]));  ~rtmSeqView.valueAction_([0, 1])
		});
		if (~proPat[~tracksValue][~seqsValue] == 0,
			{~proReadView.value_(~proSeqVSpec2[~tab][~currentSeq].unmap(~posPro[~tab][~currentSeq] - ~proSeqStart[~tab][~currentSeq]))
			},{ ~proReadView.value_(~proSeqVSpec[~tab][~currentSeq].unmap(~posPro[~tab][~currentSeq]));  ~proSeqView.valueAction_([0, 1])
		});
		if (~synPat[~tracksValue][~seqsValue] == 0,
			{~synReadView.value_(~synSeqVSpec2[~tab][~currentSeq].unmap(~posSyn[~tab][~currentSeq] - ~synSeqStart[~tab][~currentSeq]))
			},{ ~synReadView.value_(~synSeqVSpec[~tab][~currentSeq].unmap(~posSyn[~tab][~currentSeq]));  ~synSeqView.valueAction_([0, 1])
		});
		if (~spaPat[~tracksValue][~seqsValue] == 0,
			{~spaReadView.value_(~spaSeqVSpec2[~tab][~currentSeq].unmap(~posSpa[~tab][~currentSeq] - ~spaSeqStart[~tab][~currentSeq]))
			},{ ~spaReadView.value_(~spaSeqVSpec[~tab][~currentSeq].unmap(~posSpa[~tab][~currentSeq]));  ~spaSeqView.valueAction_([0, 1])
		});
		if (~legPat[~tracksValue][~seqsValue] == 0,
			{~legReadView.value_(~legSeqVSpec2[~tab][~currentSeq].unmap(~posLeg[~tab][~currentSeq] - ~legSeqStart[~tab][~currentSeq]))
			}, { ~legReadView.value_(~legSeqVSpec[~tab][~currentSeq].unmap(~posLeg[~tab][~currentSeq]));  ~legSeqView.valueAction_([0, 1])
		});
		if (~envPat[~tracksValue][~seqsValue] == 0,
			{~envReadView.value_(~envSeqVSpec2[~tab][~currentSeq].unmap(~posEnv[~tab][~currentSeq] - ~envSeqStart[~tab][~currentSeq]))
			},{ ~envReadView.value_(~envSeqVSpec[~tab][~currentSeq].unmap(~posEnv[~tab][~currentSeq]));  ~envSeqView.valueAction_([0, 1])
		});
		if (~bufPat[~tracksValue][~seqsValue] == 0,
			{~bufReadView.value_(~bufSeqVSpec2[~tab][~currentSeq].unmap(~posBuf[~tab][~currentSeq] - ~bufSeqStart[~tab][~currentSeq]))
			},{~bufReadView.value_(~bufSeqVSpec[~tab][~currentSeq].unmap(~posBuf[~tab][~currentSeq]));  ~bufSeqView.valueAction_([0, 1])
		});
		if (~ampPat[~tracksValue][~seqsValue] == 0,
			{~ampReadView.value_(~ampSeqVSpec2[~tab][~currentSeq].unmap(~posAmp[~tab][~currentSeq] - ~ampSeqStart[~tab][~currentSeq]))
			},{~ampReadView.value_(~ampSeqVSpec[~tab][~currentSeq].unmap(~posAmp[~tab][~currentSeq]));  ~ampSeqView.valueAction_([0, 1])
		});
		if (~offPat[~tracksValue][~seqsValue] == 0,
			{~offReadView.value_(~offSeqVSpec2[~tab][~currentSeq].unmap(~posOff[~tab][~currentSeq] - ~offSeqStart[~tab][~currentSeq]))
			},{~offReadView.value_(~offSeqVSpec[~tab][~currentSeq].unmap(~posOff[~tab][~currentSeq]));  ~offSeqView.valueAction_([0, 1])
		});
		if (~panPat[~tracksValue][~seqsValue] == 0,
			{~panReadView.value_(~panSeqVSpec2[~tab][~currentSeq].unmap(~posPan[~tab][~currentSeq] - ~panSeqStart[~tab][~currentSeq]))
			},{~panReadView.value_(~panSeqVSpec[~tab][~currentSeq].unmap(~posPan[~tab][~currentSeq]));  ~panSeqView.valueAction_([0, 1])
		});
		if (~delPat[~tracksValue][~seqsValue] == 0,
			{~delReadView.value_(~delSeqVSpec2[~tab][~currentSeq].unmap(~posDel[~tab][~currentSeq] - ~delSeqStart[~tab][~currentSeq]))
			},{~delReadView.value_(~delSeqVSpec[~tab][~currentSeq].unmap(~posDel[~tab][~currentSeq]));  ~delSeqView.valueAction_([0, 1])
		});


		if (~ratCompChoose == 0,
			{if (~ratPat[~tracksValue][~seqsValue] == 0,
				{~ratReadView.value_(~ratSeqVSpec2[~tab][~currentSeq].unmap(~posRat[~tab][~currentSeq] - ~ratSeqStart[~tab][~currentSeq]))
				},{~ratReadView.value_(~ratSeqVSpec[~tab][~currentSeq].unmap(~posRat[~tab][~currentSeq]));  ~ratSeqView.valueAction_([0, 1])
			});
			},{ if (~rat2Pat[~tracksValue][~seqsValue] == 0,
				{~rat2ReadView.value_(~rat2SeqVSpec2[~tab][~currentSeq].unmap(~posRat2[~tab][~currentSeq] - ~rat2SeqStart[~tab][~currentSeq]))
				},{~rat2ReadView.value_(~rat2SeqVSpec[~tab][~currentSeq].unmap(~posRat2[~tab][~currentSeq]));  ~rat2SeqView.valueAction_([0, 1])
			});
		});
		if (~strCompChoose == 0,
			{if (~strPat[~tracksValue][~seqsValue] == 0,
				{~strReadView.value_(~strSeqVSpec2[~tab][~currentSeq].unmap(~posStr[~tab][~currentSeq] - ~strSeqStart[~tab][~currentSeq]))
				},{~strReadView.value_(~strSeqVSpec[~tab][~currentSeq].unmap(~posStr[~tab][~currentSeq]));  ~strSeqView.valueAction_([0, 1])
			});
			},{if (~str2Pat[~tracksValue][~seqsValue] == 0,
				{~str2ReadView.value_(~str2SeqVSpec2[~tab][~currentSeq].unmap(~posStr2[~tab][~currentSeq] - ~str2SeqStart[~tab][~currentSeq]))
				},{ ~str2ReadView.value_(~str2SeqVSpec[~tab][~currentSeq].unmap(~posStr2[~tab][~currentSeq]));  ~str2SeqView.valueAction_([0, 1])
			});
		});
		if (~cenCompChoose == 0,
			{if (~cenPat[~tracksValue][~seqsValue] == 0,
				{~cenReadView.value_(~cenSeqVSpec2[~tab][~currentSeq].unmap(~posCen[~tab][~currentSeq] - ~cenSeqStart[~tab][~currentSeq]))
				},{~cenReadView.value_(~cenSeqVSpec[~tab][~currentSeq].unmap(~posCen[~tab][~currentSeq]));  ~cenSeqView.valueAction_([0, 1])
			});
			},{if (~cen2Pat[~tracksValue][~seqsValue] == 0,
				{~cen2ReadView.value_(~cen2SeqVSpec2[~tab][~currentSeq].unmap(~posCen2[~tab][~currentSeq] - ~cen2SeqStart[~tab][~currentSeq]))
				},{~cen2ReadView.value_(~cen2SeqVSpec[~tab][~currentSeq].unmap(~posCen2[~tab][~currentSeq]));  ~cen2SeqView.valueAction_([0, 1])
			});
		});
		if (~outCompChoose == 0,
			{if (~fxLPat[~tracksValue][~seqsValue] == 0,
				{~fxLReadView.value_(~fxLSeqVSpec2[~tab][~currentSeq].unmap(~posFxL[~tab][~currentSeq] - ~fxLSeqStart[~tab][~currentSeq]))
				},{~fxLReadView.value_(~fxLSeqVSpec[~tab][~currentSeq].unmap(~posFxL[~tab][~currentSeq]));  ~fxLSeqView.valueAction_([0, 1])
			});
			if (~outLPat[~tracksValue][~seqsValue] == 0,
				{~outLReadView.value_(~outLSeqVSpec2[~tab][~currentSeq].unmap(~posOutL[~tab][~currentSeq] - ~outLSeqStart[~tab][~currentSeq]))
				},{~outLReadView.value_(~outLSeqVSpec[~tab][~currentSeq].unmap(~posOutL[~tab][~currentSeq]));  ~outLSeqView.valueAction_([0, 1])
			});
			},{if (~fxRPat[~tracksValue][~seqsValue] == 0,
				{~fxRReadView.value_(~fxRSeqVSpec2[~tab][~currentSeq].unmap(~posFxR[~tab][~currentSeq] - ~fxRSeqStart[~tab][~currentSeq]))
				},{~fxRReadView.value_(~fxRSeqVSpec[~tab][~currentSeq].unmap(~posFxR[~tab][~currentSeq]));  ~fxRSeqView.valueAction_([0, 1])
			});
			if (~outRPat[~tracksValue][~seqsValue] == 0,
				{~outRReadView.value_(~outRSeqVSpec2[~tab][~currentSeq].unmap(~posOutR[~tab][~currentSeq] - ~outRSeqStart[~tab][~currentSeq]))
				},{~outRReadView.value_(~outRSeqVSpec[~tab][~currentSeq].unmap(~posOutR[~tab][~currentSeq]));  ~outRSeqView.valueAction_([0, 1])
			});
		});


		// Pb du ReadView quant Pat (pattern aléatoire) est déclenché -> visualisation seulement à partir du startIndex & ReadView décalé ???
		/*~rtmReadView.value_(~rtmSeqSpec2[~tab][~currentSeq].unmap(~posRtm[~tab][~currentSeq] - ~rtmSeqStart[~tab][~currentSeq]));
		~proReadView.value_(~proSeqSpec2[~tab][~currentSeq].unmap(~posPro[~tab][~currentSeq] - ~proSeqStart[~tab][~currentSeq]));
		~synReadView.value_(~synSeqSpec2[~tab][~currentSeq].unmap(~posSyn[~tab][~currentSeq] - ~synSeqStart[~tab][~currentSeq]));
		~envReadView.value_(~envSeqSpec2[~tab][~currentSeq].unmap(~posEnv[~tab][~currentSeq] - ~envSeqStart[~tab][~currentSeq]));
		~ratReadView.value_(~ratSeqSpec2[~tab][~currentSeq].unmap(~posRat[~tab][~currentSeq] - ~ratSeqStart[~tab][~currentSeq]));
		~bufReadView.value_(~bufSeqSpec2[~tab][~currentSeq].unmap(~posBuf[~tab][~currentSeq] - ~bufSeqStart[~tab][~currentSeq]));
		~spaReadView.value_(~spaSeqSpec2[~tab][~currentSeq].unmap(~posSpa[~tab][~currentSeq] - ~spaSeqStart[~tab][~currentSeq]));
		~ampReadView.value_(~ampSeqSpec2[~tab][~currentSeq].unmap(~posAmp[~tab][~currentSeq] - ~ampSeqStart[~tab][~currentSeq]));
		~offReadView.value_(~offSeqSpec2[~tab][~currentSeq].unmap(~posOff[~tab][~currentSeq] - ~offSeqStart[~tab][~currentSeq]));
		~legReadView.value_(~legSeqSpec2[~tab][~currentSeq].unmap(~posLeg[~tab][~currentSeq] - ~legSeqStart[~tab][~currentSeq]));
		~strReadView.value_(~strSeqSpec2[~tab][~currentSeq].unmap(~posStr[~tab][~currentSeq] - ~strSeqStart[~tab][~currentSeq]));
		~cenReadView.value_(~cenSeqSpec2[~tab][~currentSeq].unmap(~posCen[~tab][~currentSeq] - ~cenSeqStart[~tab][~currentSeq]));
		~panReadView.value_(~panSeqSpec2[~tab][~currentSeq].unmap(~posPan[~tab][~currentSeq] - ~panSeqStart[~tab][~currentSeq]));
		~outLReadView.value_(~outLSeqSpec2[~tab][~currentSeq].unmap(~posOutL[~tab][~currentSeq] - ~outLSeqStart[~tab][~currentSeq]));
		~outRReadView.value_(~outRSeqSpec2[~tab][~currentSeq].unmap(~posOutR[~tab][~currentSeq] - ~outRSeqStart[~tab][~currentSeq]));
		~fxLReadView.value_(~fxLSeqSpec2[~tab][~currentSeq].unmap(~posFxL[~tab][~currentSeq] - ~fxLSeqStart[~tab][~currentSeq]));
		~fxRReadView.value_(~fxRSeqSpec2[~tab][~currentSeq].unmap(~posFxR[~tab][~currentSeq] - ~fxRSeqStart[~tab][~currentSeq]));*/

	});
};





~updateModuleMultiSliderFunction = {

	~rtmView.index_(~posRtm[~tab][~currentSeq]);
	~proView.index_(~posPro[~tab][~currentSeq]);
	~synView.index_(~posSyn[~tab][~currentSeq]);
	~spaView.index_(~posSpa[~tab][~currentSeq]);
	~legView.index_(~posLeg[~tab][~currentSeq]);
	~envView.index_(~posEnv[~tab][~currentSeq]);
	~bufView.index_(~posBuf[~tab][~currentSeq]);
	~ampView.index_(~posAmp[~tab][~currentSeq]);
	~offView.index_(~posOff[~tab][~currentSeq]);
	~panView.index_(~posPan[~tab][~currentSeq]);
	~delView.index_(~posDel[~tab][~currentSeq]);

	if (~ratCompChoose == 0,
		{~ratView.index_(~posRat[~tab][~currentSeq]);
		},{~rat2View.index_(~posRat2[~tab][~currentSeq]);
	});
	if (~strCompChoose == 0,
		{~strView.index_(~posStr[~tab][~currentSeq]);
		},{~str2View.index_(~posStr2[~tab][~currentSeq]);
	});
	if (~cenCompChoose == 0,
		{~cenView.index_(~posCen[~tab][~currentSeq]);
		},{~cen2View.index_(~posCen2[~tab][~currentSeq]);
	});
	if (~outCompChoose == 0,
		{~fxLView.index_(~posFxL[~tab][~currentSeq]); ~outLView.index_(~posOutL[~tab][~currentSeq]);
		},{~fxRView.index_(~posFxR[~tab][~currentSeq]); ~outRView.index_(~posOutR[~tab][~currentSeq]);
	});

};





~updateModuleTextFunction = {

	var stringFX, stringOUT, dur, trajBufRatio, spaString,
	syn, spa, env, buf, rat, cen, rat2, cen2, amp;

	/*
	~lastEvent[~tab][\dur]
	*/

	dur = ~lastEvent[~tab][\dur].round(0.001);
	trajBufRatio = if (~lastEvent[~tab][\prepspa0] > 17 and: { ~lastEvent[~tab][\trajBufRatio].notNil }, { " (Traj) x " ++ ~lastEvent[~tab][\trajBufRatio].round(0.1) }, {""} );

	syn = ~lastEvent[~tab][\prepsyn2];
	spa = ~lastEvent[~tab][\prepspa0];
	env = ~lastEvent[~tab][\prepenv].asInteger;
	buf = ~lastEvent[~tab][\bufm];
	rat = ~lastEvent[~tab][\rate0].round(0.001);
	rat2 = ~lastEvent[~tab][\rate20]; rat2 = if (rat2.notNil, { rat2.round(0.001) }, {""}); // .round vraiment nécessaire comme pour les autres - à cause des multiples chorus ???
	cen = ~lastEvent[~tab][\center0].round(0.001);
	cen2 = ~lastEvent[~tab][\center20]; cen2 = if (cen2.notNil, { cen2.round(0.001) }, {""});
	amp = ~lastEvent[~tab][\amp0].round(0.01);

	// Visualisation dans les sliders PosView

	// Benchmark imprécis sur l'utilité et rapidité du Round
	// Utilisation du round seulement quand le mul est différent d'un entier
	/*
	{~rtmPosView.string_(" RTM Pos : " ++ ~posRtm[~currentTab][~seqSeq[~currentTab]] ++ "  Val : " ++ ~lastEvent[~currentTab][\dur].round(0.001) )}.bench;
	{~rtmPosView.string_(" RTM Pos : " ++ ~posRtm[~currentTab][~seqSeq[~currentTab]] ++ "  Val : " ++ ~lastEvent[~currentTab][\dur] )}.bench;
	*/

	/*if (~switchSeqValue[~tab] == 1, {~seqPosView.string_(" SEQ Pos : " ++ ~posSeq[~tab] ++ "  SEQ : " ++ (~lastEvent[~tab][\prepseq]+1) ) });*/
	~seqPosView.string_(/*" SEQ Pos : " ++*/ ~posSeq[~tab].asString ++ "  @  " ++ (~lastEvent[~tab][\prepseq]+1) );

	~rtmPosView.string_(/*" RTM Pos : " ++*/ ~posRtm[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ dur ++ " ou " ++ (dur / ~toTempo).round(0.001) ++ " s");
	~proPosView.string_(/*" PRO Pos : " ++*/ ~posPro[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\preppro] ++ " - " ++  ~lastEvent[~tab][\type]);

	/* // Pas vraiment beaucoup de différence en retirant le .asString, mais de toute façon pas néxessaire
	bench { 10000.do {~proPosView.string_(" PRO Pos : " ++ ~posPro[~tab][~currentSeq].asString ++ "  Val : " ++ ~lastEvent[~tab][\preppro].round(0.01).asString ++ " : " ++  ~lastEvent[~tab][\type].asString)}};
	bench { 10000.do {~proPosView.string_((" PRO Pos : " ++ ~posPro[~tab][~currentSeq] ++ "  Val : " ++ ~lastEvent[~tab][\preppro].round(0.01) ++ " : " ++  ~lastEvent[~tab][\type])) }};
	*/

	~synPosView.string_(/*" SYN Pos : " ++*/ ~posSyn[~tab][~currentSeq].asInteger.asString ++ "  @ " ++ syn ++ " - " ++ ~allSynthsGUI[syn] );
	~spaPosView.string_(/*" SPA Pos : " ++*/ ~posSpa[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ spa ++ " - " ++ ~allSpasGUIFinal[spa] ++  trajBufRatio);
	~envPosView.string_(/*" ENV Pos : " ++*/ ~posEnv[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ env ++ " - " ++ ~allEnvsGUI[env] );
	~offPosView.string_(/*" OFF Pos : " ++*/ ~posOff[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\offset]);
	~ampPosView.string_(/*" AMP Pos : " ++*/ ~posAmp[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ amp );
	~delPosView.string_(/*" DEL Pos : " ++*/ ~posDel[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\delayTime]);

	if (~legType[~tab][~currentSeq] == 1,
		{~legPosView.string_(/*" SUS Pos : " ++*/ ~posLeg[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\durenv0].round(0.01) ++ " s");
		},{~legPosView.string_(/*" LEG Pos : " ++*/ ~posLeg[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\leg].round(0.01) ++ " x rtm ou " ++ ~lastEvent[~tab][\durenv0].round(0.01) ++ " s")
	});
	// ~legPosView.string_(" LEG Pos : " ++ ~posLeg[~tab][~currentSeq] ++ "  Val : " ++ (~lastEvent[~tab][\legato].round(0.01) ++ " x dur ou " ++ ~lastEvent[~tab][\durenv].round(0.01) ++ " s") );

	~bufPosView.string_(/*" BUF Pos : " ++*/ ~posBuf[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\prepbuf] ++ " - " ++ (if (buf.isInteger, {}, {/*~lastEvent[~tab][\bufm].path.basename[0..20]*/ buf.path.basename.splitext[0][0..20]}))); // peut-être supprimer le nom ou réduire les ressources CPU car la seconde version retire l'extension
	/*
	may i suggest using the built in .basename instead.  it's a primitive, quicker to type and about 45 times faster.
	/any/path/whatever.ext".basename
	{100000.do{"/any/path/whatever.ext".basename}}.bench
	{100000.do{"/any/path/whatever.ext".split($/).last()}}.bench
	*/
	/*
	test Benchmark
	{100000.do {~lastEvent[~tab][\bufm].path.basename}}.bench // 0.08
	{100000.do {~lastEvent[~tab][\bufm].path.basename.splitext[0][0..20]}}.bench // 0.6
	{100000.do {~lastEvent[~tab][\bufm].path.basename.split($.)[0][0..20]}}.bench // 2.4
	*/



	// Indication des vitesses de rotation pour les spatialisations circulaires dans le texte à l'intérieur du slider pan
	// A optimiser - comment ??? -> Affichage seulement si pas de multiples copies
	if (~lastEvent[~tab][\mulCopies] == 0 and: { ~lastEvent[~tab][\prepspa0].inclusivelyBetween(8,13) }, {
		var spaSpeed = ~lastEvent[~tab][\spaSpeed0]/*[0]*/;
		// ~lastEvent[~tab][\prepspa0].postln; ~lastEvent[~tab][\panCircMVarMin].postln; // A supprimer - juste pour verifier car generation dune erreur dans le retour visuel. Donc placement de \panCircMVarMax and \panCircMVarMax a l'intérieur du coeur du Pbind
		case
		{spaSpeed == 0 and: { ~lastEvent[~tab][\panCircMReg].notNil } } // Circ multiple régulier
		{spaString = (" - (CircM) à " ++ ~lastEvent[~tab][\panCircMReg].round(0.01) ++ " hz ") }
		{spaSpeed == 1 and: { ~lastEvent[~tab][\panCircMVarMin].notNil } } // Circ multiple Acc
		{spaString = (" - (CircM) de " ++ ~lastEvent[~tab][\panCircMVarMin].round(0.1) ++ " à " ++ ~lastEvent[~tab][\panCircMVarMax].round(0.1) ++ " hz ") }
		{spaSpeed == 2 and: { ~lastEvent[~tab][\panCircMVarMax].notNil } } // Circ multiple Decc
		{spaString = (" - (CircM) de " ++ ~lastEvent[~tab][\panCircMVarMax].round(0.1) ++ " à " ++ ~lastEvent[~tab][\panCircMVarMin].round(0.1) ++ " hz ") };
	},{spaString = ""} );
	// spaString = ~lastEvent[~tab][\spaSpeed].postln;
	// spaString.postln;
	~panPosView.string_(/*" PAN Pos : " ++*/ ~posPan[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\pan] ++ spaString );



	if (~ratCompChoose == 0,
		{~ratPosView.string_(/*" RAT Pos : " ++*/ ~posRat[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ rat );
		},{ ~rat2PosView.string_(/*" RAT 2 Pos : " ++*/ ~posRat2[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ rat2 );
	}); // notNil utile seulement si des paramètres comme RAT2/STR2/CEN2 sont externalisés mais Réintégration dans le coeur du pattern sinon décalage entre les modules
	if (~strCompChoose == 0,
		{~strPosView.string_(/*" STR Pos : " ++*/ ~posStr[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ ~lastEvent[~tab][\stretcher].round(0.01) );
		},{~str2PosView.string_(/*" STR 2 Pos : " ++*/ ~posStr2[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ if (~lastEvent[~tab][\stretcher2].notNil, {~lastEvent[~tab][\stretcher2].round(0.01)}, {""}) );
	});
	if (~cenCompChoose == 0,
		{~cenPosView.string_(/*" CEN Pos : " ++*/ ~posCen[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ cen );
		},{~cen2PosView.string_(/*" CEN 2 Pos : " ++*/ ~posCen2[~tab][~currentSeq].asInteger.asString ++ "  @  " ++ cen2 );
	});



	stringFX = (/*" FX Pos : " ++*/ ~posFxL[~tab][~currentSeq].asInteger.asString ++ " & " ++ ~posFxR[~tab][~currentSeq].asInteger ++ "  @  " ++ ~fxName[~lastEvent[~tab][\serverNb]][~lastEvent[~tab][\prepfxL]/*.round(1)*/] ++ " & " ++ ~fxName[~lastEvent[~tab][\serverNb]][~lastEvent[~tab][\prepfxR]/*.round(1)*/]);
	stringOUT = (/*" OUT Pos : " ++*/ ~posOutL[~tab][~currentSeq].asInteger.asString ++ " & " ++ ~posOutR[~tab][~currentSeq].asInteger ++ "  @  " ++ ~lastEvent[~tab][\prepoutL2]/*[0]*//*.round(1)*/ ++ " & " ++ ~lastEvent[~tab][\prepoutR2]/*[0]*//*.round(1)*/);
	/*~fxLPosView.string_(" FX L Pos : " ++ ~posFxL[~tab][~currentSeq] ++ "  Val : " ++ ~lastEvent[~tab][\prepfxL].round(1) );
	~fxRPosView.string_(" FX R Pos : " ++ ~posFxR[~tab][~currentSeq] ++ "  Val : " ++ ~lastEvent[~tab][\prepfxR].round(1) );
	~outLPosView.string_(" OUT L Pos : " ++ ~posOutL[~tab][~currentSeq] ++ "  Val : " ++ ~lastEvent[~tab][\prepoutL].round(1) );
	~outRPosView.string_(" OUT R Pos : " ++ ~posOutR[~tab][~currentSeq] ++ "  Val : " ++ ~lastEvent[~tab][\prepoutR].round(1) );*/

	if (~outCompChoose == 0, // Préférable de n'utiliser qu'un ~fxPosView - mais pour éviter de modifier les pos quand changment de pos du View
		{~fxLPosView.string_(stringFX); ~outLPosView.string_(stringOUT);
		},{~fxRPosView.string_(stringFX); ~outRPosView.string_(stringOUT);
	});

};





~updateSecondLemurTrack = {

	// Pour avoir la même visualisation de piste que l'interface graphique ou le 1er Lemur automatiquement sur les pistes A & B
	// Déclenchée à chaque fois, Mais comment ne la déclencher que lorsque necessaire. Il faudrait avoir un état des ~lemurABSwitchesValues du Lemur 2...
	// Ligne ci-dessous à retirer pour avoir un réel comportement indépendant du Lemur 2 au niveau des Switches
	~lemurAdress2.sendMsg( *[ ~lemurABSwitchesValues[~secondLemurRawTrack], ~seqCompGABIndex[~secondLemurRawTrack] ]);

	~lemurAdress2.sendMsg( "/CurSeq1/value", ~seqSeq[~secondLemurX2Track]+1 /*1.0.rand*/);
	~lemurAdress2.sendMsg( *["/CurSeqText1", "@content", ~presetSelection[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] ]);

	if (~lemurNewSeqs[~secondLemurX2Track].size == 0, {
		if (~presetSeqStart[~secondLemurX2Track] - ~presetSeqStop[~secondLemurX2Track] == 0, {
			~lemurAdress2.sendMsg( "/CurSeq2/value", ~presetSeqStart[~secondLemurX2Track]+1 /*1.0.rand*/);
			~lemurAdress2.sendMsg( *["/CurSeqText2", "@content", ~presetSelection[~secondLemurX2Track][ ~presetSeqStart[~secondLemurX2Track]+1] ]);
		},{
			~lemurAdress2.sendMsg( *[ ["/CurSeq2/value"], [((~presetSeqStart[~secondLemurX2Track]+1)..~presetSeqStop[~secondLemurX2Track]+1).asString] ].flatten(1) );
			~lemurAdress2.sendMsg( *["/CurSeqText2", "@content", "" ]);
		});
	},{
		~lemurAdress2.sendMsg( *[ ["/CurSeq2/value"], [~lemurNewSeqs[~secondLemurX2Track].asString] ].flatten(1) );
		~lemurAdress2.sendMsg( *["/CurSeqText2", "@content", ""/*~presetSelection[tr][~lemurNewSeqs[tr][0]+1]*/ ]);
	});

	// ~lemurAdress2.sendMsg( *["/CurSeqText1", "@color", ~lemurColors[~seqSeq[~secondLemurX2Track]] ]);
	~lemurAdress2.sendMsg( *[ ["/TrackNext"] ++ ["@color"] ++
		if (~tracksPresetColorModel1.includes(~secondLemurX2Track), { [~lemurColors[~seqSeq[~secondLemurX2Track]], ~lemurColors[~seqSeq[~secondLemurX2Track]]] },{ [~redLemurColor3, ~redLemurColor3] })
	].flatten(1) );
	~lemurAdress2.sendMsg( *["/ParC/BufM", "@content", ~bufFolderView.items[~bufFolderValue[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]] ]);
	~lemurAdress2.sendMsg( *["/ParC/BufMenuL", "@content", ~bufFolderView.items[~bufFolderValue[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]] ]);

	if (~proPat[~secondLemurX2Track][/*~seqSeq[tr]*/~seqSeq[~secondLemurX2Track]] == 0, {
		~lemurAdress2.sendMsg( *[ ["/ParC/Cyc"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1]  ].flatten(1) );
	},{
		~lemurAdress2.sendMsg( *[ ["/ParC/Cyc"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
	});

	if (~proSelect[~secondLemurX2Track][/*~seqSeq[tr]*/~seqSeq[~secondLemurX2Track]] == 0, {
		~lemurAdress2.sendMsg( *[ ["/ParC/Cyc2"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1]  ].flatten(1) );
		~lemurAdress2.sendMsg( *["/ParC/CycT2", "@content", "Pro S" ]);
	},{
		~lemurAdress2.sendMsg( *[ ["/ParC/Cyc2"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
		~lemurAdress2.sendMsg( *["/ParC/CycT2", "@content", "Pro 1" ]);
	});

	if (~legLoop[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {
		~lemurAdress2.sendMsg( *[ ["/ParC/Loop"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
	},{
		~lemurAdress2.sendMsg( *[ ["/ParC/Loop"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor]  ].flatten(1) );
	});

	if (~ratSynth[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] == 0, {
		~lemurAdress2.sendMsg( *[ ["/ParC/Gliss"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
	},{
		~lemurAdress2.sendMsg( *[ ["/ParC/Gliss"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor]  ].flatten(1) );
	});

	~lemurAdress2.sendMsg( *["/ParC/SpaMenu/x", ~multiStereo[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] ]);

	~lemurAdress2.sendMsg("/ParC/HitM/value", ~proBjor[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/HitLed/value", ~proBjorSpec[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].unmap(~proBjor[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]) );
	~lemurAdress2.sendMsg("/ParC/OffM/value", ~proBjor2[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/OffLed/value", ~proBjorSpec[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].unmap(~proBjor2[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]) );
	~lemurAdress2.sendMsg("/ParC/RtmM/value", ~rtmMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/RtmLed/value", ~rtmMulSpec[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]].unmap(~rtmMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));
	~lemurAdress2.sendMsg("/ParC/ProM/value", ~proMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/ProLed/value", ~proMulSpec.unmap(~proMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));
	~lemurAdress2.sendMsg("/ParC/RatM/value", ~ratMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/RatLed/value", ~ratMulSpec.unmap(~ratMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));
	~lemurAdress2.sendMsg("/ParC/LegM/value", ~legMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/LegLed/value", ~legMulSpec.unmap(~legMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));
	~lemurAdress2.sendMsg("/ParC/StrM/value", ~strMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/StrLed/value", ~strMulSpec.unmap(~strMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));
	~lemurAdress2.sendMsg("/ParC/CenM/value", ~cenMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]);
	~lemurAdress2.sendMsg("/ParC/CenLed/value", ~cenMulSpec.unmap(~cenMul[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]]));

};










~fxTrackCheck = 0 ! ~nbOfTracksX2;

SkipJack({

	// max(~updateTime, (~lastEvent[~currentTab][\dur] * ~gblTempo.tempo.reciprocal) ? ~updateTime).wait; // meilleur benchmark - voire ci dessous
	// ~updateTime.wait;

	~tab = ~tracksValue; // Réduire le nom de ~tracksValue pour supprimer ~tab
	~currentSeq = ~seqSeq[~tab];



	if (~lemurConnected1 == 1 and: {~lastPosSeqs2[~tracksValue] != ~posSeq2[~tracksValue]}, {

		~lemurAdress1.sendMsg( "/CurSeq1/value", /*~seqsValue[~tracksValue]*/ ~currentSeq+1 /*1.0.rand*/); // ~currentSeq = ~seqsValue[~tracksValue] dans le pattern - non décalage mais ok ici
		~lemurAdress1.sendMsg( *["/CurSeqText1", "@content", ~presetSelection[~tracksValue][~currentSeq] ]);

		// ~lemurAdress1.sendMsg( *["/CurSeqText1", "@color", ~lemurColors[~currentSeq] ]);
		~lemurAdress1.sendMsg( *[ ["/TrackNext"] ++ ["@color"] ++ [~lemurColors[~currentSeq], ~lemurColors[~currentSeq]]  ].flatten(1) );
		~lemurAdress1.sendMsg( *["/ParC/BufM", "@content", ~bufFolderView.items[~bufFolderValue[~tracksValue][~currentSeq]] ]);
		~lemurAdress1.sendMsg( *["/ParC/BufMenuL", "@content", ~bufFolderView.items[~bufFolderValue[~tracksValue][~currentSeq]] ]);

		if (~proPat[~tracksValue][/*~seqSeq[tr]*/~currentSeq] == 0, { // ~currentSeq = ~seqSeq[tr] dans le pattern
			~lemurAdress1.sendMsg( *[ ["/ParC/Cyc"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1]  ].flatten(1) );
		},{
			~lemurAdress1.sendMsg( *[ ["/ParC/Cyc"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
		});

		if (~proSelect[~tracksValue][/*~seqSeq[tr]*/~currentSeq] == 0, { // ~currentSeq = ~seqSeq[tr] dans le pattern
			~lemurAdress1.sendMsg( *[ ["/ParC/Cyc2"] ++ ["@color"] ++ [~blueLemurColor1, ~blueLemurColor1]  ].flatten(1) );
			~lemurAdress1.sendMsg( *["/ParC/CycT2", "@content", "Pro S" ]);
		},{
			~lemurAdress1.sendMsg( *[ ["/ParC/Cyc2"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
			~lemurAdress1.sendMsg( *["/ParC/CycT2", "@content", "Pro 1" ]);
		});

		if (~legLoop[~tracksValue][~currentSeq] == 0, { // ~currentSeq = ~seqSeq[tr] dans le pattern  - non décalage
			~lemurAdress1.sendMsg( *[ ["/ParC/Loop"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
		},{
			~lemurAdress1.sendMsg( *[ ["/ParC/Loop"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor]  ].flatten(1) );
		});

		if (~ratSynth[~tracksValue][~currentSeq] == 0, { // ~currentSeq = ~seqSeq[tr] dans le pattern  - non décalage
			~lemurAdress1.sendMsg( *[ ["/ParC/Gliss"] ++ ["@color"] ++ [~redLemurColor, ~redLemurColor]  ].flatten(1) );
		},{
			~lemurAdress1.sendMsg( *[ ["/ParC/Gliss"] ++ ["@color"] ++ [~greenLemurColor, ~greenLemurColor]  ].flatten(1) );
		});
		// ~playViewValue[tr]
	});



	if (~lemurConnected2 == 1 and: {~lastPosSeqs2[~secondLemurX2Track] != ~posSeq2[~secondLemurX2Track]}, { ~updateSecondLemurTrack.(); });



	// Pour le global

	if ( /*~visuelTab == 1*/ ~currentTab == 3,
		{~nbOfTracksX2.do { |tr| var seq = ~seqSeq[tr];
			if (/*~playViewValue[tr] == 1*/ /*Pdef(~patterns2[tr]).isPlaying and:*/ ~lastPosSeqs2[tr] != ~posSeq2[tr],
				{~seqReadViewG[tr].value_(~seqSeqSpec3.unmap(~posSeq2[tr]));

					// value ne met pas à jour la String
					~rtmMulViewG[tr].value_(~rtmMulSpec[tr][seq].unmap(~rtmMul[tr][seq])).string = "Rtm : %".format(~rtmMul[tr][seq].round(0.001));
					~proMulViewG[tr].value_(~proMulSpec.unmap(~proMul[tr][seq])).string = "Pro : %".format(~proMul[tr][seq].round(0.01));

					~proPatViewG[tr].value_(~proPat[tr][seq]); if (~proPat[tr][seq] == 1, {~proPatViewG[tr].background_(Color.red).stringColor_(Color.white) }, {~proPatViewG[tr].background_(~popUpMenuBackgroundColor).stringColor_(~popUpMenuStringColor)} );
					~proBjorViewG[tr].step_(1/~pro[tr][seq].size).value_(~proBjorSpec[tr][seq].unmap(~proBjor[tr][seq])).string = "Hit : %".format(~proBjor[tr][seq].asInteger);
					// necessaire de mettre .asInteger pour arrondir les données qui ont été enregistré dans les presets auparavant
					~proBjor2ViewG[tr].step_(1/~pro[tr][seq].size).value_(~proBjorSpec[tr][seq].unmap(~proBjor2[tr][seq])).string = "Off : %".format(~proBjor2[tr][seq].asInteger);
					~proSelectViewG[tr].value_(~proSelect[tr][seq]); if (~proPat[tr][seq] == 1, {~proPatViewG[tr].background_(Color.red).stringColor_(Color.white) }, {~proPatViewG[tr].background_(Color.red).stringColor_(Color.white)} );

					~ratMulViewG[tr].value_(~ratMulSpec.unmap(~ratMul[tr][seq])).string = "Rat : %".format(~ratMul[tr][seq].round(0.01));
					~legMulViewG[tr].value_(~legMulSpec.unmap(~legMul[tr][seq])).string = "Dur : %".format(~legMul[tr][seq].round(0.01));
					~strMulViewG[tr].value_(~strMulSpec.unmap(~strMul[tr][seq])).string = "Str : %".format(~strMul[tr][seq].round(0.01));
					~cenMulViewG[tr].value_(~cenMulSpec.unmap(~cenMul[tr][seq])).string = "Cen : %".format(~cenMul[tr][seq].round(0.01));
					~bufMulViewG[tr].value_(~bufMulSpec.unmap(~bufMul[tr][seq])).string = "Buf : %".format(~bufMul[tr][seq].round(0.01));
					~offMulViewG[tr].value_(~offMulSpec.unmap(~offMul[tr][seq])).string = "Start : %".format(~offMul[tr][seq].round(0.01));
					~spaRangePresetViewG[tr].value_(~spaRangePreset[tr][seq]); // ne retranscrit pas l'état actuel, mais juste la dernière sélection faite dans ce popUp Menu....
					~panRangePresetViewG[tr].value_(~panRangePreset[tr][seq]); // idem à ci-dessus
					~spaPatSelViewG[tr].value_(~spaPatSel[tr][seq]);
					~spaPatViewG[tr].value_(~spaPat[tr][seq]);
					if (~spaPat[tr][seq] == 1, {
						~spaPatSelViewG[tr].background_(Color.red(0.7)).stringColor_(Color.white); // repris de envir[patView].states
					},{
						~spaPatSelViewG[tr].background_(~popUpMenuBackgroundColor).stringColor_(~popUpMenuStringColor);
					});
					~bufFolderViewG[tr].value_(~bufFolderValue[tr][seq]);
					// ~lastPosSeqs2[tr] = ~posSeq2[tr]; // mis en dessous car utilisé a en dessous dans le déclenchement des effets


					if (~twister.notNil, {
						~rtmValues[tr].value_(~rtmMulSpec[tr][seq].unmap(~rtmMul[tr][seq]));
						~proValues[tr].value_(~proMulSpec.unmap(~proMul[tr][seq]));
						// n.control(0, a+8, (~ratMulSpec.unmap(~ratMul[tr][~seqSeq[a]]) * 127.0).round(1) ); // pour l'envoi de n en MIDIOut
						~ratValues[tr].value_(~ratMulSpec.unmap(~ratMul[tr][seq/*~seqSeq[tr]*/]) )/*.copy*/; // Pour mise à jour du Twister
						~legValues[tr].value_(~legMulSpec.unmap(~legMul[tr][seq]));
						~strValues[tr].value_(~strMulSpec.unmap(~strMul[tr][seq]));
						~cenValues[tr].value_(~cenMulSpec.unmap(~cenMul[tr][seq]));
						~bufValues[tr].value_(~bufMulSpec.unmap(~bufMul[tr][seq]));
						~offValues[tr].value_(~offMulSpec.unmap(~offMul[tr][seq]));
						~bufFolValues[tr].value_(~bufFolderValue[tr][seq]);
					});


					if (~rhythmTracksX2.includes(tr), {
						if (~lemurConnected1 == 1, {
							~lemurAdress1.sendMsg(~lemurRatGTextValues[tr], ~ratMul[tr][~seqSeq[tr]]);
							~lemurAdress1.sendMsg(~lemurRatGLedValues[tr], ~ratMulSpec.unmap(~ratMul[tr][~seqSeq[tr]]));
							~lemurAdress1.sendMsg(~lemurLegGTextValues[tr], ~legMul[tr][~seqSeq[tr]]);
							~lemurAdress1.sendMsg(~lemurLegGLedValues[tr], ~legMulSpec.unmap(~legMul[tr][~seqSeq[tr]]));
						});
						if (~lemurConnected2 == 1, {
							~lemurAdress2.sendMsg(~lemurRatGTextValues[tr], ~ratMul[tr][~seqSeq[tr]]);
							~lemurAdress2.sendMsg(~lemurRatGLedValues[tr], ~ratMulSpec.unmap(~ratMul[tr][~seqSeq[tr]]));
							~lemurAdress2.sendMsg(~lemurLegGTextValues[tr], ~legMul[tr][~seqSeq[tr]]);
							~lemurAdress2.sendMsg(~lemurLegGLedValues[tr], ~legMulSpec.unmap(~legMul[tr][~seqSeq[tr]]));
						});
					});

			});
			// Pour modif de la valeur & du ThumbSize du ReadViewSlider dans le Tab Global XXX
			if (Pdef(~patterns2[tr]).isPlaying, { ~rtmReadViewG[tr].thumbSize_(~rtmThumbSizeValue[tr][seq]).value_(~rtmSeqVSpec[tr][seq].unmap(~posRtm[tr][seq])) } );
	}});





	// Données du mode des effets si E à la fin du preset - un peu lourd et redondant car relance l'effet à chaque fois qu'il est joué même s'il est déjà présent ???
	// ne remet à jour le preset si modifié entre-temps car pas d'action si l'effet est déjà présent -> OK voire ci-dessous
	// à simplifier et optimiser XXXXXXXXX
	// ~presetSeqTextViewG[tr][~seqSeq[tr]].string.asSymbol.postln;
	~nbOfTracksX2.do { |tr|

		// if ( ~posSeq2[tr] >= ~nbOfSeqs or:
		// { ~lastPosSeqs2[tr] != ~posSeq2[tr] } // seulement si changement de séquence
		// 2 Lignes ci-dessus -> solution provisoire rajouté pour mettre à jour les FX des séquences supérieurs à ~nbOfSeqs, pouvant être modifiés à n'importe quel moment // voir si ce génère pas trop de CPU - sinon à retirer car vraiment utilisé ??? -> retiré car plus possible d'arrêter les FX -> voire ~fxDefaultAll2View pour forcer le retrait des FX ???

		if (~lastPosSeqs2[tr] != ~posSeq2[tr]
			and: { ~presetSelection[tr][~seqSeq[tr]] != 0} // seulement si séquence contient un preset
			and: { ~presetsDontTriggerFX == 0}, {
				// and: { ~presets[~presetSelection[tr][~seqSeq[tr]].asSymbol][\fxSynth] == 1}, { // seulement si preset contient un preset d'effet

				var preset = ~presets[~presetSelection[tr][~seqSeq[tr]].asSymbol];

				var sv; if (~server2.isNil or: {(tr/2).asInteger < ~serverTrackSwitch}, {sv = 0}, {sv = 1} );


				if ( preset[\fxSynth] == 1, { // seulement si preset contient un preset d'effet

					if (sv != ~currentServerTab, { ~fxComp[sv].unfocusedColor_(Color.red); ~fxTabbedView.refresh; }); // Marquer le Tab si le FX de l'autre serveur est actif
					// ~fxComp[0].unfocusedColor_(Color.white)
					// ~fxComp[1].unfocusedColor_(Color.red).stringColor_(Color.white); ~fxTabbedView.refresh; // Voir si besoin de changer la couleur de la string ?

					// ~presetSelection[tr][~seqSeq[tr]].asSymbol.postln;
					~fxTrackCheck[tr] = 1;

					/*~fxSelect[sv]*/preset[\fxSynthNum].do { |y, yi|

						// seulement si l'effet 1 à 5 est différent de l'état actuel et si l'effet est différent de 0
						// if (~presets[~presetSelection[tr][~seqSeq[tr]].asSymbol][\fxSynthNum][yi] != ~fxSelect[yi] and: {~presets[~presetSelection[tr][~seqSeq[tr]].asSymbol][\fxSynthNum][yi] != 0}, {
						// remet à jour le preset des effets si modifié entre-temps - seulement si l'effet est différent de 0

						if (preset[\fxSynthNum][yi] != 0, { // condition retirée car pb de déclenchement des effets ???

							case
							{ preset[\fxSynthNum][yi] > 0 and: {preset[\fxSynthNum][yi] <= ~numFxSynthDef} }
							{
								if (~fxSynthDef[preset[\fxSynthNum][yi]-1].metadata['orderM'].notNil, {
									~fxSynthDef[preset[\fxSynthNum][yi]-1].metadata['orderM'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDef[preset[\fxSynthNum][yi]-1].name ++ ~fxSynthDef[preset[\fxSynthNum][yi]-1].metadata['orderM'][i]).asSymbol] }.do { |atem, a| try {atem.valueAction_(preset[\fxSynthDataM][yi][a]) } }
								});
								~fxSynthDef[preset[\fxSynthNum][yi]-1].metadata['order'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDef[preset[\fxSynthNum][yi]-1].name ++ ~fxSynthDef[preset[\fxSynthNum][yi]-1].metadata['order'][i]).asSymbol] }.do { |atem, a| atem.valueAction_(preset[\fxSynthData][yi][a]) };
							}

							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+1) }
							{ ~eqUnitLib[sv][0].setting = preset[\fxSynthData][yi] }
							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+2) }
							{ ~eqUnitLib[sv][1].setting = preset[\fxSynthData][yi] }
							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+3) }
							{ ~eqUnitLib[sv][2].setting = preset[\fxSynthData][yi] }

							// Intégration des effets spectraux XXXXXXXXX
							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+4) }
							{
								2.do { |i| ~fftEQMagValues[sv][i] = preset[\fxSynthData][yi][0][i]; ~fftEQBufsGet.(i, sv) };
								~fftEQSliderLagView[sv].valueAction_(preset[\fxSynthData][yi][1]);
								~fftEQCompChooseView[sv].valueAction_(preset[\fxSynthData][yi][2]);
								~fftEQBufChooseView[sv].valueAction_(preset[\fxSynthData][yi][3]);
								~fftEQRoutRandView[sv].valueAction_(preset[\fxSynthData][yi][4])
							}
							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+5) }
							{
								4.do { |i| ~fftDelfbValues[sv][i] = preset[\fxSynthData][yi][0][i]; ~fftDelBufsGet.(i, sv) };
								~fftDelSliderLagView[sv].valueAction_(preset[\fxSynthData][yi][1]);
								~fftDelCompChooseView[sv].valueAction_(preset[\fxSynthData][yi][2]);
								~fftDelBufChooseView[sv].valueAction_(preset[\fxSynthData][yi][3]);
								~fftDelRoutRandView[sv].valueAction_(preset[\fxSynthData][yi][4])
							}
							{ preset[\fxSynthNum][yi] == (~numFxSynthDef+6) }
							{
								2.do { |i|
									~fftOutChannelValues[sv][i] = preset[\fxSynthData][yi][0][i];
									~getBinChannelsPan2Outs.(~fftOutChannelValues[sv][i], i, sv); // fonction n'intègre pas d'update visuel à la différence des autres ci-dessus
									~fftOutPlotterView[sv][i].setValue(~fftOutChannelValues[sv][i], false)
								};
								~fftOutSliderLagView[sv].valueAction_(preset[\fxSynthData][yi][1]);
								~fftOutCompChooseView[sv].valueAction_(preset[\fxSynthData][yi][2]);
								~fftOutBufChooseView[sv].valueAction_(preset[\fxSynthData][yi][3]);
								~fftOutRoutRandView[sv].valueAction_(preset[\fxSynthData][yi][4])
							};

							// ~fxSelect.do { |i| i.postln }
							// ~fxSelect.do { |i| ~fxSelectView[i].valueAction_(~fxSelect[i]) }
							// ~fxSelectView[yi].valueAction_(preset[\fxSynthNum][yi]);
							if (~fxSelect[sv][yi] != preset[\fxSynthNum][yi], {

								if (~fxXfadePlaying[sv][yi] == 0 and: {~fxXfadePlayingT[sv][yi].isPlaying == false}, {

									~fxSelectView[sv][yi].valueAction_(preset[\fxSynthNum][yi]);
									// ~fxInSerieChooseButtonView[sv][yi].valueAction_( preset[\fxSynthSerPar][yi] /* préférer y ??? */ );

									{
										~fxXfadePlayingF.value(yi, sv);
										("FX Xfade begins - End in" + ( ~fadeTimeSynthFx[sv] /*/ ~toTempo*/) ++ "s !!!").warn; (~fadeTimeSynthFx[sv]+0.01).wait; "End of Xfade - OK to retrigger".inform;
										if (~fxXfadePlayingT[sv][yi].isPlaying == false, { ~fxXfadePlaying[sv][yi] = 0 } );
										// while ( { ~fxXfadePlaying[yi] == 1 }, { loop { if (~fxXfadePlayingT[yi].isPlaying == false, { ~fxXfadePlaying[yi] = 0 } ); 0.2.wait; ~fxXfadePlayingT[yi].isPlaying.postln; } } );

										// Arrêt des FX si aucun preset sélectionné n'utilise de FX ou Xfade du FX en cours
										// Vérification à chaque changement de preset et après le temps Xfade des FX
										if (~fxCPUCheck == 1, {
											if (~server2.isNil, {
												if (~fxTrackCheck.includes(1) or: { ~fxXfadePlaying[sv].includes(1) }, {
												},{
													if (~fxSelect[sv]!= #[ 0, 0, 0, 0, 0 ] /*.sum > 0*/, { {~fxDefaultAll2View[sv].valueAction_(1); }.defer });
												});
											},{
												var arrayCheck;
												if (sv == 0, { arrayCheck = ~fxTrackCheck[0..((~serverTrackSwitch*2)-1)] }, { arrayCheck = ~fxTrackCheck[(~serverTrackSwitch*2)..~nbOfTracksX2] } );
												if (arrayCheck.includes(1) or: { ~fxXfadePlaying[sv].includes(1) }, {
												},{
													if (~fxSelect[sv]!= #[ 0, 0, 0, 0, 0 ] /*.sum > 0*/, { {~fxDefaultAll2View[sv].valueAction_(1); }.defer });
												});
											});
										});
									}.fork;
								},{
									("Could not send FX of Preset" + (~seqSeq[~tab]+1)).postln;
									// ("Could not send FX & INOUT of Preset" + (~seqSeq[~tab]+1)).postln;
								}); /*"ok".postln;*/ // permet d'éviter le redéclenchement du même effet et d'en déclencher un nouveau si le Xfade n'est pas fini
							});

						}); // condition retirée car pb de déclenchement des effets ???

						// if (~mixFXTrigger == 1, {~mixAllFxView.valueAction_(/*~mixAllFxViewSpec.unmap(*/~mixAllFx)/*.doAction*//*)*/ }); // retiré d'en bas pour permettre d'appliquer le mix, même lorsque de multiples FX en crossfade ont été déclenchés et d'en haut pour éviter de répéter 5x l'action et retrait du wait

						// 0.001.wait; // Temps d'attente Pour éviter de lancer trop de synthé en même temps et de les bloquer
						// Le temps d'attente décale légèrement l'action sur les synthés INOUT en dessous
					};

					if (~mixFXTrigger[sv] == 1, {~mixAllFxView[sv].valueAction_(/*~mixAllFxViewSpec.unmap(*/~mixAllFx[sv])/*.doAction*//*)*/ }); // retiré d'en bas pour permettre d'appliquer le mix, même lorsque de multiples FX en crossfade ont été déclenchés et d'en haut pour éviter de répéter 5x l'action et retrait du wait


					// Ajout pour les effets en série ou en parallèle
					// Réintégré au dessus afin d'éviter le redéclenchement du même effet et d'en déclencher un nouveau si le Xfade n'est pas fini
					// Mais le changement du preset n'est pas forcément lié au changement du INOUT -> Routine sécifique pour le INOUT A faire -> OK
					/*~fxInSerieChoose*/

					preset[\fxSynthSerPar].do { |y, yi| // seulement 4 données et non pas 5 comme ~fxSelect

						if (~fxInSerieChoose[sv][yi] != preset[\fxSynthSerPar][yi], {

							if (~fxXIOfadePlaying[sv][yi] == 0 and: {~fxXIOfadePlayingT[sv][yi].isPlaying == false}, {

								~fxInSerieChooseButtonView[sv][yi].valueAction_( preset[\fxSynthSerPar][yi] /* préférer y ??? */ );
								// ~presets[~presetSelection[0][~seqSeq[0]].asSymbol][\fxSynthSerPar]
								{
									~fxXIOfadePlayingF.value(yi, sv);
									("FX INOUT Xfade begins - End in" + ( ~fadeTimeSynthFx[sv].min(6) /*/ ~toTempo*/) ++ "s !!!").warn; (~fadeTimeSynthFx[sv].min(6)+0.01).wait; "End of FX INOUT Xfade - OK to retrigger".inform;
									if (~fxXIOfadePlayingT[sv][yi].isPlaying == false, { ~fxXIOfadePlaying[sv][yi] = 0 } );
								}.fork;
							},{
								("Could not send FX INOUT of Preset" + (~seqSeq[~tab]+1)).postln;
							});
						});
					};

					if (~fxInSerieChoose[sv].sum == 4, {
						~fxInSerieChooseAllButtonView[sv].value_(1); ~fxInSerieChoose2AllButtonView[sv].value_(1)
					}, {
						~fxInSerieChooseAllButtonView[sv].value_(0); ~fxInSerieChoose2AllButtonView[sv].value_(0);
					}); // juste pour indiquer que certains effets sont en parallèle
					// Mais PROBLEME car dès qu'il y en a un, celà l'indique pour tout le monde XXX
					// [1, 0, 0, 0 ].includes(1)

				},{
					~fxTrackCheck[tr] = 0;
				});



				// Arrêt des FX si aucun preset sélectionné n'utilise de FX ou Xfade du FX en cours
				// Vérification à chaque changement de preset et après le temps Xfade des FX (mais pas après celui du FX INOUT pour l'instant...)
				if (~fxCPUCheck == 1, {
					if (~server2.isNil, {
						if (~fxTrackCheck.includes(1) or: { ~fxXfadePlaying[sv].includes(1) }, {
						},{
							if (~fxSelect[sv]!= #[ 0, 0, 0, 0, 0 ] /*.sum > 0*/, { {~fxDefaultAll2View[sv].valueAction_(1); }.defer });
						});
					},{
						var arrayCheck;
						if (sv == 0, { arrayCheck = ~fxTrackCheck[0..((~serverTrackSwitch*2)-1)] }, { arrayCheck = ~fxTrackCheck[(~serverTrackSwitch*2)..~nbOfTracksX2] } );
						if (arrayCheck.includes(1) or: { ~fxXfadePlaying[sv].includes(1) }, {
						},{
							if (~fxSelect[sv]!= #[ 0, 0, 0, 0, 0 ] /*.sum > 0*/, { {~fxDefaultAll2View[sv].valueAction_(1); }.defer });
						});
					});
				});



				// Remise des effets ambisoniques à 0 à chaque nouveau preset pour éviter qu'un effet ambisonique interagisse avec la séquence
				// Vérifier si OK en termes de CPU ??? -> voire ci-dessous
				// Mettre une literal Array pour gagner en CPU ????????? -> includes préférable
				// ??????????????????????????????????????????????????????
				// ??????????????????????????????????????????????????????

				// Benchmark
				/*
				bench { 100000.do { ~fxInSerieChoose != #[ 0, 0, 0, 0, 0 ] } }
				bench { 100000.do { ~fxInSerieChoose.includes(1) } }
				*/

				if (~fxASelect[sv] != #[ 0, 0, 0, 0, 0 ] /*.sum > 0 OK*/ /*~fxASelect[sv].includes(1) pas bon*/, {
					~fxASelect[sv].do { |y, yi| ~fxASelectView[sv][yi].valueAction_(0) };
					// ~presets[~presetSelection[0][~seqSeq[0]].asSymbol][\fxASynthNum];
				});


				if ( preset[\fxASynth] == 1, { // seulement si preset contient un preset d'effet A

					/*~fxASelect[sv]*/ preset[\fxASynthNum].do { |y, yi|

						// remet à jour le preset des effets Ambisoniques si modifié entre-temps - seulement si l'effet est différent de 0
						if (preset[\fxASynthNum][yi] != 0, {

							var numS, pres = preset[\fxASynthNum][yi]-1;

							case
							{ preset[\fxASynthNum][yi].inclusivelyBetween(1, ~numFxSynthDef5) }
							{ ~fxSynthDefA[pres].metadata['order'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDefA[pres].name.asString[0..2] ++ pres.asSymbol ++ ~fxSynthDefA[pres].metadata['order'][i]).asSymbol] }.do { |atem, a| atem.valueAction_(preset[\fxASynthData][yi][0][a]) };
								~fxSynthDef5SwitchTypView[sv][pres].valueAction_(preset[\fxASynthData][yi][1])
							}
							{ preset[\fxASynthNum][yi].inclusivelyBetween(~numFxSynthDef5-1, ~numFxSynthDef6Cum) }
							{ numS = pres-~numFxSynthDef5; ~fxSynthDefA[pres].metadata['order'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDefA[pres].name.asString[0..2] ++ numS.asSymbol ++ ~fxSynthDefA[pres].metadata['order'][i]).asSymbol] }.do { |atem, a| atem.valueAction_(preset[\fxASynthData][yi][0][a]) };
								~fxSynthDef6SwitchTypView[sv][numS].valueAction_(preset[\fxASynthData][yi][1])
							}
							{ preset[\fxASynthNum][yi].inclusivelyBetween(~numFxSynthDef6Cum-1, ~numFxSynthDef7Cum) }
							{ numS = pres-~numFxSynthDef6Cum; ~fxSynthDefA[pres].metadata['order'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDefA[pres].name.asString[0..1] ++ numS.asSymbol ++ ~fxSynthDefA[pres].metadata['order'][i]).asSymbol] }.do { |atem, a| atem.valueAction_(preset[\fxASynthData][yi][0][a]) };
								~fxSynthDef7SwitchTypView[sv][numS].valueAction_(preset[\fxASynthData][yi][1]);
								~fxSynthDef7SwitchTypPCView[sv][numS].valueAction_(preset[\fxASynthData][yi][2])
							}
							{ preset[\fxASynthNum][yi].inclusivelyBetween(~numFxSynthDef7Cum-1, ~numFxSynthDefA) }
							{ numS = pres-~numFxSynthDef7Cum; ~fxSynthDefA[pres].metadata['order'].size.collect { |i| ~fxSynthDefViews[sv][(~fxSynthDefA[pres].name.asString[0..4] ++ numS.asSymbol ++ ~fxSynthDefA[pres].metadata['order'][i]).asSymbol] }.do { |atem, a| atem.valueAction_(preset[\fxASynthData][yi][0][a]) };
								~fxSynthDef8SwitchTypView[sv][numS].valueAction_(preset[\fxASynthData][yi][1]);
								~fxSynthDef8SwitchTypPCView[sv][numS].valueAction_(preset[\fxASynthData][yi][2]);
								~fxSynthDef8SwitchRevView[sv][numS].valueAction_(preset[\fxASynthData][yi][3])
							};

							// ~fxASelectView[yi].valueAction_(preset[\fxASynthNum][yi]);
							if (~fxASelect[sv][yi] != preset[\fxASynthNum][yi], {~fxASelectView[sv][yi].valueAction_(preset[\fxASynthNum][yi])} ); // permet d'éviter le redéclenchement du même effet

						})
					}
				});

		});

		if (~lemurConnected1 == 1 /*and: {tr == ~tracksValue}*/ and: {~lastPosSeqs2[tr] != ~posSeq2[tr]}, {

			~lemurAdress1.sendMsg( ~lemurCurSeqNames[tr], ~seqSeq[tr]+1 /*1.0.rand*/);
			// ~lemurAdress1.sendMsg( "/CurSeqT1/value", ~seqSeq[0]+1 /*1.0.rand*/);

			if (tr == ~tracksValue, {
				~lemurAdress1.sendMsg( *["/CurSeqText1", "@content", ~presetSelection[~tracksValue][~seqSeq[~tracksValue]] ]);
				// ~lemurAdress1.sendMsg( *["/CurSeqText1", "@color", ~lemurColors[~seqSeq[~tracksValue]] ]); // illisible
			});

		});

		if (~lemurConnected2 == 1 /*and: {tr == ~secondLemurX2Track}*/ and: {~lastPosSeqs2[tr] != ~posSeq2[tr]}, {

			~lemurAdress2.sendMsg( ~lemurCurSeqNames[tr], ~seqSeq[tr]+1 /*1.0.rand*/);

			if (tr == ~secondLemurX2Track, {
				~lemurAdress2.sendMsg( *["/CurSeqText1", "@content", ~presetSelection[~secondLemurX2Track][~seqSeq[~secondLemurX2Track]] ]);
				// ~lemurAdress2.sendMsg( *["/CurSeqText1", "@color", ~lemurColors[~seqSeq[~secondLemurX2Track]] ]); // illisible
			});
		});



		~lastPosSeqs2[tr] = ~posSeq2[tr];

	};





	// Changement de Tab du au changement de séquences
	if (~visuelTab == 1 and: {~prevseq != ~currentSeq} and: {~playViewValue[~tab] == 1}, {~seqsView.valueAction_(~currentSeq); // "test".postln;

		/*if (/*~sequenceType[track][seq] != prevSeqType or: {*/ /*~seqSeq[track] != seq*/ test == 1 /*}*/, {
		"change of seq in track".postln; ~seqSeq[track].postln;
		// { ~presetSelectionView.doAction/*valueAction_(/*~presetSelectionView.selection[0]*/ ~presetSelectionView.items.indexOfEqual(~presetSelection[track][seq]/*[~seqSeq[track]]*/) )*/; }.defer;
		// {~presetGetFunction.value(~presetSelection[track][~seqSeq[track]].asSymbol, track, ~seqSeq[track])}.defer;
		{~presetGetFunction.value(~presetSelection[track][seq].asSymbol, track, seq)}.defer;
		});*/

	} );

	// (~prevseq != ~currentSeq).postln;
	// ~prevseq = ~currentSeq;
	~prevseq = ~seqsValue; // permet d'indiquer la position de la séquence dans toutes les situations afin de rendre le bouton tab actif

	// Voire l'update seulement quand  ~currentTab == 3 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	// Update des positions et des valeurs dans les multisliders
	// and: + performant que &&
	if (~visuelVal == 1 and: {Pdef(~patterns2[~tab]).isPlaying} and: {~currentSeq == ~seqsValue},
		{
			// ~seqReadView.value_(~seqSeqSpec2.unmap(~posSeq[~tab]));

			// Mise à jour du ~seqReadView ou ~seqRead2View seulement quand la valeur change
			if (~switchSeqValue[~tab] == 1,
				{if (~lastPosSeq != ~posSeq[~tab], {~seqReadView.value_(~seqSeqSpec2.unmap(~posSeq[~tab])) })
				},{if (~lastPosSeq2 != ~posSeq2[~tab], {~seqRead2View.value_(~seqSeqSpec3.unmap(~posSeq2[~tab]));

					/*if (~presetSelection[~tab][~currentSeq] != 0 and:{ ~updatePresetSelection == 0}, {
					~presetSelectionView.selection_(~presetSelectionView.items.indexOfEqual(~presetSelection[~tab][~currentSeq]));
					});*/
				})
			});





			if (~visuelSlider == 1,
				{
					~lastPosSeq = ~posSeq[~tab]; // Récupération de la dernière position de séquence pour les 2 types de sélection de preset
					~lastPosSeq2 = ~posSeq2[~tab];

					~updateModuleSliderFunction.();
				},{
					// Pourquoi error at avec l'update direct du multislider ???
					if (~switchSeqValue[~tab] == 1, {~seqView.index_(~posSeq[~tab]) });
					// ~seqView.index_(~posSeq[~tab]);

					~updateModuleMultiSliderFunction.();
					~updateModuleSliderFunction.(); // update des 2 // pas très économique ou mettre les sliders à la fin, mais dans le cas ou l'on ne voit pas les multisliders
			});


			// ~updateModuleTextFunction.();
			if ( ~lastEvent[~tab] != 0, { ~updateModuleTextFunction.() });





			// Update du SoundFileView que de la 1ère piste

			// Changement récent de l'argument startframe - voir impact dans code ci-dessous ?????????
			// [#2239](https://github.com/supercollider/supercollider/pull/2239) [vivid-synth](https://github.com/vivid-synth)
			// - class library: sound file view - rename argument startframe -> startFrame to match convention

			if (~updateSoundFile == 1 and: {~soundFileViewWindow.notNil} and: {~lastEvent[~tab][\bufm].path.notNil} and: {~lastEvent[~tab][\type] == (\note)},

				{if (~curSoundFile != ~lastEvent[~tab][\bufm] or: {~curOffSoundFile != ~lastEvent[~tab][\offset]} or: {~curLegSoundFile != ~lastEvent[~tab][\durenv0]} or: {~curRatSoundFile != ~lastEvent[~tab][\rate0]},

					{
						// pb avec le type [\type] == \note (parfois pas d'update alors que le type est note
						// "ok".postln;

						~soundFile = SoundFile.new;
						~soundFile.openRead(~lastEvent[~tab][\bufm].path);
						~soundFileView.soundfile = ~soundFile; // pb quand nom de fichier contient des caractères spéciaux comme des accents ???
						// ~soundFileView.read(0, ~soundFile.numFrames);
						// ~soundFileView.read.refresh;
						// for longer files, you can use - showProgress: false ne marche pas avec Qt
						~soundFileView.readWithTask(showProgress: false).refresh;
						// ~soundFile.close; // à tester utilité puisque l'on en n'a plus besoin ???

						// Selection OK seulement si Rate == 1

						if (~lastEvent[~tab][\rate0].isPositive,
							{~soundFileView.setSelectionColor(0, Color.blue(0.5));
								~soundFileView.setSelection(0, [~lastEvent[~tab][\offset] * ~soundFile.numFrames, min(~soundFile.numFrames, (~lastEvent[~tab][\durenv0] * ~soundFile.sampleRate * ~lastEvent[~tab][\rate0].abs)) ]);
							},{~soundFileView.setSelectionColor(0, Color.red);
								~soundFileView.setSelection(0, [max(0, (~lastEvent[~tab][\offset] * ~soundFile.numFrames) - ((~lastEvent[~tab][\durenv0] * ~soundFile.sampleRate) * ~lastEvent[~tab][\rate0].abs)), ~lastEvent[~tab][\offset] * ~soundFile.numFrames - max(0, (~lastEvent[~tab][\offset] * ~soundFile.numFrames) - ((~lastEvent[~tab][\durenv0] * ~soundFile.sampleRate) * ~lastEvent[~tab][\rate0].abs)) ] );
						});

						~curSoundFile = ~lastEvent[~tab][\bufm];
						~curOffSoundFile = ~lastEvent[~tab][\offset];
						~curLegSoundFile = ~lastEvent[~tab][\durenv0];
						~curRatSoundFile = ~lastEvent[~tab][\rate0];

				});
			});

	});

}, ~updateTime, ~globalWindow.isClosed, name: "visualUpdate");

SkipJack.verbose = true;





// ~trackFXVolView.valueAction_(0.12);
// Comme "~trackFXVolView.valueAction_(0.12);" n'est pas redéclenché dans Init Pattern car ~fxSynth2 est déclenché dans Init Pattern
~nbOfServers.do { |s| ~numEffects.do { |i|  ~fxSynth2[s][i].set( \amp, ~fxVolume ) } };










// Déclenchement d'un évènement d'un pattern un par un manuellement

/*
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, 0.1).play;
a = Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, 0.1).asStream;
a.next(()).play;
*/

// La fonction ~play doit avoir été lancée pour déclencher un évènement un par un
/*
~oneEventA = Pdef(\a_one).asStream;
~oneEventA.next(()).play;
*/

// Préparation afin de déclencher un évènement d'un pattern un par un en choisissant la piste - mais pas d'update visuel XXXXXX
// Problème de positionnement quand le pattern est relancé - obligé de relancer le code ci-dessous ?????????





~oneEvent = 0 ! ~nbOfTracks /*~tracksList.size*/;

fork {
	/*0.01*/ 0.1.wait;
	~tracksList.do { |tr|
		~play.value(npdef: ~patterns[tr], track: (~tracks[tr] *2), nfade: ~nFade[tr], pfade: 0, quant: 0, stretchdur: 1/1);
		Pdef(~patterns[tr]).quant_(/*~quant[tr]*/ 0); Pdef(~patterns[tr]).pause;
		~oneEvent[tr] = Pdef(~patterns[tr]).asStream;
	};
	// };



	~trackAllVolView.value_(~dbSpec.unmap(~globalVolume)).doAction; // pas forcément pris en compte avec .valueAction si on est déjà sur la même valeur
	// ~trackAllVolView.valueAction_(0); // ~globalVolume



	/*
	Pdef(~patterns[0]).gui
	Pdef(~patterns[0]).asStream.iter

	a = Pdef(~patterns[0]).asStream
	a.nextN(10)

	Pdef(~patterns[0]).asStream.asESP
	Editor.for(Event.default)
	Editor.for(~lastTrigEvent[0][0])
	*/



	/*~oneEvent = 0 ! ~nbOfSeqs ! ~nbOfTracks;

	{
	0.01.wait;
	~tracks.do { |tr|
	~nbOfSeqs.do { |seq|
	if (~presetSelection[tr][~presetSeqStart[tr]] != 0, {
	// try { ~presetGetFunctionQuick.value(~presetSelection[tr][~presetSeqStart[tr] /*~seqsValue*/].asSymbol, tr, ~presetSeqStart[tr]); };
	~tracksView.valueAction_(tr);
	~seqsView.valueAction_(seq);
	// try { ~presetGetFunction.value(~presetSelection[tr][~presetSeqStart[tr] /*~seqsValue*/].asSymbol/*, tr, ~presetSeqStart[tr];*/ ) };

	~play.value(npdef: ~patterns2[tr], track: (~tracks[tr]), nfade: ~nFade[tr], pfade: 0, quant: 0, stretchdur: 1/1);
	Pdef(~patterns2[tr]).quant_(/*~quant[tr]*/ 0); Pdef(~patterns2[tr]).pause;
	~oneEvent[tr][seq] = Pdef(~patterns2[tr]).asStream;
	})
	}
	};
	"fini".postln;
	}.fork(AppClock);*/





	/*
	~oneEvent[0].next(()).play; // 1ère piste
	~oneEvent[(~tracksValue/2).floor].next(()).play; // piste du ~tracksValue
	*/

	// Quelle est la vitesse de déclenchement lorsqu'on reste appuyé sur l'évaluation ?????????





	// "Pattern Function & Routine triggered"; // n'est pas affichée la 1ère fois que fichier lancé ?????????
	0.2.wait; "Pattern Function & Routine triggered".postln;

	( // Uniquement Si le pattern (CmdPeriod) est arrêté, obligé de relancer l'APC Mini et le Morph - Pourquoi ?
		if (~initAkai == 1, {"_Init Midi Ak.scd".loadRelative}); // Akai APC Mini à partir du Quark hacké d'Andrés Pérez López // ~akController = MKtl('pcmn0', "APC MINI");
		~initAkai = 1;
		"_Init Midi Morph.scd".loadRelative; // Sensel Morph - Canal 6
	)

};

);