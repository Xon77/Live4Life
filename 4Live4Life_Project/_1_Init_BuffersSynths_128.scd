(

~loadServer = { | server, name, serverNb, port, serverFX, nameFX, portFX |



	var serverFXV, nameFXV, portFXV;
	if ( serverFX.isNil or: { ~viaJACK == 0 }, { ~serverFX = 0; serverFXV = server; nameFXV = name; portFXV = port; }, { ~serverFX = 1;  serverFXV = serverFX; nameFXV = nameFX; portFXV = portFX; } );



	( // ServerOptions

		currentEnvironment[server] = Server(name, NetAddr("127.0.0.1", port));

		// Server.default = s = Server.local;
		if (currentEnvironment[server] == ~server1, {Server.default = currentEnvironment[server]; } );



		~serverOptions = currentEnvironment[server].options;



		if (Server.program.split($/).last == "supernova", {
			~serverOptions.threads = ~supernovaThreads; ~serverOptions.useSystemClock = ~scClock /*false*/ /*default = sample clock */;
		});



		if (~viaJACK == 1, { ~serverOptions.device = "JackRouter";
			// "SC_JACK_DEFAULT_INPUTS".setenv("system");
			// "SC_JACK_DEFAULT_OUTPUTS".setenv("system");

		} ); // ROUTING JACK
		// s.options.device = "JackRouter";
		// Quel Buffer size pour Jack choisir ? // 128 -> apparemment 512 necessaire pour éviter les lates ???

		/*
		// connect first to input channels with system
		"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
		// connect all output channels with system
		"SC_JACK_DEFAULT_OUTPUTS".setenv("system");

		// hook up jack ports to audio channels
		"SC_JACK_DEFAULT_INPUTS".setenv("system");
		"SC_JACK_DEFAULT_OUTPUTS".setenv("system");

		*/



		// Martin Marier Server Options
		/*
		s.options.sampleRate_(48000);
		s.options.numAudioBusChannels_(2.pow(11));
		s.options.numOutputBusChannels_(30);
		s.options.numInputBusChannels_(2);
		s.options.numBuffers_(2048);
		s.options.memSize_(2.pow(21));
		s.options.numWireBufs_(2.pow(16));
		*/



		if (~setSampleRate == true, {~serverOptions.sampleRate_(~sampleRate)} ); // set the sampleRate



		~serverOptions.pingsBeforeConsideredDead = 350;
		// /*s.aliveThreadPeriod = 0.01;*/ s.options.pingsBeforeConsideredDead = 350; // Init des requêtes CPU et coupure du server - mais pb lors du chargement des buffers avec aliveThreadPeriod



		~serverOptions.numWireBufs_(8192*12000); // 5000 auparavant - default 64 The maximum number of buffers that are allocated to interconnect unit generators -> This sets the limit of complexity of SynthDefs that can be loaded at runtime. This value will be automatically increased if a more complex def is loaded at startup, but it cannot be increased thereafter without rebooting.
		/*
		(8192*5000)
		(8192*9000)
		(2.pow(16))
		(2.pow(26))
		*/

		// numWireBufs à limiter à 800 ou 500 car génère une erreur sur Linux ???????????????????????????

		~serverOptions.maxNodes_(8192*5000); // default 1024

		// This memory is used to allocate synths and any memory that unit generators themselves allocate (for instance in the case of delay ugens which do not use buffers, such as CombN), and is separate from the memory used for buffers. Setting this too low is a common cause of 'exception in real time: alloc failed' errors.
		// ~serverOptions.memSize_(2.pow(18)) // 262.144 // insuffisant et provoque des bursts du Server quand on change de presets ou buffers rapidement
		// ~serverOptions.memSize_(65536 * 4); // 262.144 - necessary for Greyhole & JPVerb
		~serverOptions.memSize_(2.pow(21)); // (2.pow(21)) - 2GB alloué - vraiment nécessaire ???????????????????????????
		// (1024*1900) 1.945.600 // to get the nb of MB // -> 1.6GB // default 8192 kilobytes (8 M) of real time memory allocated to the server // crash à 2GB ?????????
		// Yes - the memory is definitely grabbed on server boot and unavailable to other apps.
		// it's reserverd in the sense that it would immediately be made accessible by the operating system in case of being needed.
		// It refers to a block of memory that the server reserves in advance while booting -- the "real-time memory pool." It needs this because some UGens need to grab extra memory, and it is not safe to ask the OS for memory in a context (such as real-time DSP) where low latency is critical. The server has its own, faster allocator that uses this pre-reserved block.

		~serverOptions.numBuffers_(7000); // default 1024

		~serverOptions.maxSynthDefs_(7000); // to adapt according to the nb of synthdefs created

		~serverOptions.hardwareBufferSize = ~hardwareBufferSize; // 512 par défaut sur la carte son ->  to get less audio input latency -> impact CPU et sur enregistrement ???
		// 64 apparemment suporte mieux les surcharges du server mais ne résoud pas la coupure de l'enregistrement à certains moments ??? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		/*
		1/441000*512 -> 0.0011609977324263
		1/441000*64 -> 0.00014512471655329
		*/

		// ServerOptions ci-dessous à modifier pour optimiser le Server ???
		~serverOptions.zeroConf = true; // A Boolean indication whether or not the server should publish its port using zero configuration networking, to facilitate network interaction. This is true by default; if you find unacceptable delays (beachballing) upon server boot, you can try setting this to false.

		// intérêt ??? - apparemment pas d'effet
		~serverOptions.memoryLocking = false /*true*/; // A Boolean indicating whether the server should try to lock its memory into physical RAM. Default is false.

		~serverOptions.numBuffers;
		~serverOptions.numWireBufs;
		~serverOptions.maxNodes;
		~serverOptions.memSize/1024; // en MB
		~serverOptions.blockSize; // The number of samples in one control period. The default is 64.
		~serverOptions.hardwareBufferSize; // The preferred hardware buffer size. If non-nil the server app will attempt to set the hardware buffer frame size.
		// SC_AudioDriver: sample rate = 44100.000000, driver's block size = 512 ??? for audio internal card & RME





		// Config multicanale pour version stéréo si besoin des pistes séparées dans un séquenceur
		~numChannels = ~numChannelsConfig.split($-)[0].asInteger;

		if (~numChannelsConfig == "2-MultiChannelSequencer", {
			~serverOptions.numOutputBusChannels = 16; ~numChannelsFX = 16
		}, {
			~serverOptions.numOutputBusChannels = ~numChannels; ~numChannelsFX = ~numChannels
		});

		// ~serverOptions.numOutputBusChannels = ~numChannels;
		// ~serverOptions.numOutputBusChannels = 5
		// ~serverOptions.numInputBusChannels;

		// Particularité Salle Claude Champagne ou Dome 32 HP - Overwrite
		// if (~numChannelsConfig == "22-8+Dome-8-4-2-Pair", {~serverOptions.numOutputBusChannels = 36; ~numChannelsFX = 14}); // 22 HP normaux, mais aussi HP en 33 / 34 / 35 / 36

		case

		{~numChannelsConfig == "16-Dome-8-6-2-Clock"}
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 18; ~numChannelsFX = 16} // 16 HP, mais aussi 2 Subs

		{~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"}
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 20; ~numChannelsFX = 16} // 16 HP, mais aussi 4 Subs

		{~numChannelsConfig == "22-8+Dome-8-4-2-Pair"}
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 36; ~numChannelsFX = 14} // 22 HP, mais aussi Susbs en 33 / 34 / 35 / 36

		{~numChannelsConfig == "16-UsineC-2Octo"}
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 18; ~numChannelsFX = 16}

		{~numChannelsConfig == "24-UsineC-3Octo"}
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 27; ~numChannelsFX = 24}

		{~numChannelsConfig ==  "32-Dome-12-10-8-2-Motu" or: { ~numChannelsConfig == "32-Dome-12-10-8-2" } } // 32 HP, mais aussi 2 Subs
		{~serverOptions.numInputBusChannels = 0; ~serverOptions.numOutputBusChannels = 34; ~numChannelsFX = 32; // 32 HP, mais aussi Subs en 33 / 34

			// Adaptation des FX quand nb de canaux supérieurs à 16 faute de CPU
			~numChannelsFX2 = 16;
			~outChannelsFXSpaceCuts = [(0,2..30), ((0,2..30)+1)];
			// ~outChannelsFXSpaceCuts[0].collect { |i, id| i.postln; id.postln };
		};

		// Une fois que la distinction Performance ou multi-canale est faite, besoin de les regrouper pour l'utilisation ~numChannelsConfig pour la version stéréo
		if (~numChannels == 2, { ~numChannelsConfig = "2"});



		// numAudioBusChannels Par default 128 avant, mais maintenant 1024, donc plus bsesoin de le changer quand config de 64 HP
		// if (~numChannels > 16, {~serverOptions.numAudioBusChannels = 40 * 6} ); // correspondant à ~fxMulChannel
		// if (~numChannels > 32, {~serverOptions.numAudioBusChannels = 70 * 6} );





		if (~serverFX == 1, {
			currentEnvironment[serverFXV] = Server(nameFXV, NetAddr("127.0.0.1", portFXV));
			~serverOptionsFX = currentEnvironment[serverFXV].options;
			~serverOptionsFX.device = ~serverOptions.device;
			if (~setSampleRate == true, {~serverOptionsFX.sampleRate_(~sampleRate)} );
			~serverOptionsFX.pingsBeforeConsideredDead = ~serverOptions.pingsBeforeConsideredDead;
			~serverOptionsFX.numWireBufs_(~serverOptions.numWireBufs);
			~serverOptionsFX.maxNodes_(~serverOptions.maxNodes);
			~serverOptionsFX.memSize_(~serverOptions.memSize);
			~serverOptionsFX.numBuffers_(~serverOptions.numBuffers);
			~serverOptionsFX.maxSynthDefs_(~serverOptions.maxSynthDefs);
			~serverOptionsFX.hardwareBufferSize = ~serverOptions.hardwareBufferSize;
			~serverOptionsFX.zeroConf = ~serverOptions.zeroConf;
			~serverOptionsFX.memoryLocking = ~serverOptions.memoryLocking;
			~serverOptionsFX.numOutputBusChannels = ~serverOptions.numOutputBusChannels;

			~serverOptionsFX.numInputBusChannels = 40 * 6 /*~numChannels*/; // Important car dans les serveurs générateurs, il n'y en a que 2.
			~serverOptions.numOutputBusChannels = 40 * 6;
		});





		VBAPSpeakerArray.maxNumSpeakers = ~numChannels;



		// s.latency = 1.0; // pour réduire les late ???? - ServerTiming



		// Chemin nécessaire pour charger les fichiers html de code qui s'affichent dans les TextViews de la GUI
		// Mais pourquoi ~currentPath doit être indiqué auparavant et non pas dans le fichier de la GUI ???
		~currentPath = thisProcess.nowExecutingPath; // pour charger les presets & les fichiers html de code qui s'affichent dans les TextViews de la GUI

		/*
		// Auparavant avant l'IDE, ce code marchait pour lancer un fichier
		~home = Document.current.path.dirname ++ "/";
		this.executeFile( ~home ++ "uc33e3.scd" );
		// Désormais le code ci-dessous pour récupérer l'adresse
		thisProcess.nowExecutingPath;
		*/


	);





	// SynthDef Management

	~synthDefsFolderS1 = Platform.userAppSupportDir ++ "/synthdefsLive4Life-" ++ ~numChannelsConfig ++"-S1";
	~synthDefsFolderS2 = Platform.userAppSupportDir ++ "/synthdefsLive4Life-" ++ ~numChannelsConfig ++"-S2";

	// Création d'un dossier de synthé pour chaque type de config multi-canale
	// Nécessité de rajouter les synthés dans synthdefsInit, par exemple pour jitlib ou autres - utiliser SynthDescLib.send(s); ?????????
	if (PathName(~synthDefsFolderS1).isFolder == false, {~synthDefsFolderS1.mkdir; ~synthDefsFolderS2.mkdir; /*~synthDefsBuild = 1; ~synthDefsManagementChoose = 1*/ } );
	if (PathName(~synthDefsFolderS1).files == [ ], {~synthDefsBuild = 1; ~synthDefsManagementChoose = 1} ); // Construction des synthés si dossier vide

	// See SynthDesc helpfile
	// Store the SynthDef along with metadata
	// d.store(mdPlugin: TextArchiveMDPlugin);
	// Pas vraiment nécessaire car obligé de récupérer les descriptions des synthés avec SynthDescLib.global.read

	/*
	~synthDefsManagementChoose = 0; // 0 -> add / 1 -> load --- utile seulement si ~synthDefsBuild = 1
	*/
	// ~synthDefsManagementList = ["add", "store((mdPlugin: TextArchiveMDPlugin));", "writeDefFile(\""++~synthDefsFolder++"\")"];
	~synthDefsManagementList = ["add", "store", "store((mdPlugin: TextArchiveMDPlugin));"];
	~synthDefsManagement = ~synthDefsManagementList[~synthDefsManagementChoose];

	if (currentEnvironment[server] == ~server1, {SynthDef.synthDefDir = ~synthDefsFolderS1}, {SynthDef.synthDefDir = ~synthDefsFolderS2} );
	/*
	SynthDef.synthDefDir = "/Users/Xon/Library/Application Support/SuperCollider/synthdefsLiveForLife/"
	SynthDef.synthDefDir
	*/

	// Look at Server helpfile
	// all defs in this directory will be loaded when a local server boots
	/*
	"SC_SYNTHDEF_PATH".setenv("~/scwork/".standardizePath);
	"SC_SYNTHDEF_PATH".setenv("/Users/Xon77/Library/Application Support/SuperCollider/synthdefsLiveForLife-5-Centre/".standardizePath);
	"echo $SC_SYNTHDEF_PATH".unixCmd;
	*/

	if ( ~synthDefsBuild == 0, {"SC_SYNTHDEF_PATH".setenv(SynthDef.synthDefDir.standardizePath) });



	SynthDescLib.global.addServer(currentEnvironment[server]); // n'a pas l'air d'être nécessaire ???
	// SI, sinon les synthé du 2ème serveur ne sont pas chargés lors de la constuction des synthés et obligé de rebooter le server pour que les synthés soient lus

	if (~serverFX == 1, { SynthDescLib.global.addServer(currentEnvironment[serverFXV]); }); // n'a pas l'air d'être nécessaire au chargement des synthés dans le 2ème serveur ??? voire ci-dessus





	~windowHeight = Window.screenBounds.height/*.asInteger*/; // ~windowHeight = Window.availableBounds.height/*.asInteger*/;
	~windowWidth = Window.screenBounds.width/*.asInteger*/;
	if (~windowHeight == 1200, {~windowTopMargin = 0; ~windowUpperMargin = 6}, {~windowTopMargin = 26; ~windowUpperMargin = 0});










	currentEnvironment[server].waitForBoot(limit: 1000, onComplete:{

		currentEnvironment[server].sync; // 3.wait;

		// { // à décommenter pour mesurer la rapidité d'affichage de la GUI et réorganistion des sons

		// permet d'utiliser les Ndef bien que this.send(server, false) soit mis en commentaire dans SynthDescLib *initClass
		// SynthDescLib.send(s); // plus nécessaire



		// Problème Server failed to start lorsque le nb de SynthDefs à charger est > 3500 ou 4000 ?????????
		// '_ServerShmInterface_connectSharedMem' failed.
		// Augmentation de la limite à 1000 au lieu de 100 et rajout de s.initTree;



		// s.initTree; // Apparemment ne provoque pas d'erreur ???

		// sinon :
		// FAILURE IN SERVER /s_new Node 1 not found
		// FAILURE IN SERVER /n_set Node 1003 not found



		if (currentEnvironment[server] == ~server2, {
			~server2Window = currentEnvironment[server].makeWindow;
			if (~serverFX == 1, {
				~server2Window.window.alpha_(0.6).bounds_(Rect.new(33,925,283,94)).alwaysOnTop_(true);
			},{
				// ~server2Window.window.bounds_(Rect.new(0,124,305,100)).alwaysOnTop_(true);
				// ~server2Window = currentEnvironment[\server2].makeWindow;
				~server2Window.window.alpha_(0.7).bounds_(Rect.new(41, /*1080*/ (~windowHeight-120) ,274,94)).alwaysOnTop_(true);
			});
		});



		currentEnvironment[server].loadDirectory (Platform.userAppSupportDir ++ "/synthdefs", "loading Initial SynthDefs".postln); // Chargement des synthés initiaux

		currentEnvironment[server].sync;



		if (~serverFX == 1, {
			currentEnvironment[serverFXV].waitForBoot(limit: 1000, onComplete:{

				if (currentEnvironment[server] == ~server1, {
					~server1FXWindow = currentEnvironment[serverFXV].makeWindow; ~server1FXWindow.window.alpha_(0.6).bounds_(Rect.new(33,1070,283,94)).alwaysOnTop_(true);
				},{
					~server2FXWindow = currentEnvironment[serverFXV].makeWindow; ~server2FXWindow.window.alpha_(0.6).bounds_(Rect.new(33,1000,283,94)).alwaysOnTop_(true);

					~limiterNotification[serverNb] = 0; ~limiterFunction.(serverFXV, serverNb);
					// Ligne au dessus necessaire car sinon la limiteur ne se lance pas dès la première fois sur le 2 ème serveur FX
					// donc obligé de le redéclencher quand le 2ème serveur FX est vraiment en place
					/**** ERROR: SynthDef Limiter not found
					FAILURE IN SERVER /s_new SynthDef not found*/
				});
				currentEnvironment[serverFXV].loadDirectory (Platform.userAppSupportDir ++ "/synthdefs", "loading Initial SynthDefs".postln); // Chargement des synthés initiaux
				currentEnvironment[serverFXV].sync;
			});
			3.wait; // si retiré génération d'une erreur dans les synthés FX -> ERROR: binary operator '/' failed.
		});







		// Chargement des buffers du Kernel ambisonique : binaural et stéréo - mis à la fin de la spatialisation car le numéro de VBAP.bufnum change sinon XXX
		/*case
		{~ambATKConfig == "binaural"}
		{ ~binauralDecoder = ~binauralDecoder.interpret }
		{~ambATKConfig == "stereo"}
		{ ~stereoDecoder = FoaDecoderKernel.newUHJ };*/





		// Temps pour libérer le synthé lorsqu'il franchit un seuil ou est égal à 0
		~silenceTime = 0.1;





		// Activate limiter - transféré dans la GUI après le s.volume
		// prevents nan in audio & limiter in Bat lib
		// StageLimiter.activate(numChannels: ~numChannels);
		// StageLimiterCL.activate(numChannels: ~numChannels, level: 0.8, dur: 0.01); // XXXXXXXXXXXXXXX
		// StageLimiter.deactivate;



		/*
		SynthDef(\SanitizeLimiter, { |level = 0.8|
		var input = In.ar(0, ~numChannels);
		ReplaceOut.ar(0, SanitizeLimit.ar(input, level)) ;
		}).add;

		Synth(\SanitizeLimiter, target: RootNode(Server.default), addAction: \addToTail);
		*/



		/*
		SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, sigMax = 10 |

		var input, bad, badTrig, sign, signLatch, sig, limitSig;

		input = In.ar(0, /*2*/ ~numChannels);

		bad = CheckBadValues.ar(input, 0, 0);
		badTrig = (bad > 0) + (abs(input) > sigMax);

		// hold last sign to avoid sudden sign changes
		sign = input.sign;
		signLatch = Select.ar(badTrig, [sign, Latch.ar(sign, badTrig)]);

		sig = Select.ar(badTrig, [input, signLatch * sigMax]);

		ReplaceOut.ar(0, LeakDC.ar(Limiter.ar(input * limDrive, ampLimit) * postAmp));
		}).add;
		*/





		// Intérêt du SafetyNet vs limiter CL en termes d'efficacité d'explosion et de CPU ???
		// Le limiter CL comprend : Select / CheckBadValues / Limiter / LeakDC / ReplaceOut + Out & NumChannels pour le mixage du Sub (à optimiser en fonction du Quark SafetyNet)
		// SafetyNet comprend : ReplaceBadValues (Select / CheckBadValues + array) / ReplaceOut + .softclip ( d'autres synthés sont aussi dispos...)

		/*
		s.numChannels // ???
		Safety(s).numChannels;
		Safety(s).defaultDefName; Safety(s).synthDefs; Safety(s).synth
		Safety(s).defName = \safeClip
		Safety(s).defName = \safeLimit;
		Safety(s).initSynthDefs(5);
		Safety(s).enable; // remake list of default synthdefs for a given number of channels
		Safety(s).synth.set(\limit, 0.5); // set limit lower
		Safety.all;
		*/
		/*
		// Safety ne marche pas bien si server par défault ~server1 : ajoute 1 synthé et ne les supprime pas peu importe la commande ???
		Safety( s /*s*/ /*\localhost*/).enable;
		Safety( s /*s*/ /*\localhost*/).disable;
		Safety( ~server1 /*s*/ /*\localhost*/).disable; // Safety(s).enable; ou supprimer le quark - vient de façon automatique
		*/





		// Particularité Salle Claude Champagne et Dôme 32 HP - Overwrite POUR REASSIGNATION SUB

		case

		{ ~numChannelsConfig == "16-Dome-8-6-2-Clock" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				// Sub G 16 / D 17 - Assignation G / D sauf pour les HP 9 et 12 ou sorties 8 et 11, qui sont respectivement en Avant centre et en Arriere centre
				/*Out.ar(16, LPF.ar(NumChannels.ar(input[0, 7, 13, 14, 8, 5, 6, 12, 11], 1) * mulSub), 80); // HP réels 1 / 8 / 14 / 15 / 9 // Ne marche que pour le 1er input
				Out.ar(17, LPF.ar(NumChannels.ar(input[1, 2, 9, 15, 8, 3, 4, 10, 11], 1) * mulSub), 80); // HP réels 2 / 3 / 10 / 16 / 9 // Ne marche que pour le 1er input*/
				Out.ar(16, LPF.ar(Mix.new([input[0], input[7], input[13], input[14], input[8], input[5], input[6], input[12], input[11]], 1) * mulSub), 80);
				Out.ar(17, LPF.ar(Mix.new([input[1], input[2], input[9], input[15], input[8], input[3], input[4], input[10], input[11]], 1) * mulSub), 80);
			}).add;
		}

		{ ~numChannelsConfig == "16-Dome-8-6-2-Clock-CC" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				// Sub Av G 16 / D 17 / Ar G 18 / Ar D 19
				// 1. Assignation à chaque sub au point cardinal des 3 HP les + proches
				// 2. Attribution latérale pour les 2 HP au plafond 15 & 16 et avant/arrière pour HP 9 & 10
				// 3. Attribution latérale pour les 4 lointains avant de chaque côté (latérales pas prises en compte)
				/*Out.ar(16, LPF.ar(NumChannels.ar(input[0, 7, 13, 14, 8], 1) * mulSub), 80); // HP réels 1 / 8 / 14 / 15 / 9 // Ne marche que pour le 1er input
				Out.ar(17, LPF.ar(NumChannels.ar(input[1, 2, 9, 15, 8], 1) * mulSub), 80); // HP réels 2 / 3 / 10 / 16 / 9 // Ne marche que pour le 1er input
				Out.ar(18, LPF.ar(NumChannels.ar(input[5, 6, 12, 14, 11], 1) * mulSub), 80); // HP réels 6 / 7 / 13 / 15 / 12 // Ne marche que pour le 1er input
				Out.ar(19, LPF.ar(NumChannels.ar(input[3, 4, 10, 15, 11], 1) * mulSub), 80); // HP réels 4 / 5 / 11 / 16 / 12 // Ne marche que pour le 1er input*/
				Out.ar(16, LPF.ar(Mix.new([input[0], input[7], input[13], input[14], input[8]], 1) * mulSub), 80);
				Out.ar(17, LPF.ar(Mix.new([input[1], input[2], input[9], input[15], input[8]], 1) * mulSub), 80);
				Out.ar(18, LPF.ar(Mix.new([input[5], input[6], input[12], input[14], input[11]], 1) * mulSub), 80);
				Out.ar(19, LPF.ar(Mix.new([input[3], input[4], input[10], input[15], input[11]], 1) * mulSub), 80);
			}).add;
		}

		{ ~numChannelsConfig == "22-8+Dome-8-4-2-Pair" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				// Sub Av G 33 / D 34 / Ar G 35 / Ar D 36
				// 1. Assignation à chaque sub au point cardinal des 3 HP les + proches
				// 2. Attribution latérale pour les 2 HP au plafond 12 & 13
				// 3. Attribution latérale pour les 4 lointains avant de chaque côté
				/*Out.ar(32, NumChannels.ar(input[0, 2, 8, 12, 14, 16, 18, 20], 1) * mulSub);
				Out.ar(33, NumChannels.ar(input[1, 3, 9, 13, 15, 17, 19, 21], 1) * mulSub);
				Out.ar(34, NumChannels.ar(input[4, 6, 10, 12, 14, 16, 18, 20], 1) * mulSub);
				Out.ar(35, NumChannels.ar(input[5, 7, 11, 13, 15, 17, 19, 21], 1) * mulSub);*/
				Out.ar(32, LPF.ar(Mix.new([input[0], input[2], input[8], input[12], input[14], input[16], input[18], input[20]], 1) * mulSub), 80);
				Out.ar(33, LPF.ar(Mix.new([input[1], input[3], input[9], input[13], input[15], input[17], input[19], input[21]], 1) * mulSub), 80);
				Out.ar(34, LPF.ar(Mix.new([input[4], input[6], input[10], input[12], input[14], input[16], input[18], input[20]], 1) * mulSub), 80);
				Out.ar(35, LPF.ar(Mix.new([input[5], input[7], input[11], input[13], input[15], input[17], input[19], input[21]], 1) * mulSub), 80);
			}).add;
		}

		{ ~numChannelsConfig == "16-UsineC-2Octo" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				Out.ar(16, LPF.ar(Mix.new([input[0], input[1], input[2], input[3], input[4], input[5], input[6], input[7]], 1) * mulSub), 80);
				Out.ar(17, LPF.ar(Mix.new([input[8], input[9], input[10], input[11], input[12], input[13], input[14], input[15]]) * mulSub), 80);
			}).add;
		}

		{ ~numChannelsConfig == "24-UsineC-3Octo" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8, mulSub2 = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				Out.ar(24, LPF.ar(Mix.new([input[0], input[1], input[2], input[3], input[4], input[5], input[6], input[7]], 1) * mulSub), 80);
				Out.ar(25, LPF.ar(Mix.new([input[8], input[13], input[14], input[15], input[16], input[21], input[22], input[23]]) * mulSub2), 80);
				Out.ar(26, LPF.ar(Mix.new([input[9], input[10], input[11], input[12], input[17], input[18], input[19], input[20]]) * mulSub2), 80);
			}).add;
		}

		{ ~numChannelsConfig == "32-Dome-12-10-8-2" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				// 1. Assignation Gauche Droite
				/*Out.ar(32, NumChannels.ar(input[0, 11, 10, 9, 8, 7, 12, 21, 20, 19, 18, 22, 29, 28, 27, 30], 1, true) * mulSub); // Ne marche que pour le 1er input
				Out.ar(33, NumChannels.ar(input[1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 17, 23, 24, 25, 26, 31], 1, true) * mulSub);*/
				/*Out.ar(32, Mix.new(input[0, 11, 10, 9, 8, 7, 12, 21, 20, 19, 18, 22, 29, 28, 27, 30]) * mulSub);
				Out.ar(33, Mix.new(input[1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 17, 23, 24, 25, 26, 31]) * mulSub);*/
				Out.ar(32, LPF.ar(Mix.new([input[0], input[11], input[10], input[9], input[8], input[7], input[12], input[21], input[20], input[19], input[18], input[22], input[29], input[28], input[27], input[30]]) * mulSub), 80);
				Out.ar(33, LPF.ar(Mix.new([input[1], input[2], input[3], input[4], input[5], input[6], input[13], input[14], input[15], input[16], input[17], input[23], input[24], input[25], input[26], input[31]]) * mulSub), 80);
			}).add;
		}

		{ ~numChannelsConfig == "32-Dome-12-10-8-2-Motu" }
		{
			// Equivalent au StageLimiter, mais fait à la main
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);

				// 1. Assignation Gauche Droites
				Out.ar(32, NumChannels.ar(input[10, 20, 24, 22, 29, 16, 5, 9, 19, 31, 30, 17, 6, 8, 18, 7], 1) * mulSub); // Ne marche que pour le 1er input
				Out.ar(33, NumChannels.ar(input[11, 21, 25, 23, 28, 15, 4, 0, 12, 26, 27, 14, 3, 1, 13, 2], 1) * mulSub); // Ne marche que pour le 1er input
			}).add;
		}

		{ ~numChannelsConfig != "22-8+Dome-8-4-2-Pair" or: {~numChannelsConfig != "32-Dome-12-10-8-2"} or: {~numChannelsConfig != "32-Dome-12-10-8-2-Motu"} or: {~numChannelsConfig != "16-Dome-8-6-2-Clock-CC"} or: {~numChannelsConfig != "16-Dome-8-6-2-Clock"} or: {~numChannelsConfig != "24-UsineC-3Octo"} or: {~numChannelsConfig != "16-UsineC-2Octo"} }
		{
			SynthDef(\Limiter, { | limDrive = 1, ampLimit = 0.99, postAmp = 1, mulSub = 0.8 |
				var input = In.ar(0, /*2*/ ~numChannels);

				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]); // Pour réduire l'impact CPU de 2%
				// Check Bad Values -> repris de StageLimiter de Botuhan Bozkurt

				input = LeakDC.ar(input, 0.995);
				input = Limiter.ar(input * limDrive, ampLimit) * postAmp;
				// input = BHiPass4.ar(input, 50); // quel est le meilleur Ugen (efficace en termes de CPU) qui filtre les infra-basses pour les petits HP ?????????
				ReplaceOut.ar(0, input);
			}).add;

			/*
			BHiPass4
			BLowShelf
			BPeakEQ
			LeakDC
			*/
		};





		if (currentEnvironment[server] == ~server1, { ~limiter = 0 ! 2; ~limiterNotification = 0 ! 2; } );

		~limiterFunction = { |serverFX, serverNb|
			{
				if (~limiterNotification[serverNb] == 0, {
					~limiter[serverNb] = Synth(\Limiter, target: RootNode(currentEnvironment[serverFX]), addAction: \addToTail);
					("Limiter "++serverNb++" triggered").postln; ~limiterNotification[serverNb] = 1
				}, {
					("Limiter "++serverNb++" already playing").postln; /*~limiterNotification = 1*/} )
			}.defer(1)
		};

		// ~limiterNotification[serverNb] = 0;
		~limiterFunction.(serverFXV, serverNb);

		CmdPeriod.add({
			if (~server2.notNil, {
				~limiterNotification[0] = 0; ~limiterNotification[1] = 0;
				if (~serverFX == 0, {
					~limiterFunction.(\server1, 0); ~limiterFunction.(\server2, 1);
				},{
					~limiterFunction.(\serverFX1, 0); ~limiterFunction.(\serverFX2, 1);
				});
			},{
				~limiterNotification[0] = 0;
				if (~serverFX == 0, {
					~limiterFunction.(\server1, 0);
				},{
					~limiterFunction.(\serverFX1, 0);
				});
			});
			try { ~spatioScopePlayer.stop };

		});

		// ~limiter.set(\ampLimit, 0.8);










		// Model for the global volume of the synthesis server Volume (server, startBus: 0, numChans, min: -90, max: 6, persist: false)
		// Create and return a new instance of Volume for a given server, ranging from startBus over numChans (usually the server's number of output bus channels)

		/*
		~serverVolume = s.volume;
		// if (~serverVolume.isNil, { ~serverVolume = s.volume }); // Protection pour éviter de le relancer quand relancement de la GUI
		*/

		if (currentEnvironment[server] == ~server1, { ~serverVolume = 0 ! 2 });

		~serverVolume[serverNb] = Volume(currentEnvironment[serverFXV], 0, ~numChannels, -90, 6, false /*true*/).lag_(7);

		currentEnvironment[server].sync;


		// Génération de 2 synthés volumeAmpControl si mise en veille de l'ordi ???
		// ~serverVolume.lag = 1;
		// ~serverVolume.lag_(1);

		/*
		~serverVolume.min;
		~serverVolume.max;
		~serverVolume.volume = rrand(-50, 5);
		~serverVolume.setVolumeRange(-90, 8);
		~serverVolume.mute;
		~serverVolume.unmute;
		~serverVolume.numChans;
		~serverVolume.gui; // separate window
		*/





		// Allocation de buffers pour le synthé WarpIn
		if (currentEnvironment[server] == ~server1, { ~bufEmpty = 0 ! 2 });
		~bufEmpty[serverNb] = Buffer.alloc(currentEnvironment[server], currentEnvironment[server].sampleRate * 16, 1);



		~chaoticEnvString = 0 ! 3; // ajout des buffers d'enveloppes

		// ~chaoticEnv[0] = Env([0, 1], [0.1]) ++ Env.saw2(segs: 700, amp: 1, startPhase: 0, endPhase: 1900pi, dur: 1-0.1-0.1).range(0, 1) ++ Env.cutoff(0.1, 0); // avec fades
		// à utiliser pour éviter Env.linen dans les enveloppes -> plus économique ???
		~chaoticEnvString[0] = "Env.saw2(segs: 700, startPhase: 0, endPhase: 1900pi, amp: 1, dur: 1) .range(0, 1)";
		~chaoticEnvString[1] = "Env.triangle2(segs: 700, startPhase: 0, endPhase: 401pi, amp: 1, dur: 1) .range(0, 1)";
		~chaoticEnvString[2] = "Env.square2(segs: 1000, startPhase: 0, endPhase: 401pi, amp: 1, dur: 1) .range(0, 1)";

		~chaoticEnv = 0 ! 3; // ajout des enveloppes
		3.do { |i| ~chaoticEnv[i] = ~chaoticEnvString[i].interpret };
		~bufEnvFunc = { |servers, serverNbs, i| ~bufEnv[serverNbs][i] = Buffer.sendCollection(servers, ~chaoticEnv[i].asArray, numChannels: 1, wait: -1, action: { "Chaotic Buffer loaded".postln }) };

		// currentEnvironment[\server1]

		if (currentEnvironment[server] == ~server1, {
			~bufEnv = 0 ! 3 ! 2; // ajout des buffers d'enveloppes
			// ~bufEnvFunc = { |i| ~bufEnv[0][i] = Buffer.sendCollection(currentEnvironment[server], ~chaoticEnv[i].asArray, numChannels: 1, wait: -1, action: { "Chaotic Buffer loaded".postln }) };
			// 3.do { |i| ~bufEnvFunc.(i) };
		},{
			// ~bufEnvFunc = { |i| ~bufEnv[1][i] = Buffer.sendCollection(currentEnvironment[server], ~chaoticEnv[i].asArray, numChannels: 1, wait: -1, action: { "Chaotic Buffer loaded".postln }) };
			// 3.do { |i| ~bufEnvFunc.(i) };
		});

		3.do { |i| ~bufEnvFunc.(currentEnvironment[server], serverNb, i) };

		/*
		~chaoticEnv[0].plot
		~chaoticEnv[1].plot
		~chaoticEnv[2].plot
		~bufEnv[0].getn(0, 800, {|msg| msg.postcs});
		*/



		// path to auxiliary wav file for Qitch - frequency tracking
		if (currentEnvironment[server] == ~server1, {
			~qitchBuffer = 0 ! 2;
			if (~sampleRate == 44100, {
				~qitchBuffer[0] = Buffer.read(currentEnvironment[server],
					// "/Users/Xon/sc3-plugins/build/build_osx/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav"
					Platform.userAppSupportDir ++ "/Extensions/plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav" // L'alias ne marche pas, mais OK avec le Symbolic Link
				);
			}, {
				~qitchBuffer[0] = Buffer.read(currentEnvironment[server],
					// "/Users/Xon/sc3-plugins/build/build_osx/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR48000.wav"
					Platform.userAppSupportDir ++ "/Extensions/plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR48000.wav" // L'alias ne marche pas, mais OK avec le Symbolic Link
				);
			});
		},{
			if (~sampleRate == 44100, {
				~qitchBuffer[1] = Buffer.read(currentEnvironment[server],
					// "/Users/Xon/sc3-plugins/build/build_osx/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav"
					Platform.userAppSupportDir ++ "/Extensions/plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR44100.wav" // L'alias ne marche pas, mais OK avec le Symbolic Link
				);
			}, {
				~qitchBuffer[1] = Buffer.read(currentEnvironment[server],
					// "/Users/Xon/sc3-plugins/build/build_osx/SC3plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR48000.wav"
					Platform.userAppSupportDir ++ "/Extensions/plugins/PitchDetection/extraqitchfiles/QspeckernN2048SR48000.wav" // L'alias ne marche pas, mais OK avec le Symbolic Link
				);
			});
		});




		// j -> enveloppe -> utilisé préalablement pour GrainIn, GrainSin, GrainFM -> utilisation actuellement d'une enveloppe générique avec -1
		/*j = Env([0, 1, 0], [0.5, 0.5], [-5, 5]);
		j = Buffer.sendCollection(s, j.discretize, 1);*/



		currentEnvironment[server].sync;




















		( // Load Synthdefs





			// Enveloppes

			/*
			Check SC Book Chapter 16 Microsound
			"/Users/Xon/Documents/SC3/Super Collider Book/code/Ch 16 Microsound/c16_micro_figures2_anatomy.scd".openDocument;


			( // a sinc function envelope
			q = q ? ();
			q.makeSinc = { |q, num=1, size=400|
			dup({ |x| x = x.linlin(0, size-1, -pi, pi) * num; sin(x) / x }, size);
			};
			a = q.makeSinc(6);
			a.plot(bounds: Rect(0,0,409,200), minval: -1, maxval: 1);
			)


			( // more envelopes plotted
			[ 	Env.sine,
			Env([0, 1, 1, 0], [0.2, 0.6, 0.2], \sin),
			Env([0, 1, 1, 0], [0.2, 0.6, 0.2], \lin),
			Env([0, 1, 1, 0], [0.2, 0.6, 0.2], \welch),
			Env([1, 0.001], [1], \exp),
			Env([0.001, 1], [1], \exp),
			Env.perc(0.05, 0.95)
			]	.collect(_.discretize(400))
			.add(q.makeSinc(6)).clump(4).collect { |gr4, i|
			gr4.flop.flat.plot(
			["Sine (gauss), Quasi-gauss, Line, Welch",
			"Exp decay, Rev Exp decay, Perc, Sinc" ][i],
			Rect(420 * i + 100, 300, 408, 400), numChannels: 4)
			};
			)


			( // Enveloppes plotted in Synths
			var atk = 0.1, rel = 0.1, durenv = 1, amp = 1;
			var width = 0.6, holdT = durenv * width, fadeT = 1 - width * durenv * 0.5;
			var width2 = 0.2, holdT2 = durenv * width2, fadeT2 = 1 - width2 * durenv * 0.5;
			[ 	Env.linen(atk, durenv-atk-rel, rel, amp),
			Env.sine,
			// Env.sine/*(durenv, amp)*/,
			Env([0, 1, 1, 0], [fadeT, holdT, fadeT], \sin),
			Env([0, 1, 1, 0], [fadeT2, holdT2, fadeT2], \sin), // \welch
			Env.perc(atk, 1-atk, amp), // pas besoin de amp - par défaut 1 ?
			Env.perc(1-rel, rel, amp),
			Env([1, 0.001], [1], \exp),
			Env([0.001, 1], [1], \exp),
			]	.collect(_.discretize(400))
			.add(q.makeSinc(6)).clump(4).collect { |gr4, i|
			gr4.flop.flat.plot(
			["Line, Sine, Gauss1, Gauss2", "Perc, PercRev, Exp, ExpRev", "SincFunc"][i],
			Rect(420 * i + 100, 300, 408, 400), numChannels: 4)
			};
			)


			( // Enveloppes plotted in Synths 2
			var atk = 0.1, rel = 0.1, durenv = 1, amp = 1;
			var width = 0.998, holdT = durenv * width, fadeT = 1 - width * durenv * 0.5;
			var width2 = 0.4, holdT2 = durenv * width2, fadeT2 = 1 - width2 * durenv * 0.5;
			q = q ? ();
			q.makeSinc = { |q, num=1, size=400|
			dup({ |x| x = x.linlin(0, size-1, -pi, pi) * num; sin(x) / x }, size);
			};
			[ 	Env.linen(atk, durenv-atk-rel, rel, amp),
			Env.sine,
			// Env.sine/*(durenv, amp)*/,
			Env([0, 1, 1, 0], [fadeT, holdT, fadeT], \sin),
			Env([0, 1, 1, 0], [fadeT2, holdT2, fadeT2], \sin), // \welch
			Env.perc(atk, 1-atk, amp), // pas besoin de amp - par défaut 1 ?
			Env.perc(1-rel, rel, amp),
			Env([1, 0.001], [1], \exp),
			Env([0.001, 1], [1], \exp),
			Env.square2(segs: 1000, amp: 1, startPhase: 0, endPhase: 401pi, dur: 1).range(0, 1), // Bad Fadeout
			Env.saw2(segs: 700, amp: 1, startPhase: 0, endPhase: 1900pi, dur: 1).range(0, 1),
			Env.triangle2(segs: 700, amp: 1, startPhase: 0, endPhase: 401pi, dur: 1).range(0, 1),
			]	.collect(_.discretize(400))
			.add(q.makeSinc(6)).clump(4).collect { |gr4, i|
			gr4.flop.flat.plot(
			["Line, Sine, Gauss1, Gauss2", "Perc, PercRev, Exp, ExpRev", "Chaos1, Chaos2, Chaos3, SincFunc"][i],
			Rect(420 * i + 100, 300, 408, 400), numChannels: 4)
			};
			)





			// Changement du paramètre env en réduisant le nb de synthés et le basculant sur le pattern // Checker impact Server ??? trop gourmand (40% vs 30%)
			// env = Control.names([\envelope]).kr(env.asArray);
			("_Init Buffers & Synths 20.scd").loadRelative;
			("_Init GUI 37.scd").loadRelative;
			("_Init Pattern 32.scd").loadRelative;



			// Env is fixed-length (e.g. Env.linen, Env.perc) ?????????
			(
			SynthDef(\sin, {
			arg out=0, amp=1, gate=1, freq=440;
			var ou;
			var env, envctl;

			env = Env.adsr(0.02, 0.2, 0.25, 0.1, 1, -4);
			//env = Env.newClear(6);

			envctl = Control.names([\adsr]).kr( env.asArray );
			ou = SinOsc.ar( freq);
			ou = ou * EnvGen.kr(envctl, gate, doneAction:2);
			Out.ar(out, ou * amp)
			}).add;
			)



			Env.perc(0.1, 1, 1, [-4, -4]).plot
			Env.perc(0.1, 1, 1, [4, 4]).plot
			Env.perc(0.1, 1, 1, [4, -4]).plot
			Env.perc(0.1, 1, 1, [-4, 4]).plot

			*/










			// Voire https://scsynth.org/t/envelope-in-a-buffer-how-to/2046 XXXXXXXXXXXXXXXXXXXX
			// pour intégrer l'enveloppe directement dans le pattern et réduire le nombre de définitions de synthés d'enveloppe de 5 à 3
			// Peut être plus de travail pour le pattern, mais celà permmettrait de faire beaucoup plus de spatialisations différentes

			~allEnvsGUI = [	"Line1", "Line2", /*"Sine",*/ "Gauss1", "Gauss2", "Perc1", "Perc2", "PercRev1", "PercRev2", "Spec1-Line1", "Spec2-Line1", "Spec3-Line1", "Spec1-Line2", "Spec2-Line2", "Spec3-Line2", "Exp", "ExpRev" ];

			~allEnvs = [ // 5 Enveloppe Synths
				["Line", /*"Sine",*/ "Gauss", "Perc", "SpecVar", "Exp"],

				[ // Functions

					// var w, x, y, z, r, s, t, u, v, a, b; -> intégration de variables pour la spatialisation ambisonique
					// & var spadur = durenv; à retirer car enveloppe fixe retirée XXXXXXXXX

					// Pour	couper les synthés lorsque le signal franchit le seuil 0
					// inBusVol = In.kr(busVolume);
					// DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);
					// FreeSelf.kr(inBusVol <= 0).poll; // a pratiquement le même effet - et en termes de CPU ???
					// FreeSelf.kr(inBusVol == 0).poll; // Pourquoi cette version ne marche pas ???

					// 0 - Enveloppe linéaire Variable
					// Durée totale est égale à durenv // peut provoquer des clics si durenv est extrêmement court
					// Voire si la déclaration de variables superflues pour certains synthés causent une augmentation de CPU ????????????????????
					"var inBusVol = In.kr(busVolume);
// var env = EnvGen.ar(Env.linen(atk, 1-atk-rel, rel, 1, [atkCurve, relCurve]), timeScale: durenv, doneAction: 2); // ne prenait pas en compte relCurve
var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, 1-atk-rel, rel], [atkCurve, 0, relCurve]), timeScale: durenv, doneAction: 2);
var spadur = durenv;
DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",
					// Env.linen(0.1, 0.2-0.2, 0.1, 1).plot2 // dans le cas ou durenv est égale à atk + rel -> pas de sustain
					// Env.linen(0.1, 0.1-0.2, 0.1, 1).plot2 // dans le cas ou durenv est < que atk + rel -> seulement une attaque et clic

					// 1 - Enveloppe sinusoïdale (approx. gaussian-shaped)
					// Durée totale est égale à durenv
					/*"var chainA, chainB, panSpectral, pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM, micsVM, w, x, y, z, r, s, t, u, v, a, b, /* */ c, d, e, f, g, h, i, j, k, l, m;
					var inBusVol = In.kr(busVolume);
					var env = EnvGen.ar(Env.sine(durenv, 1), doneAction: 2);
					var spadur = durenv;
					DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",*/

					// 2 - Enveloppe gaussienne (quasi-gaussian envelope, with a hold time in the middle)
					// Durée totale est égale à durenv
					"var inBusVol = In.kr(busVolume);
var fadeT = 1 - width * 0.5;
var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeT, width, fadeT], \\sin), levelScale: 1, timeScale: durenv, doneAction: 2);
var spadur = durenv;
DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",

					// 3 - Enveloppe percussive & percussive inversée
					// var env = EnvGen.ar(Env.perc(atk, 1-atk, amp), timeScale: durenv, doneAction: 2); // Enveloppe percussive
					// var env = EnvGen.ar(Env.perc(1-rel, rel, amp), timeScale: durenv, doneAction: 2); // Enveloppe percussive inversée
					// Durée totale est égale à durenv
					"var inBusVol = In.kr(busVolume);
var env = EnvGen.ar(Env.perc(atkPerc, relPerc, 1, [atkCurve, relCurve]), timeScale: durenv, doneAction: 2);
var spadur = durenv;
DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",

					// 4 - Enveloppe spéciale chaotique "fractale" déterminée Variable
					// Durée totale est égale à durenv
					"var inBusVol = In.kr(busVolume);
var numSeg = Index.kr(bufSpec, 1);
var env = DemandEnvGen.ar(
Dbufrd(bufSpec, Dseries(0, 4, numSeg+1)),
Dbufrd(bufSpec, Dseries(5, 4, numSeg)),
Dbufrd(bufSpec, Dseries(6, 4, numSeg)),
Dbufrd(bufSpec, Dseries(7, 4, numSeg)),
timeScale: durenv) * EnvGen.ar(Env([0, 1, 1, 0], [atk, 1-atk-rel, rel], [atkCurve, 0, relCurve]), timeScale: durenv, doneAction: 2);
var spadur = durenv;
DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",

					// 4b - Enveloppe spéciale chaotique changeante Variable
					// Durée totale est égale à durenv
					/* "var env = DemandEnvGen.ar(
					Dwhite(0, 1, inf), // levels
					Dwhite(SampleDur.ir, 0.001, inf) /** MouseY.kr(0, 100, 0)*/, // dur
					Diwhite(-8, 8, inf), // shape
					timeScale: durenv) * EnvGen.ar(Env.linen(atk, 1-atk-rel, rel, amp), timeScale: durenv, doneAction: 2);
					var spadur = durenv;",
					*/

					// 4c - Enveloppe spéciale chaotique "fractale" à déterminer ???
					/*"var enveloppe = Env.newClear(1000);
					var envctl = Control.names([\envi]).kr(enveloppe.asArray);
					var env = EnvGen.ar(envctl, levelScale: amp, timeScale: durenv, doneAction: 2);"*/

					// 5 - Enveloppe exponentielle & exponentielle inversée
					// var env = EnvGen.ar(Env([1, 0.001], [amp], \\exp), timeScale: durenv, doneAction: 2); // Enveloppe exponentielle
					// var env = XLine.ar(amp, amp * 0.001, durenv, doneAction: 2); // Enveloppe exponentielle bis
					// var env = EnvGen.ar(Env([0.001, 1], [amp], \\exp), timeScale: durenv, doneAction: 2); // Enveloppe exponentielle inversée
					// var env = XLine.ar(amp * 0.001, amp, durenv, doneAction: 2); // Enveloppe exponentielle inversée bis
					// Durée totale est égale à durenv
					"var inBusVol = In.kr(busVolume);
var env = XLine.ar(1 * envexp1, 1 * envexp2, durenv, doneAction: 2);
var spadur = durenv;
DetectSilence.kr(inBusVol, time: silenceTime, doneAction:2);",

			]];

			~allEnvsSize = ~allEnvs[0].size; // Info Pour le pattern






























			( // Spatialisation

				/*
				spatialization Post	:
				- Tour_of_Ugens  - Artificial Space - Parallel Structures
				- SuperCollider Book
				- Check out the Haas effect: http://en.wikipedia.org/wiki/Haas_effect
				- http://www.dewdrop-world.net/words/blog5.php/2010/09/17/reverb-for-spatialization
				- http://sonenvir.at/

				Two Channel Spatialization Effects :
				- Search BaBo (reverb) paper! It works fine in Csound.

				Seminar: Realtime Sound Spatialization with Wave Field Synthesis (18-20 June, Barcelona)



				// PanAZ vs PanX XXXXXXXXX
				// PanAz wraps around in a circle, PanX doesn't. So PanAz is typically used with a circular setup of speakers, PanX with a line of speakers.



				Question about panning ugen
				http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/question-about-panning-ugen-td5541234.html#a5546548

				SynthDef(\test, {
				var src, loc, ienv, rev;
				src = PinkNoise.ar(LFSaw.kr(-10, 0, 0.25, 0.25) ** 2);
				loc = MouseX.kr(-1, 1);
				ienv = IEnvGen.kr(InterplXYC([-1, 0, \sin], [0, 1, \sin], [1, 0]), loc);
				src = LPF.ar(src, 100 + (ienv * 4000));
				rev = FreeVerb.ar(src, 0.8, 0.6) * (1 - ienv) * 0.2;
				Out.ar(0, Pan2.ar(src, loc) * ienv + rev.dup);
				}).add;


				a = Synth(\test);
				a.free;

				*/





				/*
				Calculating radians & degrees

				45.degrad;
				0.5pi.raddeg;

				-0.25pi, 0.25pi -> 2 channels
				-0.25pi, 0.25pi, 0.75pi, 1.25pi; -> 4 channels
				-0.25pi, 0.25pi, 0pi, 0.75pi, 1.25pi; -> 5 channels // Pas la config 5.1 -> -30 / 0 / 30 / 110 / -110

				-0.25pi.raddeg;
				0.25pi.raddeg;
				0.75pi.raddeg;
				1.25pi.raddeg;
				2pi.raddeg / 8;



				degrees * pi / 180 (degrees -> radians)
				radians * 180 / pi (radians -> degrees)

				If methods don't exist, you could always add the following in a file
				to your classpath:

				+ SimpleNumber {
				toDegrees { ^this * 180 / pi }
				toRadians { ^this * pi / 180 }
				}

				You can find a good place to put such a file (doesn't matter what you
				name it -- just needs to end in .sc, for example SimpleNumberExt.sc)

				Then:

				180.toRadians
				pi.toDegrees
				*/





				/*
				Test simple ambisonique avec la 1ère trajectoire

				~trajBuf = ~trajectoryView.object.asBuffer(s);
				~trajBufDur = ~trajectoryView.object.duration;
				~trajectoryBuffers

				// Ambisonique du 1er ordre

				({ ~levelScale = 0.5; ~duration = 10; ~ratio = (~duration/~trajectoryBuffers[0][1]).reciprocal;
				#a, b = WFSPathPlayer.kr(~trajectoryBuffers[0][0], ratio: ~ratio, loop: 0, doneAction: 2);
				#w, x, y, z = BFEncode2.ar(WhiteNoise.ar, (a * ~levelScale).poll, (b * ~levelScale).poll, 0, 0.3);
				//decode for 5 channels
				BFDecode1.ar(w, x, y, z, [-0.25pi, 0.25pi, 0pi, 0.75pi, 1.25pi], 0);
				}.play); // .scope(5)

				// Ambisonique du 2nd ordre - test apparemment OK ??? -> précision

				({ var w, x, y, z, r, s, t, u, v, a, b;
				~levelScale = 0.5; ~duration = 10; ~ratio = (~duration/~trajectoryBuffers[0][1]).reciprocal;
				#a, b = WFSPathPlayer.kr(~trajectoryBuffers[0][0], ratio: ~ratio, loop: 0, doneAction: 2);
				#w, x, y, z, r, s, t, u, v = FMHEncode2.ar(WhiteNoise.ar,(a * ~levelScale).poll, (b * ~levelScale).poll, 0);
				//decode for 5 channel
				FMHDecode1.ar(w, x, y, z, r, s, t, u, v, [-0.25pi, 0.25pi, 0pi, 0.75pi, 1.25pi], 0, 0.3);
				}.play); // .scope(5)
				*/





				if (currentEnvironment[server] == ~server1, {~configVBAPBuffers = 0 ! 2} ); // Chargement des Buffers VBAP sur les 2 serveurs

				case

				{~numChannelsConfig == "2"}
				// Config Output 2 sorties
				// Program ->  Front Links (0)  /  Front Right (1)
				// Console ->  Front Links (1)  /  Front Right (2)  ->  +1
				{~configOuts = "[ src1[0], src1[1] ]"; ~configOuts2 = "[ src2[0], src2[1] ]";

					~configOutsCircS = "[ src2[0], src2[1] ]";
					~configOutsCircM = "[ src1[0], src1[1] ]";

					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1] ]"; ~numChannelsVP = ~numChannels;
					~configAmbi = "[ -0.25pi, 0.25pi ]";
					~configVBAP = VBAPSpeakerArray.new(2, [-45, 45]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					/*
					VBAPSpeakerArray.new(2, ((..7) / 8 * 360).wrap(-180,180)).loadToBuffer(server);
					((..7) / 8 * 360).wrap(-180,180) -> [ 0, 45, 90, 135, -180, -135, -90, -45 ]
					*/
				}
				// Pourquoi écart de 90° alors qu'il doit être de 60° en stéréo ?????????


				{~numChannelsConfig == "4"}
				// Config Output 4 sorties - Clockwise
				// Program ->  Front Links (0)  /  Front Right (1)  /  Rear Right (2)  /  Rear Links (3)
				// Console ->  Front Links (1)  /  Front Right (2)  /  Rear Right (3)  /  Rear Links (4)  ->  +1
				{~configOuts = "[ src1[0], src1[1], src1[2], src1[3] ]"; ~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3] ]";

					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3] ]"; ~numChannelsVP = ~numChannels;
					~configAmbi = "[ -0.25pi, 0.25pi, 0.75pi, 1.25pi ]";
					~configVBAP = VBAPSpeakerArray.new(2, [ -45, 45, 135, -135 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.25pi, 0.25pi, 0.75pi, 1.25pi ].raddeg.wrap(-180,180)
				}


				{~numChannelsConfig == "5-Centre"}
				// Config Output 5 sorties - Clockwise sauf Centre = 3
				// Program ->  Front Links (0)  /  Front Right (1)  /  Centre (2)  /  Rear Right (3)  /  Rear Links (4)
				// Console ->  Front Links (1)  /  Front Right (2)  /  Centre (3)  /  Rear Right (4)  /  Rear Links (5)  ->  +1
				{~configOuts = "[ src1[0], src1[2], src1[1], src1[3], src1[4] ]"; ~configOuts2 = "[ src2[0], src2[2], src2[1], src2[3], src2[4] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4] ]";

					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[2], src[1], src[3], src[4] ]"; ~numChannelsVP = ~numChannels;
					~configAmbi = "[ -0.25pi, 0.25pi, 0, 0.75pi, 1.25pi ]";
					~configVBAP = VBAPSpeakerArray.new(2, [ -45, 45, 0, 135, -135 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.25pi, 0.25pi, 0, 0.75pi, 1.25pi ].raddeg.wrap(-180,180)
				}


				{~numChannelsConfig == "5-Clock"}
				// Config Output 5 sorties - Clockwise à partir du Centre XXXXXX
				// Program ->  Centre (0)  /  Front Right (1)  /  Rear Right (2)  /  Rear Links (3)  /  Front Links (4)
				// Console ->  Centre (1)  /  Front Right (2)  /  Rear Right (3)  /  Rear Links (4)  /  Front Links (5)  ->  +1
				{~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4] ]"; ~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4] ]";

					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4] ]"; ~numChannelsVP = ~numChannels;
					~configAmbi = "[ 0, 0.25pi, 0.75pi, 1.25pi, -0.25pi ]";
					~configVBAP = VBAPSpeakerArray.new(2, [ 0, 45, 135, -135, -45 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ 0, 0.25pi, 0.75pi, 1.25pi, -0.25pi ].raddeg.wrap(-180,180)
				}


				{~numChannelsConfig == "7"} // à vérifier ?????????
				// Config Output 7 sorties - Clockwise à partir du Centre
				// Program ->  Centre (0)  /  Front Right (1)  /  Middle Right (2)  /  Rear Right (3)  /  Rear Links (4)  /  Middle Links (5)  /  Front Links (6)
				// Console ->  Centre (1)  /  Front Right (2)  /  Middle Right (3)  /  Rear Right (4)  /  Rear Links (5)  /  Middle Links (6)  /  Front Links (7)  ->  +1
				{~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6] ]"; ~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6] ]";

					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6] ]"; ~numChannelsVP = ~numChannels;
					~configAmbi = "[ 0, 0.25pi, 0.5pi, 0.75pi, 1.25pi, -0.5pi, -0.25pi ]"; // ~configAmbi à vérifier ?????????
					~configVBAP = VBAPSpeakerArray.new(2, [ 0, 45, 90, 135, -135, -90, -45 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ 0, 0.25pi, 0.5pi, 0.75pi, 1.25pi, -0.5pi, -0.25pi ].raddeg
					// [ 0, 0.25pi, 0.5pi, 0.75pi, 1.25pi, -0.5pi, -0.25pi ].raddeg.wrap(-180,180)
				}
				// {~configOuts = "[ src1[0], src1[2], src1[1], src1[4], src1[6], src1[5], src1[3] ]"} // Config alternant gauche / droite


				{~numChannelsConfig == "8-Centre"}
				// Config Output 8 sorties Centre - Clockwise à partir du Centre
				// Program ->  Centre (0)  /  Front Right (1)  /  Right (2)  /  Rear Right (3)  /  Rear (4)  /  Rear Links (5)  /  Links (6)  /  Front Links (7)
				// Console ->  Centre (1)  /  Front Right (2)  /  Right (3)  /  Rear Right (4)  /  Rear (5)  /  Rear Links (6)  /  Links (7)  /  Front Links (8)  ->  +1
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configAmbi = "[ 0, 0.25pi, 0.5pi, 0.75pi, 1pi, 1.25pi, 1.5pi, -0.25pi ]";
					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = ~numChannels;
					// Ecart de 0.25pi.raddeg ou 45° entre les enceintes                                                 0    1        2     3      4     5       6        7
					// [ 0, 0.25pi, 0.5pi, 0.75pi, pi, 1.25pi, 1.5pi, -0.25pi ].raddeg;
					// ou [ 0, 0.25pi, 0.5pi, 0.75pi, pi, 1.25pi, 1.5pi, 1.75pi ].raddeg;
					// [ 0, 0.25pi, 0.5pi, 0.75pi, pi, 1.25pi, 1.5pi, 1.75pi ].raddeg.differentiate;
					// 360 - 45 // qui correspond à 1.75pi.raddeg = 315
					~configVBAP = VBAPSpeakerArray.new(2, [ 0, 45, 90, 135, -180, -135, -90, -45 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ 0, 0.25pi, 0.5pi, 0.75pi, 1pi, 1.25pi, 1.5pi, -0.25pi ].raddeg.wrap(-180,180)
				}


				{~numChannelsConfig == "8-PairClock"}
				// Config Output 8 sorties Paire (sans Centre) - Clockwise à partir de la gauche
				// Program ->  Front Links (0)  /  Front Right (1)  /  Middle1 Right (2)  /  Middle2 Right (3)  /  Rear Right (4)  /  Rear Links (5)  /  Middle2 Links (6)  / Middle1 Links (7)
				// Console ->  Front Links (1)  /  Front Right (2)  /  Middle1 Right (3)  /  Middle2 Right (4)  /  Rear Right (5)  /  Rear Links (6)  /  Middle2 Links (7)  / Middle1 Links (8)  ->  +1
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ]";
					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = ~numChannels;
					// Ecart de 0.25pi.raddeg ou 45° entre les enceintes                                                     0         1        2        3        4        5        6         7
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg;
					// ou [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, 1.625pi ].raddeg;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, 1.625pi ].raddeg.differentiate;
					// 360 - 22.5 - 45 // qui correspond à 1.625pi.raddeg = 292.5
					~configVBAP = VBAPSpeakerArray.new(2, [ -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180)
				}


				{~numChannelsConfig == "8-PairPair"}
				// Config Output 8 sorties Paire en alternant gauche / droite - Changement ~configOuts si impératif de sorties par exemple XXXXXX
				// Changement Config Program selon impératif de sorties en alternant gauche / droite -> FL (1) / FR (2) / M1L (3) / M1R (4) / M2L (5) / M2R (6) / RL (7) / RR (8)
				// Regroupement 4 pistes Clockwise -> Links = 1/3 - Right 2/4 - Rear Right 6/8 - Rear Left 5/7
				{ ~configOuts2 = "[ src2[0], src2[1], src2[7], src2[2], src2[6], src2[3], src2[5], src2[4] ]";
					~configOuts = "[ src1[0], src1[1], src1[7], src1[2], src1[6], src1[3], src1[5], src1[4] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[7], src2[2], src2[6], src2[3], src2[5], src2[4] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[7], src1[2], src1[6], src1[3], src1[5], src1[4] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi ]";
					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[7], src[2], src[6], src[3], src[5], src[4] ]"; ~numChannelsVP = ~numChannels;
					//                                                                                                       0         1         7        2        6        3        5        4
					~configVBAP = VBAPSpeakerArray.new(2, [ -22.5, 22.5, -67.5, 67.5, -112.5, 112.5, -157.5, 157.5 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi ].raddeg.wrap(-180,180)
				}

				// A faire - repris de 8-PairClock ?????????
				{~numChannelsConfig == "16-PairClock"}
				// Config Output 16 sorties Paire (sans Centre) - Clockwise à partir de la gauche
				// Program ->  Front Links (0)  /  Front Right (1)  /  Middle1 Right (2)  /  Middle2 Right (3)  /  Rear Right (4)  /  Rear Links (5)  /  Middle2 Links (6)  / Middle1 Links (7)
				// Console ->  Front Links (1)  /  Front Right (2)  /  Middle1 Right (3)  /  Middle2 Right (4)  /  Rear Right (5)  /  Rear Links (6)  /  Middle2 Links (7)  / Middle1 Links (8)  ->  +1
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ]";
					~configOutsVPM = ~configOuts; ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = ~numChannels;
					~configVBAP = VBAPSpeakerArray.new(2, [ -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180)
				}

				{~numChannelsConfig == "16-Dome-8-6-2-Pair"}
				// Config Output Dome 16 sorties - Paire - Placement de la 2ème couronne à 45° en élévation ???
				{
					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = 8 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi, -0.3333pi, 0.3333pi, (-0.3333*2)*pi, (0.3333*2)*pi, 0pi, 1pi, -0.5pi, 0.5pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.5pi, 0.5pi ]"; // 0 / 45 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-22.5, 0], [22.5, 0], [-67.5, 0], [67.5, 0], [-112.5, 0], [112.5, 0], [-157.5, 0], [157.5, 0], [-60, 45], [60, 45], [-120, 45], [120, 45], [0, 45], [-180, 45], [-90, 85], [90, 85] ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [[360-22.5, 0], [22.5, 0], [360-67.5, 0], [67.5, 0], [360-112.5, 0], [112.5, 0], [360-157.5, 0], [157.5, 0], [360-60, 40], [60, 40], [360-120, 40], [120, 40], [0, 40], [360-180, 40], [360-90, 80], [90, 80]] // Pour HOALIB
					// 337.5, 0, 22.5, 0, 292.5, 0, 67.5, 0, 247.5, 0, 112.5, 0, 202.5, 0, 157.5, 0, 300, 40, 60, 40, 240, 40, 120, 40, 0, 40, 180, 40, 270, 80, 90, 80
					// [ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi, -0.3333pi, 0.3333pi, (-0.3333*2)*pi, (0.3333*2)*pi, 0pi, 1pi, -0.5pi, 0.5pi].raddeg.wrap(-180,180)
				}

				// Mise en place seulement du dôme de 16 - Clock - sorties à réorganiser dans la carte son selon l'attribution du SpatioScope (+ Subs selon config)
				{~numChannelsConfig == "16-Dome-8-6-2-Clock" or: {~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"}}
				// Config Output Dome 16 sorties - Clockwise à partir de la gauche
				{
					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = 8 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, 0pi, 0.3333pi, (0.3333*2)*pi, 1pi, (-0.3333*2)*pi, -0.3333pi, -0.5pi, 0.5pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.5pi, 0.5pi ]"; // 0 / 45 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-22.5, 0], [22.5, 0], [67.5, 0], [112.5, 0], [157.5, 0], [-157.5, 0], [-112.5, 0], [-67.5, 0], [0, 45], [60, 45], [120, 45], [-180, 45], [-120, 45], [-60, 45], [-90, 85], [90, 85] ]); /*~configVBAPBuffers = ~configVBAP.loadToBuffer(server);*/
					// ~configVBAPBuffers = Buffer.loadCollection(currentEnvironment[server], ~configVBAP.getSetsAndMatrices);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, 0pi, 0.3333pi, (0.3333*2)*pi, 1pi, (-0.3333*2)*pi, -0.3333pi, -0.5pi, 0.5pi].raddeg.wrap(-180,180)
				}

				// Mise en place seulement du dôme de 24 UsineC - Clock - sorties à réorganiser dans la carte son selon l'attribution du SpatioScope (+ Subs selon config)
				{~numChannelsConfig == "16-UsineC-2Octo"}
				// Config Output Dome 16 sorties - Clockwise à partir de la gauche
				{
					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = 8 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0.45pi, 0.45pi, 0.45pi, 0.45pi, 0.45pi, 0.45pi, 0.45pi, 0.45pi ]"; // 0 / 45 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-22.5, 0], [22.5, 0], [67.5, 0], [112.5, 0], [157.5, 0], [-157.5, 0], [-112.5, 0], [-67.5, 0], [-22.5, 45], [22.5, 45], [67.5, 45], [112.5, 45], [157.5, 45], [-157.5, 45], [-112.5, 45], [-67.5, 45] ]); /*~configVBAPBuffers = ~configVBAP.loadToBuffer(server);*/
					// ~configVBAPBuffers = Buffer.loadCollection(currentEnvironment[server], ~configVBAP.getSetsAndMatrices);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, 0pi, 0.3333pi, (0.3333*2)*pi, 1pi, (-0.3333*2)*pi, -0.3333pi, -0.5pi, 0.5pi].raddeg.wrap(-180,180)
				}

				// Mise en place seulement du dôme de 24 UsineC - Clock - sorties à réorganiser dans la carte son selon l'attribution du SpatioScope (+ Subs selon config)
				{~numChannelsConfig == "24-UsineC-3Octo"}
				// Config Output Dome 16 sorties - Clockwise à partir de la gauche
				{
					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7] ]"; ~numChannelsVP = 8 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0.3pi, 0.3pi, 0.3pi, 0.3pi, 0.3pi, 0.3pi, 0.3pi, 0.3pi, 0.6pi, 0.6pi, 0.6pi, 0.6pi, 0.6pi, 0.6pi, 0.6pi, 0.6pi ]"; // 0 / 45 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-22.5, 0], [22.5, 0], [67.5, 0], [112.5, 0], [157.5, 0], [-157.5, 0], [-112.5, 0], [-67.5, 0], [-22.5, 33], [22.5, 33], [67.5, 33], [112.5, 33], [157.5, 33], [-157.5, 33], [-112.5, 33], [-67.5, 33], [-22.5, 66], [22.5, 66], [67.5, 66], [112.5, 66], [157.5, 66], [-157.5, 66], [-112.5, 66], [-67.5, 66] ]); /*~configVBAPBuffers = ~configVBAP.loadToBuffer(server);*/
					// ~configVBAPBuffers = Buffer.loadCollection(currentEnvironment[server], ~configVBAP.getSetsAndMatrices);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, 0pi, 0.3333pi, (0.3333*2)*pi, 1pi, (-0.3333*2)*pi, -0.3333pi, -0.5pi, 0.5pi].raddeg.wrap(-180,180)
				}

				// Mise en place seulement du dôme de 32 - Clock - sorties à réorganiser dans la carte son selon l'attribution du SpatioScope
				{~numChannelsConfig == "32-Dome-12-10-8-2"} // à améliorer XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				// Config Output Dome 32 sorties - Clockwise à partir de la gauche
				{
					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11] ]"; ~numChannelsVP = 12 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";

					~configAmbi = "[ -0.0833pi, 0.0833pi, 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi, -0.1pi, 0.1pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.5pi, 0.5pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.5pi, 0.5pi ]"; // 0 / 30 / 60 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-15, 0], [15, 0], [45, 0], [75, 0], [105, 0], [135, 0], [165, 0], [-165, 0], [-135, 0], [-105, 0], [-75, 0], [-45, 0], [-18, 30], [18, 30], [54, 30], [90, 30], [126, 30], [162, 30], [-162, 30], [-126, 30], [-90, 30], [-54, 30], [-22.5, 60], [22.5, 60], [67.5, 60], [112.5, 60], [157.5, 60], [-157.5, 60], [-112.5, 60], [-67.5, 60], [-90, 85], [90, 85] ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					/*
					[ -0.0833pi, 0.0833pi, 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi, -0.1pi, 0.1pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.5pi, 0.5pi].raddeg.wrap(-180,180) // tous
					[ -0.0833pi, 0.0833pi, 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi].raddeg.wrap(-180,180) // pour les 12
					[ -0.1pi, 0.1pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi ].raddeg.wrap(-180,180) // pour les 10
					[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi].raddeg.wrap(-180,180) // pour les 8
					*/
				}
				// Mise en place seulement du dôme de 32 Motu - Clock - sorties à réorganiser dans la carte son selon l'attribution du SpatioScope
				{~numChannelsConfig == "32-Dome-12-10-8-2-Motu"} // à améliorer XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				// Config Output Dome 32 sorties - Clockwise à partir de la gauche
				{
					/*~configOuts2 = "[ src2[10], src2[11], src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[20], src2[21], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[22], src2[23] ]";
					~configOuts = "[ src1[10], src1[11], src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[20], src1[21], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[22], src1[23] ]";
					~configOutsVPM = "[ src1[10], src1[11], src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9] ]";
					~configOutsVPS = "[ src[10], src[11], src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9] ]"; ~numChannelsVP = 12 /*~numChannels*/;*/

					~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";

					// Pourquoi nécessité de décaler de 2 pour chaque couronne ?????????
					~configOutsCircS = "[ src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[0], src2[1], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[12], src2[13], src2[30], src2[31], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29] ]";
					/*"[ src2[10], src2[11], src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[20], src2[21], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[22], src2[23] ]";*/
					~configOutsCircM = "[ src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[0], src1[1], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[12], src1[13], src1[30], src1[31], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29] ]";

					// Pourquoi nécessité de décaler de 2 pour chaque couronne ?????????
					~configOutsVPM = "[ src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[0], src1[1] ]";
					~configOutsVPS = "[ src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[0], src[1] ]"; ~numChannelsVP = 12 /*~numChannels*/;
					/*~configOutsVPM = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11] ]";
					~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11] ]"; ~numChannelsVP = 12 /*~numChannels*/;*/

					~configAmbi = "[ 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi, -0.0833pi, 0.0833pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi, -0.1pi, 0.1pi, -0.5pi, 0.5pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.18pi, 0.5pi, 0.5pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi ]"; // 0 / 32.4 / 60 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [45, 0], [75, 0], [105, 0], [135, 0], [165, 0], [-165, 0], [-135, 0], [-105, 0], [-75, 0], [-45, 0], [-15, 0], [15, 0], [54, 30], [90, 30], [126, 30], [162, 30], [-162, 30], [-126, 30], [-90, 30], [-54, 30], [-18, 30], [18, 30], [-90, 85], [90, 85], [-22.5, 60], [22.5, 60], [67.5, 60], [112.5, 60], [157.5, 60], [-157.5, 60], [-112.5, 60], [-67.5, 60] ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;

					/*~configAmbi = "[ -0.0833pi, 0.0833pi, 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi, -0.1pi, 0.1pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi, -0.5pi, 0.5pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.1666pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.333pi, 0.5pi, 0.5pi ]"; // 0 / 30 / 60 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-15, 0], [15, 0], [45, 0], [75, 0], [105, 0], [135, 0], [165, 0], [-165, 0], [-135, 0], [-105, 0], [-75, 0], [-45, 0], [-18, 30], [18, 30], [54, 30], [90, 30], [126, 30], [162, 30], [-162, 30], [-126, 30], [-90, 30], [-54, 30], [-22.5, 60], [22.5, 60], [67.5, 60], [112.5, 60], [157.5, 60], [-157.5, 60], [-112.5, 60], [-67.5, 60], [-90, 80], [90, 80] ]); ~configVBAPBuffers = ~configVBAP.loadToBuffer(server); "VBAP Buffer loaded".postln;*/

					/*
					[ 0.25pi, 0.4166pi, 0.5833pi, 0.75pi, 0.9166pi, 1.0833pi, 1.25pi, 1.4166pi, 1.5833pi, 1.75pi, -0.0833pi, 0.0833pi, 0.3pi, 0.5pi, 0.7pi, 0.9pi, 1.1pi, 1.3pi, 1.5pi, 1.7pi, -0.1pi, 0.1pi, -0.5pi, 0.5pi, -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180) // tous

					[ 45, 74.988, 104.994, 135, 164.988, -165.006, -135, -105.012, -75.006, -45, -14.994, 14.994, 54, 90, 126, 162, -162, -126, -90, -54, -18, 18, -90, 90, -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]
					*/
					// 0.25pi.raddeg.wrap(-180,180)
				}

				{~numChannelsConfig == "22-8+Dome-8-4-2-Pair"}
				// Config Output Dome 14 sorties + 8 - Paire - Placement de la 2ème couronne à 45° en élévation ???
				{
					~configOuts2 = "[ src2[0], src2[1], src2[7], src2[2], src2[6], src2[3], src2[5], src2[4], src2[8], src2[9], src2[11], src2[10], src2[12], src2[13] ]";
					~configOuts = "[ src1[0], src1[1], src1[7], src1[2], src1[6], src1[3], src1[5], src1[4], src1[8], src1[9], src1[11], src1[10], src1[12], src1[13] ]";
					~configOutsVPM = "[ src1[0], src1[1], src1[7], src1[2], src1[6], src1[3], src1[5], src1[4] ]";
					~configOutsVPS = "[ src[0], src[1], src[7], src[2], src[6], src[3], src[5], src[4] ]"; ~numChannelsVP = 8 /*~numChannels*/;

					~configOutsCircS = "[ src2[0], src2[1], src2[7], src2[2], src2[6], src2[3], src2[5], src2[4], src2[8], src2[9], src2[11], src2[10], src2[12], src2[13] ]";
					~configOutsCircM = "[ src1[0], src1[1], src1[7], src1[2], src1[6], src1[3], src1[5], src1[4], src1[8], src1[9], src1[11], src1[10], src1[12], src1[13] ]";

					~configAmbi = "[ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi, -0.3333pi, 0.3333pi, (-0.3333*2)*pi, (0.3333*2)*pi, -0.5pi, 0.5pi], [ 0, 0, 0, 0, 0, 0, 0, 0, 0.25pi, 0.25pi, 0.25pi, 0.25pi, 0.5pi, 0.5pi ]"; // 0 / 45 / 90° pour l'élévation
					~configVBAP = VBAPSpeakerArray.new(3, [ [-22.5, 0], [22.5, 0], [-67.5, 0], [67.5, 0], [-112.5, 0], [112.5, 0], [-157.5, 0], [157.5, 0], [-60, 40], [60, 40], [-120, 40], [120, 40], [-90, 80], [90, 80] ]);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, -0.375pi, 0.375pi, 1.375pi, 0.625pi, 1.125pi, 0.875pi, -0.3333pi, 0.3333pi, (-0.3333*2)*pi, (0.3333*2)*pi, /*0pi, 1pi,*/ -0.5pi, 0.5pi].raddeg.wrap(-180,180)
				}

				/*
				(1/64)*pi.raddeg
				0.3pi.raddeg
				30 * 12
				0.0833pi.raddeg
				0.16666666666667 / 2
				0.083333 + (0.16666666666667 * 10)
				(0.3333*3)*pi.raddeg
				0.25pi.raddeg * 8
				0.1666pi.raddeg
				*/

				{~numChannelsConfig == "64-CentreClock"}
				// Config Output 64 sorties (sans Centre) - Clockwise à partir de la gauche
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63] ]";
					~configOutsCircM =  "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63] ]";

					~configAmbi = Array.series(64,0,2pi/64).cs /*"[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ]"*/;

					// préférable en termes de performance, mais pas en termes de lignes rajoutées :
					// de rajouter dans ~allSpas une variable sil = Silent.ar(1), afin d'éviter de répéter ce UGen 32 x ou plus... mais nécessaire de rajouter 8 conditions pour seulement ~numChannelsConfig == "64-CentreClock" pour éviter d'introduire encore un UGen, même si ce n'est que Silent.ar ???
					// ~configOutsVPM = /*~configOuts*/ "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";
					~configOutsVPM = /*~configOuts*/ "[ src1[0], Silent.ar(1), src1[1], Silent.ar(1), src1[2], Silent.ar(1), src1[3], Silent.ar(1), src1[4], Silent.ar(1), src1[5], Silent.ar(1), src1[6], Silent.ar(1), src1[7], Silent.ar(1), src1[8], Silent.ar(1), src1[9], Silent.ar(1), src1[10], Silent.ar(1), src1[11], Silent.ar(1), src1[12], Silent.ar(1), src1[13], Silent.ar(1), src1[14], Silent.ar(1), src1[15], Silent.ar(1), src1[16], Silent.ar(1), src1[17], Silent.ar(1), src1[18], Silent.ar(1), src1[19], Silent.ar(1), src1[20], Silent.ar(1), src1[21], Silent.ar(1), src1[22], Silent.ar(1), src1[23], Silent.ar(1), src1[24], Silent.ar(1), src1[25], Silent.ar(1), src1[26], Silent.ar(1), src1[27], Silent.ar(1), src1[28], Silent.ar(1), src1[29], Silent.ar(1), src1[30], Silent.ar(1), src1[31], Silent.ar(1) ]";
					// ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31] ]";
					~configOutsVPS = "[ src[0], Silent.ar(1), src[1], Silent.ar(1), src[2], Silent.ar(1), src[3], Silent.ar(1), src[4], Silent.ar(1), src[5], Silent.ar(1), src[6], Silent.ar(1), src[7], Silent.ar(1), src[8], Silent.ar(1), src[9], Silent.ar(1), src[10], Silent.ar(1), src[11], Silent.ar(1), src[12], Silent.ar(1), src[13], Silent.ar(1), src[14], Silent.ar(1), src[15], Silent.ar(1), src[16], Silent.ar(1), src[17], Silent.ar(1), src[18], Silent.ar(1), src[19], Silent.ar(1), src[20], Silent.ar(1), src[21], Silent.ar(1), src[22], Silent.ar(1), src[23], Silent.ar(1), src[24], Silent.ar(1), src[25], Silent.ar(1), src[26], Silent.ar(1), src[27], Silent.ar(1), src[28], Silent.ar(1), src[29], Silent.ar(1), src[30], Silent.ar(1), src[31], Silent.ar(1) ]";
					~numChannelsVP = 32 /*~numChannels*/;

					~configVBAP = VBAPSpeakerArray.new(2, Array.series(64,0,2pi/64).raddeg /*[ -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]*/);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180)
				}

				/*
				Array.series(64,0,2pi/64).cs
				Array.series(64,0,2pi/64).cs.class
				Array.series(64,0,2pi/64).raddeg.cs
				(6.1850105367549 + (2pi/64)).raddeg
				*/

				{~numChannelsConfig == "96-CentreClock"}
				// Config Output 128 sorties (sans Centre) - Clockwise à partir de la gauche
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63], src2[64], src2[65], src2[66], src2[67], src2[68], src2[69], src2[70], src2[71], src2[72], src2[73], src2[74], src2[75], src2[76], src2[77], src2[78], src2[79], src2[80], src2[81], src2[82], src2[83], src2[84], src2[85], src2[86], src2[87], src2[88], src2[89], src2[90], src2[91], src2[92], src2[93], src2[94], src2[95] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63], src1[64], src1[65], src1[66], src1[67], src1[68], src1[69], src1[70], src1[71], src1[72], src1[73], src1[74], src1[75], src1[76], src1[77], src1[78], src1[79], src1[80], src1[81], src1[82], src1[83], src1[84], src1[85], src1[86], src1[87], src1[88], src1[89], src1[90], src1[91], src1[92], src1[93], src1[94], src1[95] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63], src2[64], src2[65], src2[66], src2[67], src2[68], src2[69], src2[70], src2[71], src2[72], src2[73], src2[74], src2[75], src2[76], src2[77], src2[78], src2[79], src2[80], src2[81], src2[82], src2[83], src2[84], src2[85], src2[86], src2[87], src2[88], src2[89], src2[90], src2[91], src2[92], src2[93], src2[94], src2[95] ]";
					~configOutsCircM =   "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63], src1[64], src1[65], src1[66], src1[67], src1[68], src1[69], src1[70], src1[71], src1[72], src1[73], src1[74], src1[75], src1[76], src1[77], src1[78], src1[79], src1[80], src1[81], src1[82], src1[83], src1[84], src1[85], src1[86], src1[87], src1[88], src1[89], src1[90], src1[91], src1[92], src1[93], src1[94], src1[95] ]";

					~configAmbi = Array.series(96,0,2pi/96).cs /*"[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ]"*/;

					// préférable en termes de performance, mais pas en termes de lignes rajoutées :
					// de rajouter dans ~allSpas une variable sil = Silent.ar(1), afin d'éviter de répéter ce UGen 32 x ou plus... mais nécessaire de rajouter 8 conditions pour seulement ~numChannelsConfig == "64-CentreClock" pour éviter d'introduire encore un UGen, même si ce n'est que Silent.ar ???
					// ~configOutsVPM = /*~configOuts*/ "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";
					~configOutsVPM = /*~configOuts*/ "[ src1[0], Silent.ar(1), Silent.ar(1), src1[1], Silent.ar(1), Silent.ar(1), src1[2], Silent.ar(1), Silent.ar(1), src1[3], Silent.ar(1), Silent.ar(1), src1[4], Silent.ar(1), Silent.ar(1), src1[5], Silent.ar(1), Silent.ar(1), src1[6], Silent.ar(1), Silent.ar(1), src1[7], Silent.ar(1), Silent.ar(1), src1[8], Silent.ar(1), Silent.ar(1), src1[9], Silent.ar(1), Silent.ar(1), src1[10], Silent.ar(1), Silent.ar(1), src1[11], Silent.ar(1), Silent.ar(1), src1[12], Silent.ar(1), Silent.ar(1), src1[13], Silent.ar(1), Silent.ar(1), src1[14], Silent.ar(1), Silent.ar(1), src1[15], Silent.ar(1), Silent.ar(1), src1[16], Silent.ar(1), Silent.ar(1), src1[17], Silent.ar(1), Silent.ar(1), src1[18], Silent.ar(1), Silent.ar(1), src1[19], Silent.ar(1), Silent.ar(1), src1[20], Silent.ar(1), Silent.ar(1), src1[21], Silent.ar(1), Silent.ar(1), src1[22], Silent.ar(1), Silent.ar(1), src1[23], Silent.ar(1), Silent.ar(1), src1[24], Silent.ar(1), Silent.ar(1), src1[25], Silent.ar(1), Silent.ar(1), src1[26], Silent.ar(1), Silent.ar(1), src1[27], Silent.ar(1), Silent.ar(1), src1[28], Silent.ar(1), Silent.ar(1), src1[29], Silent.ar(1),  Silent.ar(1), src1[30], Silent.ar(1), Silent.ar(1), src1[31], Silent.ar(1), Silent.ar(1) ]";
					// ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31] ]";
					~configOutsVPS = "[ src[0], Silent.ar(1), Silent.ar(1), src[1], Silent.ar(1), Silent.ar(1), src[2], Silent.ar(1), Silent.ar(1), src[3], Silent.ar(1), Silent.ar(1), src[4], Silent.ar(1), Silent.ar(1), src[5], Silent.ar(1), Silent.ar(1), src[6], Silent.ar(1), Silent.ar(1), src[7], Silent.ar(1), Silent.ar(1), src[8], Silent.ar(1), Silent.ar(1), src[9], Silent.ar(1), Silent.ar(1), src[10], Silent.ar(1), Silent.ar(1), src[11], Silent.ar(1), Silent.ar(1), src[12], Silent.ar(1), Silent.ar(1), src[13], Silent.ar(1), Silent.ar(1), src[14], Silent.ar(1), Silent.ar(1), src[15], Silent.ar(1), Silent.ar(1), src[16], Silent.ar(1), Silent.ar(1), src[17], Silent.ar(1), Silent.ar(1), src[18], Silent.ar(1), Silent.ar(1), src[19], Silent.ar(1), Silent.ar(1), src[20], Silent.ar(1), Silent.ar(1), src[21], Silent.ar(1), Silent.ar(1), src[22], Silent.ar(1), Silent.ar(1), src[23], Silent.ar(1), Silent.ar(1), src[24], Silent.ar(1), Silent.ar(1), src[25], Silent.ar(1), Silent.ar(1), src[26], Silent.ar(1), Silent.ar(1), src[27], Silent.ar(1), Silent.ar(1), src[28], Silent.ar(1), Silent.ar(1), src[29], Silent.ar(1), Silent.ar(1), src[30], Silent.ar(1), Silent.ar(1), src[31], Silent.ar(1), Silent.ar(1) ]";
					~numChannelsVP = 32 /*~numChannels*/;

					~configVBAP = VBAPSpeakerArray.new(2, Array.series(96,0,2pi/96).raddeg /*[ -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]*/);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180)
				}

				{~numChannelsConfig == "128-CentreClock"}
				// Config Output 128 sorties (sans Centre) - Clockwise à partir de la gauche
				{~configOuts2 = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63], src2[64], src2[65], src2[66], src2[67], src2[68], src2[69], src2[70], src2[71], src2[72], src2[73], src2[74], src2[75], src2[76], src2[77], src2[78], src2[79], src2[80], src2[81], src2[82], src2[83], src2[84], src2[85], src2[86], src2[87], src2[88], src2[89], src2[90], src2[91], src2[92], src2[93], src2[94], src2[95], src2[96], src2[97], src2[98], src2[99], src2[100], src2[101], src2[102], src2[103], src2[104], src2[105], src2[106], src2[107], src2[108], src2[109], src2[110], src2[111], src2[112], src2[113], src2[114], src2[115], src2[116], src2[117], src2[118], src2[119], src2[120], src2[121], src2[122], src2[123], src2[124], src2[125], src2[126], src2[127] ]";
					~configOuts = "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63], src1[64], src1[65], src1[66], src1[67], src1[68], src1[69], src1[70], src1[71], src1[72], src1[73], src1[74], src1[75], src1[76], src1[77], src1[78], src1[79], src1[80], src1[81], src1[82], src1[83], src1[84], src1[85], src1[86], src1[87], src1[88], src1[89], src1[90], src1[91], src1[92], src1[93], src1[94], src1[95], src1[96], src1[97], src1[98], src1[99], src1[100], src1[101], src1[102], src1[103], src1[104], src1[105], src1[106], src1[107], src1[108], src1[109], src1[110], src1[111], src1[112], src1[113], src1[114], src1[115], src1[116], src1[117], src1[118], src1[119], src1[120], src1[121], src1[122], src1[123], src1[124], src1[125], src1[126], src1[127] ]";

					~configOutsCircS = "[ src2[0], src2[1], src2[2], src2[3], src2[4], src2[5], src2[6], src2[7], src2[8], src2[9], src2[10], src2[11], src2[12], src2[13], src2[14], src2[15], src2[16], src2[17], src2[18], src2[19], src2[20], src2[21], src2[22], src2[23], src2[24], src2[25], src2[26], src2[27], src2[28], src2[29], src2[30], src2[31], src2[32], src2[33], src2[34], src2[35], src2[36], src2[37], src2[38], src2[39], src2[40], src2[41], src2[42], src2[43], src2[44], src2[45], src2[46], src2[47], src2[48], src2[49], src2[50], src2[51], src2[52], src2[53], src2[54], src2[55], src2[56], src2[57], src2[58], src2[59], src2[60], src2[61], src2[62], src2[63], src2[64], src2[65], src2[66], src2[67], src2[68], src2[69], src2[70], src2[71], src2[72], src2[73], src2[74], src2[75], src2[76], src2[77], src2[78], src2[79], src2[80], src2[81], src2[82], src2[83], src2[84], src2[85], src2[86], src2[87], src2[88], src2[89], src2[90], src2[91], src2[92], src2[93], src2[94], src2[95], src2[96], src2[97], src2[98], src2[99], src2[100], src2[101], src2[102], src2[103], src2[104], src2[105], src2[106], src2[107], src2[108], src2[109], src2[110], src2[111], src2[112], src2[113], src2[114], src2[115], src2[116], src2[117], src2[118], src2[119], src2[120], src2[121], src2[122], src2[123], src2[124], src2[125], src2[126], src2[127] ]";
					~configOutsCircM =   "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31], src1[32], src1[33], src1[34], src1[35], src1[36], src1[37], src1[38], src1[39], src1[40], src1[41], src1[42], src1[43], src1[44], src1[45], src1[46], src1[47], src1[48], src1[49], src1[50], src1[51], src1[52], src1[53], src1[54], src1[55], src1[56], src1[57], src1[58], src1[59], src1[60], src1[61], src1[62], src1[63], src1[64], src1[65], src1[66], src1[67], src1[68], src1[69], src1[70], src1[71], src1[72], src1[73], src1[74], src1[75], src1[76], src1[77], src1[78], src1[79], src1[80], src1[81], src1[82], src1[83], src1[84], src1[85], src1[86], src1[87], src1[88], src1[89], src1[90], src1[91], src1[92], src1[93], src1[94], src1[95], src1[96], src1[97], src1[98], src1[99], src1[100], src1[101], src1[102], src1[103], src1[104], src1[105], src1[106], src1[107], src1[108], src1[109], src1[110], src1[111], src1[112], src1[113], src1[114], src1[115], src1[116], src1[117], src1[118], src1[119], src1[120], src1[121], src1[122], src1[123], src1[124], src1[125], src1[126], src1[127] ]";

					~configAmbi = Array.series(128,0,2pi/128).cs /*"[ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ]"*/;

					// préférable en termes de performance, mais pas en termes de lignes rajoutées :
					// de rajouter dans ~allSpas une variable sil = Silent.ar(1), afin d'éviter de répéter ce UGen 32 x ou plus... mais nécessaire de rajouter 8 conditions pour seulement ~numChannelsConfig == "64-CentreClock" pour éviter d'introduire encore un UGen, même si ce n'est que Silent.ar ???
					// ~configOutsVPM = /*~configOuts*/ "[ src1[0], src1[1], src1[2], src1[3], src1[4], src1[5], src1[6], src1[7], src1[8], src1[9], src1[10], src1[11], src1[12], src1[13], src1[14], src1[15], src1[16], src1[17], src1[18], src1[19], src1[20], src1[21], src1[22], src1[23], src1[24], src1[25], src1[26], src1[27], src1[28], src1[29], src1[30], src1[31] ]";
					~configOutsVPM = /*~configOuts*/ "[ src1[0], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[1], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[2], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[3], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[4], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[5], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[6], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[7], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[8], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[9], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[10], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[11], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[12], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[13], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[14], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[15], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[16], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[17], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[18], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[19], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[20], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[21], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[22], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[23], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[24], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[25], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[26], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[27], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[28], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[29], Silent.ar(1),  Silent.ar(1), Silent.ar(1),src1[30], Silent.ar(1), Silent.ar(1), Silent.ar(1), src1[31], Silent.ar(1), Silent.ar(1), Silent.ar(1) ]";
					// ~configOutsVPS = "[ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31] ]";
					~configOutsVPS = "[ src[0], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[1], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[2], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[3], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[4], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[5], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[6], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[7], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[8], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[9], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[10], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[11], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[12], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[13], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[14], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[15], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[16], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[17], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[18], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[19], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[20], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[21], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[22], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[23], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[24], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[25], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[26], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[27], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[28], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[29], Silent.ar(1),  Silent.ar(1), Silent.ar(1), src[30], Silent.ar(1), Silent.ar(1), Silent.ar(1), src[31], Silent.ar(1), Silent.ar(1), Silent.ar(1) ]";
					~numChannelsVP = 32 /*~numChannels*/;

					~configVBAP = VBAPSpeakerArray.new(2, Array.series(128,0,2pi/128).raddeg /*[ -22.5, 22.5, 67.5, 112.5, 157.5, -157.5, -112.5, -67.5 ]*/);
					~configVBAPBuffers[serverNb] = ~configVBAP.loadToBuffer(currentEnvironment[server]);
					"VBAP Buffer loaded".postln;
					// [ -0.125pi, 0.125pi, 0.375pi, 0.625pi, 0.875pi, 1.125pi, 1.375pi, -0.375pi ].raddeg.wrap(-180,180)
				};

				currentEnvironment[server].sync;


				// Chargement des buffers du Kernel ambisonique : binaural et stéréo - mis à la fin de la spatialisation car le numéro de VBAP.bufnum change sinon XXX
				case
				// ~server1
				{~ambATKConfig == "binaural"}
				{
					// var sv; if (currentEnvironment[server] == ~server1, { sv = ~server1; ~binauralDecoder = 0 ! 2; }, { sv = ~server2; } );
					if (currentEnvironment[server] == ~server1, { ~binauralDecoder = 0 ! 2; } );
					~binauralDecoder[serverNb] = (~binauralDecoderName ++( "(server:"++ "~server" ++ (serverNb+1)/*1*/.asString) ++")" ).interpret; currentEnvironment[server].sync; 2.wait;
				}
				{~ambATKConfig == "stereo"}
				{
					var sv; if (currentEnvironment[server] == ~server1, { sv = ~server1; ~stereoDecoder = 0 ! 2; }, { sv = ~server2; } );
					// if (currentEnvironment[server] == ~server1, { ~stereoDecoder = 0 ! 2; } );
					~stereoDecoder[serverNb] = FoaDecoderKernel.newUHJ(server: sv); currentEnvironment[server].sync; 2.wait; /* Apparemment le .wait est necessaire car sinon les Buffers binauraux ne sont pas tous chargés */
				};









				(
					// Redéfinition du contenu de module de spatialisation dans ~allSpasGUI selon les trajectoires de presets dans _Init GUI 43
					~allSpasGUI = ["Stereo Fix", "Stereo Del", "Stereo 0->1", "Stereo 1->0", "Stereo 0->1->0", "Stereo 1->0->1", /*"Bad PanB2", "Bad Pan"*/ "Circ_1_GD", "Circ_1_DG", "CircM_GD", "CircM_DG", "CircMAc_GD", "CircMAc_DG", "CircMDc_GD", "CircMDc_DG", "Circ_Cen_GD", "Circ_Cen_DG", "Traj_CenLoud", "Traj_LoudCen", "T"];

					~allSpas = [ // 16 Spatialisation Synths

						// ["_Stereo", "_Traj_01", "_Traj_10", "_Traj_010", "_Traj_101", /*"_Bad_PanB2", "_Bad_Pan"*/ "_Circ1", "_Circ2"],
						// ~allSpasGUI.collect {|i| "_" ++ i.replace(" ","_").replace("->","")}, // juste pour nommer les spatialisations du Synth

						// Stereo Fixe Intensité / Stereo Délai Fixe Intensité / Stereo Aller Intensité (plus présent) / Stereo AllerRetour Intensité
						// Stereo Fixe Virtuel / Stereo Aller Virtuel (plus présent) / Stereo AllerRetour Virtuel
						// Stereo Fixe Spectral / Stereo Aller Spectral (plus présent) / Stereo AllerRetour Spectral
						// Circulaire unique / Circulaire multiple / Circulaire selon données spectrales (centroïde spectral)
						// Circulaire VBAP unique / Circulaire VBAP multiple
						// Virtuel selon données sonores / Virtuel Trajectoires
						// VBAP selon données sonores / VBAP Trajectoires (plus présent)
						// VBAP Distance selon données sonores / VBAP Distance Trajectoires
						// Ambisonique selon données sonores / Ambisonique Trajectoires

						["_StereoFInt", "_StereoFIntDel", "_StereoARInt", /* */ "_StereoFVM", "_StereoARVM", /* */ "_StereoFSpec", "_StereoARSpec", /* */ /*"Bad PanB2", "Bad Pan"*/ "_Circ1", "_CircM", "_Circ_SD", "_C_VBAP1", "_C_VBAPM", "_VM_SD_CenLoud", "_VB_SD_CenLoud", "_VBDist_SD_CenLoud", "_ASD_CenLoud", "_VM", "_VBDist", "_A"],





						[ // Functions pour synthés monos --------------------------------------------------------

							// 0 - Répartition stéréo normale (à changer le Balance2 to Splay pour panning de l'ensemble des canaux ????????? XXX)
							// 1 - Trajectoire stéréo entre le canal 0 et 1
							// 2 - Trajectoire stéréo entre le canal 1 et 0
							// 3 - Trajectoire stéréo entre le canal 0 et 1 et 0
							// 4 - Trajectoire stéréo entre le canal 1 et 0 et 1


							// Panning d'intensité
							"src1 = Pan2.ar(src1, pan) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							// Panning d'intensité avec délai
							"src1 = Pan2.ar(src1, pan) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, DelayN.ar(src1[1], 0.2, delayTime));",
							// Panning d'intensité Lines
							/*"src1 = Pan2.ar(src1, Line.kr(panL, panR, spadur));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							// "src1 = Pan2.ar(src1, EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')));
							"src1 = Pan2.ar(src1, Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ] )) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Panning VirtualMics Distance
							"pointVM = [/*pointX*/ pan * pointScale, 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*, \none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							/*"pointVM = [Line.kr(panL, panR, spadur) * pointScale, 0].asPoint;
							pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
							polarVM = pointVM.asPolar;
							angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*,\none*/); // none ???
							ampVM = (0.15 / polarVM.rho).min( 1 );
							pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
							src1 = pannedVM * pankrVM;
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							// "pointVM = [EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * pointScale, 0].asPoint;
							"pointVM = [ Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * pointScale, 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*, \none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Panning spectral (Spectral 'pan' in PV_Copy Help)
							// -> voire Manière simple de créer une courbe exp en partant de 0
							// Augmentation de la valeur de départ de 0.001 à 0.005 pour avoir un Panning spectral + "linéaire"
							"chainA = FFT(LocalBuf(2048), src1);
chainB = PV_Copy(chainA, LocalBuf(2048));
panSpectral = pan.lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src1 = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							// Voire si préférable d'utiliser le pattern pour envoyer les données pour éviter l'utilisation de linexp et Line pour XLine à la place ???
							/*"chainA = FFT(LocalBuf(2048), src1);
							chainB = PV_Copy(chainA, LocalBuf(2048));
							panSpectral = Line.kr(panL, panR, spadur).lincurve(-1, 1, 0, 1, panSpectralCurve);
							chainA = PV_BrickWall(chainA, panSpectral);
							chainB = PV_BrickWall(chainB, -1 + panSpectral);
							src1 = IFFT([chainA, chainB]);
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							"chainA = FFT(LocalBuf(2048), src1);
chainB = PV_Copy(chainA, LocalBuf(2048));
// panSpectral = EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')).lincurve(-1, 1, 0, 1, panSpectralCurve);
panSpectral = Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src1 = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Bad
							/*"src1 = BiPanB2.ar(src1[0], src1[1], Line.kr(-1, 1, spadur));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",
							"src1 = Pan2.ar(src1[0], src1[1], Line.kr(-1, 1, spadur));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);"*/


							// Circulaire Unique PanAz
							// si prepoutLU = 0, le son commence à gauche / si 1 a fait le tour du cercle et commence au centre
							// panR permet d'aller dans le sens inverse
							/*if (x == 0, {*/
							"src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR ), width: circWidth, orientation: 0.5) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");"
							/*},{
							})*/
							,


							// Circulaire Multiple PanAz
							// Range & mapping à tester dans le pattern (max à 20hz et test à 66hz et mapping linéaire ou exponentiel...)
							/*"src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(pan.linexp(-1, 1, 20, 0.2), prepoutLU * 2, mul: panR ) );
							OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",*/ // auparavant

							// si spaSpeed = 0, vitesse de rotation régulière qui varie de 0.2 à 20 hz selon pan avec comme point de départ prepoutLU et panR permet le changement de sens
							// si spaSpeed = 1, vitesse de rotation accélère avec comme vitesse de départ (prepoutRU de 0 à 1) et vitesse maximale (pan à 20) avec comme point de départ prepoutLU et panR permet le changement de sens
							// si spaSpeed = 2, même chose que ci-dessus mais en déccélèrant

							// Select.kr(spaSpeed, [ pan.linexp(-1, 1, 20, 0.2), Line.kr(start:prepoutRU, end:pan.range(20, prepoutRU), dur:spadur), Line.kr(start:pan.range(20, prepoutRU), end:prepoutRU, dur:spadur) ] ) // trop lourd en CPU de faire la sélection dans le synth afin d'éviter le nb de synthés dans le server ???
							"src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ] ), prepoutLU * 2, mul: panR ), width: circWidth ) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");",


							// Circulaire selon données du centre spectral
							// 4000.lincurve(20, 6000, 0.1, 20, 2) // voire mapping préférable - lorsque données sonores fréquentielles ou d'amplitude ???????????????????????????
							// 4000.curvelin(20, 6000, 0.1, 20, 2)
							// 4000.linlin(20, 6000, 0.1, 20)
							"src1 = src1 * env;
a = FFT(LocalBuf(2048), src1);  // a complex signal
// b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(c.curvelin(freqMin, freqMax, 0.1, panCircMReg, freqCurve), prepoutLU * 2, mul: panR ), width: circWidth );
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");",


							// Circulaire Unique VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// (1 tour max - OUTL & OUTR déterminent l'angle de départ et d'arrivée du son)
							// {MouseX.kr(-1, 1).range(-180, 180).poll }.play // utilisation de linlin pour faire un range de -1 à 1 - range prend des données que de 0 à 1
							// Utilisation d'un range(-90, 90) -> pour pouvoir avec un delayU de 0 toucher uniquement la couronne extérieure - pourquoi range(0, 90) n'est pas suffisant ????????? -> apparemment OK
							/*
							{100000.do{0.linlin(0, 1, -180, 180)}}.bench
							{100000.do{0.range(-180, 180, 'unipolar')}}.bench
							{100000.do{0.linlin(0, 1, 0, 360).fold(-180, 180)}}.bench
							{100000.do{0.range(0, 360, 'unipolar').fold(-180, 180)}}.bench // afin qu'à 0, on commence en face et non en arriè
							0.range(0, 360).wrap(-180, 180)
							0.range(0, 360).fold(-180, 180) // pas possible car obligé de faire un line de 0 -> 180 -> -180 -> 0, donc obligé d'utiliser Ramp et non CircleRamp car prend le chemin le + court
							*/
							" // circPosX = Line.kr(start: Ramp.kr(prepoutLU.linlin(0, 1, 0, 360), 10), end: Ramp.kr(prepoutRU.linlin(0, 1, 0, 360), 10), dur: spadur).wrap(-180, 180);
circPosX = Line.kr(start: prepoutLU, end: prepoutRU, dur: spadur).linlin(0, 1, 0, 360).wrap(-180, 180);
// circPosY = /*Ramp.kr(*/ delayUElev /*, 10)*/ ;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
/*
prepoutLU.poll;
prepoutLU.range(0, 360, 'unipolar').poll; // range est bipolaire sur les Ugen uniquement et peut être unipolaire ou bipolaire dans le langage XXXXXXXXX ?????????
prepoutLU.linlin(0, 1, 0, 360).poll;
*/
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++ ", circPosX * panR, circPosY, spread) * env;
// src1 = VBAP.ar(~numChannels, src1, ~configVBAPBuffers[serverNb].bufnum, LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR).range(0, 360).wrap(-180, 180)), circPosY, spread) * env; // 1 tour
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Circulaire Multiple VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							"circPosX = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ]), prepoutLU * 2, mul: panR).range(-180, 180) /*.wrap(-180, 180)*/;
// circPosY = /*Ramp.kr(*/ delayUElev /*, 10)*/ ;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", circPosX.wrap(-180, 180), circPosY, spread) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Panning VirtualMics roundPanOutput Distance avec les données fréquentielles et d'amplitude
							// Placement de l'enveloppe à 2 endroits au début au niveau de l'analyse et à la fin sur le signal
							"src1 = src1 * env;
/*#d, e = Pitch.kr(src1);
#f, g = Tartini.kr(src1);
#h, j = Qitch.kr(src1, ~qitchBuffer);*/

a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal

/*k = SpecFlatness.kr(a); // how complicated the signal is (0 for sinusoid / white noise close to 1)
// SpecPcile
l = FFTCrest.kr(a /*,1800,2200*/); // calculate the spectral crest of a signal, which indicates how flat (white noise -> low value) or peaky a signal is
m = SensoryDissonance.kr(a); // how dissonant a signal is (1 totally dissonant / 0 consonant)
i = Impulse.kr(10);
SendReply.kr(i, '/loudness', b, replyID: 1); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/pitch', [d, e], replyID: 2); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/tartini', [f, g], replyID: 3); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/qitch', [h, j], replyID: 4); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/specCentroid', c, replyID: 5); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/specFlatnessAndDissonance', [k, m], replyID: 6); // ligne à décommenter pour récupérer les valeurs
SendReply.kr(i, '/fftCrest', l, replyID: 7); // ligne à décommenter pour récupérer les valeurs*/

micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [(c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR)].asPoint;
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
pannedVM = VirtualMics.ar( micsVM, src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar - pi; // -pi nécessaire pour commencer la trajectoire au bon angle / Pourquoi ?
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outSpa, "++ ~configOutsVPM ++ ");",


							// VBAP selon données fréquentielles (angle) et d'amplitude (élévation)
							// - à optimiser ??????????????????
							// mettre l'enveloppe sur la src au début pour économiser du CPU sans générer de clic ??????????????????
							// Pourquoi génération de clics lorsque b.range(-90, 90) ??? Pourquoi obligé de mettre entre 0 et 90, alors que pour les circulaires -> pas de clic ??????????????????
							/*{SinOsc.kr(3, 0).range(0, 14.97).poll}.play
							{(LFSaw.kr(0.5, 0).range(-180, 180)).poll}.play*/
							"src1 = src1 * env;
/*#d, e = Pitch.kr(src1);
#f, g = Tartini.kr(src1);
#h, j = Qitch.kr(src1, ~qitchBuffer);*/

a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal

src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", (c.curvelin(freqMin, freqMax, 0, 360, freqCurve) * panR).wrap(-180, 180), (b.linlin(dbMin, dbMax, -1, 1) * panR).range(0, 90), spread) * env;

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// VBAP Distance selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de 0 à 90)
							"src1 = src1 * env;
/*#d, e = Pitch.kr(src1);
#f, g = Tartini.kr(src1);
#h, j = Qitch.kr(src1, ~qitchBuffer);*/

a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
b = b.linlin(dbMin, dbMax, -5, 5) * panR;
c = c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * panR;

point = [c * pointScale, b * pointScale].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src1, point );
// src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElev, spread) * env;
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]), spread) * env;

// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones)

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Ambisonique selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							"src1 = src1 * env;
/*#d, e = Pitch.kr(src1);
#f, g = Tartini.kr(src1);
#h, j = Qitch.kr(src1, ~qitchBuffer);*/

a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal

// #w, x, y, z = BFEncode2.ar(src1, (c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR), delayUElev, 1.0);
#w, x, y, z = BFEncode2.ar(src1, (c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR), Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]), 1.0);
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0);
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",
							/*
							( // Pour récupérer les valeurs sonores Loudness - Comment obtenir des données arrondies ->.round(0.01) ne marche pas ?????????
							~getSynthDataSound = OSCFunc({ arg msg;
							msg.postln; // print the message to the post window
							}, '/qitch', Server.default.addr); // respond only to message /freq coming from the default Server's address.
							);
							~getSynthDataSound.free;
							400.explin(20, 6000 , -5, 5)
							*/


							// Panning VirtualMics roundPanOutput Distance avec trajectoires
							// https://github.com/GameOfLife/Unit-Lib/blob/master/UnitDefs/roundPanOutput.scd
							/*
							dbRollOff: number of dB's amplitude rolloff per distance doubling
							speakerRadius: the distance of the virtual microphones from the center of the room, in meters. When 0, no inter-speaker delays are applied (only a distance-dependant doppler delay). Default value is 0.19, which is okay for normal speaker setups. Optimum value may differ per setup.
							orientation: the speaker index of the front. 0.5 (default) means that the front position is in between the first and second speaker (normal for stereo and quad setups). This value can also be modulated to rotate the whole spatial image.
							numChannels: number of speakers (*)

							(*) only the following numbers of channels are allowed:
							2,3,4,5,6,7,8,10,12,16,24,32
							*/
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [a * pointScale, b * pointScale].asPoint;
pannedVM = VirtualMics.ar( micsVM, src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outSpa, "++ ~configOutsVPM ++ ");",


							// VBAP Distance avec trajectoires - (Elévation déterminée par delayU -> range de 0 à 90)
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;

point = [a * pointScale, b * pointScale].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src1, point );
// src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElev, spread) * env;
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]), spread) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Ambisonique avec trajectoires - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							// Ambisonique du 2ème ordre -> filtrage à améliorer et ≠ avec le 1er ordre ???
							// #w, x, y, z, r, s, t, u, v = FMHEncode2.ar(WhiteNoise.ar, a * pointScale, b * pointScale, 0);
							// FMHDecode1.ar(w, x, y, z, r, s, t, u, v, [-0.25pi, 0.25pi, 0pi, 0.75pi, 1.25pi], 0);

							// "#a, b = WFSPathPlayer.kr(trajBuf, ratio: (durenv / trajBufDur).reciprocal, loop: 0, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/; // ratio déjà intégré dans le pattern - à changer le nom par ratio // test avec .ar ?????????
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;

// Poll.kr(Impulse.kr(10), [a, b], [\a, \b]); // Pas possible de faire un polling clair -> a BinaryOpUGen: -0.516581
// SendReply.kr(Impulse.kr(10), '/xy', [(a * pointScale), (b * pointScale)].round(0.01), replyID: 10); // ligne à décommenter pour récupérer les valeurs

// #w, x, y, z = BFEncode2.ar(src1, a * pointScale, b * pointScale, delayUElev, 1.0);
#w, x, y, z = BFEncode2.ar(src1, a * pointScale, b * pointScale, Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]), 1.0);
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");"
							/*
							( // Pour récupérer les valeurs X & Y
							~getSynthDataXY = OSCFunc({ arg msg;
							msg.postln; // print the message to the post window
							}, '/xy', Server.default.addr); // respond only to message /freq coming from the default Server's address.
							);
							~getSynthDataXY.free;
							*/

						],





						[ // Functions pour synthés monos avec variateur de vitesse sur panning --------------------------------------------------------

							// Check http://supercollider.sourceforge.net/wiki/index.php/If_statements_in_a_SynthDef
							// Select.kr(aKrSignal > anotherKrSignal, [false_signal, true_signal]);
							// SinOsc donne une distorsion LFO - LFPar aussi mais différent
							// LFDNoise3 pas approprié pour le panning et plus intéressant en vitesse de lecture

							/*"src1 = Balance2.ar(src1[0], src1[1], pan * LFDNoise3.kr(panrate, pamp, 1).range(-1, 1));",
							"src1 = Pan2.ar(src1[0], src1[1], Line.kr(-1, 1, durenv) * LFDNoise3.kr(panrate, pamp, 1).range(-1, 1));"*/
							/*"src1 = Balance2.ar(src1[0], src1[1], pan * LFPar.ar(panrate, 0, pamp, 1).range(-1, 1));",
							"src1 = Pan2.ar(src1[0], src1[1], Line.kr(-1, 1, durenv) * LFPar.ar(panrate, 0, pamp, 1).range(-1, 1));"*/

							// "src1 = Pan2.ar(src1, pan * (Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate).bipolar(pamp) ])));


							// Panning d'intensité
							"src1 = Pan2.ar(src1, pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							// Panning d'intensité avec délai
							"src1 = Pan2.ar(src1, pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, DelayN.ar(src1[1], 0.2, delayTime));",
							// Panning d'intensité Lines
							/*"src1 = Pan2.ar(src1, Line.kr(panL, panR, spadur) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							// "src1 = Pan2.ar(src1, EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]));
							"src1 = Pan2.ar(src1, Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Panning VirtualMics (prenant en compte la distance)
							"pointVM = [/*pointX*/ pan * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*, \none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							/*"pointVM = [Line.kr(panL, panR, spadur) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
							pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
							polarVM = pointVM.asPolar;
							angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*,\none*/); // none ???
							ampVM = (0.15 / polarVM.rho).min( 1 );
							pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
							src1 = pannedVM * pankrVM;
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							// "pointVM = [EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
							"pointVM = [ Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*, \none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Panning spectral
							"chainA = FFT(LocalBuf(2048), src1);
chainB = PV_Copy(chainA, LocalBuf(2048));
panSpectral = (pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src1 = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",
							/*"chainA = FFT(LocalBuf(2048), src1);
							chainB = PV_Copy(chainA, LocalBuf(2048));
							panSpectral = (Line.kr(panL, panR, spadur) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
							chainA = PV_BrickWall(chainA, panSpectral);
							chainB = PV_BrickWall(chainB, -1 + panSpectral);
							src1 = IFFT([chainA, chainB]);
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",*/
							"chainA = FFT(LocalBuf(2048), src1);
chainB = PV_Copy(chainA, LocalBuf(2048));
// panSpectral = (EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
panSpectral = (Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src1 = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src1[0]);
OffsetOut.ar(outR, src1[1]);",


							// Bad
							/*"src1 = BiPanB2.ar(src1[0], src1[1], Line.kr(-1, 1, spadur) * Select.kr(pamp == 0, [SinOsc.ar(panrate).bipolar(pamp), DC.ar(1)]));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);",
							"src1 = Pan2.ar(src1[0], src1[1], Line.kr(-1, 1, spadur) * Select.kr(pamp == 0, [SinOsc.ar(panrate).bipolar(pamp), DC.ar(1)]));
							OffsetOut.ar(outL, src1[0]);
							OffsetOut.ar(outR, src1[1]);"*/


							// Circulaire Unique PanAz
							// Les variations de vitesse sur panning n'ont aucun intérêt quand panning circulaire ??????????????????
							"src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), width: circWidth) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");",


							// Circulaire Multiple PanAz
							// (le même qu'en mono simple car pas de variateur de vitesse)
							"src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ] ), prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), width: circWidth ) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");",


							// Circulaire selon données du centre spectral
							"src1 = src1 * env;
a = FFT(LocalBuf(2048), src1);  // a complex signal
// b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
src1 = PanAz.ar(~numChannels, src1, LFSaw.kr(c.curvelin(freqMin, freqMax, 0.1, panCircMReg, freqCurve), prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), width: circWidth );
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");",


							// Circulaire Unique VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// (1 tour max OUTL & OUTR déterminent l'angle de départ et d'arrivée du son)
							"d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
// circPosX = Line.kr(start: Ramp.kr(prepoutLU.linlin(0, 1, 0, 360), 10), end: Ramp.kr(prepoutRU.linlin(0, 1, 0, 360), 10), dur: spadur).wrap(-180, 180);
circPosX = Line.kr(start: prepoutLU, end: prepoutRU, dur: spadur).linlin(0, 1, 0, 360).wrap(-180, 180);
// circPosY = delayUElev;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", circPosX * panR * d, circPosY * d, spread) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Circulaire Multiple VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							"d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
circPosX = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ]), prepoutLU * 2, mul: panR).range(-180, 180) /*.wrap(-180, 180)*/;
// circPosY = delayUElev ;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);

src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", circPosX * d, circPosY * d, spread) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Panning VirtualMics roundPanOutput Distance avec les données fréquentielles et d'amplitude
							"src1 = src1 * env;
a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [(c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * pointScale * panR * d), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR * d )].asPoint;
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
pannedVM = VirtualMics.ar( micsVM, src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src1 = pannedVM * pankrVM * env;

OffsetOut.ar(outSpa, "++ ~configOutsVPM ++ ");",


							// VBAP selon données fréquentielles (angle) et d'amplitude (élévation)
							"src1 = src1 * env;
a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", (c.curvelin(freqMin, freqMax, 0, 360, freqCurve) * panR * d).wrap(-180, 180), (b.linlin(dbMin, dbMax, -1, 1) * panR * d).range(0, 90), spread) * env;

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// VBAP Distance selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de 0 à 90)
							"src1 = src1 * env;
/*#d, e = Pitch.kr(src1);
#f, g = Tartini.kr(src1);
#h, j = Qitch.kr(src1, ~qitchBuffer);*/

a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
b = b.linlin(dbMin, dbMax, -5, 5) * panR;
c = c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * panR;

point = [c * pointScale, b * pointScale].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src1, point );
// src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElev, spread) * env;
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]), spread) * env;

// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones)

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Ambisonique selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							"src1 = src1 * env;
a = FFT(LocalBuf(2048), src1);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

// #w, x, y, z = BFEncode2.ar(src1, (c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR * d) , (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR * d), delayUElev, 1.0);
#w, x, y, z = BFEncode2.ar(src1, (c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR * d) , (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR * d), Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]), 1.0);
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0);
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Panning VirtualMics roundPanOutput Distance avec trajectoires
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

pointVM = [a * pointScale * c, b * pointScale * c].asPoint;
pannedVM = VirtualMics.ar( micsVM, src1, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src1 = pannedVM * pankrVM * env;
OffsetOut.ar(outSpa, "++ ~configOutsVPM ++ ");",


							// VBAP Distance avec trajectoires - (Elévation déterminée par delayU -> range de 0 à 90)
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

point = [a * pointScale * c, b * pointScale * c].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src1, point );
// src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElev, spread) * env;
src1 = VBAP.ar(~numChannels, src1, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]), spread) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Ambisonique avec trajectoires - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							"#a, b = WFSPathPlayer.ar(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0);
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
// #w, x, y, z = BFEncode2.ar(src1, a * pointScale * c, b * pointScale * c, delayUElev, 1.0);
#w, x, y, z = BFEncode2.ar(src1, a * pointScale * c, b * pointScale * c, Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]), 1.0);
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0) * env;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");"

						],





						[ // Functions pour synthés stéréos --------------------------------------------------------

							// 0 - Répartition stéréo normale (à changer le Balance2 to Splay pour panning de l'ensemble des canaux ??? XXX)
							// 1 - Trajectoire stéréo entre le canal 0 et 1
							// 2 - Trajectoire stéréo entre le canal 1 et 0
							// 3 - Trajectoire stéréo entre le canal 0 et 1 et 0
							// 4 - Trajectoire stéréo entre le canal 1 et 0 et 1


							// Panning d'intensité
							"src = Balance2.ar(src[0], src[1], pan) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							// Panning d'intensité avec délai
							"src = Balance2.ar(src[0], src[1], pan) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, DelayN.ar(src[1], 0.2, delayTime));",
							// Panning d'intensité Lines
							/*"src = Balance2.ar(src[0], src[1], Line.kr(panL, panR, spadur));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							// "src = Balance2.ar(src[0], src[1], EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')));
							"src = Balance2.ar(src[0], src[1], Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ] )) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Panning VirtualMics (prenant en compte la distance)
							// Vraiment intéressant de fusionner la gauche et la droite ???????????????
							"src = NumChannels.ar(src, 1);
pointVM = [/*pointX*/ pan * pointScale, 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1 /*,\none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							/*"src = NumChannels.ar(src, 1);
							pointVM = [Line.kr(panL, panR, spadur) * pointScale, 0].asPoint;
							pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
							polarVM = pointVM.asPolar;
							angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*,\none*/); // none ???
							ampVM = (0.15 / polarVM.rho).min( 1 );
							pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
							src = pannedVM * pankrVM;
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							"src = NumChannels.ar(src, 1);
// pointVM = [EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * pointScale, 0].asPoint;
pointVM = [ Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * pointScale, 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*, \none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Panning spectral
							"chainA = FFT(LocalBuf(2048), src[0]);
chainB = FFT(LocalBuf(2048), src[1]);
panSpectral = pan.lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							/*"chainA = FFT(LocalBuf(2048), src[0]);
							chainB = FFT(LocalBuf(2048), src[1]);
							panSpectral = Line.kr(panL, panR, spadur).lincurve(-1, 1, 0, 1, panSpectralCurve);
							chainA = PV_BrickWall(chainA, panSpectral);
							chainB = PV_BrickWall(chainB, -1 + panSpectral);
							src = IFFT([chainA, chainB]);
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							"chainA = FFT(LocalBuf(2048), src[0]);
chainB = FFT(LocalBuf(2048), src[1]);
// panSpectral = EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')).lincurve(-1, 1, 0, 1, panSpectralCurve);
panSpectral = Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Bad
							/*"src = BiPanB2.ar(src[0], src[1], Line.kr(-1, 1, spadur));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",
							"src = Pan2.ar(src[0], src[1], Line.kr(-1, 1, spadur));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);"*/


							// Circulaire Unique PanAz
							/*"src1 = PanAz.ar(~numChannels, src[0], LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR ));
							OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",*/
							// Ajout de 3 lignes pour avoir la version MIROIR & réduction du volume à 0.7
							// Comment optimiser le CPU pour ne pas rajouter 2 enveloppes ??????????????????????????????????????????????????????????????????
							"a = LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR );
src1 = PanAz.ar(~numChannels, src[0], a, 0.7, width: circWidth) * env;
src2 = PanAz.ar(~numChannels, src[1], a * (-1), 0.7, width: circWidth) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire Multiple PanAz
							"a = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ] ), prepoutLU * 2, mul: panR );
src1 = PanAz.ar(~numChannels, src[0], a, 0.7, width: circWidth) * env;
src2 = PanAz.ar(~numChannels, src[1], a * (-1), 0.7, width: circWidth) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire selon données du centre spectral
							// Pourquoi NumChannels.ar(src, 1) au lieu de src[0] pour analyse de la FFT -> ne marche pas ????????????????????????????????????????????????????????????????
							"src = src * env;
a = FFT(LocalBuf(2048), src[0] /*NumChannels.ar(src, 1)*/);  // a complex signal
// b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = LFSaw.kr(c.curvelin(freqMin, freqMax, 0.1, panCircMReg, freqCurve), prepoutLU * 2, mul: panR );
src1 = PanAz.ar(~numChannels, src[0], d, 0.7, width: circWidth);
src2 = PanAz.ar(~numChannels, src[1], d * (-1), 0.7, width: circWidth);
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire Unique VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							// (1 tour max OUTL & OUTR déterminent l'angle de départ et d'arrivée du son)
							/*
							{100000.do {0.5.range(-90, 90)}}.bench;
							{100000.do {0.5.range(-90, 90).wrap(-90, 90)}}.bench;
							*/
							" // circPosX = Line.kr(start: Ramp.kr(prepoutLU.linlin(0, 1, 0, 360), 10), end: Ramp.kr(prepoutRU.linlin(0, 1, 0, 360), 10), dur: spadur);
circPosX = Line.kr(start: prepoutLU, end: prepoutRU, dur: spadur).linlin(0, 1, 0, 360).wrap(-180, 180);
// circPosY = delayUElev;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src[0], "++ ~configVBAPBuffers[serverNb].bufnum ++", (circPosX * panR).wrap(-180, 180), circPosY, spread) * env * 0.7;
src2 = VBAP.ar(~numChannels, src[1], "++ ~configVBAPBuffers[serverNb].bufnum ++", ((circPosX * panR) + x2Off /** (-1)*/ ).wrap(-180, 180), circPosY, spread) * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Circulaire Multiple VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"circPosX = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ]), prepoutLU * 2, mul: panR).range(-180, 180) /*.wrap(-180, 180)*/;
// circPosY = delayUElev;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src[0], "++ ~configVBAPBuffers[serverNb].bufnum ++", circPosX.wrap(-180, 180), circPosY, spread) * env * 0.7;
src2 = VBAP.ar(~numChannels, src[1], "++ ~configVBAPBuffers[serverNb].bufnum ++", (circPosX + x2Off /** (-1)*/ ).wrap(-180, 180), circPosY, spread) * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Panning VirtualMics roundPanOutput Distance selon données fréquentielles et d'amplitude
							// Rajout en multipliant le signal par 0.7 car signal trop fort du à NumChannels ?????????
							// Pourquoi obligé de mettre : a = FFT(LocalBuf(2048), src[0]); // car avec a = FFT(LocalBuf(2048), src); // Pas d'erreur, mais celà ne compile pas ?????????
							"src = src * env;
src = NumChannels.ar(src, 1);
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal

micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [(c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR)].asPoint;
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
pannedVM = VirtualMics.ar( micsVM, src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src = pannedVM * pankrVM * env * 0.7;

OffsetOut.ar(outSpa, "++ ~configOutsVPS ++ ");",


							// VBAP selon données fréquentielles (angle) et d'amplitude (élévation)
							"src = src * env;
a = FFT(LocalBuf(2048), src[0] /*NumChannels.ar(src, 1)*/);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
b = b.linlin(dbMin, dbMax, -1, 1) * panR;
c = c.curvelin(freqMin, freqMax, 0, 360, freqCurve) * panR;
b = b.range(0, 90);

src1 = VBAP.ar(~numChannels, src[0] * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", c.wrap(-180, 180), b /*b.range(0, 90)*/, spread) * env;
src2 = VBAP.ar(~numChannels, src[1] * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", (c + x2Off /** (-1)*/ ).wrap(-180, 180), b /*(b /** (-1)*/).range(0, 90)*/, spread) * env; // MIR
// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones) et miroir

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",


							// VBAP Distance selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"src = src * env;
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
b = b.linlin(dbMin, dbMax, -5, 5) * panR;
c = c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * panR;
b = b * pointScale;
c = c * pointScale;

point = [c, b].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[0], point );
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

point = [c * (-1), b * (-1)].asPoint;
src2 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[1], point );
src2 = VBAP.ar(~numChannels, src2 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones)

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Ambisonique selon données (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							// Angle inversé pour canal droit mais pas l'élévation
							// Ajout de 3 lignes pour avoir la version MIROIR & réduction du volume à 0.7 - trop lourd ???
							// Pourquoi NumChannels.ar(src, 1) au lieu de src[0] pour analyse de la FFT -> ne marche pas ????????????????????????????????????????????????????????????????
							"src = src * env;
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
c = c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR; // MIR
b = b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR; // MIR
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]);
#w, x, y, z = BFEncode2.ar(src[0], c, b, delayUElevG, /*1.0*/ 0.7);
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
#d, e, f, g = BFEncode2.ar(src[1], c * (-1), b * (-1), delayUElevG /** (-1)*/, /*1.0*/ 0.7); // MIR
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0);
src2 = BFDecode1.ar(d, e, f, g, "++ ~configAmbi ++ ", 0); // MIR
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",


							// Panning VirtualMics roundPanOutput Distance avec trajectoires
							// Rajout en multipliant le signal par 0.7 car signal trop fort du à NumChannels ?????????
							"src = NumChannels.ar(src, 1);
#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [a * pointScale, b * pointScale].asPoint;
pannedVM = VirtualMics.ar( micsVM, src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src = pannedVM * pankrVM * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOutsVPS ++ ");",


							// VBAP Distance avec trajectoires - (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
a = a * pointScale;
b = b * pointScale;

point = [a, b].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[0], point );
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

point = [a * (-1), b * (-1)].asPoint;
src2 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[1], point );
src2 = VBAP.ar(~numChannels, src2 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Ambisonique avec trajectoires - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							// Angle inversé pour canal droit mais pas l'élévation
							// Ajout de 3 lignes pour avoir la version MIROIR & réduction du volume à 0.7 - trop lourd ???
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0);
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]);
#w, x, y, z = BFEncode2.ar(src[0], a * pointScale, b * pointScale, delayUElevG, /*1.0*/ 0.7);
#d, e, f, g = BFEncode2.ar(src[1], a * pointScale * (-1), b * pointScale * (-1), delayUElevG /** (-1)*/, /*1.0*/ 0.7); // MIR
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0) * env;
src2 = BFDecode1.ar(d, e, f, g, "++ ~configAmbi ++ ", 0) * env; // MIR
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",

						],





						[ // Functions pour synthés stéréos avec variateur de vitesse sur panning --------------------------------------------------------

							// Différents variateurs de vitesse par canal stéréo ???????????????????????????????????


							// Panning d'intensité
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							// Panning d'intensité avec délai
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, DelayN.ar(src[1], 0.2, delayTime));",
							// Panning d'intensité Lines
							/*"src = Balance2.ar(src[0], src[1], Line.kr(panL, panR, spadur) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							// "src = Balance2.ar(src[0], src[1], EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]));
							"src = Balance2.ar(src[0], src[1], Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Panning VirtualMics (prenant en compte la distance)
							"src = NumChannels.ar(src, 1);
pointVM = [/*pointX*/ pan * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1 /*,\none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							/*"src = NumChannels.ar(src, 1);
							pointVM = [Line.kr(panL, panR, spadur) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
							pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
							polarVM = pointVM.asPolar;
							angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1/*,\none*/); // none ???
							ampVM = (0.15 / polarVM.rho).min( 1 );
							pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
							src = pannedVM * pankrVM;
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							"src = NumChannels.ar(src, 1);
// pointVM = [EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
pointVM = [ Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * pointScale * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]), 0].asPoint;
pannedVM = VirtualMics.ar( [ speakerRadius.neg @ 0,  speakerRadius @ 0 ], src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.fold(0,pi).linlin(0,pi,1,-1 /*,\none*/); // none ???
ampVM = (0.15 / polarVM.rho).min( 1 );
pankrVM = Pan2.kr( 1, angleVM ).max(ampVM);
src = pannedVM * pankrVM * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Panning spectral
							"chainA = FFT(LocalBuf(2048), src[0]);
chainB = FFT(LocalBuf(2048), src[1]);
panSpectral = (pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",
							/*"chainA = FFT(LocalBuf(2048), src[0]);
							chainB = FFT(LocalBuf(2048), src[1]);
							panSpectral = (Line.kr(panL, panR, spadur) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
							chainA = PV_BrickWall(chainA, panSpectral);
							chainB = PV_BrickWall(chainB, -1 + panSpectral);
							src = IFFT([chainA, chainB]);
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",*/
							"chainA = FFT(LocalBuf(2048), src[0]);
chainB = FFT(LocalBuf(2048), src[1]);
// panSpectral = (EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
panSpectral = (Select.kr(spaSpeed, [ Line.kr(panL, panR, spadur), EnvGen.kr(Env([panL, panR, panL], [spadur/2, spadur/2], 'linear')) ]) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])).lincurve(-1, 1, 0, 1, panSpectralCurve);
chainA = PV_BrickWall(chainA, panSpectral);
chainB = PV_BrickWall(chainB, -1 + panSpectral);
src = IFFT([chainA, chainB]) * env;
OffsetOut.ar(outL, src[0]);
OffsetOut.ar(outR, src[1]);",


							// Bad
							/*"src = BiPanB2.ar(src[0], src[1], Line.kr(-1, 1, spadur) * Select.kr(pamp == 0, [SinOsc.ar(panrate).bipolar(pamp), DC.ar(1)]));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);",
							"src = Pan2.ar(src[0], src[1], Line.kr(-1, 1, spadur) * Select.kr(pamp == 0, [SinOsc.ar(panrate).bipolar(pamp), DC.ar(1)]));
							OffsetOut.ar(outL, src[0]);
							OffsetOut.ar(outR, src[1]);"*/


							// Circulaire Unique PanAz
							// (le même qu'en stéréo simple car pas de variateur de vitesse)
							"a = LFSaw.kr(spadur.reciprocal, prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
src1 = PanAz.ar(~numChannels, src[0], a, 0.7, width: circWidth) * env;
src2 = PanAz.ar(~numChannels, src[1], a * (-1), 0.7, width: circWidth) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire Multiple PanAz
							"a = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ] ), prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
src1 = PanAz.ar(~numChannels, src[0], a, 0.7, width: circWidth) * env;
src2 = PanAz.ar(~numChannels, src[1], a * (-1), 0.7, width: circWidth) * env;
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire selon données du centre spectral
							"src = src * env;
a = FFT(LocalBuf(2048), src[0] /*NumChannels.ar(src, 1)*/);  // a complex signal
// b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = LFSaw.kr(c.curvelin(freqMin, freqMax, 0.1, panCircMReg, freqCurve), prepoutLU * 2, mul: panR ) * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
src1 = PanAz.ar(~numChannels, src[0], d, 0.7, width: circWidth);
src2 = PanAz.ar(~numChannels, src[1], d * (-1), 0.7, width: circWidth);
OffsetOut.ar(outSpa, "++ ~configOutsCircM ++ ");
OffsetOut.ar(outSpa, "++ ~configOutsCircS ++ ");",


							// Circulaire Unique VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							// (1 tour max OUTL & OUTR déterminent l'angle de départ et d'arrivée du son)
							"d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
// circPosX = Line.kr(start: Ramp.kr(prepoutLU.linlin(0, 1, 0, 360), 10), end: Ramp.kr(prepoutRU.linlin(0, 1, 0, 360), 10), dur: spadur) * d;
circPosX = Line.kr(start: prepoutLU, end: prepoutRU, dur: spadur).linlin(0, 1, 0, 360).wrap(-180, 180) * d;
// circPosY = delayUElev * d;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]) * d;
src1 = VBAP.ar(~numChannels, src[0], "++ ~configVBAPBuffers[serverNb].bufnum ++", (circPosX * panR).wrap(-180, 180), circPosY, spread) * env * 0.7;
src2 = VBAP.ar(~numChannels, src[1], "++ ~configVBAPBuffers[serverNb].bufnum ++", (circPosX * panR + x2Off /** (-1)*/ ).wrap(-180, 180), circPosY, spread) * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");",


							// Circulaire Multiple VBAP (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
circPosX = LFSaw.kr(Select.kr(spaSpeed, [ panCircMReg, Line.kr(start: panCircMVarMin, end: panCircMVarMax, dur: spadur), Line.kr(start: panCircMVarMax, end: panCircMVarMin, dur: spadur) ]), prepoutLU * 2, mul: panR).range(-180, 180) /*.wrap(-180, 180)*/ * d;
// circPosY = delayUElev * d;
circPosY = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]) * d;
src1 = VBAP.ar(~numChannels, src[0], "++ ~configVBAPBuffers[serverNb].bufnum ++", circPosX.wrap(-180, 180), circPosY, spread) * env * 0.7;
src2 = VBAP.ar(~numChannels, src[1], "++ ~configVBAPBuffers[serverNb].bufnum ++", (circPosX + x2Off /** (-1)*/ ).wrap(-180, 180), circPosY, spread) * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Panning VirtualMics roundPanOutput Distance selon données fréquentielles et d'amplitude
							// Rajout en multipliant le signal par 0.7 car signal trop fort du à NumChannels ?????????
							// Pourquoi obligé de mettre : a = FFT(LocalBuf(2048), src[0]); // car avec a = FFT(LocalBuf(2048), src); // Pas d'erreur, mais celà ne compile pas ?????????
							"src = src * env;
src = NumChannels.ar(src, 1);
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );

pointVM = [(c.curvelin(freqMin, freqMax , -5, 5, freqCurve) * pointScale * panR * d), (b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR * d)].asPoint;
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
pannedVM = VirtualMics.ar( micsVM, src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src = pannedVM * pankrVM * env * 0.7;

OffsetOut.ar(outSpa, "++ ~configOutsVPS ++ ");",


							// VBAP selon données fréquentielles (angle) et d'amplitude (élévation)
							"src = src * env;
a = FFT(LocalBuf(2048), src[0] /*NumChannels.ar(src, 1)*/);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
d = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
b = b.linlin(dbMin, dbMax, -1, 1) * panR * d;
c = c.curvelin(freqMin, freqMax, 0, 360, freqCurve) * panR * d;
b = b.range(0, 90);

src1 = VBAP.ar(~numChannels, src[0], "++ ~configVBAPBuffers[serverNb].bufnum ++", c.wrap(-180, 180), b /*b.range(0, 90)*/, spread) * env;
src2 = VBAP.ar(~numChannels, src[1], "++ ~configVBAPBuffers[serverNb].bufnum ++", (c + x2Off /** (-1)*/ ).wrap(-180, 180), b /*(b /** (-1)*/).range(0, 90)*/, spread) * env; // MIR
// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones) et miroir

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",


							// VBAP Distance selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"src = src * env;
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
b = b.linlin(dbMin, dbMax, -5, 5) * panR;
c = c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * panR;
b = b * pointScale;
c = c * pointScale;

point = [c, b].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[0], point );
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

point = [c * (-1), b * (-1)].asPoint;
src2 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[1], point );
src2 = VBAP.ar(~numChannels, src2 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

// de gauche à droite du cercle -> du + grave au plus aigu (20/6K) & élévation -> du plus faible au plus fort (0/40 sones)

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Ambisonique selon données fréquentielles (x) et d'amplitude (y) - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							// Angle inversé pour canal droit mais pas l'élévation
							"src = src * env;
a = FFT(LocalBuf(2048), src[0]);  // a complex signal
b = Loudness.kr(a).varlag(spaLagTime);
c = SpecCentroid.kr(a).varlag(spaLagTime); // the most perceptually prominent frequency range in signal
h = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
c = c.curvelin(freqMin, freqMax, -5, 5, freqCurve) * pointScale * panR * h; // MIR
b = b.linlin(dbMin, dbMax, -5, 5) * pointScale * panR * h; // MIR
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]);
#w, x, y, z = BFEncode2.ar(src[0], c, b, delayUElevG, /*1.0*/ 0.7);
// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)
#d, e, f, g = BFEncode2.ar(src[1], c * (-1), b * (-1), delayUElevG /** (-1)*/, /*1.0*/ 0.7); // MIR
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0);
src2 = BFDecode1.ar(d, e, f, g, "++ ~configAmbi ++ ", 0); // MIR
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",


							// Panning VirtualMics roundPanOutput Distance avec trajectoires
							// Rajout en multipliant le signal par 0.7 car signal trop fort du à NumChannels ?????????
							"src = NumChannels.ar(src, 1);
#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
micsVM = ({ |i|
Polar( speakerRadius, (i - orientation).linlin( 0, ~numChannelsVP, 0.5pi, -1.5pi /*, \none*/ ) ).asPoint
} ! ~numChannelsVP );
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);

pointVM = [a * pointScale * c, b * pointScale * c].asPoint;
pannedVM = VirtualMics.ar( micsVM, src, pointVM, dbRollOff );
polarVM = pointVM.asPolar;
angleVM = polarVM.angle.linlin(-0.5pi, 1.5pi, 1, -1 /*,\none*/ );
ampVM = (0.15 / polarVM.rho).linlin(0.15, 1, 0, 1 /*,\minmax*/ );

pankrVM = PanAz.kr( ~numChannelsVP, 1, angleVM, orientation ).max(ampVM);
src = pannedVM * pankrVM * env * 0.7;
OffsetOut.ar(outSpa, "++ ~configOutsVPS ++ ");",


							// VBAP Distance avec trajectoires - (Elévation déterminée par delayU -> range de 0 à 90)
							// Angle inversé pour canal droit mais pas l'élévation
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0)/*.poll(label: [\a, \b], trigid: [0, 1])*/;
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
a = a * pointScale * c;
b = b * pointScale * c;

point = [a, b].asPoint;
src1 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[0], point );
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: 0, end: 90, dur: spadur), Line.kr(start: 90, end: 0, dur: spadur) ]);
src1 = VBAP.ar(~numChannels, src1 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

point = [a * (-1), b * (-1)].asPoint;
src2 = WFSPrePan( dbRollOff, maxAmpRadius, latencyComp ).ar( src[1], point );
src2 = VBAP.ar(~numChannels, src2 * 0.7, "++ ~configVBAPBuffers[serverNb].bufnum ++", point.theta/2pi*360.neg + 90, delayUElevG, spread) * env;

OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ ");",


							// Ambisonique avec trajectoires - (Elévation déterminée par delayU -> range de -0.5pi à 0.5pi)
							// Angle inversé pour canal droit mais pas l'élévation
							"#a, b = WFSPathPlayer.kr(trajBuf, ratio: trajBufRatio, loop: trajBufLoop, doneAction: 0);
c = Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ]);
delayUElevG = Select.kr(selElev, [ delayUElev, Line.kr(start: -0.5pi, end: 0.5pi, dur: spadur), Line.kr(start: 0.5pi, end: -0.5pi, dur: spadur) ]);
#w, x, y, z = BFEncode2.ar(src[0], a * pointScale * c, b * pointScale * c, delayUElevG, /*1.0*/ 0.7);
#d, e, f, g = BFEncode2.ar(src[1], a * pointScale * (-1), b * pointScale * (-1), delayUElevG /** (-1)*/, /*1.0*/ 0.7); // MIR
src1 = BFDecode1.ar(w, x, y, z, "++ ~configAmbi ++ ", 0) * env;
src2 = BFDecode1.ar(d, e, f, g, "++ ~configAmbi ++ ", 0) * env; // MIR
OffsetOut.ar(outSpa, "++ ~configOuts ++ ");
OffsetOut.ar(outSpa, "++ ~configOuts2 ++ "); // MIR",

						]

					];





					case

					{~numChannelsConfig == "16-Dome-8-6-2-Clock" or: {~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"}}

					{

						~acousItems = [
							"A1_1_S", "A1_1b_S", "A1_2_S", "A1_2b_S", "A1_3_S", "A1_3b_S", "A1_4_S", "A1_4b_S",
							"A1_5_S", "A1_5b_S", "A1_6_S", "A1_6b_S", "A1_7_S", "A1_7b_S", "A1_8_S", "A1_8b_S",
							"A1_9_M", "A1_9b_M", "A1_10_M", "A1_10b_M", "A1_11_M", "A1_11b_M", "A1_12_M", "A1_12b_M",
							"A1_13_H", "A1_13b_H", "A1_14_H", "A1_14b_H",  "A2_15_H", "A2_15b_H",
							"A2_16_M", "A2_16b_M", "A2_17_M", "A2_17b_M", "A2_18_M", "A2_18b_M", "A2_19_M", "A2_19b_M",
							"A3_20_S", "A2_20b_S", "A3_21_M", "A3_21b_M", "A3_22_M", "A3_22b_M", "A3_23_M", "A3_23b_M",
							"A3_24_M", "A3_24b_M", "A4_25_T", "A4_25b_T"
						];

						~bigStereoOuts = [
							[[0, 7], [1, 2]], // "A1_1_S",
							[[0, 1], [7, 2]], // "A1_1b_S",
							[[1, 2], [3, 4]], // "A1_2_S",
							[[2, 3], [1, 4]], // "A1_2b_S",
							[[3, 4], [5, 6]], // "A1_3_S",
							[[4, 5], [3, 6]], // "A1_3b_S",
							[[5, 6], [7, 0]], // "A1_4_S",
							[[6, 7], [0, 5]], // "A1_4b_S",
							[[0, 5], [1, 4]], // "A1_5_S",
							[[0, 1], [4, 5]], // "A1_5b_S",
							[[1, 6], [2, 5]], // "A1_6_S",
							[[1, 2], [5, 6]], // "A1_6b_S",
							[[7, 2], [6, 3]], // "A1_7_S",
							[[2, 3], [7, 6]], // "A1_7b_S",
							[[0, 3], [7, 4]], // "A1_8_S",
							[[3, 4], [0, 7]], // "A1_8b_S",
							[[0, 13], [1, 9]], // "A1_9_M",
							[[0, 1], [13, 9]], // "A1_9b_M",
							[[9, 2], [10, 3]], // "A1_10_M",
							[[2, 3], [9, 10]], // "A1_10b_M",
							[[10, 4], [12, 5]], // "A1_11_M",
							[[5, 4], [12, 10]], // "A1_11b_M",
							[[6, 12], [7, 13]], // "A1_12_M",
							[[7, 6], [13, 12]], // "A1_12b_M",
							[[13, 12], [9, 10]], // "A1_13_H",
							[[13, 9], [10, 12]], // "A1_13b_H",
							[[8, 14], [11, 15]], // "A1_14_H",
							[[8, 15], [11, 14]], // "A1_14b_H",

							[[8, 12, 13], [9, 10, 11]], // "A2_15_H",
							[[8, 9, 13], [10, 11, 12]], // "A2_15b_H",
							[[0, 7, 13], [1, 2, 9]], // "A2_16_M",
							[[0, 1, 7], [2, 9, 13]], // "A2_16b_M",
							[[1, 2, 9], [3, 4, 10]], // "A2_17_M",
							[[1, 10, 9], [3, 4, 2]], // "A2_17b_M",
							[[3, 4, 10], [5, 6, 12]], // "A2_18_M",
							[[3, 4, 5], [6, 12, 10]], // "A2_18b_M",
							[[5, 6, 12], [0, 7, 13]], // "A2_19_M",
							[[0, 12, 13], [5, 6, 7]], // "A2_19b_M",
							[[0, 1, 2, 7], [3, 4, 5, 6]], // "A3_20_S",
							[[0, 7, 6, 5], [1, 2, 3, 4]], // "A2_20b_S",

							[[0, 1, 13, 9], [12, 10, 5, 4]], // "A3_21_M",
							[[0, 12, 13, 5], [1, 10, 9, 4]], // "A3_21b_M",
							[[2, 1, 8, 9], [12, 11, 5, 6]], // "A3_22_M",
							[[6, 1, 8, 12], [2, 9, 5, 11]], // "A3_22b_M",
							[[2, 3, 10, 9], [12, 13, 6, 7]], // "A3_23_M",
							[[2, 7, 13, 9], [12, 10, 3, 6]], // "A3_23b_M",
							[[10, 11, 3, 4], [13, 0, 7, 8]], // "A3_24_M",
							[[0, 10, 3, 8], [11, 7, 13, 4]], // "A3_24b_M",

							[[0, 7, 6, 5, 8, 13, 12], [1, 2, 3, 4, 9, 10, 11]], // "A4_25_T",
							[[0, 1, 8, 7, 13, 9, 2], [3, 4, 5, 6, 10, 11, 12]] // "A4_25b_T"
						];

						// ~bigStereoOutsSizes = [28, 10, 10, 2];
						~bigStereoOutsSizes2 = [28, 38, 48];
						// ~bigStereoOuts.collect { |i| i[0].size }
						// [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7, 7 ]


						~allSpas[0].addAll ( ["_Acous1", "_Acous2", "_Acous3", "_Acous4"] );

						~allSpas[1].addAll ( [
							"src1 = Pan2.ar(src1, pan) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src1[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.57735;
OffsetOut.ar(\\outsL.ar([0,1,2]), src1[0]);
OffsetOut.ar(\\outsR.ar([3,4,5]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.377964473;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6]), src1[0]);
OffsetOut.ar(\\outsR.ar([7,8,9,10,11,12,13]), src1[1]);",
						] );
						// Pour la gestion des volumes
						// 7.reciprocal.sqrt // 0.70710678118655 // 0.57735026918963 // 0.5 // 0.37796447300923

						~allSpas[2].addAll ( [
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src1[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.57735;
OffsetOut.ar(\\outsL.ar([0,1,2]), src1[0]);
OffsetOut.ar(\\outsR.ar([3,4,5]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.377964473;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6]), src1[0]);
OffsetOut.ar(\\outsR.ar([7,8,9,10,11,12,13]), src1[1]);",
						] );

						~allSpas[3].addAll ( [
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.57735;
OffsetOut.ar(\\outsL.ar([0,1,2]), src[0]);
OffsetOut.ar(\\outsR.ar([3,4,5]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.377964473;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6]), src[0]);
OffsetOut.ar(\\outsR.ar([7,8,9,10,11,12,13]), src[1]);",
						] );

						~allSpas[4].addAll ( [
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env  * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.57735;
OffsetOut.ar(\\outsL.ar([0,1,2]), src[0]);
OffsetOut.ar(\\outsR.ar([3,4,5]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.377964473;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6]), src[0]);
OffsetOut.ar(\\outsR.ar([7,8,9,10,11,12,13]), src[1]);",
						] );

					}


					{~numChannelsConfig == "24-UsineC-3Octo" or: {~numChannelsConfig == "16-UsineC-2Octo"}}

					{

						~acousItems = [
							"A1_1_S", "A1_1b_S", "A1_2_S", "A1_2b_S", "A1_3_S", "A1_3b_S", "A1_4_S", "A1_4b_S",
							"A1_5_S", "A1_5b_S", "A1_6_S", "A1_6b_S", "A1_7_S", "A1_7b_S", "A1_8_S", "A1_8b_S",
							"A1_9_M", "A1_9b_M", "A1_10_M", "A1_10b_M", "A1_11_M", "A1_11b_M", "A1_12_M", "A1_12b_M",
							"A1_13_H", "A1_13b_H", "A1_14_H", "A1_14b_H",  "A2_15_H", "A2_15b_H",
							"A2_16_M", "A2_16b_M", "A2_17_M", "A2_17b_M", "A2_18_M", "A2_18b_M", "A2_19_M", "A2_19b_M",
							"A3_20_S", "A2_20b_S", "A3_21_M", "A3_21b_M", "A3_22_M", "A3_22b_M", "A3_23_M", "A3_23b_M",
							"A3_24_M", "A3_24b_M", "A4_25_T", "A4_25b_T"
						];

						~bigStereoOuts = [
							[[0, 7], [1, 2]], // "A1_1_S",
							[[0, 1], [7, 2]], // "A1_1b_S",
							[[1, 2], [3, 4]], // "A1_2_S",
							[[2, 3], [1, 4]], // "A1_2b_S",
							[[3, 4], [5, 6]], // "A1_3_S",
							[[4, 5], [3, 6]], // "A1_3b_S",
							[[5, 6], [7, 0]], // "A1_4_S",
							[[6, 7], [0, 5]], // "A1_4b_S",
							[[0, 5], [1, 4]], // "A1_5_S",
							[[0, 1], [4, 5]], // "A1_5b_S",
							[[1, 6], [2, 5]], // "A1_6_S",
							[[1, 2], [5, 6]], // "A1_6b_S",
							[[7, 2], [6, 3]], // "A1_7_S",
							[[2, 3], [7, 6]], // "A1_7b_S",
							[[0, 3], [7, 4]], // "A1_8_S",
							[[3, 4], [0, 7]], // "A1_8b_S",

							[[0, 8], [1, 9]], // "A1_9_M",
							[[0, 1], [8, 9]], // "A1_9b_M",
							[[10, 2], [11, 3]], // "A1_10_M",
							[[2, 3], [10, 11]], // "A1_10b_M",
							[[12, 4], [13, 5]], // "A1_11_M",
							[[5, 4], [12, 13]], // "A1_11b_M",
							[[6, 14], [7, 15]], // "A1_12_M",
							[[7, 6], [14, 15]], // "A1_12b_M",
							[[14, 15], [10, 11]], // "A1_13_H",
							[[15, 10], [14, 11]], // "A1_13b_H",
							[[14, 15], [11, 10]], // "A1_14_H",
							[[8, 13], [12, 9]], // "A1_14b_H",

							[[8, 13, 14, 15], [9, 10, 11, 12]], // "A2_15_H",
							[[8, 9, 15, 10], [10, 11, 12]], // "A2_15b_H",
							[[0, 7, 8, 15], [1, 2, 9, 10]], // "A2_16_M",
							[[0, 1, 7, 2], [8, 9, 10, 15]], // "A2_16b_M",
							[[1, 2, 9, 10], [3, 4, 11, 12]], // "A2_17_M",
							[[1, 2, 3, 4], [9, 10, 11, 12]], // "A2_17b_M",
							[[3, 4, 11, 12], [5, 6, 13, 14]], // "A2_18_M",
							[[3, 4, 5, 6], [11, 12, 13, 14]], // "A2_18b_M",
							[[5, 6, 13, 14], [0, 7, 15, 8]], // "A2_19_M",
							[[13, 14, 15, 8], [5, 6, 7, 0]], // "A2_19b_M",
							[[0, 1, 2, 7], [3, 4, 5, 6]], // "A3_20_S",
							[[0, 7, 6, 5], [1, 2, 3, 4]], // "A2_20b_S",

							[[0, 1, 9, 8], [12, 13, 5, 4]], // "A3_21_M",
							[[0, 8, 13, 5], [1, 12, 9, 4]], // "A3_21b_M",
							[[2, 1, 9, 10], [13, 14, 5, 6]], // "A3_22_M",
							[[6, 1, 9, 14], [2, 10, 5, 13]], // "A3_22b_M",
							[[2, 3, 10, 11], [14, 15, 6, 7]], // "A3_23_M",
							[[2, 7, 15, 10], [11, 14, 3, 6]], // "A3_23b_M",
							[[11, 12, 3, 4], [15, 0, 7, 8]], // "A3_24_M",
							[[0, 8, 3,11], [12, 7, 15, 4]], // "A3_24b_M",

							[[0, 7, 6, 5, 8, 13, 14, 15], [1, 2, 3, 4, 9, 10, 11, 12]], // "A4_25_T",
							[[0, 1, 2, 7, 8, 9, 10, 15], [3, 4, 5, 6, 11, 12, 13, 14]] // "A4_25b_T"
						];

						// ~bigStereoOutsSizes = [28, 10, 10, 2];
						~bigStereoOutsSizes2 = [28, 38, 48];
						// ~bigStereoOuts.collect { |i| i[0].size }
						// [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 7, 7 ]
						// [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8, 8 ]


						~allSpas[0].addAll ( ["_Acous1", "_Acous2", "_Acous3", "_Acous4"] );

						~allSpas[1].addAll ( [
							"src1 = Pan2.ar(src1, pan) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src1[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.5;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan) * env * 0.377964473;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6,7]), src1[0]);
OffsetOut.ar(\\outsR.ar([8,9,10,11,12,13,14,15]), src1[1]);",
						] );
						// Pour la gestion des volumes
						// 7.reciprocal.sqrt // 0.70710678118655 // 0.57735026918963 // 0.5 // 0.37796447300923

						~allSpas[2].addAll ( [
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src1[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src1[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src1[1]);",
							"src1 = Pan2.ar(src1, pan * Select.ar(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.42;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6,7]), src1[0]);
OffsetOut.ar(\\outsR.ar([8,9,10,11,12,13,14,15]), src1[1]);",
						] );

						~allSpas[3].addAll ( [
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan) * env * 0.42;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6,7]), src[0]);
OffsetOut.ar(\\outsR.ar([8,9,10,11,12,13,14,15]), src[1]);",
						] );

						~allSpas[4].addAll ( [
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env  * 0.7071;
OffsetOut.ar(\\outsL.ar([0,1]), src[0]);
OffsetOut.ar(\\outsR.ar([2,3]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.55;
OffsetOut.ar(\\outsL.ar([0,1,2,3]), src[0]);
OffsetOut.ar(\\outsR.ar([4,5,6,7]), src[1]);",
							"src = Balance2.ar(src[0], src[1], pan * Select.kr(pamp.ceil, [DC.ar(1), SinOsc.ar(panrate, 0, pamp) ])) * env * 0.42;
OffsetOut.ar(\\outsL.ar([0,1,2,3,4,5,6,7]), src[0]);
OffsetOut.ar(\\outsR.ar([8,9,10,11,12,13,14,15]), src[1]);",
						] );

					};


					~allSpasSize = ~allSpas[0].size; // Info Pour le pattern


				);
			);










			// ALL OLD
			// ~commonSynthArgs = "outL= 0, outR= 1, outSpa= 0, prepoutLU=0, prepoutRU=0, amp= 0.5, pan= 0, panL= 1, panR= -1, panCircMReg= 1, panCircMVarMin= 0.1, panCircMVarMax= 2, spaSpeed= 0, spaLagTime= 1, durenv= 1, atk= 0.1, rel= 0.1, atkPerc= 0.1, relPerc= 0.1, atkCurve= 0, relCurve= 0, width= 0.6, envexp1= 1, envexp2= 0.001, envperc1= 1, envperc2= 1, bufSpec, busVolume= 100, trajBuf, trajBufRatio= 1, trajBufLoop= 0, pointScale= 0.5, silenceTime= 1, pointX= 0, pointY= 0, pointScale= 0, dbRollOff= (-6), speakerRadius= 0.3, orientation= 0.5, delayTime= 0.2,";
			// segs= 1000, endphase= 1000, // plus utilisé -> buffer d'enveloppe à modifier en dehors du synthé

			// SPA
			// outL= 0, outR= 1, outSpa= 0, prepoutLU=0, prepoutRU=0, pan= 0, panL= 1, panR= -1, panCircMReg= 1, panCircMVarMin= 0.1, panCircMVarMax= 2, spaSpeed= 0, spaLagTime= 1, trajBuf, trajBufRatio= 1, trajBufLoop= 0, pointScale= 0.5, pointX= 0, pointY= 0, pointScale= 0, dbRollOff= (-6), speakerRadius= 0.3, orientation= 0.5, delayTime= 0.2

			// ENV
			// atk= 0.1, rel= 0.1, atkPerc= 0.1, relPerc= 0.1, atkCurve= 0, relCurve= 0, width= 0.6, envexp1= 1, envexp2= 0.001, envperc1= 1, envperc2= 1, bufSpec,



			~commonSynthArgs = "amp= 0.5, durenv= 1, busVolume= 100, silenceTime= 1,";

			~envSynthArgs = [
				"atk= 0.1, rel= 0.1, atkCurve= 0, relCurve= 0,", // Enveloppe linéaire Variable
				"width= 0.6,", // Enveloppe gaussienne
				"atkPerc= 0.1, relPerc= 0.1, atkCurve= 0, relCurve= 0,", // Enveloppe percussive & percussive inversée
				"atk= 0.1, rel= 0.1, atkCurve= 0, relCurve= 0, bufSpec,", // Enveloppe spéciale chaotique "fractale" déterminée Variable
				"envexp1= 1, envexp2= 0.001," // Enveloppe exponentielle & exponentielle inversée
			];

			~spaSynthArgs = [
				"outL= 0, outR= 1, pan= 0", // Panning d'intensité
				"outL= 0, outR= 1, pan= 0, delayTime= 0.2", // Panning d'intensité avec délai
				"outL= 0, outR= 1, spaSpeed= 0, panL= 1, panR= (-1)", // Panning d'intensité Lines
				"outL= 0, outR= 1, pan= 0, /*pointX= 0,*/ pointScale= 1, dbRollOff= (-6), speakerRadius= 0.3", // Panning VirtualMics Distance
				"outL= 0, outR= 1, spaSpeed= 0, panL= 1, panR= (-1), pointScale= 1, dbRollOff= (-6), speakerRadius= 0.3", // Panning VirtualMics Distance Lines
				"outL= 0, outR= 1, pan= 0, panSpectralCurve= 8", // Panning spectral Lines
				"outL= 0, outR= 1, spaSpeed= 0, panL= 1, panR= (-1), panSpectralCurve= 8", // Panning spectral avec AR
				"outSpa= 0, prepoutLU=0, panR= (-1), circWidth= 2", // Circulaire unique
				"outSpa= 0, prepoutLU=0, panR= (-1), spaSpeed= 0, panCircMReg= 1, panCircMVarMin= 0.1, panCircMVarMax= 2, circWidth= 2", // Circulaire multiple
				"outSpa= 0, prepoutLU=0, panR= (-1), spaLagTime= 1, panCircMReg= 1, circWidth= 2, freqMin= 20, freqMax= 6000, freqCurve= 2", // Circulaire selon données du centre spectral
				"outSpa= 0, prepoutLU=0, prepoutRU=0, panR= (-1), spread= 0.1, selElev=0, delayUElev= 0, x2Off= 180", // Circulaire unique VBAP
				"outSpa= 0, prepoutLU=0, panR= (-1), spaSpeed= 0, panCircMReg= 1, panCircMVarMin= 0.1, panCircMVarMax= 2, spread= 0.1, selElev=0, delayUElev= 0, x2Off= 180", // Circulaire multiple VBAP
				"outSpa= 0, panR= (-1), spaLagTime= 1, pointScale= 1, dbRollOff= (-6), speakerRadius= 0.3, orientation= 0.5, freqMin= 20, freqMax= 6000, freqCurve= 2, dbMin= 0, dbMax= 50", // Panning VirtualMics roundPanOutput Distance selon données fréquentielles et d'amplitude
				"outSpa= 0, panR= (-1), spaLagTime= 1, spread= 1, x2Off= 180, freqMin= 20, freqMax= 6000, freqCurve= 2, dbMin= 0, dbMax= 50", // VBAP avec les données fréquentielles et d'amplitude
				"outSpa= 0, panR= (-1), spaLagTime= 1, pointScale= 1, spread= 1, x2Off= 180, dbRollOff= -6, maxAmpRadius= 2, latencyComp= 0, selElev=0, delayUElev= 0, freqMin= 20, freqMax= 6000, freqCurve= 2, dbMin= 0, dbMax= 50", // VBAP Distance selon données fréquentielles et d'amplitude perceptives et spectrales
				"outSpa= 0, panR= (-1), spaLagTime= 1, pointScale= 0.5, selElev=0, delayUElev= 0, freqMin= 20, freqMax= 6000, freqCurve= 2, dbMin= 0, dbMax= 50", // Ambisonique selon données fréquentielles et d'amplitude
				"outSpa= 0, pointScale= 1, trajBuf, trajBufRatio= 1, trajBufLoop= 0, dbRollOff= (-6), speakerRadius= 0.3, orientation= 0.5", // Panning VirtualMics roundPanOutput selon avec trajectoires
				"outSpa= 0, pointScale= 1, trajBuf, trajBufRatio= 1, trajBufLoop= 0, dbRollOff= (-6), maxAmpRadius= 2, latencyComp= 0, selElev=0, delayUElev= 0, spread= 1", // VBAP Distance avec trajectoires
				"outSpa= 0, pointScale= 0.5, trajBuf, trajBufRatio= 1, trajBufLoop= 0, selElev=0, delayUElev= 0" // Ambisonique avec trajectoires
			];





			// OLD SPA variables
			// var chainA, chainB, panSpectral, pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM, micsVM, w, x, y, z, r, s, t, u, v, a, b, /* */ c, d, e, f, g, h, i, j, k, l, m;

			~spaSynthVars = [
				"", // Panning d'intensité
				"", // Panning d'intensité avec délai
				"", // Panning d'intensité Lines
				"var pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM;", // Panning VirtualMics Distance
				"var pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM;", // Panning VirtualMics Distance Lines
				"var chainA, chainB, panSpectral;", // Panning spectral Lines
				"var chainA, chainB, panSpectral;", // Panning spectral avec AR
				"var a;", // Circulaire unique (a -> seulement pour version stéréo)
				"var a;", // Circulaire multiple (a -> seulement pour version stéréo)
				"var a, /*b,*/ c, d;", // Circulaire selon données du centre spectral (d -> seulement pour version stéréo)
				"var circPosX, circPosY, d, delayUElevG;", // Circulaire unique VBAP (circPosX, circPosY, delayUElevG -> seulement pour la stéréo) (d -> seulement pour la variation de vitesse)
				"var circPosX, circPosY, d, delayUElevG;", // CIrculaire multiple VBAP (circPosX, circPosY, delayUElevG -> seulement pour la stéréo) (d -> seulement pour la variation de vitesse)
				"var pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM, micsVM, a, b, c, d /*, e, f, g, h, i, j, k, l, m*/ ;", // Panning VirtualMics roundPanOutput Distance selon données fréquentielles et d'amplitude perceptives et spectrales (d -> seulement pour la variation de vitesse)
				"var a, b, c, d ;", // VBAP selon données fréquentielles et d'amplitude perceptives et spectrales
				"var a, b, c, d, point, delayUElevG ;", // VBAP Distance selon données fréquentielles et d'amplitude perceptives et spectrales (delayUElevG -> seulement pour la stéréo)
				"var w, x, y, z, /*r, s, t, u, v,*/ a, b, c, d, e, f, g, h, delayUElevG /*, i, j, k, l, m*/;", // Ambisonique selon données fréquentielles et d'amplitude perceptives et spectrales (d, e, f, g, delayUElevG -> seulement pour version stéréo) (h -> seulement pour la variation de vitesse)
				"var pointVM, pannedVM, pankrVM, polarVM, angleVM, ampVM, micsVM, a, b, c;", // Panning VirtualMics roundPanOutput Distance avec trajectoires
				"var point, a, b, c, delayUElevG;", // VBAP Distance avec trajectoires (delayUElevG -> seulement pour la stéréo)
				"var w, x, y, z, /*r, s, t, u, v,*/ a, b, c, d, e, f, g, delayUElevG;"// Ambisonique avec trajectoires (d, e, f, g, delayUElevG -> seulement pour version stéréo) (c -> seulement pour la variation de vitesse)
			];





			case
			{~numChannelsConfig == "16-Dome-8-6-2-Clock" or: {~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"} or: {~numChannelsConfig == "24-UsineC-3Octo"} or: {~numChannelsConfig == "16-UsineC-2Octo"}}
			{
				~spaSynthArgs.addAll ([
					"pan= 0", // Acous 1
					"pan= 0", // Acous 2
					"pan= 0", // Acous 3
					"pan= 0" // Acous 4
				]);

				~spaSynthVars.addAll ([
					"", // Acous 1
					"", // Acous 2
					"", // Acous 3
					"" // Acous 4
				]);
			};






























			// Liste de tous les synthés avec les enveloppes et les spatialisations

			// Changer le \durenv & \prepsyn2 & \prepsynExt dans le pattern si changement des synthés XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

			~allSynthsGUI = [
				"BufM", "BufMVar", "BufMVar2", "BufMPitch", "BufMPitchVar", "BufMPitchVar2", "BufMR", "BufMRoll", "WarpM", // Mono
				"BufS", "BufSVar", "BufSVar2", "BufSPitch", "BufSPitchVar", "BufSPitchVar2", "BufSR", "BufSRoll", "WarpS", // Stereo
				/*"BufGrain",*/ "GrainBuf", "ConcatBufSig", "ConcatBufIn",
				"ConcatInSig", "GrainIn", "WarpIn",
				/*"Sine",*/ "SineFB", "Blip", "PMOsc", "GrainSin", "GrainFM",
				"UpPiano", "AcidOto", "StringOto", /*"Guit_Oto",*/
				"KikOto", "SnareOto", "ClapOto", "HatOto",
				"Electribe",
				"BufMGliss", "BufMPitchGliss", "WarpMGliss", // Glissando Mono
				"BufSGliss", "BufSPitchGliss", "WarpSGliss", // Glissando Stereo
				"GrainBufGliss", "PMOscGliss" // Glissando Autres
			];
			// juste pour nommer les synthés de la GUI

			// ~allSynthsGUI.size
			~nbSynthBuf = 8; // nb de synthé avec Buffers à partir de 0

			~allSynthsGUI2 = (~allSynthsGUI[0..~nbSynthBuf] ++ ~allSynthsGUI[((~nbSynthBuf*2)+2)..~allSynthsGUI.size-1-8]); // -8 pour les glissandi, qui sont déclenchés avec le bouton ~ratSynth
			// juste pour nommer les synthés de la GUI en retirant les bufs M ou S

			~allSynths = ~allSynthsGUI.collect {|i| i ++ "_"}; // juste pour nommer les synthés du Synth

			~allSynths2 = ~allSynthsGUI2.collect {|i| i ++ "_"}; // juste pour nommer les synthés du Synth en retirant les bufs M ou S

			(
				~instruments = List.new;
				~allSynths.collect { | iSy |
					~allSpas[0].collect {| iSp |
						~allEnvs[0].collect {| iE |
							~instruments.add(iSy++iE++iSp);
						}
					}
				};

				// ~instruments.postln; // coupe la liste à la différence de ci-dessous
				// Pas nécessaire d'afficher tous les synthés
				/*Post << ~instruments;
				" ".postln;*/ // Check Post within Collections

			);





			// Nb de synthés générés et chargés dans le serveur
			/*
			"synths loaded = " + ("~allSynths.size".interpret + " * " + "~allSpas[0].size".interpret + " * " + ~allEnvs[0].size) + " = " + "~allSynths.size * ~allSpas[0].size * ~allEnvs[0].size".interpret;
			~instruments.size; // Check

			// 1680 synthés + 154 par défault => 1834 + 5 synthés effets + 1 StageLimiter = 1840 synthés ?
			"nb synths loaded + 84 default synths  + 5 synthés effets + 1 StageLimiter = " + ((~allSynths.size * ~allSpas[0].size * ~allEnvs[0].size) + 84 + 6);
			*/






























			({
				// Construction de Synthés avec ≠ enveloppes & spatialisations

				// voir l'utilisation de Out vs ReplaceOut vs OffsetOut vs XOut XXX ???
				// obligé de mettre EnvGen.ar sur l'envelope sinon clics si .kr quand enveloppe trop courte
				// Attention pour les synthés mono à mettre en stéréo -> utilisation {}.dup ou ().dup ou !2 // plus nécessaire





				// ~allSpas[0].collect {|itemS, indexS| ~allEnvs[0].collect {|item, index| // juste pour recompiler un synthé XXXXXXXXX

				// Buffer Mono simple

				/*~synth =
				("SynthDef(\\BufM_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs++" /*rate= 1,*/ lagTime= 0.1, offset= 0, bufm, trig, loop= 0 |
				var src1, bufRate, bufFrames;
				"+~allEnvs[1][index]+"
				bufRate = \\rate.kr(1, lagTime) * BufRateScale.ir(bufm);
				bufFrames = offset * BufFrames.ir(bufm);
				src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;
				"+~allSpas[1][indexS]+"
				})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
				~synth.asCompileString.postln;
				~synth.interpret;*/

				// }}; // juste pour recompiler un synthé XXXXXXXXX





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple
							// A comparer version avec un petit lag comme au dessus et sans lag ci-dessus XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

							~synth =
							("SynthDef(\\BufM_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
							~synth.asCompileString.postln;
							~synth.interpret;

				}})}); // ~synthDefsManagement = ~synthDefsManagementList[1]; // Pour sauvegarder de nouveau le synthé dans un fichier XXXXXXXXX

				~metaDataBufM = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple avec variation de la vitesse de lecture, d'amplitude et du panning
							// au niveau de la vitesse de lecture utiliser SinOsc au lieu de LFPar ou LFDNoise3 ???
							// voir comment intégrer la variation de Pan car intégré dans le AllSpas ???
							// voir comment gérer la variation de pan & qualité du kr (pas plus que 800) ???

							~synth =
							("SynthDef(\\BufMVar_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * SinOsc.ar(amprate, 0, aamp, 1) * inBusVol * amp;

"+~allSpas[2][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMVar = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple 2 avec variation de la vitesse de lecture, d'amplitude et du panning (différence dans le Ugen de variation)
							// au niveau de la vitesse de lecture utiliser SinOsc au lieu de LFPar ou LFDNoise3 ???
							// voir comment intégrer la variation de Pan car intégré dans le AllSpas ???
							// voir comment gérer la variation de pan & qualité du kr (pas plus que 800) ???

							~synth =
							("SynthDef(\\BufMVar2_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0, stretcherU= 1, centerU= 1 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * LFDNoise3.ar(amprate, aamp, 1) * inBusVol * amp;
src1 = BBandPass.ar(src1, centerU.linexp(0, 1, 20, 20000)/*.poll*/, stretcherU.lincurve(0, 1, 0.01, 10, 3)/*.poll*/ );

/*src1 = BBandPass.ar(src1,
MouseX.kr(20, 20000, \\exponential),
MouseY.kr(0.0, 10.0, \\linear)
);*/

/*src1 = BPeakEQ.ar(src1, // Parametric equalizer
MouseX.kr(20, 20000, \\exponential),
0.8, // rq
MouseY.kr(12.0, -12.0, \\linear),
1); // mul*/

/*src1 = BMoog.ar(src1,
MouseX.kr(20, 20000, \\exponential),
MouseY.kr(1.0, 0.0, \\linear),
2);*/ // mode BandPass

"+~allSpas[2][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMVar2 = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Filter Bandwidth (U)'), // stretcherU -> version unitaire, mais conservation des ControlSpec par défaut de BufMpitch
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'Filter Freq (U)'), // centerU -> version unitaire, mais conservation des ControlSpec par défaut de BufMpitch
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono avec Pitchshift & Freqshift
							// A peaufiner le pitchshift & freqshift XXXXXXX

							~synth =
							("SynthDef(\\BufMPitch_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, center= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src1 = PitchShift.ar(src1, windowSize: psWindowSize, pitchRatio: stretcher, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src1 = FreqShift.ar(src1, center * (1-stretcher)) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMPitch = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];



				// Fun : Frequency-stretching evil
				// http://www.newscores.com/scforum/index.php?topic=278.0

				/*
				s.boot;
				p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
				b = Buffer.read(s, p);

				(
				SynthDef('freq-stretch-evil', { |stretch = 1, center = 440, out|
				var	sig = PlayBuf.ar(1, b, loop: 1);
				// stretched
				sig = PitchShift.ar(sig, 0.2, stretch, timeDispersion: 0.05);
				// re-centered
				sig = FreqShift.ar(sig, center * (1-stretch));
				Out.ar(out, sig ! 2);
				}, metadata: (specs: (stretch: [0.25, 4, \exp], center: [0, 16000, 6] /*\freq*/ ))).store;

				SynthDescLib.at('freq-stretch-evil').makeWindow;
				)

				(
				SynthDef('freq-stretch-evil', { |stretch = 1, center = 440, out|
				var	sig = PlayBuf.ar(1, b, loop: 1);
				// stretched
				sig = PitchShift.ar(sig, 0.2, stretch * [0.25, 0.33], timeDispersion: 0.5, pitchDispersion: 0.5).sum;
				// re-centered
				sig = FreqShift.ar(sig, center * (1-stretch) - [200, 100, 50]).sum;
				Out.ar(out, sig ! 2);
				}, metadata: (specs: (stretch: [0.25, 4, \exp], center: \freq))).store;

				SynthDescLib.at('freq-stretch-evil').makeWindow;
				)
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono avec Pitchshift & Freqshift & Variation de vitesse
							// Pour la variation de vistesse le LFDNoise a été modifié par un LFPar

							~synth =
							("SynthDef(\\BufMPitchVar_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, center= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src1 = PitchShift.ar(src1, windowSize: psWindowSize, pitchRatio: stretcher, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src1 = FreqShift.ar(src1, center * (1-stretcher)) * SinOsc.ar(amprate, 0, aamp, 1) * inBusVol * amp;

"+~allSpas[2][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMPitchVar = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono avec Pitchshift & Freqshift 2 & Variation de vitesse (différence dans le Ugen de variation)
							// Pour la variation de vistesse le LFDNoise a été modifié par un LFPar
							// Mettre un timeDispersion & pitchDispersion par défaut à 0.5 XXXXXXXXX

							~synth =
							("SynthDef(\\BufMPitchVar2_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, stretcher2U= 1, center= 440, center2U=1, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);

/*sig = PitchShift.ar(sig, 0.2, stretch * [0.25, 0.33], timeDispersion: 0.5, pitchDispersion: 0.5).sum;
sig = FreqShift.ar(sig, center * (1-stretch) - [200, 100, 50]).sum;*/

// [0.98, 1.02] [0.9, 1.1] [0.1, 0.3] [0.6, 0.9]

src1 = PitchShift.ar(src1, windowSize: psWindowSize, pitchRatio: stretcher * [0.25, 0.33], pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers).sum;
src1 = FreqShift.ar(src1, center * (1-stretcher) - [200, 100, 50]).sum * LFDNoise3.ar(amprate, aamp, 1) * inBusVol * amp;
src1 = BBandPass.ar(src1, center2U.linexp(0, 1, 20, 20000)/*.poll*/, stretcher2U.lincurve(0, 1, 0.01, 10, 3)/*.poll*/ );

"+~allSpas[2][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMPitchVar2 = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2U ->  'Filter Bandwidth (U)
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2U - > 'Filter Freq (U)'
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				/*
				if ( ~synthDefsBuild == 1, {
				( // juste pour recompiler un synthé XXXXXXXXX
				~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

				// Buffer Mono simple - BufRd - Version random sur la tête de lecture

				~synth =
				("SynthDef(\\BufMR_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rate= 1, /*offset= 0,*/ bufm, /*trig,*/ loop= 0 |
				var src1, bufRate, bufFrames;
				"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

				bufRate = /*LFDNoise1*/ LFDNoise3.ar(rate) * BufFrames.ir(bufm);
				// bufFrames = offset * BufFrames.ir(bufm);

				src1 = BufRd.ar(1, bufm, bufRate, loop, 4) * inBusVol * amp;

				"+~allSpas[1][indexS]+"
				})."++~synthDefsManagement);
				~synth.asCompileString.postln;
				~synth.interpret;

				}})});*/

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple - BufRd - Version avec ou sans random sur la tête de lecture
							// Stretcher détermine la fréquence du générateur aléatoire LFDNoise3 & offset l'amplitude de l'aléatoire
							// Voire utilité d'avoir .ar pour le rate sur Line & LFDNoise3 ???????????????????????????
							// The phase argument only offers precision for addressing 2**24 samples (about 6.3 minutes at 44100Hz).

							~synth =
							("SynthDef(\\BufMR_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprateU= 1, preprate2U= 1, offset= 0, stretcher=1, bufm, /*trig,*/ loop= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// bufRate = /*LFDNoise1*/ LFDNoise3.ar(offset) * BufFrames.ir(bufm);
// bufFrames = offset * BufFrames.ir(bufm);

bufRate = (Line.ar(preprateU, preprate2U, durenv) + LFDNoise3.ar(stretcher, offset)).wrap(0,1) * BufFrames.ir(bufm);

src1 = BufRd.ar(1, bufm, bufRate, loop, 4) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMR = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Pos Start (U)'), // preprateU -> version unitaire, mais conservation des ControlSpec par défaut de BufM
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Pos End (U)'), // preprate2U -> version unitaire, mais conservation des ControlSpec par défaut de BufM
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Rand Pos Freq Rate'), // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Mul Pos Freq Rate'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple avec Roll / Stutter
							// (from the ddwChucklib quark) -> changement de Line en XLine
							// Voire d'autes synthés avec Stutter

							~synth =
							("SynthDef(\\BufMRoll_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, loop= 0, stretcher= 1, stretcher2= 1, centerU= 1 |
var src1, bufRate, bufFrames, trigger, trigs, strokeEnv, attack, decay, strokesPerSec;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

attack = 0.002;
decay = 0.002;
strokesPerSec = Select.kr(centerU, [stretcher, Line.kr(stretcher, stretcher2, durenv)] );
// trigger = Impulse.ar(stretcher); // strokesPerSec
trigger = Impulse.ar(strokesPerSec);
trigs = PulseDivider.ar(trigger, 2, (0..1));
strokeEnv = EnvGen.ar(Env.linen(attack, strokesPerSec.reciprocal - attack - decay, decay), trigs);

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = (PlayBuf.ar(1, bufm, bufRate, trigs, bufFrames, loop) * strokeEnv).sum * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMRoll = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0.1, 10, 'lin', 0.01, 1, 'Strokes Per Sec Start'), // stretcher
					ControlSpec(0.1, 10, 'lin', 0.01, 1, 'Strokes Per Sec End'), // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'Switch Roll Line (U)'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				/*
				if ( ~synthDefsBuild == 1, {
				( // juste pour recompiler un synthé XXXXXXXXX
				~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

				// Warp0 Mono
				// A tester les buffers de son pour envbufnum XXXXXXXXX
				// Warp0.ar(numChannels, buffer, warpFactor, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add)
				// Def = pointer = LFSaw.kr( warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
				// Def = ^Warp1.ar(numChannels, buffer, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add);
				// Inspired by Chad Kirby's SuperCollider2 Warp1 class, which was inspired by Richard Karpen's sndwarp for CSound. A granular time strecher and pitchshifter.

				~synth =
				("SynthDef(\\WarpM_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, bufm, /*trig, loop= 0,*/ stretcher= 1, center= 1, psWindowSize= 0.2 /*, psTimeDispers= 0.05*/ |
				var src1, bufRate, bufFrames;
				"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

				bufRate = preprate * BufRateScale.ir(bufm);

				// bufFrames = offset * BufFrames.ir(bufm);
				// src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

				src1 = Warp0.ar(1, bufm, stretcher, bufRate, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4) * inBusVol * amp;

				"+~allSpas[1][indexS]+"
				})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
				~synth.asCompileString.postln;
				~synth.interpret;

				}})});

				~metaDataWarpM = [
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale'), // preprate
				nil, // rate2
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor (Stretch / Compress)'), // stretcher
				nil, // stretcher2
				ControlSpec(1, 100, 'lin', 0.01, 8, 'Overlaps (de 1 à 100)'), // center.clip(1, 100)
				nil, // center2
				ControlSpec(0, 1, 'lin', 0.01, 0, 'Window Rand Ratio'), // offset
				];
				*/

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono Time-Stretch (exemple PD)
							// Proposition de contrôle
							/*
							RAT -> Transpo
							STR -> Stretch
							CEN -> Harmonizer - auparavant gDur / taille de fenêtre en ms -> Multiple ou % de la taille de fenêtre - entre 0.01 ms ou plus et la taille de fenêtre - comment faire ?;
							OFF -> Position de départ dans Buffer -> pas de position de fin - calculé selon durée et stretch
							*/
							// La variation de gDur devrait produire des clics.

							// Le nbGrain doit être réduit à 8 quand spatialisation sur 8 canaux, sinon les synthés avec _VM & _VM_SD_CenLoud ne peuvent pas être compilés car apparemment trop lourd ????????
							// ["WarpM_Exp_VM_SD_CenLoud.scsyndef", "WarpM_Exp_VM.scsyndef", "WarpM_Gauss_VM_SD_CenLoud.scsyndef", "WarpM_Gauss_VM.scsyndef", "WarpM_Line_VM_SD_CenLoud.scsyndef", "WarpM_Line_VM.scsyndef", "WarpM_Perc_VM_SD_CenLoud.scsyndef", "WarpM_Perc_VM.scsyndef", "WarpM_SpecVar_VM_SD_CenLoud.scsyndef", "WarpM_SpecVar_VM.scsyndef" ]
							// Le synthé "WarpM_SpecVar_VM.scsyndef" ne peut tout de même pas compilé avec 8 grains et les enveloppes chaotiques

							~synth =
							("SynthDef(\\WarpM_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, center= 1, nbSlices = 1, gDurRand = 0.01/*0.01*/, trajRand = 3/*3*/, rdRand = 0.01, grainSize = 60, grain2Size = 60 /*, psWindowSize= 0.2*/ /*0.01*/ /*, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0*/ |
// arg buf = b, posS = 0, posE = 1, len = 1, gDur = 100, nbSlices = 1, transpo = 1, gDurRand = 0.01, trajRand = 3, rdRand = 0.01, envWidth = 0.95 /*, nbGrain = 8, nbChannel = 1*/;

var nbChannel, nbGrain, nbGrainReciprocal, volGrain, srDiv, gDur, gDurV, gDurSmp, slice, len, posE, traj, mainPhasor, src1, rd, gEnv, pos, gr;
var semitone, rd1, env1, rd2, env2, bufL, tapWrite, outs, out1, out2;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

nbChannel = 1; // Question perso : Comment mettre nbChannel & nbGrain en argument ?
nbGrain = 16; // Quel nb de grains à appliquer pour le meilleur compromis entre rendu sonore et CPU ? 16 ou 32 ? XXXXXXXXX
// Note that .asInteger doesn't round to the nearest integer. It chops off the fractional part. So the server-side equivalent is 'trunc'. // ne marche pas ?

nbGrainReciprocal = nbGrain.reciprocal;
volGrain = nbGrainReciprocal/*.sqrt*/; // Comment déterminer le niveau de volume (le + intéressant) à attribuer pour chaque grain ? Quelle formule ? // (1/2).sqrt si 2 sons ? XXXXXXXXX
srDiv = SampleRate.ir * 0.001; // préférable de diviser ou multiplier le signal en termes de CPU ?
// gDur =  psWindowSize.linlin(0.05, 1, 0.01, 200) /*centerU.linlin(0, 1, 0.01, 200)*/; // .linlin pratiquement même benchmark qu'avec .range
gDur = grainSize/*.varlag(1)*/; // Control.names([\\psWindowSize]).ir(0.2).linlin(0.05, 1, 20, 200);
// Apparemment une valeur de 0.1 minimale ne provoque pas d'explosions, mais en dessous si...
gDurV = gDur + WhiteNoise.ar( gDurRand /*0.05*/ /*0.5*/); // JITTER sur la taille de la fenêtre - Voire l'intérêt de LFDNoise3 (Dynamic cubic noise) au lieu de WhiteNoise ? XXXXXXXXX
gDurSmp = gDurV * srDiv; // Conversion de la durée de la taille de fenêtre de ms en samples
slice = BufFrames.ir/*kr*/(bufm) / nbSlices; // slice.poll; // nbSlices pas utilisé ????????? - 1 par défaut // Durée du Buffer lu

// durenv.poll;
// BufDur.ir(bufm).poll;
len = ((durenv / BufDur.ir(bufm)) * stretcher/*.clip(0.001, 10)*/)/*.poll*/;
posE = (offset + len)/*.poll*/;

traj = Line.ar(offset * slice, posE * slice, durenv /*dur*/ /*, doneAction: 2*/) + WhiteNoise.ar( trajRand /*5*/); // Lecture linéaire de la position dans le grain avec JITTER
// A expérimenter avec différentes enveloppes de trajectoires ? Lesquelles pourraient être les plus intéressantes ?

mainPhasor = LFSaw.ar(gDur.reciprocal * 1000 * rater.abs /*.clip(0.001, 10)*/; /*MouseX.kr(0.1, 10)*/, 0, 0.5, 0.5);
// Pourquoi crash avec Saw ? - Intérêt si fréquence très élevée ?

rd = 0 ! nbGrain; // Question perso : Autre moyen d'initialiser les Arrays ?
gEnv = 0 ! nbGrain;
pos = 0 ! nbGrain;
gr = 0 ! nbGrain;

// Code pour la génération d'un nb de grains en fonction de la variable nbGrain
nbGrain.do { |i| // Mettre .collect ou .do ??? - Aucun besoin de collecter ???
// rd[i] calcule la position du pointeur de lecture de chaque grain = LFSaw (main_phasor) + phase + JITTER pour chaque grain
rd[i] = Wrap.ar(mainPhasor + (nbGrainReciprocal * i)/*.postln*/ + /*WhiteNoise.ar(rdRand).unipolar*/ Rand(0, rdRand) );
// équivalent de 100.rand * 0.0001 - voire changement à chaque sample avec WhiteNoise.ar(rdRand) ou TRand avec Trigger ? XXXXXXXXX
// rdRand.rand // valeur aléatoire, la même pour tous les grains
gEnv[i] = (rd[i] * pi).sin; // enveloppe sinusoïdale ?
// gEnv[i] = rd[i].welWindow; // Autre manière de faire l'enveloppe sinusoïdale ? - Plus lourde - prend au moins 1% de CPU en plus ? Question perso : Pourquoi ?
// gEnv[i] = ( -0.5 * (rd[i] * 2 * pi).cos + 0.5); // enveloppe hanning
// gEnv[i] = rd[i].hanWindow; // Autre manière de faire l'enveloppe Hanning - Plus lourde - prend au moins 1% de CPU en plus ?
// gEnv[i] = rd[i].rectWindow; // Intérêt de l'enveloppe rectangulaire ? fait du crunchy...
// gEnv[i] = rd[i].triWindow; // enveloppe triangulaire
// Comment faire le switch entre différentes enveloppes dans un même synthé de manière économique en CPU ?
pos[i] = Latch.ar(traj, rd[i] > 0.99); // Latch -> Sample and hold
gr[i] = BufRd.ar(nbChannel, bufm, (rd[i] * gDurSmp) + pos[i], loop, interpolation: 4) * gEnv[i] * volGrain; // pas de Latch pour gDurSmp comme dans l'exemple PD ?
}; // voire exemples de BufRd

// (pos[0] / BufFrames.ir(bufm)).wrap.poll; // Indication de la position dans le Buffer de 0 à 1. A retirer.
outs = gr.sum;
// src1 = Out.ar(0, (gr.sum * env) ! 2); // ! 2 pour dupliquer le signal mono
// Out.ar(0, Mix(gr * env) ! 2); // équivalent
// Out.ar(0, NumChannels.ar(gr, 2));

// Partie Harmonizer
/*
0.midicps
0.pow(24 / 12)
*/

semitone = 2.pow(/*MouseX.kr(-127, 127, 0, 0.5)*/ (center - 50).clip(-50, 50) /*.linlin(0, 127, -64, 64);*/ /*pitch*/ / 12)/*.poll*/;

rd1 = LFSaw.ar( ((-1) * (semitone-1)) / ( /*gDur.max(1)*/ grain2Size /*60*/ * 0.001) /*pitch*/, 0, 0.5, 0.5); // Intérêt du jitter dans ce cas ?
// Comment adoucir les aigues et les sifflantes quand filtre est partfois trop élevé ? en fonction des sons ? Type de filtre HP et contrôle ?

env1 = (rd1 * pi).sin; // enveloppe sinusoïdale
rd2 = Wrap.ar(rd1 + 0.5); // Wrap a signal outside given thresholds.
env2 = (rd2 * pi).sin;

/*var env1 = ( -0.5 * (rd1 * 2 * pi).cos + 0.5); // enveloppe hanning
var rd2 = Wrap.ar(rd1 + 0.5); // Wrap a signal outside given thresholds.
var env2 = ( -0.5 * (rd2 * 2 * pi).cos + 0.5);*/

/*var snd1 = AllpassL.ar(sig, 2, ((rd1 * gDur) /*+ 2*/) / 1000, 0) * env1; // // All pass delay line with linear interpolation.
var snd2 = AllpassL.ar(sig, 2, ((rd2 * gDur) /*+ 2*/) / 1000, 0) * env2;*/

bufL = LocalBuf(SampleRate.ir * 2).clear;
tapWrite = DelTapWr.ar(bufL, outs);
out1 = DelTapRd.ar(bufL, tapWrite, delTime: (rd1 * /*gDur.max(1)*/ 60 * 0.001) + 0.002, interp: 2) * env1;
out2 = DelTapRd.ar(bufL, tapWrite, delTime: (rd2 * /*gDur.max(1)*/ 60 * 0.001) + 0.002, interp: 2) * env2;
// Pourquoi 0.002 ??? -> ne peut pas aller au delà du blocksize - 64 / 44100
// Clic avec interpolation cubique (4) sur DelTapRd

// (pos[0] / BufFrames.ir(buf)).wrap.poll; // Indication de la position dans le Buffer de 0 à 1. A retirer.

// comment créer la même chose que Hip~ 4 (Filtre Hipass IIR de 1er ordre) de PD dans SC ?
// Out.ar(0, (gr.sum * env) ! 2); // ! 2 pour dupliquer le signal mono
// Out.ar(0, (HPF.ar((snd1 + snd2) * env, 4)) ! 2); // ! 2 pour dupliquer le signal mono
// HPF => A second order high pass filter.
src1 = HPF.ar((out1 + out2) * inBusVol * amp, 4);

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataWarpM = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Transpo'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Stretch'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 100, 'lin', 0.001, 50, 'Harmonizer (en demi-ton - 50)'), // center
					// ControlSpec(0, 127, 'lin', 1, 1, 'gDur (20 - 200 ms)'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];

				/*(
				SynthDef(\samplerT, { arg buf = b, posS = 0, posE = 1, len = 1, gDur = 100, nbSlices = 1, transpo = 1, gDurRand = 0.01, trajRand = 3, rdRand = 0.01, envWidth = 0.95 /*, nbGrain = 8, nbChannel = 1*/;

				var nbChannel = 1; // Question perso : Comment mettre nbChannel & nbGrain en argument ?
				var nbGrain = 16; // Quel nb de grains à appliquer pour le meilleur compromis entre rendu sonore et CPU ? 16 ou 32 ? XXXXXXXXX
				// Note that .asInteger doesn't round to the nearest integer. It chops off the fractional part. So the server-side equivalent is 'trunc'. // ne marche pas ?

				var nbGrainReciprocal = nbGrain.reciprocal;
				var volGrain = nbGrainReciprocal.sqrt; // Comment déterminer le niveau de volume (le + intéressant) à attribuer pour chaque grain ? Quelle formule ? // (1/2).sqrt si 2 sons ? XXXXXXXXX
				var srDiv = SampleRate.ir * 0.001; // préférable de diviser ou multiplier le signal en termes de CPU ?
				var gDurV = gDur + WhiteNoise.ar( gDurRand /*0.05*/ /*0.5*/); // JITTER sur la taille de la fenêtre - Voire l'intérêt de LFDNoise3 (Dynamic cubic noise) au lieu de WhiteNoise ? XXXXXXXXX
				var gDurSmp = gDurV * srDiv; // Conversion de la durée de la taille de fenêtre de ms en samples

				// Enveloppe globale sinusoïdale - si envWidth = 0.95 et len = 1s, la durée des fadeTimes de début et de fin seront de 0.025 secondes, cad 25 ms
				var fadeT = (1 - envWidth) * 0.5;
				var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeT, envWidth, fadeT], \sin), levelScale: 1, timeScale: len, doneAction: 2);

				var slice = BufFrames.ir/*kr*/(buf) / nbSlices; // slice.poll; // nbSlices pas utilisé ????????? - 1 par défaut // Durée du Buffer lu
				var traj = Line.ar(posS * slice, posE * slice, len /*, doneAction: 2*/) + WhiteNoise.ar( trajRand /*5*/); // Lecture linéaire de la position dans le grain avec JITTER
				// A expérimenter avec différentes enveloppes de trajectoires ? Lesquelles pourraient être les plus intéressantes ?

				var mainPhasor = LFSaw.ar(gDur.reciprocal * 1000 * transpo /*MouseX.kr(0.1, 10)*/, 0, 0.5, 0.5);
				// Pourquoi crash avec Saw ? - Intérêt si fréquence très élevée ?

				var rd = 0 ! nbGrain; // Question perso : Autre moyen d'initialiser les Arrays ?
				var gEnv = 0 ! nbGrain;
				var pos = 0 ! nbGrain;
				var gr = 0 ! nbGrain;

				// Code pour la génération d'un nb de grains en fonction de la variable nbGrain
				var grains = nbGrain.do { |i| // Mettre .collect ou .do ??? - Aucun besoin de collecter ???
				// rd[i] calcule la position du pointeur de lecture de chaque grain = LFSaw (main_phasor) + phase + JITTER pour chaque grain
				rd[i] = Wrap.ar(mainPhasor + (nbGrainReciprocal * i).postln + Rand(0, rdRand) );
				// équivalent de 100.rand * 0.0001 - voire changement à chaque sample avec WhiteNoise.ar(rdRand) ou TRand avec Trigger ? XXXXXXXXX
				// rdRand.rand // valeur aléatoire, la même pour tous les grains
				gEnv[i] = (rd[i] * pi).sin; // enveloppe sinusoïdale ?
				// gEnv[i] = rd[i].welWindow; // Autre manière de faire l'enveloppe sinusoïdale ? - Plus lourde - prend au moins 1% de CPU en plus ? Question perso : Pourquoi ?
				// gEnv[i] = ( -0.5 * (rd[i] * 2 * pi).cos + 0.5); // enveloppe hanning
				// gEnv[i] = rd[i].hanWindow; // Autre manière de faire l'enveloppe Hanning - Plus lourde - prend au moins 1% de CPU en plus ?
				// gEnv[i] = rd[i].rectWindow; // Intérêt de l'enveloppe rectangulaire ? fait du crunchy...
				// gEnv[i] = rd[i].triWindow; // enveloppe triangulaire
				// Comment faire le switch entre différentes enveloppes dans un même synthé de manière économique en CPU ?
				pos[i] = Latch.ar(traj, rd[i] > 0.99); // Latch -> Sample and hold
				gr[i] = BufRd.ar(nbChannel, buf, (rd[i] * gDurSmp) + pos[i]) * gEnv[i] * volGrain; // pas de Latch pour gDurSmp comme dans l'exemple PD ?
				};

				// (pos[0] / BufFrames.ir(buf)).wrap.poll; // Indication de la position dans le Buffer de 0 à 1. A retirer.

				Out.ar(0, (gr.sum * env) ! 2); // ! 2 pour dupliquer le signal mono
				// Out.ar(0, Mix(gr * env) ! 2); // équivalent
				// Out.ar(0, NumChannels.ar(gr, 2));

				// gr.postln; // donne avec .collect -> [ a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen, a BinaryOpUGen ]
				// grains.postcs; // donne avec .collect ce qu'il y a au dessus multiplé par 16 - Question perso : Pourquoi ???

				// gDurRand.postln; // Question perso : Comment récupérer dans le post window la valeur et non pas -> an OutputProxy ?

				/* // Code pour générer des enveloppes XXXXXXXXX
				(0..100..1) // Question perso : Comment générer une liste avec des steps ???

				((((0..100)/100) * pi).sin).plot; // Création d'une enveloppe sinusoïdale ? XXXXXXXXX
				(((((0..100)/100) * pi) - (0.25 * 2pi)).cos).plot; // Création d'une enveloppe sinusoïdale ? Plus lourd ?
				( -0.5 * (((0..100)/100) * 2 * pi).cos + 0.5).plot; // Création d'une enveloppe hanning XXXXXXXXX

				((((0..100)/100) * pi).sin.tan.normalize).plot // Création d'une enveloppe quasi triangulaire
				((((0..100)/100) * pi).sin.squared.normalize).plot // Création d'une enveloppe quasi triangulaire
				((((0..100)/100) * pi).sin.distort.normalize).plot // Création d'une enveloppe en forme de cloche
				// Attention -> .normalize ne peut pas s'appliquer sur un signal, mais sur un Array -> nécessite le Ugen Normalizer et un temps de délai, mais pas approprié
				// A optimiser la création d'enveloppes différentes ??? Comment remplacer les moses de PD de manière simple et plus économique que :
				Select.ar(aSignal > anotherSignal, [false_signal, true_signal]);
				// car avec Select -> "All the UGens are continously running. This may not be the most efficient way if each input is CPU-expensive."

				// Contournement pour créer quelques enveloppes - voire windowing in SimpleNumber / mais plus lourd en CPU que de la créer à la main - voire plus haut ?
				((0..100) / 100 ).collect(_.rectWindow).plot
				((0..100) / 100 ).collect(_.hanWindow).plot
				((0..100) / 100 ).collect(_.welWindow).plot
				((0..100) / 100 ).collect(_.triWindow).plot

				((0..100) / 100 ).collect(_.scurve).plot
				*/

				/* A deleter
				gEnv[i] = (rd[i] * pi).sin;
				((((0..100)/100) * pi).sin).plot;
				( -0.5 * (((0..100)/100) * 2 * pi).cos + 0.5).plot;
				*/

				/* XXXXXXXXX
				// a sinc function envelope - Comment la retranscrire en signal et non en array ?
				~env = { | num=1, size=200| dup({ |x| x = x.linlin(0, size-1, -pi, pi) * num; sin(x) / x }, size); };
				~env.(2).plot
				// utiliser rd[i] * gDurSmp pour la taille de la fenêtre ? et normaliser de 0 à 1 ?
				*/

				// enveloppe Tuckey ??? dans patch en classe granulaire

				/* // enveloppe "gaussienne" avec taille variable - voire patch en classe granulaire
				~env = { |w|
				var x = ((0..100)/100);
				case
				{ x < w }
				{ ( -0.5 * x * pi / w).cos + 0.5).plot;

				}
				~env.(8)
				*/

				/* // Code du Beat slicer by Brusli
				rd1 = LFSaw.ar(1000 / gDur, 1, 0.5, 0.5);
				hann1 = (rd1 * pi).sin;
				pos1 = Latch.ar(Line.ar(pos * slice, (pos * slice) + slice, len, doneAction: 2), rd1 > 0.99);
				gr1 = BufRd.ar(2, buf, (rd1 * 44.1 * gDur) + pos1) * hann1;
				*/

				}).add /*load*/;
				// Génération éventuelle d'une erreur au delà d'un certain nb de grains en simultané avec add -> utiliser load à la place :
				/*ERROR: makeSynthMsgWithTags: buffer overflow
				ERROR: Primitive '_NetAddr_SendMsg' failed.
				Failed.*/
				)*/










				// Stéréo ----------------------------------------------------------------------------------------------

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple
							// éventuellement mettre un variateur de vitesse dynamique (SinOsc / LFDNoise3) au lieu de statique (offRateSecondBuf) XXX

							~synth =
							("SynthDef(\\BufS_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufS = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple avec variation de la vitesse de lecture, d'amplitude et du panning
							// au niveau de la vitesse de lecture utiliser SinOsc au lieu de LFPar ou LFDNoise3 ???
							// voir comment intégrer la variation de Pan car intégré dans le AllSpas ???
							// voir comment gérer la variation de pan & qualité du kr (pas plus que 800) ???

							// éventuellement mettre un variateur de vitesse différencié entre le canal gauche et droit XXX

							~synth =
							("SynthDef(\\BufSVar_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2] * SinOsc.ar(amprate, 0, aamp, 1) * inBusVol * amp;

"+~allSpas[4][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSVar = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple avec variation de la vitesse de lecture, d'amplitude et du panning (différence dans le Ugen de variation)
							// au niveau de la vitesse de lecture utiliser SinOsc au lieu de LFPar ou LFDNoise3 ???
							// voir comment intégrer la variation de Pan car intégré dans le AllSpas ???
							// voir comment gérer la variation de pan & qualité du kr (pas plus que 800) ???

							~synth =
							("SynthDef(\\BufSVar2_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0, stretcherU= 1, centerU= 1 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2] * LFDNoise3.ar(amprate, aamp, 1) * inBusVol * amp;

src = BBandPass.ar(src, centerU.linexp(0, 1, 20, 20000), stretcherU.lincurve(0, 1, 0.01, 10, 3) );

"+~allSpas[4][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSVar2 = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Filter Bandwidth (U)'), // stretcherU
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'Filter Freq (U)'), // centerU
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo avec Pitchshift & Freqshift
							// A peaufiner le pitchshift & freqshift XXXXXXX

							~synth =
							("SynthDef(\\BufSPitch_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, stretcher= 1, center= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2];
src = PitchShift.ar(src, windowSize: psWindowSize, pitchRatio: stretcher, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src = FreqShift.ar(src, center * (1-stretcher)) * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSPitch = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo avec Pitchshift & Freqshift & Variation de vitesse
							// Pour la variation de vistesse le LFDNoise a été modifié par un LFPar

							~synth =
							("SynthDef(\\BufSPitchVar_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, stretcher= 1, center= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2];
src = PitchShift.ar(src, windowSize: psWindowSize, pitchRatio: stretcher, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src = FreqShift.ar(src, center * (1-stretcher)) * SinOsc.ar(amprate, 0, aamp, 1) * inBusVol * amp;

"+~allSpas[4][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSPitchVar = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo avec Pitchshift & Freqshift 2 & Variation de vitesse (différence dans le Ugen de variation)
							// Pour la variation de vistesse le LFDNoise a été modifié par un LFPar

							~synth =
							("SynthDef(\\BufSPitchVar2_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, stretcher= 1, center= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

/*SinOsc.ar(freqrate, 0, famp, 1), LFPar.ar(freqrate, 0, famp, 1)*/
/*SinOsc.ar(amprate, 0, aamp, 1), LFPar.ar(amprate, 0, aamp, 1)*/
bufRate = rater * BufRateScale.ir(bufm) * LFDNoise3.ar(freqrate, famp, 1);
bufFrames = offset * BufFrames.ir(bufm);

/*sig = PitchShift.ar(sig, 0.2, stretch * [0.25, 0.33], timeDispersion: 0.5, pitchDispersion: 0.5).sum;
sig = FreqShift.ar(sig, center * (1-stretch) - [200, 100, 50]).sum;*/

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);

/*src = [src1, src2];
src = PitchShift.ar(src, windowSize: psWindowSize, pitchRatio: stretcher * [0.25, 0.33], pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src = FreqShift.ar(src, center * (1-stretcher) - [200, 100, 50]) * LFDNoise3.ar(amprate, aamp, 1) * inBusVol * amp;*/

src1 = PitchShift.ar(src1, windowSize: psWindowSize, pitchRatio: stretcher * [0.25, 0.33], pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers).sum;
src2 = PitchShift.ar(src2, windowSize: psWindowSize, pitchRatio: stretcher * [0.25, 0.33], pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers).sum;
src1 = FreqShift.ar(src1, center * (1-stretcher) - [200, 100, 50]).sum;
src2 = FreqShift.ar(src2, center * (1-stretcher) - [200, 100, 50]).sum;
src = [src1, src2] * LFDNoise3.ar(amprate, aamp, 1) * inBusVol * amp;

"+~allSpas[4][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSPitchVar2 = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio'), // stretcher
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				/*if ( ~synthDefsBuild == 1, {
				( // juste pour recompiler un synthé XXXXXXXXX
				~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

				// Buffer Stéréo simple - BufRd - Version random sur la tête de lecture

				~synth =
				("SynthDef(\\BufSR_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rate= 1, /*offset= 0,*/ bufm, bufm2, /*trig,*/ loop= 0 |
				var src1, src2, src, bufRate1, bufRate2, bufFrames;
				"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

				bufRate1 = /*LFDNoise1*/ LFDNoise3.ar(rate * BufFrames.ir(bufm));
				bufRate2 = /*LFDNoise1*/ LFDNoise3.ar(rate * BufFrames.ir(bufm2));
				// bufFrames = offset * BufFrames.ir(bufm);

				src1 = BufRd.ar(1, bufm, bufRate1, loop, 4);
				src2 = BufRd.ar(1, bufm2, bufRate2, loop, 4);
				src = [src1, src2] * inBusVol * amp;

				"+~allSpas[3][indexS]+"
				})."++~synthDefsManagement);
				~synth.asCompileString.postln;
				~synth.interpret;

				}})});*/

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple - BufRd - Version avec ou sans random sur la tête de lecture

							~synth =
							("SynthDef(\\BufSR_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprateU= 1, preprate2U= 1, offset= 0, stretcherU= 1, stretcher2U=1, center= 1, bufm, bufm2, /*trig,*/ loop= 0 |
var src1, src2, src, bufRate1, bufRate2, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate1 = (Line.ar(preprateU, preprate2U, durenv) + LFDNoise3.ar(center, offset)).wrap(0,1) * BufFrames.ir(bufm);
bufRate2 = (Line.ar(stretcherU, stretcher2U, durenv) + LFDNoise3.ar(center, offset)).wrap(0,1) * BufFrames.ir(bufm2);
// bufFrames = offset * BufFrames.ir(bufm);

src1 = BufRd.ar(1, bufm, bufRate1, loop, 4);
src2 = BufRd.ar(1, bufm2, bufRate2, loop, 4);
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSR = [
					ControlSpec(0, 2, 'lin', 0.01, 1, '(U) Buf 1 Pos Start'), // preprateU
					ControlSpec(0, 2, 'lin', 0.01, 1, '(U) Buf 1 Pos End'), // preprate2U
					ControlSpec(0, 2, 'lin', 0.01, 1, '(U) Buf2 Pos Start'), // stretcherU
					ControlSpec(0, 2, 'lin', 0.01, 1, '(U) Buf 2 Pos End'), // stretcher2U
					ControlSpec(0, 10, 'lin', 0.01, 1, 'Rand Pos Freq Rate'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Mul Freq Rate'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple avec Roll / Stutter
							// a couple of my stock synthdefs (from the ddwChucklib quark) -> changement de Line en XLine
							// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Stutter-Effects-td3211350.html
							// voire aussi d'autres synthés -> http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/stutter-in-sc3-td7586504.html

							~synth =
							("SynthDef(\\BufSRoll_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, offRateSecondBuf= 1, bufm, bufm2, loop= 0, stretcher= 1, stretcher2= 1, centerU= 1 |
var src1, src2, src, bufRate, bufFrames, trigger, trigs, strokeEnv, attack, decay, strokesPerSec;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

attack = 0.002;
decay = 0.002;
strokesPerSec = Select.kr(centerU, [stretcher, Line.kr(stretcher, stretcher2, durenv)] );
// trigger = Impulse.ar(stretcher); // strokesPerSec
trigger = Impulse.ar(strokesPerSec);
trigs = PulseDivider.ar(trigger, 2, (0..1));
strokeEnv = EnvGen.ar(Env.linen(attack, strokesPerSec.reciprocal - attack - decay, decay), trigs);

bufRate = rater * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = (PlayBuf.ar(1, bufm, bufRate, trigs, bufFrames, loop) * strokeEnv).sum;
src2 = (PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trigs, bufFrames, loop) * strokeEnv).sum;
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSRoll = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate'), // rater
					nil, // rate2
					ControlSpec(0.1, 10, 'lin', 0.01, 1, 'Strokes Per Sec Start'), // stretcher
					ControlSpec(0.1, 10, 'lin', 0.01, 1, 'Strokes Per Sec End'), // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'CenterU - Switch Roll Line'), // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Warp0 Stéréo
							// Warp0.ar(numChannels, buffer, warpFactor, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add)
							// Def = pointer = LFSaw.kr( warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
							// Def = ^Warp1.ar(numChannels, buffer, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add);
							// Inspired by Chad Kirby's SuperCollider2 Warp1 class, which was inspired by Richard Karpen's sndwarp for CSound. A granular time strecher and pitchshifter.

							~synth =
							("SynthDef(\\WarpS_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, /*trig, loop= 0,*/ stretcher= 1, center= 440, psWindowSize= 0.2 /*, psTimeDispers= 0.05*/ |
var src1, src2, src, bufRate /*, bufFrames*/;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = rater * BufRateScale.ir(bufm);

// bufFrames = offset * BufFrames.ir(bufm);
// src = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

src1 = Warp0.ar(1, bufm, stretcher, bufRate, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4);
src2 = Warp0.ar(1, bufm2, stretcher, bufRate * offRateSecondBuf, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4);
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataWarpS = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale'), // rater
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor (Stretch / Compress)'), // stretcher
					nil, // stretcher2
					ControlSpec(1, 100, 'lin', 0.01, 8, 'Overlaps (de 1 à 100)'), // center.clip(1, 100)
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Window Rand Ratio'), // offset
				];










				// GRANULATOR

				// ~allSpas[0].collect {|itemS, indexS| ~allEnvs[0].collect {|item, index| // juste pour recompiler un synthé XXXXXXXXX

				// BufGrain (trigger, dur, sndbuf, rate, pos, interp, mul, add)

				/*
				~synth =
				("SynthDef(\\BufGrain_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| outL= 0, outR= 1, prepoutLU= 0, prepoutRU= 0, amp= 0.5, pan= 0, durenv= 1, atk= 0.1, rel= 0.1, width= 0.6, width2= 0.2, segs= 1000, endphase= 1000, rate= 1, offset= 0, bufm, trig, stretcher= 1, center= 1, busVolume= 100|
				var src1, triggerGrain, freq;
				"+~allEnvs[1][index]+"
				triggerGrain = Impulse.ar(stretcher.clip(0.1, 200));
				freq = rate + TRand.kr(0.0, 0.5, triggerGrain);
				src1 = BufGrain.ar(trigger: triggerGrain, dur: durenv / triggerGrain, sndbuf: bufm, rate: freq /** BufRateScale.ir(buf)*/, pos: offset, interp: 2) * In.kr(busVolume);
				"+~allSpas[1][indexS]+"
				}).add");
				~synth.asCompileString.postln;
				~synth.interpret;
				*/

				// }}; // juste pour recompiler un synthé XXXXXXXXX





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// GrainBuf (numChannels: 1, trigger: 0, dur: 1, sndbuf, rate: 1, pos: 0, interp: 2, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
							// 512 -> maxgrains -> maximum number of overlapping grains set at the UGens init time that can be used at a given time. This can be set lower for more efficient use of memory.
							// voire faire varier le buffer selon le grain ?????? - quel contrôle envisager pour la variation ??????

							// La spatialisation est intégrée dans le pattern et non pas à l'intérieur du UGen
							// voire utilisation d'un Buffer stéréo avec 2 GrainBuf pour faire varier la spatialisation dans le UGen aussi ??????
							// No panning puisque numChannels est = 1
							// Pan - If numChannels = 1, no panning is done. Best way ??????
							// Pan - If numChannels = 2, panning is similar to Pan2.
							// Pan - If numChannels > 2, panning is the same as PanAz.

							~synth =
							("SynthDef(\\GrainBuf_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, bufm, /*trig,*/ stretcher= 1, center= 1, stretcher2= 1 |
var src1, grain, triggerGrain, freq, freqVar;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

grain = preprate.clip(0.1, 200);
triggerGrain = /*Impulse.kr(grain)*/ Dust.kr(grain); // voire intéret entre Impulse.kr & .ar & possibilité de swithcher avec Dust ???

freq = stretcher * BufRateScale.ir(bufm) /*+ TRand.kr(0.0, 0.5, triggerGrain)*/;
// Auparavant utilisation du TRand [+ ou x TRand.kr(0.0, 0.5, triggerGrain)] afin de faire varier constamment la vitesse de lecture selon le grain

src1 = GrainBuf.ar(numChannels: 1,
trigger: triggerGrain,
dur: durenv / triggerGrain * stretcher2.clip(0.1,20),
sndbuf: bufm,
rate: LFNoise2.ar(center).range(freq, (freq * 3)),
pos: LFNoise2.kr(offset*100).range(0, 1),
interp: 2, /*pan: pan,*/ envbufnum: -1, maxGrains: 512) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataGrainBuf = [
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain (de 0.1 à 200) that also determine Grain Duration'), // preprate
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Base Rate (Variation to x3)'), // stretcher - range de la variation de la vitesse de lecture (de rate à rate * 3)
					ControlSpec(0, 4, 'lin', 0.01, 1, 'Relative Grain Duration (de 0.1 à 20)'), // stretcher2.clip(0.1,20)
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Rate Mod Speed'), // center - fréquence du changement aléatoire (LFNoise2) pour changer la vitesse de lecture
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Offset Mod Speed (de 0 à 100 Hz)') // offset - fréquence du changement aléatoire (LFNoise2) pour changer la playback position
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// ConcatBuf (control, source, storesize: 1, seektime: 1, seekdur: 1, matchlength: 0.05, freezestore: 0, zcr: 1, lms: 1, sc: 1, st: 0, randscore: 0, threshold: 0.01, mul: 1, add: 0) de l'exemple Granulator de Concat2

							// rater -> Vitesse de lecture
							// stretcher -> matchlength
							// center -> zcr

							~synth =
							("SynthDef(\\ConcatBufSig_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 1, stretcherU= 1, centerU= 1 |
var src1, control, input;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// control = Saw.ar(SinOsc.kr(LFNoise0.kr(MouseY.kr(0.01 ,1), 3, 4. 5), 0, 10, MouseY.kr(12, 100)));
control = Saw.ar(SinOsc.kr(LFNoise0.kr(centerU.max(0.01), 3, 4.5), 0, 10, centerU.linlin(0, 1, 12, 100)));

// input = PlayBuf.ar(1, bufm, BufRateScale.kr(bufm), loop: 1);
input = PlayBuf.ar(1, bufm, rater * BufRateScale.ir(bufm), trig, offset * BufFrames.ir(bufm), loop);

// src1 = Concat2.ar(control, input, 2.0, 2.0, 2.0, MouseX.kr(0.01,0.1), 0, MouseY.kr(0.0,1.0), 1.0, 0.5) !2;
src1 = Concat2.ar(control, input, 2.0, 2.0, 2.0, stretcherU.linlin(0, 1, 0.01, 1), 0, centerU, 1.0, 0.5) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// ConcatBuf (control, source, storesize: 1, seektime: 1, seekdur: 1, matchlength: 0.05, freezestore: 0, zcr: 1, lms: 1, sc: 1, st: 0, randscore: 0, threshold: 0.01, mul: 1, add: 0) de l'exemple Granulator de Concat2

							// prepbufU / prepbuf / bufs / (bufm) -> buf input
							// offsetU / (offset) -> offset buf (≠ entre offsetU et offset ?)
							// preprateU / preprate / (rate) -> buf rate
							// stretcherU / stretcher -> matchlength (Match length in seconds (this will be rounded to the nearest FFT frame)
							// centerU / center -> zcr (Weight for zero crossing rate feature)

							~synth =
							("SynthDef(\\ConcatBufIn_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 1, stretcherU= 1, centerU= 1 |
var src1, control, input;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// control = Saw.ar(SinOsc.kr(LFNoise0.kr(MouseY.kr(0.01 ,1), 3, 4. 5), 0, 10, MouseY.kr(12, 100)));
control= SoundIn.ar(~soundIn);

// input=PlayBuf.ar(1, bufnum,BufRateScale.kr(bufnum), loop: 1);
input = PlayBuf.ar(1, bufm, rater * BufRateScale.ir(bufm), trig, offset * BufFrames.ir(bufm), loop);

// src1 = Concat2.ar(control, input, 2.0, 2.0, 2.0, MouseX.kr(0.01,0.1), 0, MouseY.kr(0.0,1.0) ,1.0 ,0.5) !2;
// src1 = Concat2.ar(control, input, 1.0, 1.0, 1.0, matchlength, freeze, 0.0, 1.0, 0.0, 0.0);
src1 = Concat2.ar(control, input, 2.0, 2.0, 2.0, stretcherU.linlin(0,1,0.01,1), 0, centerU, 1.0, 0.5) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});










				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// ConcatBuf (control, source, storesize: 1, seektime: 1, seekdur: 1, matchlength: 0.05, freezestore: 0, zcr: 1, lms: 1, sc: 1, st: 0, randscore: 0, threshold: 0.01, mul: 1, add: 0) de l'exemple Granulator de Concat2

							// prepbufU / prepbuf / bufs / (bufm) -> ?
							// offsetU / (offset) -> ? (≠ entre offsetU et offset ?)
							// preprateU / preprate / (rate) -> buf rate
							// stretcherU / stretcher -> matchlength (Match length in seconds (this will be rounded to the nearest FFT frame)
							// centerU / center -> zcr (Weight for zero crossing rate feature)

							~synth =
							("SynthDef(\\ConcatInSig_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, offset= 0, bufm, trig, loop= 1, stretcherU= 1, centerU= 1, inBusVolume= 99 |
var src1, control, input, inRBusVol;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// control = Saw.ar(SinOsc.kr(LFNoise0.kr(MouseY.kr(0.01 ,1), 3, 4. 5), 0, 10, MouseY.kr(12, 100)));
control = SinOsc.ar(0.5)*Saw.ar(SinOsc.kr(LFNoise0.kr(MouseY.kr(0.01,1),3,4.5),0,50,MouseY.kr(120,500)));
// control = SoundIn.ar;

// input = PlayBuf.ar(1, bufnum,BufRateScale.kr(bufnum), loop: 1);
// input = PlayBuf.ar(1, bufm, rater * BufRateScale.ir(bufm), trig, offset * BufFrames.ir(bufm), loop);
inRBusVol = In.kr(inBusVolume);
input = SoundIn.ar(~soundIn) * inRBusVol;

// src1 = Concat2.ar(control, input, 2.0, 2.0, 2.0, MouseX.kr(0.01,0.1), 0, MouseY.kr(0.0,1.0) ,1.0 ,0.5) !2;
// src1 = Concat2.ar(control, input, 4.0, 4.0, 4.0, MouseX.kr(0.0, 0.5), 0, 0.5, 1.0, 0.5, 0.0);
// src1 = Concat2.ar(control, input, 1.0, 1.0, 1.0, matchlength, freeze, 0.0, 1.0, 0.0, 0.0);
src1 = Concat2.ar(control, input, 4.0, 4.0, 4.0, stretcherU, 0, centerU, 1.0, 0.5) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// GrainIn avec entrée micro mono (numChannels: 1, trigger: 0, dur: 1, in, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
							// AudioIn may be deprecated in the future
							// 512 -> maxgrains -> maximum number of overlapping grains set at the init time that can be used at a given time. This can be set lower for more efficient use of memory.

							// preprate -> Nothing
							// stretcher -> Nothing
							// center -> trigger (de 0.1 à 200) & impact sur la durée du grain
							// offset -> Nothing

							// La spatialisation est intégrée dans le pattern et non pas à l'intérieur du UGen
							// Pan - If numChannels = 1, no panning is done. Best way ???
							// Pan - If numChannels = 2, panning is similar to Pan2.
							// Pan - If numChannels > 2, pannins is the same as PanAz.

							~synth =
							("SynthDef(\\GrainIn_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, stretcher= 1, center= 1, inBusVolume= 99 |
var grain, triggerGrain, src1, inRBusVol;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

grain = preprate.clip(0.1, 200);
triggerGrain = Impulse.kr(grain); // voire intéret entre Impulse.kr & .ar & possibilité de swithcher avec Dust ???

inRBusVol = In.kr(inBusVolume);
src1 = SoundIn.ar(~soundIn) * inRBusVol;
src1 = GrainIn.ar(numChannels: 1, trigger: triggerGrain, dur: durenv / grain * stretcher.clip(0.1,20), in: src1, envbufnum: /*j*/ -1, maxGrains: 512) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataGrainIn = [
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain (de 0.1 à 200) that also determine Grain Duration'), // preprate
					nil, // rate2
					ControlSpec(0, 4, 'lin', 0.01, 1, 'Relative Grain Duration (de 0.1 à 20)'), // stretcher.clip(0.1,20)
					nil, // stretcher2
					nil, // center
					nil, // center2
					nil // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// WarpIn avec entrée micro mono
							// AudioIn may be deprecated in the future

							~synth =
							("SynthDef(\\WarpIn_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, stretcher= 1, center= 1, psWindowSize= 0.2, /*psTimeDispers= 0.05,*/ inBusVolume= 99 |
var src1, inRBusVol;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

inRBusVol = In.kr(inBusVolume);
src1 = SoundIn.ar(~soundIn) * inRBusVol;
src1 = WarpIn.ar(src1, ~bufEmpty"++[serverNb]++".bufnum, warpFactor: stretcher, freqScale: preprate, windowSize: psWindowSize, envbufnum: -1, overlaps: center.clip(1, 100) /*8*/, windowRandRatio: offset /*psTimeDispers*/, interp: 4) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataWarpIn = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale'), // preprate
					nil, // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor (Stretch / Compress)'), // stretcher
					nil, // stretcher2
					ControlSpec(1, 100, 'lin', 0.01, 8, 'Overlaps (de 1 à 100)'), // center.clip(1, 100)
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Window Rand Ratio') // offset
				];










				// Synthèse pure

				// Sinus simple (redondant avec SinOscFB et économise peu de CPU vs SinOscFB) (freq: 440, iphase: 0, mul: 1, add: 0)

				// preprate.clip(0,127).midicps -> freq
				// stretcher -> Nothing
				// center -> Nothing
				// offset -> Nothing

				/*
				~synth =
				("SynthDef(\\Sine_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs++" preprate= 60, offset= 0 |
				"+~allEnvs[1][index]+"
				var freq = preprate.clip(0,127).midicps;
				var amp2 = AmpCompA.kr(freq) * 0.1;
				var src1 = FSinOsc.ar(freq, 0, amp2) * In.kr(busVolume);
				"+~allSpas[1][indexS]+"
				}).add");
				~synth.asCompileString.postln;
				~synth.interpret;
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// SinOscFB (freq: 440, feedback: 0, mul: 1, add: 0)
							// is a sine oscillator that has phase modulation feedback; its output plugs back into the phase input. Basically this allows a modulation between a sine wave and a sawtooth like wave. Overmodulation causes chaotic oscillation. It may be useful if you want to simulate feedback FM synths.
							// Rajouter des delays pour l'amplifier ???
							// AmpCompA ou AmpComp pour compenser l'amplitude des hautes fréquences
							// & Amp * 0.15 pour normaliser les amps selon les synthés (à corriger ???)

							~synth =
							("SynthDef(\\SineFB_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", center= 60, offset= 0 |
var src1, freq, amp2;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

freq = center.min(127).midicps;
amp2 = AmpCompA.kr(freq) * 0.15;

src1 = SinOscFB.ar(freq, ((offset * 5).exp) -1 /*offset.linlin(0,1,0,2pi)*/, amp2) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataSineFB = [
					nil, // preprate
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					ControlSpec(36, 84, 'lin', 0.01, 60, 'Midi Freq'), // center.min(127).midicps - 4 octaves
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Feedback : ((offset * 5).exp) -1) - de 0 à 148') // offset - variété de sons plus importante que le range en radian
				];

				// basic usage without adding a delay line: self-modulating sine wave.
				/*
				(
				{
				var fbNode = FbNode(1);
				var signal = SinOsc.ar(100, fbNode * MouseX.kr(0,2) );
				// the FbNode is used to modulate the SinOsc's phase

				fbNode.write(signal);
				signal ! 2;
				}.play;
				)
				*/





				// voire l'intégration d'un PitchShift à Blip comme dans l'exemple de PitchShift
				/*
				(
				play({
				z = Blip.ar(800, 6, 0.1);
				PitchShift.ar(z, 0.02, Line.kr(0.1,4,20), 0, 0.0001)
				}))
				*/

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Blip (freq: 440, numharm: 200, mul: 1, add: 0)
							// Band Limited ImPulse generator. All harmonics have equal amplitude. This is the equivalent of 'buzz' in MusicN languages.
							// Rajouter des delays pour l'amplifier ???
							// AmpCompA ou AmpComp pour compenser l'amplitude des hautes fréquences - pas utilisé  ???
							// & Amp * 0.15 pour normaliser les amps selon les synthés (à corriger ???)

							~synth =
							("SynthDef(\\Blip_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", center= 60, offset= 0 |
var src1, freq;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

freq = center.min(127).midicps;
// var amp2 = AmpCompA.kr(freq) * 0.2;

src1 = Blip.ar(freq, (offset * 200).max(1), 0.15) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBlip = [
					nil, // preprate
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					ControlSpec(36, 84, 'lin', 0.01, 60, 'Midi Freq'), // center.min(127).midicps - 4 octaves
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Nb of Harmonics (de 1 à 200)') // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// PMOsc (Phase modulation sine oscillator pair) (carfreq, modfreq, pmindex: 0, modphase: 0, mul: 1, add: 0)
							// AmpCompA ou AmpComp pour compenser l'amplitude des hautes fréquences - pas utilisé  ???
							// & Amp * 0.08 pour normaliser les amps selon les synthés (à corriger ???)

							~synth =
							("SynthDef(\\PMOsc_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, stretcher= 1, center= 1 |
var src1;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

src1 = PMOsc.ar(preprate.min(127).midicps, stretcher.min(127).midicps, center, offset /*((offset * 5).exp) -1*/, 0.08) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataPMOsc = [
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Car Freq'), // preprate.min(127).midicps
					nil, // rate2
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Mod Freq'), // stretcher.min(127).midicps
					nil, // stretcher2
					ControlSpec(0, 127, 'lin', 0.01, 1, 'PM Index'), // center - Modulation index in radians ???
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Mod Phase') // offset - A modulation input for the modulator's phase in radians - pas d'effet puisque pas de changement dynamique
					// -> à moduler par un oscillateur chaotique XXXXXXXXX
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// GrainSin (numChannels: 1, trigger: 0, dur: 1, freq: 440, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
							// & Amp * 0.5 pour normaliser les amps selon les synthés (à corriger ???)
							// 512 -> maxgrains -> maximum number of overlapping grains set at the UGens init time that can be used at a given time. This can be set lower for more efficient use of memory.

							// La spatialisation est intégrée dans le pattern et non pas à l'intérieur du UGen
							// Pan - If numChannels = 1, no panning is done. Best way ???
							// Pan - If numChannels = 2, panning is similar to Pan2.
							// Pan - If numChannels > 2, pannins is the same as PanAz.

							~synth =
							("SynthDef(\\GrainSin_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, stretcher= 1, center= 1 |
var src1, grain, triggerGrain, freq, freqVar, amp2;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

grain = preprate.clip(0.1, 200);
triggerGrain = Impulse.kr(grain); // voire intéret entre Impulse.kr & .ar & possibilité de swithcher avec Dust ???

// freq = (center + 5.rand2).clip(0, 127).midicps; // valeur aléatoire juste à l'initialisation
// freqVar = TRand.kr(0.0, 24, triggerGrain);
freqVar = WhiteNoise.kr(24);

freq = (center + (freqVar * offset)).min(127).midicps;
amp2 = AmpCompA.kr(freq) * 0.5;

src1 = GrainSin.ar(numChannels: 1, trigger: triggerGrain, dur: durenv / grain * stretcher.clip(0.1,20), freq: freq, envbufnum: /*j*/ -1, maxGrains: 512) * amp2 * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataGrainSin = [
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain (de 0.1 à 200)'), // preprate - that also determine Grain Duration
					nil, // rate2
					ControlSpec(0, 4, 'lin', 0.01, 1, 'Relative Grain Duration (de 0.1 à 20)'), // stretcher.clip(0.1,20)
					nil, // stretcher2
					ControlSpec(36, 84, 'lin', 0.01, 60, 'Midi Freq Base'), // center.min(127).midicps - 4 octaves
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Freq Variation Depth (de 0 à 24 demi-tons)') // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// GrainFM (numChannels: 1, trigger: 0, dur: 1, carfreq: 440, modfreq: 200, index: 1, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
							// & Amp * 0.2 pour normaliser les amps selon les synthés (à corriger ???)
							// 512 -> maxgrains -> maximum number of overlapping grains set at the UGens init time that can be used at a given time. This can be set lower for more efficient use of memory.

							// La spatialisation est intégrée dans le pattern et non pas à l'intérieur du UGen
							// Pan - If numChannels = 1, no panning is done. Best way ???
							// Pan - If numChannels = 2, panning is similar to Pan2.
							// Pan - If numChannels > 2, pannins is the same as PanAz.

							~synth =
							("SynthDef(\\GrainFM_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, offset= 0, stretcher= 1, center= 1, rate2= 1, stretcher2U= 1, center2U= 1 |
var src1, grain, triggerGrain, cFreq, mFreq, cFreqVar, mFreqVar, amp2;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

grain = preprate.clip(0.1, 200);
triggerGrain = Impulse.kr(grain); // voire intéret entre Impulse.kr & .ar & possibilité de swithcher avec Dust ???

cFreqVar = WhiteNoise.kr(24);
mFreqVar = WhiteNoise.kr(24);

cFreq = (stretcher + (cFreqVar * stretcher2U)).min(127).midicps;
mFreq = (center + (mFreqVar * center2U)).min(127).midicps;
amp2 = AmpCompA.kr(cFreq) * 0.2; // intérêt ???

src1 = GrainFM.ar(numChannels: 1, trigger: triggerGrain, dur: durenv / grain * rate2.clip(0.1,20), carfreq: cFreq, modfreq: mFreq, index: (offset * 200).max(1), envbufnum: /*j*/ -1, maxGrains: 512) * amp2 * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataGrainFM = [
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain (de 0.1 à 200)'), // preprate - that also determine Grain Duration
					ControlSpec(0, 4, 'lin', 0.01, 1, 'Relative Grain Duration (de 0.1 à 20)'), // rate2.clip(0.1,20)
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Car Freq Base'), // stretcher.min(127).midicps
					ControlSpec(0, 1, 'lin', 0.01, 0, '(U) Car Freq Variation Depth (de 0 à 24 demi-tons)'), // stretcher2U -> voire l'utilité d'utiliser stretcher avec les rangeSliders de 0 à 24 ?????????
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Mod Freq Base'), // center.min(127).midicps
					ControlSpec(0, 1, 'lin', 0.01, 0, '(U) Mod Freq Variation Depth (de 0 à 24 demi-tons)'), // center2U -> voire l'utilité d'utiliser center avec les rangeSliders de 0 à 24 ?????????
					ControlSpec(0, 1, 'lin', 0.01, 1, 'Mod Index (de 0 à 200)') // offset.max(1)
				];










				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// UpPiano - à explorer & améliorer - see below
							// & Amp * 0.08 pour normaliser les amps selon les synthés (à corriger ???)

							// n_set not found avec UpPiano & AcidOto avec l'ambisonique et adaptime = 1 ????????? -> retiré en remplacant le gate ???

							~synth =
							("SynthDef(\\UpPiano_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", center= 60 /*, gate=1*/ |
var src1, lfo, mod1, mod2, mod3, burstEnv, burst, atk2, rateClip;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

rateClip = center.min(127).midicps;
lfo = LFNoise2.kr(30, /*amp * */rateClip, /*amp * */rateClip);
mod1 = SinOsc.ar( rateClip * 3.01, 0, rateClip);
mod2 = SinOsc.ar( rateClip * 4, 0, lfo);
mod3 = SinOsc.ar( rateClip * 2 + mod1, 0, 200);
burstEnv = Env.perc(0, 0.01);
burst = WhiteNoise.ar * EnvGen.kr(burstEnv);
atk2 = RLPF.ar(
CombC.ar(burst, rateClip.reciprocal, rateClip.reciprocal, -1, 1),
6800, 3, amp
);
src1 = SinOsc.ar(rateClip + mod2 + mod3, 0, 0.08, atk2).softclip * inBusVol * amp * 1.5;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataUpPiano = [
					nil, // preprate
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					ControlSpec(36, 84, 'lin', 0.01, 60, 'Midi Freq'), // -> center.min(127).midicps - 4 octaves
					nil, // center2
					nil // offset
				];

				// sound designed by umbrella_process (see up-piano-11-2 by Takuro_Hishikawa in SC Book Japan)
				// "I love delicate, shimmered sound".
				// Pas super adapté pour un pattern
				// To check -> FAILURE /n_set Node not found & attention aux sons trop aigus
				/*
				SynthDef("uppiano", {
				arg rate=440, gate=1, amp=1, pan=0.5, durenv= 0.1, atk= 0.01, rel= 0.1, outL= 0, outR= 1;
				var x, lfo, mod1, mod2, mod3, env, burstEnv, burst, atk2;
				// env = Env.adsr(0.01,0.2,0.5,1,1,-4); // changement pour adaptation au pattern - à améliorer
				env = EnvGen.ar(Env.linen(atk, durenv-atk-rel, rel, amp), doneAction:2);
				lfo = LFNoise2.kr(30, amp * rate.midicps, amp * rate.midicps);
				mod1 = SinOsc.ar( rate.midicps * 3.01, 0, rate);
				mod2 = SinOsc.ar( rate.midicps * 4, 0, lfo);
				mod3 = SinOsc.ar( rate.midicps * 2 + mod1, 0, 200);
				burstEnv = Env.perc(0, 0.01);
				burst = WhiteNoise.ar * EnvGen.kr(burstEnv);
				atk2 = RLPF.ar(
				CombC.ar(burst, rate.midicps.reciprocal, rate.midicps.reciprocal, -1, 1),
				6800, 3, amp
				);
				x = SinOsc.ar(rate.midicps + mod2 + mod3, 0, amp, atk).softclip;
				// x = EnvGen.kr(env,gate,doneAction: 2) * x;
				// Out.ar(outBus, Pan2.ar(x,pan)); // changement pour adaptation au pattern - à améliorer
				x = Pan2.ar(x*env, pan);
				OffsetOut.ar(outL, x[0]);
				OffsetOut.ar(outR, x[1]);
				}).add;

				a= Synth("uppiano");
				a.set(\gate, 1);
				a.set(\gate, 0);
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Acid
							// n_set not found avec UpPiano & AcidOto avec l'ambisonique et adaptime = 1 ????????? -> retiré en remplacant le gate par 1 ???

							~synth =
							("SynthDef(\\AcidOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", center= 1 /*, gate = 1*/ |
// var env1, env2, son, pitch;
var env2, src1, pitch;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
pitch = center.min(88); // car peut provoquer des explosions sonores au delà de 90 - Pourquoi cette limite - varie selon les durées ?????????
pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(/*gate*/ 1, 0.001)) * /*gate*/ 1);
// env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), /*gate*/ 1, amp);
// Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2).plot
env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), /*gate*/ 1, /*levelScale: amp.min(0.9),*/ timeScale: spadur); // protection de l'amp sinon explosions sonore au delà de 0.9 ?????????
src1 = LFPulse.ar(pitch.midicps, 0.0, 0.51, 2, -1);

src1 = RLPF.ar(src1, (pitch + env2).midicps, 0.3);
src1 = src1 * inBusVol * amp * 0.1;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataAcidOto = [
					nil, // preprate
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					ControlSpec(24, 72, 'lin', 0.01, 48, 'Midi Freq'), // center.min(127).midicps - 4 octaves
					nil, // center2
					nil // offset
				];

				/*
				SynthDef("acid_oto309", {
				arg out=0, gate=1, freq=440, amp=0.1, pan=0;
				var env1, env2, son, pitch;
				pitch = freq.cpsmidi;
				pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
				env1 = EnvGen.ar(Env.new([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp);
				env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
				son = LFPulse.ar(pitch.midicps, 0.0, 0.51, 2, -1);

				son = RLPF.ar(son, (pitch + env2).midicps, 0.3);
				son = son * env1;

				Out.ar(out, Pan2.ar(son, pan));
				},
				metadata: (
				credit: "from 08091500Acid309 by_otophilia",
				tags: [\pitched, \acid, \phat, \subtractive]
				))
				*/






				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// String

							~synth =
							("SynthDef(\\StringOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", center= 1, trig= 1 |
// var output, string, excite;
var src1, string, excite, clipRate, eAtk=0.01, eDec=0.02, damp=8;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
clipRate = center.min(127).midicps;
excite = GrayNoise.ar(
EnvGen.ar( Env.perc(eAtk, eDec / clipRate, 1, -4), trig)
);

string = CombC.ar(excite, 0.1, clipRate.reciprocal, spadur);
string = string.clip2(1);

src1 = string;
src1 = LPF.ar(src1, EnvGen.ar( Env.perc(0, spadur, 1, -6), trig, 60, clipRate + damp).midicps.min(SampleRate.ir/2));
src1 = src1.softclip * inBusVol * amp * 0.2;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataStringOto = [
					nil, // preprate
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					ControlSpec(36, 84, 'lin', 0.01, 60, 'Midi Freq'), // center.min(127).midicps - 4 octaves
					nil, // center2
					nil // offset
				];

				// Guitar => String + Amp Simulator
				/*
				~synth =
				("SynthDef(\\Guit_Oto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| outL= 0, outR= 1, prepoutLU=0, prepoutRU=0, amp= 0.5, pan= 0, panL= 1, panR= -1, durenv= 1, atk= 0.1, rel= 0.1, width= 0.6, width2= 0.2, rate= 1, trig= 1|
				// var output, string, excite;
				var src1, string, excite, clipRate, eAtk=0.01, eDec=0.02, damp=8;

				"+~allEnvs[1][index]+"
				clipRate = rate.clip(36,84).midicps;
				excite = GrayNoise.ar(
				EnvGen.ar( Env.perc(eAtk, eDec / clipRate, 1, -4), trig)
				);

				string = CombC.ar(excite, 0.1, clipRate.reciprocal, spadur);
				string = string.clip2(1);

				src1 = string;
				src1 = LPF.ar(src1, EnvGen.ar( Env.perc(0, spadur, 1, -6), trig, 60, clipRate + damp).midicps.min(SampleRate.ir/2));

				src1 = Compander.ar(src1, src1, 0.5, 1, 0.2, 0.01, 0.01); // ????????????????????????????? - pourquoi 2 source ????????????????
				src1 = HPF.ar(src1, 100, 1) + RHPF.ar(src1, 7140, 0.3, 0.1);
				src1 = RLPF.ar(src1, 2650, 0.3, 12.0);
				src1 = src1.softclip;
				src1 = RLPF.ar(src1, 4720, 0.3, 0.6);
				src1 = BPF.ar(src1, 3800, 0.3, 0.6, src1);
				5.do{|i|
				thisThread.randSeed = 1220;
				src1 = src1 + AllpassL.ar(src1, 0.03, [exprand(0.01, 0.02),exprand(0.01, 0.02),], 0.02, 0.05)
				};

				src1 = HPF.ar(src1, 100, 1.0);
				src1 = HPF.ar(src1, 7000, 0.5, src1);

				src1 = Limiter.ar(src1, 1, 0.002);

				src1 = (src1.softclip /** amp*/);

				"+~allSpas[1][indexS]+"
				}).add");
				~synth.asCompileString.postln;
				~synth.interpret;
				*/

				// cf GoodNoseGUI in SC Book Japan

				/*
				SynthDef(\string, {
				arg outBus=0, amp=1.0,
				trig=0, pitch=60, damp=8, decay=2.0, eAtk=0.01, eDec=0.02;
				var output, string, excite;

				excite = GrayNoise.ar(
				EnvGen.ar( Env.perc(eAtk, eDec / pitch.midicps, 1, -4), trig)
				);

				string = CombC.ar(excite, 0.1, pitch.midicps.reciprocal, decay);
				string = string.clip2(1);

				output = string;
				output = LPF.ar(output, EnvGen.ar( Env.perc(0, decay, 1, -6), trig, 60, pitch + damp).midicps.min(SampleRate.ir/2));
				output = output.softclip * amp;

				Out.ar(outBus, output);
				}, [nil, nil, \tr]).send(s);

				SynthDef(\ampSimulator, {
				arg inBus=0, outBus=0, amp=1.0;
				var output, hpf;
				output = In.ar(inBus, 1);
				output = Compander.ar(output, output, 0.5, 1, 0.2, 0.01, 0.01);
				output = HPF.ar(output, 100, 1) + RHPF.ar(output, 7140, 0.3, 0.1);
				output = RLPF.ar(output, 2650, 0.3, 12.0);
				output = output.softclip;
				output = RLPF.ar(output, 4720, 0.3, 0.6);
				output = BPF.ar(output, 3800, 0.3, 0.6, output);
				5.do{|i|
				thisThread.randSeed = 1220;
				output = output + AllpassL.ar(output, 0.03, [exprand(0.01, 0.02),exprand(0.01, 0.02),], 0.02, 0.05)
				};

				output = HPF.ar(output, 100, 1.0);
				output = HPF.ar(output, 7000, 0.5, output);

				output = Limiter.ar(output, 1, 0.002);

				Out.ar(outBus, output);
				}).send(s);
				*/










				// Drum Kit by otophilia

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Kick (utilisation de l'agument preprate car 1 rate négatif rend l'amplitude incontrolable -> spectre saturé)

							~synth =
							("SynthDef(\\KikOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1 |
var src1, env1, env1m;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
// env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2); // env0 substituée par env
// Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]).plot

env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
// Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]).plot
env1m = env1.midicps * preprate.min(10);

src1 = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
src1 = src1 + WhiteNoise.ar(1);
src1 = LPF.ar(src1, env1m * 1.5);
src1 = src1 + SinOsc.ar(env1m, 0.5);

// src1 = src1 * 1.2 * amp;
// src1 = {src1.clip2(1)};
src1 = src1.clip2(1) * inBusVol * amp * 0.5;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataKikOto = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Mul Freq (max 10)'), // preprate.min(10)
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center2
					nil, // center2
					nil // offset
				];

				/*
				SynthDef("kick", {
				arg outBus=0, amp;
				var env0, env1, env1m, out;

				env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
				env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
				env1m = env1.midicps;

				out = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
				out = out + WhiteNoise.ar(1);
				out = LPF.ar(out, env1m*1.5, env0);
				out = out + SinOsc.ar(env1m, 0.5, env0);

				out = out * 1.2 * amp;
				out = out.clip2(1);

				Out.ar(outBus, out.dup);
				}).add;
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Snare (utilisation de l'agument preprate car 1 rate négation rend l'amplitude incontrolable -> spectre saturé)

							~synth =
							("SynthDef(\\SnareOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1 |
// var env0, env1, env2, env1m, oscs, noise, out;
var src1, env1, env0, env1m, oscs, noise;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]), timeScale: spadur);
env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
env1m = env1.midicps * preprate.min(10);
// env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
oscs = LPF.ar(oscs, env1m * 1.2, env0);
oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

noise = WhiteNoise.ar(0.2);
noise = HPF.ar(noise, 200, 2);
noise = BPF.ar(noise, 6900, 0.6, 3) + noise;

src1 = oscs + noise;
src1 = src1.clip2(1) * inBusVol * amp * 0.2;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataSnareOto = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Mul Freq (max 10)'), // preprate.min(10)
					nil, // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center2
					nil, // center2
					nil // offset
				];

				/*
				SynthDef("snare", {
				arg outBus=0, amp=0.8;
				var env0, env1, env2, env1m, oscs, noise, out;

				env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
				env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
				env1m = env1.midicps;
				env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

				oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
				oscs = LPF.ar(oscs, env1m*1.2, env0);
				oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

				noise = WhiteNoise.ar(0.2);
				noise = HPF.ar(noise, 200, 2);
				noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
				noise = noise * env2;

				out = oscs + noise;
				out = out.clip2(1) * amp * -3.dbamp;

				Out.ar(outBus, out.dup);
				}).add;
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Clap
							// Pourquoi env1 n'a pas de doneAction ? Env2 ayant un doneAction & étant plus long arrête toute la synthèse ???
							// Quel paramètre à moduler avec rat, str, cen, buf, off ???

							~synth =
							("SynthDef(\\ClapOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++" /*preprate= 1*/ |
// var env1, env2, out, noise1, noise2;
var env1, env2, src1, noise1, noise2;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]), timeScale: spadur);
env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), timeScale: spadur, doneAction:2);

noise1 = WhiteNoise.ar(env1);
noise1 = HPF.ar(noise1, 600);
noise1 = BPF.ar(noise1, 2000, 3);

noise2 = WhiteNoise.ar(env2);
noise2 = HPF.ar(noise2, 1000);
noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

src1 = noise1 + noise2;
src1 = src1 * 2;
src1 = src1.softclip * -6.dbamp * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				/*
				SynthDef("clap", {
				arg outBus=0, amp = 0.5;
				var env1, env2, out, noise1, noise2;

				env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
				env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

				noise1 = WhiteNoise.ar(env1);
				noise1 = HPF.ar(noise1, 600);
				noise1 = BPF.ar(noise1, 2000, 3);

				noise2 = WhiteNoise.ar(env2);
				noise2 = HPF.ar(noise2, 1000);
				noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

				out = noise1 + noise2;
				out = out * 2;
				out = out.softclip * amp * -6.dbamp;

				Out.ar(outBus, out.dup);
				}).add;
				*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Hat

							~synth =
							("SynthDef(\\HatOto_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++" /*preprate= 1*/ |
// var env1, env2, out, oscs1, noise, n, n2;
var env1, env2, src1, oscs1, noise, n, n2;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"
n = 5;
thisThread.randSeed = 4;

env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]), timeScale: spadur);
env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), timeScale: spadur, doneAction:2);

oscs1 = Mix.fill(n, {|i|
SinOsc.ar(
( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
1/n
)
});

oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
n2 = 8;
noise = WhiteNoise.ar;
noise = Mix.fill(n2, {|i|
var freq;
freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
CombN.ar(noise, 0.04, freq, 0.1)
}) * (1/n) + noise;
noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
noise = BLowShelf.ar(noise, 3000, 0.5, -6);
noise = BHiPass.ar(noise, 1000, 1.5, env2);

src1 = noise + oscs1;
src1 = src1.softclip;
src1 = src1 * -9.dbamp * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				/*
				SynthDef("hat", {
				arg outBus=0, amp=0.3;
				var env1, env2, out, oscs1, noise, n, n2;

				n = 5;
				thisThread.randSeed = 4;

				env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
				env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:2);

				oscs1 = Mix.fill(n, {|i|
				SinOsc.ar(
				( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
				SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
				1/n
				)
				});

				oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
				n2 = 8;
				noise = WhiteNoise.ar;
				noise = Mix.fill(n2, {|i|
				var freq;
				freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
				CombN.ar(noise, 0.04, freq, 0.1)
				}) * (1/n) + noise;
				noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
				noise = BLowShelf.ar(noise, 3000, 0.5, -6);
				noise = BHiPass.ar(noise, 1000, 1.5, env2);

				out = noise + oscs1;
				out = out.softclip;
				out = out * amp * -9.dbamp;

				Out.ar(outBus, out.dup);
				}).add;
				*/










				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// SynthDef inspired by Korg Electribe ER-1 (voire tests dans fichier SynthDefs)
							// 38nonprivate@durftal.com nov 2009
							// http://dane.sound.pl/prod/3232/er1.jpg

							~synth =
							("SynthDef(\\Electribe_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, gate = 1, offset= 0, stretcher= 1, stretcher2= 1, center= 1, center2= 1 |

var freq, src1, modEnvGen, /*ampEnvGen,*/ pitchMod, white, waveFreq;

"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

freq = center.midicps * preprate;
white = WhiteNoise.ar;
modEnvGen = EnvGen.kr(Env.perc(0.0001, center2.reciprocal, 1, -6), gate);

pitchMod =
LinSelectX.kr(stretcher/*.round(1)*//*.clip(0,6)*/, // voire impact de LinSelectX.kr - Select.kr à l'origine ???
// voire si SelectXFocus peut s'avérer plus intéressant en modifiant le focus ???
[
LFSaw.ar(center2),
LFPulse.ar(center2),
LFTri.ar(center2),
Latch.ar(white, Impulse.ar(center2)),
white,
white * modEnvGen,
modEnvGen
]
);

waveFreq = (freq * (1 + (pitchMod * stretcher2))).clip(40, inf);

src1 =
SelectX.ar(offset, // voire impact de SelectX.ar - Select.kr à l'origine ???
// Dans ce cas un equal power crossfade avec SelectX est approprié vs LinSelectX avec interpolation sur les fréquences ci-dessus
[
SinOsc.ar(waveFreq),
LFTri.ar(waveFreq)
]
);

// ampEnvGen = EnvGen.kr(Env.perc(0.0001, ampDecay, 1, -6), gate, doneAction: 2);
// src1 = src1 * ampEnvGen * amp;
src1 = src1 * inBusVol * amp * 0.2;

"+~allSpas[1][indexS]+"
}
/*,
metadata: (
comments: [
ControlSpec(0.25, 16.0, 'exp', 0.01, 1.0, 'Freq Mul'), // -> preprate
nil,
ControlSpec(0, 6, 'lin', 0.1, 0.0, 'Mod Type'), // -> stretcher
ControlSpec(/*-1.0*/ 0 , 12.0, 'lin', 0.001, 1.0, 'Mod Depth'), // -> stretcher2 - voire comment avoir la valeur entre -1 et 12 ??????
ControlSpec(0, 127, 'lin', 0.01, 60, 'Midi Freq'), // -> center
ControlSpec(0.2, 120.0, 'exp', 0.001, 4.0, 'Mod Speed') // -> center2
]
)*/
)."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				// préférable de créer des metadata en dehors pour éviter la redondance et la création de fichiers .txarcmeta
				// Pourquoi exp ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
				~metaDataElectribe = [
					ControlSpec(0.25, 16.0, 'exp', 0.01, 1.0, 'Freq Mul'), // preprate
					nil,
					ControlSpec(0, 6, 'lin', 0.01, 0, '7 Mod Types (0-LFSaw, 1-LFPulse, 2-LFTri, 3-White, 4-Impulse, 5-White, 6-White Envgen)'), // stretcher
					ControlSpec(/*-1.0*/ 0 , 12.0, 'lin', 0.001, 1.0, 'Mod Depth XXX'), // stretcher2 - voire comment avoir la valeur entre -1 et 12 ?????? - très important pour entendre pitchMod
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Midi Freq'), // center
					ControlSpec(0.2, 120.0, 'exp', 0.001, 4.0, 'Mod Speed'), // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, '2 Wave Types (SinOsc, LFTri)') // offset
				];

				/*SynthDef("tribe1", {
				|outBus = 0, midiFreq = 60, gate = 1.0, amp = 0.5, freqMult = 1,
				waveType = 0, modType = 0, modDepth = 0.0, modSpeed = 4.0, ampDecay = 0.1|

				var freq, output, modEnvGen, ampEnvGen, pitchMod, white, waveFreq;

				freq = midiFreq.midicps * freqMult; // freqMult pas vaiment nécessaire
				white = WhiteNoise.ar;
				modEnvGen = EnvGen.kr(Env.perc(0.0001, modSpeed.reciprocal, 1, -6), gate);

				pitchMod =
				Select.kr(modType,
				[
				LFSaw.ar(modSpeed),
				LFPulse.ar(modSpeed),
				LFTri.ar(modSpeed),
				Latch.ar(white, Impulse.ar(modSpeed)),
				white,
				white * modEnvGen,
				modEnvGen
				]
				);

				waveFreq = (freq * (1 + (pitchMod * modDepth))).clip(40, inf);

				output =
				Select.ar(waveType,
				[
				SinOsc.ar(waveFreq),
				LFTri.ar(waveFreq)
				]
				);

				ampEnvGen = EnvGen.kr(Env.perc(0.0001, ampDecay, 1, -6), gate, doneAction: 2);
				output = output * ampEnvGen * amp;

				Out.ar(outBus, output ! 2);
				}
				).add;

				// here are some control specs given as name Symbol / ControlSpec pairs
				// that give a sensible range of values
				// copy and paste to taste
				[
				\amp, ControlSpec(0.0, 1.0, \lin, 0.01, 0.5, "level"), // -> amp
				\freqMult, ControlSpec(0.25, 16.0, \exp, 0.01, 1.0, "mult"), // -> preprate
				\waveType, ControlSpec(0, 1, \lin, 0.1, 0.0, "wave type"), // -> off
				\modType, ControlSpec(0, 6, \lin, 0.1, 0.0, "mod type"), // -> stretcher
				\modDepth, ControlSpec(-1.0, 12.0, \lin, 0.001, 0.0, "mod depth"), // -> stretcher 2
				\modSpeed, ControlSpec(0.2, 120.0, \exp, 0.001, 4.0, "mod speed"), // -> center 2
				\ampDecay, ControlSpec(0.05, 0.8, \exp, 0.0001, 0.1, "amp DK") // -> dur
				]*/










				// Glissando

				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono simple Glissando

							~synth =
							("SynthDef(\\BufMGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, rate2= 1, offset= 0, bufm, trig, loop= 0 |
var src1, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = Line.kr(rater, rate2, durenv, mul:BufRateScale.ir(bufm));
// bufRate = Select.kr(1, [rater, Line.kr(rater, rate2, durenv)]) * BufRateScale.ir(bufm);
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMGliss = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate Start'), // rater
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate End'), // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Mono avec Pitchshift & Freqshift Glissando

							~synth =
							("SynthDef(\\BufMPitchGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, rate2= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, stretcher2= 1, center= 440, center2= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05 |
var src1, bufRate, bufFrames, stretch;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// bufRate = rater * BufRateScale.ir(bufm);
bufRate = Line.kr(rater, rate2, durenv, mul:BufRateScale.ir(bufm));
bufFrames = offset * BufFrames.ir(bufm);
stretch = Line.kr(stretcher, stretcher2, durenv);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src1 = PitchShift.ar(src1, windowSize: psWindowSize, pitchRatio: stretch, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src1 = FreqShift.ar(src1, Line.kr(center, center2, durenv) * (1-stretch)) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufMPitchGliss = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate Start'), // rater
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate End'), // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio Start'), // stretcher
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio End'), // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale Start'), // center
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale End'), // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Warp0 Mono Glissando
							// Warp0.ar(numChannels, buffer, warpFactor, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add)
							// Def = pointer = LFSaw.kr( warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
							// Def = ^Warp1.ar(numChannels, buffer, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add);
							// Inspired by Chad Kirby's SuperCollider2 Warp1 class, which was inspired by Richard Karpen's sndwarp for CSound. A granular time strecher and pitchshifter.

							~synth =
							("SynthDef(\\WarpMGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, rate2= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, stretcher2= 1, center= 1, center2= 1, nbSlices = 1, gDurRand = 0.01 /*0.01*/, trajRand = 3/*3*/, rdRand = 0.01, grainSize = 60, grain2Size = 60 /*, psPitchDispers= 0*/ /*psWindowSize= 0.2*/ /*0.01*/ /*, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05, freqrate= 1, famp= 0, amprate= 1, aamp= 0, panrate= 1, pamp= 0*/ |
// arg buf = b, posS = 0, posE = 1, len = 1, gDur = 100, nbSlices = 1, transpo = 1, gDurRand = 0.01, trajRand = 3, rdRand = 0.01, envWidth = 0.95 /*, nbGrain = 8, nbChannel = 1*/;

var nbChannel, nbGrain, nbGrainReciprocal, volGrain, srDiv, gDur, gDurV, gDurSmp, slice, len, posE, /*len2, posE2,*/ traj, mainPhasor, src1, rd, gEnv, pos, gr, transpo, stretch, harmonize;
var semitone, rd1, env1, rd2, env2, bufL, tapWrite, outs, out1, out2, fbNode1, sig;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

transpo = /*rate;*/ XLine.kr(preprate, rate2, durenv, mul:BufRateScale.ir(bufm)) /*.clip(0.001, 10)*/ /*.poll*/ ;
stretch =  stretcher /*\\stretcher.ir*/ /*Line.kr(stretcher, stretcher2, durenv)*/ /*.clip(0.001, 10)*/ ;
harmonize = /*center.clip(0, 24);*/ /*.poll*/ (XLine.kr(center, center2, durenv) - 50) /*.varlag(0.5)*/.clip(-50, 50);

nbChannel = 1; // Question perso : Comment mettre nbChannel & nbGrain en argument ?
nbGrain = 8; // Quel nb de grains à appliquer pour le meilleur compromis entre rendu sonore et CPU ? 16 ou 32 ? XXXXXXXXX
// Note that .asInteger doesn't round to the nearest integer. It chops off the fractional part. So the server-side equivalent is 'trunc'. // ne marche pas ?

nbGrainReciprocal = nbGrain.reciprocal;
volGrain = nbGrainReciprocal/*.sqrt*/; // Comment déterminer le niveau de volume (le + intéressant) à attribuer pour chaque grain ? Quelle formule ? // (1/2).sqrt si 2 sons ? XXXXXXXXX
srDiv = SampleRate.ir * 0.001; // préférable de diviser ou multiplier le signal en termes de CPU ?
gDur = grainSize/*.varlag(1)*/; // psPitchDispers/*psWindowSize*/.linlin(0, 0.5, 0.001, 200)/*.round(1)*//*.poll*/; // .linlin pratiquement même benchmark qu'avec .range
// Apparemment une valeur de 0.1 minimale ne provoque pas d'explosions, mais en dessous si...
gDurV = gDur + WhiteNoise.ar( gDurRand /*0.05*/ /*0.5*/); // JITTER sur la taille de la fenêtre - Voire l'intérêt de LFDNoise3 (Dynamic cubic noise) au lieu de WhiteNoise ? XXXXXXXXX
gDurSmp = gDurV * srDiv; // Conversion de la durée de la taille de fenêtre de ms en samples
slice = BufFrames.ir/*kr*/(bufm) /*/ nbSlices*/; // slice.poll; // nbSlices pas utilisé ????????? - 1 par défaut // Durée du Buffer lu

// durenv.poll;
// BufDur.ir(bufm).poll;
len = ((durenv / BufDur.ir(bufm)) * stretch)/*.poll*/;
posE = (offset + len)/*.poll*/;
// posE = durenv % (offset + len)/*.poll*/; // 1 % (2 / 1)

/*len2 = ((durenv / BufDur.ir(bufm)) * stretcher2)/*.poll*/;
posE2 = (offset + len2)/*.poll*/;*/

traj = Line.ar(offset * slice, posE * slice /*Line.ar(posE * slice, posE * slice, durenv)*/ /*posE * slice*/, /*len * BufFrames.ir(bufm)*/ durenv /*dur*/ /*, doneAction: 2*/) + WhiteNoise.ar( trajRand /*5*/); // Lecture linéaire de la position dans le grain avec JITTER
// A expérimenter avec différentes enveloppes de trajectoires ? Lesquelles pourraient être les plus intéressantes ?

mainPhasor = LFSaw.ar(gDur.reciprocal * 1000 * transpo /*MouseX.kr(0.1, 10)*/, 0, 0.5, 0.5);
// Pourquoi crash avec Saw ? - Intérêt si fréquence très élevée ?

rd = 0 ! nbGrain; // Question perso : Autre moyen d'initialiser les Arrays ?
gEnv = 0 ! nbGrain;
pos = 0 ! nbGrain;
gr = 0 ! nbGrain;

// Code pour la génération d'un nb de grains en fonction de la variable nbGrain
nbGrain.do { |i| // Mettre .collect ou .do ??? - Aucun besoin de collecter ???
// rd[i] calcule la position du pointeur de lecture de chaque grain = LFSaw (main_phasor) + phase + JITTER pour chaque grain
rd[i] = Wrap.ar(mainPhasor + (nbGrainReciprocal * i)/*.postln*/ + Rand(0, rdRand) );
// équivalent de 100.rand * 0.0001 - voire changement à chaque sample avec WhiteNoise.ar(rdRand) ou TRand avec Trigger ? XXXXXXXXX
// rdRand.rand // valeur aléatoire, la même pour tous les grains
gEnv[i] = (rd[i] * pi).sin; // enveloppe sinusoïdale ?
// gEnv[i] = rd[i].welWindow; // Autre manière de faire l'enveloppe sinusoïdale ? - Plus lourde - prend au moins 1% de CPU en plus ? Question perso : Pourquoi ?
// gEnv[i] = ( -0.5 * (rd[i] * 2 * pi).cos + 0.5); // enveloppe hanning
// gEnv[i] = rd[i].hanWindow; // Autre manière de faire l'enveloppe Hanning - Plus lourde - prend au moins 1% de CPU en plus ?
// gEnv[i] = rd[i].rectWindow; // Intérêt de l'enveloppe rectangulaire ? fait du crunchy...
// gEnv[i] = rd[i].triWindow; // enveloppe triangulaire
// Comment faire le switch entre différentes enveloppes dans un même synthé de manière économique en CPU ?
pos[i] = Latch.ar(traj, rd[i] > 0.99); // Latch -> Sample and hold
gr[i] = BufRd.ar(nbChannel, bufm, (rd[i] * gDurSmp) + pos[i], loop, interpolation: 4) * gEnv[i] * volGrain; // pas de Latch pour gDurSmp comme dans l'exemple PD ?
}; // voire exemples de BufRd

// (pos[0] / BufFrames.ir(bufm)).wrap.poll; // Indication de la position dans le Buffer de 0 à 1. A retirer.
outs /*src1*/ = gr.sum /** inBusVol * amp*/;
// src1 = Out.ar(0, (gr.sum * env) ! 2); // ! 2 pour dupliquer le signal mono
// Out.ar(0, Mix(gr * env) ! 2); // équivalent
// Out.ar(0, NumChannels.ar(gr, 2));


// Partie Harmonizer
/*
0.midicps
0.pow(24 / 12)
*/

semitone = 2.pow(/*MouseX.kr(-127, 127, 0, 0.5)*/ harmonize /*.linlin(0, 127, -64, 64);*/ /*pitch*/ / 12)/*.poll*/;

rd1 = LFSaw.ar( ((-1) * (semitone-1)) / ( /*gDur.max(1)*/ /*60*/ grain2Size * 0.001) /*pitch*/, 0, 0.5, 0.5); // Intérêt du jitter dans ce cas ?
// Comment adoucir les aigues et les sifflantes quand filtre est partfois trop élevé ? en fonction des sons ? Type de filtre HP et contrôle ?

// rd1 = Phasor.ar( 0, ((-1) * (semitone-1)) / (/*gDur*/ (100 * 0.001).min(durenv)) /*pitch*/, 0, 1);

env1 = (rd1 * pi).sin; // enveloppe sinusoïdale
rd2 = Wrap.ar(rd1 + 0.5); // Wrap a signal outside given thresholds.
env2 = (rd2 * pi).sin;

/*var env1 = ( -0.5 * (rd1 * 2 * pi).cos + 0.5); // enveloppe hanning
var rd2 = Wrap.ar(rd1 + 0.5); // Wrap a signal outside given thresholds.
var env2 = ( -0.5 * (rd2 * 2 * pi).cos + 0.5);*/

/*var snd1 = AllpassL.ar(sig, 2, ((rd1 * gDur) /*+ 2*/) / 1000, 0) * env1; // // All pass delay line with linear interpolation.
var snd2 = AllpassL.ar(sig, 2, ((rd2 * gDur) /*+ 2*/) / 1000, 0) * env2;*/

bufL = LocalBuf(SampleRate.ir * 2).clear;
tapWrite = DelTapWr.ar(bufL, outs);
out1 = DelTapRd.ar(bufL, tapWrite, delTime: (rd1 * /*gDur.max(1)*/ 60 * 0.001) + 0.002, interp: 2) * env1;
out2 = DelTapRd.ar(bufL, tapWrite, delTime: (rd2 * /*gDur.max(1)*/ 60 * 0.001) + 0.002, interp: 2) * env2;
// Pourquoi 0.002 ??? -> ne peut pas aller au delà du blocksize - 64 / 44100
// Clic avec interpolation cubique (4) sur DelTapRd

// (pos[0] / BufFrames.ir(buf)).wrap.poll; // Indication de la position dans le Buffer de 0 à 1. A retirer.

// comment créer la même chose que Hip~ 4 (Filtre Hipass IIR de 1er ordre) de PD dans SC ?
// Out.ar(0, (gr.sum * env) ! 2); // ! 2 pour dupliquer le signal mono
// Out.ar(0, (HPF.ar((snd1 + snd2) * env, 4)) ! 2); // ! 2 pour dupliquer le signal mono
src1 = HPF.ar((out1 + out2) * inBusVol * amp, 4);
// HPF => A second order high pass filter.


/*
// create two FbNodes with different delay times
fbNode1 = FbNode(1, 1, 4);
src1 = src1 + (fbNode1.delay(0) * /*fb*/ stretcher2.clip(0, 0.95));
// var sig2 = out2 + (fbNode2.delay(del2) * fb); // del 2 pas utilisé XXXXXX

fbNode1.write(outs);
// fbNode2.write(sig2);
*/


"+~allSpas[1][indexS]+"
})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataWarpMGliss = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Transpo Start'), // preprate
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Transpo End'), // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor (Stretch / Compress)'), // stretcher
					ControlSpec(0, 0.95, 'lin', 0.01, 0, 'FB'), // stretcher2
					ControlSpec(0, 100, 'lin', 0.001, 50, 'Harmonizer Start (en demi-ton - 50)'), // center.clip(1, 100)
					ControlSpec(0, 100, 'lin', 0.001, 50, 'Harmonizer End (en demi-ton - 50)'), // 2 center
					/*ControlSpec(1, 127, 'lin', 0.01, 1, 'gDur Start (20 - 200 ms)'), // center.clip(1, 100)
					ControlSpec(1, 127, 'lin', 0.01, 1, 'gDur End (20 - 200 ms)'), //2 center*/
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];

				/*if ( ~synthDefsBuild == 1, {
				( // juste pour recompiler un synthé XXXXXXXXX
				~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

				// Warp0 Mono Glissando
				// Warp0.ar(numChannels, buffer, warpFactor, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add)
				// Def = pointer = LFSaw.kr( warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
				// Def = ^Warp1.ar(numChannels, buffer, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add);
				// Inspired by Chad Kirby's SuperCollider2 Warp1 class, which was inspired by Richard Karpen's sndwarp for CSound. A granular time strecher and pitchshifter.

				~synth =
				("SynthDef(\\WarpMGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, rate2= 1, offset= 0, bufm, trig, loop= 0, stretcher= 1, stretcher2= 1, center= 1, center2= 1, psWindowSize= 0.2, psTimeDispers= 0.05 |
				var src1, bufRate, stretch;
				"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

				bufRate = Line.kr(preprate, rate2, durenv, mul:BufRateScale.ir(bufm));
				stretch = Line.kr(stretcher, stretcher2, durenv);

				// bufFrames = offset * BufFrames.ir(bufm);
				// src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

				src1 = Warp0.ar(1, bufm, stretch, bufRate, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4) * inBusVol * amp;

				"+~allSpas[1][indexS]+"
				})."++~synthDefsManagement); // ou .cs for short .asCompileString // It will still truncate after 8188 chars tho.
				~synth.asCompileString.postln;
				~synth.interpret;

				}})});

				~metaDataWarpMGliss = [
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale Start'), // preprate
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale End'), // rate2
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor Start'), // stretcher (Stretch / Compress)
				ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor End'), // stretcher2 (Stretch / Compress)
				ControlSpec(1, 100, 'lin', 0.01, 8, 'Overlaps (de 1 à 100)'), // center.clip(1, 100)
				nil, // center2
				ControlSpec(0, 1, 'lin', 0.01, 0, 'Window Rand Ratio'), // offset
				];*/





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo simple Glissando

							~synth =
							("SynthDef(\\BufSGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, rate2= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0 |
var src1, src2, src, bufRate, bufFrames;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// bufRate = rater * BufRateScale.ir(bufm);
bufRate = Line.kr(rater, rate2, durenv, mul:BufRateScale.ir(bufm));
bufFrames = offset * BufFrames.ir(bufm);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSGliss = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate Start'), // rater
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate End'), // rate2
					nil, // stretcher
					nil, // stretcher2
					nil, // center
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Buffer Stéréo avec Pitchshift & Freqshift Glissando

							~synth =
							("SynthDef(\\BufSPitchGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", rater= 1, rate2= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, trig, loop= 0, stretcher= 1, stretcher2= 1, center= 440, center2= 440, psWindowSize= 0.2, psPitchDispers= 0, psTimeDispers= 0.05 |
var src1, src2, src, bufRate, bufFrames, stretch;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

// bufRate = rater * BufRateScale.ir(bufm);
bufRate = Line.kr(rater, rate2, durenv, mul:BufRateScale.ir(bufm));
bufFrames = offset * BufFrames.ir(bufm);
stretch = Line.kr(stretcher, stretcher2, durenv);

src1 = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop);
src2 = PlayBuf.ar(1, bufm2, bufRate * offRateSecondBuf, trig, bufFrames, loop);
src = [src1, src2];
src = PitchShift.ar(src, windowSize: psWindowSize, pitchRatio: stretcher, pitchDispersion: psPitchDispers, timeDispersion: psTimeDispers);
src = FreqShift.ar(src, Line.kr(center, center2, durenv) * (1-stretcher)) * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataBufSPitchGliss = [ // à terminer
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate Start'), // rater
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Buf Rate End'), // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio Start'), // stretcher
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Pitch Ratio End'), // stretcher2
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale Start'), // center
					ControlSpec(0, 127, 'lin', 0.25, 60, 'FreqScale End'), // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Buf Offset'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// Warp0 Stéréo Glissando
							// Warp0.ar(numChannels, buffer, warpFactor, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add)
							// Def = pointer = LFSaw.kr( warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
							// Def = ^Warp1.ar(numChannels, buffer, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add);
							// Inspired by Chad Kirby's SuperCollider2 Warp1 class, which was inspired by Richard Karpen's sndwarp for CSound. A granular time strecher and pitchshifter.

							~synth =
							("SynthDef(\\WarpSGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, rate2= 1, offRateSecondBuf= 1, offset= 0, bufm, bufm2, /*trig, loop= 0,*/ stretcher= 1, stretcher2= 1, center= 440, center2= 440, psWindowSize= 0.2 /*, psTimeDispers= 0.05*/ |
var src1, src2, src, bufRate, stretch;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

bufRate = Line.kr(preprate, rate2, durenv, mul:BufRateScale.ir(bufm));
stretch = Line.kr(stretcher, stretcher2, durenv);

// bufFrames = offset * BufFrames.ir(bufm);
// src = PlayBuf.ar(1, bufm, bufRate, trig, bufFrames, loop) * inBusVol * amp;

src1 = Warp0.ar(1, bufm, stretch, bufRate, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4);
src2 = Warp0.ar(1, bufm2, stretch, bufRate * offRateSecondBuf, psWindowSize, -1, center.clip(1, 100) /*8*/, offset, 4);
src = [src1, src2] * inBusVol * amp;

"+~allSpas[3][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataWarpSGliss = [
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale Start'), // preprate
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Freq Scale End'), // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor Start (Stretch / Compress)'), // stretcher
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Warp Factor End (Stretch / Compress)'), // stretcher2
					ControlSpec(1, 100, 'lin', 0.01, 8, 'Overlaps (de 1 à 100)'), // center.clip(1, 100)
					nil, // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Window Rand Ratio'), // offset
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// GrainBuf Glissando
							// (numChannels: 1, trigger: 0, dur: 1, sndbuf, rate: 1, pos: 0, interp: 2, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
							// 1024 -> maxgrains -> maximum number of overlapping grains set at the UGens init time that can be used at a given time. This can be set lower for more efficient use of memory.
							// voire faire varier le buffer selon le grain ?????? - quel contrôle envisager pour la variation ??????

							// La spatialisation est intégrée dans le pattern et non pas à l'intérieur du UGen
							// voire utilisation d'un Buffer stéréo avec 2 GrainBuf pour faire varier la spatialisation dans le UGen aussi ??????
							// No panning puisque numChannels est = 1
							// Pan - If numChannels = 1, no panning is done. Best way ??????
							// Pan - If numChannels = 2, panning is similar to Pan2.
							// Pan - If numChannels > 2, panning is the same as PanAz.

							~synth =
							("SynthDef(\\GrainBufGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, rate2= 1, offset= 0, bufm, /*trig,*/ stretcher= 1, stretcher2= 1, center= 1, center2= 1 |
var src1, grain, grain1, grain2, triggerGrain;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

grain1 = preprate.clip(0.1, 200);
grain2 = rate2.clip(0.1, 200);
grain = Line.kr(center, center2, durenv);
triggerGrain = /*Impulse.kr(grain)*/ Dust.kr(grain); // voire intéret entre Impulse.kr & .ar & possibilité de swithcher avec Dust ???

// freq = preprate * BufRateScale.ir(bufm) /*+ TRand.kr(0.0, 0.5, triggerGrain)*/;
// Auparavant utilisation du TRand [+ ou x TRand.kr(0.0, 0.5, triggerGrain)] afin de faire varier constamment la vitesse de lecture selon le grain

src1 = GrainBuf.ar(numChannels: 1,
trigger: triggerGrain,
dur: durenv / triggerGrain,
sndbuf: bufm,
rate: LFNoise2.ar(Line.kr(center, center2, durenv)).range(stretcher, stretcher2) ,
pos: LFNoise2.kr(offset*100).range(0, 1),
interp: 2, /*pan: pan,*/ envbufnum: -1, maxGrains: 1024) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataGrainBufGliss = [
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain Start (de 0.1 à 200) that also determine Grain Duration'), // preprate
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Trigger Grain End'), // rate2
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Base Rate Start'), // stretcher
					ControlSpec(0, 2, 'lin', 0.01, 1, 'Base Rate End'), // stretcher2
					// ControlSpec(0, 4, 'lin', 0.01, 1, 'Relative Grain Duration (de 0.1 à 20)'), // stretcher2.clip(0.1,20) -> à réaffecter sur une autre GUI ????????? Index2 ou autre
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Rate Mod Speed Start'), // center
					ControlSpec(0, 127, 'lin', 0.01, 1, 'Rate Mod Speed End'), // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Offset Mod Speed (de 0 à 100 Hz)') // offset - Fréquence du changement aléatoire (LFNoise2) pour changer la playback position
				];





				if ( ~synthDefsBuild == 1, {
					( // juste pour recompiler un synthé XXXXXXXXX
						~allSpas[0].do {|itemS, indexS| ~allEnvs[0].do {|item, index|

							// PMOsc Glissando
							// (Phase modulation sine oscillator pair) (carfreq, modfreq, pmindex: 0, modphase: 0, mul: 1, add: 0)
							// AmpCompA ou AmpComp pour compenser l'amplitude des hautes fréquences - pas utilisé  ???
							// & Amp * 0.08 pour normaliser les amps selon les synthés (à corriger ???)

							~synth =
							("SynthDef(\\PMOscGliss_"++~allEnvs[0][index]++~allSpas[0][indexS]+", {| "++~commonSynthArgs+~envSynthArgs[index]+~spaSynthArgs[indexS]++", preprate= 1, rate2= 1, offset= 0, stretcher= 1, stretcher2= 1, center= 1, center2= 1 |
var src1, cFreq, mFreq, pmIndex;
"+~spaSynthVars[indexS]+~allEnvs[1][index]+"

cFreq = Line.kr(preprate, rate2, durenv).min(127).midicps;
mFreq = Line.kr(stretcher, stretcher2, durenv).min(127).midicps;
pmIndex = Line.kr(center, center2, durenv);

src1 = PMOsc.ar(cFreq, mFreq, pmIndex, offset /*((offset * 5).exp) -1*/, 0.08) * inBusVol * amp;

"+~allSpas[1][indexS]+"
})."++~synthDefsManagement);
							~synth.asCompileString.postln;
							~synth.interpret;

				}})});

				~metaDataPMOscGliss = [
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Car Freq Start'), // preprate.min(127).midicps - 6 octaves
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Car Freq End'), // rate2
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Mod Freq Start'), // stretcher.min(127).midicps - 6 octaves
					ControlSpec(0, 127, 'lin', 0.01, 60, 'Mod Freq End'), // stretcher2
					ControlSpec(0, 127, 'lin', 0.01, 1, 'PM Index Start'), // center - Modulation index in radians ???
					ControlSpec(0, 127, 'lin', 0.01, 1, 'PM Index End'), // center2
					ControlSpec(0, 1, 'lin', 0.01, 0, 'Mod Phase') // offset - A modulation input for the modulator's phase in radians - pas d'effet puisque pas de changement dynamique
					// -> à moduler par un oscillateur chotique XXXXXXXXX
				];





				// Fork nécessaire avec un petit wait nécessaire, sinon ERROR: Message '-' not understood -> provoqué la fin de Spectral diffusion ?????????
				0.01.wait;

			}.fork;

			);





			if ( ~synthDefsBuild == 0, {

				// PathName(~synthDefsFolder).files.do {|i| SynthDescLib.global.read(i); /*i.postln;*/ }; "SynthDescLib loaded".postln // Pour charger les SynthDesc si synthés ne sont pas reconstruits
				// Rajout d'une protection pour ne pas charger les fichiers avec une extension txarcmeta, qui provoquent un crash du server XXXXXXXXX
				// ????????????????????????????????????????????????????????????????????????
				// voire si pas trop demandeur en CPU ?????????
				// PathName(~synthDefsFolder).files.do { |i| if (i.extension != "txarcmeta", { SynthDescLib.global.read(i); /*i.postln;*/ }) };
				if (currentEnvironment[server] == ~server1, {PathName(~synthDefsFolderS1).files.do { |i| if (i.extension != "txarcmeta", { SynthDescLib.global.read(i); /*i.postln;*/ }) }}, {PathName(~synthDefsFolderS2).files.do { |i| if (i.extension != "txarcmeta", { SynthDescLib.global.read(i); /*i.postln;*/ }) }} );
				"SynthDescLib loaded".postln; // Pour charger les SynthDesc si synthés ne sont pas reconstruits


				/*
				SynthDescLib.global.synthDescs.keys.cs;
				SynthDescLib.global.synthDescs.keys.do { |i| i.postln }; // SynthDef descriptions added to the server XXXXXXXXX
				// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/feature-request-server-command-to-list-available-synthdefs-td5561829.html#a6187334
				SynthDefRegistery

				SynthDescLib.default
				SynthDescLib.browse; // ???
				SynthDescLib.global.browse // permet d'afficher les controles et gui des synthés chargés XXXXXXXXX
				SynthDescLib.global.read("synthdefs/default.scsyndef");
				SynthDescLib.send(s);
				*/

			});










			// Synth to add XXX

			// Warp
			// a granular time stretcher & pitchshifter inspired by Richard Karpen's sndwarp for Csound
			// Warp0 (Warp a buffer with a warpFactor & freqScale) -> Quark WarpExt
			// WarpIn (Warp live input with a warpFactor & freqScale) -> Quark WarpExt
			// Warp1 (Warp a buffer with a (time) pointer & freqScale) -> SC3 vanilla
			// WarpZ (Warp a buffer with a (time) pointer, zeroSearch, zeroStart & freqScale) -> Josh UGen plugin
			// WarpOverlap -> Josh UGen plugin



			/* Granulateurs
			//--ugens in the standard distribution:
			TGrains, GrainIn, GrainSin, GrainFM, GrainBuf, Warp1

			//--sc-plugins:
			MonoGrain, SinGrain, FMGrain, BufGrain, WarpZ (JoshUGens - see GrainSynths.sc)
			TGrains2, TGrains3	(BhobUGens)
			Concat (MLfftwUGens)

			//--other:
			GrainDelay			(http://git.k-hornz.de/)
			RedGrain			(http://www.fredrikolofsson.com/pages/code-sc.html)
			BMSwarmGranulator	(http://www.beast.bham.ac.uk/research/mulch.shtml)
			Emission Control	(http://www.create.ucsb.edu/downloads.html)
			Particularity		(http://chrisjeffs.blogspot.com/)
			http://www.informatics.sussex.ac.uk/users/nc81/courses/cm1/workshop.html#chapter7
			http://swiki.hfbk-hamburg.de:8888/MusicTechnology/869

			//--recommended reading:
			microsound - curtis roads
			http://www.lowkeydigitalstudio.com/docs/wolek_PHDdiss.pdf
			http://www.granularsynthesis.com/books.php


			BufGrain (trigger, The following args are polled at grain creation time -> dur, sndbuf, rate, pos, interp, mul, add)

			GrainBuf (numChannels: 1, trigger: 0, dur: 1, sndbuf, rate: 1, pos: 0, interp: 2, pan: 0, envbufnum: -1, maxGrains: 512, mul: 1, add: 0)
			GrainBuf a l'avantage de pouvoir choisir une enveloppe (par défaut -1 pour une built-in Hann enveloppe) vs BuGrain & Tgrains (à la différence de TGrains3 ???)
			et de pouvoir déterminer le nb de grains max (par défaut 512) pour économiser du CPU vs TGrains

			Tgrains a en plus un paramètre d'amplitude
			Tgrains (numChannels, trigger: 0, bufnum: 0, rate: 1, centerPos: 0, dur: 0.1, pan: 0, amp: 0.1, interp: 4)
			Tgrains2 with linear att/dec (numChannels, trigger: 0, bufnum: 0, rate: 1, centerPos: 0, dur: 0.1, pan: 0, amp: 0.1, att: 0.5, dec: 0.5, interp: 4)
			Tgrains3 with user envelope (numChannels, trigger, bufnum, rate, centerPos, dur, pan, amp, att, dec, window (bufnum of rise/decay shape), interp)
			Comment faire l'enveloppe à la fois du rise et du decay en même temps ?

			I've been trying both TGrains and Grainbuf and it seems that TGrains has a much higher processor overload.
			From what I understand the only advantage of TGrains is the ability to define attack and decay time for grain envelopes…
			*/



			// Shaper
			// autres formes d'ondes Saw, VarSaw, VOsc, chaotiques...

			// OverlapTexture -> Josh UGen plugin
			// MoogVCF -> Josh UGen plugin

			// Gendy

			// Breakcore
			// ["/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/aggressor_snare.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/aggressor_snare1.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/aggressor_snare2.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/ballon stretch_1_5.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/ballon_kick.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/balloon stretc_2_9.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/balloon stretch_1_1.wav", "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/SoundsChahut/Drums_Exile/balloon stretch_1_2.wav"];



			/*
			// Simple modulation d'amplitude de sinus qui sonne bien
			{ var ampOsc;
			ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
			SinOsc.ar(100, 0, ampOsc);
			}.play;
			{ var ampOsc;
			ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
			SinOsc.ar(200, 0, ampOsc);
			}.play;
			{ var ampOsc;
			ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
			SinOsc.ar(300, 0, ampOsc);
			}.play;
			{ var ampOsc;
			ampOsc = SinOsc.kr(0.5, 1.5pi, 0.5, 0.5);
			SinOsc.ar(400, 0, ampOsc);
			}.play;
			*/





			// Ugen Oregonator Chemical reaction modelling Oscillator - à étudier
			/*
			{Out.ar(0,Pan2.ar(0.1*Oregonator.ar(Impulse.kr(10),MouseX.kr(0.01,1,'exponential')),0.0))}.play
			{Out.ar(0,Oregonator.ar(Impulse.kr(100),0.1, 0.1, 0.5, 0.2,initx:0.1, inity:-0.5, initz:0.7))}.plot(0.1)
			{Out.ar(0,Pan2.ar(0.1*Oregonator.ar(Impulse.kr(100),0.1, 0.1, 0.5, 0.2,initx:0.1, inity:-0.5, initz:MouseX.kr)[0],0.0))}.play
			{Out.ar(0,Pan2.ar(0.1*Oregonator.ar(Impulse.kr(MouseX.kr(100,1000)),0.1, 0.2, 0.5, 0.2,initx:MouseY.kr, inity:-0.5, initz:0.5)[0],0.0))}.play
			{Out.ar(0,Pan2.ar(0.1*Oregonator.ar(Impulse.kr(MouseX.kr(10,1000,'exponential')),0.3, 0.1,0.1, 0.2,initx:MouseY.kr(0.1,1.0), inity:-0.5, initz:0.5)[0],0.0))}.play
			{Out.ar(0,Pan2.ar(0.1*Oregonator.ar(Impulse.kr(MouseX.kr(100,1000)),0.1, 0.2, 0.5, 0.2,initx:MouseY.kr, inity:-0.5, initz:0.5)[1],0.0))}.play
			{Out.ar(0,Pan2.ar(0.1*Mix(Oregonator.ar(Impulse.kr(MouseX.kr(10,1000)),0.1, 0.2, 0.5, 0.2,initx:MouseY.kr, inity:-0.5, initz:0.5)),0.0))}.play
			*/

			// Gendyn






			// test enveloppe
			/*
			k = Buffer.read(s, "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds/Frozen/1ts2_bowl_mouth_03_xs.wav");
			k = Buffer.read(s, "/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds/Kik/0NotKick-1.wav");
			Synth(\Buf_Line, [buf: k]);
			Synth(\Buf_Sine, [buf: k]);
			Synth(\Buf_Gauss1, [buf: k]);
			Synth(\Buf_Gauss2, [buf: k]);
			Synth(\Buf_Perc, [buf: k]);
			Synth(\Buf_PercRev, [buf: k]);
			Synth(\Buf_Exp, [buf: k]);
			Synth(\Buf_ExpRev, [buf: k]);
			*/






























			// Effets

			// see in _Init Buffers & Synths.rtf Pfx
			/*
			(
			SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1;
			var env, in;
			env = Linen.kr(gate, 0.05, 1, 0.1, 2);
			in = In.ar(out, 2);
			XOut.ar(out, env, CombL.ar(in * env, maxdtime, dtime, decay, 1, in));
			}, [\ir, \ir, 0.1, 0.1, 0]).add;

			SynthDef(\distort, { arg out=0, pregain=40, amp=0.2, gate=1;
			var env;
			env = Linen.kr(gate, 0.05, 1, 0.1, 2);
			XOut.ar(out, env, (In.ar(out, 2) * pregain).distort * amp);
			}, [\ir, 0.1, 0.1, 0]).add;

			SynthDef(\wah, { arg out=0, gate=1;
			var env, in;
			env = Linen.kr(gate, 0.05, 1, 0.4, 2);
			in = In.ar(out, 2);
			XOut.ar(out, env, RLPF.ar(in, LinExp.kr(LFNoise1.kr(0.3), -1, 1, 200, 8000), 0.1).softclip * 0.8);
			}, [\ir, 0]).add;
			)

			// intérêt du .ir ???
			// intérêt du XOut.ar ???
			*/


			/*
			SynthDef(\inout, { arg in=0, out=0, amp=1;
			var src= In.ar(in, ~numChannels) * amp;
			Out.ar(out, src);
			}).add/*.allControlNames*/;
			*/

			// Nouvelle version avec classe de Lucas Saramunga permettant de faire des crossfades sur différents bus
			// entraine une augmentation du CPU de quelques % - à réduire en alternant avec le synthé précédent quand seulement utilisation des synthés en parallèle et non en série ???
			// voir la gestion de l'amplitude avec lag( 7 ) ?????????

			if (~numChannels <= 16, { ~fx16Split = 0 } );

			if (~fx16Split == 1, {

				var out1, out2;
				var serverNb = 0;

				if (serverNb == 0, {
					out1 = ~outChannelsFXSpaceCuts[0];
					out2 = ~outChannelsFXSpaceCuts[1];
				},{
					out1 = ~outChannelsFXSpaceCuts[1];
					out2 = ~outChannelsFXSpaceCuts[0];
				});

				// (0..31)[~outChannelsFXSpaceCuts[0]]

				// pourquoi les synthé ci-dessous n'est pas plus économique que celui plus bas ???????????????????????????

				/*SynthDef(\inout, { arg in=0, out=0, amp=1, maxFadeTime = 6, fadeTime = 6 /*, ampFadeTime = 1*/;
				// var src= In.ar(in, ~numChannelsFX) * amp./*var*/lag( 7/*ampF*/ /*fadeTime*/ /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
				var src, srcA;
				srcA= In.ar(in, ~numChannelsFX);
				// src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| srcA[i] };
				src = srcA[~outChannelsFXSpaceCuts[serverNb]];
				src = src * amp.varlag( /*7*/ /*ampF*/ fadeTime /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
				out1.do { |i, id| FadeBusOut.ar(out+i, src[id], maxFadeTime, fadeTime); };
				out2.do { |i, id| OffsetOut.ar(out+i, srcA[i]); };
				// FadeBusOut.ar(out, src, maxFadeTime, fadeTime);
				}).add/*.allControlNames*/;*/

				SynthDef(\inout, { arg in=0, out=0, amp=1, maxFadeTime = 6, fadeTime = 6 /*, ampFadeTime = 1*/;
					// var src= In.ar(in, ~numChannelsFX) * amp./*var*/lag( 7/*ampF*/ /*fadeTime*/ /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
					var src= In.ar(in, ~numChannelsFX) * amp.varlag( /*7*/ /*ampF*/ fadeTime /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
					FadeBusOut.ar(out, src, maxFadeTime, fadeTime);
				}).add/*.allControlNames*/;

			},{

				SynthDef(\inout, { arg in=0, out=0, amp=1, maxFadeTime = 6, fadeTime = 6 /*, ampFadeTime = 1*/;
					// var src= In.ar(in, ~numChannelsFX) * amp./*var*/lag( 7/*ampF*/ /*fadeTime*/ /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
					var src= In.ar(in, ~numChannelsFX) * amp.varlag( /*7*/ /*ampF*/ fadeTime /*fadeTime.min(maxFadeTime)*/ /*0.4*/);
					FadeBusOut.ar(out, src, maxFadeTime, fadeTime);
				}).add/*.allControlNames*/;

			});



			if (~serverFX == 1, {

				SynthDef(\inout2, { arg in=0, out=0;
					var src= SoundIn.ar((0..~numChannelsFX));
					OffsetOut.ar(out, src);
				}).add;

			});










			// The makeEffect function below wraps a simpler function within itself and provides
			// a crossfade into the effect (so you can add it without clicks), control over wet
			// and dry mix, etc.
			// Such functionality is useful for a variety of effects, and SynthDef-wrap
			// lets you reuse the common code.
			/*
			( // original
			// the basic wrapper
			~makeEffect = {| name, func, lags, numChannels = 2 |

			SynthDef(name, {| i_bus = 0, gate = 1, wet = 1|
			var in, out, env, lfo;
			in = In.ar(i_bus, numChannels);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect

			// call the wrapped function. The in and env arguments are passed to the function
			// as the first two arguments (prependArgs).
			// Any other arguments of the wrapped function will be Controls.
			out = SynthDef.wrap(func, lags, [in, env]);

			XOut.ar(i_bus, wet * env, out);
			}, [0, 0, 0.1] ).add;

			};
			)

			// something to process
			x = { {Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2))} ! 2}.play;

			y = Synth.tail(s, \wah);
			z = Synth.tail(s, \reverb, [\wet, 0.5]);

			// we used an arg named gate, so Node-release can crossfade out the effects
			y.release;

			// setting gate to zero has the same result
			z.set(\gate, 0);

			x.free;



			( // modified
			// the basic wrapper with 1 channel and changing input output
			~makeEffect = {| name, func, lags, numChannels = 1 |

			SynthDef(name, {| in_bus = 0/* out_bus = 0*/, gate = 1, wet = 1|
			var in, out, env, lfo;
			in = In.ar(in_bus, numChannels);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect

			// call the wrapped function. The in and env arguments are passed to the function
			// as the first two arguments (prependArgs).
			// Any other arguments of the wrapped function will be Controls.

			//out = SynthDef.wrap(func, lags, [in, env]);

			Out.ar(out_bus, (XOut.ar(in_bus, wet * env, out)));
			}, [0, 0, 0.1] ).add;

			};
			)

			// something to process modified
			~x1 = { Out.ar(0, Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2)))}.play;
			~x2 = { Out.ar(2, Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2)))}.play;
			~x2 = { Out.ar(3, Decay2.ar(Dust2.ar(3), mul: PinkNoise.ar(0.2)))}.play;

			~y1 = Synth(\wah, [\in_bus, 2, \out_bus, 0]);
			~y2 = Synth(\echoM, [\in_bus, 3, \out_bus, 1]);

			~y1 = Synth.tail(s, \wah, [\in_bus, 2, \out_bus, 0]);
			~y2 = Synth.tail(s, \echoM, [\in_bus, 3, \out_bus, 1]);

			// we used an arg named gate, so Node-release can crossfade out the effects
			~y1.release;
			// ~y1.set(\gate, 0); // setting gate to zero has the same result
			~y1 = Synth.tail(s, \reverb, [\wet, 1]);

			~y1.set(\out_bus, 4);

			*/







			/*
			( // the basic wrapper modified
			~makeEffect = {| name, func, lags, numChannels = 1 |

			SynthDef(name, {| in_bus = 0/*, out_bus = 0*/, gate = 1, wet = 1|
			var in, out, env;
			in = In.ar(in_bus, numChannels);
			env = Linen.kr(gate, 2, 1, 2, 2); // fade in the effect
			// .kr (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0)

			// call the wrapped function. The in and env arguments are passed to the function
			// as the first two arguments (prependArgs).
			// Any other arguments of the wrapped function will be Controls.
			out = SynthDef.wrap(func, lags, [in, env]);
			XOut.ar(in_bus, wet * env, out);

			// Porquoi ne marche pas ??? permmettrait d'éviter l'utilisation d'un synth inout en plus ???
			// Out.ar(out_bus, (XOut.ar(in_bus, wet * env, out)));
			}, [0, 0, 0, 0.1] /*lags ???*/ ).add;
			};
			);

			(// now make a wah SynthDef
			~makeEffect.value(\wah, {|in, env, rate = 0.7, ffreq = 1200, depth = 0.8, rq = 0.1|
			// in and env come from the wrapper. The rest are controls
			var lfo;
			lfo = LFNoise1.kr(rate, depth * ffreq, ffreq);
			RLPF.ar(in, lfo, rq, 10).distort * 0.15; },
			[0.1, 0.1, 0.1, 0.1],  // lags for rate ffreq, depth and rq
			1    // numChannels
			);
			);/*.allControlNames*/


			(// now make a simple reverb SynthDef
			~makeEffect.value(\reverb, {|in, env|
			// in and env come from the wrapper.
			var input;
			input = in;
			16.do({ input = AllpassC.ar(input, 0.04, 0.004/*Rand(0.001,0.04)*/, 3)});
			input; },
			nil,  // no lags
			1    // numChannels
			);
			);



			/*SynthDef(\echoM, { arg in= 10, out=0, maxdtime=0.2, dtime=0.1, decay=2;
			var src= In.ar(in, 1);
			Out.ar(out, CombL.ar(src, maxdtime, dtime, decay, 1, src));
			}).add;*/

			(// now make an echo SynthDef
			~makeEffect.value(\echoM, {|in, env, maxdtime=0.2, dtime=0.1, decay=2|
			// in and env come from the wrapper.
			var input;
			input = in;
			CombL.ar(in, maxdtime, dtime, decay, 1/*, in*/)},
			nil, // no lags
			1    // numChannels
			);
			);


			/*SynthDef(\distortM, { arg in= 11, out=0, pregain=30, amp=0.2;
			// var env = Env([0, 1, 1, 0], [0.001, 1, 0.001]);
			// var envgen = EnvGen.ar(env, doneAction: 2);
			var src= In.ar(in, 1);
			Out.ar(out, (src * pregain).distort * amp) * envgen;
			}).add;*/

			(// now make a distort SynthDef
			~makeEffect.value(\distortM, {|in, env, pregain=40, amp=0.2|
			// in and env come from the wrapper.
			var input;
			input = in;
			(in * pregain).distort},
			nil, // no lags
			1    // numChannels
			);
			);


			/*SynthDef(\tanhDistort, {arg in = 0, out = 0, distortGain = 2;
			var signal = In.ar(in, 1) * distortGain; // Input Signal (inBus)
			var distortedOutput = tanh(signal);
			Out.ar(out, distortedOutput); // Output Signal (outBus)
			}).add;*/

			(// now make a distort tanh SynthDef
			~makeEffect.value(\distortTanh, {|in, env, distortGain = 2|
			// in and env come from the wrapper.
			var input;
			input = in;
			tanh(in * distortGain)},
			nil, // no lags
			1    // numChannels
			);
			);


			/*SynthDef(\reverb2, {arg in_bus=0, out_bus=0, roomsize, revtime, damping, inputbw, spread = 0/*15*/, drylevel, earlylevel, taillevel;
			var src= In.ar(in_bus, 1);
			var reverb= GVerb.ar(
			src,
			roomsize,
			revtime,
			damping,
			inputbw,
			spread,
			drylevel.dbamp,
			earlylevel.dbamp,
			taillevel.dbamp,
			roomsize, 0.3); /*+ src*/
			Out.ar(out_bus, reverb[0]);
			}).add;*/

			(// now make a simple Gverb SynthDef
			~makeEffect.value(\reverb2, {|in, env, roomsize=5, revtime=0.6, damping=0.62, inputbw=0.48, spread=0 /*15*/, drylevel= -6, earlylevel= -12, taillevel= -13|
			// in and env come from the wrapper.
			var input, reverb;
			input = in;
			reverb= GVerb.ar(
			in,
			roomsize,
			revtime,
			damping,
			inputbw,
			spread,
			drylevel.dbamp,
			earlylevel.dbamp,
			taillevel.dbamp,
			roomsize, 0.3); /*+ src*/
			reverb[0];},
			nil, // no lags
			1    // numChannels
			);
			);
			*/















			// Test avec Xfade & variants car impossible d'intégrer des variants avec le wrap ???


			// voire possibilité de créer des effets stéréos (certains ont été créés avec Rotate2 ou ≠ légers Rand sur les paramètres de chaque canal -> voire RevTank ou GVerb) et multicanaux (AdcVerb) à la place des effets mono ??? XXXXXXXXXXXXXXXXXXXX


			// for rotating an ambisonic B-format sound field around an axis. Rotate2 does an equal power rotation so it also works well on stereo sounds. It takes two audio inputs (x, y) and an angle control (pos). It outputs two channels (x, y)


			// Question on mailing list : VarLag with different warp shapes for up and down
			/*
			Does this kind of Ugen or method exist ?
			a mix between LagUD (for downgoing and upgoing signal) and VarLag (for warp  shapes) ?
			or maybe someone has already implemented it or best way to implement ?

			I think you can use VarLag:
			e.g. lag a step noise with warp of your choice.
			You can track the steps and let
			lagtime depend on the sign of the last step.
			This could be a bit of a fiddling though I suppose ...
			*/
			// Actuellement .varlag quand linéaire et .lag2 quand exponentiel -> pas idéal
			// Pour les exponentiels ->
			// .lag provoque une montée trop rapide, mais la descente a un effet "linéaire intéressant" bien que trop lent au départ
			// .lag3 provoque une montée moins rapide (que .lag ou .lag2) et plus appréciable, mais la descente est moins intéressante car trop rapide (vs .lag ou .lag2)
			// .lag2 s'avère pour l'instant un conpromis acceptable
			// .varlag une belle montée, mais la descente est trop brutale

			// exponentiel (lag2) utilisé pour :
			/*
			- Distort (pregain)
			- DisTanh (pregain)
			- Squiz (pitchratio / zcperchunk)
			- Decim (rate / bits) -> pas exp mais curve de 2
			- RingMod (freq / rate)
			- Voco (freq)
			- FreqS (freq)
			- DFM1 (cutoff / resonance / noiselevel)
			- BMoog (cutoff / q / saturation)
			- MoogFF (cutoff)
			- MoogLa (cutoff)
			- RLPFD (cutoff)
			- Wah (rate / ffreq) // pourquoi ffreq avait lin auparavant ???
			- CombL (dtime) -> pas exp mais curve de 2
			- DelPitch (dly / fc / rq / fc2 / rq2)
			- RevAdC (revTime)
			- GVerb (revTime)
			*/


			// Le controlSpec du Mix est différent pour le Wah et le delPitch (-1 à -0.5) pour protection - A améliorer XXXXXXXXX
			// Le controlSpec du Mix est différent pour le RevF (FreeVerb (0 à 1) car UGen intègre déjà le mix


			// resonance en exp ou linéaire selon les synthés ?????????


			// Vérifier que .varlag est au niveau .kr et est équivalent à VarLag.kr et non .ar ?????????


			// L'argument bits de Decimator ne marche pas ?????????





			( // Sélection des effets + effets ambisoniques

				( // Sélection des effets seulement modulant les HP
					// Penser à retirer les synhés chargés sur le server si changement des définitions de synhés de FX sinon le server ne répond plus / crashe et devient jaune XXXXXXXXXXXXXXXXXXXXXXXXXXX

					// A décommenter pour pouvoir évaluer seulement les FX


					/*var server = \server1;
					var serverNb = 0;*/

					/*var server = \server2;
					var serverNb = 1;*/

					// ~fx16Split = 1; // Adaptation des FX quand nb de canaux supérieurs à 16 faute de CPU




					~fxSynthDef = List.new;
					~fxSynthDef1 = List.new; // pour chaque colonne (4)
					~fxSynthDef2 = List.new;
					~fxSynthDef3 = List.new;
					~fxSynthDef4 = List.new;
					~fxSynthDef2b = List.new; // EQ Unitlib
					~fxSynthDef2Cha = List.new; // EQ Unitlib pour chaque canal à la fin des groupes
					~fxSynthDef2c = List.new; // Effets spectraux





					if (~hpModulation == 0, {

						// Pas vraiment de différence entre .distort & .tanh pour distortion

						~fxSynthDef1.add(
							SynthDef(\Distort, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, amp = 0.2, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = (src * pre_gain_E.lag2(lag)).distort * amp /** pre_gain_E.lag2(lag).reciprocal*/ ;
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							// Utilisation de ReplaceOut.ar(out, XFade2.ar(dry, wet2, mix)) dans RedFrik - intérêt ???
							variants: (
								// a: [pre_gain_E: 5],
								a: [pre_gain_E: 10],
								b: [pre_gain_E: 50]),
							metadata: (
								specs: (
									// \out: \audiobus.asSpec,
									// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
								),
								specsR: (
									// \out: \audiobus.asSpec,
									// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
									\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
								),
								order: [
									\mix,
									\lag,
									\pre_gain_E
								]
							)
							).add;
						);

					},{

						// Synthés pour ne pas créer de modulation entre les HP
						~fxSynthDefNoHPMod = [
							\Greyhole_2, \RevG_2, \JPverb_2, \GreyholeA_2, \RevGA_2, \JPverbA_2, \Rootate, \RevAdC, // car stéréos ou déjà multicanal
							\Voco, \RevTank, // Concernant \RevTank, crash du server ????????????????????????????????????
							// \RingMod, \DFM1, \BMoog, \Wah, \DelPitch, // Synthés qui prennaient trop de temps à être libérés ????????????????????????????????????
							\DelPitch, // ne marche pas dans la configuration
							\Streson, // Explosion du volume ????
							\RLPFD // ,
						];


						/*
						// Adaptation des FX quand nb de canaux supérieurs à 16 faute de CPU
						~outChannelsFXSpaceCuts = [(0,2..30), ((0,2..30)+1)];
						// ~outChannelsFXSpaceCuts[0].collect { |i, id| i.postln; id.postln };

						src = In.ar(in_bus, ~numChannelsFX);
						XOut.ar(in_bus, wet * env, efx)s

						src = ~outChannelsFXSpaceCuts[0].collect { |i| In.ar(i, 1) };
						~outChannelsFXSpaceCuts[0].collect { |i, id| XOut.ar(i, wet * env, efx[id]) };*/


						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								// var serverNb = 0; // 20.do {x = Synth(\Distort) };
								SynthDef(\Distort, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, pre_gain_HP = 0, amp = 0.2, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pre_gain;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = (src * pre_gain_E.lag2(lag)).distort * amp /** pre_gain_E.lag2(lag).reciprocal*/ ;

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
									mod_pre_gain = Control.names([\pre_gain_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										(src[i] * mod_pre_gain[i] );
									};

									efx = XFade2.ar(src, efx.distort * amp, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								// Utilisation de ReplaceOut.ar(out, XFade2.ar(dry, wet2, mix)) dans RedFrik - intérêt ???
								variants: (
									// a: [pre_gain_E: 5],
									a: [pre_gain_E: 10],
									b: [pre_gain_E: 50]),
								metadata: (
									specs: (
										// \out: \audiobus.asSpec,
										// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
									),
									specsR: (
										// \out: \audiobus.asSpec,
										// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
									),
									order: [
										\mix,
										\lag,
										\pre_gain_E
									],
									specsM: (
										\pre_gain_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pre_gain_HP
									],
									orderMod: [
										\pre_gain_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								// var serverNb = 0; // 20.do {x = Synth(\Distort) };
								SynthDef(\Distort, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, pre_gain_HP = 0, amp = 0.2, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pre_gain;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = (src * pre_gain_E.lag2(lag)).distort * amp /** pre_gain_E.lag2(lag).reciprocal*/ ;

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
									mod_pre_gain = Control.names([\pre_gain_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										(src[i] * mod_pre_gain[i] );
									};

									efx = XFade2.ar(src, efx.distort * amp, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								// Utilisation de ReplaceOut.ar(out, XFade2.ar(dry, wet2, mix)) dans RedFrik - intérêt ???
								variants: (
									// a: [pre_gain_E: 5],
									a: [pre_gain_E: 10],
									b: [pre_gain_E: 50]),
								metadata: (
									specs: (
										// \out: \audiobus.asSpec,
										// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
									),
									specsR: (
										// \out: \audiobus.asSpec,
										// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10) // en dessous de 10, le son est plus bas au niveau perceptif que le son normal
									),
									order: [
										\mix,
										\lag,
										\pre_gain_E
									],
									specsM: (
										\pre_gain_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pre_gain_HP
									],
									orderMod: [
										\pre_gain_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Pourquoi un distortGain seulement de 0 arrête le son du synthé quand le synthé d'origine n'est pas dirigé vers l'effet ???
						/*~fxSynthDef1.add(
						SynthDef(\DisTanh, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, amp = 0.2, lag = 1, mix = -1;
						var env, src, efx;
						env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
						src = In.ar(in_bus, ~numChannelsFX);
						efx = (src * pre_gain_E.lag2(lag)).tanh * amp /** pre_gain_E.lag2(lag).reciprocal*/;
						// Augmentation constante du gain selon distortGain / à compenser par distortGain.reciprocal mais le son avec une grosse distortion est trop faible
						// src = tanh(src) * distortGain.reciprocal;
						efx = XFade2.ar(src, efx, mix.varlag(lag));
						XOut.ar(in_bus, wet * env, efx)},
						variants: (
						a: [pre_gain_E: 10],
						b: [pre_gain_E: 50]),
						metadata: (
						specs: (
						// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
						\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
						),
						specsR: (
						// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
						\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
						),
						order: [
						\mix,
						\lag,
						\pre_gain_E
						]
						)
						).add;
						);*/

						~fxSynthDef1.add(
							SynthDef(\DisTanh, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, /*pre_gain_HP = 0,*/ amp = 0.2, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);

								efx = (src * pre_gain_E.lag2(lag))/*.tanh * amp*/;
								// * pre_gain_E.lag2(lag).reciprocal*/

								/*efx = 0 ! ~numChannelsFX;
								~numChannelsFX.collect { |i|
								var vol = (pre_gain_E.lag2(lag) * ((1 + i) * pre_gain_HP /*(pre_gain_HP.varlag(lag) * (((1.0473**i) * 1) - 1.5))*/))/*.poll*/;
								efx[i] = (src[i] * vol );
								};*/

								// Ajout d'un modulateur au contrôle -> * (1 + (mod * (((1.0473**i) * 1) - 1.5)))
								/*
								efx[0] = (src[0] * pre_gain_E.lag2(lag) * mod ).tanh * amp /** pre_gain_E.lag2(lag).reciprocal*/;
								efx[1] = (src[1] * pre_gain_E.lag2(lag) * mod * mod ).tanh * amp*/
								/*
								(1.0473**15) - 1
								16.collect { |i| i.postln; ( ( (1.0473**i) * 1) - 1.5 ) * 1 } // pour faire une variation entre 0.5 et 1.5, en ajoutant 1.
								16.collect { |i| i.postln; ( ( (1.0473**i) * 1.9) - 2.8 ) * 1 } // pour faire une variation entre 0.1 et 2, en ajoutant 1.
								*/
								// ~numChannelsFX.collect { |i| i.postln; ( ( ((i+1) /*/ (~numChannelsFX-1)*/ ) * 1) * ((20000 - 5) / ~numChannelsFX )) }


								// Augmentation constante du gain selon distortGain / à compenser par distortGain.reciprocal mais le son avec une grosse distortion est trop faible
								// src = tanh(src) * distortGain.reciprocal;
								efx = XFade2.ar(src, efx.tanh * amp, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							variants: (
								a: [pre_gain_E: 10],
								b: [pre_gain_E: 50]),
							metadata: (
								specs: (
									// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10),
									// \pre_gain_HP: ControlSpec(0, 1, 'lin', 0.001, 0)
								),
								specsR: (
									// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
									\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
								),
								order: [
									\mix,
									\lag,
									\pre_gain_E,
									// \pre_gain_HP
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\DisTanh, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, pre_gain_HP = 0, amp = 0.2, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pre_gain;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = (src * pre_gain_E.lag2(lag)).tanh * amp /** pre_gain_E.lag2(lag).reciprocal*/;

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_pre_gain = Control.names([\pre_gain_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										(src[i] * mod_pre_gain[i] );
									};

									// Augmentation constante du gain selon distortGain / à compenser par distortGain.reciprocal mais le son avec une grosse distortion est trop faible
									// src = tanh(src) * distortGain.reciprocal;
									efx = XFade2.ar(src, efx.tanh * amp, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								variants: (
									a: [pre_gain_E: 10],
									b: [pre_gain_E: 50]),
								metadata: (
									specs: (
										// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
									),
									specsR: (
										// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
									),
									order: [
										\mix,
										\lag,
										\pre_gain_E,
									],
									specsM: (
										\pre_gain_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pre_gain_HP
									],
									orderMod: [
										\pre_gain_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\DisTanh, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pre_gain_E = 10, pre_gain_HP = 0, amp = 0.2, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pre_gain;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = (src * pre_gain_E.lag2(lag)).tanh * amp /** pre_gain_E.lag2(lag).reciprocal*/;

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_pre_gain = Control.names([\pre_gain_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										(src[i] * mod_pre_gain[i] );
									};

									// Augmentation constante du gain selon distortGain / à compenser par distortGain.reciprocal mais le son avec une grosse distortion est trop faible
									// src = tanh(src) * distortGain.reciprocal;
									efx = XFade2.ar(src, efx.tanh * amp, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								variants: (
									a: [pre_gain_E: 10],
									b: [pre_gain_E: 50]),
								metadata: (
									specs: (
										// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
									),
									specsR: (
										// \distortGain: ControlSpec(0.01, 10, 'lin', 0.01, 2)
										\pre_gain_E: ControlSpec(5, 10000, 'exp', 0.01, 10)
									),
									order: [
										\mix,
										\lag,
										\pre_gain_E,
									],
									specsM: (
										\pre_gain_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pre_gain_HP
									],
									orderMod: [
										\pre_gain_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// A simplistic pitch-raising algorithm. It's not meant to sound natural; its sound is reminiscent of some weird mixture of filter, ring-modulator and pitch-shifter, depending on the input. The algorithm works by cutting the signal into fragments (delimited by upwards-going zero-crossings) and squeezing those fragments in the time domain (i.e. simply playing them back faster than they came in), leaving silences imbetween. All the parameters apart from memlen can be modulated.
						// This UGen is dedicated to Suburban Base Records. (It doesn't sound like them, but was half-inspired by them.)
						// check helpfile for more complicated examples
						/*
						b = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
						b = Buffer.read(s, p);
						*/

						~fxSynthDef1.add(
							SynthDef(\Squiz, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pitch_ratio_E = 2, zcpchunk_E = 1, /*pitch_ratio_HP = 0, zcpchunk_HP = 0,*/ memlen = 0.1, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);

								efx = Squiz.ar(src, pitch_ratio_E.lag2(lag), zcpchunk_E.lag2(lag), memlen );
								/*efx = 0 ! ~numChannelsFX;
								~numChannelsFX.collect { |i|
								// var vol = (pre_gain_E.lag2(lag) * (1 + i /*(pre_gain_HP.varlag(lag) * (((1.0473**i) * 1) - 1.5))*/)).poll;
								efx[i] = Squiz.ar(src[i], pitch_ratio_E.lag2(lag) * ((1 + i) * pitch_ratio_HP), zcpchunk_E.lag2(lag) * ((1 + i) * zcpchunk_HP), memlen );
								};*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
									\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)/*,
									\pitch_ratio_HP: ControlSpec(0, 1, 'lin', 0.001, 0),
									\zcpchunk_HP: ControlSpec(0, 1, 'lin', 0.001, 0)*/
								),
								specsR: (
									\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
									\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)
								),
								order: [
									\mix,
									\lag,
									\pitch_ratio_E,
									\zcpchunk_E,
									/*\pitch_ratio_HP,
									\zcpchunk_HP*/
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\Squiz, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pitch_ratio_E = 2, zcpchunk_E = 1, pitch_ratio_HP = 0, zcpchunk_HP = 0, memlen = 0.1, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pitch_ratio, mod_zcpchunk;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = Squiz.ar(src, pitch_ratio_E.lag2(lag), zcpchunk_E.lag2(lag), memlen );

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_pitch_ratio = Control.names([\pitch_ratio_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_zcpchunk = Control.names([\zcpchunk_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										Squiz.ar(src[i], mod_pitch_ratio[i], mod_zcpchunk[i], memlen);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
										\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)/*,
										\pitch_ratio_HP: ControlSpec(0, 1, 'lin', 0.001, 0),
										\zcpchunk_HP: ControlSpec(0, 1, 'lin', 0.001, 0)*/
									),
									specsR: (
										\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
										\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)
									),
									order: [
										\mix,
										\lag,
										\pitch_ratio_E,
										\zcpchunk_E,
										/*\pitch_ratio_HP,
										\zcpchunk_HP*/
									],
									specsM: (
										\pitch_ratio_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\zcpchunk_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pitch_ratio_HP,
										\zcpchunk_HP
									],
									orderMod: [
										\pitch_ratio_Mod,
										\zcpchunk_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\Squiz, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, pitch_ratio_E = 2, zcpchunk_E = 1, pitch_ratio_HP = 0, zcpchunk_HP = 0, memlen = 0.1, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_pitch_ratio, mod_zcpchunk;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = Squiz.ar(src, pitch_ratio_E.lag2(lag), zcpchunk_E.lag2(lag), memlen );

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_pitch_ratio = Control.names([\pitch_ratio_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_zcpchunk = Control.names([\zcpchunk_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										Squiz.ar(src[i], mod_pitch_ratio[i], mod_zcpchunk[i], memlen);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
										\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)/*,
										\pitch_ratio_HP: ControlSpec(0, 1, 'lin', 0.001, 0),
										\zcpchunk_HP: ControlSpec(0, 1, 'lin', 0.001, 0)*/
									),
									specsR: (
										\pitch_ratio_E: ControlSpec(1, 100, 'exp', 0.001, 1.5),
										\zcpchunk_E: ControlSpec(1, 100, 'exp', 0.001, 1)
									),
									order: [
										\mix,
										\lag,
										\pitch_ratio_E,
										\zcpchunk_E,
										/*\pitch_ratio_HP,
										\zcpchunk_HP*/
									],
									specsM: (
										\pitch_ratio_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\zcpchunk_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\pitch_ratio_HP,
										\zcpchunk_HP
									],
									orderMod: [
										\pitch_ratio_Mod,
										\zcpchunk_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Pb en multicanal - le fait de baisser le bits déclenche l'effet sur tous les canaux ?????????
						// L'argument bits de Decimator ne marche pas ?????????
						// port of some ladspa plugins
						// Decimates (reduces the effective sample rate), and reduces the bit depth of the input signal, allows non integer values for smooth transitions between clean and lofi signals.

						~fxSynthDef1.add(
							SynthDef(\Decim, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_6 = 44100, bits_2 = 24, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = Decimator.ar(src, rate_6.lag2(lag), bits_2.lag2(lag)); // limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb ???
								// efx = ~numChannels.collect { |i| efx = Decimator.ar(src[i], rate_6.lag2(lag), bits_2.lag2(lag)) };
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
									\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
								),
								specsR: (
									\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
									\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
								),
								order: [
									\mix,
									\lag,
									\rate_6,
									\bits_2
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\Decim, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_6 = 44100, bits_2 = 24, rate_HP = 0, bits_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_rate, mod_bits;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = Decimator.ar(src, rate_6.lag2(lag), bits_2.lag2(lag)); // limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb ???

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_bits = Control.names([\bits_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										Decimator.ar(src[i], mod_rate[i], mod_bits[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
										\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
									),
									specsR: (
										\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
										\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
									),
									order: [
										\mix,
										\lag,
										\rate_6,
										\bits_2
									],
									specsM: (
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\bits_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\rate_HP,
										\bits_HP
									],
									orderMod: [
										\rate_Mod,
										\bits_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\Decim, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_6 = 44100, bits_2 = 24, rate_HP = 0, bits_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_rate, mod_bits;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = Decimator.ar(src, rate_6.lag2(lag), bits_2.lag2(lag)); // limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb ???

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_bits = Control.names([\bits_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										Decimator.ar(src[i], mod_rate[i], mod_bits[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
										\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
									),
									specsR: (
										\rate_6: ControlSpec(4, 44100, 6, 1, 44100),
										\bits_2: ControlSpec(8, 24, 2, 0.01, 24) // - limité à 8 bits car sinon déclenché sur tous les canaux ou collect pour ne pas avoir le pb mais n'a aucun effet ???
									),
									order: [
										\mix,
										\lag,
										\rate_6,
										\bits_2
									],
									specsM: (
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\bits_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\rate_HP,
										\bits_HP
									],
									orderMod: [
										\rate_Mod,
										\bits_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// port of some ladspa plugins
						// Amplifies random half-cycles of it's input by multiplier. Set multiplier to 0 and vary probability for a weird fade effect, or set multiplier to -1 and probability to 0.5 to turn pitched sounds into noise.

						~fxSynthDef1.add(
							SynthDef(\Disin, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, probability = 0.5, multiplier = 0, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = Disintegrator.ar(src, probability.varlag(lag), multiplier.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
								),
								specsR: (
									\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
								),
								order: [
									\mix,
									\lag,
									\probability,
									\multiplier
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\Disin, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, probability = 0.5, multiplier = 0, probability_HP = 0, multiplier_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_probability, mod_multiplier;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = Disintegrator.ar(src, probability.varlag(lag), multiplier.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_probability = Control.names([\probability_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_multiplier = Control.names([\multiplier_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										Disintegrator.ar(src[i], mod_probability[i], mod_multiplier[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
									),
									specsR: (
										\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\probability,
										\multiplier
									],
									specsM: (
										\probability_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\multiplier_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\probability_HP,
										\multiplier_HP
									],
									orderMod: [
										\probability_Mod,
										\multiplier_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\Disin, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, probability = 0.5, multiplier = 0, probability_HP = 0, multiplier_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_probability, mod_multiplier;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = Disintegrator.ar(src, probability.varlag(lag), multiplier.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_probability = Control.names([\probability_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_multiplier = Control.names([\multiplier_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										Disintegrator.ar(src[i], mod_probability[i], mod_multiplier[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
									),
									specsR: (
										\probability: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\multiplier: ControlSpec(-1, 1, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\probability,
										\multiplier
									],
									specsM: (
										\probability_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\multiplier_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\probability_HP,
										\multiplier_HP
									],
									orderMod: [
										\probability_Mod,
										\multiplier_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						~fxSynthDef1.add(
							SynthDef(\RingMod, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E= 100, mul= 1, rate_E= 6, depth= 0, lag = 1, mix = -1, lagM = 1;
								var env, src, efx, lfo;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								lfo = SinOsc.ar(rate_E.lag2(lag), 0, mul.varlag(lag));
								// efx = src * SinOsc.ar(\freq_E.kr(440, lag) * [1, 2.pow(\depth.kr(0, lag) )] + lfo, 0, 1);
								efx = src * SinOsc.ar(freq_E.lag2(lag) * 2.pow(depth.varlag(lag) ) + lfo, 0, 1);
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\freq_E: \freq.asSpec,
									\mul: ControlSpec(0, 100, 'lin', 0, 1),
									\rate_E: \lofreq.asSpec,
									\depth: ControlSpec(-2, 2, 'lin', 0, 0)
								),
								specsR: (
									\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
									\mul: ControlSpec(0, 100, 'lin', 0, 1),
									\rate_E: \lofreq.asSpec,
									\depth: ControlSpec(-2, 2, 'lin', 0, 0)
								),
								order: [
									\mix,
									\lag,
									\freq_E,
									\mul,
									\rate_E,
									\depth
								]
							)
							).add;
						);
						/*
						RedEfxRing : RedEffectModule {
						*def {
						^SynthDef(\redEfxRing, {|out= 0, mix= -1, freq= 440, mul= 1, rate= 6, det= 0|
						var dry, wet, lfo;
						dry= In.ar(out, 2);
						lfo= SinOsc.ar(rate, 0, mul);
						wet= dry*SinOsc.ar(freq*[1, 2.pow(det)]+lfo, 0, 1);
						ReplaceOut.ar(out, XFade2.ar(dry, wet, mix));
						}, metadata: (
						specs: (
						\out: \audiobus.asSpec,
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\freq: \freq.asSpec,
						\mul: ControlSpec(0, 100, 'lin', 0, 1),
						\rate: \lofreq.asSpec,
						\det: ControlSpec(-2, 2, \lin, 0, 0)
						),
						order: [
						\out -> \ringOut,
						\mix -> \ringMix,
						\freq -> \ringFreq,
						\mul -> \ringMul,
						\rate -> \ringRate,
						\det -> \ringDet
						]
						));
						}
						}
						*/


						/*
						aussi voire RM octaver in SC examples/pieces/RM-octaver

						inSignal is RingModulated by a sinusoidal tone with half frequency.
						The resulting spectrum is given by all the components of inSignal with
						half freqs.
						This means that the new spectrum is a one 8ve below version of the input signal's one,
						with only odd partials.
						As a consequence, if inSignal is added again, even partials are
						recovered.

						See:
						Miller Puckette, The Theory and Technique of Electronic Music, p. 126
						http://crca.ucsd.edu/~msp/techniques/latest/book.pdf
						http://crca.ucsd.edu/~msp/techniques/latest/book-html/node77.html#sect5.ringmod

						andreavalle
						*/

						/*
						s = Server.local.waitForBoot({
						SynthDef.new(\RmOctaver, { var in, out = 0, freq, hasFreq ;
						in = SoundIn.ar(0) ;
						# freq, hasFreq = Pitch.kr(in) ;
						Out.ar(out, SinOsc.ar(freq: freq*0.5)*in+in);
						}).send(s) ;
						})
						)
						Synth.new(\RmOctaver);
						*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\RingMod, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 100, mul = 1, rate_E = 6, depth = 0, /*freq_HP = 0, mul_HP = 0, rate_HP = 0, depth_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, lfo, mod_freq, mod_mul, mod_rate, mod_depth;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									/*lfo = SinOsc.ar(rate_E.lag2(lag), 0, mul.varlag(lag));
									// efx = src * SinOsc.ar(\freq_E.kr(440, lag) * [1, 2.pow(\depth.kr(0, lag) )] + lfo, 0, 1);
									efx = src * SinOsc.ar(freq_E.lag2(lag) * 2.pow(depth.varlag(lag) ) + lfo, 0, 1);*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_freq = Control.names([\freq_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_mul = Control.names([\mul_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_depth = Control.names([\depth_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									lfo = 0 ! ~numChannelsFX2;
									efx = ~numChannelsFX2.collect { |i|
										lfo[i] = SinOsc.ar(mod_rate[i], 0, mod_mul[i]);
										src[i] * SinOsc.ar(mod_freq[i] * 2.pow(mod_depth[i]) + lfo[i], 0, 1);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\freq_E: \freq.asSpec,
										\mul: ControlSpec(0, 100, 'lin', 0, 1),
										\rate_E: \lofreq.asSpec,
										\depth: ControlSpec(-2, 2, 'lin', 0, 0)
									),
									specsR: (
										\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
										\mul: ControlSpec(0, 100, 'lin', 0, 1),
										\rate_E: \lofreq.asSpec,
										\depth: ControlSpec(-2, 2, 'lin', 0, 0)
									),
									order: [
										\mix,
										\lag,
										\freq_E,
										\mul,
										\rate_E,
										\depth
									],
									specsM: (
										\freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\mul_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\freq_HP,
										\mul_HP,
										\rate_HP,
										\depth_HP
									],
									orderMod: [
										\freq_Mod,
										\mul_Mod,
										\rate_Mod,
										\depth_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\RingMod, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 100, mul = 1, rate_E = 6, depth = 0, /*freq_HP = 0, mul_HP = 0, rate_HP = 0, depth_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, lfo, mod_freq, mod_mul, mod_rate, mod_depth;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									/*lfo = SinOsc.ar(rate_E.lag2(lag), 0, mul.varlag(lag));
									// efx = src * SinOsc.ar(\freq_E.kr(440, lag) * [1, 2.pow(\depth.kr(0, lag) )] + lfo, 0, 1);
									efx = src * SinOsc.ar(freq_E.lag2(lag) * 2.pow(depth.varlag(lag) ) + lfo, 0, 1);*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_freq = Control.names([\freq_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_mul = Control.names([\mul_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_depth = Control.names([\depth_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									lfo = 0 ! ~numChannelsFX;
									efx = ~numChannelsFX.collect { |i|
										lfo[i] = SinOsc.ar(mod_rate[i], 0, mod_mul[i]);
										src[i] * SinOsc.ar(mod_freq[i] * 2.pow(mod_depth[i]) + lfo[i], 0, 1);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\freq_E: \freq.asSpec,
										\mul: ControlSpec(0, 100, 'lin', 0, 1),
										\rate_E: \lofreq.asSpec,
										\depth: ControlSpec(-2, 2, 'lin', 0, 0)
									),
									specsR: (
										\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
										\mul: ControlSpec(0, 100, 'lin', 0, 1),
										\rate_E: \lofreq.asSpec,
										\depth: ControlSpec(-2, 2, 'lin', 0, 0)
									),
									order: [
										\mix,
										\lag,
										\freq_E,
										\mul,
										\rate_E,
										\depth
									],
									specsM: (
										\freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\mul_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\freq_HP,
										\mul_HP,
										\rate_HP,
										\depth_HP
									],
									orderMod: [
										\freq_Mod,
										\mul_Mod,
										\rate_Mod,
										\depth_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Problème avec synthé multi-canal - pour l'instant stéréo ????????? - à mettre en multi-canal
						// redFrik - with built in sawtooth and whitenoise consonant xfader
						// phase problem when xfading? - keep either full on or full off

						~fxSynthDef1.add(
							SynthDef(\Voco, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 400, cons = 1, lag = 1, mix = -1, lagM = 1;
								var /*dry, wet*/ src, efx, exc, chainA0, chainA1, chainB, x, env;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src/*dry*/= In.ar(in_bus, 2);
								x= (1-Pitch.kr(Mix(/*dry*/), clar:1)[1]) * cons.varlag(lag);
								exc= SelectX.ar(x, [LFSaw.ar(freq_E.lag2(lag)), WhiteNoise.ar]);
								chainA0= FFT(LocalBuf(2048), src[0]/*dry*//*[0]*/);
								chainA1= FFT(LocalBuf(2048), src[1]);
								chainB= FFT(LocalBuf(2048), exc);
								efx= IFFT([PV_MagMul(chainA0, chainB), PV_MagMul(chainA1, chainB)]) * 0.1;
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\freq_E: \freq.asSpec,
									\cons: ControlSpec(0, 1, 'lin', 0, 1)
								),
								specsR: (
									\freq_E: /*\freq.asSpec*/ ControlSpec(100, 20000, 'exp', 0, 150, " Hz"), // Modifié pour éviter des saturations dans le grave,
									\cons: ControlSpec(0, 1, 'lin', 0, 1)
								),
								order: [
									\mix,
									\lag,
									\freq_E,
									\cons
								]
							)
							).add;
						);
						/*RedEfxVoco : RedEffectModule {
						*def {
						^SynthDef(\redEfxVoco, {|out= 0, mix= -1, freq= 400, cons= 1|
						var dry, wet, exc, chainA0, chainA1, chainB, x;
						dry= In.ar(out, 2);
						x= (1-Pitch.kr(Mix(dry), clar:1)[1])*cons;
						exc= SelectX.ar(x, [LFSaw.ar(freq), WhiteNoise.ar]);
						chainA0= FFT(LocalBuf(2048), dry[0]);
						chainA1= FFT(LocalBuf(2048), dry[1]);
						chainB= FFT(LocalBuf(2048), exc);
						wet= IFFT([PV_MagMul(chainA0, chainB), PV_MagMul(chainA1, chainB)])*0.1;
						ReplaceOut.ar(out, XFade2.ar(dry, wet, mix));
						}, metadata: (
						specs: (
						\out: \audiobus.asSpec,
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\freq: \freq.asSpec,
						\cons: ControlSpec(0, 1, 'lin', 0, 1)
						),
						order: [
						\out -> \vocoOut,
						\mix -> \vocoMix,
						\freq -> \vocoFreq,
						\cons -> \vocoCons
						]
						));
						}
						}*/

					},{

						~fxSynthDef1.add(
							SynthDef(\Voco, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 400, cons = 1, /*freq_HP = 0, cons_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var /*dry, wet*/ src, efx, exc, chainA0, chainA1, chainB, x, env/*, mod_freq, mod_cons*/;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src/*dry*/= In.ar(in_bus, 2);

								// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
								/*
								mod_freq = Control.names([\freq_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
								mod_cons = Control.names([\cons_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
								*/

								x= (1-Pitch.kr(Mix(/*dry*/), clar:1)[1]) * cons.varlag(lag);
								exc= SelectX.ar(x, [LFSaw.ar(freq_E.lag2(lag)), WhiteNoise.ar]);
								chainA0= FFT(LocalBuf(2048), src[0]/*dry*//*[0]*/);
								chainA1= FFT(LocalBuf(2048), src[1]);
								chainB= FFT(LocalBuf(2048), exc);
								efx= IFFT([PV_MagMul(chainA0, chainB), PV_MagMul(chainA1, chainB)]) * 0.1;

								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\freq_E: \freq.asSpec,
									\cons: ControlSpec(0, 1, 'lin', 0, 1)
								),
								specsR: (
									\freq_E: /*\freq.asSpec*/ ControlSpec(100, 20000, 'exp', 0, 150, " Hz"), // Modifié pour éviter des saturations dans le grave,
									\cons: ControlSpec(0, 1, 'lin', 0, 1)
								),
								order: [
									\mix,
									\lag,
									\freq_E,
									\cons
								]/*,
								specsM: (
								\freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\cons_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\freq_HP,
								\cons_HP
								],
								orderMod: [
								\freq_Mod,
								\cons_Mod
								]*/
							)
							).add;
						);

					});





					if (~hpModulation == 0, {

						// FreqShift implements single sideband amplitude modulation, also known as frequency shifting, but not to be confused with pitch shifting. Frequency shifting moves all the components of a signal by a fixed amount but does not preserve the original harmonic relationships.

						~fxSynthDef1.add(
							SynthDef(\FreqS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 400, phase = 0, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = FreqShift.ar(src, freq_E.lag2(lag), phase.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\freq_E: \freq.asSpec,
									\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
								),
								specsR: (
									\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
									\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
								),
								order: [
									\mix,
									\lag,
									\freq_E,
									\phase
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\FreqS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 400, phase = 0, freq_HP = 0, phase_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_freq, mod_phase;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = FreqShift.ar(src, freq_E.lag2(lag), phase.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_freq = Control.names([\freq_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_phase = Control.names([\phase_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										FreqShift.ar(src[i], mod_freq[i], mod_phase[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\freq_E: \freq.asSpec,
										\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
									),
									specsR: (
										\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
										\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\freq_E,
										\phase
									],
									specsM: (
										\freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\phase_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\freq_HP,
										\phase_HP
									],
									orderMod: [
										\freq_Mod,
										\phase_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\FreqS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, freq_E = 400, phase = 0, freq_HP = 0, phase_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_freq, mod_phase;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = FreqShift.ar(src, freq_E.lag2(lag), phase.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_freq = Control.names([\freq_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_phase = Control.names([\phase_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										FreqShift.ar(src[i], mod_freq[i], mod_phase[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\freq_E: \freq.asSpec,
										\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
									),
									specsR: (
										\freq_E: /*\freq.asSpec*/ ControlSpec(20, 400, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX
										\phase: ControlSpec(0, 2pi, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\freq_E,
										\phase
									],
									specsM: (
										\freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\phase_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\freq_HP,
										\phase_HP
									],
									orderMod: [
										\freq_Mod,
										\phase_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// A time domain granular pitch shifter. Grains have a triangular amplitude envelope and an overlap of 4:1.
						// The size of the grain window in seconds. This value cannot be modulated

						~fxSynthDef1.add(
							SynthDef(\PitchS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, window_size = 0.2, pitch_ratio = 1, pitch_dispers = 0, time_dispers = 0, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = PitchShift.ar(src, window_size.varlag(lag), pitch_ratio.varlag(lag), pitch_dispers.varlag(lag), time_dispers.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
									\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
									\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
								),
								specsR: (
									\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
									\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
									\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
								),
								order: [
									\mix,
									\lag,
									\window_size,
									\pitch_ratio,
									\pitch_dispers,
									\time_dispers
								]
							)
							).add;
						);



						// A time domain granular pitch shifter. Grains have a triangular amplitude envelope and an overlap of 4:1.
						/*
						~fxSynthDef1.add(
						SynthDef(\FreqEvil, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, window_size = 0.2, pitch_ratio = 1, center_E = 200, pitch_dispers = 0, time_dispers = 0, lag = 1, mix = -1;
						var env, src, efx;
						env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
						src = In.ar(in_bus, ~numChannelsFX);
						efx = PitchShift.ar(src, window_size.varlag(lag), pitch_ratio.varlag(lag) * [0.25, 0.33], pitch_dispers.varlag(lag), time_dispers.varlag(lag));
						efx = FreqShift.ar(efx, center_E.varlag(lag) * (1-pitch_ratio.varlag(lag)) - [200, 100, 50]).sum;
						efx = XFade2.ar(src, efx, mix.varlag(lag));
						XOut.ar(in_bus, wet * env, efx)},
						metadata: (
						specs: (
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
						\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
						\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
						\center_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 200),
						\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
						\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
						),
						specsR: (
						\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
						\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
						\center_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 200),
						\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
						\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
						),
						order: [
						\mix,
						\lag,
						\window_size,
						\pitch_ratio,
						\center_E,
						\pitch_dispers,
						\time_dispers
						]
						)
						).add;
						);
						*/

						/*
						~fxSynthDef1.add(
						SynthDef(\freq-stretch-evil, { |stretch = 1, center = 440, out|
						var	sig = PlayBuf.ar(1, b, loop: 1);
						// stretched
						sig = PitchShift.ar(sig, 0.2, stretch * [0.25, 0.33], timeDispersion: 0.5, pitchDispersion: 0.5).sum;
						// re-centered
						sig = FreqShift.ar(sig, center * (1-stretch) - [200, 100, 50]).sum;
						Out.ar(out, sig ! 2);
						}, metadata: (specs: (stretch: [0.25, 4, \exp], center: \freq))).add;
						*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef1.add(
								SynthDef(\PitchS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, window_size = 0.2, pitch_ratio = 1, pitch_dispers = 0, time_dispers = 0, window_size_HP = 0, pitch_ratio_HP = 0, pitch_dispers_HP = 0, time_dispers_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_window_size, mod_pitch_ratio, mod_pitch_dispers, mod_time_dispers;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = PitchShift.ar(src, window_size.varlag(lag), pitch_ratio.varlag(lag), pitch_dispers.varlag(lag), time_dispers.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_window_size = Control.names([\window_size_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_pitch_ratio = Control.names([\pitch_ratio_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_pitch_dispers = Control.names([\pitch_dispers_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_time_dispers = Control.names([\time_dispers_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										PitchShift.ar(src[i], window_size, mod_pitch_ratio[i], mod_pitch_dispers[i], mod_time_dispers[i]);
										// Window size cannot be modulated ???????????????????????????????????????????????????????????????????????
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
										\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									),
									specsR: (
										\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
										\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									),
									order: [
										\mix,
										\lag,
										\window_size,
										\pitch_ratio,
										\pitch_dispers,
										\time_dispers
									],
									specsM: (
										\window_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\pitch_ratio_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\pitch_dispers_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\time_dispers_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\window_size_HP,
										\pitch_ratio_HP,
										\pitch_dispers_HP,
										\time_dispers_HP
									],
									orderMod: [
										\window_size_Mod,
										\pitch_ratio_Mod,
										\pitch_dispers_Mod,
										\time_dispers_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef1.add(
								SynthDef(\PitchS, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, window_size = 0.2, pitch_ratio = 1, pitch_dispers = 0, time_dispers = 0, window_size_HP = 0, pitch_ratio_HP = 0, pitch_dispers_HP = 0, time_dispers_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_window_size, mod_pitch_ratio, mod_pitch_dispers, mod_time_dispers;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = PitchShift.ar(src, window_size.varlag(lag), pitch_ratio.varlag(lag), pitch_dispers.varlag(lag), time_dispers.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_window_size = Control.names([\window_size_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_pitch_ratio = Control.names([\pitch_ratio_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_pitch_dispers = Control.names([\pitch_dispers_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_time_dispers = Control.names([\time_dispers_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										PitchShift.ar(src[i], window_size, mod_pitch_ratio[i], mod_pitch_dispers[i], mod_time_dispers[i]);
										// Window size cannot be modulated ???????????????????????????????????????????????????????????????????????
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
										\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									),
									specsR: (
										\window_size: ControlSpec(0, 1, 'lin', 0.01, 0.2),
										\pitch_ratio: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\pitch_dispers: ControlSpec(0.001, 4, 'lin', 0.001, 1),
										\time_dispers: ControlSpec(0, 1, 'lin', 0.01, 0.2),
									),
									order: [
										\mix,
										\lag,
										\window_size,
										\pitch_ratio,
										\pitch_dispers,
										\time_dispers
									],
									specsM: (
										\window_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\pitch_ratio_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\pitch_dispers_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\time_dispers_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\window_size_HP,
										\pitch_ratio_HP,
										\pitch_dispers_HP,
										\time_dispers_HP
									],
									orderMod: [
										\window_size_Mod,
										\pitch_ratio_Mod,
										\pitch_dispers_Mod,
										\time_dispers_Mod
									]
								)
								).add;
							);

						});

					});





					// http://sccode.org/1-4XD#c404
					// «Dissonator» by backseatviolist on 10 Apr'15 03:27 in effectdissonantring modulatorpsychoacoustic
					// as described in "Real-Time Dissonancizers: Two Dissonance-Augmenting Audio Effects"
					// by Matthew Hoffman and Perry Cook. put any kind of tonal sound into it for nasty detuned goodness

					// Son grave -> ne marche pas ?????????

					/*
					~fxSynthDef1.add(
					SynthDef(\Disson, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, wid = 1, lag = 1, mix = -1;
					// out = 0, mix = 1.0;
					var filterfreqs = Array.geom(23, 60, 2**(1/3));
					var rq = ((2**(1/3)) - 1) / (2**(1/6));
					var width = 2**(1/6) * wid.varlag(lag);
					var fmin = filterfreqs / width;
					var fmax = filterfreqs * width;
					var g = { |f| 2.27 * (f**0.477) };
					// var snd, mod;
					var env, src, efx;
					env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
					src = In.ar(in_bus, ~numChannelsFX);
					efx = BPF.ar(src, filterfreqs, rq);
					efx = efx * SinOsc.ar(0.5 * g.value((0.2*fmin) + (0.8*fmax)));
					/*mod = (1 - mix) + (mix * mod);
					snd = snd * mod;
					snd = Mix(snd);
					ReplaceOut.ar(out, snd)*/
					efx = XFade2.ar(src, efx, mix.varlag(lag));
					XOut.ar(in_bus, wet * env, efx)},
					metadata: (
					specs: (
					\mix: ControlSpec(-1, 1, 'lin', 0, 0),
					\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
					\wid: ControlSpec(0.1, 2, 'lin', 0.01, 1)
					),
					specsR: (
					\wid: ControlSpec(0.1, 2, 'lin', 0.01, 1)
					),
					order: [
					\mix,
					\lag,
					\wid
					]
					)
					).add;
					);
					*/

					/*
					SynthDef(\dissonator, {
					|out = 0, mix = 1.0|
					var filterfreqs = Array.geom(23, 60, 2**(1/3));
					var rq = ((2**(1/3)) - 1) / (2**(1/6));
					var width = 2**(1/6);
					var fmin = filterfreqs / width;
					var fmax = filterfreqs * width;
					var g = { |f| 2.27 * (f**0.477) };
					var snd, mod;
					snd = In.ar(out);
					snd = BPF.ar(snd, filterfreqs, rq);
					mod = SinOsc.ar(0.5 * g.value((0.2*fmin) + (0.8*fmax)));
					mod = (1 - mix) + (mix * mod);
					snd = snd * mod;
					snd = Mix(snd);
					ReplaceOut.ar(out, snd);
					}).add;
					*/





					/*

					// http://sccode.org/1-4ZT
					// «Grain Freeze» by patrickryanmcminn
					// SynthDef for capturing and holding incoming audio as a drone

					~fxSynthDef1.add(
					SynthDef(\Freeze, {
					|
					inBus = 0, outBus = 0, amp = 1,
					trigRate = 60, grainDur = 0.35, pos = 0.3, rate = 1,
					attackTime = 0.5, decayTime = 0, sustainLevel = 1, releaseTime = 2, /*gate = 1,*/
					lowPassCutoff = 7000, highPassCutoff = 100, postDistCutoff = 18000, distAmt = 1,
					in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, mix = -1
					|

					var grainTrig, granulation, env1, lpf, hpf, dist, sig;
					var env, src, efx, record;

					env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);

					// Record (into a 1 second, mono buffer)
					src = In.ar(in_bus, ~numChannelsFX);
					efx = LocalBuf.new(SampleRate.ir * 1, ~numChannelsFX).clear;
					record = RecordBuf.ar(src, efx, loop: 0);

					//// Granulate:
					// Random distribution of triggers prevents amplitude modulation artifacts
					grainTrig = Dust.ar(trigRate);
					granulation = GrainBuf.ar(1, grainTrig, grainDur, efx, rate, pos);

					// Filter and distort
					lpf = LPF.ar(granulation, lowPassCutoff);
					hpf = HPF.ar(lpf, highPassCutoff);
					dist = (hpf * distAmt).distort;
					dist = LPF.ar(dist, postDistCutoff);

					// Envelope -- delays start until recording has finished
					env1 = EnvGen.kr(Env.dadsr(1, attackTime, decayTime, sustainLevel, releaseTime), gate, amp, doneAction: 2);
					sig = dist * env1;

					efx = XFade2.ar(src, sig, mix.varlag(lag));
					XOut.ar(in_bus, wet * env, efx)},
					metadata: (
					specs: (
					\mix: ControlSpec(-1, 1, 'lin', 0, 0),
					\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
					\trigRate: ControlSpec(0.2, 200, 'lin', 0.1, 60),
					\grainDur: ControlSpec(0.1, 1, 'lin', 0.1, 0.35),
					\pos: ControlSpec(0.1, 1, 'lin', 0.1, 0.3),
					\rate: ControlSpec(0.1, 10, 'lin', 0.01, 1),
					\lPCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 7000),
					\HPCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 100),
					\postDistCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 18000)
					),
					specsR: (
					\trigRate: ControlSpec(0.2, 200, 'lin', 0.1, 60),
					\grainDur: ControlSpec(0.1, 1, 'lin', 0.1, 0.35),
					\pos: ControlSpec(0.1, 1, 'lin', 0.1, 0.3),
					\rate: ControlSpec(0.1, 10, 'lin', 0.01, 1),
					\lPCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 7000),
					\HPCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 100),
					\postDistCut_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 18000)
					),
					order: [
					\mix,
					\lag,
					\trigRate,
					\grainDur,
					\pos,
					\rate,
					\lPCut_E,
					\HPCut_E,
					\postDistCut_E
					]
					)
					).add;
					);
					*/





					// harmonizer Ugen in SC3

					/*
					I was just wondering if there is an harmonizer Ugen in SC3 and if so what's it called,
					mySignal + PitchShift.ar(mySignal, ...)
					hjh
					*/





					// IIRFilter - 24db/oct rolloff, 4nd order resonant Low Pass Filter - SC3plugins/BlackrainUGens

					// SVF - 12db/Oct State Variable Filter - SC3plugins/BhobUGens

					// NLFiltN / NLFiltL / NLFiltC - Non-linear Filter - SC3plugins/BhobUGens -> Implements the filter Y{n} =a Y{n-1} + b Y{n-2} + d Y^2{n-l} + X{n} - c described in Dobson and sigmoid clipping. This filter is inherently unstable, so pick some sane values and move slowly from there

					// LTI - Linear Time Invariant General Filter Equation

					// Klank / Resonz / Ringz - Bank of resonators

					// Formlet





					if (~hpModulation == 0, {

						// Problème - le noiselevel décleche sur tous les canaux si synthé mono ?????????
						// DFM1 is a digitally modelled analog filter. It provides low-pass and high-pass filtering. The filter can be overdriven and will self-oscillate at high resonances.
						// resonance & noiselevel agit sur les autres canaux ??? - InputGain à rajouter ???

						~fxSynthDef2.add(
							SynthDef(\DFM1, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 1000, resonance_E = 0.1, typeLH = 0, noise_level_E = 0.0003, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = DFM1.ar(src, cutoff_E.lag2(lag), resonance_E.lag2(lag), 1, typeLH.varlag(lag), noise_level_E.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\cutoff_E: \freq.asSpec,
									\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
									\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
									\noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
								),
								specsR: (
									\cutoff_E: \freq.asSpec,
									\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
									\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
									// \noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
								),
								order: [
									\mix,
									\lag,
									\cutoff_E,
									\resonance_E,
									\typeLH,
									\noise_level_E
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\DFM1, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 1000, resonance_E = 0.1, typeLH = 0, noise_level_E = 0.0003, cutoff_HP = 0, /*resonance_HP = 0, typeLH_HP = 0, noise_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance, mod_typeLH, mod_noise_level;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									efx = DFM1.ar(src, cutoff_E.lag2(lag), resonance_E.lag2(lag), 1, typeLH.varlag(lag), noise_level_E.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_typeLH = Control.names([\typeLH_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_noise_level = Control.names([\noise_level_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										DFM1.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_typeLH[i], mod_noise_level[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
										\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
										\noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
										\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
										// \noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance_E,
										\typeLH,
										\noise_level_E
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\typeLH_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\noise_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP,
										\typeLH_HP,
										\noise_level_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod,
										\typeLH_Mod,
										\noise_level_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\DFM1, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 1000, resonance_E = 0.1, typeLH = 0, noise_level_E = 0.0003, cutoff_HP = 0, /*resonance_HP = 0, typeLH_HP = 0, noise_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance, mod_typeLH, mod_noise_level;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									efx = DFM1.ar(src, cutoff_E.lag2(lag), resonance_E.lag2(lag), 1, typeLH.varlag(lag), noise_level_E.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_typeLH = Control.names([\typeLH_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_noise_level = Control.names([\noise_level_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										DFM1.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_typeLH[i], mod_noise_level[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
										\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
										\noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.1),
										\typeLH: ControlSpec(0, 1, 'lin', 1, 0),
										// \noise_level_E: ControlSpec(0.0001, 0.5, 'exp', 0.0001, 0.0003)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance_E,
										\typeLH,
										\noise_level_E
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\typeLH_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\noise_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP,
										\typeLH_HP,
										\noise_level_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod,
										\typeLH_Mod,
										\noise_level_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Pb de saturation si cutoff en dessous de 50 - & peut provoquer des clics ?????????
						// BlackRain's yet 'nother moog impersonation
						// 24db/oct rolloff - 4nd order resonant Low/High/Band Pass Filter
						// BMoog.scopeResponse
						// rq is the reciprocal of Q. Q is conventionally defined as cutoffFreq / bandwidth, meaning rq = (bandwidth / cutoffFreq)

						~fxSynthDef2.add(
							SynthDef(\BMoog, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, rq_E = 0.2, mode = 0, saturation_E = 0.001, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = BMoog.ar(src, cutoff_E.lag2(lag), rq_E.lag2(lag), mode.varlag(lag), saturation_E.lag2(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
									\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
									\mode: ControlSpec(0, 3, 'lin', 0.1, 0),
									\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
								),
								specsR: (
									\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
									\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
									// \mode: ControlSpec(0, 3, 'lin', 0.1, 0),
									\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
								),
								order: [
									\mix,
									\lag,
									\cutoff_E,
									\rq_E,
									\mode,
									\saturation_E
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\BMoog, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, rq_E = 0.2, mode = 0, saturation_E = 0.001, /*cutoff_HP = 0, rq_HP = 0, mode_HP = 0, saturation_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_rq, mod_mode, mod_saturation;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									efx = BMoog.ar(src, cutoff_E.lag2(lag), rq_E.lag2(lag), mode.varlag(lag), saturation_E.lag2(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_rq = Control.names([\rq_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_mode = Control.names([\mode_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_saturation = Control.names([\saturation_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										BMoog.ar(src[i], mod_cutoff[i], mod_rq[i], mod_mode[i], mod_saturation[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
										\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
										\mode: ControlSpec(0, 3, 'lin', 0.1, 0),
										\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
									),
									specsR: (
										\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
										\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
										// \mode: ControlSpec(0, 3, 'lin', 0.1, 0),
										\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\rq_E,
										\mode,
										\saturation_E
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\mode_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\saturation_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\rq_HP,
										\mode_HP,
										\saturation_HP
									],
									orderMod: [
										\cutoff_Mod,
										\rq_Mod,
										\mode_Mod,
										\saturation_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\BMoog, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, rq_E = 0.2, mode = 0, saturation_E = 0.001, /*cutoff_HP = 0, rq_HP = 0, mode_HP = 0, saturation_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_rq, mod_mode, mod_saturation;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									efx = BMoog.ar(src, cutoff_E.lag2(lag), rq_E.lag2(lag), mode.varlag(lag), saturation_E.lag2(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_rq = Control.names([\rq_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_mode = Control.names([\mode_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_saturation = Control.names([\saturation_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										BMoog.ar(src[i], mod_cutoff[i], mod_rq[i], mod_mode[i], mod_saturation[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
										\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
										\mode: ControlSpec(0, 3, 'lin', 0.1, 0),
										\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
									),
									specsR: (
										\cutoff_E: /*\freq.asSpec,*/ ControlSpec(50, 20000, 'exp', 1, 440),
										\rq_E: ControlSpec(0.001, 1.0, 'exp', 0.001, 0.2),
										// \mode: ControlSpec(0, 3, 'lin', 0.1, 0),
										\saturation_E: ControlSpec(0.001, 1.1, 'exp', 0.001, 0.95)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\rq_E,
										\mode,
										\saturation_E
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\mode_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\saturation_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\rq_HP,
										\mode_HP,
										\saturation_HP
									],
									orderMod: [
										\cutoff_Mod,
										\rq_Mod,
										\mode_Mod,
										\saturation_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// A digital implementation of the Moog VCF (filter), designed by Federico Fontana - Ported to C++ for SuperCollider by Dan Stowell
						// The design of this filter is described in the conference paper Fontana, F. (2007) Preserving the Digital Structure of the Moog VCF. In Proc. ICMC07

						~fxSynthDef2.add(
							SynthDef(\MoogFF, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, reset = 0, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = MoogFF.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), reset.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\cutoff_E: \freq.asSpec,
									\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
									\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
								),
								specsR: (
									\cutoff_E: \freq.asSpec,
									\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
									\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
								),
								order: [
									\mix,
									\lag,
									\cutoff_E,
									\resonance,
									\reset
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\MoogFF, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, reset = 0, cutoff_HP = 0, resonance_HP = 0, reset_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance, mod_reset;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = MoogFF.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), reset.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_reset = Control.names([\reset_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										MoogFF.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_reset[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
										\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
										\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance,
										\reset
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\reset_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP,
										\reset_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod,
										\reset_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\MoogFF, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, reset = 0, cutoff_HP = 0, resonance_HP = 0, reset_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance, mod_reset;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = MoogFF.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), reset.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_reset = Control.names([\reset_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										MoogFF.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_reset[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
										\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 4, 'lin', 0.01, 2),
										\reset: ControlSpec(0, 1, 'lin', 0.1, 0)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance,
										\reset
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\reset_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP,
										\reset_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod,
										\reset_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Moog Filter Emulation - SC3plugins/BhobUGens
						// based on code by Victor Lazzarini and Antti Huovilainen

						~fxSynthDef2.add(
							SynthDef(\MoogLa, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = MoogLadder.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\cutoff_E: \freq.asSpec,
									\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
								),
								specsR: (
									\cutoff_E: \freq.asSpec,
									\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
								),
								order: [
									\mix,
									\lag,
									\cutoff_E,
									\resonance
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\MoogLa, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, cutoff_HP = 0, resonance_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = MoogLadder.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										MoogLadder.ar(src[i], mod_cutoff[i], mod_resonance[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\MoogLa, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, cutoff_HP = 0, resonance_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_cutoff, mod_resonance;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = MoogLadder.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										MoogLadder.ar(src[i], mod_cutoff[i], mod_resonance[i]);
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
									),
									specsR: (
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0)
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance
									],
									specsM: (
										\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\cutoff_HP,
										\resonance_HP
									],
									orderMod: [
										\cutoff_Mod,
										\resonance_Mod
									]
								)
								).add;
							);

						});

					});





					// MoogVCF -> Josh UGen plugin





					if (~hpModulation == 0, {

						// TB303 Filter Emulation - SC3plugins/BhobUGens
						// This filter can be a little quiet, so i often multiply it by 3 or so. Watch out for high frequencies + hi res + hi dist = feedback
						// resonance and distortion are related. can become nasty when cutoff, res, and dist are all high. this is based on code by Josep M Comajuncosas meant to emulate the TB303

						~fxSynthDef2.add(
							SynthDef(\RLPFD, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, distortion = 0.1, mul = 0.01, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = RLPFD.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), distortion.varlag(lag), mul.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\cutoff_E: \freq.asSpec,
									\resonance: ControlSpec(0, /*4*/ 2, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
									\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
									\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
								),
								specsR: (
									\cutoff_E: /*\freq.asSpec*/ ControlSpec(20, 1500, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX,
									\resonance: ControlSpec(0, /*4*/ 1, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
									\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
									\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
								),
								order: [
									\mix,
									\lag,
									\cutoff_E,
									\resonance,
									\distortion,
									\mul
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\RLPFD, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, distortion = 0.1 /*, cutoff_HP = 0, resonance_HP = 0, distortion_HP = 0*/, mul = 0.01, lag = 1, mix = -1, lagM = 1;
									var env, src, efx/*, mod_cutoff, mod_resonance, mod_distortion, mod_mul*/;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									efx = RLPFD.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), distortion.varlag(lag), mul.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									/*mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_distortion = Control.names([\distortion_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_mul = Control.names([\mul_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX;
									~numChannelsFX.collect { |i|
									efx[i] = RLPFD.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_distortion[i], mod_mul[i]);
									};*/

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, /*4*/ 2, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
										\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
										\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
									),
									specsR: (
										\cutoff_E: /*\freq.asSpec*/ ControlSpec(20, 1500, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX,
										\resonance: ControlSpec(0, /*4*/ 1, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
										\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
										\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance,
										\distortion,
										\mul
									]/*,
									specsM: (
									\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\distortion_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\mul_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
									\cutoff_HP,
									\resonance_HP,
									\distortion_HP,
									\mul_HP
									],
									orderMod: [
									\cutoff_Mod,
									\resonance_Mod,
									\distortion_Mod,
									\mul_Mod
									]*/
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\RLPFD, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, cutoff_E = 440, resonance = 0.01, distortion = 0.1 /*, cutoff_HP = 0, resonance_HP = 0, distortion_HP = 0*/, mul = 0.01, lag = 1, mix = -1, lagM = 1;
									var env, src, efx/*, mod_cutoff, mod_resonance, mod_distortion, mod_mul*/;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									efx = RLPFD.ar(src, cutoff_E.lag2(lag), resonance.varlag(lag), distortion.varlag(lag), mul.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									/*mod_cutoff = Control.names([\cutoff_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_distortion = Control.names([\distortion_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_mul = Control.names([\mul_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX;
									~numChannelsFX.collect { |i|
									efx[i] = RLPFD.ar(src[i], mod_cutoff[i], mod_resonance[i], mod_distortion[i], mod_mul[i]);
									};*/

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\cutoff_E: \freq.asSpec,
										\resonance: ControlSpec(0, /*4*/ 2, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
										\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
										\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
									),
									specsR: (
										\cutoff_E: /*\freq.asSpec*/ ControlSpec(20, 1500, 'exp', 0, 100, " Hz"), // Modifié pour éviter d'être trop aigu XXXXXXXXX,
										\resonance: ControlSpec(0, /*4*/ 1, 'lin', 0.01, 2), // Changement des ControlSpec car trop aigu XXXXXXXXX
										\distortion: ControlSpec(0, 1, 'lin', 0.1, 0),
										\mul: ControlSpec(0, /*3*/ 1, 'lin', 0.01, 1), // Changement des ControlSpec car trop aigu XXXXXXXXX
									),
									order: [
										\mix,
										\lag,
										\cutoff_E,
										\resonance,
										\distortion,
										\mul
									]/*,
									specsM: (
									\cutoff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\distortion_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\mul_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
									\cutoff_HP,
									\resonance_HP,
									\distortion_HP,
									\mul_HP
									],
									orderMod: [
									\cutoff_Mod,
									\resonance_Mod,
									\distortion_Mod,
									\mul_Mod
									]*/
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// String resonance filter - SC3plugins/BhobUGens
						// This filter is based on Victor Lazzrini's csound opcode by the same name
						// delayTime -> delay (1/ffreq)
						// Son intéressant en modifiant le delayTime et résonance = 1

						~fxSynthDef2.add(
							SynthDef(\Streson, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 0.003, resonance = 0.9, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								efx = Streson.ar(src, delay_time.varlag(lag), resonance.varlag(lag));
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
									\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
								),
								specsR: (
									\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
									\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
								),
								order: [
									\mix,
									\lag,
									\delay_time,
									\resonance
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\Streson, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 0.003, resonance = 0.9, /*delay_time_HP = 0, resonance_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx/*, mod_delay_time, mod_resonance*/;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									efx = Streson.ar(src, delay_time.varlag(lag), resonance.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									/*mod_delay_time = Control.names([\delay_time_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX;
									~numChannelsFX.collect { |i|
									efx[i] = Streson.ar(src[i], mod_delay_time[i], mod_resonance[i]);
									};*/

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
									),
									specsR: (
										\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
									),
									order: [
										\mix,
										\lag,
										\delay_time,
										\resonance
									]/*,
									specsM: (
									\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
									\delay_time_HP,
									\resonance_HP
									],
									orderMod: [
									\delay_time_Mod,
									\resonance_Mod
									]*/
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\Streson, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 0.003, resonance = 0.9, /*delay_time_HP = 0, resonance_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx/*, mod_delay_time, mod_resonance*/;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									efx = Streson.ar(src, delay_time.varlag(lag), resonance.varlag(lag));

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									/*mod_delay_time = Control.names([\delay_time_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_resonance = Control.names([\resonance_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX;
									~numChannelsFX.collect { |i|
									efx[i] = Streson.ar(src[i], mod_delay_time[i], mod_resonance[i]);
									};*/

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
									),
									specsR: (
										\delay_time: ControlSpec(0, 1, 'lin', 0.001, 0.003),
										\resonance: ControlSpec(0, 1, 'lin', 0.01, 0.9)
									),
									order: [
										\mix,
										\lag,
										\delay_time,
										\resonance
									]/*,
									specsM: (
									\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									\resonance_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
									\delay_time_HP,
									\resonance_HP
									],
									orderMod: [
									\delay_time_Mod,
									\resonance_Mod
									]*/
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// Certaines valeurs ffreq importantes de ffreq & depth provoque des sons intéressants mais très forts même quand le mix est à -1 ?????????

						~fxSynthDef2.add(
							SynthDef(\Wah, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_E = 0.7, ffreq_E = 1000, depth = 0.8, rq = 0.0001, lag = 1, mix = -1, lagM = 1;
								var env, src, efx, lfo;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								lfo = LFNoise1.kr(rate_E./*lag2*/varlag(lag), depth.varlag(lag) * ffreq_E./*lag2*/varlag(lag), ffreq_E./*lag2*/varlag(lag));
								src = In.ar(in_bus, ~numChannelsFX);
								efx = RLPF.ar(src, lfo, rq.varlag(lag), 10).distort * 0.15;
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							variants: (
								a: [rate_E: 0.7, ffreq_E: 1200, depth: 0.8, rq: 0.1],
								b: [rate_E: 2, ffreq_E: 2000, depth: 0.8, rq: 0.2],
								c: [rate_E: 4, ffreq_E: 1200, depth: 0.8, rq: 0.1],
								d: [rate_E: 8, ffreq_E: 2000, depth: 0.8, rq: 0.2]),
							metadata: (
								specs: (
									\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
									\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
									\depth: ControlSpec(0, 50, 'lin', 0, 2),
									\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
								),
								specsR: (
									\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
									\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
									\depth: ControlSpec(0, 50, 'lin', 0, 2),
									\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
								),
								order: [
									\mix,
									\lag,
									\rate_E,
									\ffreq_E,
									\depth,
									\rq
								]
							)
							).add;
						);
						/*~fxSynthDef.add(
						SynthDef(\wah, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate = 0.7, ffreq = 1200, depth = 0.8, rq = 0.1;
						var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
						var lfo = LFNoise1.kr(rate, depth * ffreq, ffreq);
						var src = In.ar(in_bus, 1);
						src = RLPF.ar(src, lfo, rq, 10).distort * 0.15;
						XOut.ar(in_bus, wet * env, src)},
						variants: (
						a: [rate: 0.7, ffreq: 1200, depth: 0.8, rq: 0.1],
						b: [rate: 2, ffreq: 2000, depth: 0.8, rq: 0.2],
						c: [rate: 4, ffreq: 1200, depth: 0.8, rq: 0.1],
						d: [rate: 8, ffreq: 2000, depth: 0.8, rq: 0.2]),
						metadata: (
						specs: (
						// \out: \audiobus.asSpec,
						// \mix: ControlSpec(-1, 1, 'lin', 0, -1),
						// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
						\rate: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
						\ffreq: ControlSpec(20, 15000, 'lin', 0, 1000),
						\depth: ControlSpec(0, 50, 'lin', 0, 2),
						\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
						),
						order: [
						\rate,
						\ffreq,
						\depth,
						\rq
						]
						)
						).add;
						);*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef2.add(
								SynthDef(\Wah, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_E = 0.7, ffreq_E = 1000, depth = 0.8, rq = 0.0001, /*rate_HP = 0, ffreq_HP = 0, depth_HP = 0, rq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, lfo, mod_rate, mod_ffreq, mod_depth, mod_rq;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									/*lfo = LFNoise1.kr(rate_E.lag2(lag), depth.varlag(lag) * ffreq_E.lag2(lag), ffreq_E.lag2(lag));
									efx = RLPF.ar(src, lfo, rq.varlag(lag), 10).distort * 0.15;*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX2)./*lag2*/varlag(lag)/*.poll*/;
									mod_ffreq = Control.names([\ffreq_Mod]).kr(0 ! ~numChannelsFX2)./*lag2*/varlag(lag)/*.poll*/;
									mod_depth = Control.names([\depth_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_rq = Control.names([\rq_Mod]).kr(0 ! ~numChannelsFX2)./*lag2*/varlag(lag)/*.poll*/;

									lfo = 0 ! ~numChannelsFX2;
									efx = ~numChannelsFX2.collect { |i|
										lfo[i] = LFNoise1.kr(mod_rate[i], mod_depth[i] * mod_ffreq[i], mod_ffreq[i]); /*lfo[0].poll;*/
										RLPF.ar(src[i], lfo[i], mod_rq[i], 10).distort * 0.15;
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								variants: (
									a: [rate_E: 0.7, ffreq_E: 1200, depth: 0.8, rq: 0.1],
									b: [rate_E: 2, ffreq_E: 2000, depth: 0.8, rq: 0.2],
									c: [rate_E: 4, ffreq_E: 1200, depth: 0.8, rq: 0.1],
									d: [rate_E: 8, ffreq_E: 2000, depth: 0.8, rq: 0.2]),
								metadata: (
									specs: (
										\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
										\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
										\depth: ControlSpec(0, 50, 'lin', 0, 2),
										\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
									),
									specsR: (
										\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
										\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
										\depth: ControlSpec(0, 50, 'lin', 0, 2),
										\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
									),
									order: [
										\mix,
										\lag,
										\rate_E,
										\ffreq_E,
										\depth,
										\rq
									],
									specsM: (
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\ffreq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\rate_HP,
										\ffreq_HP,
										\depth_HP,
										\rq_HP
									],
									orderMod: [
										\rate_Mod,
										\ffreq_Mod,
										\depth_Mod,
										\rq_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef2.add(
								SynthDef(\Wah, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rate_E = 0.7, ffreq_E = 1000, depth = 0.8, rq = 0.0001, /*rate_HP = 0, ffreq_HP = 0, depth_HP = 0, rq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
									var env, src, efx, lfo, mod_rate, mod_ffreq, mod_depth, mod_rq;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									/*lfo = LFNoise1.kr(rate_E.lag2(lag), depth.varlag(lag) * ffreq_E.lag2(lag), ffreq_E.lag2(lag));
									efx = RLPF.ar(src, lfo, rq.varlag(lag), 10).distort * 0.15;*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX)./*lag2*/varlag(lag)/*.poll*/;
									mod_ffreq = Control.names([\ffreq_Mod]).kr(0 ! ~numChannelsFX)./*lag2*/varlag(lag)/*.poll*/;
									mod_depth = Control.names([\depth_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_rq = Control.names([\rq_Mod]).kr(0 ! ~numChannelsFX)./*lag2*/varlag(lag)/*.poll*/;

									lfo = 0 ! ~numChannelsFX;
									efx = ~numChannelsFX.collect { |i|
										lfo[i] = LFNoise1.kr(mod_rate[i], mod_depth[i] * mod_ffreq[i], mod_ffreq[i]); /*lfo[0].poll;*/
										RLPF.ar(src[i], lfo[i], mod_rq[i], 10).distort * 0.15;
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)},
								variants: (
									a: [rate_E: 0.7, ffreq_E: 1200, depth: 0.8, rq: 0.1],
									b: [rate_E: 2, ffreq_E: 2000, depth: 0.8, rq: 0.2],
									c: [rate_E: 4, ffreq_E: 1200, depth: 0.8, rq: 0.1],
									d: [rate_E: 8, ffreq_E: 2000, depth: 0.8, rq: 0.2]),
								metadata: (
									specs: (
										\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
										\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
										\depth: ControlSpec(0, 50, 'lin', 0, 2),
										\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
									),
									specsR: (
										\rate_E: ControlSpec(0.0001, 200, 'exp', 0.0001, 2),
										\ffreq_E: ControlSpec(20, 15000, 'exp', 0, 1000),
										\depth: ControlSpec(0, 50, 'lin', 0, 2),
										\rq: ControlSpec(0, 3, 'lin', 0.0001, 0.2)
									),
									order: [
										\mix,
										\lag,
										\rate_E,
										\ffreq_E,
										\depth,
										\rq
									],
									specsM: (
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\ffreq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\rate_HP,
										\ffreq_HP,
										\depth_HP,
										\rq_HP
									],
									orderMod: [
										\rate_Mod,
										\ffreq_Mod,
										\depth_Mod,
										\rq_Mod
									]
								)
								).add;
							);

						});

					});










					// EQ UnitLib
					// Vérifier que varlag ne change pas les ressources en CPU vs \eqSetting.kr( ~eqUnitLib3.setting, lag ) XXXXXXXXX

					~defEQUnitLib = EQdef /*( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf )*/; // define een eq (name, Filter class)
					~nbOfEQ = 3;
					if (currentEnvironment[server] == ~server1, { ~eqUnitLib = 0 ! 2 });
					~eqUnitLib[serverNb] = EQSetting( ~defEQUnitLib ) ! ~nbOfEQ;

					~eqSynthDefNames = [\EQ1, \EQ2, \EQ3];


					if (~fx16Split == 1, {

						~nbOfEQ.do { |i|
							~fxSynthDef2b.add(
								SynthDef(~eqSynthDefNames[i], {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
									var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									// var src = In.ar(in_bus, ~numChannelsFX);
									var src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									src = ~eqUnitLib[serverNb][i].ar( src, \eqSetting.kr(~eqUnitLib[serverNb][i].setting).varlag(lag) );
									// XOut.ar(in_bus, wet * env, src)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, src[id]) }},
								).add;
							);
						};

					},{

						~nbOfEQ.do { |i|
							~fxSynthDef2b.add(
								SynthDef(~eqSynthDefNames[i], {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
									var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									var src = In.ar(in_bus, ~numChannelsFX);
									src = ~eqUnitLib[serverNb][i].ar( src, \eqSetting.kr(~eqUnitLib[serverNb][i].setting).varlag(lag) );
									XOut.ar(in_bus, wet * env, src)},
								).add;
							);
						};

					});

					/* OLD
					~defEQUnitLib = EQdef /*( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf )*/; // define een eq (name, Filter class)
					~eqUnitLib1 = EQSetting( ~defEQUnitLib ); // define een setting instance, based on def
					~fxSynthDef2b.add(
					SynthDef(\EQ1, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
					var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
					var src = In.ar(in_bus, ~numChannelsFX);
					src = ~eqUnitLib1.ar( src, \eqSetting.kr(~eqUnitLib1.setting).varlag(lag) );
					XOut.ar(in_bus, wet * env, src)},
					).add;
					);

					// ~defEQUnitLib2 = EQdef /*( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf )*/; // define een eq (name, Filter class)
					~eqUnitLib2 = EQSetting( ~defEQUnitLib ); // define een setting instance, based on def
					~fxSynthDef2b.add(
					SynthDef(\EQ2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
					var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
					var src = In.ar(in_bus, ~numChannelsFX);
					src = ~eqUnitLib2.ar( src, \eqSetting.kr(~eqUnitLib2.setting).varlag(lag) );
					XOut.ar(in_bus, wet * env, src)},
					).add;
					);

					// ~defEQUnitLib3 = EQdef /*( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf )*/; // define een eq (name, Filter class)
					~eqUnitLib3 = EQSetting( ~defEQUnitLib ); // define een setting instance, based on def
					~fxSynthDef2b.add(
					SynthDef(\EQ3, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
					var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
					var src = In.ar(in_bus, ~numChannelsFX);
					src = ~eqUnitLib3.ar( src, \eqSetting.kr(~eqUnitLib3.setting).varlag(lag) );
					XOut.ar(in_bus, wet * env, src)},
					).add;
					);
					*/



					// Synthés pour les EQ Channels à la fin des groupes

					~defEQUnitLib2 = EQdef ( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf ); // define een eq (name, Filter class)
					~nbOfChannelEQ = 9 /*~nbOfTracks+1 // Le nb de Tracks n'est pas encore défini*/ ; // +1 pour les canaux FX
					if (currentEnvironment[server] == ~server1, { ~eqChannelUnitLib = 0 ! 2 });
					~eqChannelUnitLib[serverNb] = EQSetting( ~defEQUnitLib2 ) ! ~nbOfChannelEQ;
					// ~eqChannelUnitLib.do { |i| i.set( \lowShelf, \freq, 150); i.set( \peak, \freq, 1500); i.set( \hiShelf, \freq, 5000); }; // setting parameters à intégrer dans la GUI car sinon pas mis à jour

					~eqChannelSynthDefNames = [\EQCha1, \EQCha2, \EQCha3, \EQCha4, \EQCha5, \EQCha6, \EQCha7, \EQCha8, \EQChaFX];

					~nbOfChannelEQ.do { |i|
						~fxSynthDef2Cha.add(
							SynthDef(~eqChannelSynthDefNames[i], {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1;
								var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								var src = In.ar(in_bus, ~numChannelsFX);
								src = ~eqChannelUnitLib[serverNb][i].ar( src, \eqSetting.kr(~eqChannelUnitLib[serverNb][i].setting).varlag(lag) );
								XOut.ar(in_bus, wet * env, src)},
							).add;
						);
					};

					/*
					~def = EQdef( 'lowShelf', BLowShelf, 'peak', BPeakEQ, 'hiShelf', BHiShelf ); // define een eq (name, Filter class)
					~eq = EQSetting( ~def ); // define een setting instance, based on def
					~eq.set( \hiShelf, \freq, 2000); // setting parameters
					~synth = { ~eq.ar( WhiteNoise.ar(0.1), \eqSetting.kr( ~eq.setting ) ) }.play; // use it in a synth
					// \eqSetting is an array, with as default value de current eq setting
					~view = EQView( eqSetting: ~eq ); // create a gui
					~view.action = { |view, setting| ~synth.set( \eqSetting, setting ) } // make sure it updates your synth
					*/










					// Effets spectraux

					~fftEQSize = 1024; // FFTsize containing for each bin -> magnitude and phase - à diviser / 2 pour obtenir la taille réelle de la FFT // léger ralentissement lorsque modif des minisliders des bins avec des valeurs aléatoires avec FFTsize de 2048
					~fftEQNbOfBins = ~fftEQSize / 2;
					if (currentEnvironment[server] == ~server1, { ~fftEQBufValues = 0 ! 2; ~fftEQBufs = 0 ! 2; });
					~fftEQBufValues[serverNb] = 0 ! ~fftEQSize ! 2; // initialize FFT buffer values

					~fftEQBufs[serverNb] = 2.collect { |i| Buffer.loadCollection(currentEnvironment[serverFXV], ~fftEQBufValues[serverNb][i]) }; // cette ligne remplace les 2 lignes c-dessous
					/*
					~fftEQBufs = 2.collect { Buffer.alloc(s, ~fftEQSize, 1) };
					~fftEQBufs.do { |buf, i| buf.loadCollection(~fftEQBufValues[i]) };
					*/
					// currentEnvironment[server].sync; // utile ???

					if (~fx16Split == 1, {

						~fxSynthDef2c.add(
							SynthDef(\FFTEQ, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftEQSize = ~fftEQSize, bufnum1 = ~fftEQBufs[serverNb][0], bufnum2 = ~fftEQBufs[serverNb][0], fade = (-1);
								var env, src, chain1, chain2, filtered1, filtered2, filtered;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2)/*.poll*/; // Pourquoi linen ne revient jamais vraiment à 0, mais ok pour aller à 1 ???
								src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
								// src = In.ar(in_bus, ~numChannelsFX);

								chain1 = ~numChannelsFX2.collect { |i| FFT(LocalBuf(fftEQSize, 1), src[i], 0.25) };
								chain2 = PV_Copy(chain1, {LocalBuf(fftEQSize, 1)} ! ~numChannelsFX2); // copy the initial analysis
								filtered1 = PV_MagMul(chain1, bufnum1);
								filtered2 = PV_MagMul(chain2, bufnum2);

								filtered = XFade2.ar(IFFT(filtered1), IFFT(filtered2), fade.varlag(lag));
								// PV_XFade + doux que XFade2 - voire PV_Morph ???
								// filtered = /*PV_Morph*/ PV_XFade(filtered1, filtered2, fade.varlag(lag));
								// filtered = IFFT(filtered);

								// XOut.ar(in_bus, wet * env, filtered);
								~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, filtered[id]) };
								// ReplaceOut.ar(in_bus, filtered);
							}).add;
						);

					},{

						~fxSynthDef2c.add(
							SynthDef(\FFTEQ, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftEQSize = ~fftEQSize, bufnum1 = ~fftEQBufs[serverNb][0], bufnum2 = ~fftEQBufs[serverNb][0], fade = (-1);
								var env, src, chain1, chain2, filtered1, filtered2, filtered;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2)/*.poll*/; // Pourquoi linen ne revient jamais vraiment à 0, mais ok pour aller à 1 ???
								src = In.ar(in_bus, ~numChannelsFX);

								chain1 = ~numChannelsFX.collect { |i| FFT(LocalBuf(fftEQSize, 1), src[i], 0.25) };
								chain2 = PV_Copy(chain1, {LocalBuf(fftEQSize, 1)} ! ~numChannelsFX); // copy the initial analysis
								filtered1 = PV_MagMul(chain1, bufnum1);
								filtered2 = PV_MagMul(chain2, bufnum2);

								filtered = XFade2.ar(IFFT(filtered1), IFFT(filtered2), fade.varlag(lag));
								// PV_XFade + doux que XFade2 - voire PV_Morph ???
								// filtered = /*PV_Morph*/ PV_XFade(filtered1, filtered2, fade.varlag(lag));
								// filtered = IFFT(filtered);

								XOut.ar(in_bus, wet * env, filtered);
								// ReplaceOut.ar(in_bus, filtered);
							}).add;
						);

					});

					~fftDelSize = 512;
					~fftDelNbOfBins = ~fftDelSize / 2;
					if (currentEnvironment[server] == ~server1, { ~fftDelfbValues = 0 ! 2; ~fftDelfbBufs = 0 ! 2; });
					~fftDelfbValues[serverNb] = 0 ! ~fftDelNbOfBins ! 4; // initialize delay and feedback values

					~fftDelfbBufs[serverNb] = Array.fill(4, {Buffer.alloc(currentEnvironment[serverFXV], ~fftDelNbOfBins, 1)}); // initialize delay and feedback buffer
					~fftDelfbBufs[serverNb].do { |buf, i| buf.setn(0, ~fftDelfbValues[serverNb][i]) }; // Allocate & Fill ranges of sample value(s)
					// currentEnvironment[server].sync; // utile ???

					if (~fx16Split == 1, {

						~fxSynthDef2c.add(
							SynthDef(\FFTDelay, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftDelSize = ~fftDelSize, dels1 = ~fftDelfbBufs[serverNb][0], fb1 = ~fftDelfbBufs[serverNb][1], dels2 = ~fftDelfbBufs[serverNb][2], fb2 = ~fftDelfbBufs[serverNb][3], fade = 0;
								var env, src, chain1, chain2, delay1, delay2, delay;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
								// src = In.ar(in_bus, ~numChannelsFX);

								chain1 = ~numChannelsFX2.collect { |i| FFT(LocalBuf(fftDelSize, 1), src[i], 0.25) };
								chain2 = PV_Copy(chain1, {LocalBuf(fftDelSize, 1)} ! ~numChannelsFX2); // copy the initial analysis

								delay1 = PV_BinDelay(chain1, 1.0, dels1, fb1, 0.25);
								delay2 = PV_BinDelay(chain2, 1.0, dels2, fb2, 0.25);
								delay = /*PV_Morph*/ PV_XFade(delay1, delay2, fade.varlag(lag));
								delay = IFFT(delay);

								// XOut.ar(in_bus, wet * env, delay);
								~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, delay[id]) };
							}).add;
						);

					},{

						~fxSynthDef2c.add(
							SynthDef(\FFTDelay, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftDelSize = ~fftDelSize, dels1 = ~fftDelfbBufs[serverNb][0], fb1 = ~fftDelfbBufs[serverNb][1], dels2 = ~fftDelfbBufs[serverNb][2], fb2 = ~fftDelfbBufs[serverNb][3], fade = 0;
								var env, src, chain1, chain2, delay1, delay2, delay;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);

								chain1 = ~numChannelsFX.collect { |i| FFT(LocalBuf(fftDelSize, 1), src[i], 0.25) };
								chain2 = PV_Copy(chain1, {LocalBuf(fftDelSize, 1)} ! ~numChannelsFX); // copy the initial analysis

								delay1 = PV_BinDelay(chain1, 1.0, dels1, fb1, 0.25);
								delay2 = PV_BinDelay(chain2, 1.0, dels2, fb2, 0.25);
								delay = /*PV_Morph*/ PV_XFade(delay1, delay2, fade.varlag(lag));
								delay = IFFT(delay);

								XOut.ar(in_bus, wet * env, delay);
							}).add;
						);

					});

					~numChannelsFX16 = ~numChannelsFX.min(16);
					~fftOutSize = 1024;
					~fftOutNbOfBins = ~fftOutSize / 2;
					if (currentEnvironment[server] == ~server1, { ~fftOut1MagValues = 0 ! 2; ~fftOutMagPhaValues = 0 ! 2; ~fftOutChannelValues = 0 ! 2; ~fftOutBufs = 0 ! 2; });
					~fftOut1MagValues[serverNb] = {0 ! ~fftOutNbOfBins ! ~numChannelsFX16} ! 2;
					~fftOutMagPhaValues[serverNb] = {0 ! ~fftOutSize ! ~numChannelsFX16} ! 2;
					~fftOutChannelValues[serverNb] = 0 ! ~fftOutNbOfBins ! 2;
					// ~fftOutChannelValues[0] = Array.fill(~fftOutNbOfBins, {~numChannelsFX.rand});
					// ~fftOutChannelValues.cs; // Random Selection of a bin to a specific channel
					// ~fftOutChannelValues[0].indicesOfEqual(0);

					2.do { |a| ~numChannelsFX16.do { |ch| ~fftOut1MagValues[serverNb][a][ch].do { |item, i| if (~fftOutChannelValues[serverNb][a][i] == ch, {~fftOut1MagValues[serverNb][a][ch][i] = 1}, {~fftOut1MagValues[serverNb][a][ch][i] = 0}) } } };
					// ~fftOut1MagValues[0].cs; // Amplitude of bins for each channel
					2.do { |a| ~numChannelsFX16.do { |ch| ~fftOutMagPhaValues[serverNb][a][ch] = [~fftOut1MagValues[serverNb][a][ch], (0 ! (~fftOutNbOfBins))].flop.flat } };
					// ~fftOutMagPhaValues[0].cs; // Amplitude and phases (at 0) of bins for each channel


					~fftOutBufs[serverNb] = 2.collect { |a| ~numChannelsFX16.collect { |i| Buffer.loadCollection(currentEnvironment[server], ~fftOutMagPhaValues[serverNb][a][i]) } };

					// currentEnvironment[server].sync; // utile ???

					if (~fx16Split == 1, {

						~fxSynthDef2c.add(
							// Create automatically a multi-channel SynthDef according to the nb of channels
							SynthDef(\FFTDiffusion/*"spectral_diffusion_" ++ ~nbOfChannels*/, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftOutSize = ~fftOutSize, fade=(-1);
								var env, src, chain1, chainCopies, outs, scaleBufs = \scaleBufs.kr(0 ! (~numChannelsFX16 * 2)) ;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
								// src = In.ar(in_bus, ~numChannelsFX16);

								// NumChannels // L'entrée audio est copiée/mixée pour assurer une sortie sur le nb de canaux souhaités // pour récupérer le contenu de tous les canaux et les respatialiser
								src = NumChannels.ar(src, 1);

								chain1 = FFT(LocalBuf(fftOutSize, 1), src);
								chainCopies = (~numChannelsFX16 * 2 - 1).collect { |i| PV_Copy(chain1, LocalBuf(~fftOutSize, 1)) };  // copy the initial analysis X times

								chain1 = PV_MagMul(chain1, scaleBufs[0]);
								chainCopies = (~numChannelsFX16 * 2 - 1).collect { |i| PV_MagMul(chainCopies[i], scaleBufs[i+1]) };

								// outs = PV_XFade( [chain1] ++ chainCopies[0..~numChannelsFX-2], chainCopies[~numChannelsFX-1..~numChannelsFX*2-2], fade.varlag(lag));
								// outs = IFFT(outs);
								outs = XFade2.ar( IFFT([chain1] ++ chainCopies[0..~numChannelsFX16-2]), IFFT(chainCopies[~numChannelsFX16-1..~numChannelsFX16*2-2]), fade.varlag(lag));
								// Out.ar(out, outs * EnvGate.new * 0.5);
								// XOut.ar(in_bus, wet * env, outs);
								~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, outs[id]) }
							}).add;
						);

					},{

						~fxSynthDef2c.add(
							// Create automatically a multi-channel SynthDef according to the nb of channels
							SynthDef(\FFTDiffusion/*"spectral_diffusion_" ++ ~nbOfChannels*/, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, lag = 1, fftOutSize = ~fftOutSize, fade=(-1);
								var env, src, chain1, chainCopies, outs, scaleBufs = \scaleBufs.kr(0 ! (~numChannelsFX16 * 2)) ;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX16);

								// NumChannels // L'entrée audio est copiée/mixée pour assurer une sortie sur le nb de canaux souhaités // pour récupérer le contenu de tous les canaux et les respatialiser
								src = NumChannels.ar(src, 1);

								chain1 = FFT(LocalBuf(fftOutSize, 1), src);
								chainCopies = (~numChannelsFX16 * 2 - 1).collect { |i| PV_Copy(chain1, LocalBuf(~fftOutSize, 1)) };  // copy the initial analysis X times

								chain1 = PV_MagMul(chain1, scaleBufs[0]);
								chainCopies = (~numChannelsFX16 * 2 - 1).collect { |i| PV_MagMul(chainCopies[i], scaleBufs[i+1]) };

								// outs = PV_XFade( [chain1] ++ chainCopies[0..~numChannelsFX-2], chainCopies[~numChannelsFX-1..~numChannelsFX*2-2], fade.varlag(lag));
								// outs = IFFT(outs);
								outs = XFade2.ar( IFFT([chain1] ++ chainCopies[0..~numChannelsFX16-2]), IFFT(chainCopies[~numChannelsFX16-1..~numChannelsFX16*2-2]), fade.varlag(lag));
								// Out.ar(out, outs * EnvGate.new * 0.5);
								XOut.ar(in_bus, wet * env, outs);
							}).add;
						);

					});










					// NestedAllpassN / L/ C - DoubleNestedAllpassC





					if (~hpModulation == 0, {

						// Comb delay line

						~fxSynthDef3.add(
							SynthDef(\CombL, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, delay_time_2 = 0.1, decay_time = 2, lag = 1, mix = -1, lagM = 1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
								src = In.ar(in_bus, ~numChannelsFX);
								efx = CombL.ar(src, maxdtime, delay_time_2.lag2(lag), decay_time.varlag(lag), 1, src); // peut provoquer des clics surtout si dtime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)}, /*[0, 0, 0, 0, 0, 1, 1],*/
							variants: (
								a: [delay_time_2: 0.1, decay_time: 2],
								b: [delay_time_2: 0.2, decay_time: 2],
								c: [delay_time_2: 0.5, decay_time: 2],
								d: [delay_time_2: 1, decay_time: 5]),
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.001, 1),
									\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
									\decay_time: ControlSpec(0.01 /*0.001*/ /*-5*/, 5, 'lin', 0, 2) // Avec 0.001 explosions moins fortes aparemment

								),
								specsR: (
									\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
									\decay_time: ControlSpec(0.01 /*-5*/, 5, 'lin', 0, 2)

								),
								order: [
									\mix,
									\lag,
									\delay_time_2,
									\decay_time,
								]
							)
							).add;
						);
						/*~fxSynthDef.add(
						SynthDef(\echo, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, dtime = 0.1, decay = 2;
						var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
						var src = In.ar(in_bus, 1);
						src = CombL.ar(src, maxdtime, dtime, decay, 1, src); // peut provoquer des clics surtout si stime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???
						XOut.ar(in_bus, wet * env, src)}, [0, 0, 0, 0, 0, 1, 1],
						variants: (
						a: [dtime: 0.1, decay: 2],
						b: [dtime: 0.2, decay: 2],
						c: [dtime: 0.5, decay: 2],
						d: [dtime: 1, decay: 5]),
						metadata: (
						specs: (
						// \out: \audiobus.asSpec,
						// \mix: ControlSpec(-1, 1, 'lin', 0, -1),
						// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
						\dtime: ControlSpec(0.000001, 1, 2, 0.000001, 0.1),
						\decay: ControlSpec(-5, 5, 'lin', 0, 2),
						),
						order: [
						\dtime,
						\decay
						]
						)
						).add;
						);*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef3.add(
								SynthDef(\CombL, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, delay_time_2 = 0.1, decay_time = 2, maxdtime_HP = 0, delay_time_HP = 0, decay_time_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_delay_time, mod_decay_time;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									// efx = CombL.ar(src, maxdtime, delay_time_2.lag2(lag), decay_time.varlag(lag), 1, src); // peut provoquer des clics surtout si dtime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_delay_time = Control.names([\delay_time_Mod]).kr(0 ! ~numChannelsFX2).lag2(lag)/*.poll*/;
									mod_decay_time = Control.names([\decay_time_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										CombL.ar(src[i], maxdtime, mod_delay_time[i], mod_decay_time[i], 1, src[i]); // peut provoquer des clics surtout si dtime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }}, /*[0, 0, 0, 0, 0, 1, 1],*/
								variants: (
									a: [delay_time_2: 0.1, decay_time: 2],
									b: [delay_time_2: 0.2, decay_time: 2],
									c: [delay_time_2: 0.5, decay_time: 2],
									d: [delay_time_2: 1, decay_time: 5]),
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.001, 1),
										\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
										\decay_time: ControlSpec(0.01 /*-5*/, 5, 'lin', 0, 2)
									),
									specsR: (
										\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
										\decay_time: ControlSpec(0.01 /*-5*/, 5, 'lin', 0, 2)
									),
									order: [
										\mix,
										\lag,
										\delay_time_2,
										\decay_time,
									],
									specsM: (
										\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\decay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\delay_time_HP,
										\decay_time_HP
									],
									orderMod: [
										\delay_time_Mod,
										\decay_time_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef3.add(
								SynthDef(\CombL, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, delay_time_2 = 0.1, decay_time = 2, maxdtime_HP = 0, delay_time_HP = 0, decay_time_HP = 0, lag = 1, mix = -1, lagM = 1;
									var env, src, efx, mod_delay_time, mod_decay_time;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
									src = In.ar(in_bus, ~numChannelsFX);

									// efx = CombL.ar(src, maxdtime, delay_time_2.lag2(lag), decay_time.varlag(lag), 1, src); // peut provoquer des clics surtout si dtime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									mod_delay_time = Control.names([\delay_time_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
									mod_decay_time = Control.names([\decay_time_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										CombL.ar(src[i], maxdtime, mod_delay_time[i], mod_decay_time[i], 1, src[i]); // peut provoquer des clics surtout si dtime est important -> 0.5 et en particulier 1 ??? -> interaction avec le son d'origine ???
									};

									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx)}, /*[0, 0, 0, 0, 0, 1, 1],*/
								variants: (
									a: [delay_time_2: 0.1, decay_time: 2],
									b: [delay_time_2: 0.2, decay_time: 2],
									c: [delay_time_2: 0.5, decay_time: 2],
									d: [delay_time_2: 1, decay_time: 5]),
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.001, 1),
										\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
										\decay_time: ControlSpec(0.01 /*-5*/, 5, 'lin', 0, 2)
									),
									specsR: (
										\delay_time_2: ControlSpec(0.0001, 1, 2, 0.0001, 0.1),
										\decay_time: ControlSpec(0.01 /*-5*/, 5, 'lin', 0, 2)
									),
									order: [
										\mix,
										\lag,
										\delay_time_2,
										\decay_time,
									],
									specsM: (
										\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\decay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\delay_time_HP,
										\decay_time_HP
									],
									orderMod: [
										\delay_time_Mod,
										\decay_time_Mod
									]
								)
								).add;
							);

						});

					});





					if (~hpModulation == 0, {

						// provoque des sons très forts ?????????
						// redFrik - delay with pitchshift -> adapted from sc-users post 'FM Swear Box' by Paul Jones, sc-users 090919

						~fxSynthDef3.add(
							SynthDef(\DelPitch, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, feedback = 0.98, delay_time_E = 0.3, pitch_dipers = 1.667, cutoff1_E = 9999, rq1_E = 1, cutoff2_E = 3000, rq2_E = 2, lag = 1, mix = -1, lagM = 1;
								var src, efx, efx2, loc, cmp, pch, env;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
								src= In.ar(in_bus, ~numChannelsFX);
								loc= LocalIn.ar(~numChannelsFX); // ?????????
								efx= DelayL/*N*/.ar(src+loc, 1, delay_time_E.lag2(lag));
								cmp= Compander.ar(efx, efx, 0.5, 1, 0.001);
								pch= PitchShift.ar(cmp, delay_time_E.lag2(lag), pitch_dipers.varlag(lag), 0, 0.1);
								efx2= BLowPass.ar(cmp+pch, cutoff2_E.lag2(lag), rq2_E.lag2(lag));
								efx2= LeakDC.ar(efx2);
								LocalOut.ar(efx2 * feedback.varlag(lag));
								efx2= BLowPass4.ar(efx2, cutoff1_E.lag2(lag), rq1_E.lag2(lag));
								efx2 = XFade2.ar(src, efx2, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx2/*src*/)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
									\delay_time_E: \delay.asSpec,
									\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
									\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
									\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
									\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
									\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
								),
								specsR: (
									\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
									\delay_time_E: \delay.asSpec,
									\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
									\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
									\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
									\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
									\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
								),
								order: [
									\mix,
									\lag,
									\delay_time_E,
									\pitch_dipers,
									\feedback,
									\cutoff1_E,
									\rq1_E,
									\cutoff2_E,
									\rq2_E
								]
							)
							).add;
						);
						/*RedEfxDelp : RedEffectModule {
						*def {
						^SynthDef(\redEfxDelp, {|out= 0, mix= -1, fb= 0.98, dly= 0.3, ps= 1.667, fc= 9999, rq= 1, fc2= 3000, rq2= 2|
						var dry, wet, loc, cmp, pch, wet2;
						dry= In.ar(out, 2);
						loc= LocalIn.ar(2);
						wet= DelayN.ar(dry+loc, 1, dly);
						cmp= Compander.ar(wet, wet, 0.5, 1, 0.001);
						pch= PitchShift.ar(cmp, dly, ps, 0, 0.1);
						wet2= BLowPass.ar(cmp+pch, fc2, rq2);
						wet2= LeakDC.ar(wet2);
						LocalOut.ar(wet2*fb);
						wet2= BLowPass4.ar(wet2, fc, rq);
						ReplaceOut.ar(out, XFade2.ar(dry, wet2, mix));
						}, metadata: (
						specs: (
						\out: \audiobus.asSpec,
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\fb: ControlSpec(0, 2, 'lin', 0, 0.98),
						\dly: \delay.asSpec,
						\ps: ControlSpec(0, 5, 'lin', 0, 1.667),
						\fc: ControlSpec(20, 20000, 'exp', 0, 9999),
						\rq: ControlSpec(0.01, 4, 'exp', 0, 1),
						\fc2: ControlSpec(20, 20000, 'exp', 0, 3000),
						\rq2: ControlSpec(0.01, 4, 'exp', 0, 2)
						),
						order: [
						\out -> \delpOut,
						\mix -> \delpMix,
						\fb -> \delpFB,
						\dly -> \delpDly,
						\ps -> \delpPS,
						\fc -> \delpFC,
						\rq -> \delpRQ,
						\fc2 -> \delpFC2,
						\rq2 -> \delpRQ2
						]
						));
						}
						}*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef3.add(
								SynthDef(\DelPitch, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, feedback = 0.98, delay_time_E = 0.3, pitch_dipers = 1.667, cutoff1_E = 9999, rq1_E = 1, cutoff2_E = 3000, rq2_E = 2, lag = 1, mix = -1, lagM = 1;
									var src, efx, efx2, loc, cmp, pch, env;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
									// src= In.ar(in_bus, ~numChannelsFX);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									loc= LocalIn.ar(~numChannelsFX2); // ?????????
									efx= DelayL/*N*/.ar(src+loc, 1, delay_time_E.lag2(lag));
									cmp= Compander.ar(efx, efx, 0.5, 1, 0.001);
									pch= PitchShift.ar(cmp, delay_time_E.lag2(lag), pitch_dipers.varlag(lag), 0, 0.1);
									efx2= BLowPass.ar(cmp+pch, cutoff2_E.lag2(lag), rq2_E.lag2(lag));
									efx2= LeakDC.ar(efx2);
									LocalOut.ar(efx2 * feedback.varlag(lag));
									efx2= BLowPass4.ar(efx2, cutoff1_E.lag2(lag), rq1_E.lag2(lag));
									efx2 = XFade2.ar(src, efx2, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx2/*src*/)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx2[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
										\delay_time_E: \delay.asSpec,
										\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
										\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
										\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
										\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
										\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
									),
									specsR: (
										\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
										\delay_time_E: \delay.asSpec,
										\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
										\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
										\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
										\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
										\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
									),
									order: [
										\mix,
										\lag,
										\delay_time_E,
										\pitch_dipers,
										\feedback,
										\cutoff1_E,
										\rq1_E,
										\cutoff2_E,
										\rq2_E
									]
								)
								).add;
							);

						},{

							~fxSynthDef3.add(
								SynthDef(\DelPitch, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, feedback = 0.98, delay_time_E = 0.3, pitch_dipers = 1.667, cutoff1_E = 9999, rq1_E = 1, cutoff2_E = 3000, rq2_E = 2, lag = 1, mix = -1, lagM = 1;
									var src, efx, efx2, loc, cmp, pch, env;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
									src= In.ar(in_bus, ~numChannelsFX);
									loc= LocalIn.ar(~numChannelsFX); // ?????????
									efx= DelayL/*N*/.ar(src+loc, 1, delay_time_E.lag2(lag));
									cmp= Compander.ar(efx, efx, 0.5, 1, 0.001);
									pch= PitchShift.ar(cmp, delay_time_E.lag2(lag), pitch_dipers.varlag(lag), 0, 0.1);
									efx2= BLowPass.ar(cmp+pch, cutoff2_E.lag2(lag), rq2_E.lag2(lag));
									efx2= LeakDC.ar(efx2);
									LocalOut.ar(efx2 * feedback.varlag(lag));
									efx2= BLowPass4.ar(efx2, cutoff1_E.lag2(lag), rq1_E.lag2(lag));
									efx2 = XFade2.ar(src, efx2, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx2/*src*/)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
										\delay_time_E: \delay.asSpec,
										\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
										\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
										\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
										\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
										\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
									),
									specsR: (
										\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
										\delay_time_E: \delay.asSpec,
										\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
										\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
										\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
										\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
										\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
									),
									order: [
										\mix,
										\lag,
										\delay_time_E,
										\pitch_dipers,
										\feedback,
										\cutoff1_E,
										\rq1_E,
										\cutoff2_E,
										\rq2_E
									]
								)
								).add;
							);

						});

						/*~fxSynthDef3.add(
						SynthDef(\DelPitch, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, maxdtime = 1.0, feedback = 0.98, delay_time_E = 0.3, pitch_dipers = 1.667, cutoff1_E = 9999, rq1_E = 1, cutoff2_E = 3000, rq2_E = 2, /*maxdtime_HP = 0, feedback_HP = 0, delay_time_HP = 0, pitch_dipers_HP = 0, cutoff1_HP = 0, rq1_HP = 0, cutoff2_HP = 0, rq2_HP = 0,*/ lag = 1, mix = -1;
						var src, efx, efx2, loc, cmp, pch, env, mod_feedback, mod_delay_time, mod_pitch_dipers, mod_cutoff1, mod_rq1, mod_cutoff2, mod_rq2;
						env = Linen.kr(gate, fadeTime, 1, fadeTime, 2); // (gate: 1, attackTime: 0.01, susLevel: 1, releaseTime: 1, doneAction: 0) // (gate, 0.01, 0.01, 0.01, 2)
						src= In.ar(in_bus, ~numChannelsFX);
						loc= LocalIn.ar(~numChannelsFX); // ?????????

						/*efx= DelayN.ar(src+loc, 1, delay_time_E.lag2(lag));
						cmp= Compander.ar(efx, efx, 0.5, 1, 0.001);
						pch= PitchShift.ar(cmp, delay_time_E.lag2(lag), pitch_dipers.varlag(lag), 0, 0.1);
						efx2= BLowPass.ar(cmp+pch, cutoff2_E.lag2(lag), rq2_E.lag2(lag));
						efx2= LeakDC.ar(efx2);
						LocalOut.ar(efx2 * feedback.varlag(lag));
						efx2= BLowPass4.ar(efx2, cutoff1_E.lag2(lag), rq1_E.lag2(lag));*/

						// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
						mod_feedback = Control.names([\feedback_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
						mod_delay_time = Control.names([\delay_time_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
						mod_pitch_dipers = Control.names([\pitch_dipers_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
						mod_cutoff1 = Control.names([\cutoff1_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
						mod_rq1 = Control.names([\rq1_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
						mod_cutoff2 = Control.names([\cutoff2_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;
						mod_rq2 = Control.names([\rq2_Mod]).kr(0 ! ~numChannelsFX).lag2(lag)/*.poll*/;

						efx = 0 ! ~numChannelsFX;
						efx2 = 0 ! ~numChannelsFX;
						cmp = 0 ! ~numChannelsFX;
						pch = 0 ! ~numChannelsFX;
						~numChannelsFX.collect { |i|
						efx[i]= DelayL/*N*/.ar(src[i]+loc[i], 1, mod_delay_time[i]); // Meilleur en cubique
						cmp[i]= Compander.ar(efx[i], efx[i], 0.5, 1, 0.001);
						pch[i]= PitchShift.ar(cmp[i], /*delay_time_E.lag2(lag)*/ mod_delay_time[i], mod_pitch_dipers[i], 0, 0.1);
						// Window size cannot be modulated ??????????????????????????????????????????????????????????????????????? Mais à l'instantiation du synthé -> oui
						efx2[i]= BLowPass.ar(cmp[i]+pch[i], mod_cutoff2[i], mod_rq2[i]);
						efx2[i]= LeakDC.ar(efx2[i]);
						LocalOut.ar(efx2[i] * mod_feedback[i]);
						efx2[i]= BLowPass4.ar(efx2[i], mod_cutoff1[i], mod_rq1[i]);
						};

						efx2 = XFade2.ar(src, efx2, mix.varlag(lag));
						XOut.ar(in_bus, wet * env, efx2/*src*/)},
						metadata: (
						specs: (
						\mix: ControlSpec(-1, -0.5, 'lin', 0, -1), // limite pour éviter les sons trop forts ?????????
						\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
						\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
						\delay_time_E: \delay.asSpec,
						\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
						\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
						\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
						\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
						\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
						),
						specsR: (
						\feedback: ControlSpec(0, 2, 'lin', 0, 0.98),
						\delay_time_E: \delay.asSpec,
						\pitch_dipers: ControlSpec(0, 5, 'lin', 0, 1.667),
						\cutoff1_E: ControlSpec(20, 20000, 'exp', 0, 9999),
						\rq1_E: ControlSpec(0.01, 4, 'exp', 0, 1),
						\cutoff2_E: ControlSpec(20, 20000, 'exp', 0, 3000),
						\rq2_E: ControlSpec(0.01, 4, 'exp', 0, 2)
						),
						order: [
						\mix,
						\lag,
						\delay_time_E,
						\pitch_dipers,
						\feedback,
						\cutoff1_E,
						\rq1_E,
						\cutoff2_E,
						\rq2_E
						],
						specsM: (
						\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\pitch_dipers_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\cutoff1_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\rq1_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\cutoff2_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
						\rq2_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
						),
						orderM: [
						\feedback_HP,
						\delay_time_HP,
						\pitch_dipers_HP,
						\cutoff1_HP,
						\rq1_HP,
						\cutoff2_HP,
						\rq2_HP
						],
						orderMod: [
						\feedback_Mod,
						\delay_time_Mod,
						\pitch_dipers_Mod,
						\cutoff1_Mod,
						\rq1_Mod,
						\cutoff2_Mod,
						\rq2_Mod
						]
						)
						).add;
						);*/

					});





					if (~hpModulation == 0, {

						// redFrik - tape echo -> adapted from jmc's tape example in LocalIn helpfile

						~fxSynthDef3.add(
							SynthDef(\TapEcho_C, { arg /*out= 0, mix= -1,*/ in_bus = 0, gate = 1, wet = 1, fadeTime = 1, feedback= 1, ff= 1.25, threshold= 0.02, rate= 0.25, lag = 1, mix = -1, lagM = 1;
								var src, efx, in2, env;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								in2 = src * (Amplitude.kr(Mix(src)) > threshold.varlag(lag)); // vers ou est redirigé l'in2 - pas utilisé ???
								efx = LocalIn.ar(~numChannelsFX) * feedback.varlag(lag); // ?????????
								efx = OnePole.ar(OnePole.ar(efx, 0.4), -0.08);
								// wet = Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
								efx = DelayL.ar(efx, 2, rate.varlag(lag).min(2));
								efx = LeakDC.ar(efx);
								efx = ((efx + src) * ff.varlag(lag)).softclip;
								LocalOut.ar(efx);
								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx /** 0.1*/)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\feedback: ControlSpec(0, 2, 'lin', 0, 1),
									\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
									\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
									\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
								),
								specsR: (
									\feedback: ControlSpec(0, 2, 'lin', 0, 1),
									\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
									\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
									\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
								),
								order: [
									\mix,
									\lag,
									\feedback,
									\ff,
									\threshold,
									\rate
								]
							));
						);
						/*RedEfxTape : RedEffectModule {
						*def {
						^SynthDef(\redEfxTape, {|out= 0, mix= -1, fb= 1, ff= 1.25, thresh= 0.02, rate= 0.25|
						var dry, wet, in2;
						dry= In.ar(out, 2);
						in2= dry*(Amplitude.kr(Mix(dry))>thresh);
						wet= LocalIn.ar(2)*fb;
						wet= OnePole.ar(OnePole.ar(wet, 0.4), -0.08);
						wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
						wet= DelayL.ar(wet, 2, rate.min(2));
						wet= LeakDC.ar(wet);
						wet= ((wet+dry)*ff).softclip;
						LocalOut.ar(wet);
						ReplaceOut.ar(out, XFade2.ar(dry, wet*0.1, mix));
						}, metadata: (
						specs: (
						\out: \audiobus.asSpec,
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\fb: ControlSpec(0, 2, 'lin', 0, 1),
						\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
						\thresh: ControlSpec(0, 1, 'lin', 0, 0.02),
						\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
						),
						order: [
						\out -> \tapeOut,
						\mix -> \tapeMix,
						\fb -> \tapeFB,
						\ff -> \tapeFF,
						\thresh -> \tapeThresh,
						\rate -> \tapeRate
						]
						));
						}
						}*/

					},{

						if (~fx16Split == 1, {

							~fxSynthDef3.add(
								SynthDef(\TapEcho_C, { arg /*out= 0, mix= -1,*/ in_bus = 0, gate = 1, wet = 1, fadeTime = 1, feedback= 1, ff= 1.25, threshold= 0.02, rate= 0.25, feedback_HP= 0, ff_HP= 0, threshold_HP= 0, rate_HP= 0, lag = 1, mix = -1, lagM = 1;
									var src, efx, in2, env, loc, mod_feedback, mod_ff, mod_threshold, mod_rate;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);
									loc= LocalIn.ar(~numChannelsFX2); // ?????????

									/*in2 = src * (Amplitude.kr(Mix(src)) > threshold.varlag(lag)); // vers ou est redirigé l'in2 - pas utilisé ???
									efx = LocalIn.ar(~numChannelsFX) * feedback.varlag(lag); // ?????????
									efx = OnePole.ar(OnePole.ar(efx, 0.4), -0.08);
									// wet = Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
									efx = DelayL.ar(efx, 2, rate.varlag(lag).min(2));
									efx = LeakDC.ar(efx);
									efx = ((efx + src) * ff.varlag(lag)).softclip;
									LocalOut.ar(efx);*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX2, lag)/*.poll*/;
									mod_feedback = Control.names([\feedback_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_ff = Control.names([\ff_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_threshold = Control.names([\threshold_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX2;
									in2 = 0 ! ~numChannelsFX2;
									~numChannelsFX2.collect { |i|
										in2[i] = src[i] * (Amplitude.kr(Mix(src[i])) > mod_threshold[i]); // vers ou est redirigé l'in2 - pas utilisé ???
										efx[i] = loc[i] * mod_feedback[i]; // ?????????
										efx[i] = OnePole.ar(OnePole.ar(efx[i], 0.4), -0.08);
										// wet = Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
										efx[i] = DelayL.ar(efx[i], 2, mod_rate[i].min(2));
										efx[i] = LeakDC.ar(efx[i]);
										efx[i] = ((efx[i] + src[i]) * mod_ff[i]).softclip;
										LocalOut.ar(efx[i]);
									};


									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									// XOut.ar(in_bus, wet * env, efx /** 0.1*/)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\feedback: ControlSpec(0, 2, 'lin', 0, 1),
										\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
										\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
										\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
									),
									specsR: (
										\feedback: ControlSpec(0, 2, 'lin', 0, 1),
										\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
										\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
										\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
									),
									order: [
										\mix,
										\lag,
										\feedback,
										\ff,
										\threshold,
										\rate
									],
									specsM: (
										\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\ff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\threshold_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\feedback_HP,
										\ff_HP,
										\threshold_HP,
										\rate_HP
									],
									orderMod: [
										\feedback_Mod,
										\ff_Mod,
										\threshold_Mod,
										\rate_Mod
									]
								));
							);

						},{

							~fxSynthDef3.add(
								SynthDef(\TapEcho_C, { arg /*out= 0, mix= -1,*/ in_bus = 0, gate = 1, wet = 1, fadeTime = 1, feedback= 1, ff= 1.25, threshold= 0.02, rate= 0.25, feedback_HP= 0, ff_HP= 0, threshold_HP= 0, rate_HP= 0, lag = 1, mix = -1, lagM = 1;
									var src, efx, in2, env, loc, mod_feedback, mod_ff, mod_threshold, mod_rate;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);
									loc= LocalIn.ar(~numChannelsFX); // ?????????

									/*in2 = src * (Amplitude.kr(Mix(src)) > threshold.varlag(lag)); // vers ou est redirigé l'in2 - pas utilisé ???
									efx = LocalIn.ar(~numChannelsFX) * feedback.varlag(lag); // ?????????
									efx = OnePole.ar(OnePole.ar(efx, 0.4), -0.08);
									// wet = Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
									efx = DelayL.ar(efx, 2, rate.varlag(lag).min(2));
									efx = LeakDC.ar(efx);
									efx = ((efx + src) * ff.varlag(lag)).softclip;
									LocalOut.ar(efx);*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
									mod_feedback = Control.names([\feedback_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_ff = Control.names([\ff_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_threshold = Control.names([\threshold_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_rate = Control.names([\rate_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = 0 ! ~numChannelsFX;
									in2 = 0 ! ~numChannelsFX;
									~numChannelsFX.collect { |i|
										in2[i] = src[i] * (Amplitude.kr(Mix(src[i])) > mod_threshold[i]); // vers ou est redirigé l'in2 - pas utilisé ???
										efx[i] = loc[i] * mod_feedback[i]; // ?????????
										efx[i] = OnePole.ar(OnePole.ar(efx[i], 0.4), -0.08);
										// wet = Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
										efx[i] = DelayL.ar(efx[i], 2, mod_rate[i].min(2));
										efx[i] = LeakDC.ar(efx[i]);
										efx[i] = ((efx[i] + src[i]) * mod_ff[i]).softclip;
										LocalOut.ar(efx[i]);
									};


									efx = XFade2.ar(src, efx, mix.varlag(lagM));
									XOut.ar(in_bus, wet * env, efx /** 0.1*/)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\feedback: ControlSpec(0, 2, 'lin', 0, 1),
										\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
										\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
										\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
									),
									specsR: (
										\feedback: ControlSpec(0, 2, 'lin', 0, 1),
										\ff: ControlSpec(0, 2, 'lin', 0, 1.25),
										\threshold: ControlSpec(0, 1, 'lin', 0, 0.02),
										\rate: ControlSpec(0, 2, 'lin', 0, 0.25)
									),
									order: [
										\mix,
										\lag,
										\feedback,
										\ff,
										\threshold,
										\rate
									],
									specsM: (
										\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\ff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\threshold_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\rate_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
									),
									orderM: [
										\feedback_HP,
										\ff_HP,
										\threshold_HP,
										\rate_HP
									],
									orderMod: [
										\feedback_Mod,
										\ff_Mod,
										\threshold_Mod,
										\rate_Mod
									]
								));
							);

						});

					});





					if (~numChannels == 2, {

						// très lourd entre 30 et 40% de CPU à 5 canaux - Uilisation d'une version stéréo car multicanal trop lourd XXXXXXXXX
						// -> voire utilisation de synthés stéréo (par ex pour 5 canaux -> 2 + 2 + 1, donc 3 au lieu de 5)
						// A complex echo-like effect, inspired by the classic Eventide effect of a similar name.
						// The effect consists of a diffuser (like a mini-reverb) connected in a feedback system with a long modulated delay-line.
						// Excels at producing spacey washes of sound.
						/*
						delayTime	approximate delay time in seconds. (0.1..60)
						damp	    damping of high-frequencies as the delay decays. 0 is no damping, 1 is very strong damping (0..1)
						size	    scales size of delay-lines within the diffusion unit, producing the impression of a larger or smaller space. Values below 1 can sound metallic. (0.5..5)
						diff	    controls pattern of echoes produced by the diffuser. At very low values, the diffuser acts like a delay-line whose length is controlled by the 'size' parameter. Medium values produce a slow build-up of echoes, giving the sound a reversed-like quality. Values of 0.707 or greater than produce smooth exponentially decaying echoes. (0..1)
						feedback	amount of feedback through the system. Sets the number of repeating echoes. A setting of 1.0 produces infinite sustain. (0..1)
						modDepth	depth of delay-line modulation. Use in combination with mFreq to produce chorus and pitch-variations in the echoes. (0..1)
						modFreq	    frequency of delay-line modulation. Use in combination with mFreq to produce chorus and pitch-variations in the echoes. (0..10)
						*/

						~fxSynthDef3.add(
							SynthDef(\Greyhole_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 2, damping = 0, room_size = 1, diff = 0.707, feedback = 0.9, mod_depth = 0.1, mod_freq = 2, /*out = 0,*/ /*delay_time_HP = 0, damping_HP = 0, room_size_HP = 0, diff_HP = 0, feedback_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // either an array of two audio signals, or one audiosignal ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								// src2 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = Greyhole.ar(src, delay_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), diff.varlag(lag), feedback.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = Greyhole.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \diff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
								),
								order: [
									\mix,
									\lag,
									\delay_time,
									\room_size,
									\damping,
									\feedback,
									\diff,
									\mod_depth,
									\mod_freq,
									\out,
									\out_mul
								]
							)
							).add;
						);

					},{

						/* Obligé de modifier l'Array car NumChannels mixe d'une façon spécifique
						// Transformation des FX stéréo
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.2, 0, 0]), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.1, 0, 0].mirror2), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0, 0.2, 0]), /*1*/ 2) }.play
						[0.2, 0.1, 0, 0].clump(2).flop.flat
						*/

						~fxSynthDef3.add(
							SynthDef(\Greyhole_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 2, damping = 0, room_size = 1, diff = 0.707, feedback = 0.9, mod_depth = 0.1, mod_freq = 2, out = 0, out_mul = 1, /*delay_time_HP = 0, damping_HP = 0, room_size_HP = 0, diff_HP = 0, feedback_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // either an array of two audio signals, or one audiosignal ?????????
								src = In.ar(in_bus, ~numChannelsFX).clump(2).flop.flat;
								src2 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = Greyhole.ar(src2, delay_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), diff.varlag(lag), feedback.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = Greyhole.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \diff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src2, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus + out, wet * env, efx * out_mul.varlag(lag) )},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
								),
								order: [
									\mix,
									\lag,
									\delay_time,
									\room_size,
									\damping,
									\feedback,
									\diff,
									\mod_depth,
									\mod_freq,
									\out,
									\out_mul
								]/*,
								specsM: (
								\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\diff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\delay_time_HP,
								\damping_HP,
								\room_size_HP,
								\diff_HP,
								\feedback_HP,
								\mod_depth_HP,
								\mod_freq_HP
								],
								orderMod: [
								\delay_time_Mod,
								\damping_Mod,
								\room_size_Mod,
								\diff_Mod,
								\feedback_Mod,
								\mod_depth_Mod,
								\mod_freq_Mod
								]*/
							)
							).add;
						);

					});





					if (~numChannels == 2, {

						// très lourd entre 30 et 40% de CPU à 5 canaux - Uilisation d'une version stéréo car multicanal trop lourd XXXXXXXXX
						// -> voire utilisation de synthés stéréo (par ex pour 5 canaux -> 2 + 2 + 1, donc 3 au lieu de 5)
						// A complex echo-like effect, inspired by the classic Eventide effect of a similar name.
						// The effect consists of a diffuser (like a mini-reverb) connected in a feedback system with a long modulated delay-line.
						// Excels at producing spacey washes of sound.
						/*
						delayTime	approximate delay time in seconds. (0.1..60)
						damp	    damping of high-frequencies as the delay decays. 0 is no damping, 1 is very strong damping (0..1)
						size	    scales size of delay-lines within the diffusion unit, producing the impression of a larger or smaller space. Values below 1 can sound metallic. (0.5..5)
						diff	    controls pattern of echoes produced by the diffuser. At very low values, the diffuser acts like a delay-line whose length is controlled by the 'size' parameter. Medium values produce a slow build-up of echoes, giving the sound a reversed-like quality. Values of 0.707 or greater than produce smooth exponentially decaying echoes. (0..1)
						feedback	amount of feedback through the system. Sets the number of repeating echoes. A setting of 1.0 produces infinite sustain. (0..1)
						modDepth	depth of delay-line modulation. Use in combination with mFreq to produce chorus and pitch-variations in the echoes. (0..1)
						modFreq	    frequency of delay-line modulation. Use in combination with mFreq to produce chorus and pitch-variations in the echoes. (0..10)
						*/

						~fxSynthDef3.add(
							SynthDef(\GreyholeA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 2, damping = 0, room_size = 1, diff = 0.707, feedback = 0.9, mod_depth = 0.1, mod_freq = 2, /*out = 0,*/ /*delay_time_HP = 0, damping_HP = 0, room_size_HP = 0, diff_HP = 0, feedback_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // either an array of two audio signals, or one audiosignal ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								// src2 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = Greyhole.ar(src, delay_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), diff.varlag(lag), feedback.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = Greyhole.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \diff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
								),
								specsR: (
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
								),
								order: [
									\mix,
									\lag,
									\delay_time,
									\room_size,
									\damping,
									\feedback,
									\diff,
									\mod_depth,
									\mod_freq
								]
							)
							).add;
						);

					},{

						~fxSynthDef3.add(
							SynthDef(\GreyholeA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, delay_time = 2, damping = 0, room_size = 1, diff = 0.707, feedback = 0.9, mod_depth = 0.1, mod_freq = 2, /*out = 0, out_mul = 1, delay_time_HP = 0, damping_HP = 0, room_size_HP = 0, diff_HP = 0, feedback_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // either an array of two audio signals, or one audiosignal ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								src2 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = Greyhole.ar(src2, delay_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), diff.varlag(lag), feedback.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = Greyhole.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \diff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag)) };

								// avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lagM));

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								// efx = XFade2.ar(src2, efx, mix.varlag(lag)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx /** out_mul.varlag(lag)*/ )},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
								),
								specsR: (
									\delay_time: ControlSpec(0, 60, 'lin', 0.001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\feedback: ControlSpec(0, 1, 'lin', 0.01, 0.9),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2)
								),
								order: [
									\mix,
									\lag,
									\delay_time,
									\room_size,
									\damping,
									\feedback,
									\diff,
									\mod_depth,
									\mod_freq
								]/*,
								specsM: (
								\delay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\diff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\delay_time_HP,
								\damping_HP,
								\room_size_HP,
								\diff_HP,
								\feedback_HP,
								\mod_depth_HP,
								\mod_freq_HP
								],
								orderMod: [
								\delay_time_Mod,
								\damping_Mod,
								\room_size_Mod,
								\diff_Mod,
								\feedback_Mod,
								\mod_depth_Mod,
								\mod_freq_Mod
								]*/
							)
							).add;
						);

					});





					// XFadeRotate : Rotates an array of input channels with equal power between channels. from wslib
					// Nom donné Rootate et non rotate, pour faire la distinction avec les synthés ambisoniques -> voire ~lagTimeAllFxOViewCollection

					~fxSynthDef3.add(
						SynthDef(\Rootate, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, speed_E = 1, scale_dir = 1, /*speed_HP = 0, scale_dir_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
							var env, src, efx /*, mod_speed, mod_scale_dir, phasor*/;
							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							efx = XFadeRotate.ar(Phasor.kr(0, speed_E.varlag(lag) / currentEnvironment[serverFXV].sampleRate * scale_dir.varlag(lag), 0.0, ~numChannelsFX), src);

							// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
							// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
							/*mod_speed = Control.names([\speed_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
							mod_scale_dir = Control.names([\scale_dir_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

							efx = 0 ! ~numChannelsFX;
							phasor = 0 ! ~numChannelsFX;
							~numChannelsFX.collect { |i|
							phasor[i] = Phasor.ar(0, mod_speed[i] / s.sampleRate * mod_scale_dir[i], 0.0, ~numChannelsFX);
							efx[i] = XFadeRotate.ar(phasor[i], src[i]);
							// Voir si besoin d'aller de 0 à 16 ou 15 ????????????
							};*/

							efx = XFade2.ar(src, efx, mix.varlag(lagM));
							XOut.ar(in_bus, wet * env, efx)},
						metadata: (
							specs: (
								\mix: ControlSpec(-1, 1, 'lin', 0, -1),
								\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
								\speed_E: ControlSpec(0.01, 10000, 'exp', 0.01, 0.5),
								\scale_dir: ControlSpec(-1, 1, 'lin', 0.01, 1),
							),
							specsR: (
								\speed_E: ControlSpec(0.01, 1000, 'exp', 0.01, 0.5),
								\scale_dir: ControlSpec(-1, 1, 'lin', 0.01, 1),
							),
							order: [
								\mix,
								\lag,
								\speed_E,
								\scale_dir
							]/*,
							specsM: (
							\speed_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\scale_dir_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
							),
							orderM: [
							\speed_HP,
							\scale_dir_HP
							],
							orderMod: [
							\speed_Mod,
							\scale_dir_Mod
							]*/
						)
						).add;
					);
					/*(
					{arg level = 0.125, speed = 0.5;
					var inArray = [SinOsc.ar(200), Saw.ar(300), Pulse.ar(400), SinOsc.ar(250), GrayNoise.ar];
					var out = XFadeRotate.ar(Phasor.ar(0, speed / 44100, 0.0, inArray.size), inArray);
					out * level;
					}.play;
					s.scope;
					)*/










					/*~fxSynthDef4.add(
					SynthDef(\RevAll, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, /*dtime = 0.1, decay = 3,*/ lag = 1;
					var env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
					var src = In.ar(in_bus, 1);
					// Pas vraiment d'intérêt du Rand car juste utilsé à l'instantiation du synthé ???
					16.do({ src = AllpassC.ar(src, 0.1, /*\dtime.kr(0.1, lag)*/ Rand(0.001, \dtime.kr(0.1, lag)), \decay.kr(2, lag) )});
					XOut.ar(in_bus, wet * env, src)},
					variants: (
					a: [dtime: 0.001],
					b: [dtime: 0.002],
					c: [dtime: 0.004],
					d: [dtime: 0.01]),
					metadata: (
					specs: (
					// \out: \audiobus.asSpec,
					// \mix: ControlSpec(-1, 1, 'lin', 0, -1),
					// \amount: ControlSpec(0, 0.9999999, 'lin', 0, 0.5),
					\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
					\dtime: ControlSpec(0.001, 0.04, 'lin', 0.001, 0.04),
					\decay: ControlSpec(-5, 5, 'lin', 0, 2)
					),
					order: [
					\lag,
					\dtime,
					\decay
					]
					)
					).add;
					);*/





					// redFrik - adapted from jmc's tank example in LocalIn helpfile
					// modif mapping feedback & damping car explosion du signal
					// essayer avec des valeurs de decay basses XXXXXXXXX

					if (~fx16Split == 1, {

						~fxSynthDef4.add(
							SynthDef(\RevTank, { arg in_bus = 0/*, mix = -1*/, gate = 1, wet = 1, fadeTime = 1, feedback = 0.98, decay_time = 1, damping = 1, /*feedback_HP = 0, decay_time_HP = 0, damping_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var src, efx, in2, env/*, loc, mod_feedback, mod_decay_time, mod_damping*/;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
								// src = In.ar(in_bus, ~numChannelsFX);
								// loc= LocalIn.ar(~numChannelsFX);

								in2= src;
								4.do{in2= AllpassN.ar(in2, 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, decay_time.varlag(lag), damping.varlag(lag))};
								efx= LocalIn.ar(1) * feedback.varlag(lag);
								efx= OnePole.ar(efx, 0.5);
								// wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
								efx= AllpassN.ar(efx, 0.05, /*{*/Rand(0.01, 0.05)/*}.dup*/, 2 * decay_time.varlag(lag), damping.varlag(lag));
								efx= DelayN.ar(efx, 0.26, /*{*/Rand(0.1, 0.26)/*}.dup*/);
								efx= AllpassN.ar(efx, 0.05, /*{*/Rand(0.03, 0.05)/*}.dup*/, 2 * decay_time.varlag(lag), damping.varlag(lag));
								//wet= LeakDC.ar(Limiter.ar(wet));
								efx= LeakDC.ar(efx);
								efx= efx+in2;
								LocalOut.ar(efx);

								// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
								// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
								/*mod_feedback = Control.names([\feedback_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
								mod_decay_time = Control.names([\decay_time_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
								mod_damping = Control.names([\damping_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

								efx = 0 ! ~numChannelsFX;
								~numChannelsFX.collect { |i|
								// 4.do{ src[i] = AllpassL.ar(src[i], 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, mod_decay_time[i], mod_damping[i])};
								src[i] = AllpassL.ar(src[i], 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, mod_decay_time[i], mod_damping[i]);
								efx[i] = loc[i] * mod_feedback[i];
								efx[i] = OnePole.ar(efx[i], 0.5);
								// wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
								efx[i] = AllpassL.ar(efx[i], 0.05, /*{*/Rand(0.01, 0.05)/*}.dup*/, 2 * mod_decay_time[i], mod_damping[i]);
								efx[i] = DelayL.ar(efx[i], 0.26, /*{*/Rand(0.1, 0.26)/*}.dup*/);
								efx[i] = AllpassL.ar(efx[i], 0.05, /*{*/Rand(0.03, 0.05)/*}.dup*/, 2 * mod_decay_time[i], mod_damping[i]);
								//wet= LeakDC.ar(Limiter.ar(wet));
								efx[i] = LeakDC.ar(efx[i]);
								efx[i] = efx[i] +src[i] ;
								LocalOut.ar(efx[i]);
								};*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								// XOut.ar(in_bus, wet * env, efx)
								~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\feedback: ControlSpec(0, 1.5, 'lin', 0, 0.98),
									\decay_time: ControlSpec(0, 10, 'lin', 0.01, 1),
									\damping: ControlSpec(0, 2 /*1.2*/, 'lin', 0, 1)
								),
								specsR: (
									\feedback: ControlSpec(0, 1.5, 'lin', 0, 0.98),
									\decay_time: ControlSpec(0, 10, 'lin', 0.01, 1),
									\damping: ControlSpec(0, 2 /*1.2*/, 'lin', 0, 1)
								),
								order: [
									\mix,
									\lag,
									\decay_time,
									\damping,
									\feedback,
								]/*,
								specsM: (
								\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\decay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\feedback_HP,
								\decay_time_HP,
								\damping_HP
								],
								orderMod: [
								\feedback_Mod,
								\decay_time_Mod,
								\damping_Mod
								]*/
							)
							).add;
						);
						/*RedEfxTank : RedEffectModule {
						*def {
						^SynthDef(\redEfxTank, {|out= 0, mix= -1, fb= 0.98, dec= 1, damp= 1|
						var dry, wet, in2;
						dry= In.ar(out, 2);
						in2= dry;
						4.do{in2= AllpassN.ar(in2, 0.02, {Rand(0.005, 0.02)}.dup, dec, damp)};
						wet= LocalIn.ar(2)*fb;
						wet= OnePole.ar(wet, 0.5);
						wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
						wet= AllpassN.ar(wet, 0.05, {Rand(0.01, 0.05)}.dup, 2*dec, damp);
						wet= DelayN.ar(wet, 0.26, {Rand(0.1, 0.26)}.dup);
						wet= AllpassN.ar(wet, 0.05, {Rand(0.03, 0.05)}.dup, 2*dec, damp);
						//wet= LeakDC.ar(Limiter.ar(wet));
						wet= LeakDC.ar(wet);
						wet= wet+in2;
						LocalOut.ar(wet);
						ReplaceOut.ar(out, XFade2.ar(dry, wet, mix));
						}, metadata: (
						specs: (
						\out: \audiobus.asSpec,
						\mix: ControlSpec(-1, 1, 'lin', 0, -1),
						\fb: ControlSpec(0, 2, 'lin', 0, 0.98),
						\dec: ControlSpec(0, 10, 'lin', 0, 1),
						\damp: ControlSpec(0, 2, 'lin', 0, 1)
						),
						order: [
						\out -> \tankOut,
						\mix -> \tankMix,
						\fb -> \tankFB,
						\dec -> \tankDec,
						\damp -> \tankDamp
						]
						));
						}
						}*/

					},{

						~fxSynthDef4.add(
							SynthDef(\RevTank, { arg in_bus = 0/*, mix = -1*/, gate = 1, wet = 1, fadeTime = 1, feedback = 0.98, decay_time = 1, damping = 1, /*feedback_HP = 0, decay_time_HP = 0, damping_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var src, efx, in2, env/*, loc, mod_feedback, mod_decay_time, mod_damping*/;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								// loc= LocalIn.ar(~numChannelsFX);

								in2= src;
								4.do{in2= AllpassN.ar(in2, 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, decay_time.varlag(lag), damping.varlag(lag))};
								efx= LocalIn.ar(1) * feedback.varlag(lag);
								efx= OnePole.ar(efx, 0.5);
								// wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
								efx= AllpassN.ar(efx, 0.05, /*{*/Rand(0.01, 0.05)/*}.dup*/, 2 * decay_time.varlag(lag), damping.varlag(lag));
								efx= DelayN.ar(efx, 0.26, /*{*/Rand(0.1, 0.26)/*}.dup*/);
								efx= AllpassN.ar(efx, 0.05, /*{*/Rand(0.03, 0.05)/*}.dup*/, 2 * decay_time.varlag(lag), damping.varlag(lag));
								//wet= LeakDC.ar(Limiter.ar(wet));
								efx= LeakDC.ar(efx);
								efx= efx+in2;
								LocalOut.ar(efx);

								// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
								// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
								/*mod_feedback = Control.names([\feedback_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
								mod_decay_time = Control.names([\decay_time_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
								mod_damping = Control.names([\damping_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

								efx = 0 ! ~numChannelsFX;
								~numChannelsFX.collect { |i|
								// 4.do{ src[i] = AllpassL.ar(src[i], 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, mod_decay_time[i], mod_damping[i])};
								src[i] = AllpassL.ar(src[i], 0.02, /*{*/Rand(0.005, 0.02)/*}.dup*/, mod_decay_time[i], mod_damping[i]);
								efx[i] = loc[i] * mod_feedback[i];
								efx[i] = OnePole.ar(efx[i], 0.5);
								// wet= Rotate2.ar(wet[0], wet[1], Rand(0.1, 0.25));
								efx[i] = AllpassL.ar(efx[i], 0.05, /*{*/Rand(0.01, 0.05)/*}.dup*/, 2 * mod_decay_time[i], mod_damping[i]);
								efx[i] = DelayL.ar(efx[i], 0.26, /*{*/Rand(0.1, 0.26)/*}.dup*/);
								efx[i] = AllpassL.ar(efx[i], 0.05, /*{*/Rand(0.03, 0.05)/*}.dup*/, 2 * mod_decay_time[i], mod_damping[i]);
								//wet= LeakDC.ar(Limiter.ar(wet));
								efx[i] = LeakDC.ar(efx[i]);
								efx[i] = efx[i] +src[i] ;
								LocalOut.ar(efx[i]);
								};*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\feedback: ControlSpec(0, 1.5, 'lin', 0, 0.98),
									\decay_time: ControlSpec(0, 10, 'lin', 0.01, 1),
									\damping: ControlSpec(0, 2 /*1.2*/, 'lin', 0, 1)
								),
								specsR: (
									\feedback: ControlSpec(0, 1.5, 'lin', 0, 0.98),
									\decay_time: ControlSpec(0, 10, 'lin', 0.01, 1),
									\damping: ControlSpec(0, 2 /*1.2*/, 'lin', 0, 1)
								),
								order: [
									\mix,
									\lag,
									\decay_time,
									\damping,
									\feedback,
								]/*,
								specsM: (
								\feedback_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\decay_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\feedback_HP,
								\decay_time_HP,
								\damping_HP
								],
								orderMod: [
								\feedback_Mod,
								\decay_time_Mod,
								\damping_Mod
								]*/
							)
							).add;
						);

					});





					if (~hpModulation == 0, {

						// inutile d'utiliser XFade2 car FreeVerb intègre une dry/wet balance mais le ControlSpec est différent du \mix aux autres effets (0/1 au lieu de -1/1) ???
						// mais comment pour ne pas créer 16 audio outputs ???

						~fxSynthDef4.add(
							SynthDef(\RevF, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, /*mix0 = 0,*/ room_size = 0.5, damping = 0.5, lag = 1, lagM = 1, mix = -1;
								var env, src, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);
								// 16.do({ src = FreeVerb.ar(src, \mix0.kr(0.33, lag), \roomsize.kr(0.5, lag), \damping.kr(0.5, lag) )}); // ?????????
								efx = FreeVerb.ar(src, /*mix0*/ ((mix+1)*0.5).varlag(lagM), room_size.varlag(lag), damping.varlag(lag) );
								// efx = XFade2.ar(src, efx, \mix.kr(-1, lag));
								XOut.ar(in_bus, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1), // Adaptation et mapping du mix0 en mix pour rendre le spec cohérent avec les autres FX (de -1 à +1)
									// \mix0: ControlSpec(0, 1, 'lin', 0.01, 0 /*0.3*/),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
								),
								specsR: (
									\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
								),
								order: [
									// \mix0,
									\mix,
									\lag,
									\room_size,
									\damping
								]
							)
							).add;
						);

					},{

						if (~fx16Split == 1, {

							~fxSynthDef4.add(
								SynthDef(\RevF, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, /*mix0 = 0,*/ room_size = 0.5, damping = 0.5, room_size_HP = 0, damping_HP = 0, lag = 1, lagM = 1, mix = -1;
									var env, src, efx, mod_room_size, mod_damping;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = ~outChannelsFXSpaceCuts[serverNb].collect { |i| In.ar(in_bus+i, 1) };
									// src = In.ar(in_bus, ~numChannelsFX);

									/*// 16.do({ src = FreeVerb.ar(src, \mix0.kr(0.33, lag), \roomsize.kr(0.5, lag), \damping.kr(0.5, lag) )}); // ?????????
									efx = FreeVerb.ar(src, mix0.varlag(lag), room_size.varlag(lag), damping.varlag(lag) );
									// efx = XFade2.ar(src, efx, \mix.kr(-1, lag));*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
									mod_room_size = Control.names([\room_size_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;
									mod_damping = Control.names([\damping_Mod]).kr(0 ! ~numChannelsFX2).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX2.collect { |i|
										FreeVerb.ar(src[i], /*mix0*/ ((mix+1)*0.5).varlag(lagM), mod_room_size[i], mod_damping[i] );
									};

									// XOut.ar(in_bus, wet * env, efx)
									~outChannelsFXSpaceCuts[serverNb].collect { |i, id| XOut.ar(in_bus+i, wet * env, efx[id]) }},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1), // Adaptation et mapping du mix0 en mix pour rendre le spec cohérent avec les autres FX (de -1 à +1)
										// \mix0: ControlSpec(0, 1, 'lin', 0.01, 0 /*0.3*/),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									),
									specsR: (
										\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									),
									order: [
										// \mix0,
										\mix,
										\lag,
										\room_size,
										\damping
									],
									specsM: (
										\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\room_size_HP,
										\damping_HP
									],
									orderMod: [
										\room_size_Mod,
										\damping_Mod
									]
								)
								).add;
							);

						},{

							~fxSynthDef4.add(
								SynthDef(\RevF, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, /*mix0 = 0,*/ room_size = 0.5, damping = 0.5, room_size_HP = 0, damping_HP = 0, lag = 1, lagM = 1, mix = -1;
									var env, src, efx, mod_room_size, mod_damping;
									env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
									src = In.ar(in_bus, ~numChannelsFX);

									/*// 16.do({ src = FreeVerb.ar(src, \mix0.kr(0.33, lag), \roomsize.kr(0.5, lag), \damping.kr(0.5, lag) )}); // ?????????
									efx = FreeVerb.ar(src, mix0.varlag(lag), room_size.varlag(lag), damping.varlag(lag) );
									// efx = XFade2.ar(src, efx, \mix.kr(-1, lag));*/

									// Calcul de modHP dans la GUI, notamment dans les EZSliders NamedControl.kr
									// mod_pre_gain = \pre_gain_Mod.kr(0 ! ~numChannelsFX, lag)/*.poll*/;
									mod_room_size = Control.names([\room_size_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;
									mod_damping = Control.names([\damping_Mod]).kr(0 ! ~numChannelsFX).varlag(lag)/*.poll*/;

									efx = ~numChannelsFX.collect { |i|
										FreeVerb.ar(src[i], /*mix0*/ ((mix+1)*0.5).varlag(lagM), mod_room_size[i], mod_damping[i] );
									};

									XOut.ar(in_bus, wet * env, efx)},
								metadata: (
									specs: (
										\mix: ControlSpec(-1, 1, 'lin', 0, -1), // Adaptation et mapping du mix0 en mix pour rendre le spec cohérent avec les autres FX (de -1 à +1)
										// \mix0: ControlSpec(0, 1, 'lin', 0.01, 0 /*0.3*/),
										\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
										\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									),
									specsR: (
										\room_size: ControlSpec(0, 1, 'lin', 0.01, 0.5),
										\damping: ControlSpec(0, 1, 'lin', 0.01, 0.5),
									),
									order: [
										// \mix0,
										\mix,
										\lag,
										\room_size,
										\damping
									],
									specsM: (
										\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
										\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
									),
									orderM: [
										\room_size_HP,
										\damping_HP
									],
									orderMod: [
										\room_size_Mod,
										\damping_Mod
									]
								)
								).add;
							);

						});

					});




					// son réparti sur les 5 canaux même si input stéréo et son qui peut être très fort ?????????
					// AdCVerb - a simple reverb based on Schroeder and Moorer/Loy models, tuned for low coloration, with some special tweaks.
					// AdCVerb is a bank of comb filters going thru a bank of allpass filters, with optional predelay.
					// Input filtering is provided (high rolloff, DC removal), and it is easy and efficient to use for multichannel systems.
					/* The overall structure is:
					|||||   in (number of channels of input array, e.g. 5)
					\\|//	summed to
					|		mono
					/// \\\	fanning out to <numCombs> (e.g. 6 here)
					||| |||   comb filters
					\\ //
					|		summed to mono
					//|\\    fanned to <nOuts> allpass chain channels for decorrelation/diffuseness;
					|||||	for each channel, a chain of <numAllpasses> allPasses,
					|||||	e.g. 3 here.
					|||||
					_____________
					|||||	<nOuts> output channels.*/

					// There is no specific design of first reflections; if there are no particular demands on the early reflections, those created by AdCVerb are often fully sufficient.
					// One can easily add first reflections, e.g. based on room geometry, by adding higher predelays, and creating a special purpose set of first reflections; then AdCVerb works well for global reverb tails.
					// Currently, the combTimes are hardcoded to be colouration-free (based on prime numbers), and they can be scaled. The allpassTimes are generated randomly based on prime number ratios, but can also be passed in if desired
					/*
					in				audio input; this is converted to mono.
					revTime 		reverb time for -60 db decay of combs.
					hfDamping		0.0 is no damping, 1.0 means high frequencies roll off significantly faster.
					nOuts			number of outputs; each out gets its own group of allpass filters for more density and decorrelation
					predelay 		predelay before reverb tail begins, in sec
					numCombs		number of combs used for reverb tail
					numAllpasses	number of allpasses used for decorrelating each out channel
					inFilter 		a coefficient for reverb input filtering; 0.0 is no filtering, 0.99 is very dark.
					combScale		scales all combTimes (within a max of 0.2 sec); can be used to adjust room size. 1.0 is default.
					apScale			scales all allpassTimes (within a max of 0.2 sec); can be used to adjust room size. 1.0 is default.
					allpassPrimes	a list of prime numbers for the allpass filters; providing them overrides numAllpasses and nOuts.
					*/
					// *verbose		turn posting of random-generated allpass number info on and off, so one can get the exact same reverb again if desired.
					// AdCVerb.verbose_(true); // post
					// *maxTime	    set the maximum delay time for predelay, combs and allpasses. When maxTime is changed, the next instance of AdCVerb will have this maxdelaytime for combs, allpasses and predelay. Default value is 0.2. XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					// if desired, use these specific random primes: e.g. [ [ 683, 757, 1319, 1597 ], [ 419, 1009, 1129, 2053 ] ]

					~fxSynthDef4.add(
						SynthDef(\RevAdC, { arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rev_time_E = 3, hf_damping = 0.1, pre_delay = 0.02, in_filter = 0.6, leak_coeff = 0.995, comb_scale = 1, allp_scale = 1, num_combs = 8, num_allp = 4, /*rev_time_HP = 0, hf_damping_HP = 0, pre_delay_HP = 0, in_filter_HP = 0, leak_coeff_HP = 0, comb_scale_HP = 0, allp_scale_HP = 0, num_combs_HP = 0, num_allp_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
							var env, src, efx;
							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							efx = AdCVerb.ar(src, rev_time_E.lag2(lag), hf_damping.varlag(lag), ~numChannelsFX, pre_delay.varlag(lag), /*\numCombsF.ir(8).round(1), \numAllpF.ir(4).round(1),*/ /*numCombsF, numAllpF,*/ 10, 6, in_filter.varlag(lag), leak_coeff.varlag(lag), comb_scale.varlag(lag), allp_scale.varlag(lag) );

							efx = XFade2.ar(src, efx, mix.varlag(lagM));
							XOut.ar(in_bus, wet * env, efx)},
						metadata: (
							specs: (
								\mix: ControlSpec(-1, 1, 'lin', 0, -1),
								\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
								\rev_time_E: ControlSpec(0.01, 100, 'exp', 0.01, 3),
								\hf_damping: ControlSpec(0, 1, 'lin', 0.01, 0.1),
								\pre_delay: ControlSpec(0, 0.2, 'lin', 0.01, 0.02),
								\in_filter: ControlSpec(-0.99, 0.99, 'lin', 0.01, 0.6),
								\leak_coeff: ControlSpec(0.8, 1.0, 'lin', 0.001, 0.995),
								\comb_scale: ControlSpec(0.1, 2, 'lin', 0.01, 1),
								\allp_scale: ControlSpec(0.1, 2, 'lin', 0.01, 1),
								// \numCombsF: ControlSpec(1, 20, 'lin', 1, 8), // fixed number - increase for more density - StaticIntegerSpec - NamedIntegersSpec ?????????
								// \numAllpF: ControlSpec(1, 20, 'lin', 1, 4) // fixed number - increase for more diffuseness - Comment varier le nb d'AllPass et de Comb Filters ?????????
							),
							specsR: (
								\rev_time_E: ControlSpec(0.01, 20, 'exp', 0.01, 3), // réduit à 20 XXXXXXXXX
								\hf_damping: ControlSpec(0, 1, 'lin', 0.01, 0.1),
								\pre_delay: ControlSpec(0, 0.2, 'lin', 0.01, 0.02),
								\in_filter: ControlSpec(-0.99, 0.99, 'lin', 0.01, 0.6),
								\leak_coeff: ControlSpec(0.8, 1.0, 'lin', 0.001, 0.995),
								\comb_scale: ControlSpec(0.1, 2, 'lin', 0.01, 1),
								\allp_scale: ControlSpec(0.1, 2, 'lin', 0.01, 1),
								// \numCombsF: ControlSpec(1, 20, 'lin', 1, 8), // fixed number - increase for more density - StaticIntegerSpec - NamedIntegersSpec ?????????
								// \numAllpF: ControlSpec(1, 20, 'lin', 1, 4) // fixed number - increase for more diffuseness - Comment varier le nb d'AllPass et de Comb Filters ?????????
							),
							order: [
								\mix,
								\lag,
								\rev_time_E,
								\hf_damping,
								\pre_delay,
								\in_filter,
								\leak_coeff,
								\comb_scale,
								\allp_scale,
								// \numCombsF,
								// \numAllpF
							]/*,
							specsM: (
							\rev_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\hf_damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\pre_delay_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\in_filter_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\leak_coeff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\comb_scale_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							\allp_scale_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
							),
							orderM: [
							\rev_time_HP,
							\hf_damping_HP,
							\pre_delay_HP,
							\in_filter_HP,
							\leak_coeff_HP,
							\comb_scale_HP,
							\allp_scale_HP
							],
							orderMod: [
							\rev_time_Mod,
							\hf_damping_Mod,
							\pre_delay_Mod,
							\in_filter_Mod,
							\leak_coeff_Mod,
							\comb_scale_Mod,
							\allp_scale_Mod
							]*/
						)
						).add;
					);





					if (~numChannels == 2, {

						//  Utilisation d'une version stéréo - GVerb prend 1 canal mono ou mixe tous les canaux sur 1 canal et sort en stéréo

						~fxSynthDef4.add(
							SynthDef(\RevG_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, room_size, rev_time_E, damping, input_bw, spread = 15, dry_level, early_level, tail_level, /*out = 0,*/ /*room_size_HP = 0, rev_time_HP = 0, damping_HP = 0, input_bw_HP = 0, spread_HP = 0, dry_level_HP = 0, early_level_HP = 0, tail_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, 2);
								// src = src[0]; // Pour ne reprendre que le signal de gauche en annulant le droit car généré par GVerb
								// src = In.ar(in_bus, 1); // seulement réverb sur 1 & 2 // pas possible de l'utiliser sur les autres canaux ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								// src2 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = GVerb.ar( // CPU spike at instantiation & zipper with changes of roomsize
									src,
									room_size.varlag(lag),
									rev_time_E.lag2(lag),
									damping.varlag(lag),
									input_bw.varlag(lag),
									spread.varlag(lag),
									dry_level.varlag(lag).dbamp,
									early_level.varlag(lag).dbamp,
									tail_level.varlag(lag).dbamp/*,
								roomsize, 0.3*/); /*+ src*/

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							variants: (
								bath: [room_size: 5, rev_time_E: 0.6, damping: 0.62, input_bw: 0.48, dry_level: -6, early_level: -11, tail_level: -13],
								liv: [room_size: 16, rev_time_E: 1.24, damping: 0.10, input_bw: 0.95, dry_level: -3, early_level: -15, tail_level: -17], // living
								chur: [room_size: 80, rev_time_E: 4.85, damping: 0.41, input_bw: 0.19, dry_level: -3, early_level: -9, tail_level: -11], // church
								cath: [room_size: 243, rev_time_E: 1, damping: 0.1, input_bw: 0.34, dry_level: -3, early_level: -11, tail_level: -9], // cathedral
								can: [room_size: 300, rev_time_E: 103, damping: 0.43, input_bw: 0.51, dry_level: -5, early_level: -26, tail_level: -20]), // canyon
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\room_size: ControlSpec(0, 300, 'lin', 0, 20),
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									// \room_size: ControlSpec(0, 300, 'lin', 0, 20), // Changing the roomsize does not work properly! Still trying to look for the bug... (-josh)
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
								),
								order: [
									\mix,
									\lag,
									\rev_time_E,
									\room_size,
									\damping,
									\input_bw,
									\spread,
									\dry_level,
									\early_level,
									\tail_level,
									\out,
									\out_mul
								]
							)
							).add;
						);

					}, {

						/* Obligé de modifier l'Array car NumChannels mixe d'une façon spécifique
						// Transformation des FX stéréo
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.2, 0, 0]), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.1, 0, 0].mirror2), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0, 0.2, 0]), /*1*/ 2) }.play
						[0.2, 0.1, 0, 0].clump(2).flop.flat
						*/

						~fxSynthDef4.add(
							SynthDef(\RevG_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, room_size, rev_time_E, damping, input_bw, spread = 15, dry_level, early_level, tail_level, out = 0, out_mul = 1, /*room_size_HP = 0, rev_time_HP = 0, damping_HP = 0, input_bw_HP = 0, spread_HP = 0, dry_level_HP = 0, early_level_HP = 0, tail_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, src3, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, 2);
								// src = src[0]; // Pour ne reprendre que le signal de gauche en annulant le droit car généré par GVerb
								// src = In.ar(in_bus, 1); // seulement réverb sur 1 & 2 // pas possible de l'utiliser sur les autres canaux ?????????
								src = In.ar(in_bus, ~numChannelsFX).clump(2).flop.flat;
								src2 = NumChannels.ar(src, 1); // récupération de tous les canaux et mix sur 1 canal car GVerb n'agit qu'en mono XXXXXX
								src3 = NumChannels.ar(src, 2); // récupération de tous les canaux et mix sur 2 canaux car besoin de mixer un signal stereo XXXXXX
								efx = GVerb.ar( // CPU spike at instantiation & zipper with changes of roomsize
									src2,
									room_size.varlag(lag),
									rev_time_E.lag2(lag),
									damping.varlag(lag),
									input_bw.varlag(lag),
									spread.varlag(lag),
									dry_level.varlag(lag).dbamp,
									early_level.varlag(lag).dbamp,
									tail_level.varlag(lag).dbamp/*,
								roomsize, 0.3*/); /*+ src*/

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src3, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus + out, wet * env, efx * out_mul.varlag(lag) )},
							variants: (
								bath: [room_size: 5, rev_time_E: 0.6, damping: 0.62, input_bw: 0.48, dry_level: -6, early_level: -11, tail_level: -13],
								liv: [room_size: 16, rev_time_E: 1.24, damping: 0.10, input_bw: 0.95, dry_level: -3, early_level: -15, tail_level: -17], // living
								chur: [room_size: 80, rev_time_E: 4.85, damping: 0.41, input_bw: 0.19, dry_level: -3, early_level: -9, tail_level: -11], // church
								cath: [room_size: 243, rev_time_E: 1, damping: 0.1, input_bw: 0.34, dry_level: -3, early_level: -11, tail_level: -9], // cathedral
								can: [room_size: 300, rev_time_E: 103, damping: 0.43, input_bw: 0.51, dry_level: -5, early_level: -26, tail_level: -20]), // canyon
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\room_size: ControlSpec(0, 300, 'lin', 0, 20),
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									// \room_size: ControlSpec(0, 300, 'lin', 0, 20), // Changing the roomsize does not work properly! Still trying to look for the bug... (-josh)
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
								),
								order: [
									\mix,
									\lag,
									\rev_time_E,
									\room_size,
									\damping,
									\input_bw,
									\spread,
									\dry_level,
									\early_level,
									\tail_level,
									\out,
									\out_mul
								]/*,
								specsM: (
								\rev_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\input_bw_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\spread_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\dry_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\early_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\tail_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								),
								orderM: [
								\rev_time_HP,
								\room_size_HP,
								\damping_HP,
								\input_bw_HP,
								\spread_HP,
								\dry_level_HP,
								\early_level_HP,
								\tail_level_HP
								],
								orderMod: [
								\rev_time_Mod,
								\room_size_Mod,
								\damping_Mod,
								\input_bw_Mod,
								\spread_Mod,
								\dry_level_Mod,
								\early_level_Mod,
								\tail_level_Mod
								]*/
							)
							).add;
							/*
							a = Synth(\RevG_2)
							*/
						);

					});





					if (~numChannels == 2, {

						// très lourd entre 30 et 40% de CPU à 5 canaux - Uilisation d'une version stéréo car multicanal trop lourd XXXXXXXXX
						// Algorithmic reverberator, designed to produce long and rich reverberant tails.
						// An algorithmic reverb, inspired by the lush chorused sound of certain vintage Lexicon and Alesis reverberation units.
						// Designed to sound great with synthetic sound sources, rather than sound like a realistic space.
						/*
						t60	        approximate reverberation time in seconds (T60 - the time for the reverb to decay 60db). Does not effect early reflections. (0.1..60)
						damp	    controls damping of high-frequencies as the reverb decays. 0 is no damping, 1 is very strong damping (0..1)
						size	    scales size of delay-lines within the reverberator, producing the impression of a larger or smaller space. Values below 1 can sound metallic. (0.5..5)
						earlyDiff	controls shape of early reflections. Values of 0.707 or more produce smooth exponential decay. Lower values produce a slower build-up of echoes. (0..1)
						modDepth	depth of delay-line modulation. Use in combination with modFreq to set amount of chorusing within the structure. (0..1)
						modFreq	    frequency of delay-line modulation. Use in combination with modDepth to set amount of chorusing within the structure. (0..10)
						low	        multiplier for the reverberation time within the low band. (0..1)
						mid	        multiplier for the reverberation time within the mid band. (0..1)
						high	    multiplier for the reverberation time within the high band. (0..1)
						lowcut	    frequency at which the crossover between the low and mid bands of the reverb occurs. (100..6000)
						highcut	    frequency at which the crossover between the mid and high bands of the reverb occurs. (1000..10000)
						*/

						~fxSynthDef4.add(
							SynthDef(\JPverb_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rev_time = 2, damping = 0, room_size = 1, early_diff = 0.707, mod_depth = 0.1, mod_freq = 2, lo_mul_time = 1, mi_mul_time = 1, hi_mul_time = 1, lo_cross = 500, hi_cross = 2000, /*out = 0,*/ /*rev_time_HP = 0, damping_HP = 0, room_size_HP = 0, early_diff_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0, lo_mul_time_HP = 0, mi_mul_time_HP = 0, hi_mul_time_HP = 0, lo_cross_HP = 0, hi_cross_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // input to the reverb. Either an array of two audio signals, or one audiosignal
								src = In.ar(in_bus, ~numChannelsFX);
								// src2 = NumChannels.ar(src, /*1*/ 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = JPverb.ar(src, rev_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), early_diff.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag), lo_mul_time.varlag(lag), mi_mul_time.varlag(lag), hi_mul_time.varlag(lag), lo_cross.varlag(lag), hi_cross.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = JPverb.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \earlyDiff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag), \low.kr(1, lag), \mid.kr(1, lag), \high.kr(1, lag), \lowcut.kr(500, lag), \highcut.kr(2000, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							variants: ( // extraites de l'aide de JPverb - pas encore de prise en compte de l'amplitude et du wet - comment le prendre en compte ???

								dream: [rev_time: 60, damping: 0.31443298969072, room_size: 2.7938144329897, early_diff: 0.421875, mod_depth: 4.639175257732, mod_freq: 0.10309278350515, lo_mul_time: 0.84375, mi_mul_time: 0.70618556701031, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 1024.0219794048], // Amp : 0.6 - Wet : 0.9921875

								a: [rev_time: 16, damping: 0.671875, room_size: 0.94921875, early_diff: 0.421875, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 4450.794062356], // Amp : 0.66015625

								b: [rev_time: 60, damping: 0.671875, room_size: 0.94921875, early_diff: 0.421875, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 4450.794062356], // Amp : 0.66015625

								c: [rev_time: 4.0375572334984, damping: 0.2890625, room_size: 0.6171875, early_diff: 0.765625, mod_depth: 0.0, mod_freq: 2.03125, lo_mul_time: 0.609375, mi_mul_time: 0.515625, hi_mul_time: 0.2265625, lo_cross: 681.56675509913, hi_cross: 7233.9416273667], // Amp : 0.38092041015625

								d: [rev_time: 0.16483258382257, damping: 0.875, room_size: 0.5, early_diff: 0.765625, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 100.0, hi_cross: 5829.4153471361], // Amp : 0.66015625
							),
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\lo_cross: ControlSpec(100, 6000, 'lin', 1, 500),
									\hi_cross: ControlSpec(1000, 10000, 'lin', 1, 2000),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
									// \lowcut: ControlSpec(100, 6000, 'lin', 1, 500),
									// \highcut: ControlSpec(1000, 10000, 'lin', 1, 2000),
								),
								order: [
									\mix,
									\lag,
									\rev_time,
									\room_size,
									\damping,
									\early_diff,
									\mod_depth,
									\mod_freq,
									\lo_mul_time,
									\mi_mul_time,
									\hi_mul_time,
									\lo_cross,
									\hi_cross,
									\out,
									\out_mul
								]
							)
							).add;
						);

					},{

						/* Obligé de modifier l'Array car NumChannels mixe d'une façon spécifique
						// Transformation des FX stéréo
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.2, 0, 0]), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0.1, 0, 0].mirror2), /*1*/ 2) }.play
						{ NumChannels.ar(WhiteNoise.ar([0.2, 0, 0.2, 0]), /*1*/ 2) }.play
						[0.2, 0.1, 0, 0].clump(2).flop.flat
						*/

						~fxSynthDef4.add(
							SynthDef(\JPverb_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rev_time = 2, damping = 0, room_size = 1, early_diff = 0.707, mod_depth = 0.1, mod_freq = 2, lo_mul_time = 1, mi_mul_time = 1, hi_mul_time = 1, lo_cross = 500, hi_cross = 2000, out = 0, out_mul = 1, /*rev_time_HP = 0, damping_HP = 0, room_size_HP = 0, early_diff_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0, lo_mul_time_HP = 0, mi_mul_time_HP = 0, hi_mul_time_HP = 0, lo_cross_HP = 0, hi_cross_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // input to the reverb. Either an array of two audio signals, or one audiosignal
								src = In.ar(in_bus, ~numChannelsFX).clump(2).flop.flat;
								src2 = NumChannels.ar(src, /*1*/ 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = JPverb.ar(src2, rev_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), early_diff.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag), lo_mul_time.varlag(lag), mi_mul_time.varlag(lag), hi_mul_time.varlag(lag), lo_cross.varlag(lag), hi_cross.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = JPverb.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \earlyDiff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag), \low.kr(1, lag), \mid.kr(1, lag), \high.kr(1, lag), \lowcut.kr(500, lag), \highcut.kr(2000, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								efx = XFade2.ar(src2, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus + out, wet * env, efx * out_mul.varlag(lag) )},
							variants: ( // extraites de l'aide de JPverb - pas encore de prise en compte de l'amplitude et du wet - comment le prendre en compte ???

								dream: [rev_time: 60, damping: 0.31443298969072, room_size: 2.7938144329897, early_diff: 0.421875, mod_depth: 4.639175257732, mod_freq: 0.10309278350515, lo_mul_time: 0.84375, mi_mul_time: 0.70618556701031, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 1024.0219794048], // Amp : 0.6 - Wet : 0.9921875

								a: [rev_time: 16, damping: 0.671875, room_size: 0.94921875, early_diff: 0.421875, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 4450.794062356], // Amp : 0.66015625

								b: [rev_time: 60, damping: 0.671875, room_size: 0.94921875, early_diff: 0.421875, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 2450.0822520097, hi_cross: 4450.794062356], // Amp : 0.66015625

								c: [rev_time: 4.0375572334984, damping: 0.2890625, room_size: 0.6171875, early_diff: 0.765625, mod_depth: 0.0, mod_freq: 2.03125, lo_mul_time: 0.609375, mi_mul_time: 0.515625, hi_mul_time: 0.2265625, lo_cross: 681.56675509913, hi_cross: 7233.9416273667], // Amp : 0.38092041015625

								d: [rev_time: 0.16483258382257, damping: 0.875, room_size: 0.5, early_diff: 0.765625, mod_depth: 17.96875, mod_freq: 0.0, lo_mul_time: 0.84375, mi_mul_time: 0.5546875, hi_mul_time: 0.0, lo_cross: 100.0, hi_cross: 5829.4153471361], // Amp : 0.66015625
							),
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\lo_cross: ControlSpec(100, 6000, 'lin', 1, 500),
									\hi_cross: ControlSpec(1000, 10000, 'lin', 1, 2000),
									\out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0),
									\out_mul: ControlSpec(0, 4, 'lin', 0.01, 1)
								),
								specsR: (
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1)
									// \out: ControlSpec(0, ~numChannelsFX-2, 'lin', 1, 0)
									// \out_mul: ControlSpec(0, 3, 'lin', 0.01, 1)
									// \lowcut: ControlSpec(100, 6000, 'lin', 1, 500),
									// \highcut: ControlSpec(1000, 10000, 'lin', 1, 2000),
								),
								order: [
									\mix,
									\lag,
									\rev_time,
									\room_size,
									\damping,
									\early_diff,
									\mod_depth,
									\mod_freq,
									\lo_mul_time,
									\mi_mul_time,
									\hi_mul_time,
									\lo_cross,
									\hi_cross,
									\out,
									\out_mul
								]/*,
								specsM: (
								\rev_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\early_diff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\lo_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mi_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\hi_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\lo_cross_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\hi_cross_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\rev_time_HP,
								\room_size_HP,
								\damping_HP,
								\early_diff_HP,
								\mod_depth_HP,
								\mod_freq_HP,
								\lo_mul_time_HP,
								\mi_mul_time_HP,
								\hi_mul_time_HP,
								\lo_cross_HP,
								\hi_cross_HP
								],
								orderMod: [
								\rev_time_Mod,
								\room_size_Mod,
								\damping_Mod,
								\early_diff_Mod,
								\mod_depth_Mod,
								\mod_freq_Mod,
								\lo_mul_time_Mod,
								\mi_mul_time_Mod,
								\hi_mul_time_Mod,
								\lo_cross_Mod,
								\hi_cross_Mod
								]*/
							)
							).add;
						);

					});





					if (~numChannels == 2, {

						//  Utilisation d'une version stéréo - GVerb prend 1 canal mono ou mixe tous les canaux sur 1 canal et sort en stéréo

						~fxSynthDef4.add(
							SynthDef(\RevGA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, room_size, rev_time_E, damping, input_bw, spread = 15, dry_level, early_level, tail_level, /*out = 0,*/ /*room_size_HP = 0, rev_time_HP = 0, damping_HP = 0, input_bw_HP = 0, spread_HP = 0, dry_level_HP = 0, early_level_HP = 0, tail_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, 2);
								// src = src[0]; // Pour ne reprendre que le signal de gauche en annulant le droit car généré par GVerb
								// src = In.ar(in_bus, 1); // seulement réverb sur 1 & 2 // pas possible de l'utiliser sur les autres canaux ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								src2 = NumChannels.ar(src, 1); // récupération de tous les canaux et mix sur 1 canal
								efx = GVerb.ar( // CPU spike at instantiation & zipper with changes of roomsize
									src2,
									room_size.varlag(lag),
									rev_time_E.lag2(lag),
									damping.varlag(lag),
									input_bw.varlag(lag),
									spread.varlag(lag),
									dry_level.varlag(lag).dbamp,
									early_level.varlag(lag).dbamp,
									tail_level.varlag(lag).dbamp/*,
								roomsize, 0.3*/); /*+ src*/

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\room_size: ControlSpec(0, 300, 'lin', 0, 20),
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
								),
								specsR: (
									// \room_size: ControlSpec(0, 300, 'lin', 0, 20), // Changing the roomsize does not work properly! Still trying to look for the bug... (-josh)
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
								),
								order: [
									\mix,
									\lag,
									\rev_time_E,
									\room_size,
									\damping,
									\input_bw,
									\spread,
									\dry_level,
									\early_level,
									\tail_level
								]
							)
							).add;
						);

					}, {

						~fxSynthDef4.add(
							SynthDef(\RevGA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, room_size, rev_time_E, damping, input_bw, spread = 15, dry_level, early_level, tail_level, /*out = 0, out_mul = 1, room_size_HP = 0, rev_time_HP = 0, damping_HP = 0, input_bw_HP = 0, spread_HP = 0, dry_level_HP = 0, early_level_HP = 0, tail_level_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, 2);
								// src = src[0]; // Pour ne reprendre que le signal de gauche en annulant le droit car généré par GVerb
								// src = In.ar(in_bus, 1); // seulement réverb sur 1 & 2 // pas possible de l'utiliser sur les autres canaux ?????????
								src = In.ar(in_bus, ~numChannelsFX);
								src2 = NumChannels.ar(src, 1); // récupération de tous les canaux et mix sur 1 canal car GVerb n'agit qu'en mono XXXXXX
								efx = GVerb.ar( // CPU spike at instantiation & zipper with changes of roomsize
									src2,
									room_size.varlag(lag),
									rev_time_E.lag2(lag),
									damping.varlag(lag),
									input_bw.varlag(lag),
									spread.varlag(lag),
									dry_level.varlag(lag).dbamp,
									early_level.varlag(lag).dbamp,
									tail_level.varlag(lag).dbamp/*,
								roomsize, 0.3*/); /*+ src*/

								// avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx, mix.varlag(lagM));


								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx, mix.varlag(lag));
								*/

								// efx = XFade2.ar(src2, efx, mix.varlag(lag)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx /** out_mul.varlag(lag)*/ )},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\room_size: ControlSpec(0, 300, 'lin', 0, 20),
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
								),
								specsR: (
									// \room_size: ControlSpec(0, 300, 'lin', 0, 20), // Changing the roomsize does not work properly! Still trying to look for the bug... (-josh)
									\rev_time_E: ControlSpec(0.0001, 100, 'exp', 0.0001, 2),
									\damping: ControlSpec(0, 1, 'lin', 0, 0.5),
									\input_bw: ControlSpec(0, 1, 'lin', 0, 0.5),
									\spread: ControlSpec(0, 150, 'lin', 1, 15), // Quelle est la valeur max ??? Au delà d'un certain seuil (> 150), crash du server ?????????
									\dry_level: ControlSpec(0, -30, 'lin', 0, -10),
									\early_level: ControlSpec(0, -30, 'lin', 0, -10),
									\tail_level: ControlSpec(0, -30, 'lin', 0, -10)
								),
								order: [
									\mix,
									\lag,
									\rev_time_E,
									\room_size,
									\damping,
									\input_bw,
									\spread,
									\dry_level,
									\early_level,
									\tail_level
								]/*,
								specsM: (
								\rev_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\input_bw_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\spread_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\dry_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\early_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\tail_level_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								),
								orderM: [
								\rev_time_HP,
								\room_size_HP,
								\damping_HP,
								\input_bw_HP,
								\spread_HP,
								\dry_level_HP,
								\early_level_HP,
								\tail_level_HP
								],
								orderMod: [
								\rev_time_Mod,
								\room_size_Mod,
								\damping_Mod,
								\input_bw_Mod,
								\spread_Mod,
								\dry_level_Mod,
								\early_level_Mod,
								\tail_level_Mod
								]*/
							)
							).add;
							/*
							a = Synth(\RevG_2)
							*/
						);

					});





					if (~numChannels == 2, {

						// très lourd entre 30 et 40% de CPU à 5 canaux - Utilisation d'une version stéréo car multicanal trop lourd XXXXXXXXX
						// Algorithmic reverberator, designed to produce long and rich reverberant tails.
						// An algorithmic reverb, inspired by the lush chorused sound of certain vintage Lexicon and Alesis reverberation units.
						// Designed to sound great with synthetic sound sources, rather than sound like a realistic space.
						/*
						t60	        approximate reverberation time in seconds (T60 - the time for the reverb to decay 60db). Does not effect early reflections. (0.1..60)
						damp	    controls damping of high-frequencies as the reverb decays. 0 is no damping, 1 is very strong damping (0..1)
						size	    scales size of delay-lines within the reverberator, producing the impression of a larger or smaller space. Values below 1 can sound metallic. (0.5..5)
						earlyDiff	controls shape of early reflections. Values of 0.707 or more produce smooth exponential decay. Lower values produce a slower build-up of echoes. (0..1)
						modDepth	depth of delay-line modulation. Use in combination with modFreq to set amount of chorusing within the structure. (0..1)
						modFreq	    frequency of delay-line modulation. Use in combination with modDepth to set amount of chorusing within the structure. (0..10)
						low	        multiplier for the reverberation time within the low band. (0..1)
						mid	        multiplier for the reverberation time within the mid band. (0..1)
						high	    multiplier for the reverberation time within the high band. (0..1)
						lowcut	    frequency at which the crossover between the low and mid bands of the reverb occurs. (100..6000)
						highcut	    frequency at which the crossover between the mid and high bands of the reverb occurs. (1000..10000)
						*/

						~fxSynthDef4.add(
							SynthDef(\JPverbA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rev_time = 2, damping = 0, room_size = 1, early_diff = 0.707, mod_depth = 0.1, mod_freq = 2, lo_mul_time = 1, mi_mul_time = 1, hi_mul_time = 1, lo_cross = 500, hi_cross = 2000, /*out = 0,*/ /*rev_time_HP = 0, damping_HP = 0, room_size_HP = 0, early_diff_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0, lo_mul_time_HP = 0, mi_mul_time_HP = 0, hi_mul_time_HP = 0, lo_cross_HP = 0, hi_cross_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // input to the reverb. Either an array of two audio signals, or one audiosignal
								src = In.ar(in_bus, ~numChannelsFX);
								// src2 = NumChannels.ar(src, /*1*/ 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = JPverb.ar(src, rev_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), early_diff.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag), lo_mul_time.varlag(lag), mi_mul_time.varlag(lag), hi_mul_time.varlag(lag), lo_cross.varlag(lag), hi_cross.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = JPverb.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \earlyDiff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag), \low.kr(1, lag), \mid.kr(1, lag), \high.kr(1, lag), \lowcut.kr(500, lag), \highcut.kr(2000, lag)) };

								/* // avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								efx = XFade2.ar(src, efx, mix.varlag(lagM)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx)},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\lo_cross: ControlSpec(100, 6000, 'lin', 1, 500),
									\hi_cross: ControlSpec(1000, 10000, 'lin', 1, 2000)
								),
								specsR: (
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1)
									// \lowcut: ControlSpec(100, 6000, 'lin', 1, 500),
									// \highcut: ControlSpec(1000, 10000, 'lin', 1, 2000),
								),
								order: [
									\mix,
									\lag,
									\rev_time,
									\room_size,
									\damping,
									\early_diff,
									\mod_depth,
									\mod_freq,
									\lo_mul_time,
									\mi_mul_time,
									\hi_mul_time,
									\lo_cross,
									\hi_cross
								]
							)
							).add;
						);

					},{

						~fxSynthDef4.add(
							SynthDef(\JPverbA_2, {arg in_bus = 0, gate = 1, wet = 1, fadeTime = 1, rev_time = 2, damping = 0, room_size = 1, early_diff = 0.707, mod_depth = 0.1, mod_freq = 2, lo_mul_time = 1, mi_mul_time = 1, hi_mul_time = 1, lo_cross = 500, hi_cross = 2000, /*out = 0, out_mul = 1, rev_time_HP = 0, damping_HP = 0, room_size_HP = 0, early_diff_HP = 0, mod_depth_HP = 0, mod_freq_HP = 0, lo_mul_time_HP = 0, mi_mul_time_HP = 0, hi_mul_time_HP = 0, lo_cross_HP = 0, hi_cross_HP = 0,*/ lag = 1, mix = -1, lagM = 1;
								var env, src, src2, efx;
								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								// src = In.ar(in_bus, /*~numChannels*/ 2); // input to the reverb. Either an array of two audio signals, or one audiosignal
								src = In.ar(in_bus, ~numChannelsFX);
								src2 = NumChannels.ar(src, /*1*/ 2); // récupération de tous les canaux et mix sur 2 canaux
								efx = JPverb.ar(src2, rev_time.varlag(lag), damping.varlag(lag), room_size.varlag(lag), early_diff.varlag(lag), mod_depth.varlag(lag), mod_freq.varlag(lag), lo_mul_time.varlag(lag), mi_mul_time.varlag(lag), hi_mul_time.varlag(lag), lo_cross.varlag(lag), hi_cross.varlag(lag));
								// efx = ~numChannels.collect{ |i| efx = JPverb.ar(src[i], \delayTime.kr(2, lag), \damp.kr(0, lag), \size.kr(1, lag), \earlyDiff.kr(0.707, lag), \feedback.kr(0.9, lag), \modDepth.kr(0.1, lag), \modFreq.kr(2, lag), \low.kr(1, lag), \mid.kr(1, lag), \high.kr(1, lag), \lowcut.kr(500, lag), \highcut.kr(2000, lag)) };

								// avant multiplication du signal stereo sur tous les canaux
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lagM));

								/* // pour rediriger et faire passer les autres canaux autres que les 2 premiers
								efx = efx ++ src[2..~numChannelsFX-1];
								efx = XFade2.ar(src, efx /*[efx, efx]*/, mix.varlag(lag));*/

								// efx = XFade2.ar(src2, efx, mix.varlag(lag)); // Réduction du mix sur 2 canaux pour économiser du CPU

								XOut.ar(in_bus /*+ out*/, wet * env, efx /** out_mul.varlag(lag)*/ )},
							metadata: (
								specs: (
									\mix: ControlSpec(-1, 1, 'lin', 0, -1),
									\lag: ControlSpec(0, 30, 'lin', 0.01, 1),
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\lo_cross: ControlSpec(100, 6000, 'lin', 1, 500),
									\hi_cross: ControlSpec(1000, 10000, 'lin', 1, 2000)
								),
								specsR: (
									\rev_time: ControlSpec(0, 60, 'lin', 0.001, 1),
									\damping: ControlSpec(0, 1, 'lin', 0.01, 0),
									\room_size: ControlSpec(0.5, 5, 'lin', 0.01, 1),
									\early_diff: ControlSpec(0, 1, 'lin', 0.001, 0.707),
									\mod_depth: ControlSpec(0, 1, 'lin', 0.01, 0.1),
									\mod_freq: ControlSpec(0, 10, 'lin', 0.01, 2),
									\lo_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\mi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1),
									\hi_mul_time: ControlSpec(0, 1, 'lin', 0.01, 1)
									// \lowcut: ControlSpec(100, 6000, 'lin', 1, 500),
									// \highcut: ControlSpec(1000, 10000, 'lin', 1, 2000),
								),
								order: [
									\mix,
									\lag,
									\rev_time,
									\room_size,
									\damping,
									\early_diff,
									\mod_depth,
									\mod_freq,
									\lo_mul_time,
									\mi_mul_time,
									\hi_mul_time,
									\lo_cross,
									\hi_cross
								]/*,
								specsM: (
								\rev_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\room_size_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\damping_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\early_diff_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_depth_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mod_freq_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\lo_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\mi_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\hi_mul_time_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\lo_cross_HP: ControlSpec(-1, 1, 'lin', 0.001, 0),
								\hi_cross_HP: ControlSpec(-1, 1, 'lin', 0.001, 0)
								),
								orderM: [
								\rev_time_HP,
								\room_size_HP,
								\damping_HP,
								\early_diff_HP,
								\mod_depth_HP,
								\mod_freq_HP,
								\lo_mul_time_HP,
								\mi_mul_time_HP,
								\hi_mul_time_HP,
								\lo_cross_HP,
								\hi_cross_HP
								],
								orderMod: [
								\rev_time_Mod,
								\room_size_Mod,
								\damping_Mod,
								\early_diff_Mod,
								\mod_depth_Mod,
								\mod_freq_Mod,
								\lo_mul_time_Mod,
								\mi_mul_time_Mod,
								\hi_mul_time_Mod,
								\lo_cross_Mod,
								\hi_cross_Mod
								]*/
							)
							).add;
						);

					});





					~fxSynthDef = ~fxSynthDef1 ++ ~fxSynthDef2 ++ ~fxSynthDef3 ++ ~fxSynthDef4;

					~fxSynthDefV = ~fxSynthDef.collect { |i| i.variants.size.collect { i } }.flat; // Rajouté pour pouvoir rappeler dans les fonctions de presets les FX variants dans la GUI

					~numFxSynthDef = ~fxSynthDef.size;
					~numFxSynthDef1 = ~fxSynthDef1.size;
					~numFxSynthDef2 = ~fxSynthDef2.size;
					~numFxSynthDef3 = ~fxSynthDef3.size;
					~numFxSynthDef4 = ~fxSynthDef4.size;

					~numFxSynthDef2b = ~fxSynthDef2b.size; // EQ
					~numFxSynthDef2c = ~fxSynthDef2c.size; // Effets spectraux

					~numFxSynthDef2Cum = ~numFxSynthDef1 + ~numFxSynthDef2;
					~numFxSynthDef3Cum = ~numFxSynthDef2Cum +~numFxSynthDef3;

				); // Penser à retirer les synhés chargés sur le server si changement des définitions de synhés de FX sinon le server ne répond plus / crashe et devient jaune XXXXXXXXXXXXXXXXXXXXXXXXXXX











				// Synthèse ambisonique ATK

				~fxSynthDef5ALL = List.new; // Effets spatialisation ambisoniques - pour switcher entre zoom, focus, push, press
				~fxSynthDef6ALL = List.new; // Effets spatialisation ambisoniques - pour switcher entre zoom, focus, push, press
				~fxSynthDef7ALL = List.new; // Effets spatialisation ambisoniques - pour switcher entre polaire et cartésien
				~fxSynthDef8ALL = List.new; // Effets spatialisation ambisoniques - pour switcher entre différentes réverbs



				(
					~renderEncode = { arg src; var configEncoderATK;

						case
						{~numChannelsConfig == "2"}
						{
							configEncoderATK = FoaEncoderMatrix.newStereo(pi/4);
							FoaEncode.ar([ src[0], src[1] ], configEncoderATK);
							// voir si préférable de garder 0 pour l'angle ??????
							// When angle = 0, the left and right channels of the input signal arrive at [90, -90] degrees.
							// angle = pi/4 distorts the arrivals to [45, -45] degrees.
							// angle = pi/2, places both the left and right inputs at front centre, [0, 0] degrees.
						}
						{~numChannelsConfig == "4"} // Clockwise
						{
							configEncoderATK = FoaEncoderMatrix.newQuad;
							FoaEncode.ar([ src[0], src[3], src[2], src[1] ], configEncoderATK);
							// Inputs are in anti-clockwise order. The position of the first input channel is either centre or left of centre.
							// de 0 à 180 -> de devant à derriere sur la gauche
							// de -180 à 0 -> de derrière à devant sur la droite
							// FoaEncoderMatrix.newQuad.dirChannels * 180/pi
						}
						{~numChannelsConfig == "5-Centre"} // Clockwise sauf Centre = 3
						{
							// configEncoderATK = FoaEncoderMatrix.newPanto(5, orientation: 'point');
							// FoaEncoderMatrix.newPanto(5, orientation: 'point').dirChannels * 180/pi // Besoin de mettre une orientation point si HP central comme dans le cas du 5.1

							// configEncoderATK = FoaEncoderMatrix.new5_0;
							// ~configSrcATK = "[ src[1], src[4], src[0], src[3], src[2] ]"; // for new5_0
							// FoaEncoderMatrix.new5_0.dirChannels * 180/pi

							// préférable d'utiliser newDirections pour préciser un angle de 45° pour le L & R - new5_0 -> espacement trop petit (30°) & newPanto -> espacement trop grand (72°)
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 135, -135, -45], 0.5); // Comme la quadriphonie, plus 1 HP central
							FoaEncode.ar([ src[1], src[4], src[0], src[3], src[2] ], configEncoderATK);
							// voire avec des patterns différents de 0.5 - cardiod ???
							// FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 135, -135, -45], 0.5).dirChannels * 180/pi
							// FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 135, -135, -45], 0.5).dirChannels.raddeg
							// FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 135, -135, -45], 0.5).matrix // answers encoding matrix [ W, X, Y ]
						}
						{~numChannelsConfig == "5-Clock"} // Clockwise à partir du Centre = 0 - XXXXXX
						{
							// configEncoderATK = FoaEncoderMatrix.new5_0;
							// ~configSrcATK = "[ src[0], src[4], src[3], src[2], src[1] ]"; // for new5_0 - identique à newDirections

							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 135, -135, -45], 0.5);
							FoaEncode.ar([ src[0], src[4], src[3], src[2], src[1] ], configEncoderATK);
							// voire avec des patterns différents de 0.5 - cardiod ???
						}
						{~numChannelsConfig == "7"}
						{
							// configEncoderATK = FoaEncoderMatrix.new7_0; // [ 0, 30, 90, 135, -135, -90, -30 ]
							// encodage avec newDirections préférable pour positionner les HP L & R à 45° au lieu de 30° - comme le 8-Centre mais sans arrière ?????????
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 90, 135, -135, -90, -45], 0.5);
							FoaEncode.ar([ src[0], src[6], src[5], src[4], src[3], src[2], src[1] ], configEncoderATK);
							// FoaEncoderMatrix.newDirections( pi/180 * [0, 45, 90, 135, -135, -90, -45], 0.5).dirChannels.raddeg;
						}
						{~numChannelsConfig == "8-Centre"} // // Clockwise à partir du Centre = 0
						{
							configEncoderATK = FoaEncoderMatrix.newPanto(8, orientation: 'point');
							FoaEncode.ar([ src[0], src[7], src[6], src[5], src[4], src[3], src[2], src[1] ], configEncoderATK);
							// FoaEncoderMatrix.newPanto(8, orientation: 'point').dirChannels * 180/pi // Attribution renversée vs BFEncode (plus haut) ??????
						}
						{~numChannelsConfig == "8-PairClock"} // Clockwise à partir de la gauche - XXXXXX
						{
							configEncoderATK = FoaEncoderMatrix.newPanto(8, orientation: 'flat');
							FoaEncode.ar([ src[0], src[7], src[6], src[5], src[4], src[3], src[2], src[1] ], configEncoderATK);
							// FoaEncoderMatrix.newPanto(8, orientation: 'flat').dirChannels * 180/pi
						}
						{~numChannelsConfig == "8-PairPair"} // en alternant gauche / droite, du devant vers l'arrière
						{
							configEncoderATK = FoaEncoderMatrix.newPanto(8, orientation: 'flat');
							FoaEncode.ar([ src[0], src[7], src[1], src[6], src[2], src[5], src[3], src[4] ], configEncoderATK);
							// préférable d'utiliser newDirections pour préciser un angle
							// voire le niveau d'élévation à indiquer -> 0 / 35 / 80 (90 pour 1 HP à la verticale)
						}
						{~numChannelsConfig == "16-Dome-8-6-2-Pair"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[22.5, 0], [-22.5, 0], [67.5, 0], [-67.5, 0], [112.5, 0], [-112.5, 0], [157.5, 0], [-157.5, 0], [60, 45], [-60, 45], [120, 45], [-120, 45], [0, 45], [180, 45], [90, 85], [-90, 85]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[7], src[2], src[6], src[3], src[5], src[4], src[13], src[9], src[12], src[10], src[8], src[11], src[14], src[15] ], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "16-Dome-8-6-2-Clock" or: {~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"}}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [0, 45], [-60, 45], [-120, 45], [180, 45], [120, 45], [60, 45], [90, 85], [-90, 85]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15]], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "16-UsineC-2Octo"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [22.5, 45], [-22.5, 45], [-67.5, 45], [-112.5, 45], [-157.5, 45], [157.5, 45], [112.5, 45], [67.5, 45]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15]], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "24-UsineC-3Octo"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [22.5, 33], [-22.5, 33], [-67.5, 33], [-112.5, 33], [-157.5, 33], [157.5, 33], [112.5, 33], [67.5, 33], [22.5, 66], [-22.5, 66], [-67.5, 66], [-112.5, 66], [-157.5, 66], [157.5, 66], [112.5, 66], [67.5, 66]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23]], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "32-Dome-12-10-8-2"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [75, 0], [45, 0], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [90, 30], [54, 30], [22.5, 60], [-22.5, 60], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 85], [-90, 85]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31]], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "32-Dome-12-10-8-2-Motu"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [75, 0], [45, 0], [15, 0], [-15, 0], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [90, 30], [54, 30], [18, 30], [-18, 30], [90, 85], [-90, 85], [22.5, 60], [-22.5, 60], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60]], 0.5)
							/*( pi/180 * [[75, 0], [45, 0], [15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [90, 30], [54, 30], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 80], [-90, 80], [22.5, 60], [-22.5, 60]], 0.5)*/;
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31]], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "22-8+Dome-8-4-2-Pair"}
						{
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[22.5, 0], [-22.5, 0], [67.5, 0], [-67.5, 0], [112.5, 0], [-112.5, 0], [157.5, 0], [-157.5, 0], [60, 35], [-60, 35], [120, 35], [-120, 35], [90, 80], [-90, 80]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[7], src[2], src[6], src[3], src[5], src[4], src[8], src[9], src[11], src[10], src[12], src[13] ], configEncoderATK);
						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "64-CentreClock"}
						{
							// Array.series(64,0,2pi/64).raddeg
							// [ 0, -5.625, -11.25, -16.875, -22.5, -28.125, -33.75, -39.375, -45, -50.625, -56.25, -61.875, -67.5, -73.125, -78.75, -84.375, -90, -95.625, -101.25, -106.875, -112.5, -118.125, -123.75, -129.375, -135, -140.625, -146.25, -151.875, -157.5, -163.125, -168.75, -174.375, -180 ]++ [ 174.375, 168.75, 163.125, 157.5, 151.875, 146.25, 140.625, 135, 129.375, 123.75, 118.125, 112.5, 106.875, 101.25, 95.625, 90, 84.375, 78.75, 73.125, 67.5, 61.875, 56.25, 50.625, 45, 39.375, 33.75, 28.125, 22.5, 16.875, 11.25, 5.625 ]

							/*
							ERROR: matrix singular in Matrix-inverse avec 64 HP ????????????????????????????????????
							configEncoderATK = FoaEncoderMatrix.newDirections( /*pi/180 * */[ [0, 0], [-5.625, 0], [-11.25, 0], [-16.875, 0], [-22.5, 0], [-28.125, 0], [-33.75, 0], [-39.375, 0], [-45, 0], [-50.625, 0], [-56.25, 0], [-61.875, 0], [-67.5, 0], [-73.125, 0], [-78.75, 0], [-84.375, 0], [-90, 0], [-95.625, 0], [-101.25, 0], [-106.875, 0], [-112.5, 0], [-118.125, 0], [-123.75, 0], [-129.375, 0], [-135, 0], [-140.625, 0], [-146.25, 0], [-151.875, 0], [-157.5, 0], [-163.125, 0], [-168.75, 0], [-174.375, 0], [180, 0], [174.375, 0], [168.75, 0], [163.125, 0], [157.5, 0], [151.875, 0], [146.25, 0], [140.625, 0], [135, 0], [129.375, 0], [123.75, 0], [118.125, 0], [112.5, 0], [106.875, 0], [101.25, 0], [95.625, 0], [90, 0], [84.375, 0], [78.75, 0], [73.125, 0], [67.5, 0], [61.875, 0], [56.25, 0], [50.625, 0], [45, 0], [39.375, 0], [33.75, 0], [28.125, 0], [22.5, 0], [16.875, 0], [11.25, 0], [5.625, 0] ].degrad, 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31], src[32], src[33], src[34], src[35], src[36], src[37], src[38], src[39], src[40], src[41], src[42], src[43], src[44], src[45], src[46], src[47], src[48], src[49], src[50], src[51], src[52], src[53], src[54], src[55], src[56], src[57], src[58], src[59], src[60], src[61], src[62], src[63] ], configEncoderATK);*/

							configEncoderATK = FoaEncoderMatrix.newPanto(64, orientation: 'point');
							FoaEncode.ar([ src[63], src[62], src[61], src[60], src[59], src[58], src[57], src[56], src[55], src[54], src[53], src[52], src[51], src[50], src[49], src[48], src[46], src[46], src[45], src[44], src[43], src[42], src[41], src[40], src[39], src[38], src[37], src[36], src[35], src[34], src[33], src[32], src[31], src[30], src[29], src[28], src[27], src[26], src[25], src[24], src[23], src[22], src[21], src[20], src[19], src[18], src[17], src[16], src[15], src[14], src[13], src[12], src[11], src[10], src[9], src[8], src[7], src[6], src[5], src[4], src[3], src[2], src[1], src[0] ], configEncoderATK);
							// FoaEncoderMatrix.newPanto(64, orientation: 'point').dirChannels * 180/pi

							/*
							// Pourquoi ne marche pas alors qu'ok en dessous ???
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [ [-1, 0], [-11, 0], [-22, 0], [-33, 0], [-45, 0], [-56, 0], [-67, 0], [-78, 0], [-90, 0], [-101, 0], [-112, 0], [-123, 0], [-135, 0], [-146, 0], [-157, 0], [-168, 0], [-179, 0], [168, 0], [157, 0], [146, 0], [135, 0], [123, 0], [112, 0], [101, 0], [90, 0], [78, 0], [73, 0], [61, 0], [50, 0], [39, 0], [28, 0], [16, 0] ], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31]], configEncoderATK);
							*/

							/* // OK repis du 32 ???
							configEncoderATK = FoaEncoderMatrix.newDirections( pi/180 * [[15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [75, 0], [45, 0], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [90, 30], [54, 30], [22.5, 60], [-22.5, 60], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 85], [-90, 85]], 0.5);
							FoaEncode.ar([ src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7], src[8], src[9], src[10], src[11], src[12], src[13], src[14], src[15], src[16], src[17], src[18], src[19], src[20], src[21], src[22], src[23], src[24], src[25], src[26], src[27], src[28], src[29], src[30], src[31]], configEncoderATK);
							*/

						} // le signe négatif correspond à la droite

						{~numChannelsConfig == "96-CentreClock"}
						{
							configEncoderATK = FoaEncoderMatrix.newPanto(96, orientation: 'point');
							FoaEncode.ar([ src[95], src[94], src[93], src[92], src[91], src[90], src[89], src[88], src[87], src[86], src[85], src[84], src[83], src[82], src[81], src[80], src[79], src[78], src[77], src[76], src[75], src[74], src[73], src[72], src[71], src[70], src[69], src[68], src[67], src[66], src[65], src[64], src[63], src[62], src[61], src[60], src[59], src[58], src[57], src[56], src[55], src[54], src[53], src[52], src[51], src[50], src[49], src[48], src[46], src[46], src[45], src[44], src[43], src[42], src[41], src[40], src[39], src[38], src[37], src[36], src[35], src[34], src[33], src[32], src[31], src[30], src[29], src[28], src[27], src[26], src[25], src[24], src[23], src[22], src[21], src[20], src[19], src[18], src[17], src[16], src[15], src[14], src[13], src[12], src[11], src[10], src[9], src[8], src[7], src[6], src[5], src[4], src[3], src[2], src[1], src[0] ], configEncoderATK);
							// FoaEncoderMatrix.newPanto(64, orientation: 'point').dirChannels * 180/pi
						}

						{~numChannelsConfig == "128-CentreClock"}
						{
							configEncoderATK = FoaEncoderMatrix.newPanto(128, orientation: 'point');
							FoaEncode.ar([ src[127], src[126], src[125], src[124], src[123], src[122], src[121], src[120], src[119], src[118], src[117], src[116], src[115], src[114], src[113], src[112], src[111], src[110], src[109], src[108], src[107], src[106], src[105], src[104], src[103], src[102], src[101], src[100], src[99], src[98], src[97], src[96], src[95], src[94], src[93], src[92], src[91], src[90], src[89], src[88], src[87], src[86], src[85], src[84], src[83], src[82], src[81], src[80], src[79], src[78], src[77], src[76], src[75], src[74], src[73], src[72], src[71], src[70], src[69], src[68], src[67], src[66], src[65], src[64], src[63], src[62], src[61], src[60], src[59], src[58], src[57], src[56], src[55], src[54], src[53], src[52], src[51], src[50], src[49], src[48], src[46], src[46], src[45], src[44], src[43], src[42], src[41], src[40], src[39], src[38], src[37], src[36], src[35], src[34], src[33], src[32], src[31], src[30], src[29], src[28], src[27], src[26], src[25], src[24], src[23], src[22], src[21], src[20], src[19], src[18], src[17], src[16], src[15], src[14], src[13], src[12], src[11], src[10], src[9], src[8], src[7], src[6], src[5], src[4], src[3], src[2], src[1], src[0] ], configEncoderATK);
							// FoaEncoderMatrix.newPanto(64, orientation: 'point').dirChannels * 180/pi
						}
					}
				);




				(
					~renderDecode = { arg in;
						var fl, bl, br, fr; // Front links / Back Links / Back right / Front right
						var fc/*, lo*/; // Font Center / LFO
						var bc, l, r; // Back Center / Links / Right (aux extrémités) -> pour la ~numChannelsConfig == "8-Centre"
						var ml1, mr1, ml2, mr2; // Mid Links & Right 1 & 2 -> pour la numChannelsConfig == "8-PairClock" & "8-PairPair"

						// var h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32;
						// h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64;
						// impact CPU si trop de variables ????????????????????????????????????????????????????????????????????????????????????????????????????????????

						var h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64, h65, h66, h67, h68, h69, h70, h71, h72, h73, h74, h75, h76, h77, h78, h79, h80, h81, h82, h83, h84, h85, h86, h87, h88, h89, h90, h91, h92, h93, h94, h95, h96, h97, h98, h99, h100, h101, h102, h103, h104, h105, h106, h107, h108, h109, h110, h111, h112, h113, h114, h115, h116, h117, h118, h119, h120, h121, h122, h123, h124, h125, h126, h127, h128;

						/*if (~numChannelsConfig == "128-CentreClock", {
						var h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64, h65, h66, h67, h68, h69, h70, h71, h72, h73, h74, h75, h76, h77, h78, h79, h80, h81, h82, h83, h84, h85, h86, h87, h88, h89, h90, h91, h92, h93, h94, h95, h96, h97, h98, h99, h100, h101, h102, h103, h104, h105, h106, h107, h108, h109, h110, h111, h112, h113, h114, h115, h116, h117, h118, h119, h120, h121, h122, h123, h124, h125, h126, h127, h128;
						},{
						if (~numChannelsConfig == "64-CentreClock", {
						var h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64;
						},{
						var h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32;
						});
						});*/



						case
						{~ambATKConfig == "binaural"}
						{ FoaDecode.ar(in, ~binauralDecoder[serverNb]) } // voire pour la mise en place d'un décodeur binaural ???

						{~ambATKConfig == "stereo"}
						// voire aussi intérêt du Virtual microphone stereophonic decoder -> FoaDecoderMatrix.newStereo(~angle, ~pattern) ???
						{ FoaDecode.ar(in, ~stereoDecoder[serverNb] /*FoaDecoderKernel.newUHJ*/) } // Stéréo - incidence et importance de la taille du kernelSize en stereo ??? - voire ci-dessous en partie

						{~ambATKConfig == "multiChannel"}

						{ // différentes configs pour multicanal et stéréo
							case
							{~numChannelsConfig == "2"}
							{
								FoaDecode.ar(in, ~stereoDecoder[serverNb]); // Stéréo
								/*
								For stereo decoding, you should think of the UHJ decoder as the ambisonic 'native' stereo output...
								so that when you plan to distribute or otherwise monitor in stereo, this should be your first choice.
								UHJ gives a broad image beyound the edges of the stereo pair with a natural sounding depth into the image.

								UHJ is also interesting in that we can go back and forth between UHJ and horizontal only b-format.
								(The ATK includes a UHJ encoder!)
								We do lose information in this process--decoding to UHJ 'compresses' three channels [W, X, Y] down to two [L, R],
								so it shouldn't be surprising that some information is lost.

								It should be noted that the kernel decoders add a delay to the signal of approximately kernelSize/2 samples.
								*/
							}
							{~numChannelsConfig == "4"}
							{
								#fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.newQuad(angle: pi/4, k: ~ambATKkFactor));

								// reorder output to match speaker arrangement
								[fl, fr, br, bl]
							}
							{~numChannelsConfig == "5-Centre"}
							{
								// #fc, fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [0, 45, 135, -135, -45], k: ~ambATKkFactor) );
								// FoaDecoderMatrix.newDiametric( pi/180 * [0, 45, 135, -135, -45]).dirChannels // Pas bon car double les coordonnées selon un axe et requiert un nb de HP pairs ???

								#fc, fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.new5_0(irregKind: 'equal')); // equal - focused - four
								// FoaDecoderMatrix.new5_0(irregKind: 'equal').dirChannels.raddeg

								// #fc, fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(5, orientation: 'point', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(5, orientation: 'point', k: ~ambATKkFactor).dirChannels.raddeg

								// lo = Silent.ar;
								// reorder output to match speaker arrangement
								// [fl, fr, fc, lo, bl, br]

								// reorder output to match speaker arrangement - CL
								[fl, fr, fc, br, bl] // dans le sens des aiguilles d'une montre excepté le centre
							}
							{~numChannelsConfig == "5-Clock"}
							{
								#fc, fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.new5_0(irregKind: 'equal')); // equal - focused - four
								// #fc, fl, bl, br, fr = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(5, orientation: 'point', k: ~ambATKkFactor));

								// reorder output to match speaker arrangement - CL
								[fc, fr, br, bl, fl] // dans le sens des aiguilles à partir du centre
							}
							{~numChannelsConfig == "7"}
							{
								#fc, fl, l, bl, br, r, fr =  FoaDecode.ar(in, FoaDecoderMatrix.newPanto(7, orientation: 'point', k: ~ambATKkFactor));
								// à vérifier l'encodage et le décodage pour le 7.0 ?????????
								// FoaDecoderMatrix.newPanto(7, orientation: 'point', k: ~ambATKkFactor).dirChannels.raddeg.round(0.5)
								[fc, fr, r, br, bl, l, fl]
							}
							{~numChannelsConfig == "8-Centre"}
							{
								#fc, fl, l, bl, bc, br, r, fr = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(8, orientation: 'point', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(8, orientation: 'point', k: ~ambATKkFactor).dirChannels.raddeg
								[fc, fr, r, br, bc, bl, l, fl]
							}
							{~numChannelsConfig == "8-PairClock"}
							{
								#fl, ml1, ml2, bl, br, mr2, mr1, fr = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(8, orientation: 'flat', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(8, orientation: 'flat', k: ~ambATKkFactor).dirChannels.raddeg
								[fl, fr, mr1, mr2, br, bl, ml2, ml1]
							}
							{~numChannelsConfig == "16-Dome-8-6-2-Pair"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[22.5, 0], [-22.5, 0], [67.5, 0], [-67.5, 0], [112.5, 0], [-112.5, 0], [157.5, 0], [-157.5, 0], [60, 35], [-60, 35], [120, 35], [-120, 35], [0, 35], [180, 35], [90, 80], [-90, 80]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h8, h3, h7, h4, h6, h5, h14, h10, h13, h11, h9, h12, h15, h16]
							}
							{~numChannelsConfig == "16-Dome-8-6-2-Clock" or: {~numChannelsConfig == "16-Dome-8-6-2-Clock-CC"}}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [0, 35], [-60, 35], [-120, 35], [180, 35], [120, 35], [60, 35], [90, 80], [-90, 80]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16] // réattribution dans la carte son
							}
							{~numChannelsConfig == "16-UsineC-2Octo"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [22.5, 45], [-22.5, 45], [-67.5, 45], [-112.5, 45], [-157.5, 45], [157.5, 45], [112.5, 45], [67.5, 45]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16] // réattribution dans la carte son
							}
							{~numChannelsConfig == "24-UsineC-3Octo"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[22.5, 0], [-22.5, 0], [-67.5, 0], [-112.5, 0], [-157.5, 0], [157.5, 0], [112.5, 0], [67.5, 0], [22.5, 33], [-22.5, 33], [-67.5, 33], [-112.5, 33], [-157.5, 33], [157.5, 33], [112.5, 33], [67.5, 33], [22.5, 66], [-22.5, 66], [-67.5, 66], [-112.5, 66], [-157.5, 66], [157.5, 66], [112.5, 66], [67.5, 66]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24] // réattribution dans la carte son
							}
							{~numChannelsConfig == "32-Dome-12-10-8-2"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [75, 0], [45, 0], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [90, 30], [54, 30], [22.5, 60], [-22.5, 60], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 80], [-90, 80]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32] // réattribution dans la carte son
							}
							{~numChannelsConfig == "32-Dome-12-10-8-2-Motu"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[75, 0], [45, 0], [15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [90, 30], [54, 30], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 80], [-90, 80], [22.5, 60], [-22.5, 60]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32] // réattribution adaptée à la carte son Motu
							}
							{~numChannelsConfig == "22-8+Dome-8-4-2-Pair"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[22.5, 0], [-22.5, 0], [67.5, 0], [-67.5, 0], [112.5, 0], [-112.5, 0], [157.5, 0], [-157.5, 0], [60, 35], [-60, 35], [120, 35], [-120, 35], [90, 80], [-90, 80]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h8, h3, h7, h4, h6, h5, h9, h10, h12, h11, h13, h14]
							}
							{~numChannelsConfig == "64-CentreClock"}
							{
								// #h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [ [0, 0], [-5.625, 0], [-11.25, 0], [-16.875, 0], [-22.5, 0], [-28.125, 0], [-33.75, 0], [-39.375, 0], [-45, 0], [-50.625, 0], [-56.25, 0], [-61.875, 0], [-67.5, 0], [-73.125, 0], [-78.75, 0], [-84.375, 0], [-90, 0], [-95.625, 0], [-101.25, 0], [-106.875, 0], [-112.5, 0], [-118.125, 0], [-123.75, 0], [-129.375, 0], [-135, 0], [-140.625, 0], [-146.25, 0], [-151.875, 0], [-157.5, 0], [-163.125, 0], [-168.75, 0], [-174.375, 0], [-180, 0], [174.375, 0], [168.75, 0], [163.125, 0], [157.5, 0], [151.875, 0], [146.25, 0], [140.625, 0], [135, 0], [129.375, 0], [123.75, 0], [118.125, 0], [112.5, 0], [106.875, 0], [101.25, 0], [95.625, 0], [90, 0], [84.375, 0], [78.75, 0], [73.125, 0], [67.5, 0], [61.875, 0], [56.25, 0], [50.625, 0], [45, 0], [39.375, 0], [33.75, 0], [28.125, 0], [22.5, 0], [16.875, 0], [11.25, 0], [5.625, 0] ], k: ~ambATKkFactor)); // le signe négatif correspond à la droite

								/*#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( /*pi/180 * */[0, -5.625, -11.25, -16.875, -22.5, -28.125, -33.75, -39.375, -45, -50.625, -56.25, -61.875, -67.5, -73.125, -78.75, -84.375, -90, -95.625, -101.25, -106.875, -112.5, -118.125, -123.75, -129.375, -135, -140.625, -146.25, -151.875, -157.5, -163.125, -168.75, -174.375, -180, 174.375, 168.75, 163.125, 157.5, 151.875, 146.25, 140.625, 135, 129.375, 123.75, 118.125, 112.5, 106.875, 101.25, 95.625, 90, 84.375, 78.75, 73.125, 67.5, 61.875, 56.25, 50.625, 45, 39.375, 33.75, 28.125, 22.5, 16.875, 11.25, 5.625 ].degrad, k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64]*/

								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64 = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(64, orientation: 'flat', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(64, orientation: 'point', k: 0.5).dirChannels.raddeg
								[ h64, h63, h62, h61, h60, h59, h58, h57, h56, h55, h54, h53, h52, h51, h50, h49, h48, h47, h46, h45, h44, h43, h42, h41, h40, h39, h38, h37, h36, h35, h34, h33, h32, h31, h30, h29, h28, h27, h26, h25, h24, h23, h22, h21, h20, h19, h18, h17, h16, h15, h14, h13, h12, h11, h10, h9, h8, h7, h6, h5, h4, h3, h2, h1 ] // réattribution dans la carte son

								/*
								// OK repis du 32 ???
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32 = FoaDecode.ar(in, FoaDecoderMatrix.newDiametric( pi/180 * [[15, 0], [-15, 0], [-45, 0], [-75, 0], [-105, 0], [-135, 0], [-165, 0], [165, 0], [135, 0], [105, 0], [75, 0], [45, 0], [18, 30], [-18, 30], [-54, 30], [-90, 30], [-126, 30], [-162, 30], [162, 30], [126, 30], [90, 30], [54, 30], [22.5, 60], [-22.5, 60], [-67.5, 60], [-112.5, 60], [-157.5, 60], [157.5, 60], [112.5, 60], [67.5, 60], [90, 80], [-90, 80]], k: ~ambATKkFactor)); // le signe négatif correspond à la droite
								[h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32] // réattribution dans la carte son
								*/

							}

							{~numChannelsConfig == "96-CentreClock"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64, h65, h66, h67, h68, h69, h70, h71, h72, h73, h74, h75, h76, h77, h78, h79, h80, h81, h82, h83, h84, h85, h86, h87, h88, h89, h90, h91, h92, h93, h94, h95, h96 = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(128, orientation: 'flat', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(64, orientation: 'point', k: 0.5).dirChannels.raddeg
								[ h96, h95, h94, h93, h92, h91, h90, h89, h88, h87, h86, h85, h84, h83, h82, h81, h80, h79, h78, h77, h76, h75, h74, h73, h72, h71, h70, h69, h68, h67, h66, h65, h64, h63, h62, h61, h60, h59, h58, h57, h56, h55, h54, h53, h52, h51, h50, h49, h48, h47, h46, h45, h44, h43, h42, h41, h40, h39, h38, h37, h36, h35, h34, h33, h32, h31, h30, h29, h28, h27, h26, h25, h24, h23, h22, h21, h20, h19, h18, h17, h16, h15, h14, h13, h12, h11, h10, h9, h8, h7, h6, h5, h4, h3, h2, h1 ] // réattribution dans la carte son
							}

							{~numChannelsConfig == "128-CentreClock"}
							{
								#h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h50, h51, h52, h53, h54, h55, h56, h57, h58, h59, h60, h61, h62, h63, h64, h65, h66, h67, h68, h69, h70, h71, h72, h73, h74, h75, h76, h77, h78, h79, h80, h81, h82, h83, h84, h85, h86, h87, h88, h89, h90, h91, h92, h93, h94, h95, h96, h97, h98, h99, h100, h101, h102, h103, h104, h105, h106, h107, h108, h109, h110, h111, h112, h113, h114, h115, h116, h117, h118, h119, h120, h121, h122, h123, h124, h125, h126, h127, h128 = FoaDecode.ar(in, FoaDecoderMatrix.newPanto(128, orientation: 'flat', k: ~ambATKkFactor));
								// FoaDecoderMatrix.newPanto(64, orientation: 'point', k: 0.5).dirChannels.raddeg
								[ h128, h127, h126, h125, h124, h123, h122, h121, h120, h119, h118, h117, h116, h115, h114, h113, h112, h111, h110, h109, h108, h107, h106, h105, h104, h103, h102, h101, h100, h99, h98, h97, h96, h95, h94, h93, h92, h91, h90, h89, h88, h87, h86, h85, h84, h83, h82, h81, h80, h79, h78, h77, h76, h75, h74, h73, h72, h71, h70, h69, h68, h67, h66, h65, h64, h63, h62, h61, h60, h59, h58, h57, h56, h55, h54, h53, h52, h51, h50, h49, h48, h47, h46, h45, h44, h43, h42, h41, h40, h39, h38, h37, h36, h35, h34, h33, h32, h31, h30, h29, h28, h27, h26, h25, h24, h23, h22, h21, h20, h19, h18, h17, h16, h15, h14, h13, h12, h11, h10, h9, h8, h7, h6, h5, h4, h3, h2, h1 ] // réattribution dans la carte son
							}

						}
					}
				);





				~ambATKSynthDefNames = [\PosZoom, \PosFocus, \PosPush, \PosPress];
				~ambATKTransformerNames = ['zoom', 'focus', 'push', 'press'];

				4.do { |i|
					~fxSynthDef5ALL.add(
						SynthDef(~ambATKSynthDefNames[i], { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, angle = 0, azim = 0, dist = 1, elev = 0, distMin = 0.05, lag = 1/*, mix = -1*/;

							var env, src, foa, freq, amp, distance, ang;

							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							distance = dist.varlag(lag);
							amp = (1-distance).linlin(0, 1, 0.05, 1.5)/*.poll*/;
							/*
							// Modifier le calcul de la distance de manière plus réaliste
							0.04.ampdb
							d = 5;
							a = 1/(d.pow(2)) // 1/d2
							a = 1/(d.pow(2.5)) // 1/d2.5
							*/

							// lets make this more realistic, controlling both the apparent width and the proximity, and the gain..
							// Controle de l'angle - (90.degrad) -> 1 / (60.degrad) -> 0.5 / (30.degrad) -> 0.125 / (0.degrad) -> 0.0625
							// Voire la curve (-5, moins radical) la plus réaliste pour l'ouverture de l'angle en fonction de la distance ?????????
							// Augmentation de la largeur de la source avec la distance sinon changemement brusque de position dans le cercle rapproché ?????????
							ang = distance.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
							// 0.25.lincurve(0, 1, 0, -pi/2, -6).raddeg

							// Problème lorsque angle de 0 et source au centre -> augmentation du signal sur l'avant gauche et l'arrière droit alors que le signal devrait augmenter uniformément.
							// ?????????

							/*azimD = azim.degrad; // degrad ne marche pas sur le server
							elevD = elev.degrad;*/

							// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
							ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

							// Encode into our foa signal
							foa = ~renderEncode.value(src);

							foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, azim.varlag(lag), elev.varlag(lag));   // image / pan
							freq = 20.0;				// HPF, to control proximity boost
							foa = HPF.ar(foa, freq);		// precondition signal for proximity
							foa = FoaTransform.ar(foa, 'proximity', distance.max(distMin));   // image

							foa = ~renderDecode.value(foa);

							// Out.ar(out_bus, foa * amp);
							// efx = XFade2.ar(src, efx, mix.varlag(lag));
							XOut.ar(in_bus, wet * env, foa * amp)
						},
						metadata: (
							specs: (
								\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2), // 0 in centre of Head (omni-directional -> azimuth n'a pas d'incidence) - pi/2 in front (plane wave)
								// Si Angle -pi/2, l'azimuth à pi est en face et fait le tour dans le sens horaire pour se retrouver en face à -pi
								// Si Angle pi/2, l'azimuth à pi est derrière et fait le tour dans le sens horaire pour se retrouver derrière à -pi
								\azim: ControlSpec(pi, -pi, 'lin', 0.001, pi),
								\dist: ControlSpec(0 /*0.05*/, 1, 'lin', 0.001, 0.3), // distance min incluse dans le synthé
								\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0) // a une incidence sur l'avant / arrière, mais pas beaucoup d'intérêt avec distribution des HP en 2D ???
								// mettre de 0 à pi/2 pour l'élévation au lieu de -pi / pi ???
								// \amp: ControlSpec(0, 1, 'lin', 0.001, 1) // amp automatique selon dist

							),
							specsR: (
								// \angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\azim: ControlSpec(pi, -pi, 'lin', 0.001, pi),
								\dist: ControlSpec(0.06, 1, 'lin', 0.001, 0.3)
								// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
								// \amp: ControlSpec(0, 1, 'lin', 0.001, 1) // amp automatique selon dist
							),
							order: [
								\lag,
								\angle,
								\azim,
								\dist,
								\elev
								// \amp // amp automatique selon dist
							]
						)
						).load;
					);
					~ambATKSynthDefNames[i].postln;
				};

				~fxSynthDef5 = ~fxSynthDef5ALL[0..2]; // [0..2] car juste 3 synthés d'affiché





				~ambATKSynthDefRotNames = [\RotZoom, \RotFocus, \RotPush, \RotPress];

				4.do { |i|
					~fxSynthDef6ALL.add(
						SynthDef(~ambATKSynthDefRotNames[i], { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, angle = 0, azim = 0, dist = 1, rotRate = 0.1, tilRate = 0.1, tumRate = 0.1, elev = 0, distMin = 0.05, lag = 1/*, mix = -1*/;

							var env, src, foa, freq, amp, distance, ang, rotAngle, tilAngle, tumAngle;

							rotAngle = LFNoise2.kr(rotRate, 2pi); // ou mul pi et add pi
							tilAngle = LFNoise2.kr(tilRate, 2pi);
							tumAngle = LFNoise2.kr(tumRate, 2pi);

							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							distance = dist.varlag(lag);
							amp = (1-distance).linlin(0, 1, 0.05, 1.5)/*.poll*/;

							ang = distance.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
							// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
							ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

							// Encode into our foa signal
							foa = ~renderEncode.value(src);

							foa = FoaTransform.ar(foa, 'rtt', rotAngle, tilAngle, tumAngle);
							foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, azim.varlag(lag), elev.varlag(lag));   // image / pan
							freq = 20.0;				// HPF, to control proximity boost
							foa = HPF.ar(foa, freq);		// precondition signal for proximity
							foa = FoaTransform.ar(foa, 'proximity', distance.max(distMin));   // image

							foa = ~renderDecode.value(foa);

							// Out.ar(out_bus, foa * amp);
							// efx = XFade2.ar(src, efx, mix.varlag(lag));
							XOut.ar(in_bus, wet * env, foa * amp)
						},
						metadata: (
							specs: (
								\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
								\rotRate: ControlSpec(0.01, 200, 'exp', 0.01, 0.01),
								\tilRate: ControlSpec(0.01, 200, 'exp', 0.01, 0.01),
								\tumRate: ControlSpec(0.01, 200, 'exp', 0.01, 0.01),
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\azim: ControlSpec(pi, -pi, 'lin', 0.001, pi),
								\dist: ControlSpec(0 /*0.05*/, 1, 'lin', 0.001, 0.3), // distance min incluse dans le synthé
								\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0)
								// \amp: ControlSpec(0, 1, 'lin', 0.001, 1) // amp automatique selon dist

							),
							specsR: (
								\rotRate: ControlSpec(0.01, 16, 'lin', 0.01, 0.01),
								\tilRate: ControlSpec(0.01, 16, 'lin', 0.01, 0.01),
								\tumRate: ControlSpec(0.01, 16, 'lin', 0.01, 0.01),
								// \angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\azim: ControlSpec(pi, -pi, 'lin', 0.001, pi),
								\dist: ControlSpec(0.06, 1, 'lin', 0.001, 0.3)
								// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
								// \amp: ControlSpec(0, 1, 'lin', 0.001, 1) // amp automatique selon dist
							),
							order: [
								\lag,
								\rotRate,
								\tilRate,
								\tumRate,
								\angle,
								\azim,
								\dist,
								\elev
								// \amp // amp automatique selon dist
							]
						)
						).load;
					);
					~ambATKSynthDefRotNames[i].postln;
				};

				~fxSynthDef6 = ~fxSynthDef6ALL[0..2]; // [0..2] car juste 3 synthés d'affiché





				~ambATKSynthDefSDNames = [\SDZoomPol, \SDFocusPol, \SDPushPol, \SDPressPol];

				4.do { |i|
					~fxSynthDef7ALL.add(
						SynthDef(~ambATKSynthDefSDNames[i], { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, angle = 0, ampRev = 1, freqRev = 1, ampMax = 40, freqMax = 6000, elev = 0, distMin = 0.05, lag = 1/*, mix = -1*/;

							var env, src, foa, freq, amp, ang, rotAngle, tilAngle, tumAngle, a, b, c, srcAn;

							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							srcAn = NumChannels.ar(src, 1);

							/*#d, e = Pitch.kr(src);
							#f, g = Tartini.kr(src);
							#h, j = Qitch.kr(src, ~qitchBuffer);*/

							a = FFT(LocalBuf(2048), srcAn);  // a complex signal
							b = Loudness.kr(a).varlag(lag);
							c = SpecCentroid.kr(a).varlag(lag); // the most perceptually prominent frequency range in signal

							b = b.linlin(0, ampMax.varlag(lag), 1, 0 /*distMin*/); // donne la distance (0 pour amp max et 1 pour amp à 0)
							c = c.linlin(20, freqMax.varlag(lag), pi, -pi);

							b = LinSelectX.kr(ampRev.varlag(lag) * 2, [b, 1-b /*+distMin*/]);
							c = LinSelectX.kr(freqRev.varlag(lag) * 2, [c, c.neg]);

							/*k = SpecFlatness.kr(a); // how complicated the signal is (0 for sinusoid / white noise close to 1)
							// SpecPcile
							l = FFTCrest.kr(a /*,1800,2200*/); // calculate the spectral crest of a signal, which indicates how flat (white noise -> low value) or peaky a signal is
							m = SensoryDissonance.kr(a); // how dissonant a signal is (1 totally dissonant / 0 consonant)
							i = Impulse.kr(10);
							SendReply.kr(i, '/loudness', b, replyID: 1); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/pitch', [d, e], replyID: 2); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/tartini', [f, g], replyID: 3); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/qitch', [h, j], replyID: 4); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/specCentroid', c, replyID: 5); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/specFlatnessAndDissonance', [k, m], replyID: 6); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/fftCrest', l, replyID: 7); // ligne à décommenter pour récupérer les valeurs*/

							// c.linlin(20, 6000 , -6, 6) * ambPointScale * panR,
							// b.linlin(0, 40, 1, 0.05) * ambPointScale * panR,
							// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)

							amp = (1-b).linlin(0 /*distMin*/, 1, 0.05, 1.5)/*.poll*/;

							ang = b.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
							// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
							ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

							// Encode into our foa signal
							foa = ~renderEncode.value(src);

							foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, c, elev.varlag(lag));   // image / pan
							freq = 20.0;				// HPF, to control proximity boost
							foa = HPF.ar(foa, freq);		// precondition signal for proximity
							foa = FoaTransform.ar(foa, 'proximity', b.max(distMin));   // image

							foa = ~renderDecode.value(foa);

							// Out.ar(out_bus, foa);
							// efx = XFade2.ar(src, efx, mix.varlag(lag));
							XOut.ar(in_bus, wet * env, foa * amp)
						},
						metadata: (
							specs: (
								\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
								\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000),
								\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0)

							),
							specsR: (
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000),
								\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40)
								// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
							),
							order: [
								\lag,
								\angle,
								\ampRev,
								\freqRev,
								\ampMax,
								\freqMax,
								\elev
							]
						)
						).load;
					);
					~ambATKSynthDefSDNames[i].postln;
				};
				/*
				( // Pour récupérer les valeurs sonores Loudness - Comment obtenir des données arrondies ->.round(0.01) ne marche pas ?????????
				~getSynthDataSound = OSCFunc({ arg msg;
				msg.postln; // print the message to the post window
				}, '/qitch', Server.default.addr); // respond only to message /freq coming from the default Server's address.
				);
				~getSynthDataSound.free;
				400.explin(20, 6000 , -6, 6)
				*/





				~ambATKSynthDefSDNames = [\SDZoomCar, \SDFocusCar, \SDPushCar, \SDPressCar];

				// voire si l'utilisation de Select.kr est plus optimisé que la création d'un point ?????????
				// "http://supercollider.sourceforge.net/wiki/index.php/If_statements_in_a_SynthDef"

				/*
				Polar(2,-1).y
				a = Polar(2,-1).asPoint

				a = Point(-2, -1)
				a * 2
				a.neg
				a.theta
				a.dist(Point(0, 0))
				*/

				4.do { |i|
					~fxSynthDef7ALL.add(
						SynthDef(~ambATKSynthDefSDNames[i], { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, angle = 0, ampRev = 1, freqRev = 1, ampMax = 40, freqMax = 6000, elev = 0, distMin = 0.05, lag = 1/*, mix = -1*/;

							var env, src, foa, freq, amp, distance, ang, rotAngle, tilAngle, tumAngle, a, b, c, srcAn, point, pointAng, pointDist; // var point à supprimer XXX

							env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
							src = In.ar(in_bus, ~numChannelsFX);

							srcAn = NumChannels.ar(src, 1);

							/*#d, e = Pitch.kr(src);
							#f, g = Tartini.kr(src);
							#h, j = Qitch.kr(src, ~qitchBuffer);*/

							a = FFT(LocalBuf(2048), srcAn);  // a complex signal
							b = Loudness.kr(a).varlag(lag);
							c = SpecCentroid.kr(a).varlag(lag); // the most perceptually prominent frequency range in signal

							b = b.linlin(0, ampMax.varlag(lag), -1, 1);
							c = c.linlin(20, freqMax.varlag(lag), -1, 1);

							b = LinSelectX.kr(ampRev.varlag(lag) * 2, [b, b.neg]);
							c = LinSelectX.kr(freqRev.varlag(lag) * 2, [c, c.neg]);

							/*k = SpecFlatness.kr(a); // how complicated the signal is (0 for sinusoid / white noise close to 1)
							// SpecPcile
							l = FFTCrest.kr(a /*,1800,2200*/); // calculate the spectral crest of a signal, which indicates how flat (white noise -> low value) or peaky a signal is
							m = SensoryDissonance.kr(a); // how dissonant a signal is (1 totally dissonant / 0 consonant)
							i = Impulse.kr(10);
							SendReply.kr(i, '/loudness', b, replyID: 1); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/pitch', [d, e], replyID: 2); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/tartini', [f, g], replyID: 3); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/qitch', [h, j], replyID: 4); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/specCentroid', c, replyID: 5); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/specFlatnessAndDissonance', [k, m], replyID: 6); // ligne à décommenter pour récupérer les valeurs
							SendReply.kr(i, '/fftCrest', l, replyID: 7); // ligne à décommenter pour récupérer les valeurs*/

							// c.linlin(20, 6000 , -6, 6) * ambPointScale * panR,
							// b.linlin(0, 40, 1, 0.05) * ambPointScale * panR,
							// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)

							amp = b.linlin(-1, 1, 0.05, 1.5)/*.poll*/;

							ang = b.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
							// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
							ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

							// converting signal azimuth to pi to -pi for ATK -> see pesudoUgen in Quark GameLoop
							// https://github.com/miguel-negrao/Quarks/blob/master/GameLoop/Classes/PseudoUGens/Space.sc
							// point = Point(c, b);
							/*point = Point(c, b).asPolar.rotate(-0.5pi).neg.asPoint;
							pointAng = point.theta;
							pointDist = point.dist(Point(0, 0)).max(distMin);*/

							// voire si version avec Select vs utilisation de Point est préférable en termes d'optimisation pour le server ?????????
							pointAng = atan2(c, b);
							pointAng = Select.kr(pointAng < 0, [ pi - (pointAng % 2pi), -pi + (-1 * pointAng % 2pi) ] );
							/*{ pointAng > 0 } { pointAng = pi - (delta % 2pi) } // Ajout de pi - ou -pi + à la formule de Joseph Andersen
							{ pointAng < 0 } { pointAng = -pi + (-1 * delta % 2pi) };*/
							pointDist = abs(hypot(c, b))/*.clip(/*0*/ distMin, 1)*/;

							// Encode into our foa signal
							foa = ~renderEncode.value(src);

							foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, pointAng, elev.varlag(lag));   // image / pan
							freq = 20.0;				// HPF, to control proximity boost
							foa = HPF.ar(foa, freq);		// precondition signal for proximity
							foa = FoaTransform.ar(foa, 'proximity', pointDist.max(distMin));   // image

							foa = ~renderDecode.value(foa);

							// Out.ar(out_bus, foa);
							// efx = XFade2.ar(src, efx, mix.varlag(lag));
							XOut.ar(in_bus, wet * env, foa * amp)
						},
						metadata: (
							specs: (
								\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
								\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000),
								\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0)

							),
							specsR: (
								\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
								\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
								\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
								\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000)
								// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
							),
							order: [
								\lag,
								\angle,
								\ampRev,
								\freqRev,
								\ampMax,
								\freqMax,
								\elev
							]
						)
						).load;
					);
					~ambATKSynthDefSDNames[i].postln;
				};

				~fxSynthDef7 = ~fxSynthDef7ALL.clump(4)[0]; // clump(4) car 4 synthés d'affiché





				// classic Schroeder all-pass cascade
				// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Ambisonics-Reverb-td7604352.html
				/*
				http://ambisonics.iem.at/symposium2009/proceedings/ambisym09-josephandersonseancostello-ambireverbarch.pdf
				http://valhalladsp.wordpress.com/2009/10/11/a-reverb-paper-of-mine-just-got-published-online/

				The paper has some general guidance as to how to adapt architectures found in the reverb literature to ambisonics, and then we present an example FDN reverberator. The FDN shown is more or less the FDN I've used in my Epiphanie Sequence (http://www.sargasso.com/?product=joseph-anderson-epiphanie-sequence). Tweaking the various parameters gives a variety of results. The Early Reflection cascade of fig. 1 can be useful on its own, as well.
				I haven't built the FDN illustrated in the paper in the current ATK. (One of us should do that at some point!) In the meantime, here's an example all-pass cascade.
				*/

				~ambATKSynthDefSDRevPolNames = [\SDRevZoomPol, \SDRevFocusPol, \SDRevPushPol, \SDRevPressPol];
				~ambATKSynthDefSDRevDelaytimes = [0.0625, 0.25, 1.0, 1.0, 1.0, 1.0];
				~ambATKSynthDefSDRevDecaytimes = [0.0625, 0.25, 0.0625, 0.125, 0.5, 2.0];

				~ambATKSynthDefSDRevDelaytimes.do { |ditem, d| // prend du temps à charger -> vérifier la charge mémoire ?????????
					4.do { |i|
						~fxSynthDef8ALL.add(
							SynthDef(~ambATKSynthDefSDRevPolNames[i]++d.asSymbol, { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, mix = 1, angle = 0, ampRev = 1, freqRev = 1, ampMax = 40, freqMax = 6000, elev = 0, /*delaytime = 1, decaytime = 1,*/ distMin = 0.05, lag = 1 /*, mix = -1*/;

								var env, src, foa, freq, amp, ang, rotAngle, tilAngle, tumAngle, a, b, c, srcAn, foaAP;

								var /*delaytime = 1.0, decaytime = 2.0,*/ apOrder = 6;
								// var delaytime = 1.0, decaytime = 0.5, apOrder = 6;
								// var delaytime = 1.0, decaytime = 0.125, apOrder = 6;
								// var delaytime = 1.0, decaytime = 0.0625, apOrder = 6;
								// var delaytime = 0.25, decaytime = 0.25, apOrder = 6;
								// var delaytime = 0.0625, decaytime = 0.0625, apOrder = 6;
								var orient = ['flu', 'fld', 'flr', 'fud', 'fbd', 'fbu', 'flru', 'flrd'];

								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);

								srcAn = NumChannels.ar(src, 1);

								/*#d, e = Pitch.kr(src);
								#f, g = Tartini.kr(src);
								#h, j = Qitch.kr(src, ~qitchBuffer);*/

								a = FFT(LocalBuf(2048), srcAn);  // a complex signal
								b = Loudness.kr(a).varlag(lag);
								c = SpecCentroid.kr(a).varlag(lag); // the most perceptually prominent frequency range in signal

								b = b.linlin(0, ampMax.varlag(lag), 1, 0 /*distMin*/); // donne la distance (0 pour amp max et 1 pour amp à 0)
								c = c.linlin(20, freqMax.varlag(lag), pi, -pi);

								b = LinSelectX.kr(ampRev.varlag(lag) * 2, [b, 1-b /*+distMin*/])/*.poll*/;
								c = LinSelectX.kr(freqRev.varlag(lag) * 2, [c, c.neg]);

								/*k = SpecFlatness.kr(a); // how complicated the signal is (0 for sinusoid / white noise close to 1)
								// SpecPcile
								l = FFTCrest.kr(a /*,1800,2200*/); // calculate the spectral crest of a signal, which indicates how flat (white noise -> low value) or peaky a signal is
								m = SensoryDissonance.kr(a); // how dissonant a signal is (1 totally dissonant / 0 consonant)
								i = Impulse.kr(10);
								SendReply.kr(i, '/loudness', b, replyID: 1); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/pitch', [d, e], replyID: 2); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/tartini', [f, g], replyID: 3); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/qitch', [h, j], replyID: 4); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/specCentroid', c, replyID: 5); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/specFlatnessAndDissonance', [k, m], replyID: 6); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/fftCrest', l, replyID: 7); // ligne à décommenter pour récupérer les valeurs*/

								// c.linlin(20, 6000 , -6, 6) * ambPointScale * panR,
								// b.linlin(0, 40, 1, 0.05) * ambPointScale * panR,
								// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)

								amp = (1-b).linlin(0 /*distMin*/, 1, 0.05, 1.5).varlag(lag)/*.poll*/;

								ang = b.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
								// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
								ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

								// Encode into our foa signal
								foa = ~renderEncode.value(src);

								// cascade allpass filters
								/*foaAP = src;
								foaAP = apOrder.do({arg i;
								// var orientation = orient.at(7.rand);
								AllpassL.ar(
								foaAP,
								delaytime,
								Array.fill(~numChannelsFX, delaytime).rand,
								decaytime
								)
								});
								foa = ((sqrt(mix) * src) + (sqrt(1-mix) * foaAP));*/

								// cascade allpass filters
								foaAP = foa;
								apOrder.do({arg i;
									var orientation = orient.at(7.rand);
									foaAP = FoaEncode.ar(
										AllpassL.ar(
											FoaDecode.ar(foaAP, FoaDecoderMatrix.newBtoA(orientation)),
											~ambATKSynthDefSDRevDelaytimes[d],
											Array.fill(4, ~ambATKSynthDefSDRevDelaytimes[d]).rand,
											~ambATKSynthDefSDRevDecaytimes[d]
										),
										FoaEncoderMatrix.newAtoB(orientation)
									)
								});
								foa = ((sqrt(mix) * foaAP) + (sqrt(1-mix) * foa))/*.varlag(lag)*/; // Pas de son si varlag ?????????

								foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, c, elev.varlag(lag));   // image / pan
								freq = 20.0;				// HPF, to control proximity boost
								foa = HPF.ar(foa, freq);		// precondition signal for proximity
								foa = FoaTransform.ar(foa, 'proximity', b.max(distMin));   // image

								foa = ~renderDecode.value(foa);

								// Out.ar(out_bus, foa);
								// efx = XFade2.ar(src, efx, mix.varlag(lag));
								XOut.ar(in_bus, wet * env, foa * amp)
							},
							metadata: (
								specs: (
									\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
									\mix: ControlSpec(0, 1, 'lin', 0.01, 0.7),
									/*\delaytime: ControlSpec(0.01, 2, 'lin', 0.0001, 0.0625),
									\decaytime: ControlSpec(0.01, 2, 'lin', 0.0001, 0.0625),*/
									\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
									\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
									\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000),
									\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0)
								),
								specsR: (
									\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
									\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
									\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000)
									// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
								),
								order: [
									\lag,
									\mix,
									/*\delaytime,
									\decaytime,*/
									\angle,
									\ampRev,
									\freqRev,
									\ampMax,
									\freqMax,
									\elev
								]
							)
							).load;
						);
						(~ambATKSynthDefSDRevPolNames[i]++d.asSymbol).postln;
					}
				};





				~ambATKSynthDefSDRevCarNames = [\SDRevZoomCar, \SDRevFocusCar, \SDRevPushCar, \SDRevPressCar];

				~ambATKSynthDefSDRevDelaytimes.do { |ditem, d| // prend du temps à charger -> vérifier la charge mémoire ?????????
					4.do { |i|
						~fxSynthDef8ALL.add(
							SynthDef(~ambATKSynthDefSDRevCarNames[i]++d.asSymbol, { arg in_bus = 0, /*out_bus = 0,*/ gate = 1, wet = 1, fadeTime = 1, mix = 1, angle = 0, ampRev = 1, freqRev = 1, ampMax = 40, freqMax = 6000, elev = 0,/*delaytime = 1, decaytime = 1,*/ distMin = 0.05, lag = 1 /*, mix = -1*/;

								var env, src, foa, freq, amp, ang, rotAngle, tilAngle, tumAngle, a, b, c, srcAn, point, pointAng, pointDist, foaAP; // var point à supprimer XXX

								var /*delaytime = 1.0, decaytime = 2.0,*/ apOrder = 6;
								var orient = ['flu', 'fld', 'flr', 'fud', 'fbd', 'fbu', 'flru', 'flrd'];

								env = Linen.kr(gate, fadeTime, 1, fadeTime, 2);
								src = In.ar(in_bus, ~numChannelsFX);

								srcAn = NumChannels.ar(src, 1);

								/*#d, e = Pitch.kr(src);
								#f, g = Tartini.kr(src);
								#h, j = Qitch.kr(src, ~qitchBuffer);*/

								a = FFT(LocalBuf(2048), srcAn);  // a complex signal
								b = Loudness.kr(a).varlag(lag);
								c = SpecCentroid.kr(a).varlag(lag); // the most perceptually prominent frequency range in signal

								b = b.linlin(0, ampMax.varlag(lag), -1, 1);
								c = c.linlin(20, freqMax.varlag(lag), -1, 1);

								b = LinSelectX.kr(ampRev.varlag(lag) * 2, [b, b.neg]);
								c = LinSelectX.kr(freqRev.varlag(lag) * 2, [c, c.neg]);

								/*k = SpecFlatness.kr(a); // how complicated the signal is (0 for sinusoid / white noise close to 1)
								// SpecPcile
								l = FFTCrest.kr(a /*,1800,2200*/); // calculate the spectral crest of a signal, which indicates how flat (white noise -> low value) or peaky a signal is
								m = SensoryDissonance.kr(a); // how dissonant a signal is (1 totally dissonant / 0 consonant)
								i = Impulse.kr(10);
								SendReply.kr(i, '/loudness', b, replyID: 1); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/pitch', [d, e], replyID: 2); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/tartini', [f, g], replyID: 3); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/qitch', [h, j], replyID: 4); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/specCentroid', c, replyID: 5); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/specFlatnessAndDissonance', [k, m], replyID: 6); // ligne à décommenter pour récupérer les valeurs
								SendReply.kr(i, '/fftCrest', l, replyID: 7); // ligne à décommenter pour récupérer les valeurs*/

								// c.linlin(20, 6000 , -6, 6) * ambPointScale * panR,
								// b.linlin(0, 40, 1, 0.05) * ambPointScale * panR,
								// de gauche à droite -> du + grave au plus aigu (20/6K) & devant vers l'arrière -> du plus fort au plus faible (0/40 sones)

								amp = b.linlin(-1, 1, 0.05, 1.5)/*.poll*/;

								ang = b.lincurve(0, 1, 0, -pi/2 /*1.57*/, -6)/*.poll*/;
								// si l'argument slider angle est supérieur -pi/2, on reprend le contrôle sur l'angle, sinon l'angle est calculé selon la distance
								ang = Select.kr( angle > -1.57, [ ang, angle ] ).varlag(lag);

								// converting signal azimuth to pi to -pi for ATK -> see pesudoUgen in Quark GameLoop
								// https://github.com/miguel-negrao/Quarks/blob/master/GameLoop/Classes/PseudoUGens/Space.sc
								// point = Point(c, b);
								/*point = Point(c, b).asPolar.rotate(-0.5pi).neg.asPoint;
								pointAng = point.theta;
								pointDist = point.dist(Point(0, 0)).max(distMin);*/

								// voire si version avec Select vs utilisation de Point est préférable en termes d'optimisation pour le server ?????????
								pointAng = atan2(c, b);
								pointAng = Select.kr(pointAng < 0, [ pi - (pointAng % 2pi), -pi + (-1 * pointAng % 2pi) ] );
								/*{ pointAng > 0 } { pointAng = pi - (delta % 2pi) } // Ajout de pi - ou -pi + à la formule de Joseph Andersen
								{ pointAng < 0 } { pointAng = -pi + (-1 * delta % 2pi) };*/
								pointDist = abs(hypot(c, b))/*.clip(/*0*/ distMin, 1)*/;

								// Encode into our foa signal
								foa = ~renderEncode.value(src);

								// cascade allpass filters
								foaAP = foa;
								apOrder.do({arg i;
									var orientation = orient.at(7.rand);
									foaAP = FoaEncode.ar(
										AllpassL.ar(
											FoaDecode.ar(foaAP, FoaDecoderMatrix.newBtoA(orientation)),
											~ambATKSynthDefSDRevDelaytimes[d],
											Array.fill(4, ~ambATKSynthDefSDRevDelaytimes[d]).rand,
											~ambATKSynthDefSDRevDecaytimes[d]
										),
										FoaEncoderMatrix.newAtoB(orientation)
									)
								});
								foa = ((sqrt(mix) * foaAP) + (sqrt(1-mix) * foa))/*.varlag(lag)*/; // Pas de son si varlag ?????????

								foa = FoaTransform.ar(foa, ~ambATKTransformerNames[i], ang/*le*/, pointAng, elev.varlag(lag));   // image / pan
								freq = 20.0;				// HPF, to control proximity boost
								foa = HPF.ar(foa, freq);		// precondition signal for proximity
								foa = FoaTransform.ar(foa, 'proximity', pointDist.max(distMin));   // image

								foa = ~renderDecode.value(foa);

								// Out.ar(out_bus, foa);
								// efx = XFade2.ar(src, efx, mix.varlag(lag));
								XOut.ar(in_bus, wet * env, foa * amp)
							},
							metadata: (
								specs: (
									\mix: ControlSpec(0, 1, 'lin', 0.01, 0.7),
									\lag: ControlSpec(0.01, 5, 'lin', 0.01, 0.7),
									/*\delaytime: ControlSpec(0.01, 2, 'lin', 0.0001, 0.0625),
									\decaytime: ControlSpec(0.01, 2, 'lin', 0.0001, 0.0625),*/
									\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
									\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
									\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000),
									\elev: ControlSpec(0, pi/2, 'lin', 0.001, 0)
								),
								specsR: (
									\angle: ControlSpec(0, -pi/2, 'lin', 0.001, -pi/2),
									\ampRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\freqRev: ControlSpec(0, 1, 'lin', 0.01, 0),
									\ampMax: ControlSpec(20, 60, 'lin', 0.1, 40),
									\freqMax: ControlSpec(1000, 10000, 'exp', 1, 6000)
									// \elev: ControlSpec(-pi, pi, 'lin', 0.001, 0)
								),
								order: [
									\mix,
									\lag,
									/*\delaytime,
									\decaytime,*/
									\angle,
									\ampRev,
									\freqRev,
									\ampMax,
									\freqMax,
									\elev
								]
							)
							).load;
						);
						(~ambATKSynthDefSDRevCarNames[i]++d.asSymbol).postln;
					}
				};

				~fxSynthDef8 = ~fxSynthDef8ALL.clump(3).clump(~ambATKSynthDefSDRevDelaytimes.size)[0][0]; // Sélection de la réverb la plus courte par défaut
				// clump(3) car juste 3 synthés d'affiché
				// ~fxSynthDef8ALL.cs;
				// ~fxSynthDef8[0].class





				~numFxSynthDef5 = 3 /*~fxSynthDef5.size*/; // Synthés ambisoniques ATK - changement du nb de synthés car possibilités des paramètres différents pour chacune des instances
				~numFxSynthDef6 = 3 /*~fxSynthDef6.size*/; // Synthés ambisoniques ATK - changement du nb de synthés car possibilités des paramètres différents pour chacune des instances
				~numFxSynthDef7 = 4 /*~fxSynthDef7.size*/; // Synthés ambisoniques ATK - changement du nb de synthés car possibilités des paramètres différents pour chacune des instances
				~numFxSynthDef8 = 3 /*~fxSynthDef8.size*/; // Synthés ambisoniques ATK - changement du nb de synthés car possibilités des paramètres différents pour chacune des instances

				~numFxSynthDef6Cum = ~numFxSynthDef5 + ~numFxSynthDef6;
				~numFxSynthDef7Cum = ~numFxSynthDef6Cum +~numFxSynthDef7;

				~fxSynthDefA = ~fxSynthDef5 ++ ~fxSynthDef6 ++ ~fxSynthDef7 ++ ~fxSynthDef8;
				~numFxSynthDefA = ~fxSynthDefA.size;


			); // pour resélectionner que les synthés d'effets + effets ambisoniques


		); // pour resélectionner tous les synthés




















		( // Load Mono & Stereo Buffers
			// check Buffer.readAndQuery in ddw_music & readDir in wslib quark



			/*~arrayOfFolderPaths = PathName.new(~soundsFolder).folders; // OLD
			// ~arrayOfFolderPaths[0].folderName

			( // Création d'un dico pour les sous-dossiers inclus dans le dossier Sounds - Dictionary
			~soundsFolderDict = ~soundsFolderDict ? (); // évite d'écraser un dico déjà existant

			~arrayOfFolderPaths.collect { |item, i|
			// ~soundsFolderDict.put(~arrayOfFolderPaths[i].folderName.asSymbol, ~arrayOfFolderPaths[i]); // pb si dossier alias - mais ok si lien symbolique du dossier
			~soundsFolderDict.put(~arrayOfFolderPaths[i].files[0].folderName.asSymbol, ~arrayOfFolderPaths[i]); // pour chargement des dossiers alias & a ok si lien symbolique du dossier / Mais problème si le nom du dossier original a été modifié car ne prend en compte que le nom du dossier en lien
			// -> nécessaire d'utiliser des méthodes unix pour identifier le nom des dossiers même des alias dont le nom a été changé
			};*/



			// Utilisation des méthodes unix pour identifier le nom des dossiers même des alias dont le nom a été changé
			// Tous les éléments, même les fichiers seront affichés - pas de filtrage effectué sur les dossiers - A faire XXXXXX
			// ~arrayOfFolderNamesRaw = ("ls -m" + "\""  + ~soundsFolder + "\"" ).unixCmdGetStdOut;
			~arrayOfFolderNamesRaw = ("ls -m" + ~soundsFolder).unixCmdGetStdOut;
			// http://linux.about.com/od/commands/l/blcmdl1_ls.htm
			// -m -> fill width with a comma separated list of entries

			// stripWhiteSpace -> Strips whitespace at the beginning and end of the string
			~arrayOfFolderNamesWS = ~arrayOfFolderNamesRaw.split($, ).collect { |i| i.stripWhiteSpace };
			// Supression des espaces au début et à la fin et des strings Alias dans le nom des dossiers
			~arrayOfFolderNames = ~arrayOfFolderNamesWS.collect { |i| i.replace(" alias","")};

			// Pour prendre en compte les noms de dossiers alias
			// Si un nom de dossier alias a le même nom qu'un autre dossier, le nom de dossier alias est pris en compte
			~arrayOfFolderPaths = ~arrayOfFolderNames.collect { |item, i| PathName(~soundsFolder /*++ "/"*/ ++ ~arrayOfFolderNamesWS[i]) };
			// Retrait du ++ "/" car génère 2 x // quand pas de dossier alias - mais peut être nécessaire pour les dossiers alias ?????????

			// ~foldersSize = ~arrayOfFolderNames.collect {|i| ~soundm[i.asSymbol].size }; // Pour protection quand preset enregistré avec une taille de fichier différente



			( // Création d'un dico pour les sous-dossiers inclus dans le dossier Sounds - Dictionary
				// ~soundsFolderDict = ~soundsFolderDict ? (); // évite d'écraser un dico déjà existant
				~soundsFolderDict = IdentityDictionary.new; // Changement de ~soundm de Event en IdentityDictionary
				~arrayOfFolderPaths.collect { |item, i|
					~soundsFolderDict.put(~arrayOfFolderNames[i].asSymbol, ~arrayOfFolderPaths[i]);
				};

				/*
				{~arrayOfFolderNames}.bench
				{~arrayOfFolderNames[0]}.bench
				{~arrayOfFolderPaths[0].files[0].folderName.asSymbol}.bench
				*/



				// Chargement d'un dossier de sons en dehors du dossier principal de sons
				// ~soundsFolderDict.put('ins', "/Users/Xon/Documents/Projets/ConsProject2_Logorrhee2010/Z_Suite_Declaration_de_guerre/InsultesEricIndi/");

				// ~soundsFolderDict.put('InsOMax', "/Users/Xon/Documents/Projets/ConsProject2_Logorrhee2010/Z_Suite_Declaration_de_guerre/InsultesEricDecOM_SP500Dec2PapeFinFB.aif");
				// ~soundsFolderDict.put('Baka', "/Users/Xon/Documents/Projets/ConsProject1_Baka2009/ToBakaConcert.aif");
				// ~soundsFolderDict.put('Logo', "/Users/Xon/Documents/Projets/ConsProject2_Logorrhee2010/1erePartie/ConcertXon/Logotomie Stereo.aif");

				/*
				Post << ~soundsFolderDict; // Event Dictionary containing a key and a path to each subfolder
				~soundsFolderDict.size;
				~soundsFolderDict.keys; // clés du dico
				*/
				~soundsFolderDict.associationsDo { |assoc| postln("the association: " ++ assoc) };

			);



			// Création de la collection des fichiers sons stéréos ne marchant pas lorsque trop de fichier sons car on perd les infos données du buffer
			// mais OK avec staggering mais très long ???
			// ~sounds = ~soundsFolderDict.collect { |dir| (dir +/+ "*").pathMatch.collect { |path| Buffer.read(s, path) } }; XXX

			// Création de la collection des fichiers sons monos
			// ~soundm = ~soundsFolderDict.collect { |dir| (dir +/+ "*").pathMatch.collect { |path| 2.collect { |i| Buffer.readChannel(s, path, channels: [i]) } } };

			// Que signifie dir +/+ "*") ???
			// +/+ (path) in String Helpfile
			// Path concatenation operator - useful for avoiding doubling-up slashes unnecessarily. "foo"+/+"bar" returns "foo/bar"

			/*
			PathName("/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds2013/0 Armagedon/")
			PathName("/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds2013/0 Armagedon/" +/+ "*")
			PathName("/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds2013/0 Armagedon/").pathMatch
			PathName("/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds2013/0 Armagedon/" +/+ "*").pathMatch
			PathName("/Users/Xon/Documents/Projets/ConsProject3_BeatCut2011/WithMathis/Sounds2013/0 Armagedon/").files
			*/





			/*
			HJH : Probably there is too much OSC traffic. When you read a buffer, the server loads the sound file, and then it sends a message back to the language saying "this buffer has x number of frames, y sample rate etc." I'm quite sure what's happening is that some of these messages are getting lost in transmission. UDP is known to be unreliable for high traffic.
			I would stagger the buffer loading -- use 'fork' around the buffer loading code, and insert a short 'wait' every 50 or so file paths.

			// chargement de buffers monos
			fork {
			var i = 0;
			~soundm = d.collect { |dir|
			(dir +/+ "*").pathMatch.collect { |path|
			i = i + 1;
			if(i == 1) { i = 0; 0.01.wait };
			2.collect { |i| Buffer.readChannel(s, path, channels: [i]) };
			}
			};
			("Sounds mono collected").postln; // Pourquoi besoin de parenthèses ???
			};

			Something like that; haven't tested. (In my library, I have a Buffer.readAndQuery method, which puts all of the read requests into a queue and executes them one at a time. It takes longer for a large number of files but it never chokes on too many concurrent requests. Unfortunately it doesn't support readChannel as yet... I could do that in another week or two.)
			Or you could try TCP, though that might get a little dicey when the server quits. (Note that you can't use waitForBoot here -- you have to connect the TCP socket before the language knows that the server is booted! So the waitForBoot function never executes.)
			s.options.protocol = \tcp;
			s.boot;
			// wait for server to start, then
			s.addr.connect({ "lost tcp connection to server".warn });
			*/

			// Chargement des buffers mono et stéreos dans un buffer stéréo
			// Staggering de 0.1s nécessaire ou variable selon la longueur des fichiers sons pour chargement de + de 1K fichiers sons mais très long ? -> utiliser s.sync
			// Protocole TCP à tester XXX





			// you could try to load files in chunks.
			// here's one way to do it - basically rolling your own collectIntoBuffers with added .sync at regular intervals.

			/*Routine.run{
			var bufferArray= List.new, firstBuffer;
			SoundFile.collect("an absolute path*").do{|sf, i|
			bufferArray.add(Buffer(s, sf.numFrames, sf.numChannels).allocRead(sf.path).sampleRate_(sf.sampleRate));
			if(i%10==9, {  //adjust - here every 10th file
			"breathing".postln;
			s.sync;
			//can even add tiny .wait here but only if desperately needed
			});
			};
			s.sync;
			"peuh!".postln;
			firstBuffer = bufferArray.first.postln;
			}*/






			if (currentEnvironment[server] == ~server1, {~soundm = 0 ! 2} ); // Chargement des Buffers (VBAP) sur les 2 serveurs

			// Chargement fichiers monos doublés (& doublement des fichiers monos si nécessaire) sans découpage avec méthode Buffer.readAndQueryChannel
			// Au cas ou pb de chargement, voire Server.queryAllBuffers (timeout: 1.2, wait: 0.001, action) from DewdropLib
			// a chargement des dossiers & fichiers alias

			fork {

				var sf /*, soundM, soundS = 0 !2*/;

				4.wait; currentEnvironment[server].sync;

				~soundm[serverNb] = ~soundsFolderDict.collect { |dir|

					/*0.5.wait;*/ currentEnvironment[server].sync; // à la place du 0.2.wait;

					// 0.5.wait; // Blocage pratiquement systématique et parfois affichage d'erreur comme (voire fichier Erreur Loading Buffers):
					// ^^ The preceding error dump is for ERROR: Message 'at' not understood.
					// RECEIVER: Frame (0x12f5534b8) of Meta_Post:putAll

					dir.files/*.sort*/.collect { |path, ind|

						var pathn = path.fullPath;
						sf = SoundFile.new; sf.openRead(pathn);

						case
						{ sf.duration > 20 } {0.2.wait}
						{ sf.duration > 30 } {1.wait};
						/*case
						// { sf.duration > 60 } {0.5.wait}
						{ sf.duration > (60*3) } {3.0.wait}
						{ sf.duration > (60*5) } {5.0.wait}
						{ sf.duration > (60*8) } {8.0.wait}
						{ sf.duration > (60*12) } {12.0.wait};
						// { sf.duration > (60*20) } {60.0.wait};
						// if (sf.duration > (60*3), {3.0.wait} ); // OK si attente de l'affichage de l'index time*/

						if (ind % 10 == 9, {  // adjust - here every 10th file
							// "breathing".postln;
							0.001.wait; currentEnvironment[server].sync;
							// can even add tiny .wait here but only if desperately needed
						});

						if (sf.numChannels == 2, {
							sf.close; 2.collect { |i| Buffer.readFAndQueryChannel(currentEnvironment[server], pathn, channel: [i]/*, timeout: 6*/); }
						},{ // Erreur si on met un sf.close; avant ???
							sf.close; [Buffer.readFAndQueryChannel(currentEnvironment[server], pathn, channel: [0]/*, timeout: 6*/)];
						});

						// Buffer.readAndQuery(s, path);
						// Buffer.readFAndQueryChannel(s, path, channel: [0]);
					};
				};
				// "Sounds mono & stereo (1 or 2 mono) collected".postln; // ne s'affiche qu'en cours de processus et ne s'affiche pas à la fin comme voulu...
			};





			~addBufferFolder = { | folderN, pathN, server |
				fork { var sf;
					~soundm[server].put(folderN,

						pathN.files.collect { |path, ind|

							var pathn = path.fullPath;
							sf = SoundFile.new; sf.openRead(pathn);

							if (ind % 10 == 9, {  // adjust - here every 10th file
								// "breathing".postln;
								currentEnvironment[server].sync;
								// can even add tiny .wait here but only if desperately needed
							});
							// if (sf.duration > (60*3), {3.0.wait} ); // OK si attente de l'affichage de l'index time

							if (sf.numChannels == 2, {
								sf.close; 2.collect { |i| Buffer.readFAndQueryChannel(currentEnvironment[server], pathn, channel: [i]); }
							},{
								[Buffer.readFAndQueryChannel(currentEnvironment[server], pathn, channel: [0])];
							});
						}
					)
				}
			};





			// ~insultes = Buffer.read(s,"/Users/Xon/Documents/Projets/ConsProjectLogorrhee2010/Z_Suite_Declaration_de_guerre/InsultesEricALLDec.aif");
			// ~moi = Buffer.read(s,"/Users/Xon/Documents/Projets/ConsProjectLogorrhee2010/1erePartie/ASLogorrhee/Sounds/MoiVoix/Catart/CatartMoi2.aif");
			// ~logo = Buffer.read(s,"/Users/Xon/Documents/Projets/ConsProjectLogorrhee2010/1erePartie/CommentaireEric/EnregistrementFinalEric.aif");

			// ~bufOnkolo1 = Buffer.read(s, "/Users/Xon/Documents/Projets/ConsProject2_Logorrhee2010/Z_Suite_Declaration_de_guerre/AS_Onkolo/Sounds/Onkolo-IntoEternity1.wav"); // sons de 53''
			// ~bufOnkolo2 = Buffer.read(s, "/Users/Xon/Documents/Projets/ConsProject2_Logorrhee2010/Z_Suite_Declaration_de_guerre/AS_Onkolo/Sounds/Onkolo-IntoEternity2.wav"); // sons de 44''
		);


		// }.bench; / à décommenter pour mesurer la rapidité d'affichage de la GUI et réorganistion des sons

		// }

	})

	// })

};










/*
// Server & Supernova // then simply put independent synths into a ParGroup
Server.program
Server.supernova // ReplaceOut craps with parallelized groups
Server.default

// Create a new Server on the local machine using o for its options
t = Server(\Local2, NetAddr("127.0.0.1", 57111), o);
t.makeWindow;
t.boot;
t.quit;
*/

~loadPhrases = { | server, name, port |

	currentEnvironment[server] = Server(name, NetAddr("127.0.0.1", port));

	// Config multicanale pour version stéréo si besoin des pistes séparées dans un séquenceur
	~numChannels = ~numChannelsConfig.split($-)[0].asInteger;

	// ~serverOptions.numOutputBusChannels = ~numChannels;
	// ~serverOptions.numOutputBusChannels = 5
	// ~serverOptions.numInputBusChannels;
	// currentEnvironment[\LocalP].numOutputBusChannels;

	// Redéfinir le nombre de canaux nécessaires pour le serveur des phrases
	currentEnvironment[server].options.numOutputBusChannels = ~numChannels;

	case

	{~numChannelsConfig ==  "16-Dome-8-6-2-Clock-CC" or: {~numChannelsConfig ==  "16-Dome-8-6-2-Clock"}}
	{currentEnvironment[server].options.numOutputBusChannels = 16;} // Pour les voix en 16 et 17 ???, MAIS Subs de 16 à 18 ou 20

	{~numChannelsConfig == "22-8+Dome-8-4-2-Pair"}
	{currentEnvironment[server].options.numOutputBusChannels = 36;} // 22 HP, mais aussi Subs en 33 / 34 / 35 / 36

	{~numChannelsConfig ==  "32-Dome-12-10-8-2-Motu" or: { ~numChannelsConfig == "32-Dome-12-10-8-2" } }
	{currentEnvironment[server].options.numOutputBusChannels = 34;}; // 32 HP, mais aussi Subs en 33 / 34

	// vraiment nécessaire puisque lancé à l'initialisation ???
	// SynthDef.synthDefDir = "/Users/xon/Library/Application Support/SuperCollider/synthdefs/";
	~synthDefsDefaultFolder = Platform.userAppSupportDir ++ "/synthdefs";
	SynthDef.synthDefDir = ~synthDefsDefaultFolder;
	"SC_SYNTHDEF_PATH".setenv(~synthDefsDefaultFolder.standardizePath);
	// SynthDescLib.global.addServer(currentEnvironment[server]);

	currentEnvironment[server].waitForBoot(limit: 1000, onComplete:{
		~serverPWindow = currentEnvironment[server].makeWindow; ~serverPWindow.window.bounds_(Rect.new(0,0,305,100)).alwaysOnTop_(true);
	})

};










// Instantiation des synthés principaux Qui posent SEULEMENT PROBLEME (ConcatBufSig & A_SoundData) avec arguments des buffers de trajectoires et enveloppes spéciales -> OK
/*
~initMainSynthDefs = {
(
~trajectoryBuffersX = Env( { 10.0.rand2 }!15, 0.5!14 );
~trajectoryBuffersY = Env( { 10.0.rand2 }!15, 0.5!14 );
~testWindow = Window.new; ~testWindow.front;
~trajectoryBuffersA = WFSPathGUI.new(~testWindow);
~trajectoryBuffersA.object = WFSPath2( [ ~trajectoryBuffersX.levels, ~trajectoryBuffersY.levels ].flop.collect(_.asPoint), ~trajectoryBuffersX.times );
~trajectoryBuffersTest = ~trajectoryBuffersA.object.asBuffer(s);
~testWindow.close;
{ ~testBuf = Buffer.read(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff"); 0.5.wait;
~synthDefInitialisation = Synth(\ConcatBufSig_SpecVar_ASD_CenLoud, [\bufm, ~testBuf, \bufSpec, ~bufEnv[2], \trajBuf, ~trajectoryBuffersTest ]); ~synthDefInitialisation.postln;
~synthDefInitialisation2 = Synth(\ConcatBufSig_SpecVar_StereoFSpec, [\bufm, ~testBuf, \bufSpec, ~bufEnv[2], \trajBuf, ~trajectoryBuffersTest ]); ~synthDefInitialisation2.postln;
0.5.wait; ~synthDefInitialisation.free; ~synthDefInitialisation2.free; 0.5.wait; ~trajectoryBuffersTest.free; ~testBuf.free; }.fork/*(TempoClock.new(queueSize: 2048))*/ ; /*"Main Synths initialized";*/ // since scheduler queue is full
)
};
*/

// Instantiation de tous les synthés principaux - nécessaire quand purge
// FAILURE IN SERVER /n_free Node 1040 not found - avec HatOto -> OK quand durenv de 30, mais erreur si 10 ???
~initBuffersSynths = { |server, serverNb|

	{

		// Repère les buffers dont l'info n'est pas chargée et les update (surtout utile lors du (re)-démarrage de l'ordi) - Augmente la mémoire du sclang de 20/40 Mo ??? // dans fichier _Init Buffers & Synths
		currentEnvironment[server].cachedBuffersDo({ |i| if (i.asString.split($,)[1] == " -1", {" ".postln; "Not Updated Buffer ->".postln; i.postln; " ".postln; i.updateInfo({ |i| (i.asString ++ " -> updated").postln}); }); });
		// 0.1.wait;
		currentEnvironment[server].sync;

		{
				~trajectoryBuffersX = Env( { 10.0.rand2 }!2, 0.5!1 );
				~trajectoryBuffersY = Env( { 10.0.rand2 }!2, 0.5!1 );
				~testWindow = Window.new; ~testWindow.front;
				~trajectoryBuffersA = WFSPathGUI.new(~testWindow);
				~trajectoryBuffersA.object = WFSPath2( [ ~trajectoryBuffersX.levels, ~trajectoryBuffersY.levels ].flop.collect(_.asPoint), ~trajectoryBuffersX.times );
				~trajectoryBuffersTest = ~trajectoryBuffersA.object.asBuffer(currentEnvironment[server]);
				~testWindow.close;

			}.defer; 0.1.wait;

		(

			~testBufS1 = Buffer.read(currentEnvironment[server], Platform.resourceDir +/+ "sounds/a11wlk01.wav"); /*Buffer.readChannel(s, Platform.resourceDir +/+ "sounds/SinedPink.aiff", channels: [0]);*/
			~testBufS2 = Buffer.read(currentEnvironment[server], Platform.resourceDir +/+ "sounds/a11wlk01.wav");
			/*~testBufM= Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");*/
			// ~testBufM.numChannels

			currentEnvironment[server].sync;

			/*
			~synthDefInitialisation = Synth(\ConcatBufSig_SpecVar_ASD_CenLoud, [\bufm, ~testBuf, \bufSpec, ~bufEnv[2], \trajBuf, ~trajectoryBuffersTest ]); ~synthDefInitialisation.postln;
			~synthDefInitialisation2 = Synth(\ConcatBufSig_SpecVar_StereoFSpec, [\bufm, ~testBuf, \bufSpec, ~bufEnv[2], \trajBuf, ~trajectoryBuffersTest ]); ~synthDefInitialisation2.postln;
			*/
			~synthDefInitialisation2 = Synth(\ConcatBufSig_SpecVar_StereoFSpec, [\bufm, ~testBufS1, \bufSpec, ~bufEnv[serverNb][2], \durenv, 10 ], currentEnvironment[server]); ~synthDefInitialisation2.postln; // Pour la spatialisation spectrale ?
			~synthDefInitialisation3 = Synth(\BufS_SpecVar_A, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \bufSpec, ~bufEnv[serverNb][2], \durenv, 10, \trajBuf, ~trajectoryBuffersTest, \trajBufLoop, 1 ], currentEnvironment[server]); ~synthDefInitialisation3.postln; // Pour la spatialisation Ambi avec trajectoire ?
			~synthDefInitialisation4 = Synth(\BufS_SpecVar_StereoFInt, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \durenv, 10, \bufSpec, ~bufEnv[serverNb][2] ], currentEnvironment[server]); ~synthDefInitialisation4.postln; // Pour Buf stéréo & stereo Fixe
			~synthDefInitialisation5 = Synth(\BufS_SpecVar_VB_SD_CenLoud, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \durenv, 10, \bufSpec, ~bufEnv[serverNb][2] ], currentEnvironment[server]); ~synthDefInitialisation5.postln; // Pour Buf stéréo & VBAP SD
			~synthDefInitialisation6 = Synth(\BufS_SpecVar_VBDist_SD_CenLoud, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \durenv, 10, \bufSpec, ~bufEnv[serverNb][2] ], currentEnvironment[server]); ~synthDefInitialisation6.postln; // Pour Buf stéréo & VBAP Distance SD
			~synthDefInitialisation7 = Synth(\BufS_SpecVar_VBDist, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \durenv, 10, \bufSpec, ~bufEnv[serverNb][2], \trajBuf, ~trajectoryBuffersTest, \trajBufLoop, 1 ], currentEnvironment[server]); ~synthDefInitialisation7.postln; // Pour Buf stéréo & VBAP Distance Traj
			// 0.5.wait;
			~synthDefInitialisation = 0 ! ~allSynths.size;
			~allSynths.do { |item, i| var synthName = (item ++ "SpecVar_ASD_CenLoud").asSymbol;  // synthName.postln
				~synthDefInitialisation[i] = Synth(synthName, [\bufm, ~testBufS1, \bufm2, ~testBufS2, \bufSpec, ~bufEnv[serverNb][2], \rate, 1, \durenv, 30, \loop, 1 ], currentEnvironment[server]); ~synthDefInitialisation[i].postln;
				0.001.wait; // 0.02 avant
				// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				// certains presets provoquent des explosions du server la 1ère fois, Comment les éviter ??????
				// DR RandBuf Enerve2 car BUF stéréo ??????
				// SG GongGrain OK si la synthèse préalable est de 0.5 minimum
				// TN AmbCombDist1 avec plein d'effets ??????
				// ~synthDefInitialisation[i].free;
			};

			1.wait;
			~allSynths.do { |item, i| ~synthDefInitialisation[i].free; };
			~synthDefInitialisation2.free; ~synthDefInitialisation3.free; ~synthDefInitialisation4.free; ~synthDefInitialisation5.free; ~synthDefInitialisation6.free; ~synthDefInitialisation7.free;
			0.1.wait; ~trajectoryBuffersTest.free; ~testBufS1.free; ~testBufS2.free;

			// Suppression des variables non utilisées
			// [~trajectoryBuffersX, ~trajectoryBuffersY, ~testWindow, ~trajectoryBuffersA, ~trajectoryBuffersTest, ~testBufS1, ~testBufS2, ~synthDefInitialisation, ~synthDefInitialisation2, ~synthDefInitialisation3, ~synthDefInitialisation4, ~synthDefInitialisation5, ~synthDefInitialisation6, ~synthDefInitialisation7].do { |i| i = nil; }; ne marche pas...
			// [\trajectoryBuffersX, \trajectoryBuffersY, \testWindow, \trajectoryBuffersA, \trajectoryBuffersTest, \testBufS1, \testBufS2, \synthDefInitialisation, \synthDefInitialisation2, \synthDefInitialisation3, \synthDefInitialisation4, \synthDefInitialisation5, \synthDefInitialisation6, \synthDefInitialisation7].do { |i| i.envirPut(nil); };
			"Main SynthDefs Initialized".postln;

		)
	}.fork/*(TempoClock.new(queueSize: 2048))*/ ; /*"Main Synths initialized";*/ // since scheduler queue is full

};





// Instantiation des synthés d'effets pour éviter les surcharges CPU la 1ère fois qu'ils sont lancés
// nécessaire SEULEMENT la 1ère fois que SC est lancée et l'ordi redémarré sinon possibilité de burst du server ???
// { ~fxSynthDefInitialisation = Synth('TapEcho'); 0.5.wait; ~fxSynthDefInitialisation.free }.fork; & problème avec TapEcho ???
// distanh spike ??? & TapEcho n'est pas repéré si pas lancé ???

~initFXSynthDefs = { |server, serverNb|

	(

		if (~initFXSynthDefsProcess.isNil or: {~initFXSynthDefsProcess == 0}, {

			{

				// Pour placer certaines définitions qui ont du mal à s'initialiser comme :
				// "/Users/xon/Library/Application Support/SuperCollider/synthdefsLiveForLife-16-Dome-8-6-2-Clock/TapEcho_C.scsyndef",
				if (currentEnvironment[server] == ~server1, {SynthDef.synthDefDir = ~synthDefsFolderS1}, {SynthDef.synthDefDir = ~synthDefsFolderS2} );

				~initFXSynthDefsProcess = 1;

				~serverVolume[serverNb].lag_(0);
				~trackFXVolView.valueAction_(0);
				~trackAllVolControl1View.valueAction_(1);
				~serverVolume[serverNb].mute; // Remplacement de la ligne d'au dessus à cause du Lag, qui pouvait provoquer une explosion sonore
				// résolu avec mute -> non, apparemment les 2 sont nécessaires...

				~fadeTimeSynthFxView2[serverNb].valueAction_(~fadeTimeSynthFxSpec.unmap(0));
				~lagTimeAllFxView2[serverNb].valueAction_(~lagTimeAllFxSpec.unmap(0));
				// ~mixAllFxView2.valueAction_(~mixAllFxViewSpec.unmap(0));
				// ~mixAllFxView2.value_(~mixAllFxViewSpec.unmap(~mixAllFxDefault)).doAction;

				0.2.wait;

				~fxSynthDefInitialisation = 0 ! ~numFxSynthDef;
				~numFxSynthDef.do { |i|
					~fxSynthDefInitialisation[i] = ~fxSynthDef[i].play(currentEnvironment[server]); ~fxSynthDefInitialisation[i].postln;
					/*0.5.wait;
					~fxSynthDefInitialisation[i].free;*/
				};

				1.wait;
				~numFxSynthDef.do { |i| ~fxSynthDefInitialisation[i].free; };

				// ~fxSynthDef[0].variants

				0.1.wait;

				((~fxListSize /*- ~numFxSynthDef*/) / ~numEffects).ceil.do { |a| var nb;
					// ~numEffects.do { |i| nb = min(~fxListSize, ((a*~numEffects)+i+1)); nb.postln; ~fxSelectView[i].valueAction_(nb); }; 0.2.wait; };
					~numEffects.do { |i| nb = min(~fxListSize, ((a*~numEffects)+i+1/*+~numFxSynthDef*/)).asInteger; nb.postln; ~fxSelectView[serverNb][i].valueAction_(nb); }; 0.2.wait; };
				~numEffects.do { |i| ~fxSelectView[serverNb][i].valueAction_(0); };

				// Initialisation de FFT EQ et FFT Delay
				//0.2.wait; ~fxTabCompSel2bView[0][0].valueAction_(1); 0.2.wait; ~fftTabCompSelView[0][0].valueAction_(1); 0.2.wait; ~fftTabCompSelView[1][0].valueAction_(1); 0.2.wait; ~fftTabCompSelView[1][0].valueAction_(0); 1.6.wait;
				// Aussi nécessaire pour le délai spectral et obligé de dissocier des autres effets pour réduire au max le spike au lancement ???
				// Mais toujours augmentation plus importante la 1ère fois + de 40 au lieu de 15% ???, mais toujours mieux qu'un burst
				/*{ // Pourquoi ~fftDelSyn = Synth(\FFTDelay); provoque une erreur -> FFTBase_Ctor error: buffer size (705600) not a power of two. ???
				~fftDelSyn = Synth(\FFTDelay, [\out, 20, \fadeTime, ~fadeTimeSynthFx, \fftDelSize, ~fftDelSize, \dels1, ~fftDelfbBufs[0], \fb1, ~fftDelfbBufs[1], \dels2, ~fftDelfbBufs[2], \fb2, ~fftDelfbBufs[3] ]);  0.5.wait; ~fftDelSyn.free; "FX Synths initialized" }.fork;*/
				// { ~fxSynth[0] = Synth.before(~fxSynth2[0], ~fxSynthDef2c[1].name, [\in_bus, (1)*~fxMulChannel,\fadeTime, ~fadeTimeSynthFx, \fftDelSize, ~fftDelSize, \dels1, ~fftDelfbBufs[0], \fb1, ~fftDelfbBufs[1], \dels2, ~fftDelfbBufs[2], \fb2, ~fftDelfbBufs[3]]); 0.5.wait; ~fxSynth[0].free; "FX Synths initialized" }.fork; // ne change rien ??? Comment réduire le CPU à 15% au 2ème lancement ???

				0.2.wait;

				(~fxAListSize / ~numEffects).ceil.do { |a| var nb;
					~numEffects.do { |i| nb = min(~fxAListSize, ((a*~numEffects)+i+1)).asInteger; nb.postln; ~fxASelectView[serverNb][i].valueAction_(nb); }; 0.2.wait; };
				~numEffects.do { |i| ~fxASelectView[serverNb][i].valueAction_(0); };

				// 1.0.wait;

				~fadeTimeSynthFxView2[serverNb].valueAction_(~fadeTimeSynthFxSpec.unmap( ~fadeTimeSynthFxDefault /*1*/));
				~lagTimeAllFxView2[serverNb].valueAction_(~lagTimeAllFxSpec.unmap( ~lagTimeAllFxDefault /*1*/));
				// ~mixAllFxView2.valueAction_(~mixAllFxViewSpec.unmap(-1));
				// ~mixAllFxView2.value_(~mixAllFxViewSpec.unmap(~mixAllFxDefault)).doAction;

				"FX SynthDefs Initialized".postln;

				~serverVolume[serverNb].lag_(7);
				~trackFXVolView.valueAction_(0.12);
				~trackAllVolControl2View.valueAction_(1);
				~serverVolume[serverNb].unmute; // Remplacement de la ligne d'au dessus à cause du Lag, qui pouvait provoquer une explosion sonore
				// résolu avec mute -> non, apparemment les 2 sont nécessaires...

				~initFXSynthDefsProcess = 0;

				// Les définitions sont remises par défaut dans ce dossier - Mais à considérer aussi ~synthDefsFolderS2 si des définitions de synthés sont rajoutées
				SynthDef.synthDefDir = ~synthDefsFolderS1;

			}.fork(AppClock); // Quand GUI lancé, seul moyen de réduire au max le spike au lancement

		});

	)

};


);

