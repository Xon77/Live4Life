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

+ ArrayGeneratorDef {
	
	viewNumLines {
		^super.viewNumLines + 2;
	}
	
	prMakeArgViews { |f, composite, controller|
		var views, header, labelWidth = 65;
		var font;
		
		font = (RoundView.skin ?? { ( font: Font( Font.defaultSansFace, 10 ) ) }).font;
		
		views = ();
		
		labelWidth =(RoundView.skin ? ()).labelWidth ? labelWidth;
		
		views[ \label ] = PopUpMenu( composite, labelWidth @ viewHeight )
			.applySkin( RoundView.skin ? () )
			.font_( font.boldVariant )
			.items_( this.class.all.keys.as( Array ).select({ |key|
					this.class.all[ key ].class == this.class;
				}).sort
			)
			.action_({ |pu|
				f.defName = pu.item;
			});
		
		views[ \label ].value = views[ \label ].items.indexOf( f.defName );
			
		views[ \blend ] = EZSmoothSlider( composite, (composite.bounds.width - labelWidth - 2) @ viewHeight,
				nil, 
				[0,1,\lin], { |sl|
					f.blend = sl.value;
					f.action.value( f, \blend, sl.value ); 
				}, f.blend 
			);
		
		views[ \blend ].view.resize_(2);
			
		views[ \blend ].view.background_( Color.white.alpha_(0.25) );
		views[ \blend ].sliderView.background_( Color.clear );
			
		controller.put( \blend, { views[ \blend ].value = f.blend } );
		
		composite.decorator.nextLine;
		
		StaticText( composite, labelWidth @ viewHeight )
			.applySkin( RoundView.skin ? () )
			.string_( "mode" )
			.align_( \right );
		views[ \mode ] = PopUpMenu( composite, 
				(composite.bounds.width - labelWidth - 4) @ viewHeight )
			.items_([ 'bypass', 'replace', 'lin_xfade', '+', '-', '*', 'min', 'max' ])
			.applySkin( RoundView.skin ? () )
			.action_({ |pu|
				f.mode = pu.item;
				f.action.value( f, \mode, pu.item );
			})
			.resize_(2);
		controller.put( \mode, { 
			{ views[ \mode ].value = views[ \mode ].items.indexOf( 
				f.mode 
			); }.defer;
		});
		
		f.changed( \mode );
		
		f.args.pairsDo({ |key, value, i|
			var vw, spec;
			
			spec = f.getSpec( key );
			
			vw = ObjectView( composite, nil, f, key, spec, controller );
				
			vw.action = { f.action.value( f, key, value ); };
				
			views[ key ] = vw;
		});
		
		views[ \composite ] = composite;
		
		^views;
	}

}