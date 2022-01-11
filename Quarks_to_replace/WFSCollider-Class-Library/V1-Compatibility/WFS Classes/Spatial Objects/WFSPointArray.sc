/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2010 Wouter Snoei.

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

WFSArrayBase[slot] : RawArray {
	
	asXYArray {
		^this.collect({ |item| [item.x, item.y] })
		}
	
	asAZArray { |center = 0|
		center = center ? this.center;
		center.asWFSPoint;
		^WFSTools.xyToAZ(this.asXYArray, this.center);
		}
	
	center { ^WFSPoint( *this.asArray.flop.collect{ |item| item.sum / item.size } ); }
		
	x { ^this.collect( _.x ); }
	y { ^this.collect( _.y ); }
	z { ^this.collect( _.z ); }
	
	asEnvViewInput { |autoScale = false, fromRect |
		var new;
		if(autoScale)
			{ new = this.scaleToRect( Rect(0,0,1,1), fromRect );
				^[new.x, new.y]
			}
			{ ^[this.x, this.y] };
		}
		
	scaleToRect { |toRect, fromRect, keepRatio = true, inset = 0.05|
		var out;
		toRect = (toRect ? Rect(0,0,1,1)).asRect;
		toRect = toRect.insetBy( inset * toRect.width, inset * toRect.height );
		fromRect = ( fromRect ? this.asRect ).asRect;
		out = this.move( toRect.center - fromRect.center );
		if( keepRatio )
			{ ^out.scale( (toRect.width / fromRect.width).min( toRect.height / fromRect.height ), toRect.center)  }
			{ ^out.scale( [ toRect.width / fromRect.width, toRect.height / fromRect.height ], toRect.center)  };
		}
		
	scaleFromRect { |fromRect, toRect, keepRatio = true, inset = 0.05| // inset is now for fromRect
		var out;
		fromRect = (fromRect ? Rect(0,0,1,1)).asRect;
		fromRect = fromRect.insetBy( inset * fromRect.width, inset * fromRect.height );
		toRect = ( toRect ? this.asRect ).asRect;
		out = this.move( toRect.center - fromRect.center );
		if( keepRatio )
			{ ^out.scale( (toRect.width / fromRect.width).min( toRect.height / fromRect.height ), toRect.center)  }
			{ ^out.scale( [ toRect.width / fromRect.width, toRect.height / fromRect.height ], toRect.center)  };
		}
	
	autoScaleFactor { ^0.45 / this.maxRadius }  // not used anymore
		
	plot { var a, b;
		a = SCWindow(this.class.asString, Rect(450 , 400, 410, 410), false);
		a.view.decorator =  FlowLayout(a.view.bounds);
		b = SCEnvelopeView(a, Rect(0, 0, 400, 400))
			.thumbSize_(5)
			.drawLines_( false )
			.fillColor_(Color.green)
			.selectionColor_(Color.red)
			.drawRects_(true)
			.value_(this.asEnvViewInput(true) )
			.setEditable(-1,false);
		a.front;
		^this;
		}
		
	plotSmoothInput { |size, color, fromRect| // x/y
		var path;
		size = size ? 400;
		color = color ? Color.green.alpha_(0.5);
		path = this.asEnvViewInput(true, fromRect);
		path = [path[0], 1 - path[1]];
		
		path = ( path * size ).flop
				.collect({ |item| item[0]@item[1] });
		// points
		color.set;
		path.do({ |item,i| Pen.addAnnularWedge( item, 3, 3, 0, 2pi ) });
		Pen.stroke;
		^path;
		}
		
	plotSmooth { 	|speakerConf = \default|	
		var path, angles;
		var window, fromRect;
		window = SCWindow(this.class.asString, Rect(128, 64, 400, 400)).front;
		window.view.background_(Color.black);
		
		fromRect = this.asRect;
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
							
		window.drawHook = { var tempPath, tempPath2, firstPoint, bounds;
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
			
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };
				
			this.plotSmoothInput( bounds, fromRect: fromRect );
			//this.do({ |item| item.plotSmoothInput( bounds, fromRect: fromRect ) }); 
		};
		window.refresh;
		}

		
	left { ^[this.x.minItem, 0].asWFSPoint } 
	back { ^[0, this.y.minItem].asWFSPoint }// is top
	right { ^[this.x.maxItem, 0].asWFSPoint } 
	front { ^[0, this.y.maxItem].asWFSPoint } // is bottom
	
	width {  var x; x = this.x; ^x.maxItem - x.minItem; }
	depth {  var y; y = this.y; ^y.maxItem - y.minItem; }
	
	asRect { ^Rect( this.left.x, this.back.y, this.width, this.depth ) 
		// note the reversed y axis; 
		}
	
	rectCenter { var z;
			z = this.z;
			^this.asRect.center.asWFSPoint.z_( ( z.maxItem + z.minItem ) / 2 ) } 
	
	maxRadius { ^this.asAZArray(nil).flop[1].maxItem; } //2D
	
	corners { var center, radius; //2D -- clockwise
		radius = this.maxRadius;
		center = center;
		^[	center + ([-1,  1] * radius),
			center + ([ 1,  1] * radius),
			center + ([ 1, -1] * radius),
			center + ([-1, -1] * radius) ]
		}
	
	distances { ^this[1..].collect({ |aWFSPoint, i| aWFSPoint.dist( this[i] ); });  } // to next
	
	angles { ^this[1..].collect({ |aWFSPoint, i| this[i].angleFrom( aWFSPoint ); }); } // to next
	
	scale { |amount = 1, center|
		center = center ?? { this.center };
		^this.class.fill( this.size, { |i|
			this[i].scale(amount, center) });
		}
		
	move { |amount = 0|
		^this.class.fill( this.size, { |i|
			this[i].move(amount) });
		}
	
	moveToCenter { ^this.move( this.center.neg ) }

	dist { |wfsPoint| ^this.collect( _.dist( wfsPoint ) ); }
	
	distDirection {  |wfsPoint| ^this.collect( _.distDirection( wfsPoint ) );  }
	
	distSort { |wfsPoint = 0| // sort array as absolute distance to point
		wfsPoint = wfsPoint.asWFSPoint;
		^this.sort( { |a,b| a.dist( wfsPoint ) <= b.dist( wfsPoint ) } );
		}
	
	angleSort { |wfsPoint = 0| // sort array as clockwise angle to point
		wfsPoint = wfsPoint.asWFSPoint;
		^this.sort( { |a,b| a.angleFrom( wfsPoint ) <= b.angleFrom( wfsPoint ) } );
		}
		
	angleSort2 { |wfsPoint = 0, angle = 0| // sort array as closest to specified angle from point
		var halfAzMax;
		wfsPoint = wfsPoint.asWFSPoint;
		halfAzMax = WFSPath.azMax / 2;
		^this.sort( { |a,b| 
			(a.angleFrom( wfsPoint ) - angle).wrap2(halfAzMax.neg, halfAzMax).abs <= 
			(b.angleFrom( wfsPoint ) - angle).wrap2(halfAzMax.neg, halfAzMax).abs } );
		}
		
	angleSort3 { |wfsPoint = 0, angle = 0| // sort array as closest to specified angle from point
		var halfAzMax;
		wfsPoint = wfsPoint.asWFSPoint;
		halfAzMax = WFSPath.azMax / 2;
		^this.sort( { |a,b| 
			(a.angleTo( wfsPoint ) - angle).wrap2(halfAzMax.neg, halfAzMax) <= 
			(b.angleTo( wfsPoint ) - angle).wrap2(halfAzMax.neg, halfAzMax) } );
		}
		
	nearestPoint { |wfsPoint = 0|
		^this.copy.distSort( wfsPoint )[0]; }
	
	nearestPointSort { |startPoint|  // non-destructive
		var sortedArray, outArray;
		
		startPoint = startPoint ? this[0];
		sortedArray = this.copy.distSort( startPoint );
		outArray = [ sortedArray.removeAt(0) ].asWFSPointArray;
		while { sortedArray.size > 0 }
			{sortedArray.distSort( outArray.last );
				outArray = outArray.add( sortedArray.removeAt(0) ); };
		
		^outArray;
		}
		
	smallestAngleSort { |startPoint|  // non-destructive
		// should have at least 2 points
		var sortedArray, outArray, angle;
		
		startPoint = startPoint ? this[0];
		sortedArray = this.copy.distSort( startPoint );
		outArray = [ sortedArray.removeAt(0) ].asWFSPointArray;
		sortedArray.distSort;
		outArray = outArray.add( sortedArray.removeAt(0) );
		angle = outArray.last.angleFrom( outArray[ outArray.size - 2 ] );
		while { sortedArray.size > 0 }
			{	sortedArray.angleSort2( outArray.last, angle );
				outArray = outArray.add( sortedArray.removeAt(0) );
				angle = outArray.last.angleFrom( outArray[ outArray.size - 2 ] ); };
		
		^outArray;
		}	
}

