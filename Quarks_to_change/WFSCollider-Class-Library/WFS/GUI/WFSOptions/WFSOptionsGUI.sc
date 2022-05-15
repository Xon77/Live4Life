WFSOptionsGUI {
	
	classvar <>current;
	classvar <>columnWidth = 220, <>footerHeight = 24;
	
	var <object, <>ctrl;
	var <view, <firstColumn, <secondColumn, <footer, <presetManagerGUI;
	var <optionsView;
	var <masterComp, <masterHeader, <masterView, <masterButton;
	var <wfsHeader, <taperingSpec, <taperingView, <waitView;
	var <serverComp, <serverHeader, <serverViews;
	var <>savedMasterOptions;
	
	*new { |parent, bounds, object|
		^super.new.init( parent, bounds, object )
	}
	
	*newOrCurrent {
		if( current.notNil && { current.composite.isClosed.not } ) {
			current.composite.getParents.last.findWindow.front;
			^current;
		} {
			^this.new;
		};
	}
	
	init { |parent, bounds, inObject|
		
		if( parent.isNil ) { 
			parent = this.class.asString;
			bounds = bounds ?? { Rect( 
					190 rrand: 220, 
					300 rrand: 350,
					(2 * (columnWidth + 6)) + 2, 
					500
 				 ) 
			}; 
		} {
			bounds = parent.asView.bounds;
		};
		
		object = inObject ? WFSOptions.current ?? { WFSOptions.fromPreset( \default ); };
		
		view = EZCompositeView( parent, bounds, gap: 2@2, margin: 2@2 );
		view.resize_(5);
		bounds = view.asView.bounds;
		view.addFlowLayout(2@2, 6@6);
		
		ctrl = SimpleController( object );
		
		RoundView.pushSkin( UChainGUI.skin );
		
		firstColumn = CompositeView( view, columnWidth @ (bounds.height - footerHeight) )
			.background_( Color.gray(1).alpha_(0.125) )
			.resize_(4);
			
		firstColumn.addFlowLayout(0@0, 2@2);
		
		secondColumn = CompositeView( view, columnWidth @ (bounds.height - footerHeight) )
			.background_( Color.gray(1).alpha_(0.125) )
			.resize_(5);
			
		secondColumn.addFlowLayout(0@0, 2@2);
		
		footer = CompositeView( view, ((2 * columnWidth) + 2) @ footerHeight )
			.background_( Color.gray(1).alpha_(0.125) )
			.resize_(8);
			
		footer.addFlowLayout(0@0, 2@2);
		
		StaticText( firstColumn, columnWidth @ 14 )
			.applySkin( RoundView.skin )
			.string_( " options" )
			.background_( Color.gray(0.8).alpha_(0.5) );
		
		optionsView = WFSOptionsObjectGUI( firstColumn, columnWidth @ bounds.height, object );
		
		optionsView.views.previewMode.action = optionsView.views.previewMode.action.addFunc({ |vw, mode| 
			if( WFSLib.previewMode === \off ) {
				if( mode != \off ) {
					"WFSOptionsGUI: press 'apply' to start using previewMode '%'\n".postf( mode ) 
				};
			} {
				if( mode === \off ) {
					"WFSOptionsGUI: press 'apply' to start using previewMode 'off'".postln
				} {
					WFSLib.previewMode = mode;
					"WFSOptionsGUI: changing previewMode to '%' (effective immediately)\n".postf( mode );
				};
			};
		});

		
		firstColumn.decorator.shift( 0, 14 );
			
		masterHeader = CompositeView( firstColumn, columnWidth @ 14 )
			.background_( Color.gray(0.8).alpha_(0.5) );
			
		masterHeader.addFlowLayout( 0@0, 2@2 );
			
		StaticText( masterHeader, columnWidth - (2 + 14) @ 14 )
			.applySkin( RoundView.skin )
			.string_( " master server" );

		masterButton = SmoothButton( masterHeader, 14 @ 14 )
			.label_([ "", 'x' ])
			.radius_(2)
			.value_( object.masterOptions.notNil.binaryValue )
			.action_({ |bt|
				if( bt.value == 1 ) {
					object.masterOptions = object.masterOptions ? savedMasterOptions ??
						 { WFSMasterOptions().useForWFS_(true) };
				} {
					savedMasterOptions = object.masterOptions;
					object.masterOptions = nil;
				};
				//this.makeMasterGUI;
			});		
		
		masterComp = CompositeView( firstColumn, columnWidth @ WFSMasterOptionsGUI.getHeight );
		
		this.makeMasterGUI;
		
		firstColumn.decorator.shift(0, 14);
		
		wfsHeader = CompositeView( firstColumn, columnWidth @ 14 )
			.background_( Color.gray(0.8).alpha_(0.5) );
			
		masterHeader.addFlowLayout( 0@0, 2@2 );
			
		StaticText( wfsHeader, columnWidth - (2 + 14) @ 14 )
			.applySkin( RoundView.skin )
			.string_( " wfs settings" );	
		
		SmoothButton( firstColumn, firstColumn.bounds.width @ 24 )
			.label_( "edit speaker configuration" )
			.action_({
				WFSSpeakerConfGUI.newOrCurrent
			});
			
		BoolSpec( WFSArrayPan.useFocusFades )
			.makeView( firstColumn, firstColumn.bounds.width @ 14, "useFocusFades", { |vw, value|
				WFSArrayPan.useFocusFades = value;
			} );
			
		taperingSpec = ControlSpec( 0, 0.5, \lin, 0.05, 0 ); 
		taperingView = taperingSpec.makeView( firstColumn, firstColumn.bounds.width @ 14,
			"tapering", { |vw, value|
				WFSArrayPan.tapering = value;
			}
		);
		taperingSpec.setView( taperingView, WFSArrayPan.tapering );
		
		firstColumn.decorator.nextLine;
		firstColumn.decorator.shift( 64, 0);
		
		waitView = WaitView( firstColumn, 14 @ 14 )
			.alphaWhenStopped_(0);
		
		SmoothButton( firstColumn, (firstColumn.bounds.width - 80) @ 14 )
			.label_( "rebuild SynthDefs" )
			.action_({ |bt|
				bt.enabled = false;
				waitView.start;
				{
					WFSSynthDefs.loadAll({
						waitView.stop;
						if( bt.isClosed.not ) { bt.enabled = true; };
					});
				}.defer(0.1);
			});
		
		firstColumn.decorator.nextLine;
		firstColumn.decorator.top_( firstColumn.bounds.height - 34);
		
		presetManagerGUI = PresetManagerGUI( 
			firstColumn, 
			firstColumn.bounds.width @ 28,
			object.class.presetManager, 
			object
		);
		
		presetManagerGUI.resize_(7);
		
		serverHeader = CompositeView( secondColumn, columnWidth @ 14 )
			.background_( Color.gray(0.8).alpha_(0.5) )
			.resize_( 2 );
			
		serverHeader.addFlowLayout( 0@0, 2@2 );
			
		StaticText( serverHeader, columnWidth - ((2 + 14) * 2) @ 14 )
			.applySkin( RoundView.skin )
			.string_( " servers" );

		SmoothButton( serverHeader, 14 @ 14 )
			.label_('-')
			.action_({
				object.serverOptions = object.serverOptions[..object.serverOptions.size-2];
				this.makeServersGUI;
			})
			.resize_( 3 );
		
		SmoothButton( serverHeader, 14 @ 14 )
			.label_('+')
			.action_({
				var last;
				last = object.serverOptions.last;
				if( last.notNil ) {
					last = last.copy;
					if( last.ip == "127.0.0.1" ) {
						last.ip = NetAddr.myIP;
					};
					if( last.ip != "127.0.0.1" ) {
						last.ip = PathName(last.ip).nextName;					};
					last.name = PathName(last.name).nextName;
				} {
					last = WFSServerOptions();
					if( object.masterOptions.notNil ) {
						last.ip = PathName( NetAddr.myIP ).nextName;
					};
				};
				object.serverOptions = object.serverOptions ++ [ last ];
				//this.makeServersGUI;
			})
			.resize_( 3 );
			
		serverComp = CompositeView( secondColumn, columnWidth @ (secondColumn.bounds.height - 16) )
			.resize_(5);
		
		serverComp.addFlowLayout( 0@0, 2@2 );	
					
		this.makeServersGUI;
		
		footer.decorator.left_( footer.bounds.width - 154 );
		
		/*
		SmoothButton( footer, 100 @ 14 )
			.label_( "delete prefs" )
			.action_({
				WFSLib.deletePrefs;
			})
			.resize_(9);
		*/
		
		SmoothButton( footer, 50 @ 24 )
			.states_( [ [ "save", Color.black, Color.red(1,0.25) ] ] )
			.action_({
				WFSLib.writePrefs;
			})
			.resize_(9);
		
		SmoothButton( footer, 100 @ 24 )
			.label_( "apply" )
			.action_({
				WFSLib.startup( object );
			})
			.resize_(9);
		
		RoundView.popSkin;
		
		ctrl.put( \masterOptions, {
				masterButton.value = object.masterOptions.notNil.binaryValue;
				this.makeMasterGUI;
			})
			.put( \serverOptions, {
				this.makeServersGUI;
			});

		current = this;
		this.class.changed( \current );
		
		view.findWindow.toFrontAction = { 
			current = this;
			this.class.changed( \current );
		};
		
		view.onClose = view.onClose.addFunc( { 
			ctrl.remove;
			if( current == this ) {
				current = nil;
				this.class.changed( \current );
			};
		} );
	}
	
	makeMasterGUI {
		
		masterView !? _.remove;
		masterComp.refresh;
				
		if( object.masterOptions.notNil ) {
			masterView = WFSMasterOptionsGUI( masterComp, columnWidth @ 14, object.masterOptions )
				.background_( Color.gray(0.3).alpha_(0.25) ); 
		} {
			masterView = nil;
		};
	}
	
	makeServersGUI {
		serverViews.do(_.remove);
		serverComp.refresh;
		serverComp.decorator.reset;
		
		serverViews = object.serverOptions.collect({ |item|
			WFSServerOptionsGUI( serverComp, serverComp.bounds.width @ 14, item )
				.background_( Color.gray(0.3).alpha_(0.25) );
		});
	}
	
	object_ { |obj| 
		ctrl.remove;
		object = obj;
		optionsView.object = obj;
		
	 }
	
	doesNotUnderstand { |selector ...args|
		var res;
		res = optionsView.perform( selector, *args );
		if( res != optionsView ) { ^res; }
	}
	
}

+ WFSOptions {
	gui { |parent, bounds| ^WFSOptionsGUI( parent, bounds, this ) }
}