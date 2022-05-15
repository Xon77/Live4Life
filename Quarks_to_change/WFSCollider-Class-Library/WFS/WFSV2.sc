/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Miguel Negrao, Wouter Snoei.

    GameOfLife WFSCollider software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    GameOfLife WFSCollider is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GameOfLife WFSCollider.  If not, see <http://www.gnu.org/licenses/>.
*/

WFS {

    classvar <>graphicsMode = \fast;
    classvar <>scVersion = \new;
    classvar <>debugMode = false;

    classvar <>debugSMPTE;

    classvar <>syncWrap = 16777216; // == 2**24 == max resolution 32 bits float
    
    *initClass { debugSMPTE = SMPTE(0, 1000); }

    *debug { |string ... argsArray |
        if( debugMode )
            { (string.asString ++ "\n").postf( *argsArray ); };
        }

    *secsToTimeCode { |secs = 0|
        ^debugSMPTE.initSeconds( secs ).toString;
        }

    *setServerOptions{ |numOuts=96|
        Server.default.options
            .numPrivateAudioBusChannels_(256)
            .numOutputBusChannels_(numOuts)
            .numInputBusChannels_(20)
            .numWireBufs_(2048)
            .memSize_(2**19) // 256MB
            .hardwareBufferSize_(512)
            .blockSize_(128)
            .sampleRate_( 44100 )
            .maxNodes_( 2**16 );

    }
    
    *startupCustom { |config|
		var file, speakers,ip,name, wfsConf;

		Udef.userDefsFolder = File.getcwd +/+ "UnitDefs";		   
		Udef.defsFolders = Udef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs"
		);		
		
		WFSSpeakerConf.rect( *config[\speakConf][[0,1,3,2]] * [1,1,0.5,0.5] ).makeDefault;
			
		if(config[\hostname].notNil){
			"starting server mode".postln;
			WFS.startupServer;
		};
			
		if(config[\ips].notNil){
			"starting client mode".postln;
			WFS.startupClient(
				config[\ips],
				config[\startPorts] ?? { 58000 ! 2 },
				config[\scsynthsPerSystem] ? 8,
				config[\hostnames],
				config[\soundCard] ? "MOTU 828mk2",
				config[\numSpeakers] ? 96
			);
		};			
		   
    }
	
	*startup { ^WFSLib.startup }
	
	*startupOld {
		var file, speakers,ip,name, dict, wfsConf;

		Udef.userDefsFolder = File.getcwd +/+ "UnitDefs";		   
		Udef.defsFolders = Udef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs"
		);
		
		UnitRack.defsFolders = UnitRack.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitRacks"
		);
		U.addUneditableCategory(\wfs_panner);
		
		WFSSpeakerConf.rect( 48, 48, 5, 5 ).makeDefault;
		
		GlobalPathDict.put( \wfs, "/WFSSoundFiles" );
		GlobalPathDict.put( \resources, String.scDir );
		
		UChain.makeDefaultFunc = {
			UChain( \bufSoundFile, 
				[ \wfsStaticPoint, 
					[ \point, (5@0).rotate(2pi.rand) ]
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
					[ \wfsDynamicPoint, 
						[  
							\point, 5.0.rand2@(5.0 rrand: 10),
							\pointLag, 1,
							\quality, \better
						] // always behind array
					]
				).useSndFileDur 
			})
			.putRaw( \staticPlane, { 
				UChain( 
					[ \bufSoundFile, [ 
						\soundFile, BufSndFile.newBasic("@resources/sounds/a11wlk01-44_1.aiff", 
							107520, 1, 44100, 0, nil, 1, true) 
					] ], 
					[ \wfsStaticPlane, [  \point, 5.0.rand2@(5.0 rrand: 10) ] ]
				).useSndFileDur 
			})
			.putRaw( \circlePath, {
				UChain(  
					[ \bufSoundFile, [ 
						\soundFile, BufSndFile.newBasic("@resources/sounds/a11wlk01-44_1.aiff", 
							107520, 1, 44100, 0, nil, 1, true) 
					] ],
					[ \wfsCirclePath, [ \speed, 0.4 ] ],
					[ \wfsDynamicPoint, [ \pointFromBus, true, \quality, \better ] ]
				).useSndFileDur 
			})
			.putRaw( \wfsPath, {
				UChain(  
					[ \bufSoundFile, [ 
						\soundFile, BufSndFile.newBasic("@resources/sounds/a11wlk01-44_1.aiff", 
							107520, 1, 44100, 0, nil, 1, true) 
					] ],
					[ \wfsPathPlayer, [ \wfsPath, 
						WFSPathBuffer( 
							WFSPath2.generate( 10, 5, 
								[ \random, [\seed, 100000.rand, \radius, 10@10] ] 
							), 0, 1, true
						), 
					] ],
					[ \wfsDynamicPoint, [ \pointFromBus, true, \quality, \better ] ]
				).useSndFileDur
			})
			.putRaw( \sinewave, { UChain( 
				\sine,
				[ \wfsDynamicPoint, 
						[  
							\point, 5.0.rand2@(5.0 rrand: 10),
							\pointLag, 1,
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
				[ \wfsDynamicPoint, [  
					\point, 5.0.rand2@(5.0 rrand: 10),
					\pointLag, 1,
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
				[ 'wfsStaticPoint', [ 'point', Point(-6, 6) ] ], 
				[ 'wfsStaticPlane', [ 'point', Point(6, 6), 'u_i_ar_0_bus', 1 ] ],
				[ 'wfsStaticPlane', [ 'point', Point(-6, -6), 'u_i_ar_0_bus', 2 ] ]
				)
			);
		
		
		if( File.exists( "/Library/Application Support/WFSCollider/WFSCollider_configuration.txt" ) ) {
			file = File("/Library/Application Support/WFSCollider/WFSCollider_configuration.txt","r");
			dict = file.readAllString.interpret;
			file.close;
			WFSSpeakerConf.rect( *dict[\speakConf][[0,1,3,2]] * [1,1,0.5,0.5] ).makeDefault;
			
			if(dict[\hostname].notNil){
				"starting server mode".postln;
				WFS.startupServer;
			};
			
			if(dict[\ips].notNil){
				"starting client mode".postln;
				WFS.startupClient(
					dict[\ips], 
					dict[\startPorts] ?? { 58000 ! 2 }, 
					dict[\scsynthsPerSystem] ? 8, 
					dict[\hostnames], 
					dict[\soundCard] ? "MOTU 828mk2" 
				);
			};
			
		} {
			"starting offline".postln;
			WFS.startupOffline;
		};
		
		UMenuBar.remove;
		if( thisProcess.platform.class.asSymbol === 'OSXPlatform' ) {
			thisProcess.preferencesAction = { WFSOptionsGUI.newOrCurrent; };
		};
		
		if(thisProcess.platform.class.asSymbol === 'OSXPlatform' && {
			thisProcess.platform.ideName.asSymbol === \scapp 
		}) {
			UMenuBar();
			SCMenuItem.new(UMenuBar.viewMenu, "WFS Position tracker").action_({
				WFSPositionTrackerGUI.newOrCurrent;
			});
		} {
			UMenuWindow();
			UMenuWindow.viewMenu.tree.put( 'WFS Position tracker', {
				WFSPositionTrackerGUI.newOrCurrent;
			});
			UMenuWindow.viewMenu.tree.put( 'WFS Preferences...', {
				WFSOptionsGUI.newOrCurrent;
			});
		};

	}
		
    *startupOffline {
        var server, defs;

        this.setServerOptions(20);

        server = WFSServers.single.makeDefault;
        
        WFSLib.previewMode = \headphone;

        WFSSpeakerConf
            .numSystems_(1)
            .addServer( server.m, 0 );

        defs = Udef.loadAllFromDefaultDirectory.collect(_.synthDef).flat.select(_.notNil)
        ++WFSPrePanSynthDefs.generateAll.flat++WFSPreviewSynthDefs.generateAll;

        UnitRack.loadAllFromDefaultDirectory;

        server.boot;
        server.makeWindow;
        server.m.waitForBoot({

            defs.do({|def|
                def.load( server.m );
            });



            SyncCenter.loadMasterDefs;

            // WFSLevelBus.makeWindow;

            "\n\tWelcome to the WFS Offline System V2".postln
        });

        Server.default = WFSServers.default.m;
        ULib.servers = [ Server.default ];
        WFSPathBuffer.writeServers = [ Server.default ];

        UGlobalGain.gui;
        UGlobalEQ.gui;

        ^server
    }

    *startupClient { |ips, startPort, serversPerSystem = 8, hostnames,
            soundCard = "MOTU 828mk2", numSpeakers = 96|
        var server;
        this.setServerOptions(numSpeakers);

        if(thisProcess.platform.class == OSXPlatform) {
            Server.default.options.device_( soundCard );
        };
        server = WFSServers( ips, startPort, serversPerSystem ).makeDefault;
        server.hostNames_( *hostnames );

        server.makeWindow;
        
         WFSLib.previewMode = nil;

        WFSSpeakerConf.numSystems_( ips.size );

        server.multiServers.do({ |ms, i|
            ms.servers.do({ |server|
                WFSSpeakerConf.addServer( server, i );
            });
        });

        SyncCenter.writeDefs;

        server.m.waitForBoot({
            var defs;
            SyncCenter.loadMasterDefs;

             defs = Udef.loadAllFromDefaultDirectory.collect(_.synthDef).flat.select(_.notNil);

            defs.do({|def|
                    def.load( server.m );
              });

            UnitRack.loadAllFromDefaultDirectory;
            /*
            server.multiServers.do({ |ms|
                ms.servers.do({ |server|
                    defs.do({|def|
                        def.send( server )
                    })
                })
            });
            */

            // WFSLevelBus.makeWindow;
            "\n\tWelcome to the WFS System".postln;
        });

        Server.default = WFSServers.default.m;

        ULib.servers = [ Server.default ] ++
            WFSServers.default.multiServers.collect({ |ms|
                LoadBalancer( *ms.servers )
            });
        WFSPathBuffer.writeServers = ULib.servers.collect{ |s| s.asTarget.server };

        UGlobalGain.gui;
        UGlobalEQ.gui;

        ^server
    }

    *startupServer { |hostName, startPort = 58000, serversPerSystem = 8, soundCard = "JackRouter"|
        var server, serverCounter = 0;

        if( Buffer.respondsTo( \readChannel ).not )
            { scVersion = \old };

        this.setServerOptions;

        Server.default.options.device_( soundCard );
        server = WFSServers.client(nil, startPort, serversPerSystem).makeDefault;
        server.hostNames_( hostName );
        server.boot;
        server.makeWindow;

        Routine({
            var allTypes, defs;
            while({ server.multiServers[0].servers
                    .collect( _.serverRunning ).every( _ == true ).not; },
                { 0.2.wait; });
            //allTypes = WFSSynthDef.allTypes( server.wfsConfigurations[0] );
            //allTypes.do({ |def| def.def.writeDefFile });
            // server.writeServerSyncSynthDefs;

            defs = Udef.loadAllFromDefaultDirectory.collect(_.synthDef).flat.select(_.notNil);

            defs.do({|def| def.writeDefFile; });
            SyncCenter.writeDefs;
            server.multiServers[0].servers.do({ |server|
                server.loadDirectory( SynthDef.synthDefDir );
                });

            ("System ready; playing lifesign for "++hostName).postln;
            (hostName ++ ", server ready").speak

        }).play( AppClock );
        ^server // returns an instance of WFSServers for assignment
        // best to be assigned to var 'm' in the intepreter
    }
	
}