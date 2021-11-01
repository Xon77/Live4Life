/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2010 Wouter Snoei.

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

WFSServers {

	// 3 possible types:
	//    - master: a local master server and a number of remote client multiservers
	//    - client: no master, only one set of client servers 
	//    - single: only a master server; meant for use on a single system
	
	classvar <>default;
	classvar <>pulsesNodeID = 5;
	classvar <>syncDelayBusID = 0;
	classvar <>maxStartsPerCycle = 25; // high values give errors with longer scores
	classvar  <>wrapTime = 20.0;
	classvar <>pulsesOutputBus = 14;
	classvar <>singlePort = 57999;
	
	var <ips, <startPort, <serversPerSystem;
	var <multiServers;
	var <masterServer;
	var <basicName = "wfs";
	var <window;
	var serverLabels;
	var <>pointer = 0;
	var <>wfsConfigurations;
	var <activityIndex;
	var <activityFromCPU = false;
	var <syncDelays;
	var delayViews;
	var <>singleWFSConfiguration;
	var <>debugWatchers;
	
	var <>activityDict; // added 16/04/2009 - split activity spreading
	
	//*initClass { default = WFSServers( "127.0.0.1" ); }
	
	*new { |ips, startPort = 58000, serversPerSystem = 8|
		^super.newCopyArgs( ips, startPort, serversPerSystem ).init;
	}
	
	*master { |ips, startPort = 58000, serversPerSystem = 8| 
		^this.new( ips, startPort, serversPerSystem )
		}
	
	*client { | ip, startPort = 58000, serversPerSystem = 8|
		ip = ip ? "127.0.0.1";
		^super.newCopyArgs( [ip], [startPort], serversPerSystem ).init( false );
		}
		
	*single { ^super.newCopyArgs(nil,[ singlePort + 1 ],8).init; }
		
	init { |addMaster = true|
		[ips,startPort,serversPerSystem].postln;
		multiServers = ips.collect({ |ip, i|
			MultiServer.row( 
				serversPerSystem, 
				basicName ++ (i+1) ++ "_", 
				NetAddr( ip, startPort[i] ), 
				Server.default.options , 
				synthDefDir: SynthDef.synthDefDir
				);
			}) ? [];
			
		syncDelays = { { 0 }!serversPerSystem }!ips.size;
		delayViews = { { nil }!serversPerSystem }!ips.size;
		
		CmdPeriod.add( this );
			
		if( addMaster ) { 
			masterServer = Server( 
				"wfs_master", 
				NetAddr("127.0.0.1", startPort[0] - 1 ),
				Server.default.options.copy;
				);
			};
		
		activityIndex = 0!serversPerSystem;
		activityDict = IdentityDictionary[];
		multiServers.do({ |ms| ms.servers.do({ |srv| activityDict[ srv ] = 0 }) });
		
		SyncCenter.initClass; // throw away any old servers
		
		if( this.isMaster ){
			SyncCenter.addAll(multiServers.collect{ |msv| msv.servers }.flat);
			SyncCenter.master_(masterServer);
		};
		
		if( this.isSingle ) {
			SyncCenter.master_(masterServer);
		}
	}
		
	m { ^masterServer; }
	
	freeAllBuffers {
		multiServers.do({ |ms, i|
			ms.servers.do({ |srv, ii| 
				srv.bufferArray.select( _.notNil ).do({
					|buffer| 
						"wfs%_%: freed buffer % (% samples)\n"
							.postf( i, ii, buffer.bufnum, buffer.numFrames );
						buffer.free; });
					});
				});
						
		}
	
	boot { if( masterServer.notNil )
			{ masterServer.boot; };
		multiServers.do({ |ms|
			if( ms.servers[0].addr.ip.asSymbol == '127.0.0.1' ) {				if( 
				true
				// ms[0].options.device == "JackRouter" or: { 
				//		thisProcess.platform.class.asSymbol === 'LinuxPlatform'
				//} 
				) { 
					//{ 0.1.wait; ms.boot(10) }.fork 
					Routine({
						0.1.wait;
						ms.servers.do{ |server| 
							10.wait;
							server.boot;
						}
					}).play
				} { 
					ms.servers.do(_.boot);
				};
			};
		});
	}
	
	quit {
		 if( masterServer.notNil ) { masterServer.quit; };
		 multiServers.do({ |ms|
			 ms.servers.do({ |srv|
				 if( srv.isLocal ) { srv.quit };
			 });
		 });
	}
	
	close {
		this.quit;
		this.allServers.do({ |item|
			Server.all.remove( item );
			ServerTree.objects !? _.removeAt( item );
			ServerBoot.objects !? _.removeAt( item );
			RootNode.roots.removeAt( item.name );
			NodeWatcher.all.removeAt( item.name );
		});
		if( window.notNil && { window.isClosed.not }) { window.close; };
	}
	
	cmdPeriod { Server.freeAllRemote( false ); }
	
	isMaster { ^( masterServer.notNil && { multiServers.size != 0 }) }
	isClient { ^( masterServer.isNil && { multiServers.size == 1 }) }
	isSingle { ^( masterServer.notNil && { multiServers.size == 0 }) }
	
	hasMasterServer { ^masterServer.notNil }
	
	makeWindow {
		var comp, widgets = List.new;
		var font;
		
		RoundView.pushSkin( UChainGUI.skin );
		
		font = Font( Font.defaultSansFace, 11 );
		
		if( window.notNil && { window.isClosed.not }) { window.front; ^this };
		
		window = Window("WFSServers", Rect(	
				10, 
				10 + ((this.isSingle && { Server.internal.window.notNil }).binaryValue * 250), 
				390, 
				8 + ( (ips.size * serversPerSystem) * 22) +
					( this.hasMasterServer.binaryValue * 44 ) + 
					( this.isMaster.binaryValue * 20 ) + 
					(ips.size * 16 ) 
			), false 
		).front;
		
		window.onClose_({ widgets.do(_.remove) });
		
		window.view.decorator = FlowLayout(window.view.bounds);

		
		if( this.hasMasterServer )
			{ 
			//delayViews = syncDelays.copy;
			
			SmoothButton( window, Rect( 0, 0, 16, 16 ) )
				.states_([["K", Color.black, Color.clear]])
				.font_( font )
				.action_( { "killall -9 scsynth".unixCmd; } );
			
			if( SyncCenter.mode === \sample ) {
				SmoothButton( window, Rect( 0, 0, 36, 16 ) )
					.states_( [["sync"]] )
					.font_( font )
					.action_( {
						SyncCenter.remoteSync;	
					} );
				
				widgets.add(SyncCenterStatusWidget(window,15));
			};
			
			StaticText( window, Rect( 0, 0, 118, 15 ) )
				.string_( "master (" ++ ( NetAddr.myIP ? "127.0.0.1" ) ++ ")" )
				.font_( font );
				
			window.view.decorator.shift( window.view.decorator.indentedRemaining.width - 144, 0 );
			
			SmoothButton( window, Rect( 0, 0, 36, 16 ) )
					.states_( [["clear"]] )
					.font_( font )
					.action_( {
						ULib.clear;
					} );

			EZSmoothSlider(window, Rect(0,0,100,15),nil, [0.02,1,\exp,0,0.02].asSpec)
			    .value_(masterServer.latency)
			    .font_( font )
			    .action_({ |v| masterServer.latency = v.value})
			    .numberWidth_( 40 )
			    .sliderView
			    		.string_("Latency")
			    		.knobColor_( Color.black.alpha_(0.25) );

			window.view.decorator.nextLine;
			masterServer.uView( window ); 
			if( this.isMaster ) {
				
				/*
				SmoothButton( window, Rect( 0, 0, 116, 16 ) )
					.states_( [["sync"]] )
					.font_( font )
					.action_( {
						SyncCenter.remoteSync;	
					} );
				
				widgets.add(SyncCenterStatusWidget(window,17));
				*/		
				/*		
				Button( window, Rect( 0, 0, 90, 16 ) )
					.states_( [["open hosts"]] )
					.font_( Font( "Monaco", 9 ) )
					.action_( { this.openHosts; } ); 
				*/
				
				window.view.decorator.shift(270,0);
					
				SmoothButton( window, Rect( 0, 0, 110, 16 ) )
					.states_( [["shut down hosts"]] )
					.font_( font )
					.action_( { SCAlert( "Do you really want to shut down\nboth host servers?",
							 ["cancel", "unmount only", "restart SC", "Shut Down"], 
							 [{}, 
							 { // "~/Unmount servers.app".openInFinder 
							  "umount /WFSSoundFiles".unixCmd;
								 },
							 { 
						
						ips.collect({ |ip, i|
							"killall -9 WFSCollider; 
							killall -9 WFSCollider-Leiden; 
							killall -9 scsynth ; 
							killall -9 SuperCollider; 
							killall -9 jackdmp; 
							killall -9 JackPilot; 
							open '/Applications/autostart jackosx intel.app'; 
							sleep 10; 
							open '%'"
							.format( String.scDir.dirname.dirname )
							.asSSHCmd( "gameoflife", NetAddr(ip) )
						}).join( " & " ).unixCmd;
						
						"restarting WFSCollider on hosts in apx. 10 seconds".postln;							  },
							 {
							  //"~/Unmount servers.app".openInFinder;
							  //"umount /WFSSoundFiles".unixCmd;
							  
							{	var win, views;
								
								win = Window( "", 
									Rect( *(Rect(0,0,800,250)
										.centerIn( Window.screenBounds).asArray 
											++ [800,250]) ) ).front;
								win.view.background_( Color.white
									.blend( Color.red(0.6), 0.25 ) );
								
								win.drawHook = { |win| 
									Color.red.set; 
									Pen.width_( 30 );
									Pen.strokeRect( win.view.bounds );   
									};
								
								//win.decorate;
									
								views = ();
								
								StaticText( win, win.view.bounds.copy.height_( 150 ) )
									.string_( "WARNING:\nAre the AMPLIFIERS switched OFF?" )
									.font_( Font( "Helvetica-Bold", 40 ) )
									.align_( \center );
								
								Button( win, Rect(80,150,180,50) )
									.states_( [[ "cancel", Color.black, Color.white ]] )
									.action_({ |bt| win.close; })
									.font_( Font( "Helvetica-Bold", 30 ) );
								
								Button( win, Rect(320,150,400,50) )
									.states_( [[ "yes, shut down now", 
												Color.black, Color.white ]] )
									.font_( Font( "Helvetica-Bold", 30 ) )
									.action_({ |bt| win.close;
									 // "~/Shutdown_Servers.command".openInFinder;
									  "shutting down hosts..".postln;
									  
									  /*
									  for the shutdown to work you need to use the
									  visudo unix command on each server and add 
									  the following line:
									  
									  %admin ALL=NOPASSWD:/sbin/shutdown -h now
									  */
									(
										"umount /WFSSoundFiles;" ++
										ips.collect({ |ip|
											"sudo shutdown -h now"
												.asSSHCmd( "gameoflife", NetAddr(ip) )
										}).join( " & " ) 
									).unixCmd;
									
									 }).focus;
									}.value;


							  }] )
						.iconName_( \power )
						.color_( Color.blue(0.25) ); } ); 
				
				window.view.decorator.nextLine;
				};
			};
			
		serverLabels = nil!multiServers.size;
		multiServers.do({ |multiServer, i| 
		
			SmoothButton( window, Rect( 0, 0, 12, 12 ) )
				.states_([["k", Color.black, Color.red.alpha_(0.1)]])
				.radius_(2)
				.font_( font )
				.action_( {
					// kill synths and press cmd-k on remote
					if( ips[i] == "127.0.0.1" ) {
						 "killall -9 scsynth".unixCmd; 
					} {
					"killing scsynths on server %".postf( ips[i].asString );
					"killall -9 scsynth; sleep 2; killall -9 scsynth;"
						.sshCmd( "gameoflife", NetAddr(ips[i]) );
					};
			} );
					 
			serverLabels[i] = StaticText( window, Rect( 0, 0, 200, 12 ) )
				.string_("multi" ++ (i+1) ++ " (" ++ 
					if( ips[i] == "127.0.0.1",
						{ NetAddr.myIP ? "127.0.0.1" }, { ips[i] } )
					++ "/" ++ multiServer.hostName ++ ")" )
				.font_( font );
			
			if( this.isMaster.not ) {	 
				window.view.decorator.shift( window.view.decorator.indentedRemaining.width - 144, 0 );
			
				SmoothButton( window, Rect( 0, 0, 36, 16 ) )
						.states_( [["clear"]] )
						.font_( font )
						.action_( {
							ULib.clear;
						} );
	
				EZSmoothSlider(window, Rect(0,0,100,15),nil, [0.02,1,\exp,0,0.02].asSpec)
				    .value_(multiServer[0].latency)
				    .font_( font )
				    .action_({ |v| multiServer[0].latency = v.value})
				    .numberWidth_( 40 )
				    .sliderView
				    		.string_("Latency")
				    		.knobColor_( Color.black.alpha_(0.25) );
					
				
				/*
				EZSmoothSlider(window, Rect(0,0,160,15),"Latency", [0.02,1,\exp,0,0.02].asSpec)
				    .value_(multiServer[0].latency)
				    .action_({ |v| multiServer[0].latency = v.value});
				*/
			};
			
			window.view.decorator.nextLine;
			
			multiServer.servers.do({ |server, ii| 
				if( this.isMaster ) {
					widgets.add(SyncCenterServerWidget(window,70@17,server,true))
				};
				server.uView( window ); 
				});
			});
			
		RoundView.popSkin
		
		//window.view.decorator.nextLine;
		}
		
	makeDefault { default = this }
	
	allServers { ^masterServer.asCollection ++ multiServers.collect({ |ms| ms.servers }).flat }
	
	at { |index| 
		 if( this.isSingle ) 
		 	{ ^[masterServer] } // if single always master server
			{ ^multiServers.collect({ |ms,i| 
				ms.servers.wrapAt( index.asCollection.wrapAt(i) )  // ws 16/04/09
				}); } 
		}
		
	current { if( this.isSingle ) 
		{ ^[masterServer] } 
		{ ^this.at( pointer ); } 
		}
	
	updateActivity { if( activityFromCPU && { this.isSingle.not } )
		{ activityIndex = multiServers[0].servers.collect( _.avgCPU );  };
		}
	
	addActivity { |value = 0, index| 
		activityIndex[ index ? pointer ] = activityIndex[ index ] + value; }
	
	removeActivity { |value = 0, index| 
		activityIndex[ index ? pointer ] = activityIndex[ index ] - value; }
		
	setActivity { |value = 0, index| activityIndex[ index ? pointer ] = value; }
	resetActivity { activityIndex = 0!serversPerSystem; }
	
	leastActiveIndex { ^activityIndex.normalize.detectIndex( _ == 0 ); }
	
	next {
		if( this.isSingle.not )
			{this.updateActivity; pointer = this.leastActiveIndex; };
		^this.current; 
		}
		
	currentSyncDelay { ^syncDelays.flop[ pointer ] ? 0 }
	currentSyncDelayS { ^this.currentSyncDelay / 44100 }
	
	nextIndex { |addActivity = 0|
		if( this.isSingle.not )
			{this.updateActivity;  pointer = this.leastActiveIndex; };
		//pointer = this.leastActiveIndex;
		this.addActivity( addActivity, pointer );
		^pointer 
		}
	
	nextArray { |addActivity = 0|
		if( this.isSingle.not )
			{this.updateActivity; pointer = this.leastActiveIndex; 
				this.addActivity( addActivity, pointer );
				^[pointer, this.current, this.currentSyncDelayS ];
			}
			{ ^[0, this.masterServer, 0 ] }
		
		}
		
	hostNames { ^multiServers.collect( _.hostName ); }
	hostNames_ { |... names| 
		names.do({ |name, i| multiServers[ i ].hostName = name.asString; });
		}
		
	openHosts { |login = "gameoflife", pwd = "192x"|
		multiServers.do({ |ms, i|
			if( ms.hostName.size != 0 )
				{ ms.openHost( login, pwd );  }
				{ "WFSServers-openHosts: MultiServer %: hostname not specified\n".postf( i ) };
			});
		}

	startDebugWatcher {
		if(multiServers.notNil){
			debugWatchers = multiServers.collect{ |multiServer|
				multiServer.servers.collect{ |server|
					var debug = DebugNodeWatcher(server);
					debug.start;
					debug;
				}
			}.flat
		}
	}

	stopDebugWatcher {
		debugWatchers.do{ |watcher|
				watcher.stop
		}
	}
	
	}