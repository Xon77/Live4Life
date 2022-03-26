Server.scsynth;
Server.supernova; ~supernovaThreads = 2; ~scClock = true; /* false = sample clock - true = system clock */


( // Initialisation des Données Live4Life XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

~viaJACK = 0; // 0 Sans Jack / 1 Avec Jack

~soundIn = 0; // Allocation de l'entrée audio - 0 pour l'interne & 6 pour le 1er micro la RME
~nbOfSeqs = 240 /*200*/ /*99*/ ; // Nb de séquences différentes dans une piste
~foldersStructure = 1; // 1, si les d“ossiers des fichiers sons sont déjà structurés (du format IP Gong), sinon 0
~defaultFolder = 28 /*38*/ /*4*/; // fichier sélectionné par défaut - plus vraiment utilisé sauf à l'initialisation
// ~foldersStructure = 0; ~defaultFolder = 0; // adapté pour dossier son non structuré
~recordMontage = 0; // Pour enregistrer les évènements, mettre à 1

~synthDefsBuild = 0; // 1 pour reconstuire les synthés - si aucun dossier reconstruction automatique
~synthDefsManagementChoose = 1; // 0 -> add / 1 -> load --- utile seulement si ~synthDefsBuild = 1

~initSeqOrPerfMode = 0; // Initialisation Compostion Séquence = 0 / Preformance = 1
~visualizeLevels = "ServerMeter"; /*"SpatioScope";*/ // "ServerMeter"; // -> demande un peu plus de CPU - mais plus précis sur les niveaux // ~visualizeSpatioScope.value;
// Mais depuis l'arrivée du 2ème serveur, plus très intéressant car spatioscope n'est que sur un seul serveur
~visualizeProcessing = 0; // enclenche le transfert vers Processing
~mainWindowScroll = false;

~trackXFadeDefault = 20; // Valeur par défaut du Xfade pour les pistes en beats (/ par 2 en secondes si 120 de BPM, donc 20 = 10 sec.)
~hpModulation = 1; // Active les Effets avec modulation des paramètres en fonction des HP
~mixAllFxDefault = 0; // Valeur par défaut du mix des FX
~lagTimeAllFxDefault = 7 /*4*/; // Valeur par défaut du lag des paramètres des FX
~fadeTimeSynthFxDefault = 6 /*5*/ /*3*/; // Valeur par défaut du temps de Xfade des FX
~fxMulVolume = 1.0; // Pour la gestion des volumes lors du Xfade des FX entre Série et Parallèle - à tweeker...
~fxMul2Volume = 1.0; // idem
~maxMulVolControllers = 0.7945/*7*/ /*0.57*/ /*957*/; // Pour le volume général ~trackAllVolView -> à 1 = + 6dB // 0.5957 = -3dB
~fxCPUCheck = 1; // 1 -> Active l'arrêt des FX / Check de "preset[\fxSynth]==1" sur toutes les pistes sélectionnées à chaque changement de preset et après le temps Xfade des FX (mais pas après celui du FX INOUT...)
~maxSynthTime = 30 /*60*/; // Durée en sec. max pour chaque synthèse - tester avec 60 sec. ou à moduler selon les séquences ?
~keyBoardPerfProtect = 0; // 1 -> Empêche le déclenchement de certains shortcuts trop dangereux ou incontrolables en performance (concernant le random ou la sélection dans la liste de presets)
~keyBoardPerfProtectFX = 1; // 1 -> Empêche le déclenchement du shortcut (shift + ?) de changement aléatoire des FX (résultat incontrôlable... rester à 1 pour préserver ses oreilles et le système de son)
~rtmMulMinProtect = 4; // Multiplicateur de niveau minimum du multicateur du module de rythme (qui s'adapte en fonction du nombre d'évènements) pour atteindre un onset minimal de 0.004 sec. à x1 (2 pour 0.008...)
~rhythmTracks = [4,5,3] /*[3,4,5]*/ /*[4,5,6,7,3]*/; // Manipulation des pistes rythmiques en commençant par 0

// Chemin du Dossier de Sons XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~soundsFolder = "/Users/xon/Desktop/_Sounds2021C/";

// Config spatiale (Nb de sorties et organisation spatiale) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ~numChannelsConfig = "2-MultiChannelSequencer"; // Pour récupérer les 8 pistes stéréo séparées dans un séquenceur et donc effets multi-canaux 16 pistes mono
// ~numChannelsConfig = "2-Performance"; // Mixage global donc utilisation d'effets stéréo seulement // ~ambATKConfig = "binaural" // "stereo"
~numChannelsConfig = "4";
// ~numChannelsConfig = "5-Clock"; // Clockwise à partir du Centre = 0
// ~numChannelsConfig = "5-Centre"; // Clockwise à partir de la gauche sauf Centre = 3 - XXXXXXXXX
// ~numChannelsConfig = "7"; // Clockwise à partir du Centre
// ~numChannelsConfig = "8-Centre"; // Clockwise à partir du Centre
~numChannelsConfig = "8-PairClock"; // Clockwise à partir de la gauche - XXXXXXXXX
// ~numChannelsConfig = "8-PairPair"; // par paire de gauche à droite - utile pour spatialisation avec le SpatGris - XXXXXXXXX
// ~numChannelsConfig = "16-PairClock"; // Clockwise à partir de la gauche
// ~numChannelsConfig = "16-Dome-8-6-2-Pair"; // par paire de gauche à droite XXXXXXXXX
~numChannelsConfig = "16-Dome-8-6-2-Clock"; // Clockwise à partir de la gauche - sorties de la carte son à réassigner selon SpatioScope (Hexa + 2 Subs) XXXXXXXXX
~numChannelsConfig = "16-Dome-8-6-2-Clock-CC"; // IDEM avec 4 Subs
// Clockwise à partir de la gauche - sorties de la carte son à réassigner selon SpatioScope (spécifique à la Salle CC pour Subs) XXXXXXXXX
// 1-1 / 2-2 / 3-4 / 4-6 / 5-8 / 6-7 / 7-5 / 8-3 /
// 9-13(17) / 10-10(14) / 11-12(16) / 12-14(18) / 13-11(15) / 14-9(13) / 15-15(19) / 16-16(20) -- (+ 4 car phones et SPDIF de 9 à 13)
// Pour CC Test Juillet 2018 car avant / arrière haut en 1er et non à la fin comme l'Hexa - 9-9 / 10-12 / 11-14 / 12-10 / 13-13 / 14-11 / 15-15 / 16-16
// Subs -> 17-27 / 18-28 / 19-29 / 20-30
// ~numChannelsConfig = "22-8+Dome-8-4-2-Pair"; // Salle CC
~numChannelsConfig = "32-Dome-12-10-8-2"; // Clockwise à partir de la gauche (+ 2 Subs) XXXXXXXXX
// ~numChannelsConfig = "32-Dome-12-10-8-2-Motu"; // Clockwise à partir de la droite - spirale avec quelques variations Config Motu
// ~numChannelsConfig = "64-CentreClock"; // Test - Clockwise à partir du Centre
// ~numChannelsConfig = "96-CentreClock"; // Test - Clockwise à partir du Centre
// ~numChannelsConfig = "128-CentreClock"; // Test - Clockwise à partir du Centre
// ~numChannelsConfig = "24-UsineC-3Octo";
// Ajustement volume, controle et attribution des subs dans Salle CC ou Motu...
~numChannelsConfig = "16-Dome-8-6-2-Clock";

// Nom du Fichier de Presets XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~presetsFileName = "MyPresetFile.txt";
// ~presetsFileName2 = "MyPresetFile2.txt";

// Particlarité Spatialisation Ambisonique
~ambATKConfig = "multiChannel"; // "binaural" / "stereo" / "multiChannel"
~binauralDecoderName = "FoaDecoderKernel.newSpherical"; // newSpherical ou newCIPIC (44100.0 is not available for cipic kernel decoder)
~ambATKkFactor = 'velocity'; // 'dual' / 'velocity' - uniquement pour multicanal

// Protection car ~ambATKConfig = ne peut pas être multiChannel, si config avec 2 HP
// if (~numChannelsConfig[0].digit == 2 and: { ~ambATKConfig == "multiChannel"} , { ~ambATKConfig = "binaural" /*"stereo" */}); // ne marche pas avec les 24hp de l'UsineC
// if (ServerOptions.devices.size == 5, { ~ambATKConfig = "binaural" }); // Si aucune carte son n'est repéré -> == 5 -> decoder binaural enclenché
// ServerOptions.devices; ServerOptions.outDevices; ServerOptions.inDevices; // only on OSX

/*
The default k ( 'single' ), for decoders accepting k as an argument, returns an 'energy' optimised (aka "max rE") decoder (see FoaDecoderMatrix).
'single' is suitable for larger, mid-scale environments.
'dual' returns a dual-band psychoacoustically optimised decoder.5 The 'dual' decoder is the optimum choice for small scale studio or domestic settings.
'velocity' returns "strict soundfield" (aka "basic") decoding, and is not preferred for first order Ambisonics in most circumstances.
'controlled' returns "controlled opposites" decoding (aka "in phase"), which is often preferred in large-scale, concert environments.
May be specified as a float: 0.5 to 1.0. Or more conviently by name :
'velocity'     1
'energy'       1/sqrt(2) = 0.70710678118655
'controlled'   1/2
For large-scale concert presentation, the authors advise auditioning values of k between 1/2 and 1/sqrt(2).
*/
// ~renderEncode.() & ~renderDecode.() // à réévaluer également les synthés lorsque changement du décodeur tout particulièrement binaural et ne pas oublier FoaDecoderKernel.free; si binaural ou stereo

~presetsTrajectoryFileName = "L4LPresetTrajectoryZArchive-1.txt"; // Nom du fichier de preset de trajectoires avec création du fichier si non existant

~automationInitRecTime = 0; // ~automationLoad.(); // Relance une nouvelle Automation pour l'interface graphique - Quark Automation GUI

~setSampleRate = false /*true*/ /*false*/;
~sampleRate = 48000 /*44100*/; // Concat complains: sample rate not 44100, you have 48000
~hardwareBufferSize = 128 /*512*/ /*256*/; // 512 par défaut sur la carte son ->  to get less audio input latency - 64 avec RME permet d'éviter trop de clics quand arrêt du serveur car surchargé

// 3.do { Server.killAll }; // Attendre RESULT = 1 avant d'exécuter la suite
fork { Server.killAll; /*0.1.wait;*/ s.waitForBoot({ /*0.1.wait;*/ 2.do { 0.1.wait; Server.killAll };
	0.1.wait; "".postln; ("Spatial Config ->" + ~numChannelsConfig).postln; ("Preset Filename ->" + ~presetsFileName).postln; if (~presetsFileName2.notNil, {("Preset Filename 2 ->" + ~presetsFileName2).postln}); "".postln;
}); }; // Server.allRunningServers;
)



