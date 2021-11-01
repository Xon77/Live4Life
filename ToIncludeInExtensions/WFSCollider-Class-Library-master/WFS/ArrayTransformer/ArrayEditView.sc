ArrayEditView : UBasicEditView {
	
	var <>canChangeAmount = true;
	var <spec;
	var <objectBackup, <lineIndices, <lineStartEnd, <lastDrawIndex;
	var <>transformers;
	
	// object is an array of points
	
	*new { |parent, bounds, object, spec|
		^this.newCopyArgs(object).init.makeView( parent, bounds ).setDefaults( spec );
	}

	defaultObject	{ ^(0,0.1..1)	}
	defaultSpec { ^ControlSpec(0,1); }
	defaultTransformers { 
		ArrayTransformerDef.loadOnceFromDefaultDirectory;
		^[ ArrayTransformer( \clip ) ];
	}
	
	setDefaults { |inSpec|
		object = object ?? { this.defaultObject };
		spec = (inSpec ?? spec ?? { this.defaultSpec }).asSpec;
		transformers = this.defaultTransformers;
		transformers.do(_.spec_(spec))
	}
	
	setViewProperties {
		view
			.keepRatio_(false)
			.gridLines_([0,0])
			.maxZoom_(8)
			.scale_([1,1])
			.move_([0.5,0.5])
	}	
	
	applyTransformers {
		var out;
		out = object;
		transformers.do({ |item| out = item.value( out ) });
		^out;
	}
	
	value { ^spec.map( this.applyTransformers( object ) ) }
	
	value_ { |inArray| 
		transformers.do(_.reset);
		this.object = spec.unmap( inArray ); 
	}
	
	spec_ { |newSpec|
		spec = newSpec.asSpec;
		view.refresh;
	}
	
	mouseEditSelected { |newPoint, mod|
		var pt;
		// returns true if edited
		if( mod.isKindOf( ModKey ).not ) {
			mod = ModKey( mod ? 0);
		};
		switch( editMode,
			\move,  { 
				pt = newPoint.round(round) - lastPoint.round(round);
				this.moveSelected( pt.x, pt.y, mod, \no_undo );
			},
			\scale, { 
				pt = [ lastPoint.round(round).abs.max(0.001) * 
						lastPoint.asArray.collect({ |item|
							(item > 0).binaryValue.linlin(0,1,-1,1)
						}).asPoint,
					  newPoint.round(round).abs.max(0.001) * 
						newPoint.asArray.collect({ |item|
							(item > 0).binaryValue.linlin(0,1,-1,1)
						}).asPoint
				]; // prevent inf/nan
				pt = pt[1] / pt[0];
				this.scaleSelected( pt.x, pt.y, mod, \no_undo ); 
			},
			\elastic, {
				pt = newPoint.round(round) - lastPoint.round(round);
				this.moveElastic( pt.x, pt.y, mod, \no_undo );
			},
			\sine, {
				pt = newPoint.round(round) - lastPoint.round(round);
				this.moveSine( pt.x, pt.y, mod, \no_undo );
			},
		);
	}
	
	performMouseDown { |vw, x,y, mod, oX, oY, isInside, bn, cc|
		switch( mouseMode,
			\line, {
				objectBackup = this.object.copy;
				lineIndices = [ x.floor.clip(0, this.object.size-1) ];
				lineStartEnd = [ y, y ];
				this.prSetLine( lineIndices, lineStartEnd );
				this.edited( \mouse_edit, mouseMode, \no_undo );
			},
			\draw, {
				lastDrawIndex = x.floor.clip(0, this.object.size-1);
				this.object[ lastDrawIndex ] = y;
				this.refresh;
				this.edited( \mouse_edit, mouseMode, \no_undo );
			},
			{
				super.performMouseDown( vw, x,y, mod, oX, oY, isInside, bn, cc );
			}
		);
	}
	
	performMouseMove { | vw, x, y, mod, oX, oY |
		var newIndex, changed = false;
		switch( mouseMode,
			\line, {
				newIndex = x.floor.clip(0, this.object.size-1);
				lineIndices = ( lineIndices[0] .. newIndex );
				if( lineIndices[0] == newIndex ) {
					lineStartEnd[0] = y;
				};
				lineStartEnd[1] = y;
				this.prSetLine( lineIndices, lineStartEnd );
				this.refresh;
				this.edited( \mouse_edit, mouseMode, \no_undo );
			},
			\draw, {
				newIndex = x.floor.clip(0, this.object.size-1);
				if( selected.size > 0 ) {
					if( lastDrawIndex == newIndex && { selected.includes( newIndex.asInteger ) } ) {
						this.object[ lastDrawIndex ] = y;
						changed = true;
					} {	
						(lastDrawIndex..newIndex).do({ |item, i|
							if( selected.includes( item.asInteger ) ) {
								this.object[item] = this.object[lastDrawIndex]
									.blend( y, i/((newIndex - lastDrawIndex).abs).max(1) );
								changed = true;
							};
						});
						lastDrawIndex = newIndex;
					};
				} {	
					if( lastDrawIndex == newIndex ) {
						this.object[ lastDrawIndex ] = y;
					} {	
						(lastDrawIndex..newIndex).do({ |item, i|
							this.object[item] = this.object[lastDrawIndex]
								.blend( y, i/((newIndex - lastDrawIndex).abs).max(1) );
						});
						lastDrawIndex = newIndex;
					};
					changed = true;
				};
				if( changed ) {
					this.refresh;
					this.edited( \mouse_edit, mouseMode, \no_undo );
				};
			},
			{
				super.performMouseMove( vw, x, y, mod, oX, oY );
			}
		);
	}
	
	performMouseUp { | vw, x, y, mod, oX, oY |
		switch( mouseMode,
			\line, {
				lineIndices = nil;
				objectBackup = nil;
				this.edited( \mouse_edit, mouseMode );
				hitPoint = nil;
			},
			\draw, {
				lastDrawIndex = nil;
				this.edited( \mouse_edit, mouseMode );
			},
			{
				super.performMouseUp( vw, x, y, mod, oX, oY );
			}
		);
	}
	
	prSetLine { |indices, startEnd|
		var newObject = objectBackup.copy;
		if( selected.size > 0 ) {
			indices.do({ |index, i|
				if( selected.includes( index.asInteger ) ) {
					newObject[index] = startEnd[0].blend( startEnd[1], i/(indices.size-1).max(1) );
				};
			});
		} {	
			indices.do({ |index, i|
				newObject[index] = startEnd[0].blend( startEnd[1], i/(indices.size-1).max(1) )
			});
		};
		this.object.do({ |item,i| this.object[i] = newObject[i]; });
		this.refresh;
	}
	
	setDragHandlers {
		view.view
			.beginDragAction_({ spec.map( object ) })
			.canReceiveDragHandler_({ |vw|
				var drg = View.currentDrag;
				if( drg.isString ) {
					drg = { drg.interpret }.try;
				};
				case { drg.isArray } {
					true
				} {
					false;
				};
			})
			.receiveDragHandler_({ |vw|
				var drg = View.currentDrag;
				if( drg.isString ) {
					drg = drg.interpret;
				};
				if { drg.isKindOf( Array ) } {
					this.object = spec.unmap( drg );
					this.edited( \drag_dropped_points );
				};
			});
	 }
	
	drawContents { |scale = 1|
		var points, controls;
		var selectColor = Color.yellow;
		var spc;
		var size;
		var mean, median, center;
		var ud;
		
		spc = spec ? this.defaultSpec;
		ud = spec.unmap( spec.default );
		
		size = this.object.size;
		
		view.fromBounds = Rect( 0, 1.1 ,size, -1.2 );
		
		Pen.use({	
			
			points = this.points.asCollection.collect(_.asPoint);
			
			mean = object.mean;
			
			Pen.color = Color.gray(0.5,0.5);
			
			[ 0@0, "%", 0@1, "%", 0@ud, "%", 
				20@(object.minItem), "min: %",
				90@(object.maxItem), "max: %",
				160@mean, "mean: %",
				250@(object.median), "median: %",
				340@([object.minItem, object.maxItem].mean), "center: %",
			]
				.pairsDo({ |pos, name|
					Pen.fillRect( 
						Rect( 0, pos.y-(0.5 * scale.y), size, scale.y );
					);
					Pen.use({
						Pen.translate( view.viewRect.left, pos.y );
							Pen.scale( *(scale.asArray) );
							Pen.stringAtPoint( name.format( spec.map( pos.y ).round(0.001) ), 
								(pos.x + 5) @ -13 );
					});
				});
			
			Pen.color = Color.blue(0.5,0.33);
			points.do({ |item|
					Pen.addRect( 
						Rect( item.x-0.5, ud, 1, item.y - ud );
					);
			});
			Pen.fill;	
		
			Pen.color = Color.blue(0.5,0.75);
			Pen.width = 1;
			points.do({ |item, i|
				Pen.use({
					Pen.translate( *item.asArray );
					Pen.scale( *(scale.asArray) );
					Pen.addOval( Rect.aboutPoint( 0@0, 5, 5 ) );
					Pen.stroke;
				});
			});	
			
			if( lineIndices.notNil ) {
				Pen.color = Color.gray(0.33,0.33);
				Pen.width = 0.01;
				Pen.line( 
					(lineIndices[0] + 0.5) @ lineStartEnd[0], 
					(lineIndices.last + 0.5) @ lineStartEnd[1] 
				);
				Pen.stroke;
			};
		
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					//Pen.width = scale;
					Pen.color = selectColor;
					selected.do({ |item|
						Pen.addOval( 
							Rect.aboutPoint( points[item], scale.x * 4, scale.y * 4 ) 
						);
					});
					
					Pen.fill;
				};
			});			
		});
		
	}
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var radius, rect;
		point = point * (1 @ -1);
		rect = Rect.aboutPoint( point, scaler.x.abs * 5, scaler.y.abs * 5 );
		^this.points.detectIndex({ |pt, i|
			rect.contains( pt.asPoint );
		});
	}
	
	getIndicesInRect { |rect|
		var pts = [];
		rect = rect.scale(1@(-1));
		this.points.do({ |pt, i|
			if( rect.contains( pt.asPoint ) ) { pts = pts.add(i) };
		});
		^pts;					
	}
	
	handleUndo { |obj|
		if( obj.notNil ) {
			object = obj;
			externalEdit = true;
			this.refresh;
			this.edited( \undo, \no_undo );
		};
	}
	
	// general methods
	
	point_ { |point| this.object = (object ? [0]).asCollection[0] = point.asPoint }
	point { ^this.points[0] }
	
	points_ { |points|
		if( points.isKindOf( WFSPointGroup ) ) {
			points = points.positions.deepCopy;
		} {
			points = points.asCollection.collect(_.asPoint);
		};
		points = points.sort({ |a,b| a.x <= b.x }).collect(_.y);
		if( canChangeAmount ) {
			this.object = points;
		} {
			this.object = this.object.collect({ |item, i|
				points[i] ?? { object[i] };
			});
		};
	}
	
	points {
		^this.value.collect({ |item, i|
			(i+0.5) @ ( spec.unmap( item ) );
		})
	}
	
	at { |index| ^this.object[index] }
	
	zoomToFit { |includeCenter = true|
		view.scale = [1,1];
		view.move = [0.5,0.5];
		//view.viewRect = 
	}
	
	zoomToRect { |rect|
		rect = rect ?? { 
			object.asRect.union( Rect(0,0,0,0) ).insetBy(-1,-1) 
		};
		view.viewRect = rect.scale( 1@ -1);
	}
		
	// changing the object
	
	moveSelected { |x = 0,y = 0, mod ...moreArgs|
		if( selected.size > 0 ) {
			if( mod.ctrl && { selected.size == 1 } ) {
				selected.do({ |index|
					this.object[index] = this.object[index] + y;
				});
			} {
				selected.do({ |index|
					this.object[index] = this.object[index] + y;
				});
			};
			this.refresh; 
			this.edited( \edit, \move, *moreArgs  );
		};
	}
	
	moveElastic { |x = 0,y = 0, mod ...moreArgs|
		var index, next, start, middle, end;
		index = hitIndex ? selected[0];
		
		if( index.notNil ) {
			middle = [ index ];
			next = selected.detect({ |item| item == (index + 1) });
			while { next.notNil } {
				middle = middle ++ [ next ];
				next = selected.detect({ |item| item == (next + 1) });
			};
			next = selected.detect({ |item| item == (index - 1) });
			while { next.notNil } {
				middle = [ next ] ++ middle;
				next = selected.detect({ |item| item == (next - 1) });
			};
			start = (selected.select({ |item| item < middle[0] }).sort.last ? 0..(middle[0]-1));
			end = ((selected.select({ |item| item > middle.last }).sort.first 
				?? {this.object.size-1})..(middle.last+1));
				
			[ start, end ].do({ |item|
				var size; 
				size = item.size;
				item[1..].do({ |index, i|
					var val, factor;
					val = this.object[ index ];
					if( val.notNil ) {
						factor = (i+1)/size;
						val = val + (y * factor);
						this.object[ index ] = val;
					};
				});	
	
			});
			
			middle.do({ |index|
				this.object[ index ] = this.object[ index ] + y;
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveSine { |x = 0,y = 0, mod ...moreArgs|
		var selection;
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			selection.do({ |index|
				var pt;
				this.object[ index ] = this.object[index] + y;
			});
			
			2.do({ |ii|
				var rest, restSize;
				if( ii == 0 ) {
					rest = (..selection[0]);
				} {
					rest = (selection.last..this.points.size-1).reverse;
				};
				rest = rest[..rest.size-2];
				restSize = rest.size;
				rest.do({ |index, i|
					var val, factor;
					val = this.object[ index ];
					if( val.notNil ) {
						factor = i.linlin(0,restSize,-0.5pi, 0.5pi).sin.linlin(-1,1,0,1);
						val = val + (y * factor);
						this.object[ index ] = val;
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	scaleSelected { |x = 1, y, mod ...moreArgs|
		var d;
		d = spec.unmap( spec.default );
		y = y ? x;
		if( hitPoint.y < d ) { y = 1/y };
		if( selected.size > 0 ) {
			selected.do({ |index|
				this.object[index] = ((this.object[index] - d) * y) + d;
			});
			this.refresh;
			this.edited( \edit, \scale, *moreArgs );
		};
	}
	
	duplicateSelected { 
	}
	
	removeSelected {
	}
	
	// selection
	
	select { |...indices|
		if( indices[0] === \all ) { 
			indices = this.points.asCollection.collect({ |item, i| i }).flat; 
		} { 
			indices = indices.flat;
		};
		if( selected != indices ) {
			selected = indices; 
			this.refresh;
			this.changed( \select );
		};
	}
	
	selectNoUpdate { |...index|
		if( index[0] === \all ) { 
			index = this.points.asCollection.collect({ |item, i| i }).flat 
		} {
			index = index.flat;
		};
		if( selected != index ) {
			selected = index;
			this.changed( \select ); 
		};
	}
}

