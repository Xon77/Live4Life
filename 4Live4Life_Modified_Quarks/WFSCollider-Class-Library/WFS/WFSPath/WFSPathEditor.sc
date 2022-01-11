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

WFSPathEditor {
	
	classvar <>current;
	
	var <view, <pathView, <editView;
	var <editWidth = 177;
	var <>action;
	
	
	*new { |parent, bounds, object, addUndoManager = true|
		^super.new.init( parent, bounds, object, addUndoManager )
	}
	
	init { |parent, bounds, object, addUndoManager|
		
		var ctrl, ctrl2, ctrl3;
		
		if( parent.isNil ) { 
			parent = this.class.asString;
			bounds = bounds ?? { Rect( 
					190 rrand: 220, 
					70 rrand: 100,
				 	(420 + (editWidth + 4)), 
				 	516 
				 ) 
			}; 
		} {
			bounds = parent.asView.bounds;
		};
		
		view = EZCompositeView( parent, bounds, gap: 2@2, margin: 2@2 );
		view.resize_(5);
		bounds = view.asView.bounds;
		view.addFlowLayout(0@0, 2@2);
		
		object = object.asWFSPath2;
		
		pathView = WFSPathView( view, 
			bounds.copy.width_( bounds.width - (editWidth + 4) ), object );
		
		view.view.decorator.shift(0,14);
		
		editView = WFSPathEditView( view, editWidth @ bounds.height, object );
		
		editView.resize_(3);
		
		editView.duplicateAction_({ |ev| 
			if( ev.object.isKindOf( WFSPathURL ) ) {
				WFSPathEditor( object: ev.object.wfsPath.deepCopy ) 
			} {
				WFSPathEditor( object: ev.object.deepCopy ) 
			};
		});
		
		ctrl = SimpleController( pathView.xyView )
			.put( \select, { editView.selected = pathView.selected })
			.put( \mouse_hit, { 
				editView.apply( true )
			})
			.put( \edited, { |obj, what ...moreArgs|
				if( moreArgs.includes( \no_undo ).not ) {
					editView.object = pathView.object;
				};
			})
			.put( \undo, {
				editView.object = pathView.object;
			});
			
		ctrl2 =  SimpleController( pathView.timeView )
			.put( \edited, { |obj, what ...moreArgs|
				if( moreArgs.includes( \no_undo ).not ) {
					editView.object = pathView.object;
				};
			})
			.put( \undo, {
				editView.object = pathView.object;
			});
			
		ctrl3 = SimpleController( editView )
			.put( \apply, { pathView.edited( \numerical_edit ); } );
		
		
		
		editView.action = { |ev, what|
			pathView.refresh;
			action.value(this);
		};
		
		pathView.action = { 
			action.value( this );
		};
		
		pathView.timeView.action = {
			action.value( this );
		};
		
		current = this;
		this.class.changed( \current );
		
		view.findWindow.toFrontAction = { 
			current = this;
			this.class.changed( \current );
		};
		
		view.onClose_( { 
			ctrl.remove; ctrl2.remove; ctrl3.remove; 
			if( current == this ) {
				current = nil;
				this.class.changed( \current );
			};
		} );
	
	}
	
	object { ^pathView.object }
	
	object_ { |obj| 
		pathView.object = obj;
		editView.object = obj; 
		pathView.refresh;
	 }
	
	doesNotUnderstand { |selector ...args|
		var res;
		res = pathView.perform( selector, *args );
		if( res != pathView ) { ^res; }
	}
	
}