( // Initialisation MIDI avec la librairie Modality & Quark APC Mini & Twister XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{ // MKtl.find(\midi); MKtl.postLoadedDescs; MKtlDesc.writeCache;
	~midiTouchBar = MKtl('iac', "gestionnaire-iac"); "_Init Midi T.scd".loadRelative; // Canal 7
	~akFXVol8 = 1; "_Init Midi Ak.scd".loadRelative; // Akai APC Mini à partir du Quark hacké d'Andrés Pérez López // ~akController = MKtl('pcmn0', "APC MINI"); // Canal 1
	// Mettre le ~akFXVol8 = 1; pour contrôler le volume des FX sur l'Akai APC Mini au lieu du volume de la 8ème piste
	// ~qController = MKtl('qnxs0', "keith-mcmillen-qunexus_port1_AB"); "_Init Midi Q2.scd".loadRelative; // Preset B - Canal 2 - plus utilisé pour l'instant
	// fichier "keith-mcmillen-qunexus_port1_AB.desc de Modality" -> changer de midiChan de 0 à 2 - à faire si réutilisé
	// ~uController = MKtl('csbm330', "evolution-ucontrol-uc33"); "_Init Midi U.scd".loadRelative; // Canal 0 - plus utilisé pour l'instant
	// For Midi Fighter Twister, change Midi Encoder Type to "Enc 3FH/41H"
	1.wait;
	"_Init Midi Twister7.scd".loadRelative; // Encoder Midi - Canal 1 / Switch Midi - Canal 2 / Global sttings for side buttons - Canal 4
	0.2.wait;
	"_Init Midi Morph.scd".loadRelative; // Sensel Morph - Canal 6
	"Controllers connected if available !".postln;
}.fork;
)