WFSMixedArray[slot] : WFSArrayBase { 

	// points and planes 
	
	asRect { var rect;
		rect = this[0].asRect;
		this[1..].do({ |item| rect = rect.union( item.asRect ); });
		^rect;
		}
	
	plotSmooth { |speakerConf = \default, toFront = true, events|	
		var path, angles;
		var window, fromRect;
		var originalCurrentTimes;
		var maxDuration;
		var routine;
		var wfsPaths;
		var wfsPlotSmooth;
		var currentIndex;
		var toRect, newRect, factor, height, mousePos, mouseMod, originalPos, originalPath, bounds;
		var writePaths = false;
		/*
		window = SCWindow(this.class.asString, Rect(128, 64, 400, 400)).front;
		window.view.background_(Color.black);
		*/

		window = WFSPlotSmooth( this.class.asString, toFront: toFront );
		
		window.onClose_({ if( routine.notNil ) { routine.stop } });
		
		wfsPaths = this.select( _.isWFSPath );
		if( wfsPaths.size != 0 ) {
			originalCurrentTimes = wfsPaths.collect( _.currentTime);
			wfsPaths.do( _.resetTempPlotPath );
			maxDuration = wfsPaths
				.collect({ |item| item.length - item.currentTime; }).maxItem;
			
			WFSPlotSmooth.playButton = RoundButton(window, Rect(345,5,20,20) )
				.states_( [
					[ \play, Color.white,Color.white.alpha_(0.25)],
					[ \stop, Color.white,Color.red.alpha_(0.25) ],
					[ \return, Color.white,Color.green.alpha_(0.25)]
					] )
				.action_({ |button|
					case { button.value == 1 }
					{ routine = Routine({ ((maxDuration / 0.05) + 1).do({ |i|
						
							wfsPaths.do({ |item| item.currentTime = 
								item.currentTime + 0.05; });
							{ window.view.refresh }.defer;
							0.05.wait; });
							{ button.value = 2 }.defer;
						}).play; }
						
					{ button.value == 2 }
						{ routine.stop; }
					{ button.value == 0 }
					{  wfsPaths.do({ |item, i| 
						item.currentTime = originalCurrentTimes[i]; });
						window.view.refresh; }
					})
				.resize_( 3 ); 
		};
		
		RoundButton(window, Rect(375,5,20,20) )
			.canFocus_(false)
			.states_( [
				[ \sign, Color.black,Color.grey(0.3) ],
				[ \sign, Color.black,Color.grey(0.7) ],
			] )
			.action_({
				writePaths = writePaths.not;
				WFSPlotSmooth.view.refresh;
			})
			.resize_( 3 );
		
		fromRect = this.asRect;
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
			
		if( speakerConf.notNil )
				{ fromRect = fromRect.union( speakerConf.asRect ) };
				
		toRect = Rect(0,0,window.view.bounds.width,window.view.bounds.height);
									
		WFSPlotSmooth.view.drawFunc_({
			var tempPath, tempPath2, firstPoint, x, y;
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
			
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };
				
			this.do( _.plotSmoothInput( bounds, fromRect: fromRect ) );
			
			Pen.font = Font( "Monaco", 9 );
			Pen.color = Color.white.alpha_(0.8);
			
			if( writePaths ) {
				
				this.do{ |obj,i|
					var st;
					switch(obj.class)
					{ WFSPoint } {
						x = obj.x;
						y = obj.y;
					} 
					{ WFSPath } {
						
						x = obj.center.x;
						y = obj.center.y;
					}
					{ WFSPlane } {
						x = obj.asWFSPoint.x;
						y = obj.asWFSPoint.y;	
					};
					st = PathName(events[i].filePath).fileName.removeExtension;
					if( st.notNil ) {
						Pen.stringAtPoint(
							st.asString,
							WFSPoint(x,y).toScreenCoord(bounds,fromRect).asPoint + Point(5,0)
						)
					}
				};
			};
			//post x,y positions when moving
			if(currentIndex.notNil) {
				switch(this[currentIndex].class)
				{ WFSPoint } {
					x = this[currentIndex].x;
					y = this[currentIndex].y;
				} 
				{ WFSPath } {
					
					x = this[currentIndex].center.x;
					y = this[currentIndex].center.y;
				}
				{ WFSPlane } {
					x = this[currentIndex].asWFSPoint.x;
					y = this[currentIndex].asWFSPoint.y;
				};
				
				Pen.stringAtPoint("x: "++x.round(0.1)++", y: "++y.round(0.1), Point(20,20))
			}
		})
		.mouseDownAction_({|v, x, y, mod|
			var point, side;
			mouseMod = mod;
			
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
			
			this.do{ |path,i|
				switch(path.class)
				{ WFSPoint } {
					point = path;
				} 
				{ WFSPath } {					
					point = path.center;
				}
				{ WFSPlane } {
					point = path.asWFSPoint
				};
				
				point = point.toScreenCoord(bounds, fromRect);
				originalPos = mousePos = x@y;	
				if(Rect.fromPoints(point - 	Point(4,4),point + Point(4,4)).containsPoint(x@y)) {
					currentIndex = i;

					if(path.isWFSPath) {
						originalPath = path.copy
					}
				}
			}
				
		})
		.mouseMoveAction_({|v, x, y, mod|
			var point, tempPath, dif;
			
			if(currentIndex.notNil) {
				x = x.clip(0,window.view.bounds.width);
				y = y.clip(0,window.view.bounds.height);

				point = WFSPoint(x,y).fromScreenCoord(bounds,fromRect);
				
				
				switch(this[currentIndex].class)
				{ WFSPoint } {
					this[currentIndex] = point;
				} 
				{ WFSPath } {
					
					if(mouseMod.isAlt) {
						dif = originalPos.y-mousePos.y;
						this[currentIndex].positions = originalPath.copy.scale((1 + (dif*0.05)).max(0.001)).positions;
					} {
						if(mouseMod.isShift) {
							dif = originalPos.y-mousePos.y;
							this[currentIndex].positions = originalPath.copy.rotate(dif).positions;
							
						} {
							this[currentIndex].moveCenterTo(point)
						}
					}
				}
				{ WFSPlane } {
					this[currentIndex] = WFSPlane.fromWFSPoint(point * WFSPoint(-1,-1));
				};
				
				mousePos = x@y;
				v.refresh;
			}
			
		})
		.mouseUpAction_({ |v,x,y|
			var current;
			if(currentIndex.notNil) {
				current = this[currentIndex]; 
				if( current.isWFSPoint || (current.class == WFSPlane) ) {
					events[currentIndex].wfsSynth.wfsPath = this[currentIndex]
				};
				events[currentIndex].changed;
				currentIndex = nil;
				
				v.refresh
			};
			
			
		});
		
		window.refresh;
		}
	}

