/*
VBAPSynthDef.writeDefs(32);
VBAPSynthDef.writeDefs(5);
VBAPSynthDef.writeDefs(8);
VBAPSynthDef.writeDefs(4);
)
(
Routine({
//Server.scsynth;
VBAPLib.startupR(\fivePointOne)
}).play(AppClock)
)

(
Routine({
Server.scsynth;
VBAPLib.startupR(\octo)
}).play(AppClock)
)

(
Routine({
Server.scsynth;
VBAPLib.startupR(\soniclabSlave)
}).play(AppClock)
)

(
UScore(*[
UChain([ 'bufSoundFile', [ 'soundFile', BufSndFile.newBasic("/usr/local/share/SuperCollider/sounds/a11wlk01-44_1.aiff", 107520, 1, 44100, 0, nil, 1, true) ] ], [ 'vbap2D_Simple_Panner', [ 'point', Point(-2.1, 16.6), 'lag', 2.0 ] ])]).gui
)
*/
VBAPLib {
	//stereo, quad, octo
	classvar <>previewMode;

	*startupR { |options, serverOptions|

		var defs;

		if( options.isKindOf(Symbol) ) {
			options = VBAPOptions.fromPreset(options)
		};

		UChain.makeDefaultFunc = {
			UChain( \bufSoundFile, \stereoOutput ).useSndFileDur
		};

		this.prStartupServers(options, serverOptions);

		if(options.isSlave.not) {
			this.prStartupGUIs;
			CmdPeriod.add(this);
		}
	}

	*startup { |options, serverOptions|
		Routine({
			VBAPLib.startupR(options, serverOptions)
		}).play(AppClock)
	}

	*prStartupServers{ |options, serverOptions| //servers, send = true, allDefs = true|

		var serverOptions2 = serverOptions ?? { this.serverOptions( options ) };

		var servers = options.serverDescs.collect{ |desc|
			Server(desc[0], NetAddr(desc[1], desc[2] ), serverOptions2 )
		};

		servers.do{ |s|
			if(s.isLocal){
				1.0.wait;
				s.boot;
			}
		};

		ULib.servers = [ LoadBalancer(*servers) ];
		Server.default = servers[0];
		thisProcess.interpreter.s = servers[0];

		"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n".postln;
		if( options.serverDescs.size > 1 ) {
			//this needs to be here and not somewhere else for some misterious reason I can't remember
			ULib.serversWindow;
		};
		//client and single startup
		if(options.isSlave.not) {

			VBAPSpeakerConf.default = VBAPSpeakerConf(options.angles, options.distances);

			"*** Will start waiting for servers".postln;
			ULib.waitForServersToBoot;
			"*** Servers booted\n".postln;

			//Udef SYNTHEDEFS
			this.loadDefs(options);

			if( VBAPLib.previewMode.isNil ) {
				//VBAP BUFFERS
				"*** Creating vbap buffers".postln;
				VBAPSpeakerConf.default.sendBuffer(servers);
				"*** VBAP buffers created\n".postln;
			}
		} {
			ULib.waitForServersToBoot;
		}

	}

	*prStartupGUIs {
		if( (thisProcess.platform.class.asSymbol == 'OSXPlatform') && {
			thisProcess.platform.ideName.asSymbol === \scapp
		}) {
			UMenuBar();
		} {
			UMenuWindow();
		};

		UGlobalGain.gui;
		UGlobalEQ.gui;
		//ULib.serversWindow;
	}

	*serverOptions { |options, serverOptions|
		var serverOptions2 = serverOptions !? _.deepCopy ?? {
			ServerOptions()
			.memSize_(8192*16)
			.numWireBufs_(64*2)
			.numPrivateAudioBusChannels_(1024)
			.maxSynthDefs_(2048)
			.maxNodes_(4*1024)
		};

		options.device !? { |dev|
			serverOptions2.outDevice_(dev);
			serverOptions2.inDevice_(dev);
		};
		options.numOutputChannels !? serverOptions2.numOutputBusChannels_(_);
		options.numInputChannels !? serverOptions2.numInputBusChannels_(_);

		^serverOptions2
	}

	//only needs to be run once.
	*writeDefs { |n = 32|
		Udef
		.loadAllFromDefaultDirectory
		.collect(_.synthDef)
		.flat.select(_.notNil)
		.do({|def| def.writeDefFile; });
		VBAPSynthDef.writeDefs(n);
	}

	*cmdPeriod { Server.freeAllRemote( false ); }

	*loadDefs { |options|
		//make this less messy please !
		var defs;
		var default = Udef.loadOnInit;
		var defaultMap = UMapDef.loadOnInit;

		"*** Loading system Udefs ***".postln;
		Udef.loadOnInit_(options.sendSynthDefsAtStartup);
		UMapDef.loadOnInit_(options.sendSynthDefsAtStartup);
		this.loadUDefsFromDisk(options);
		Udef.loadOnInit_(default);
		UMapDef.loadOnInit_(defaultMap);
		"*** system Udefs loaded *** \n".postln;

		"*** Loading user Udefs ***".postln;
		(options.extraDefFolders ++ [Udef.userDefsFolder]).collect({ |path|
			(path ++ "/*.scd").pathMatch.collect({ |path|
				"Loading Udef at %".format(path).postln;
				path.load
			})
		});
		"*** User Udefs loaded ***\n".postln;

	}

	*writeDefaultSynthDefs {
		Udef.defsFolders = Udef.defsFolders ++ [
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs",
			VBAPLib.filenameSymbol.asString.dirname +/+ "UnitDefs"
		];

		UMapDef.defsFolders = UMapDef.defsFolders.add(
            WFSArrayPan.filenameSymbol.asString.dirname +/+ "UMapDefs"
        );

		Udef.loadAllFromDefaultDirectory.do(_.writeDefFile);
		UMapDef.loadAllFromDefaultDirectory.do(_.writeDefFile);
	}

	*loadUDefsFromDisk { |options|
		Udef.defsFolders = if(options.loadDefsAtStartup){ Udef.defsFolders }{[]} ++ [
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs",
			VBAPLib.filenameSymbol.asString.dirname +/+ "UnitDefs"
		] ++ options.extraDefFolders;

		UMapDef.defsFolders = UMapDef.defsFolders.add(
            WFSArrayPan.filenameSymbol.asString.dirname +/+ "UMapDefs"
        );

		Udef.userDefsFolder = Platform.userExtensionDir +/+ "../UnitDefs";

		Udef.loadAllFromDefaultDirectory;
		UMapDef.loadAllFromDefaultDirectory;
	}

}