// INIT BUFFERS & SYNTHS XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
"_1_Init_BuffersSynths_128.scd".loadRelative; ~loadPhrases.(\serverP, \LocalP, 57114); ~fx16Split = 0;

~loadServer.(\server1, \Local1, 0, 57110); // Nom du server -> ~server1 // limité à 96 canaux, mais séquences d'effets multicanaux s'exprimant moins bien au delà de 16 canaux
// ~loadServer.(\server1, \Local1, 0, 57110, \serverFX1, \LocalFX1, 57111); // Noms des servers -> [~server1, ~serverFX1] // limité à 32 canaux via Jack ?
~initBuffersSynths.(\server1, 0); // dans fichier _Init Buffers & Synths // erreur et crash du server plus probable ou systématique sur 2ème server, si ordi non branché sur secteur ???
// Revoir l'affectation du Sub

// 2ème Serveur
~loadServer.(\server2, \Local2, 1, 57112); // Nom du server -> ~server2
// ~loadServer.(\server2, \Local2, 1, 57112, \serverFX2, \LocalFX2, 57113); // Noms des servers -> [~server2,  ~serverFX2]
~initBuffersSynths.(\server2, 1);



// INIT GUI (Server 1 jusqu'à la piste 2 et Server 2 au delà) XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~nbOfControlBus = 6; ~serverTrackSwitch = 2; "_2_Init_GUI_221.scd".loadRelative;

