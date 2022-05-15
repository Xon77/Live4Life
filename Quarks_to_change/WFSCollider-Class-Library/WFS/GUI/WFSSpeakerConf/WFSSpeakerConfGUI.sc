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

WFSSpeakerConfGUI {
	
	classvar <>current;
	classvar <>editWidth = 325;
	
	var <view, <editor, <editView;
	
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
	
	init { |parent, bounds, object|
		
		var ctrl;
		
		if( parent.isNil ) { 
			parent = this.class.asString;
			bounds = bounds ?? { Rect( 
					400 rrand: 450, 
					120 rrand: 150,
					737, 
					430
 				 ) 
			}; 
		} {
			bounds = parent.asView.bounds;
		};
		
		view = EZCompositeView( parent, bounds, gap: 2@2, margin: 2@2 );
		view.resize_(5);
		bounds = view.asView.bounds;
		view.addFlowLayout(0@0, 2@2);
		
		editor = WFSSpeakerConfEditor( view, editWidth @ bounds.height, object );
			
		editor.resize_(4);
		
		editView = WFSSpeakerConfView( view, 
			bounds.copy.width_( bounds.width - editWidth ), object );
		
		editView.resize_(5);
		
		editor.action = { |vw| editView.select( *editor.selected ) };
		
		ctrl = SimpleController( editView )
			.put( \select, { editor.select( *editView.selected ) });

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
		
	object { ^editor.object }
	
	object_ { |obj| 
		editor.object = obj;
		editView.object = obj; 
	 }
	
	doesNotUnderstand { |selector ...args|
		var res;
		res = editor.perform( selector, *args );
		if( res != editor ) { ^res; }
	}
	
}


+ WFSSpeakerConf {
	gui { |parent, bounds| ^WFSSpeakerConfGUI( parent, bounds, this ) }
}