WFSPointArray[slot] : WFSArrayBase {

	interpolate { |division = 10, type = 'linear', loop = true, extra, close = false|
		^[ 
			this.x.interpolate( division, type, loop, extra, close ),
			this.y.interpolate( division, type, loop, extra, close ),
			this.z.interpolate( division, type, loop, extra, close ) 
		].flop.asWFSPointArray;
		}
	
	isValid { ^this.every( _.isWFSPoint ) }
	
	intAt { |index = 0, type = 'linear', loop=true, extra|
		^WFSPoint( *[this.x, this.y, this.z]
			.collect( _.intAt( index, type, loop, extra ) ) );
		}
	
	*gridFill{ arg inArray, reverseOdd = true;
		^super.with(*Array.gridFill(inArray, reverseOdd));
		}
	
	*makeGrid{arg width, div, offset, reverseOdd = true;
		^super.with(*Array.makeGrid(width, div, offset, reverseOdd));

	}
	*makeLine{ arg start, end, div, includeEnd = true;
		if( start.isWFSPoint ) { start = start.asArray };
		if( end.isWFSPoint) { end = end.asArray };
		^super.with(*Array.makeLine(start, end, div, includeEnd));
	}
	
	*makeRect{ arg width, div, offset; // div per side, offset includes z
		^super.with(*Array.makeRect(width, div, offset));
	}
	
	*rand { arg nPoints = 10, radius = 1.0, rSeed; //simple 2D rand
		var routine;
		routine = Routine({ loop { WFSPoint.rand(radius).yield } });
		if( rSeed.notNil ) { routine.randSeed = rSeed };
		^WFSPointArray.fill(nPoints, { routine.next });
		}
	
	*rand3D { arg nPoints = 10, min = -1.0, max = 1.0; //simple 2D rand
		^WFSPointArray.fill(nPoints, { WFSPoint.rand3D(min, max) });
		}
	
	*accLine { arg start = 0, angle = 0, dist = 0.1, a = 0.9, nPoints = 10;
		// accelerating line
		var array;
		start = start.asWFSPoint;
		array = WFSPointArray[ start ];
		(nPoints - 1).do({
			start = start.moveAZ( angle, dist );
			array = array.add( start );
			dist = dist * a;
			});
		
		^array;
		}

	asArray{
		^this.collect({ |item| [item.x, item.y, item.z] })
	}
	
	add { arg item; ^super.add(item.asWFSPoint) }
	
	put { |index, item| ^super.put(index, item.asWFSPoint) }
	
	insert { |index, item| ^super.insert(index, item.asWFSPoint) }
	
	++ { |anArray| ^super ++ anArray.asWFSPointArray }
		
	asWFSPath { |deltaTime| ^WFSPath( this, deltaTime ) }
	
	asWFSPointArray { ^this }
	
	*fromAZArray { |array, center = 0|
		var points;
		points = WFSTools.azToXY( array, center );
		^this.with( *points );
		}
	
	blend {arg that, amount = 0.5;
			var intRate;
			if(that.isNil, {that = 
				WFSPath.circle(this.size - 1,
					this.center, this.maxRadius, close: true).positions; });
			that = that.asWFSPointArray;
			
			if( that.size != this.size )
				{ 
				intRate = (this.size -1) / (that.size -1); 
				that = that.interpolate( intRate, 'linear', false ); };
				
			^this.collect({arg item, i; item.blend(that.wrapAt(i), amount) }).asWFSPointArray;		}
		
	edit { |deltaTime| this.asWFSPath( deltaTime ).edit; } // shortcut
	
	
	plotSmooth { 	|speakerConf = \default, toFront = true|	
		var path, angles;
		var window, fromRect;
		
		/*
		window = SCWindow(this.class.asString, Rect(128, 64, 400, 400)).front;
		window.view.background_(Color.black);
		*/
		
		window = WFSPlotSmooth( this.class, toFront: toFront );
		
		fromRect = this.asRect;
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
			
		if( speakerConf.notNil )
				{ fromRect = fromRect.union( speakerConf.asRect ) };
							
		window.drawHook = { var tempPath, tempPath2, firstPoint, bounds;
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
			
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };
				
			this.do( _.plotSmoothInput( bounds, fromRect: fromRect ) );
			//this.do({ |item| item.plotSmoothInput( bounds, fromRect: fromRect ) }); 
		};
		window.refresh;
		}
			
}



