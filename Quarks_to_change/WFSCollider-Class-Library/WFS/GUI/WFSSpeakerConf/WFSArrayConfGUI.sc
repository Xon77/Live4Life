/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Wouter Snoei.

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

WFSArrayConfGUI {
	
	classvar <>specs;
	
	var <arrayConf, <label;
	
	var <parent, <composite, <views, <controller;
	var <viewHeight = 14, <labelWidth = 80;
	var <>action;
	var <selected = false;
	
	*initClass {
		specs = (
			n: IntegerSpec( 48, 8, 96 ).step_(8).alt_step_(1),
			center: WFSPlaneSpec( step: 0.1@0.1, mode: \polar ),
			offset: [-10, 10, \lin, 0.001, 0, " m"].asSpec,
			spWidth: [0.05,0.25,\lin, 0.001, 0.164, " m"].asSpec
		);
	}
	
	*new { |parent, bounds, arrayConf, label = ""|
		^super.newCopyArgs( arrayConf, label ).init( parent, bounds );
	}
	
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
			 4 * (viewHeight + gap.y) 
		) - gap.y;
	}
	
	makeViews { |bounds|
		var margin = 0@0, gap = 4@4;
		
		bounds = bounds ?? { parent.asView.bounds.insetBy(4,4) };
		bounds.height = this.class.getHeight( viewHeight, margin, gap );
		controller = SimpleController( arrayConf );
		
		composite = CompositeView( parent, bounds ).resize_(2);
		composite.addFlowLayout( margin, gap );
		composite.onClose = {
			controller.remove
		 };
		 
		 if( selected ) { 
			 composite.background = Color.yellow.alpha_(0.25); 
		 } {
			 composite.background = Color.white.alpha_(0.25); 
		 };
		
		views = ();
	
		views[ \select ] = SmoothButton( composite, viewHeight@viewHeight )
			.label_([ label, label ])
			.hiliteColor_( Color.yellow.alpha_(0.5) )
			.radius_(2)
			.canFocus_( false )
			.action_({ |bt| 
				this.selected = bt.value.booleanValue;
				action.value( this, \select );
			});
			
		composite.decorator.shift( (viewHeight + 4).neg, 0 );
		
		[ \n, \center, \offset, \spWidth ].do({ |key, i|
			var vw, spec;
			
			spec = specs[ key ];
						
			vw = ObjectView( composite, nil, arrayConf, key, spec, controller );
				
			vw.action = { action.value( this, key ); };
				
			views[ key ] = vw;
		});
	}
	
	remove { composite.remove; }
	
	select { |bool = true| this.selected = bool }
	
	selected_ { |bool = true|
		selected = bool;
		views[ \select ].value = selected.binaryValue;
		if( selected ) { 
			{ composite.background = Color.yellow.alpha_(0.25); }.defer;
		} {
			{ composite.background = Color.white.alpha_(0.25); }.defer;
		};
	}
	
	resize_ { |resize| composite.resize_(resize) }
	
	font_ { |font| views.values.do({ |vw| vw.font = font }); }
	viewHeight_ { |height = 16|
		views.values.do({ |vw| vw.view.bounds = vw.view.bounds.height_( height ) });
		composite.decorator.reFlow( composite );
	}
	labelWidth_ { |width=50|
		labelWidth = width;
		views.values.do(_.labelWidth_(width));
	}
	
	view { ^composite }
}

+ WFSArrayConf {
	gui { |parent, bounds, label| ^WFSArrayConfGUI( parent, bounds, this, label ) }
}