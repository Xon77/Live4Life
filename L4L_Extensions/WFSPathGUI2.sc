/*
    Adapted from GameOfLife WFSCollider.
    It is just a small change, commenting the lines 220 and 223 of the original file WFSPathGUI.sc, to avoid an error in the post window by closing the trajectory editor in L4L project.

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

WFSPathGUI2 {

	classvar <>current;

	var <view, <pathView, <editView;
	var <generatorView;
	var <editWidth = 210;
	var <>action;
	var <>onClose;


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

		editView = WFSPathTransformerView( view, editWidth @ bounds.height, object );

		editView.resize_(3);

		editView.duplicateAction_({ |ev|
			if( ev.object.isKindOf( WFSPathURL ) ) {
				WFSPathGUI( object: ev.object.wfsPath.deepCopy )
			} {
				WFSPathGUI( object: ev.object.deepCopy )
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
			generatorView !? { generatorView.object = pathView.object };
			action.value(this);
		};

		view.view.decorator.shift(editWidth.neg + 67, editView.view.bounds.height );

		SmoothButton( view, 82 @ 14 )
			.radius_( 2 )
			.border_( 1 )
			.label_( "generate" )
			.font_( Font( Font.defaultSansFace, 10 ) )
			.resize_( 3 )
			.action_({
				this.openGeneratorView;
			});

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

		view.onClose = view.onClose.addFunc( {
			ctrl.remove; ctrl2.remove; ctrl3.remove;
			if( current == this ) {
				current = nil;
				this.class.changed( \current );
			};
			onClose.value( this );
		} );

	}

	openGeneratorView2 { |parent, bounds|
		var ctrl, ctrl2, ctrl3;
		var myWindow, closeFunc;
		var generatorWindow;

		if( generatorView.isNil or: { generatorView.view.isClosed } ) {
			if( bounds.isNil ) {
				myWindow = view.findWindow;
				bounds = Rect(
					myWindow.bounds.right + 4,
					myWindow.bounds.top,
					editWidth + 8,
					myWindow.bounds.height - 24
				);
			};

			generatorView = WFSPathGeneratorView(
				parent,
				bounds,
				pathView.object,
				[ \circle, \random, \line ]
			);

			generatorView.action = { |ev, what|
				pathView.refresh;
				editView.object = pathView.object;
				action.value(this);
			};

			generatorView.duplicateAction_({ |ev|
				if( ev.object.isKindOf( WFSPathURL ) ) {
					WFSPathGUI( object: ev.object.wfsPath.deepCopy )
				} {
					WFSPathGUI( object: ev.object.deepCopy )
				};
			});


			ctrl = SimpleController( pathView.xyView )
				.put( \select, { generatorView.selected = pathView.selected })
				.put( \mouse_hit, {
					generatorView.apply( true )
				})
				.put( \edited, { |obj, what ...moreArgs|
					if( moreArgs.includes( \no_undo ).not ) {
						generatorView.object = pathView.object;
					};
				})
				.put( \undo, {
					generatorView.object = pathView.object;
				});

			ctrl2 =  SimpleController( pathView.timeView )
				.put( \edited, { |obj, what ...moreArgs|
					if( moreArgs.includes( \no_undo ).not ) {
						generatorView.object = pathView.object;
					};
				})
				.put( \undo, {
					generatorView.object = pathView.object;
				});

			ctrl3 = SimpleController( generatorView )
				.put( \apply, { pathView.edited( \generated ); } );

			closeFunc = {
				generatorView !? { generatorView.view.findWindow.close };
				generatorView = nil;
			};

			generatorView.onClose_({
				ctrl.remove; ctrl2.remove; ctrl3.remove;
				// view.onClose.removeFunc( closeFunc );
			});

			// view.onClose = view.onClose.addFunc( closeFunc );
		} {
			generatorView.view.front;
		};
		^generatorView
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


+ WFSPath2 {
	gui { |parent, bounds| ^WFSPathGUI2( parent, bounds, this ) }
}

+ WFSPathURL {
	gui { |parent, bounds| ^WFSPathGUI2( parent, bounds, this.wfsPath ) }
}