// Lemur Connection
~lemurConnected1 = 1; ~lemurAdress1 = NetAddr( "192.168.0.109", 8000);
~lemurConnected2 = 1; ~lemurAdress2 = NetAddr( "192.168.1.11", 8000);
~lemurConnected1 = 0; ~lemurAdress1 = nil; ~lemurConnected2 = 0; ~lemurAdress2 = nil;



// INIT PATTERN XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~updateTime = 0.2 /*0.1*/; "_3_Init_Pattern_181.scd".loadRelative;


if ( ~serverFX == 0, { ~initFXSynthDefs.(\server1, 0) }, { ~initFXSynthDefs.(\serverFX1, 0) } ); // dans fichier _Init Buffers & Synths XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
if ( ~serverFX == 0, { ~initFXSynthDefs.(\server2, 1) }, { ~initFXSynthDefs.(\serverFX2, 1) } ); // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



// Info sur les servers
~server1.queryAllNodes;
~server2.queryAllNodes;
~server1.numSynthDefs.postln; ~server2.numSynthDefs;
~serverVolume[0].freeSynth;

// Info sur la taille des dossiers sons
~listingSoundFolders = ("du -m -L" + ~soundsFolder +" | sort -nr").unixCmdGetStdOut; // Listing de la taille des dossiers sons
("open" + ~soundsFolder).unixCmdGetStdOut; // Ouverture du dossier son dans le Finder
("open" + PathName(thisProcess.nowExecutingPath).pathOnly).unixCmdGetStdOut; // Ouverture du dossier des fichiers texte et de presets
