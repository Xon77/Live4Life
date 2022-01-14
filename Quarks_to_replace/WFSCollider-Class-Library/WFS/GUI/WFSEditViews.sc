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

WFSBasicEditView : UBasicEditView {
	
	var <>drawMode = 0; // 0: points+lines, 1: lines, 2: points, 3: none, 4: hi-res lines
	var <>showControls = false;
	
	var <gridColor;
	
	var <>stepSize = 0.1;
	var <>round = 0;
	
	*new { |parent, bounds, object|
		^this.newCopyArgs(object).init.makeView( parent, bounds ).setDefaults;
	}
	
	init { // subclass might want to init
	}
	
	setDefaults {
		object = object ?? { this.defaultObject };
	}
	
	setViewProperties {
		gridColor = gridColor ?? { Color.white.alpha_(0.25) };
		view
			.move_( [0.5,0.5] )
			.scale_( [10,10] )
			.maxZoom_( 40 )
			.keepRatio_( true )
			.resize_(5)
			.gridLines_( [ 200, 200 ] )
			.gridMode_( \lines )
			.gridColor_( gridColor );
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
	
	gridColor_ { |aColor|
		gridColor = aColor ?? { Color.white.alpha_(0.25) };
		view.gridColor = aColor;
	}
	
		addToSelection { |...indices|
		 this.select( *((selected ? []).asSet.addAll( indices ) ).asArray );
	}
	
	prDrawContents { |vw|
		Pen.use({
			Pen.color = Color.white.alpha_(0.4);
			Pen.width = vw.pixelScale.asArray.mean;
			Pen.line( -200 @ 0, 200 @ 0 );
			Pen.line( 0 @ -200, 0 @ 200 );
			Pen.stroke;
		});
	 	this.drawContents(  vw.pixelScale );
	}
}

//////// PATH EDITOR /////////////////////////////////////////////////////////////////

WFSPathXYView : WFSBasicEditView {
	
	var <pos; 
	var <recordLastTime;
	var <animationTask, <>animationRate = 1;
	var <showInfo = true;

	defaultObject	{ ^WFSPath2( { (8.0@8.0).rand2 } ! 7, [0.5] ); }	
	mouseEditSelected { |newPoint, mod|
		var pt;
		// returns true if changed
		if( mod.isKindOf( ModKey ).not ) {
			mod = ModKey( mod ? 0);
		};
		
		switch( editMode,
			\move,  { 
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
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
			\rotate, { 
				this.rotateSelected( 
					lastPoint.angle - newPoint.angle, 
					1, 
					mod,
					\no_undo
				);
			},
			\rotateS, { 
				this.rotateSelected( 
					lastPoint.theta - newPoint.theta, 
					newPoint.rho.max(0.001) / lastPoint.rho.max(0.001), 
					mod,
					\no_undo
				);
			},
			\elastic, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveElastic( pt.x, pt.y, mod, \no_undo );
			},
			\twirl, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveTwirl( pt.x, pt.y, mod, \no_undo );
			},
			\chain, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveChain( pt.x, pt.y, mod, \no_undo );
			}
		);
	}
	
	drawContents { |scale = 1|
		var points, controls;
		
		scale = scale.asArray;
		
		Pen.use({	
			
			Pen.width = 0.164;
			Pen.color = Color.red(0.5, 0.5);
				
			//// draw configuration
			(WFSSpeakerConf.default ?? {
				WFSSpeakerConf.rect(48,48,5,5);
			}).draw;
			
			if( showInfo && { object.positions.size > 0 }) {	
				Pen.use({
					var posx, posy, leftTop;
					Pen.font = Font( Font.defaultSansFace, 10 );
					Pen.color = Color.black;
					leftTop = this.view.viewRect.leftTop;
					Pen.translate( leftTop.x, leftTop.y );
					Pen.scale(*scale.maxItem.dup);
					case { selected.size == 0 } {
						posx = object.positions.collect(_.x);
						posy = object.positions.collect(_.y);
						Pen.stringAtPoint( 
							"% points, ( % to % )@( % to %)"
								.format( 
									object.positions.size, 
									posx.minItem.round(0.01),
									posx.maxItem.round(0.01),
									posy.minItem.round(0.01),
									posy.maxItem.round(0.01)
								),
							5@2
						);
					} { selected.size == 1 } {
						if( object.positions[ selected[0] ].notNil ) {
							Pen.stringAtPoint( 
								"point #% selected, % @ %"
									.format( 
										selected[0],
										object.positions[ selected[0] ].x.round(0.001),
										object.positions[ selected[0] ].y.round(0.001)
									), 
								5@2
							);
						};
					} {
						posx = object.positions[ selected ].select(_.notNil).collect(_.x);
						posy = object.positions[ selected ].select(_.notNil).collect(_.y);
						if( posx.size > 0 ) {
							Pen.stringAtPoint( 
								"% selected points, ( % to % ) @ ( % to % )"
									.format( 
										selected.size, 
										posx.minItem.round(0.01),
										posx.maxItem.round(0.01),
										posy.minItem.round(0.01),
										posy.maxItem.round(0.01)
									),
								5@2
							);
						};
						
					};
				});
			};
			
			if( object.positions.size > 0 ) {
				object.draw( drawMode, selected, pos, showControls, scale.asArray.mean );
			};
			
		});
		
	}
	
	setDragHandlers {
		view.view
			.beginDragAction_({ object })
			.canReceiveDragHandler_({ |vw|
				var drg = View.currentDrag;
				drg.isKindOf( WFSPath2 ) or: { 
					drg.isKindOf( WFSPathURL ) or: {	
						drg.isString && { 
							WFSPathURL.all.keys.includes( drg.asSymbol ) or: {
								{ drg.interpret }.try !? { |obj|
									obj.isKindOf( WFSPath2 ) or: {
										obj.isKindOf( WFSPathURL )
									}
								} ? false;
							};
						};
					};
				};
			})
			.receiveDragHandler_({ |vw|
				var obj;
				var drg = View.currentDrag;
				if( drg.isString ) {
					if( WFSPathURL.all.keys.includes( drg.asSymbol ) ) {
						obj = drg.asWFSPath2;
					} {
						obj = drg.interpret.asWFSPath2;
					};
				} {
					obj = drg.asWFSPath2.deepCopy;
				};
				this.object = obj;
			});
	 }
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var radius;
		radius = scaler.asArray.mean * 5;
		^object.positions.detectIndex({ |pt, i|
			pt.asPoint.dist( point ) <= radius
		});
	}
	
	getIndicesInRect { |rect|
		var pts = [];
		object.positions.do({ |pt, i|
			if( rect.contains( pt.asPoint ) ) { pts = pts.add(i) };
		});
		^pts;					
	}
	
	// general methods
	
	resize { ^view.resize }
	resize_ { |resize| view.resize = resize }
	
	path_ { |path| this.object = path }
	path { ^object }
	
	pos_ { |newPos, changed = true|
		pos = newPos;
		{ this.refresh; }.defer; // for animation
		if( changed ) { this.changed( \pos ); };
	}
	
	points { ^(object !? _.positions) ? [] }
	
	points_ { |points, edited = true|
		points = points.asCollection.collect(_.asPoint);
		if( this.object.isNil ) {
			this.object = WFSPath2( points );
		} {
			this.object.positions = points;
		};
		if( edited ) { 
			this.refresh;
			this.edited( \points );
		};
	}
	
	// changing the object
	
	moveSelected { |x = 0,y = 0, mod ...moreArgs|
		if( selected.size > 0 ) {
			if( mod.ctrl && { selected.size == 1 } ) {
				selected.do({ |index|
					var pt;
					pt = object.positions[ index ];
					if( pt.notNil ) {
						pt.x = (pt.x + x).round(0.1);
						pt.y = (pt.y + y).round(0.1);
					};
				});
			} {
				selected.do({ |index|
					var pt;
					pt = object.positions[ index ];
					if( pt.notNil ) {
						pt.x = pt.x + x;
						pt.y = pt.y + y;
					};
				});
			};
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveElastic { |x = 0,y = 0, mod ...moreArgs|
		var selection;
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			selection.do({ |index|
				var pt;
				pt = object.positions[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
			});
			
			2.do({ |ii|
				var rest, restSize;
				if( ii == 0 ) {
					rest = (..selection[0]);
				} {
					rest = (selection.last..object.positions.size-1).reverse;
				};
				rest = rest[..rest.size-2];
				restSize = rest.size;
				rest.do({ |index, i|
					var pt, factor;
					pt = object.positions[ index ];
					if( pt.notNil ) {
						factor = (i/restSize);
						pt.x = pt.x + (x * factor);
						pt.y = pt.y + (y * factor);
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveTwirl { |x = 0,y = 0, mod ...moreArgs|
		var selection, angles, rhos, firstPoint, lastPoint;
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			firstPoint = object.positions[selection[0]];
			lastPoint = object.positions[selection.last]; 
			
			angles = [ 
				(firstPoint + (x@y)).angle - firstPoint.angle,
				(lastPoint + (x@y)).angle - lastPoint.angle
			].wrap(-pi, pi);
			
			rhos = [ 
				(firstPoint + (x@y)).rho - firstPoint.rho,
				(lastPoint + (x@y)).rho - lastPoint.rho
			];
			
			selection.do({ |index|
				var pt;
				pt = object.positions[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
			});
			
			2.do({ |ii|
				var rest, restSize;
				if( ii == 0 ) {
					rest = (..selection[0]);
				} {
					rest = (selection.last..object.positions.size-1).reverse;
				};
				rest = rest[..rest.size-2];
				restSize = rest.size;
				rest.do({ |index, i|
					var pt, factor, newPoint;
					pt = object.positions[ index ];
					if( pt.notNil ) {
						factor = (i/restSize);
						newPoint = pt.asPolar;
						newPoint.theta = newPoint.theta + (angles[ii] * factor);
						newPoint.rho = (newPoint.rho + (rhos[ii] * factor)).abs;
						newPoint = newPoint.asPoint;
						pt.x = newPoint.x;
						pt.y = newPoint.y;
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveChain { |x = 0,y = 0, mod ...moreArgs|
		var selection, data;
		// keeps fixed distances between points
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			data = 2.collect({ |ii|
				var rest, restSize, distance;
				if( ii == 0 ) {
					rest = (..selection[0]).reverse;
				} {
					rest = (selection.last..object.positions.size-1);
				};
				
				distance = rest[1..].collect({ |item, i|
					object.positions[item].dist( object.positions[rest[i]] );
				});
				
				[ rest, distance ];
			});
			
			selection.do({ |index|
				var pt;
				pt = object.positions[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
			});
			
			data.do({ |data|
				var rest, distances;
				#rest, distances = data;
				rest[1..].do({ |index, i|
					var pt, polar;
					pt = object.positions[ index ];
					if( pt.notNil ) {
						polar = (pt - object.positions[rest[i]]).asPolar;
						polar.rho = distances[i];
						polar = polar.asPoint + object.positions[rest[i]];
						pt.x = polar.x;
						pt.y = polar.y;
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}

	scaleSelected { |x = 1, y, mod ...moreArgs|
		y = y ? x;
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt;
				pt = object.positions[ index ];
				if( pt.notNil ) {
					pt.x = pt.x * x;
					pt.y = pt.y * y;
				};
			});
			this.refresh;
			this.edited( \edit, \scale, *moreArgs );
		};
	}
	
	rotateSelected { |angle = 0, scale = 1, mod ...moreArgs|
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt, rpt;
				pt = object.positions[ index ];
				if( pt.notNil ) {
					rpt = pt.rotate( angle ) * scale;
					pt.x = rpt.x;
					pt.y = rpt.y;
				};
			});
			this.refresh;
			this.edited( \edit, \rotate, *moreArgs );
		};
	}
	
	duplicateSelected { 
		var points, times, index;
		if( selected.size >= 1 ) {
			selected = selected.sort;
			points = object.positions[ selected ].collect(_.copy);
			times = object.times[ selected ];
			index = selected.maxItem + 1;
			selected = object.insertMultiple( index, points, times );
			this.refresh;
			this.edited( \duplicateSelected );
		};
	}
	
	removeSelected {
		var times;
		times = object.times;
		selected.do({ |item, i|
			var addTime;
			addTime = times[ item ];
			if( addTime.notNil && (item != 0) ) {
				times[item-1] = times[item-1] + addTime;
			};
		});
		object.positions = object.positions.select({ |item, i|
			selected.includes(i).not;
		});
		object.forceTimes( 
			times.select({ |item, i|
				selected.includes(i).not;
			}).collect( _ ? 0.1 )
		);
		selected = [];
		this.refresh;
		this.edited( \removeSelected );
	}
	
	// selection
	
	select { |...indices|
		if( indices[0] === \all ) { 
			indices = object.positions.collect({ |item, i| i }).flat; 
		} { 
			indices = indices.flat.select(_.notNil);
		};
		if( selected != indices ) {
			selected = indices; 
			this.refresh;
			this.changed( \select );
		};
	}
	
	selectNoUpdate { |...index|
		if( index[0] === \all ) { 
			index = object.positions.collect({ |item, i| i }).flat 
		} {
			index = index.flat.select(_.notNil);
		};
		if( selected != index ) {
			selected = index;
			this.changed( \select ); 
		};
	}
	
	// animation
	
	animate { |bool = true, startAt|
		var res = 0.05;
		animationTask.stop;
		if( bool ) {
			this.pos = pos ? startAt ? 0;
			animationTask = Task({
				while { pos.inclusivelyBetween(0, object.duration) } {
					res.wait;
					this.pos = pos + (res * animationRate);
				};
				this.pos = nil;
				this.changed( \animate, false );
			}).start;
		} {
			this.pos = nil;
		};
		this.changed( \animate, bool );
	}
	
	
	
	// recording support
	
	startRecord { |point, clearPath = true, addTime = 0.1|
		recordLastTime = Process.elapsedTime;
		if( clearPath ) { 
			object.positions = [ point.asWFSPoint ];
			object.forceTimes([]);
		} {
			object.positions = object.positions ++ [ point.asWFSPoint ];
			object.forceTimes( object.times ++ [ addTime ] );
		};
	}
	
	recordPoint { |point| // adds point to end
		var newTime, delta;
		if( recordLastTime.notNil ) { // didn't start recording yet
			newTime = Process.elapsedTime;
			object.forceTimes( object.times ++ [ newTime - recordLastTime ] );
			object.positions = object.positions ++ [ point.asWFSPoint ];
			recordLastTime = newTime;
		} { 
			"%: didn't start recording yet\n".postf( thisMethod ); 
		};	
	}
			
	endRecord {
		recordLastTime = nil;
		this.edited( \endRecord );
		this.mouseMode = \select;
	}
}

//////// PATH TIMELINE EDITOR /////////////////////////////////////////////////////////////////

WFSPathTimeView : WFSPathXYView {
	
	setDefaults {
		object = object ?? { this.defaultObject };
		view.fromBounds_( Rect( 0, -0.5, 1, 1 ) )
			.gridLines_( [ inf, inf ] )
			.scale_( 1 )
			.moveVEnabled_( false )
			.scaleVEnabled_( false )
			.keepRatio_( false );
	}
	
	
	defaultObject	{ ^WFSPath2( { (8.0@8.0).rand2 } ! 7, [0.5] ); }

	drawContents { |scale = 1|
		var times, speeds, timesSum, meanSpeed;
		var drawPoint;
		var selectColor = Color.yellow;
		var pospt;
		var vlines;
		
		scale = scale.asPoint;
		
		drawPoint = { |point, r = 3, w = 1|
			Pen.addOval( 
				Rect.aboutPoint( point, scale.x * r, scale.y * r ) );
			Pen.addOval( 
				Rect.aboutPoint( point, scale.x * (r-(w/2)) , scale.y * (r-(w/2)) ) );
		};
		
		if( object.times.size > 0 ) {	
			timesSum = this.getTimesSum;
			times = ([ 0 ] ++ object.times.integrate) / timesSum;
			speeds = object.speeds;
			meanSpeed = (speeds * object.times).sum / timesSum;
			speeds = speeds ++ [0];
			
			if( timesSum <= 60 ) {
				vlines = timesSum.ceil.asInteger.collect({ |i| i / timesSum });
				Pen.color = Color.white.alpha_(0.75);
			} {
				vlines = (timesSum / 60).ceil.asInteger.collect({ |i| i / (timesSum / 60) });
				Pen.color = Color.black.alpha_(0.25);
			};
			
			Pen.width = scale.x;
			vlines.do({ |item|
				Pen.line( item @ -1, item @ 1 );
			});
			Pen.stroke;
			
			Pen.color = Color.blue(0.5).blend( Color.white, 0.25 ).alpha_(0.5);
			times.do({ |item, i|
				//Pen.color = Color.red(0.75).alpha_( (speeds[i] / 334).min(1) );
				Pen.addRect( 
					Rect( item, 0.5, times.clipAt(i+1) - item, speeds[i].explin(0.1,344,0,1).neg));
							
			});
			Pen.fill;	
						
			Pen.color = Color.gray(0.25); // line
			Pen.addRect(Rect( 0, 0 - (scale.y/4), times.last, scale.y/2 ) ).fill;
			
			Pen.strokeColor = Color.black.alpha_(0.5); 
			Pen.fillColor = Color.white; // start point
			Pen.addOval( Rect.aboutPoint( times[0]@0, 
				scale.x * 5, scale.y * 5 ) );		
			Pen.fillStroke;
				
			Pen.fillColor = Color.red(0.85); // end point
			Pen.addOval( Rect.aboutPoint( times.last@0, 
				scale.x * 5, scale.y * 5 ) );		
			Pen.fillStroke;
			
			Pen.color = selectColor; // selected points
			selected.do({ |item| 
				if( item < times.size ) {
					Pen.addOval( Rect.aboutPoint( times[item]@0, 
						scale.x * 3.5, scale.y * 3.5 ) );
				};
			});
			Pen.fill;
			
			if( pos.notNil ) {
				pospt = pos / timesSum;
				Pen.color = Color.black.alpha_(0.5);
				Pen.width = scale.x * 2;
				Pen.line( pospt @ -0.5, pospt @ 0.5 ).stroke;
			};
			
			Pen.color = Color.blue(0.5);
			times[1..times.size-2].do({ |item, i| drawPoint.( item@0 ); });
			Pen.draw(1);
			
			if( showInfo ) {	
				Pen.use({
					var tms, leftTop;
					Pen.font = Font( Font.defaultSansFace, 10 );
					Pen.color = Color.black;
					leftTop = this.view.viewRect.leftTop;
					Pen.translate( leftTop.x, leftTop.y );
					Pen.scale(scale.x,scale.y);
					case { selected.size == 0 } {
						Pen.stringAtPoint( 
							"% points, duration: %, avg speed: %m/s"
								.format( 
									object.positions.size, 
									timesSum.asSMPTEString(1000),
									meanSpeed.round(0.01) ),
							5@2
						);
					} { selected.size == 1 } {
						if( times[ selected[0] ].notNil ) {
							Pen.stringAtPoint( 
								"point #% selected, time: %"
									.format( 
										selected[0],
										(times[selected[0]] * timesSum).asSMPTEString(1000)									), 
								5@2
							);
						};
					} {
						tms = times[ selected ].select( _.notNil );
						if( tms.size > 0 ) {
							Pen.stringAtPoint( 
								"% selected points, % to % "
									.format( 
										selected.size, 
										(tms.minItem * timesSum).asSMPTEString(1000),
										(tms.maxItem * timesSum).asSMPTEString(1000)								),
								5@2
							); 
						};
						
					};
				});
			};
		};
	}
	
	zoomToFit { |includeCenter = true|
		view.scale = 1;
		view.move = 0.5;
	}
	
	zoomToRect { |rect|
		rect = (rect ?? { Rect( 0, -0.5, 1, 1 ) }).copy;
		rect.top = -0.5;
		rect.height = 1;
		view.viewRect = rect;
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
		view.scale = level;
	}
	
	move { |x,y|
		x = x ? 0;
		view.move_(x);
	}
	
	moveToCenter { 
		view.move_([0.5,0.5]);
	}
	
	getTimesSum { ^object.times.sum }
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var times, rect;
		times = (([ 0 ] ++ object.times.integrate) / this.getTimesSum);
		rect = Rect.aboutPoint( point, scaler.x * 5, scaler.y * 5 );
		^times.detectIndex({ |t, i|
			rect.contains( t@0 );
		});
	}
	
	getIndicesInRect { |rect|
		var pts = [], times;
		times = ([ 0 ] ++ object.times.integrate) / this.getTimesSum;
		times.do({ |t, i|
			if( rect.contains( t@0 ) ) { pts = pts.add(i) };
		});
		^pts;					
	}
	
	mouseEditSelected { |newPoint, mod|
		var pt;
		// returns true if edited
		switch( editMode,
			\move,  { 
				pt = (newPoint.round(round) - lastPoint.round(round));
				this.moveSelected( pt.x, pt.y, mod, \no_undo );
			},
			\elastic,  { 
				pt = (newPoint.round(round) - lastPoint.round(round));
				this.moveElastic( pt.x, pt.y, mod, \no_undo );
			}
		);
	}

	moveSelected { |x = 0, y = 0, mod ...moreArgs|
		var timesPositions;
		var moveAmt;
		if( (selected.size > 0) ) {
			moveAmt = x * this.getTimesSum;
			
			timesPositions = [ 
				[ 0 ] ++ object.times.integrate, 
				object.positions,
				object.positions.collect({ |item, i| selected.includesEqual(i) })
			].flop;
			
			selected.do({ |index|
				timesPositions[ index ][0] = timesPositions[ index ][0] + moveAmt;
			});
			
			timesPositions = timesPositions.sort({ |a,b| a[0] <= b[0] }).flop;
			object.positions = timesPositions[1];
			object.forceTimes((timesPositions[0]).differentiate[1..]);
			selected = timesPositions[2].indicesOfEqual( true );
			this.refresh;
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveElastic { |x = 0,y = 0, mod ...moreArgs|
		var selection;
		var timesPositions;
		var moveAmt;
		if( selected.size > 0 ) {
			
			moveAmt = x * this.getTimesSum;
			
			timesPositions = [ 
				[ 0 ] ++ object.times.integrate, 
				object.positions,
				object.positions.collect({ |item, i| selected.includesEqual(i) })
			].flop;
			
			selection = (selected.minItem..selected.maxItem);
			
			selection.do({ |index|
				timesPositions[ index ][0] = timesPositions[ index ][0] + moveAmt;			});
			
			2.do({ |ii|
				var rest, restSize;
				if( ii == 0 ) {
					rest = (..selection[0]);
				} {
					rest = (selection.last..timesPositions.size-1).reverse;
				};
				rest = rest[..rest.size-2];
				restSize = rest.size;
				rest.do({ |index, i|
					timesPositions[ index ][0] = timesPositions[ index ][0] 
						+ (moveAmt * (i/restSize));
				});	
			});
			
			timesPositions = timesPositions.sort({ |a,b| a[0] <= b[0] }).flop;
			object.positions = timesPositions[1];
			object.forceTimes((timesPositions[0]).differentiate[1..]);
			selected = timesPositions[2].indicesOfEqual( true );
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	scaleSelected { |x = 1, y, mod ...moreArgs|
		y = y ? x;
		if( selected.size > 0 ) {
			selected.do({ |index|
				object.positions[ index ] = object.positions[ index ] * (x@y);
			});
			this.refresh;
			this.edited( \edit, \scale, *moreArgs );
		};
	}
	
	rotateSelected { |angle = 0, scale = 1, update = true|
		// can't rotate times
	}
	
	
	startRecord { }
	
	recordPoint { }
			
	endRecord { }

	
}

//////// POINT EDITOR /////////////////////////////////////////////////////////////////

WFSPointView : WFSBasicEditView {
	
	var <>canChangeAmount = true;
	var <showLabels = true;
	var <labels;
	
	// object is an array of points

	defaultObject	{ ^[ Point(0,0) ]	 }	
	
	mouseEditSelected { |newPoint, mod|
		var pt;
		// returns true if edited
		if( mod.isKindOf( ModKey ).not ) {
			mod = ModKey( mod ? 0);
		};
		switch( editMode,
			\move,  { 
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
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
			\rotate, { 
				this.rotateSelected( 
					lastPoint.angle - newPoint.angle, 
					1, 
					mod,
					\no_undo
				);
			},
			\rotateS, { 
				this.rotateSelected( 
					lastPoint.theta - newPoint.theta, 
					newPoint.rho.max(0.001) / lastPoint.rho.max(0.001),
					mod, 
					false
				);
			},
			\elastic, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveElastic( pt.x, pt.y, mod, \no_undo );
			},
			\twirl, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveTwirl( pt.x, pt.y, mod, \no_undo );
			},
			\chain, {
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveChain( pt.x, pt.y, mod, \no_undo );
			}
		);
	}
	
	setDragHandlers {
		view.view
			.beginDragAction_({ object })
			.canReceiveDragHandler_({ |vw|
				var drg = View.currentDrag;
				if( drg.isString ) {
					drg = { drg.interpret }.try;
				};
				case { drg.isArray } {
					drg.collect(_.asPoint).every(_.isKindOf( Point ) );
				} { drg.isKindOf( Point ) } {
					true
				} { drg.respondsTo(\asWFSPointGroup) && {drg.isArray.not} } {
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
				case { drg.isKindOf( WFSPointGroup ) } {
					this.points = drg.positions;
				} { drg.isKindOf( Point ) } {
					this.points = [ drg ];
				} { drg.isArray } {
					this.points = drg;
				} { this.points = drg.asWFSPointGroup };
				this.edited( \drag_dropped_points );
			});
	 }

	showLabels_ { |bool| 
		showLabels = bool; 
		this.refresh; 
		this.changed( \showLabels ); 
	}
	
	labels_ { |array| 
		labels = array.asCollection;
		this.refresh; 
		this.changed( \labels ); 
	}
	
	objectAndLabels_ { |object, inLabels|
		labels = inLabels.asCollection;
		this.object = object;
	}
	
	
	drawContents { |scale = 1|
		var points, controls;
		var selectColor = Color.yellow;
		
		scale = scale.asArray.mean;
		
		Pen.use({	
			
			Pen.width = 0.164;
			Pen.color = Color.red(0.5, 0.5);
				
			//// draw configuration
			(WFSSpeakerConf.default ?? {
				WFSSpeakerConf.rect(48,48,5,5);
			}).draw;

			Pen.scale(1,-1);
			
			points = this.points.asCollection.collect(_.asPoint);
			
			Pen.width = scale;
		
			Pen.color = Color.blue(0.5,0.75);
			points.do({ |item|
					Pen.moveTo( item );
					Pen.addArc( item, 3 * scale, 0, 2pi );
					Pen.line( item - ((5 * scale)@0), item + ((5 * scale)@0));
					Pen.line( item - (0@(5 * scale)), item + (0@(5 * scale)));
			});
			Pen.stroke;	
		
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					Pen.width = scale;
					Pen.color = selectColor;
					selected.do({ |item|
						Pen.moveTo( points[item] );
						Pen.addArc( points[item] , 2.5 * scale, 0, 2pi );
					});
					
					Pen.fill;
				};
			});
			
			if( showLabels && { points.size > 1 } ) {
					Pen.font = Font( Font.defaultSansFace, 9 );
					Pen.color = Color.black;
					points.do({ |item, i|
						Pen.use({
							Pen.translate( item.x, item.y );
							Pen.scale(scale,scale.neg);
							Pen.stringAtPoint( 
								((labels ? [])[i] ? i).asString, 
								5 @ -12 );
						});
					});
			};
			
		});
		
	}
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var radius;
		radius = scaler.asArray.mean * 7;
		^this.points.detectIndex({ |pt, i|
			pt.asPoint.dist( point ) <= radius
		});
	}
	
	getIndicesInRect { |rect|
		var pts = [];
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
	
	resize { ^view.resize }
	resize_ { |resize| view.resize = resize }
	
	point_ { |point| this.object = (object ? [0]).asCollection[0] = point.asPoint }
	point { ^this.points[0] }
	
	points_ { |points|
		if( points.isKindOf( WFSPointGroup ) ) {
			points = points.positions.deepCopy;
		} {
			points = points.asCollection.collect(_.asPoint);
		};
		if( canChangeAmount ) {
			this.object = points;
		} {
			this.object = this.object.collect({ |item, i|
				points[i] ?? { object[i] };
			});
		};
	}
	
	points { ^object }
	
	at { |index| ^this.points[index] }
	
	zoomToFit { |includeCenter = true|
		var x,y;
		#x, y = this.points.collect({ |item| item.asArray }).flop;
		if( includeCenter ) { 
			view.viewRect_( Rect.fromPoints( x.minItem @ y.minItem, x.maxItem @ y.maxItem )
				.scale(1@ -1)
				.union( Rect(0,0,0,0) ).insetBy(-5,-5) );  
		} { 
			view.viewRect_( Rect.fromPoints( x.minItem @ y.minItem, x.maxItem @ y.maxItem )
				.asRect.scale(1@(-1)).insetBy(-5,-5) ); 
		};
	}

		
	// changing the object
	
	moveSelected { |x = 0,y = 0, mod ...moreArgs|
		if( selected.size > 0 ) {
			if( mod.ctrl && { selected.size == 1 } ) {
				selected.do({ |index|
					var pt;
					pt = this.points.asCollection[ index ];
					pt.x = (pt.x + x).round(0.1);
					pt.y = (pt.y + y).round(0.1);
				});
			} {
				selected.do({ |index|
					var pt;
					pt = this.points.asCollection[ index ];
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				});
			};
			this.refresh; 
			this.edited( \edit, \move, *moreArgs  );
		};
	}
	
	moveElastic { |x = 0,y = 0, mod ...moreArgs|
		var selection;
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			selection.do({ |index|
				var pt;
				pt = this.points[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
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
					var pt, factor;
					pt = this.points[ index ];
					if( pt.notNil ) {
						factor = (i/restSize);
						pt.x = pt.x + (x * factor);
						pt.y = pt.y + (y * factor);
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveTwirl { |x = 0,y = 0, mod ...moreArgs|
		var selection, angles, rhos, firstPoint, lastPoint;
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			firstPoint = this.points[selection[0]];
			lastPoint = this.points[selection.last]; 
			
			angles = [ 
				(firstPoint + (x@y)).angle - firstPoint.angle,
				(lastPoint + (x@y)).angle - lastPoint.angle
			].wrap(-pi, pi);
			
			rhos = [ 
				(firstPoint + (x@y)).rho - firstPoint.rho,
				(lastPoint + (x@y)).rho - lastPoint.rho
			];
			
			selection.do({ |index|
				var pt;
				pt = this.points[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
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
					var pt, factor, newPoint;
					pt = this.points[ index ];
					if( pt.notNil ) {
						factor = (i/restSize);
						newPoint = pt.asPolar;
						newPoint.theta = newPoint.theta + (angles[ii] * factor);
						newPoint.rho = (newPoint.rho + (rhos[ii] * factor)).abs;
						newPoint = newPoint.asPoint;
						pt.x = newPoint.x;
						pt.y = newPoint.y;
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	moveChain { |x = 0,y = 0, mod ...moreArgs|
		var selection, data;
		// keeps fixed distances between points
		if( selected.size > 0 ) {
			
			selection = (selected.minItem..selected.maxItem);
			
			data = 2.collect({ |ii|
				var rest, restSize, distance;
				if( ii == 0 ) {
					rest = (..selection[0]).reverse;
				} {
					rest = (selection.last..this.points.size-1);
				};
				
				distance = rest[1..].collect({ |item, i|
					this.points[item].dist( this.points[rest[i]] );
				});
				
				[ rest, distance ];
			});
			
			selection.do({ |index|
				var pt;
				pt = this.points[ index ];
				if( pt.notNil ) {
					pt.x = pt.x + x;
					pt.y = pt.y + y;
				};
			});
			
			data.do({ |data|
				var rest, distances;
				#rest, distances = data;
				rest[1..].do({ |index, i|
					var pt, polar;
					pt = this.points[ index ];
					if( pt.notNil ) {
						polar = (pt - this.points[rest[i]]).asPolar;
						polar.rho = distances[i];
						polar = polar.asPoint + this.points[rest[i]];
						pt.x = polar.x;
						pt.y = polar.y;
					};
				});	
			});
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	scaleSelected { |x = 1, y, mod ...moreArgs|
		y = y ? x;
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt;
				pt = this.points.asCollection[ index ];
				pt.x = pt.x * x;
				pt.y = pt.y * y;
			});
			this.refresh;
			this.edited( \edit, \scale, *moreArgs );
		};
	}
	
	rotateSelected { |angle = 0, scale = 1, mod ...moreArgs|
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt, rpt;
				pt = this.points.asCollection[ index ];
				rpt = pt.rotate( angle ) * scale;
				pt.x = rpt.x;
				pt.y = rpt.y;
			});
			this.refresh;
			this.edited( \edit, \rotate, *moreArgs );
		};
	}
	
	duplicateSelected { 
		var points;
		if( canChangeAmount && { selected.size >= 1} ) {
			selected = selected.sort;
			points = this.points.asCollection[ selected ].collect(_.copy);
			selected = object.size + (..points.size-1);
			this.points = this.points ++ points;
			this.refresh;
			this.edited( \duplicateSelected );
		};
	}
	
	removeSelected {
		if( canChangeAmount && { object.size > selected.size } ) {
			this.points = this.points.select({ |item, i|
				selected.includes(i).not;
			});
			selected = [];
		} {
			"WFSPointView-removeSelected : should leave at least one point".warn;
		};
		this.refresh;
		this.edited( \removeSelected );
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

//////// PLANE EDITOR /////////////////////////////////////////////////////////////////

WFSPlaneView : WFSPointView {
	
	init {
		this.editMode = \rotateS;
	}

	drawContents { |scale = 1|
		var points, controls;
		var selectColor = Color.yellow;
		
		scale = scale.asArray.mean;
		
		Pen.use({	
			
			Pen.width = 0.164;
			Pen.color = Color.red(0.5, 0.5);
				
			//// draw configuration
			(WFSSpeakerConf.default ?? {
				WFSSpeakerConf.rect(48,48,5,5);
			}).draw;
			
			Pen.scale(1,-1);
			
			points = this.points.asCollection.collect(_.asPoint);
			
			Pen.width = scale;
		
			Pen.color = Color.blue(0.5,0.75);
			points.do({ |p|
				var polar, p1, p2;
				polar = (p * (1@ 1)).asPolar;
				p1 = polar.asPoint;
				p2 = Polar( 50, polar.angle-0.5pi).asPoint;
				Pen.line( p1 + p2, p1 - p2 ).stroke;
				p2 = Polar( scale * 15, polar.angle ).asPoint;
				Pen.arrow( p1 + p2, p1 - p2, scale * 5 );
			});
			Pen.stroke;
		
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					Pen.width = scale;
					Pen.color = selectColor;
					selected.do({ |item|
						Pen.moveTo( points[item] );
						Pen.addArc( points[item] , 2.5 * scale, 0, 2pi );
					});
					
					Pen.fill;
				};
			});
			
			if( showLabels && { points.size > 1 } ) {
					Pen.font = Font( Font.defaultSansFace, 9 );
					Pen.color = Color.black;
					points.do({ |item, i|
						Pen.use({
							Pen.translate( item.x, item.y );
							Pen.scale(scale,scale.neg);
							Pen.stringAtPoint( 
								((labels ? [])[i] ? i).asString, 
								5 @ -12 );
						});
					});
			};
			
		});
		
	}	
}


//////// MIXED EDITOR /////////////////////////////////////////////////////////////////

WFSMixedView : WFSPointView {
	
	classvar <>typeDrawFuncs;
	
	var <>type = \point;
	var <>colors;
	
	*initClass {
		typeDrawFuncs = (
			\point: { |evt, p, scale, center|
				Pen.moveTo( p );
				Pen.addArc( p, 3 * scale, 0, 2pi );
				Pen.line( p - ((5 * scale)@0), p + ((5 * scale)@0));
				Pen.line( p - (0@(5 * scale)), p + (0@(5 * scale)));
			},
			\plane: { |evt, p, scale, center|
				var polar = (p * (1@ 1)).asPolar;
				var p1 = polar.asPoint;
				var p2 = Polar( 50, polar.angle-0.5pi).asPoint;
				Pen.line( p1 + p2, p1 - p2 ).stroke;
				p2 = Polar( scale * 15, polar.angle ).asPoint;
				Pen.arrow( p1 + p2, p1 - p2, scale * 5 );
			},
			\radius: { |evt, p, scale, center|
				Pen.moveTo( p );
				Pen.addArc( p, 3 * scale, 0, 2pi );
				Pen.line(p - ((3*scale) @ 0), p * (-1 @  1) );
				Pen.lineTo( p * (-1 @ -1) );
				Pen.lineTo( p * ( 1 @ -1) );
				Pen.lineTo( p - (0 @ (3*scale) ) );
				Pen.stroke;
			},
			\speaker: { |evt, p, scale, center|
				Pen.use({
					Pen.translate( p.x, p.y );
					Pen.rotate( (p - center).angle - pi );
					Pen.alpha_( 0.75 );
					DrawIcon( \speaker, 
						Rect( -15 * scale, -15 * scale, 30 * scale, 30 * scale ) 
					);
				});
			},
		);
	}
	
	drawType { |which, p, scale = 1|
		typeDrawFuncs.perform( which, p, scale, this.center );
	}
	
	center { ^Point(0,0) }

	drawContents { |scale = 1|
		var points, controls, types;
		var selectColor = Color.yellow;
		
		scale = scale.asArray.mean;
		
		Pen.use({	
			
			Pen.width = 0.164;
			Pen.color = Color.red(0.5, 0.5);
				
			//// draw configuration
			(WFSSpeakerConf.default ?? {
				WFSSpeakerConf.rect(48,48,5,5);
			}).draw;
			
			Pen.scale(1,-1);
			
			points = this.points.asCollection;
			types = this.type.asCollection.wrapExtend(points.size);
			
			Pen.width = scale;
		
			if( this.colors.size < 2 ) {
				Pen.color = this.colors.asCollection[0] ?? { Color.blue(0.5,0.75); };
				points.do({ |p, i|
					this.drawType( types[i], p, scale );
				});
				Pen.stroke;
			} {
				points.do({ |p, i|
					Pen.color = this.colors.asCollection.wrapAt(i) ?? { Color.blue(0.5,0.75); };
					this.drawType( types[i], p, scale );
					Pen.stroke;
				});
			};
		
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					Pen.width = scale;
					Pen.color = selectColor;
					selected.do({ |item|
						Pen.moveTo( points[item] );
						Pen.addArc( points[item] , 2.5 * scale, 0, 2pi );
					});
					
					Pen.fill;
				};
			});
			
			if( showLabels && { points.size > 1 } ) {
					Pen.font = Font( Font.defaultSansFace, 9 );
					Pen.color = Color.black;
					points.do({ |item, i|
						Pen.use({
							Pen.translate( item.x, item.y );
							Pen.scale(scale,scale.neg);
							Pen.stringAtPoint( 
								((labels ? [])[i] ? i).asString, 
								5 @ -12 );
						});
					});
			};
			
		});
		
	}
	
	objectAndLabels_ { |object, inLabels, type, colors|
		labels = inLabels.asCollection;
		this.object = object;
		this.type = type ? \point;
		this.colors = colors;
	}
		
}


//////// POINT GROUP EDITOR /////////////////////////////////////////////////////////////////

WFSPointGroupView : WFSMixedView {
	
	points { ^(object !? _.positions) ? [] }
	
	points_ { |points|
		points = points.asWFSPointGroup;
		if( this.object.isNil ) {
			this.object = points;
		} {
			if( canChangeAmount ) {
				this.object.positions = points.positions;
			} {
				this.object.positions = this.object.positions.collect({ |item, i|
					points[i] ?? { object[i] };
				});
			};
		};
	}
}

