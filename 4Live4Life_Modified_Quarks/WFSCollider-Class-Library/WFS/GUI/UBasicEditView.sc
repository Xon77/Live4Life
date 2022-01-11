/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Miguel Negrao, Wouter Snoei.

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

/*
These are basic editors for WFSPath2 and (WFS-)Points.
use classes:
	WFSPathView( parent, bounds, object ); // object: a WFSPath2
	WFSPathTimeView( parent, bounds, object );  // object: a WFSPath2
	WFSPointView( parent, bounds, object );  // object: a Point or Array of Points
	WFSPlaneView( parent, bounds, object );  // object: a Point or Array of Points
*/

UBasicEditView {
	
	var <object, <view;
	
	var <selected;
	
	var <>action, <>onClose;
	
	var <selectRect, <hitIndex, <moveHitPoint;
	var <prevMouseMode;
	var <hitPoint, <lastPoint, <optionOn = false;
	
	var <mouseMode = \select; // \select, \zoom, \move (move canvas)
	var <editMode = \move; // \move, \scale, \rotate, \rotateS, \none
	var mouseEdit = false, externalEdit = false;
	
	var <gridColor;
	
	var <>stepSize = 0.1;
	var <>round = 0;
	
	var <undoManager;
	
	var <>drawFunc; // draws on top
	
	var <mouseDownActions;
	
	*new { |parent, bounds, object|
		^this.newCopyArgs(object).init.makeView( parent, bounds ).setDefaults;
	}
	
	init { // subclass might want to init
	}
	
	setDefaults {
		object = object ?? { this.defaultObject };
	}
	
	setViewProperties {
	}
	
	makeView { |parent, bounds|
		
		view = ScaledUserView.withSliders( parent ?? { this.class.name.asString }, bounds, Rect(-100, -100, 200, 200 ) )
			.scaleSliderLength_( 40 )
			.sliderWidth_( 10 );
			
		view.mouseDownAction = { |vw, x,y, mod, oX, oY, isInside, bn, cc|
			mouseEdit = false;
			hitPoint = (x@y);
			lastPoint = hitPoint;
			hitIndex = this.getNearestIndex( hitPoint * (1@ -1), vw.pixelScale );
			
			this.performMouseDown( vw, x,y, ModKey( mod ), oX, oY, isInside, bn, cc );
		};
		
		view.mouseMoveAction = { |vw, x,y, mod, oX, oY|
			this.performMouseMove( vw, x, y, ModKey( mod ), oX, oY );
		};
		
		view.mouseUpAction = { |vw, x, y, mod, oX, oY|
			this.performMouseUp( vw, x, y, ModKey(mod), oX, oY );
		};
		
		view.keyDownAction = { |vw, char, mod, unicode, keycode|
			this.performKeyDown( vw, char, ModKey( mod ), unicode, keycode );
		};
		
		view.drawFunc = { |vw|	
			Pen.use({	
				Pen.color = Color.white.alpha_(0.4);
				Pen.width = vw.pixelScale.asArray.mean;
				Pen.line( -200 @ 0, 200 @ 0 );
				Pen.line( 0 @ -200, 0 @ 200 );
				Pen.stroke;
			});	
			this.prDrawContents( vw );
			Pen.use({ this.drawFunc.value( vw ); });
		};
			
		view.unscaledDrawFunc = { |vw|
			var rect;
			
			/// border
			if( vw.view.hasFocus ) { Pen.width = 3; } { Pen.width = 1 };
			Pen.color = Color.gray(0.2).alpha_(0.75);
			Pen.strokeRect( vw.drawBounds.insetBy(0.5,0.5) );
			
			//// selection
			if( selectRect.notNil ) { 
				Pen.width = 1;
				rect = selectRect.scale(1@(-1));
				rect = vw.translateScale(rect);
				switch( mouseMode,
					\select, {
					  //Pen.fillColor = selectColor.copy.alpha_(0.05); 
					  // Pen.strokeColor = selectColor.copy.alpha_(0.5); 
					  Pen.fillColor = Color.black.alpha_(0.05); 
					  Pen.strokeColor = Color.black.alpha_(0.25);
					  Pen.lineDash_( FloatArray[4, 4] );
					},
					\zoom, {
					  Pen.fillColor = Color.black.alpha_(0.05); 
					  Pen.strokeColor = Color.black.alpha_(0.25); 
					});
					
				Pen.addRect( rect ).fillStroke;
			};
		};	
		
		view.onClose = { onClose.value( this ) };
		
		this.setViewProperties;
		
		this.setDragHandlers;
	}
	
	performMouseDown { |vw, x,y, mod, oX, oY, isInside, bn, cc|
		var includes;
				
		includes = selected.asCollection.includes( hitIndex );
		
		if( bn == 1 ) { // always select with right button
			prevMouseMode = mouseMode;
			if( mouseMode == \select ) {
					this.mouseMode = \zoom;
			} {	
					this.mouseMode = \select;
			};
		}; 
		
		if( mod.alt && includes.not ) {
			prevMouseMode = prevMouseMode ? mouseMode;
			this.mouseMode = \move;
		};

		switch( mouseMode, 
			\select, {
				this.changed( \mouse_hit );
				if( cc == 2 ) { this.zoomToFit; };
				if( mod.shift ) { 
					if( hitIndex.notNil ) { 
						if( includes ) { 
							selected.remove( hitIndex ); 
							this.select( selected ); 
						} { 
							this.select( selected.add( hitIndex ) ); 
						}; 
					}; 
				} { 
					if( hitIndex.notNil ) { 
						if( includes.not ) { 
							this.select( hitIndex ) 
						};
					} { 
						this.select() 
					};
				};
			}, \move, {
				if( cc == 2 ) { vw.movePixels = [0,0]; }; // double click
				moveHitPoint = vw.movePixels.asPoint - (oX@oY);
				if( includes.not ) { hitIndex = nil };
			}, \zoom, {
				
				if( includes.not ) { hitIndex = nil };
				if( hitIndex.isNil ) {
					case { 
						mod.shift 
					} { 
						this.zoomIn; 
					} { 
						mod.ctrl 
					} {
						this.zoomOut;
					} { 
						cc == 2 	
					} { 
						this.zoomToFit;
					};
				};
			}, \record, {
				hitIndex = nil;
				this.edited( \start_record );
				selected = [];
				this.startRecord( (x@y) * (1 @ -1), true );
			});
			
		if( hitIndex.notNil ) { 
			this.changed( \mouse_down );
		};
		
		this.refresh;
	}
	
	performMouseMove { | vw, x, y, mod, oX, oY |
		var newPoint, pts, tms;
		
		newPoint = (x@y);
			
		if( mouseMode === \record ) {
			this.recordPoint( (x@y) * (1@ -1) );
			this.refresh;
		} {
			if( hitIndex.isNil ) {
				switch( mouseMode,
					\select, {	
						// move canvas if out of bounds
						if( vw.viewRect.contains( newPoint ).not ) {
							{ 
								view.viewRect =   // change to moving/not scaling later?
									view.viewRect.union( 
										Rect.fromPoints( newPoint, newPoint ) 
									).sect( vw.fromBounds ); 
							}.defer(0.5); // 0.4s delay 
						} {	
							  // no point hit -> change selection
							selectRect = Rect.fromPoints( hitPoint, newPoint )
								.scale(1@(-1));
							
							pts = this.getIndicesInRect( selectRect );
							
							if( mod.shift ) {
								this.addToSelection( pts );
							} { 
								this.selectNoUpdate(pts);
							}; 
						};
					}, \move, { 
						view.movePixels_( moveHitPoint + (oX@oY) ); 
					}, \zoom, {
						if( hitPoint.notNil ) { 
							newPoint = (x@y);	
							if( hitPoint.dist( newPoint ) > 1 ) { 
								selectRect = Rect.fromPoints( hitPoint, newPoint )
									.scale(1@(-1)); 
							} { 
								selectRect = nil 
							};
						};
					}, \record, {
						this.recordPoint( (x@y) * (1@ -1) );
						this.refresh;
					}
				)	
			} {
				 // selected point hit -> edit contents
				if( editMode != \none ) {	
					if( externalEdit ) {
						this.edited( \mouse_edit );
						externalEdit = false;
					};
					if( mod.option && { optionOn.not }) { 
						this.duplicateSelected;
						optionOn = true;
					};
					mouseEdit = true;
					this.mouseEditSelected( newPoint, mod );
				} {
					mouseEdit = false;
				};	
			};
		};
		
		lastPoint = newPoint;
	}
	
	performMouseUp { | vw, x, y, mod, oX, oY |
		if( mouseMode == \zoom ) { 
			 if( hitPoint.notNil ) { 
				 if( selectRect.notNil ) { 
					 this.zoomToRect( selectRect );
				};
			}; 
		};
		
		optionOn = false;
		
		if( mouseMode == \record ) { 
			this.endRecord;
		} {	
			if( mouseEdit ) { 
				mouseEdit = false;
				this.edited( \mouse_edit, editMode );
			};
			selectRect = nil;
			hitPoint = nil;
		};
		
		vw.refresh;
		
		if( prevMouseMode.notNil ) {
			this.mouseMode = prevMouseMode;
			prevMouseMode = nil;
		};
	}
	
	performKeyDown { | vw, char, mod, unicode, keycode |
		var dict;
		
		if( editMode != \none ) {	
			dict = (
				127: \backspace, 
				63234: \leftArrow, 
				63235: \rightArrow,
				63232: \upArrow, 
				63233: \downArrow
			);
			 
			switch( dict[ unicode ],
				\backspace, { 
					this.removeSelected;
				},
				\leftArrow, { 
					if( selected.size == 0 ) { this.select(\all) };
					this.moveSelected( stepSize.neg, 0, mod )
				},
				\rightArrow, { 
					if( selected.size == 0 ) { this.select(\all) };
					this.moveSelected( stepSize, 0, mod )
				},
				\upArrow, { 
					if( selected.size == 0 ) { this.select(\all) };
					this.moveSelected( 0, stepSize, mod )
				},
				\downArrow, { 
					if( selected.size == 0 ) { this.select(\all) };
					this.moveSelected( 0, stepSize.neg, mod ) 
				}
			);
		};
	}
	
	setDragHandlers { }
	
	refresh {
		if( view.notNil && { view.view.isClosed.not }) { 
			{ view.refresh }.defer;
		};
	}
	
	close { // close enclosing window
		view.view.getParents.last.findWindow.close;
	}
	
	front { // close enclosing window
		view.view.getParents.last.findWindow.front;
	}

	
	isClosed { ^view.view.isClosed }
		
	undoManager_ { |um, addFirstState = true|
		undoManager = um;
		if( addFirstState ) { this.edited( \new_object ); }; // force first undo state
	}
	
	handleUndo { |obj|
		if( obj.notNil ) {
			object.positions = obj.positions;
			object.forceTimes( obj.times );
			externalEdit = true;
			this.refresh;
			this.edited( \undo, \no_undo );
		};
	}
	
	undo { |numSteps = 1|
		if( undoManager.notNil ) {
			this.handleUndo( undoManager.undo( numSteps ) );
		};
	}
	
	edited { |what ... moreArgs| // creates undo state, calls action and changed
		if( undoManager.notNil ) {
			if( moreArgs.includes( \no_undo ).not ) { 
				undoManager.add( this.object, ([ what ] ++ moreArgs).join("_").asSymbol );
			};
		};
		action.value( this );
		this.changed( \edited, what, *moreArgs );
		this.changed( what, *moreArgs );		
	}
	
	zoomToFit { |includeCenter = true|
		if( includeCenter ) { 
			view.viewRect_( object.asRect.scale(1@(-1))
				.union( Rect(0,0,0,0) ).insetBy(-1,-1) );  
		} { 
			view.viewRect_( object.asRect.scale(1@(-1)).insetBy(-1,-1) ); 
		};
	}
	
	zoomToRect { |rect|
		rect = rect ?? { 
			object.asRect.union( Rect(0,0,0,0) ).insetBy(-1,-1) 
		};
		view.viewRect = rect.scale(1@(-1));
	}
	
	zoomIn { |amt|
		amt = amt ?? { 2.sqrt };
		view.scale = view.scale * amt;
	}
	
	zoomOut { |amt|
		amt = amt ?? { 2.sqrt };
		view.scale = view.scale / amt;
	}
	
	zoom { |level = 1|
		view.scale = level*10;
	}
	
	move { |x,y|
		x = x ? 0;
		y = y ? x;
		view.move_([x,y].linlin(-100,100,0,1));
	}
	
	moveToCenter { 
		view.move_([0.5,0.5]);
	}
	
	object_ { |newPath, active = true| 
			if( object !== newPath ) {
				object = newPath;
				this.refresh;
				if( active ) { 
					this.edited( \new_object ); 				} {
					this.changed( \new_object ); 
				};
			};
	}
	
	doAction { action.value( this ) }
	
	mouseMode_ { |newMode|
		newMode = newMode ? \select;
		if( mouseMode != newMode ) {
			mouseMode = newMode;
			this.changed( \mouseMode );
		};
	}
	
	editMode_ { |newMode|
		newMode = newMode ? \move;
		if( editMode != newMode ) {
			editMode = newMode;
			this.changed( \editMode );
		}
	}
	
	gridColor_ { |aColor|
		gridColor = aColor ?? { Color.white.alpha_(0.25) };
		view.gridColor = aColor;
	}
	
		addToSelection { |...indices|
		 this.select( *((selected ? []).asSet.addAll( indices ) ).asArray );
	}
	
	selectAll { this.select( \all ) }
	selectNone { this.select( ) }
	
	resize_ { |val| view.resize = val }
	resize { ^view.resize }
	
	// subclass responsibility
	
	prDrawContents { |vw|
		this.drawContents( vw.pixelScale );
	}
	drawContents { } 	
	defaultObject { ^nil }
	getNearestIndex { ^nil }
	getIndicesInRect { ^[] }
	select { }
	selectNoUpdate { }
}

