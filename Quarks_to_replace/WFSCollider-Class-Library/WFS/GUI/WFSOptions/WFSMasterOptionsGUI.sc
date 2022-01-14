AbstractWFSOptionsGUI {
	
	var <options, <label;
	
	var <parent, <composite, <views, <controller;
	var <viewHeight = 14, <labelWidth = 120;
	var <>action;
		
	*new { |parent, bounds, options, label = ""|
		^super.newCopyArgs( options, label ).init( parent, bounds );
	}
	
	*specs { ^() }
	
	init { |inParent, bounds|
		parent = inParent;
		if( parent.isNil ) { parent = Window( this.class.name ).front };
		this.makeViews( bounds );
	}
	
	*getHeight { |viewHeight, margin, gap|
		viewHeight = viewHeight ? 14;
		margin = margin ?? {0@0};
		gap = gap ??  {4@4};
		^(margin.y * 2) + ( 
			 this.specs.keys.size * (viewHeight + gap.y) 
		) - gap.y;
	}
	
	makeViews { |bounds|
		var margin = 0@0, gap = 4@4;
		
		bounds = (bounds ?? { parent.asView.bounds.insetBy(4,4) }).asRect;
		bounds.height = this.class.getHeight( viewHeight, margin, gap );
		controller = SimpleController( options );
		
		composite = CompositeView( parent, bounds ).resize_(2);
		composite.addFlowLayout( margin, gap );
		composite.onClose = {
			controller.remove
		 };
		
		views = ();
		
		RoundView.pushSkin( UChainGUI.skin ++ ( 'labelWidth': labelWidth ) );
		
		this.class.specs.keys.do({ |key, i|
				var vw, spec;
				
				spec = this.class.specs[ key ];
							
				vw = ObjectView( composite, nil, options, key, spec, controller );
					
				vw.action = { action.value( this, key ); };
					
				views[ key ] = vw;
			});
			
		RoundView.popSkin;
	}
	
	remove { composite.remove; }
		
	resize_ { |resize| composite.resize_(resize) }
	
	font_ { |font| views.values.do({ |vw| vw.font = font }); }
	
	viewHeight_ { |height = 14|
		views.values.do({ |vw| vw.view.bounds = vw.view.bounds.height_( height ) });
		composite.decorator.reFlow( composite );
	}
	
	labelWidth_ { |width=80|
		labelWidth = width;
		views.values.do(_.labelWidth_(width));
	}
	
	view { ^composite }
	
	background_ { |color| composite.background = color }
}

WFSMasterOptionsGUI : AbstractWFSOptionsGUI {
	
	classvar <>specs;
	
	*initClass {
		specs = OEM(
			\numInputBusChannels, IntegerSpec( 20, 8, 256 ),
			\numOutputBusChannels, IntegerSpec( 20, 8, 256 ),
			\outputBusStartOffset, IntegerSpec( 0, 0, 256 ),
			\device, AudioDeviceSpec(),
			\hardwareBufferSize, ListSpec( [64, 128, 256, 512, 1024, nil] ),
			\useForWFS, BoolSpec(false),
			\toServersBus, IntegerSpec( 14, 0, 127 ),
		);
	}

}


WFSServerOptionsGUI : AbstractWFSOptionsGUI {
	
	classvar <>specs;
	
	*initClass {
		specs = OEM(
			\name, StringSpec("Game Of Life 1"),
			\ip, StringSpec("127.0.0.1"),
			\startPort, IntegerSpec( 58000, 7000, 100000 ),
			\n, IntegerSpec( 8, 1, 16 ),
			\numInputBusChannels, IntegerSpec( 8, 8, 256 ),
			\numOutputBusChannels, IntegerSpec( 96, 8, 256 ),
			\outputBusStartOffset, IntegerSpec( 0, 0, 256 ),
			\device, AudioDeviceSpec("JackRouter"),
			\hardwareBufferSize, ListSpec( [64, 128, 256, 512, 1024, nil] ),
		);
	}

}

WFSOptionsObjectGUI : AbstractWFSOptionsGUI {
	
	classvar <>specs;
	
	*initClass {
		specs = OEM(
			\previewMode, ListSpec( [ \off, \headphone, \stereo, \quad, \quad_crossed, \hexa, \hexa_pairs, \octo, \octo_pairs, \hexa_deci, \twentyfour, \thirtytwo, \sixtyfour, \b_format, \ambix, \mono ] ),
			\showGUI, BoolSpec(true),
			\showServerWindow, BoolSpec(true),
			\playSoundWhenReady, BoolSpec(true),
			\startupAction, CodeSpec(),
			\serverAction, CodeSpec(),
			\blockSize, ListSpec( [ 1, 64, 128 ] ),
			\sampleRate, ListSpec( [ 44100, 48000, 88200, 96000 ] ),
			\wfsSoundFilesLocation, StringSpec().default_( "/WFSSoundFiles" );
		);
	}

}

+ WFSMasterOptions {
	gui { |parent, bounds| ^WFSMasterOptionsGUI( parent, bounds, this ) }
}

+ WFSServerOptions {
	gui { |parent, bounds| ^WFSServerOptionsGUI( parent, bounds, this ) }
}



