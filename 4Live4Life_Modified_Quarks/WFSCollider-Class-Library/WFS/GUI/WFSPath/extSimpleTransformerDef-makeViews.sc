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

+ SimpleTransformerDef {
	
	makeViews { |parent, bounds, f|
		var res;
		RoundView.useWithSkin( ( 	
				font: Font( Font.defaultSansFace, 10 ),
				labelWidth: 65
		) ++ (RoundView.skin ? ()), {
				if( makeViewsFunc.notNil ) {
					res = makeViewsFunc.value( parent, bounds, f )
				} {
					res = this.prMakeViews( parent, bounds, f );
				};
				postMakeViewsFunc.value( f, res );
			 }
		);
		^res;
	}
	
	viewNumLines {
		^this.specs.collect({|spec|
			if( spec.isNil ) {
				1
			} {
				spec.viewNumLines
			};
		}).sum;
	}
	
	getHeight { |margin, gap|
		viewHeight = viewHeight ? 14;
		margin = margin ?? {0@0};
		gap = gap ?? {4@4};
		^(margin.y * 2) + ( this.viewNumLines * (viewHeight + gap.y) ) - gap.y;
	}
		
	
	prMakeViews { |parent, bounds, f|
		var views, controller, composite;
		var margin = 0@2, gap = 0@0;
		
		if( parent.isNil ) {
			bounds = bounds ?? { 160 @ this.getHeight( margin, 0@2 ) };
		} {
			bounds = bounds ?? { parent.asView.bounds.insetBy(4,4) };
			bounds.height = this.getHeight( margin, 0@2 );
		};
		
		controller = SimpleController( f );
		
		composite = EZCompositeView( parent, bounds, true, margin, gap ).resize_(2);
		bounds = composite.view.bounds;
		composite.onClose = {
			controller.remove
		 };
		
		views = this.prMakeArgViews( f, composite, controller ); // returns a dict
		
		if( views.size == 0 ) {
			controller.remove;
		};
		
		views[ \composite ] = composite;
		
		^views;
	}
	
	prMakeArgViews { |f, composite, controller|
		var views;
		
		views = ();
		
		f.args.pairsDo({ |key, value, i|
			var vw, spec;
			
			spec = f.getSpec( key );
			
			vw = ObjectView( composite, nil, f, key, spec, controller );
				
			vw.action = { f.action.value( f, key, value ); };
				
			views[ key ] = vw;
		
		});
		
		^views;
	}
}


+ SimpleTransformer {
	
	viewNumLines { ^this.def.viewNumLines }
	
	makeViews { |parent, bounds|
		^this.def.makeViews( parent, bounds, this );
	}
}