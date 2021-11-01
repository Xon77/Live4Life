WFSPathBox {
	
	var <wfsPath;
	var <composite;
	var <view;
	var <>action;
	
	var <>editor;
	
	var <viewHeight = 14;
	
	*new { |parent, bounds, wfsPath|
		^this.newCopyArgs(wfsPath).makeView( parent, bounds );
	}
	
	doAction { action.value( this ) }
	
	value { ^wfsPath }
	value_ { |newWFSPath|
		if( wfsPath != newWFSPath ) {
			wfsPath.removeDependant( this );
			wfsPath = newWFSPath;
			wfsPath.addDependant( this );
			if( editor.notNil && { editor.isClosed.not }) {
				editor.object = wfsPath;
			};
		};
		this.update;
	}
	
	valueAction_ { |newWFSPath|
		this.value = newWFSPath;
		this.doAction;
	}
	
	wfsPath_ { |newWFSPath|
		this.value = newWFSPath;
	}
	
	update {
		if( wfsPath.notNil ) { this.setViews( wfsPath ) };
	}
	
	resize_ { |resize|
		view.resize = resize ? 5;
	}
	
	remove {
		if( wfsPath.notNil ) { 
			wfsPath.removeDependant( this );
		};
		if( editor.notNil ) {
			editor.close;
		};
	}
	
	openEditor {
		if( wfsPath.notNil ) { 
			if( editor.isNil or: { editor.isClosed } ) {
				editor = wfsPath.gui;
				editor.onClose = { editor = nil };
				editor.action = { |vw| 
					this.valueAction = editor.object 
				};
			} {
				editor.front;
			};
		};
		^editor;
	}
	
	setViews { |inWFSPath|
		var rect;
		if( wfsPath.isWFSPath2 && { (rect = wfsPath.asRect).notNil } ) {
			view.fromBounds = rect.scale(1@ -1).insetBy(-2,-2);
		} {
			view.fromBounds = Rect(0,0,20,20);
		};
		{ view.refresh; }.defer;
	}
	
	makeView { |parent, bounds, resize|
		
		if( bounds.isNil ) { bounds= 40 @ 40 };
		
		composite = EZCompositeView( parent, bounds, gap: 4@4 );
		bounds = composite.asView.bounds;
		composite.onClose_({ 
			this.remove; 
		}).resize_( resize ? 5 );
		
		view = ScaledUserView( composite, composite.bounds.moveTo(0,0) )
			.fromBounds_( Rect.aboutPoint( 0@0, 100, 100 ) )
			.keepRatio_( true )
			.background_( Color.gray(0.9) )
			.drawFunc_({ |vw|
				var path;
				path = this.wfsPath;
				if( path.isWFSPath2 && { path.exists } ) {
					
					Pen.width = 0.164;
					Pen.color = Color.red(0.5, 0.5);
					
					//// draw configuration
					(WFSSpeakerConf.default ?? {
						WFSSpeakerConf.rect(48,48,5,5);
					}).draw;
					
					path.asWFSPath2.draw( 1, pixelScale: vw.pixelScale * 1.5);
				} {
					Pen.font = Font( Font.defaultSansFace, 16 );
					Pen.color = Color.red(0.66);
					Pen.stringAtPoint( "?", 5@0 );
				};
			})
			.mouseDownAction_({ |vw, sx, sy, mod, x, y, isInside, bn, clickCount = 0|
				if( clickCount == 2 ) { this.openEditor };
			});
			
		view.view.canReceiveDragHandler_({ |sink|
				var drg;
				drg = View.currentDrag;
				case { drg.isKindOf( WFSPath2 ) } 
					{ true }
					{ drg.isKindOf( WFSPathURL ) }
					{ true }
					{ drg.isString } 
					{
						{ drg.interpret }.try !? { |obj|
							obj.isKindOf( WFSPath2 ) or: {
								obj.isKindOf( WFSPathURL )
							}
						} ? false;
					}
					 /*
					{ drg.isKindOf( WFSPathBuffer ) }
					{ true } */
					{ false }
			})
			.receiveDragHandler_({ |sink, x, y|
					var interpreted;
					case { View.currentDrag.isKindOf( WFSPath2 ) } {
						if( this.wfsPath != View.currentDrag ) {
							this.wfsPath = View.currentDrag.deepCopy;
						};
						this.doAction;
					} { View.currentDrag.isKindOf( WFSPathURL ) } {
						this.wfsPath = View.currentDrag;
						this.doAction;
					} { View.currentDrag.isString } {
						this.wfsPath = View.currentDrag.interpret;
						this.doAction;
					};
			})
			.beginDragAction_({ 
				this.wfsPath;
			});
			
		this.setViews( this.wfsPath );
	}
	
}