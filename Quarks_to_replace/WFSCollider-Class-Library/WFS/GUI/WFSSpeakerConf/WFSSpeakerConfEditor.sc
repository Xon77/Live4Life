WFSSpeakerConfEditor {
	
	var <speakerConf;
	var <labelViews, <arrayConfGUIs, <>composite;
	var <controller, <scrollView, <parent;
	var <>action, <>onClose;
	var <presetManagerGUI;
	var <rotateSlider, <scaleSlider, <rotateVal = 0, <scaleVal = 1;
	var <gain, <arrayLimit, <focusWidth;
	var <speakerCount, <speakersUnits, <numArraysInc, <numArraysDec, <numArraysBox, <slideInc, <slideDec;
	
	
	*new { |parent, bounds, speakerConf|
		^super.newCopyArgs( speakerConf ).init( parent, bounds );
	}
	
	init { |inParent, bounds|
		
		parent = inParent;
		
		this.speakerConf = speakerConf ? WFSSpeakerConf.default;
		
		if( parent.isNil ) { 
			parent = this.class.asString;
		};
		
		if( parent.class == String ) {
			parent = Window(
				parent, 
				bounds = bounds ?? { Rect(128 rrand: 256, 64 rrand: 128, 342, 400) }, 
				scroll: false
			).front;
		};
		
		this.makeViews( bounds );
	}
	
	speakerConf_ { |newSpeakerConf|
		controller.remove;
		speakerConf = newSpeakerConf ? WFSSpeakerConf.default;
		controller = SimpleController( speakerConf );
	}
	
	selected { 
		var selected = [];
		arrayConfGUIs.do({ |gui, i|
			if( gui.selected ) { selected = selected.add(i) };
		});
		^selected;
	}
	
	select { |...indices|
		arrayConfGUIs.do({ |item, i|
			item.select( indices.includes(i) );
		});
	}
	
	makeViews { |bounds|
		var margin = 0@0, gap = 4@4;
		
		composite = CompositeView( parent, bounds.asRect.copy.moveTo(0,0) ).resize_(5);
		composite.addFlowLayout( margin, gap );
		composite.onClose = { |vw| controller.remove; onClose.value( this ); };
		
		scrollView = ScrollView( composite, 
			composite.bounds.width @  (composite.bounds.height - ((7 * 18)))
		).resize_(5);
		
		scrollView.addFlowLayout( margin, gap );
		this.makeArrayConfGUIs;
		
		RoundView.pushSkin( UChainGUI.skin );
		
		StaticText( composite, 50@14 )
			.applySkin( RoundView.skin )
			.string_( "gain" )
			.resize_( 7 );
			
		gain = SmoothNumberBox( composite, 50@14 )
			.clipLo_( -24 )
			.clipHi_( 24 )
			.step_(1)
			.scroll_step_(1)
			.value_( speakerConf.gain )
			.action_({ |nb|
				speakerConf.gain_( nb.value );
			})
			.resize_( 7 );
		
		StaticText( composite, 80@14 )
			.applySkin( RoundView.skin )
			.string_( "arrayLimit" )
			.align_( \right )
			.resize_( 7 );
		
		arrayLimit = SmoothNumberBox( composite, 50@14 )
			.clipLo_(0.1)
			.clipHi_(1)
			.step_(0.1)
			.scroll_step_(0.1)
			.value_( speakerConf.arrayLimit )
			.action_({ |nb|
				speakerConf.arrayLimit_( nb.value );
			})
			.resize_( 7 );

		composite.decorator.nextLine;
		
		focusWidth = EZSmoothSlider( composite, composite.bounds.width@14, "focusWidth", 
			[0.5,2,\lin,0.01,0.5,"pi"].asSpec, 
			{ |sl| 
				speakerConf.focusWidth_( sl.value * pi );
			}, labelWidth: 50, unitWidth: 30
		).value_( speakerConf.focusWidth / pi);
		
		focusWidth.labelWidth = 50;
		focusWidth.labelView.align = \left;
		focusWidth.view.resize_( 7 );
		
		composite.decorator.nextLine;
		
		StaticText( composite, 50@14 )
			.applySkin( RoundView.skin )
			.string_( "speakers" )
			.resize_( 7 );
			
		speakerCount = SmoothNumberBox( composite, 50@14 )
			.clipLo_(WFSArrayConfGUI.specs.n.step * speakerConf.size )
			.step_(8)
			.scroll_step_(8)
			.value_( speakerConf.speakerCount )
			.action_({ |nb|
				speakerConf.setSpeakerCount( nb.value, speakersUnits.value );
				speakerConf.changed( \init );
			})
			.resize_( 7 );
		
		StaticText( composite, 80@14 )
			.applySkin( RoundView.skin )
			.string_( "unitSize" )
			.align_( \right )
			.resize_( 7 );
		
		speakersUnits = SmoothNumberBox( composite, 50@14 )
			.clipLo_(1)
			.clipHi_(8)
			.step_(1)
			.scroll_step_(1)
			.value_( WFSArrayConfGUI.specs.n.step )
			.action_({ |nb|
				speakerCount.step = nb.value;
				speakerCount.scroll_step = nb.value;
				WFSArrayConfGUI.specs.n.step = nb.value;
				WFSArrayConfGUI.specs.n.minval = nb.value;
				arrayConfGUIs.do({ |gui|
					var box;
					box = gui.views[\n].views.box;
					box.step = nb.value;
					box.scroll_step = nb.value;
					box.clipLo = nb.value;
				});
				speakerCount.valueAction = speakerCount.value.round(nb.value);
			})
			.resize_( 7 );
		
		composite.decorator.nextLine;
		
		StaticText( composite, 50@14 )
			.applySkin( RoundView.skin )
			.string_( "arrays" )
			.resize_( 7 );
		
		numArraysInc = SmoothButton( composite, 14@14 )
			.label_( '-' )
			.action_({ 
				var count = speakerConf.speakerCount;
				speakerConf.removeArray;
				speakerConf.setSpeakerCount( count, speakersUnits.value );
				speakerConf.init;
			})
			.resize_( 7 );
		numArraysBox = StaticText( composite, 14@14 )
			.applySkin( RoundView.skin )
			.string_( speakerConf.size )
			.align_( \center )
			.resize_( 7 );
		numArraysDec = SmoothButton( composite, 14@14 )
			.label_( '+' )
			.action_({ 
				var count = speakerConf.speakerCount;
				speakerConf.addArray; 
				speakerConf.setSpeakerCount( count, speakersUnits.value );
				speakerConf.init;
			})
			.resize_( 7 );
			
		StaticText( composite, 82@14 )
			.applySkin( RoundView.skin )
			.string_( "orientation" )
			.align_( \right )
			.resize_( 7 );
			
		slideInc = SmoothButton( composite, 14@14 )
			.label_( 'back' )
			.action_({ speakerConf.arrayConfs = speakerConf.arrayConfs.rotate(1) })
			.resize_( 7 );
		slideDec = SmoothButton( composite, 14@14 )
			.label_( 'play' )
			.action_({ speakerConf.arrayConfs = speakerConf.arrayConfs.rotate(-1) })
			.resize_( 7 );
		
		rotateSlider = EZSmoothSlider( composite, composite.bounds.width@14, "rotate", 
			[1,-1,\lin,0.01,0,"pi"].asSpec, 
			{ |sl| 
				var selected = this.selected;
				if( selected.size > 0 ) {
					speakerConf.arrayConfs[selected].do( _.rotate(  (sl.value - rotateVal) * pi ) );
					speakerConf.init;
				} {
					speakerConf.rotate( (sl.value - rotateVal) * pi );
				};
				rotateVal = sl.value;
			}, labelWidth: 50, unitWidth: 30
		).value_(0);
			
		scaleSlider = EZSmoothSlider( composite, composite.bounds.width@14, "scale", 
			[0.25,4,\exp, 0.01,0, "x"].asSpec, 
			{	 |sl| 
				var selected = this.selected;
				var scaleAmt;
				scaleAmt = sl.value / scaleVal;
				
				if( selected.size == 0 ) { selected = (..speakerConf.arrayConfs.size-1) };
				
				speakerConf.arrayConfs[selected].do({ |item|
					item.dist = item.dist * scaleAmt;
				});
				
				speakerConf.init;
				
				scaleVal = sl.value;
			}, unitWidth: 30
		).value_(1);

		presetManagerGUI = PresetManagerGUI( 
			composite, 
			nil,
			WFSSpeakerConf.presetManager, 
			speakerConf 
		);
		
		rotateSlider.labelWidth = 50;
		rotateSlider.labelView.align = \left;
		scaleSlider.labelWidth = 50;
		scaleSlider.labelView.align = \left;
		rotateSlider.view.resize_( 7 );
		scaleSlider.view.resize_( 7 );
		presetManagerGUI.resize_( 7 );
		
		RoundView.popSkin;
		
		controller.put( \arrayConfs, { 
			this.resetScale;
			this.resetRotate;
			this.makeArrayConfGUIs; 
		}); 
		
		controller.put( \init, { 
			speakerCount.value = speakerConf.speakerCount;
			speakerCount.clipLo = WFSArrayConfGUI.specs.n.step * speakerConf.size;
			numArraysBox.string = speakerConf.size;
			gain.value = speakerConf.gain;
			arrayLimit.value = speakerConf.arrayLimit;
			focusWidth.value = speakerConf.focusWidth/pi;
		}); 
	}
	
	resetScale { scaleVal = 1; scaleSlider.value = 1; }
	resetRotate { rotateVal = 0; rotateSlider.value = 0; }

	makeArrayConfGUIs { 
		
		var letters;
		letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		
		RoundView.pushSkin( UChainGUI.skin );
		
		arrayConfGUIs.do(_.remove);
		scrollView.decorator.reset;
		arrayConfGUIs = speakerConf.arrayConfs.collect({ |conf, i|
			conf.gui(scrollView, nil, letters[i].asString)
				.action_({
					action.value( this );
					this.resetScale;
					this.resetRotate;
					speakerConf.init;
				})
		});
		
		RoundView.popSkin;
	}
	
	resize_ { |val| composite.resize_( val ) }
	resize { ^composite.resize }
}