WFSSpeakerArray[slot] : WFSArrayBase {

	asArray {
		^this.collect({ |item| [item.x, item.y, item.z, item.angle] })
	}
	
	validate { |warn=false|  ^WFSSpeakerLine.testNew( this.asArray, warn )  }

	angle { ^this.collect( _.angle ) }
	
	radianAngle { ^this.collect( _.radianAngle ) }
	
	asWFSSpeakerArray { ^this }
	
	//asWFSSpeaker { ^this }
	
	asWFSSpeakerLine { ^this.validate }
	
	add { arg item; ^super.add(item.asWFSSpeaker) }
	
	put { |index, item| ^super.put(index, item.asWFSSpeaker) }
	
	insert { |index, item| ^super.insert(index, item.asWFSSpeaker) }
	
	++ { |anArray| ^(super ++ anArray.asWFSSpeakerArray).asWFSSpeakerArray.validate }
	
	plotSmoothInput { |size, color, fromRect| // x/y
		var path, angles;
		size = size ? 400;
		color = color ? Color.yellow.alpha_(0.5);
		if( this.size != 0 )
		{ 	path = this.asEnvViewInput(true, fromRect);
			path = [path[0], 1 - path[1]];
			angles = this.collect( _.radianAngle);
			path = ( path * size ).flop
					.collect({ |item| item[0]@item[1] });
			// points
			color.set;
			path.do({ |item,i| Pen.addAnnularWedge( item, 3, 3, angles[i], pi ) });
			Pen.stroke;
			^path;
			};
		}
		
	distDirection { |wfsPoint = 0| // -1 when point in front of line, 1 when point behind line or on
		^this.collect( _.distDirection( wfsPoint ));
		}
		
	distances { |wfsPoint = 0|  /// used by WFSConfiguration-distances -> WFSPan / WFSPan2D
		^this.collect( _.dist( wfsPoint ) ) * this.distDirection( wfsPoint );
		}
		
	flippedPositions { |scale = 1, move = 0|
		^( this.collect( _.flipY ) * scale ) + move;
		}
	
	closestSpeakerIndex { |point = 0|
		var distances; // no fractional parts
		point = point.asWFSPoint;
		distances = this.collect( _.dist( point ) );
		^MinItem.switch( distances, (0,1 .. (distances.size - 1) ) );
		}

	}

