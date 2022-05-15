WFSLib {
	
	classvar <>previewMode;
	
	*startup { |wfsOptions|
		var servers, o;
		var bootFunc;
		
		WFSOptions.presetManager.filePath = Platform.userConfigDir +/+ "default" ++ "." ++ WFSOptions.presetManager.id ++ ".presets";
		WFSOptions.presetManager.readAdd( silent: true );
		
		WFSOptions.makeCurrentAtInit = true;
		
		this.loadOldPrefs;
		this.loadPrefs;
		
		WFSServers.default !? _.close;
				
		if( WFSSpeakerConf.default.isNil ) {
			WFSSpeakerConf.default = WFSSpeakerConf.fromPreset( \default );
		};
		
		if( wfsOptions.isNil ) {
			wfsOptions = WFSOptions.current ?? { WFSOptions.fromPreset( \default ); };
		};
		
		wfsOptions.makeCurrent;
		
		WFSOptions.makeCurrentAtInit = false;
		
		if( wfsOptions.masterOptions.notNil ) {
			if( wfsOptions.serverOptions.size > 0 ) {
				WFSServers.master( 
					wfsOptions.serverOptions.collect(_.ip),
					wfsOptions.serverOptions.collect(_.startPort),
					wfsOptions.serverOptions[0].n
				)
				.makeDefault
				.hostNames_( *wfsOptions.serverOptions.collect(_.name) );
				wfsOptions.serverOptions.do({ |item, i|
					WFSServers.default[ 0 ][ i ].options						.numInputBusChannels_(  item.numInputBusChannels )
						.numOutputBusChannels_( item.numOutputBusChannels )
						.blockSize_( wfsOptions.blockSize )
						.sampleRate_( wfsOptions.sampleRate )
						.device_( item.device )
						.maxSynthDefs_(2048)
						.hardwareBufferSize_( item.hardwareBufferSize );
					 WFSServers.default.multiServers[i].servers.do({ |srv|
						 WFSSpeakerConf.setOutputBusStartOffset( srv, item.outputBusStartOffset );
					 });
				});
				WFSPathBuffer.writeServers = WFSServers.default.multiServers.collect(_[0]);
			} {
				WFSServers.single( ).makeDefault;
				WFSPathBuffer.writeServers = [ WFSServers.default.m ];
			};
			
			Server.default = WFSServers.default.m;
			o = wfsOptions.masterOptions;
			WFSServers.pulsesOutputBus = o.toServersBus;
			SyncCenter.outBus = o.toServersBus;
			WFSSpeakerConf.setOutputBusStartOffset( WFSServers.default.m, o.outputBusStartOffset );
			
			if( o.useForWFS ) {
				servers = [ WFSServers.default.m ];
			};
			
		} {
			if( wfsOptions.serverOptions.size > 0 ) {
				
				WFSServers.newCopyArgs( 
					wfsOptions.serverOptions.collect(_.ip),
					wfsOptions.serverOptions.collect(_.startPort),
					wfsOptions.serverOptions[0].n
				).init( false )
					.makeDefault
					.hostNames_( *wfsOptions.serverOptions.collect(_.name) );
				WFSPathBuffer.writeServers = WFSServers.default.multiServers.collect(_[0]);
				Server.default = WFSServers.default.multiServers[0][0];
				o = wfsOptions.serverOptions[0];
				wfsOptions.serverOptions.do({ |item,i|
					WFSServers.default.multiServers[i].servers.do({ |srv|
						 WFSSpeakerConf.setOutputBusStartOffset( srv, item.outputBusStartOffset );
					});
				});
			} {
				"WFSLib:startup : can't startup".postln;
				"\tWFSMasterOptions and WFSServerOptions are missing".postln;
				^nil;
			};
		};
		
		this.setServerOptions( o.numOutputBusChannels, o.numInputBusChannels, 64 );
		Server.default.options.blockSize = wfsOptions.blockSize;
		Server.default.options.sampleRate = wfsOptions.sampleRate;
		Server.default.options.device = o.device;
		Server.default.options.hardwareBufferSize = o.hardwareBufferSize;
		
		
		WFSLib.previewMode = wfsOptions.previewMode;
		
		UEvent.renderNumChannels = { 
			var num;
			num = WFSPreviewSynthDefs.pannerFuncs[ \n ][ WFSLib.previewMode ].value(0,0@0) !? 
				{ |x| x.asArray.size };
			num = num ?? {
				WFSSpeakerConf.default.getArraysFor( 
					ULib.servers[0].asTarget.server 
				).collect(_.n).sum
			};
			if( num == 0 ) {
				SCAlert( "Can't export audio file with current setting. Please try again with a different previewMode.", [ "open prefs", "ok" ], [ { WFSOptionsGUI.newOrCurrent }, { } ] );
			};
			num;
		};
		
		servers = servers ++ WFSServers.default.multiServers.collect({ |ms|
			LoadBalancer( *ms.servers ).name_( ms.hostName.asSymbol )
		});
		
		WFSSpeakerConf.resetServers;
		
		WFSSpeakerConf.numSystems = servers.size;
		
		servers.do({ |srv, i|
			if( srv.class == LoadBalancer ) {
				srv.servers.do({ |server|
					WFSSpeakerConf.addServer( server, i );
				});
			} {
				WFSSpeakerConf.addServer( srv, i );
			};
		});
		
		if( WFSServers.default.m.notNil && { servers.includes( WFSServers.default.m ).not }) {
			servers = [ WFSServers.default.m ] ++ servers;
		};
		
		Udef.userDefsFolder = File.getcwd +/+ "UnitDefs";
		UMapDef.userDefsFolder = File.getcwd +/+ "UMapDefs";
	   
		Udef.defsFolders = Udef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs"
		);
		
		UMapDef.defsFolders = UMapDef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UMapDefs"
		);
			
		UnitRack.defsFolders = UnitRack.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitRacks"
		);
				
		GlobalPathDict.put( \wfs, WFSOptions.current.wfsSoundFilesLocation );
		
		if( SyncCenter.mode == 'sample' ) {
			SyncCenter.writeDefs;
		};

		this.loadUDefs( false );
		
		if( WFSOptions.current.showGUI ) {
			
			UChain.makeDefaultFunc = {	
				UChain( \bufSoundFile, 
					[ \wfsSource, 
						[ \point, 5.0.rand2@(5.0 rrand: 10) ] // always behind array
					]
				).useSndFileDur
			};
			
			UChain.presetManager
				.putRaw( \dynamicPoint, { 
					UChain( 
						[ \bufSoundFile, [ 
							\soundFile, BufSndFile.newBasic("@resources/sounds/a11wlk01-44_1.aiff", 
								107520, 1, 44100, 0, nil, 1, true) 
						] ],
						[ \wfsSource, 
							[  
								\point, [
									\lag_point, [
										\point, 5.0.rand2@(5.0 rrand: 10),
										\time, 1
									]
								],
								\quality, \better
							] // always behind array
						]
					).useSndFileDur 
				})
				.putRaw( \staticPlane, { 
					UChain( 
						\bufSoundFile, 
						[ \wfsSource, [  \point, 5.0.rand2@(5.0 rrand: 10), \type, \plane ] ]
					).useSndFileDur 
				})
				.putRaw( \circlePath, {
					UChain(  
						[ \bufSoundFile, [ 
							\soundFile, BufSndFile.newBasic("@resources/sounds/a11wlk01-44_1.aiff", 
								107520, 1, 44100, 0, nil, 1, true) 
						] ],
						[ \wfsSource, [ 
							\point, UMap( \circle_trajectory, [ \speed, 0.4 ] ),
							\quality, \better 
						] ]
					).useSndFileDur 
				})
				.putRaw( \trajectory, {
					UChain(  
						\bufSoundFile,
						[ \wfsSource, [
							\point, UMap( 'trajectory', [ \trajectory, 
								WFSPathBuffer( 
									WFSPath2.generate( 5, 2.4380952380952, 
										[ \random, [\seed, 100000.rand, \radius, 10@10] ] 
									), 0, 1, true
								)
							] ),
							\quality, \better 
						] ]
					).useSndFileDur
				})
				.putRaw( \sinewave, { UChain( 
					\sine,
					[ \wfsSource, 
							[  
								\point, [ \lag_point, [ 
									\point, 5.0.rand2@(5.0 rrand: 10), \time, 1 
								] ],
								\quality, \better
							] // always behind array
						]
					).useSndFileDur
				})
				.putRaw( \noiseband, { UChain( 
					\pinkNoise,
					[ \cutFilter, [ 
						\freq, 1.0.rand.linexp( 0,1, 200, 2000 ).round(200) + [0,200]
					] ],
					[ \wfsSource, [  
						\point, [ \lag_point, [ 
							\point, 5.0.rand2@(5.0 rrand: 10), \time, 1 
						] ],
						\quality, \better
					] ]
					).useSndFileDur
				})
				.putRaw( \dualdelay, UChain( 
					'bufSoundFile', 
					[ 'delay', 
						[ 'time', 0.3, 'maxTime', 0.3, 'dry', 0.0, 'amp', 0.5, 'u_o_ar_0_bus', 1 ] 
					],
					[ 'delay', 
						[ 'time', 0.5, 'maxTime', 0.5, 'dry', 0.0, 'amp', 0.5, 'u_o_ar_0_bus', 2 ] 
					], 
					[ 'wfsSource', [ 'point', Point(-6, 6) ] ], 
					[ 'wfsSource', [ 'type', 'plane', 'point', Point(6, 6), 'u_i_ar_0_bus', 1 ] ],
					[ 'wfsSource', [ 'type', 'plane', 'point', Point(-6, -6), 'u_i_ar_0_bus', 2 ] ]
					)
				);
				
			PresetManager.all.do({ |pm|
				if( pm.object != WFSOptions ) {
					pm.filePath = Platform.userConfigDir +/+ "default" ++ "." ++ pm.id ++ ".presets";
					pm.readAdd( silent: true );
				};
			});
			
		};
		
		ULib.servers = servers;
		
		if( wfsOptions.showServerWindow ) {
			WFSServers.default.makeWindow;
		};
		
		UMenuBar.remove;
		if( thisProcess.platform.class.asSymbol === 'OSXPlatform' && {
			Platform.ideName == "scapp";
		} ) {
			thisProcess.preferencesAction = { WFSOptionsGUI.newOrCurrent; };
		};
		
		UScore.openFunc = { |path|
			if( File(path,"r").readAllString[..8] == "<xml:wfs>") {
				WFSScore.readWFSFile(path).asUEvent;
			} {
				UScore.readTextArchive( path );
			};
		};
		
		if( wfsOptions.showGUI ) {
			
			if(thisProcess.platform.class.asSymbol === 'OSXPlatform' && {
					thisProcess.platform.ideName.asSymbol === \scapp 
				}) {
			    UMenuBar();
			    SCMenuItem.new(UMenuBar.viewMenu, "WFS Position tracker").action_({
					WFSPositionTrackerGUI.newOrCurrent;
					WFSPositionTracker.start;
				});
			} {
				UMenuWindow();
				UMenuWindow.viewMenu.tree.put( 'WFS Position tracker', {
					WFSPositionTrackerGUI.newOrCurrent;
					WFSPositionTracker.start;
				});
				UMenuWindow.viewMenu.tree.put( 'WFS Preferences...', {
					WFSOptionsGUI.newOrCurrent;
				});
			};
	
			UGlobalGain.gui;
			UGlobalEQ.gui;
		};
		
	  wfsOptions.startupAction.value( this );
		
	  WFSSynthDefs.generateAllOrCopyFromResources({
	  	StartUp.defer({ WFSServers.default.boot; })
	  });
	  
	  CmdPeriod.add( this );
	  
	  if( wfsOptions.playSoundWhenReady or: { wfsOptions.serverAction.notNil } ) {
		  Routine({
            		var allTypes, defs;
            		var servers;
            		servers = WFSServers.default.multiServers.collect(_.servers).flatten(1);
            		if( WFSServers.default.m.notNil ) {
	            		servers = servers ++ WFSServers.default.m;
            		};
	              while { 
		            	servers.collect( _.serverRunning ).every( _ == true ).not; 
		         } { 
			          0.2.wait; 
			    };
	             "System ready".postln;
	             if( wfsOptions.playSoundWhenReady ) {
		             "playing lifesign".postln;
		             "server %, ready"
		             	.format( 
		             		WFSServers.default.multiServers.collect(_.hostName).join( ", ") 
		             	).speak;
	             };
	             servers.do({ |srv| wfsOptions.serverAction.value( srv ) });
		   }).play( AppClock );
	  };
	  		 
	}
	
	*cmdPeriod {
		if( WFSOptions.current.notNil ) {
			WFSServers.default.multiServers
				.collect(_.servers).flatten(1).do({ |srv|
					WFSOptions.current.serverAction.value( srv )
				});
		};
	}
	
	*setServerOptions{ |numOuts=96, numIns = 20, numPrivate = 64|
		Server.default.options
			.maxSynthDefs_(2048)
			.numPrivateAudioBusChannels_(numPrivate)
			.numOutputBusChannels_(numOuts)
			.numInputBusChannels_(numIns)
			.numWireBufs_(2048)
			.memSize_(2**19) // 256MB
			//.hardwareBufferSize_(512)
			//.blockSize_(128)
			//.sampleRate_( 44100 )
			.maxNodes_( 2**16 );
     }
     
     *loadUDefs { |loadDir = true|
	     var defs;
	     
	     Udef.loadOnInit = false;
				
		defs = Udef.loadAllFromDefaultDirectory.select(_.notNil).collect(_.synthDef).flat.select(_.notNil);
		defs = defs ++ UMapDef.loadAllFromDefaultDirectory.select(_.notNil).collect(_.synthDef).flat.select(_.notNil);
		UnitRack.loadAllFromDefaultDirectory;
				
		Udef.loadOnInit = true;
			
		defs.do({|def| def.justWriteDefFile; });
		
		if( loadDir == true ) {
			ULib.allServers.do(_.loadDirectory( SynthDef.synthDefDir ));
		};
     }

	*getCurrentPrefsPath { |action|
		var paths;
		paths = [
			File.getcwd,
			"/Library/Application Support/WFSCollider",
			"~/Library/Application Support/WFSCollider".spath
		].collect(_ +/+ "preferences.scd");
		
		paths.do({ |path|
			if( File.exists( path ) ) {
				action.value( path );
				^path;
			};
		});
		
		^nil;
	}
	
	*loadPrefs {
		this.getCurrentPrefsPath(_.load);
	}
	
	*openPrefs {
		this.getCurrentPrefsPath(Document.open(_));
	}
	
	*formatPrefs {
		var stream;
		stream = CollStream();
		
		stream << "//// WFSCollider preferences (generated on: %) ////\n\n"
			.format( Date.localtime.asString );
			
		if( WFSSpeakerConf.default.notNil ) {	
			stream << "//speaker configuration:\n";
			stream <<< WFSSpeakerConf.default << ".makeDefault;\n\n";
		};
		
		WFSOptions.usePresetsForCS = true;
		
		stream << "//options:\n";
		stream <<< WFSOptions.current << ";";
		
		WFSOptions.usePresetsForCS = false;
		
		if( WFSArrayPan.useFocusFades != true ) {
			stream << "\n\nWFSArrayPan.useFocusFades = " << WFSArrayPan.useFocusFades << ";";
		};
		if( WFSArrayPan.tapering != 0 ) {
			stream << "\n\nWFSArrayPan.tapering = " <<< WFSArrayPan.tapering << ";";
		};
		
		^stream.collection;
	}

	*writePrefs { |path|
		var file;
		path = path ? this.getCurrentPrefsPath ? 
			"~/Library/Application Support/WFSCollider/preferences.scd".spath;
		path.dirname.makeDir;
		"writing preferences file:\n%\n".postf( path );
		file = File( path, "w" );
		file.write( this.formatPrefs );
		file.close;
	}
	
	*deletePrefs { |path|
		var file;
		path = path ? this.getCurrentPrefsPath ? 
			"~/Library/Application Support/WFSCollider/preferences.scd".spath;
		"rm %".format( path.asString.escapeChar( $ ) ).unixCmd;
	}
	
	*loadOldPrefs {
		var file, dict;
		if( File.exists( 
			"/Library/Application Support/WFSCollider/WFSCollider_configuration.txt" 
		) ) {
			file = File(
				"/Library/Application Support/WFSCollider/WFSCollider_configuration.txt","r"
			);
			dict = file.readAllString.interpret;
			file.close;
			
			WFSSpeakerConf.rect( *dict[\speakConf][[0,1,3,2]] * [1,1,0.5,0.5] ).makeDefault;
			
			if(dict[\hostname].notNil){
				"starting server mode".postln;
				WFSOptions.fromPreset( 'game_of_life_server' );
			};
			
			if(dict[\ips].notNil){
				"starting client mode".postln;
				WFSOptions()
					.masterOptions_(
						WFSMasterOptions()
							.toServersBus_(14)
							.numOutputBusChannels_(20)
							.device_( dict[\soundCard] ? "MOTU 828mk2" )					)
					.serverOptions_(
						dict[ \ips ].collect({ |ip, i|
							var startport;
							if( dict[\startPorts].notNil ) {
								startport = dict[\startPorts].asCollection.wrapAt(i);
							};
							WFSServerOptions()
								.ip_( ip )
								.n_( dict[\scsynthsPerSystem] ? 8 )
								.startPort_(  startport ? 58000 )
								.name_( dict[ \hostnames ][i] );
						})
					);
			};	
		};	
	}
	
}