WFSSpeakerLine[slot] : WFSSpeakerArray {
	
	asWFSSpeakerArray { ^WFSSpeakerArray.fill( this.size, { |i| this[i] }); }
	
	asWFSSpeaker { ^this }
	
	*testNew { |wfsSpeakers, warn=true, round = 1.0e-12|
		if( wfsSpeakers[1..].every({ |item, i|
				wfsSpeakers[i].asWFSSpeaker.isInLineWith( item, round ); }) )
			{ ^WFSSpeakerLine.with( *wfsSpeakers ) }
			{ if(warn)
				 {"speakers for WFSSpeakerLine are not in one line:
	created a WFSSpeakerArray instead".warn; };
			  ^WFSSpeakerArray.with(*wfsSpeakers) }
		}
	
	*newFromLeft { |leftSpeaker, n = 8, distance = 0.164| 
		// left speaker is on the left side of the line when you are in front of it
		leftSpeaker = leftSpeaker.asWFSSpeaker;
		^WFSSpeakerLine.with( *Array.fill(n, { |i| 
			leftSpeaker.copy.moveAZ( leftSpeaker.angle - 90, i * distance, 1.0e-15 );
			}) );
		}
	
	*newFromCenter { |centerSpeaker, n = 8, distance = 0.164|
		var offset;
		offset = distance * ((n-1)/2);
		centerSpeaker = centerSpeaker.asWFSSpeaker;
		^WFSSpeakerLine.with( *Array.fill(n, { |i| 
			centerSpeaker.copy.moveAZ( centerSpeaker.angle - 90, (i * distance) - offset, 1.0e-15 );
			}) );
		}
		
	width { ^this.first.dist( this.last ); }
	
	sortLR { var center; // left to right (from speaker direction) -- means right to left when in front
		center = this.center.asWFSSpeaker( this.angle );
		^this.sort( { |a,b|
			(a.angleOffset( center ).wrap2( -180, 180 ).sign * a.dist( center )) >=
			(b.angleOffset( center ).wrap2( -180, 180 ).sign * b.dist( center )) } );
		}
	
	corners { var sorted; // l,r
		sorted = this.copy.sortLR;
		^WFSSpeakerArray[sorted.first, sorted.last];
		 }
		 
	startSpacingAndSize {
		^[ this[0], WFSPoint( this[1].x - this[0].x, this[1].y - this[0].y ), this.size ]
		}
		
	closestSpeakerIndex { |wfsPoint = 0, clip = true|
	
		//find the index of the speaker nearest to given point
		
		var sss;
		sss = this.startSpacingAndSize;
		if( clip )
			{ if( sss[1].x == 0 )
				{ ^((wfsPoint.asWFSPoint.y - (sss[0].y)) / sss[1].y).max(0).min( this.size ); }
				{ ^((wfsPoint.asWFSPoint.x - (sss[0].x)) / sss[1].x).max(0).min( this.size ); };
			}
			{ if( sss[1].x == 0 )
				{ ^(wfsPoint.asWFSPoint.y - (sss[0].y)) / sss[1].y }
				{ ^(wfsPoint.asWFSPoint.x - (sss[0].x)) / sss[1].x };
			};
		}
		
	// for the following calculations the first speaker in the line is the reference
	angle { ^this.first.angle }	
	radianAngle { ^WFSTools.asRadians( this.first.angle ) }
	
	shortestDistFromCenter {  // shortest distance to center
		// will be POSITIVE when line is FACED TOWARDS center (aka when the center IN FRONT OF of the line)
		^this.shortestDistFrom( WFSPoint(0,0,0) ); 
		}
		
	shortestDistToCenter { ^this.shortestDistFromCenter.neg }
		
	shortestDistFromBasic { |wfsPoint| // can be kr / ar  : will be POSITIVE when point is IN FRONT OF line
		^( this.radianAngle - wfsPoint.radianAngleFrom( this.first ) ).cos * 
			this.first.dist( wfsPoint ) ;
		} 
		
	shortestDistFrom { |wfsPoint = 0|
		var thisangle;
		wfsPoint = wfsPoint.asWFSPoint;
		
		// optimized for rectangular speaker setup
		
		// will be POSITIVE when point is IN FRONT OF line
		
		if( WFSPath.azMax != 360 )
			{ thisangle = (this.angle / WFSPath.azMax) * 360; }
			{ thisangle = this.angle };
		
		case { thisangle == 0 }
			{ ^wfsPoint.y - this.first.y }
			{ thisangle == 180 }
			{ ^this.first.y - wfsPoint.y }
			{ thisangle == 90 }
			{ ^wfsPoint.x - this.first.x }
			{ thisangle == 270 }
			{ ^this.first.x - wfsPoint.x }
			{ true }
			{ ^this.shortestDistFromBasic( wfsPoint ); } 
		}
	
	shortestDistTo { |wfsPoint = 0| //  will be NEGATIVE when point is IN FRONT OF line
		^this.shortestDistFrom( wfsPoint ).neg;
		}
		
	pointIsInFront {  |wfsPoint=0| ^this.first.pointIsInFront( wfsPoint ); }
	pointIsBehind{  |wfsPoint=0| ^this.first.pointIsBehind( wfsPoint ); }
	
	orientation {
		var thisangle;
		if( WFSPath.azMax != 360 )
			{ thisangle = (this.angle / WFSPath.azMax) * 360; }
			{ thisangle = this.angle };
			
		case { [0.0, 180.0].includes( thisangle.round(1) ) }
			{ ^\h }
			{ [90.0, 270.0].includes( thisangle.round(1) ) }
			{ ^\v }
			{ true }
			{ ^\none }; // none
			
		 }
			
	distDirection { |wfsPoint = 0| // -1 when point in front of line, 1 when point behind line or on
		^this.first.distDirection( wfsPoint );
		}
		
	distances { |wfsPoint = 0|  /// used by WFSConfiguration-distances -> WFSPan / WFSPan2D
	
		var localAngle, deltaXSquared, deltaYSquared;
		wfsPoint = wfsPoint.asWFSPoint;
		
		if( WFSConfiguration.optLines )
			{ 
				if( WFSPath.azMax != 360 )
					{ localAngle = (this.first.angle / WFSPath.azMax) * 360; }
					{ localAngle = this.first.angle };
				
				case { localAngle == 0; }
					{ deltaYSquared = sqrdif(this.first.y, wfsPoint.y); }					{ localAngle == 180; }
					{ deltaYSquared = sqrdif(this.first.y, wfsPoint.y); }					{ localAngle == 90; }
					{ deltaXSquared = sqrdif(this.first.x, wfsPoint.x); }
					{ localAngle == 270; } 
					{ deltaXSquared = sqrdif(this.first.x, wfsPoint.x); };
			};
		
		^this.collect( _.distOpt( wfsPoint, deltaXSquared, deltaYSquared ) ) 
			// * this.distDirection( wfsPoint );
		}
		
	plotSmoothInput {	|size, color, fromRect, showCorners = false| // x/y
		var path, angles;
		size = size ? 400;
		color = color ? Color.yellow.alpha_(0.5);
		path = this.corners.asEnvViewInput(true, fromRect);
		path = [path[0], 1 - path[1]];
		angles = this.collect( _.radianAngle);
		path = ( path * size ).flop
				.collect({ |item| item[0]@item[1] });
		// points
		color.set;
		
		if( showCorners )
			{ path.do({ |item,i| Pen.addAnnularWedge( item, 3, 3, angles[i], pi ) });
				Pen.stroke; };
				
		Pen.moveTo( path[0] );
		Pen.lineTo( path[1] );
		Pen.stroke;
		
		^path;
		
		}
		
		
	asSVGObject { |scale, move, strokeColor|
		var flipPos, points;
		scale = scale ? 20; move = move ? 300;
		flipPos = this.flippedPositions;
		points = [ flipPos[0].asPoint, flipPos.last.asPoint ]
					.collect({ |pt| (pt * scale) + move });
		strokeColor = strokeColor ? Color.yellow(0.85);
		 ^SVGLine( points[0].x, points[0].y, points[1].x, points[1].y,
				"SpeakerLine", strokeColor, "none", 3 );
		 }
	
	}
