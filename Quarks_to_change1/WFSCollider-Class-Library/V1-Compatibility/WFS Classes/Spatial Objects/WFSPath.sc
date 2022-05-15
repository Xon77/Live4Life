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

// 3 dimensional time paths in meters and seconds
// contains array of WFSPoints, an array of delta-times and a name (String or Symbol)

WFSPath_Old {

	classvar <>defaultTime = 1;  // default delta-time
	classvar <>azMax = 360; // more WFS Classes use this
	classvar nameIndex = 0;
	classvar <>svgImportCurveResolution = 10;
	
	var <positions, <times, <name, azPositions;
	var backup;  // will always keep a copy of positions/times/name for undo capability
	var <>buffers, buffersLoaded;
	var tempPlotPath;
	var <>currentTime = 0;
	var <>plotWindow, routine;
	
	var <>sndFileName, <>sndFileStart, <>sndFileEnd;

	*new { | positions, times, name, azPositions |
		positions = positions ? [WFSPoint(-1,-1,-1), WFSPoint(1,1,1)];
		//positions = WFSTools.makeWFSPointsArray(positions);
		positions = positions.asWFSPointArray;
		if(positions.size < 2)
			{ "A WFSPath should contain at least 2 positions".warn; };
		times = times ?? { Array.fill(positions.size - 1, {defaultTime}) };
		if( times.size == 0 )
			{ times = Array.fill(positions.size - 1, { times }) };
		if(times.size != (positions.size - 1))
			{ "WFSPath : changed times-array length to fit.".warn;
				times.extend(positions.size - 1, defaultTime)  };
				
		if(name.isNil) { name = "New_*" };
		if(name.asString.contains( "*" ) ) { name = 
			name.asString.findReplaceAll( "*", (nameIndex = nameIndex + 1) ); 
			};
			
		name = name.asSymbol;
		
		^super.newCopyArgs(positions, times, name, azPositions, 
			[positions, times, name],  // backup
			[nil, nil], [false, false]); // buffers
	}
	
	*newAZ { |azPos, times, z=0, name|
		var positions;
		positions = WFSTools.azToXY(azPos);
		positions = positions.flop.add( z.asCollection ).flop;
		^WFSPath(positions, times, name, azPos);
		}
			
	*circle { arg nPoints = 35, center = 0, radius = 1, startAngle = 0, complete = 1, 
		scaleEnd = 1, close = false, length = 1, name; //2D
			var scaleAmount = 1, outPoints, azPos;
			//scaleEnd = 1 - ((1 - scaleEnd) / nPoints);
			if(center.isWFSPoint) { center = [center.x, center.y] };
			if(center.size != 2, { center = [center, center] });
			if(((complete != 1) or: (scaleEnd != 1)) or: close) 
				{outPoints = nPoints + 1} {outPoints = nPoints};
			azPos = Array.fill(outPoints, {arg i;						scaleAmount = blend(scaleAmount * scaleEnd, scaleAmount, 1/nPoints);
						[startAngle + ((i * (360.0 / nPoints)) * complete), 
							radius * scaleAmount];
						});
			name = name ??  { name = ("Circle_" ++ (nameIndex = nameIndex + 1)).asSymbol; }; 			^WFSPath( WFSTools.azToXY(azPos) +.t center, name: name).length_( length )
		}
	
	*ellipse { |nPoints = 35, center = 0, radius = 1, startAngle = 0, complete = 1, 
		scaleEnd = 1, moveEnd = 0, close = false, length = 1, name|
		// better version of *circle:
		// - radius,  can be Number, [x,y], Point or WFSPoint
		var points, times, end;
		if( close ) { nPoints = nPoints + 1 };
		radius = radius.asWFSPoint;
		center = center.asWFSPoint;
		scaleEnd = scaleEnd.asWFSPoint;
		moveEnd = moveEnd.asWFSPoint;
		startAngle = (startAngle / WFSPath.azMax) * 2pi;
		complete = complete * 2pi;
		
		if( close ) 
			{ end = (complete + startAngle) }
			{ end = (complete + startAngle) - ( complete / (nPoints - 1) ) };
			
		points = ( startAngle,  startAngle + ( complete / (nPoints - 1) ) .. end );
		
		points = points.collect({ |item, i|
			var scaleAmt, moveAmt;
			
			if( (scaleEnd.x != 1) or: (scaleEnd.y != 1) )
				{ scaleAmt = [1,1].blend( [scaleEnd.x, scaleEnd.y], (i/(points.size - 1)));  }
				{ scaleAmt = [1,1] };
			if( (moveEnd.x != 0) or: (moveEnd.y != 0) )
				{ moveAmt = [0,0].blend( [moveEnd.x, moveEnd.y], (i/(points.size - 1)));  }
				{ moveAmt = [0,0] };
			
			[	(item.sin * (radius.x * scaleAmt[0] )) + center.x + moveAmt[0], 
				(item.cos * (radius.y * scaleAmt[1])) + center.y + moveAmt[1] ]; 
			});
			
		times = { length/nPoints } ! (points.size - 1);
		name = name ??  { name = ("Ellipse_" ++ (nameIndex = nameIndex + 1)).asSymbol; }
		^WFSPath( points, times, name );
		}
	
	*rand { arg nPoints = 10, radius = 1.0, length = 1, name, seed; //simple 2D rand
		var times;
		name = name ??  { name = ("Random_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		times = Array.rand(nPoints - 1, 0.0, 1.0).normalizeSum * length;
		^WFSPath( WFSPointArray.rand(nPoints, radius, seed), times, name )
		}
		
	*randS {  // seeded rand -- default seed = 0
		 arg nPoints = 10, radius = 1.0, seed = 0, length = 1, name; //simple 2D rand
		var times;
		name = name ??  { name = ("RandS"++ seed ++ "_" ++ 
			(nameIndex = nameIndex + 1)).asSymbol; };
		times = Array.rand(nPoints - 1, 0.0, 1.0).normalizeSum * length;
		^WFSPath( WFSPointArray.rand(nPoints, radius, seed), times, name )
		}
	
	*rand3D { arg nPoints = 10, min= -1.0, max= 1.0, length = 1, name; //simple 2D rand
		var times;
		name = name ??  { name = ("Random3D_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		times = Array.rand(nPoints - 1, 0.0, 1.0).normalizeSum * length;
		^WFSPath( WFSPointArray.rand3D(nPoints, min, max), times, name )
		}
		
	*generate { arg nPoints = 10, fillFunc, name, timeMode='delta';  
		// fillfunc should return [WFSPoint,time]
		// timemode can be 'delta' or 'timeLine'
		// for 'delta' last time result is not used
		// arguments passed are:
		// index, alreadyGeneratedPoints, alreadyGeneratedTimes
		var outPoints, outTimes, new;
		
		if( fillFunc.isNil ) { fillFunc = { |i, pointsArray, timesArray|
			var outPoint, outTime; // random walk function
			outPoint = WFSPoint.rand(1.0) + ( pointsArray.last ? WFSPoint(0,0,0) );
			outTime = (0.25.rand2 +  ( timesArray.last ? defaultTime ) ).abs;
			[outPoint, outTime] }; 
			};
			
		name = name ??  { name = ("Gen_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		
		outPoints = [];
		outTimes = [];
		
		nPoints.do({ |i| new = fillFunc.value(i, outPoints, outTimes);
			outPoints = outPoints.add( new[0] );
			outTimes = outTimes.add( new[1] ? defaultTime );
			});
		
		if(timeMode != 'delta')
			{ ^WFSPath( outPoints, name: name )
				.timeLine_( WFSTools.validateTimeLine(outTimes) ); }
			{ ^WFSPath( outPoints, outTimes[..(outTimes.size - 2)], name); };

		}
	
	*spiral { |nPeriods = 5, res = 10, startSize = 1, endSize = 0.1, length, name|
		var size, levels, points, times; 
		size = (nPeriods * res).ceil.asInteger + 1;
		points = Array.fill(size, { |i|
			(i / res) * 2pi
					});
		levels =  (Array.fill(size, { |i|
			(1 - (i / size))
					}) * (startSize - endSize)) + endSize;
					
		points = [points.sin, points.cos] *.t levels;
		
		if(length.isNil) { length = nPeriods };
		name = name ??  { name = ("Spiral_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		
		^WFSPath( points.flop, name: name).length_(length)
		}
		
	*lissajous { arg nPoints = 10, periodsX = 1, periodsY = 2, 
			phaseX = 0, phaseY = 0, radius = 1, length, name;
		var vws, points, out;
		points = Array.fill(nPoints, { |i|
					i / (nPoints - 1) });
		points = [
			(((points * periodsX) + phaseX) * 2pi).sin,
			(((points * periodsY) + phaseY) * 2pi).sin ] * radius;
			
		name = name ??  { name = ("Lissa_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		out = WFSPath( points.flop, name: name);
		if(length.notNil) {out.length_( length ) };
		
		^out;
		}
	
	*line { arg nPoints = 5, start = 0, angle = 0, speed = 1, acc = 0.75, deltaTime, name;
		var points, times;
		deltaTime = deltaTime ? defaultTime;
		name = name ?? { name = ("Line_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		points = WFSPointArray.accLine( start, angle, speed/deltaTime, acc, nPoints );
		times = Array.fill( nPoints - 1, { deltaTime });
		^WFSPath( points, times, name );
		}
	
	*rect { |left = -1, top = 1, width = 2, height = 2, cr = 0, cd = 5, length, name| 
		// cr: rounded corner radius; cd: rounded corner division
		var points, times, deltaTime;
		name = name ?? { name = ("Rect_" ++ (nameIndex = nameIndex + 1)).asSymbol; };
		if( cr == 0 )
			{points = WFSPointArray[ 
				WFSPoint( left, top ), WFSPoint( left + width, top ), 
				WFSPoint( left + width, top - height), WFSPoint( left, top - height ),
				WFSPoint( left, top ) ];
			}
			{ 
			cr = cr.asWFSPoint;
			points = //WFSPointArray[ WFSPoint( left + cr, top ) ] ++
				WFSPath.ellipse( cd, WFSPoint( left + cr.x, top - cr.y ), 
					[cr.x, cr.y], 270, 0.25, close: true, name: "Temp" ).positions ++
				WFSPath.ellipse( cd, WFSPoint( (left + width) - cr.x, top - cr.y ), 
					[cr.x, cr.y], 0, 0.25, close: true, name: "Temp" ).positions ++
				WFSPath.ellipse( cd, WFSPoint( (left + width) - cr.x, (top - height) + cr.y ), 
					[cr.x, cr.y], 90, 0.25, close: true, name: "Temp" ).positions ++
				WFSPath.ellipse( cd, WFSPoint( left + cr.x, (top - height) + cr.y ), 
					[cr.x, cr.y], 180, 0.25, close: true, name: "Temp" ).positions ++
				[ WFSPoint( left, top - cr.y) ]
			};
		if( length.isNil )
			{ deltaTime = defaultTime; }
			{ deltaTime = length / (points.size - 1) };
					
		times = Array.fill( points.size - 1, { deltaTime });
		^WFSPath( points, times, name ).equalSpeeds;
		}
		
	*fromRect { |rect, cr, cd = 5, length, name, flip = true| 
		// flip for correct conversion to WFSPoint
		rect = rect.asRect;
		if( flip ) { rect.left = rect.left * -1 };
		^WFSPath.rect( rect.left, rect.top, rect.width, rect.height, cr, cd, length, name );
		}
		
	edit { WFSPathEditor.add( this ) }
	
	*fromEditor { |index|
		if(index.isNil)
			{ ^WFSPathEditor.current; }
			{ ^WFSPathEditor.paths[index] };
		}
		
	*current { ^WFSPathEditor.current }
		
	*newFrom { |aWFSPath|
		^this.new( aWFSPath.positions.collect( _.copy ), aWFSPath.times, aWFSPath.name );
		}
		
	copyNew { ^this.class.newFrom( this ); }
	
	fix { backup = [positions.copy, times.copy, name]; ^this } // keep changes
	undo {  #positions, times, name = backup; ^this } // undo changes since last fix
	
	backup { ^WFSPath( *backup ) }
	
	
	name_ { |newName| 
		if(newName.isNil) { newName = "New_*" };
		if(newName.asString.contains( "*" ) ) { newName = 
			newName.asString.findReplaceAll( "*", (nameIndex = nameIndex + 1) ); 
			};
			
		name = newName.asSymbol;
		}

	
	
	asEnvViewInput { |autoScale = true, fromRect|
		^positions.asWFSPointArray.asEnvViewInput(autoScale, fromRect)
		}
	
	*fromEnvViewInput { | input, times, name | 
		^WFSPath( input.flop, times, name ); }
	
	fromEnvViewInput { | input, autoScale = true| // back from envelope view
		var originalRect;
		originalRect = this.backup.positions.asRect;
		positions = input.flop.asWFSPointArray;
		if( autoScale )
			{  positions = positions.scaleFromRect( Rect(0,0,1,1), originalRect ); };
		^this;
		}		
	
	plot { var a, b, c, d, e;
		a = SCWindow("WFSPath '" ++ name ++ "'", Rect(200 , 450, 410, 435), false);
		a.view.decorator =  FlowLayout(a.view.bounds);
		b = SCEnvelopeView(a, Rect(0, 0, 400, 400))
			.thumbSize_(5)
			.drawLines_(true)
			.fillColor_(Color.green)
			.selectionColor_(Color.red)
			.drawRects_(true)
			.value_(this.asEnvViewInput(true) )
			.setEditable(-1,false);
		c = SCButton(a, Rect(0,0,60,20)).states_( [["refresh"]] )
			.action_({ b.value_(this.asEnvViewInput(true) )});
		d = SCButton(a, Rect(0,0,60,20)).states_( [["edit"]] )
			.action_({ a.close; this.simpleEdit; });
		e = SCButton(a, Rect(0,0,180,20)).states_( [["add to WFSPathEditor"]] )
			.action_({ this.edit; });
		^a.front;
		}
	
	simpleEdit {  
		// use undo to undo changes
		var a, b, c, d, e;
		this.fix;
		a = SCWindow("Edit WFSPath '" ++ name ++ "'", Rect(200 , 450, 410, 435), false);
		a.view.decorator =  FlowLayout(a.view.bounds);
		b = SCEnvelopeView(a, Rect(0, 0, 400, 400))
			.thumbSize_(5)
			.drawLines_(true)
			.fillColor_(Color.yellow)
			.selectionColor_(Color.red)
			.drawRects_(true)
			.value_(this.asEnvViewInput(true) )
			.setEditable(-1,true)
			.action_({ |view| this.fromEnvViewInput(view.value, true); });
		c = SCButton(a, Rect(0,0,60,20)).states_( [["undo"]] )
			.action_({ this.undo; b.value_(this.asEnvViewInput(true) )});
		d = SCButton(a, Rect(0,0,60,20)).states_( [["fix"]] )
			.action_({ this.fix; b.value_(this.asEnvViewInput(true) )});		e = SCButton(a, Rect(0,0,180,20)).states_( [["add to WFSPathEditor"]] )
			.action_({ a.close; this.plot; this.edit; });
		a.front;
		^this;
		}
		
	resetTempPlotPath { tempPlotPath = nil; }
	
	asRect { ^this.positions.asWFSPointArray.asRect }
	
	plotSmoothInput { |size, color, pointsColor, lineOnly = false, div=10, 
		intType=\hermite, pointOnly = false, fromRect, onlyShowWhenActive=true, pointRadius = 3|
	
		var path, tempPath2, firstPoint, show = true, showPoint = true;
		
		size = size ? 400;
		
		//Pen.setSmoothing( false );
		
		
		if( onlyShowWhenActive ) { if( (currentTime < 0) or: 
			{ currentTime > this.length } ) { showPoint = false } };
		
		
		if( show )
			{ if( pointOnly.not )
				{
					color = color ? Color.white.alpha_(0.4);
					pointsColor = pointsColor ? Color.red.alpha_(0.5);
					
					path = this.asEnvViewInput(true, fromRect);
					path = [path[0], 1 - path[1]];
					
					
					tempPlotPath = 
						path.collect({ |item|
								item.interpolate( div, intType, false ) });
								
					tempPath2 = ( tempPlotPath * size ).flop
							.collect({ |item| item[0]@item[1] });
							
					if( lineOnly.not )
					 { path = ( path * size ).flop
							.collect({ |item| item[0]@item[1] });
							
						// points
						pointsColor.set;
						path.do({ |item|
							Pen.moveTo( item + (pointRadius@0) ); 
							Pen.addArc( item, pointRadius, 0, 2pi ) });
						Pen.stroke; 
					 };
						
					// line
					firstPoint = tempPath2.removeAt(0);
					color.set;
					Pen.moveTo( firstPoint );
					tempPath2.do({ |item| Pen.lineTo( item ); });
					Pen.stroke;
				};
			
			// current point
			
			if( showPoint )
				{ this.atCurrentTime( intType, false )
						.plotSmoothInput( size, Color(1, 0.75, 0.75, 0.75), 
					fromRect: fromRect ?? { this.asRect } ); };
			this.center.plotSmoothInput( size, Color(0.5, 0.3, 0.8, 0.65), 
					fromRect: fromRect ?? { this.asRect } );
				
			};
			
		^path;
		
		}
	
	plotSmooth { |lineOnly = false, div = 10, pointOnly = false, 
		intType = 'hermite', speakerConf = \default, onlyShowWhenActive=false,
			toFront= true| 
			// hermite interpolated
		
		var path, path2, fromRect;
		var originalCurrentTime;
		//var routine;
		
		plotWindow = WFSPlotSmooth( "WFSPath", toFront: toFront, removeButtons: false );
		
		/* if( plotWindow.isNil or: { plotWindow.dataptr.isNil } )
		  {	plotWindow = SCWindow(name, Rect(128, 64, 400, 400)).front;
			plotWindow.view.background_(Color.black );
			} { plotWindow.front };
		*/
	
		plotWindow.onClose_({ if( routine.notNil ) { routine.stop }; plotWindow = nil});
		
		originalCurrentTime = currentTime;
		
		//if( plotWindow.view.children.asCollection
		//		.select({ |vw| vw.class == RoundButton })[0].isNil )
		if( WFSPlotSmooth.playButton.isNil )
			{  WFSPlotSmooth.playButton = 
					RoundButton(plotWindow, Rect( plotWindow.view.bounds.width - 25,5,20,20) )
				.states_( [ 
					[ \play, Color.white,Color.white.alpha_(0.25)],
					[ \stop, Color.white,Color.red.alpha_(0.25) ],					[ \return, Color.white,Color.green.alpha_(0.25)]
					] )
				.resize_( 3 );
			};
	
		//plotWindow.view.children.select({ |vw| vw.class == RoundButton })[0]
		WFSPlotSmooth.playButton
			.value_( 0 )
			.action_({ |button|
					case { button.value == 1 }
						{	routine = Routine({ 
							(((this.length - currentTime) / 0.05) + 1).do({ |i|
								currentTime = (currentTime + 0.05).min( this.length );
								{ plotWindow.refresh }.defer;
								0.05.wait; });
								
								{button.value = 2}.defer;
								
							}).play; }
						{ button.value == 2 }
						{ routine.stop; }
						{ button.value == 0 }
						{ currentTime = originalCurrentTime; plotWindow.refresh; };
					})
			.value_( 0 );
		
		tempPlotPath = nil;
		
		fromRect = this.asRect;
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
			
		if( speakerConf.notNil )
				{ fromRect = fromRect.union( speakerConf.asRect ) };
		
		WFSPlotSmooth.view.drawFunc = { var tempPath, tempPath2, firstPoint, bounds;
			bounds = [plotWindow.view.bounds.width, plotWindow.view.bounds.height]; 
			bounds = bounds.minItem;
			
			( "size:" + this.size + "points\nlength:" + this.length ++ "s\n" ++
			"avg. speed:" + this.avgSpeed.round(0.01) ++ "m/s (" ++ 
				(this.avgSpeed * 3.6).round(1) ++ "km/h)\n" ++
			"radius:" + this.maxRadius.round(0.01) ++ "m\ncenter:" + 
				this.center.x.round(0.01) ++ "@" ++
				this.center.y.round(0.01)  )
				.drawAtPoint(1@0, Font( "Monaco", 9 ), Color.white.alpha_(0.5) );
			
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };

			this.plotSmoothInput( bounds, lineOnly: lineOnly, div: div, 
				pointOnly: pointOnly, intType: intType, 
				onlyShowWhenActive: onlyShowWhenActive,
				fromRect: fromRect
				  );
			
			};
			
		WFSPlotSmooth.view.mouseDownAction_(nil).mouseMoveAction_(nil);	
			
		plotWindow.refresh;
	}
	
	animate { |pointOnly = false, frameRate = 40, rate = 1, resetAfter = nil|
		var currentTimeCopy, frameDur;
		this.plotSmooth( pointOnly: pointOnly );
		currentTimeCopy = currentTime.copy;
		frameDur = 1/frameRate;
		routine = Routine({ 
			((currentTimeCopy, (frameDur + currentTimeCopy) .. this.length) ++ [ this.length ])
				.do({ |item, i|
					currentTime = item;
					{ plotWindow.refresh; }.defer;
					(frameDur / rate).wait;
				});
			
			{ plotWindow.view.children[0].value = 2; }.defer;
				 
			if( resetAfter.notNil && { resetAfter != inf } )
				{ resetAfter.wait; currentTime = currentTimeCopy;
					 {  plotWindow.view.children[0].value = 0;  plotWindow.refresh; }.defer; 
				 };
				
			}).play;
			
		plotWindow.view.children[0].value = 1;
		
		}
	
	isWFSPath { ^true }
	asWFSPath { ^this }
	
	asWFSPathArray { ^WFSPathArray[ this ] }
	asWFSPointArray { ^positions.asWFSPointArray  }
	
	dup { |n = 2|
		^WFSPathArray.fill(n, { this.copy })
		}
		
	add { |aWFSPoint, aTime, newName|
		^WFSPath( positions ++ [aWFSPoint.asWFSPoint], times.add( aTime ? defaultTime ), newName );
		}
	
	at { |index| ^positions[index]; }
	first { ^positions.first; }
	last { ^positions.last; }
	
	intAt { |index = 0, type = 'linear', loop=true, extra|
		^positions.intAt( index, type, loop, extra );
		}
		
	// shortcuts
	atL { |index, loop=true| ^this.intAt(index, 'linear', loop) }
	atQ { |index, loop=true| ^this.intAt(index, 'quad', loop) }
	atH { |index, loop=true| ^this.intAt(index, 'hermite', loop) }
	atS { |index, loop=true, extra|  ^this.intAt(index, 'spline', loop, extra) }
	atSin { |index, loop=true|  ^this.intAt(index, 'sine', loop) }
	
	timeAt { |index| ^times[index]; }
	
	interpolate { |division = 10, type = 'hermite', loop = false, extra|
		positions = positions.interpolate( division, type, loop, extra );
		this.forceTimeLine = this.timeLine.interpolate( division, 'linear', false, extra );
		 /// to do
		}
		
	positions_ { |newPositions|	positions = newPositions.asWFSPointArray; }
	
	put { |index, aWFSPoint| positions.put(index, aWFSPoint.asWFSPoint) }
				
	times_ {	|timesArray| // size doesn't matter
		timesArray = timesArray.asCollection;
		times = times.collect({ |item, i| timesArray[i] ? item });
		^this
		}
		
	forceTimes { |timesArray|
		times = timesArray.asCollection;
		}
		
	scaleTimes { |scale = 1| times = times * scale; ^this; }
	
	avgTime { ^times.sum / times.size }  // average deltaTime
	
	getEqualTimes { |amount = 1|
		var avgTime;
		avgTime = this.avgTime;
		^times.blend( avgTime.dup(times.size), amount );
		}
	
	equalTimes { |amount = 1| times = this.getEqualTimes( amount ); }
		
	getEqualSpeeds { |amount = 1|
		var avgSpeed = this.avgSpeed;
		^times.blend( this.distances / avgSpeed, amount );
		}
		
	equalSpeeds { |amount = 1| times = this.getEqualSpeeds( amount ); }
	
	equal { |timesAmt = 0, speedsAmt = 0|
		var eqt = 0, eqs = 0;
		if( ( timesAmt + speedsAmt) > 1)
			{ #timesAmt, speedsAmt = [timesAmt, speedsAmt].normalizeSum(1) };
		if( timesAmt != 0 )
			{ eqt = this.getEqualTimes };
		if( speedsAmt != 0 )
			{ eqs = this.getEqualSpeeds };
		times = (eqt * timesAmt) + (eqs * speedsAmt) + 
			( times * ( 1 - ( timesAmt + speedsAmt ) ) );
		}

	length { ^times.sum; } // total time
	
	length_ { |newLength|
		times = (times / times.sum) * newLength;
		^this }
	
	timeLine {  arg startAt = 0; // absolute times 
		^[startAt] ++ times.collect({ arg item; startAt = item + startAt; startAt }); }
	
	timeLine_ { |inTimeLine| // size should be at least 2
		var timesArray;
		if(inTimeLine.size < 2) { "WFSPath-timeline_ : size should be at least 2".warn };
		timesArray =  { |i| inTimeLine[i + 1] - inTimeLine[i] } ! (inTimeLine.size - 1);
		times = times.collect({ |item, i| timesArray[i] ? item });
		^this;
		}
		
	forceTimeLine_ { |inTimeLine| // size should be at least 2
		var timesArray;
		if(inTimeLine.size < 2) { "WFSPath-timeline_ : size should be at least 2".warn };
		timesArray =  { |i| inTimeLine[i + 1] - inTimeLine[i] } ! (inTimeLine.size - 1);
		times = timesArray;
		^this;
		}
	
	stopAtTime { |timeToStopAt|
		var lastIndex, newPositions, newTimes;
		timeToStopAt = timeToStopAt ? this.length;
		lastIndex = this.indexAtTime( timeToStopAt );
		if( this.timeLine[ lastIndex ] == timeToStopAt )
			{	positions = positions[..lastIndex];
				times = times[..(lastIndex-1)];
			}
			{	newTimes = this.times[..(lastIndex-1)] ++ 
					[ timeToStopAt - this.timeLine[ lastIndex ]  ];
				newPositions = positions[..lastIndex] ++ [ this.atTime( timeToStopAt ) ];
				times = newTimes;
				positions = newPositions;	
			};
		}
		
	extend { |addTime = 1.0| // straight line from last point
		positions = positions ++ [ 
			positions.last.copy.moveAZ(
				positions.last.angleFrom( positions[ positions.size - 2 ] ),
				this.speeds.last * addTime );
				];
		times = times ++ [ addTime ];
		}
		
	size { ^positions.size }
		
	x { ^positions.collect( _.x ); }
	y { ^positions.collect( _.y ); }
	z { ^positions.collect( _.z ); }
	
	x_ { |xArray| // size doesn't matter..
		xArray = xArray.asCollection;
		positions = positions.collect({ |item, i| item.x = xArray[i] ? item.x; item })
			.asWFSPointArray;
		^this;
		}
		
	y_ { |yArray| 
		yArray = yArray.asCollection;
		positions = positions.collect({ |item, i| item.y = yArray[i] ? item.y; item })
			.asWFSPointArray;
		^this;
		}
		
	z_ { |zArray| 
		zArray = zArray.asCollection;
		positions = positions.collect({ |item, i| item.z = zArray[i] ? item.z; item })
			.asWFSPointArray;
		^this;
		}
		
	reversePositions { positions = positions.reverse; ^this }
	reverseTimes { times = times.reverse; ^this }
	
	reverse { positions = positions.reverse; times = times.reverse; ^this }

	distances { ^positions.asWFSPointArray.distances } // between points
	angles { ^positions.asWFSPointArray.angles }
	
	speeds { ^this.distances / times } // speeds in m/s
	speedsKMH { ^this.speeds * 3.6 }   // speeds in km/h  ;-)
	avgSpeed { ^this.speeds.sum / times.size } //avarage speed per node (rms)
	
	avgSpeed2 { ^(( this.speeds * times ).sum / times.sum ) }

	asXYArray {  ^positions.collect({ |item| [item.x,item.y] }); } //2D
	asXYZArray {  ^positions.collect({ |item| [item.x,item.y,item.z] }); }
	asXYZTArray { var timeLine;
		timeLine = this.timeLine;
		^positions.collect({ |item, i| [item.x,item.y,item.z, timeLine[i] ] }); }
	
	center { ^WFSPoint( *this.asXYZArray.flop.collect{ |item| item.sum / item.size } ); }
	
	asAZArray { arg center = 0;  // azimuth/distance -- 2D
			^positions.collect({ |item|
				var azimuth, distance, xx, yy;
				#xx, yy = [item.x, item.y] - center;
				azimuth = atan2(xx,yy) % 2pi; //theta
				distance = hypot(xx,yy); //rho
				if(azMax != 2pi, {azimuth = (azimuth / 2pi) * azMax});
				[azimuth, distance];
				});
			}
	
	calculateAZ { azPositions = this.asAZArray(0); }
	azPositions { arg refresh=false; // externally keep track of need to refresh!!
		if(azPositions.isNil or: refresh)
			{ this.calculateAZ };
		^azPositions;
		}
		
	storedAZPositions { ^azPositions; } // for testing
	
	scale { arg scale, center; 
		center = center ?? { this.center; };
		scale = scale.asWFSPoint;
		positions = positions.collect( _.scale(scale, center) ).asWFSPointArray;
		^this;
		}
	
	scale2D { arg scale, center;  //z remains the same when only 1 ratio is provided
		center = center ?? { this.center; };
		scale = scale.asWFSPoint(2);
		positions = positions.collect( _.scale(scale, center) );
		^this;
		}
	
	maxRadius { ^positions.asWFSPointArray.maxRadius } // 2D
	
	scaleTo { |newRadius = 1|
		var scaleFactor, center;
		scaleFactor = newRadius / this.maxRadius;
		positions = positions.collect( _.scale(scaleFactor, this.center) ).asWFSPointArray;
		^this;
		}
	
	move { arg delta;
		delta = delta.asWFSPoint;
		positions = positions.collect( _.move(delta) ).asWFSPointArray;
		^this;
	}
	
	rotate { |amount = 0, center| // slow?
		var azTemp;
		center = center ?? { this.center } ;
		if(center.class == WFSPoint)	
			{ center = [center.x, center.y]; };
		azTemp = this.asAZArray(center).flop;
		azTemp = azTemp + [amount, 0];
		/* positions = WFSTools.makeWFSPointsArray(
			WFSTools.azToXY(azTemp.flop, center)); */
		positions = WFSTools.azToXY(azTemp.flop, center).asWFSPointArray;	
		^this;
		}
	
	transformPositions { |move = 0, scale = 1, rotate = 0, reverse= false, center| //2D
		var z;
		z = this.z;
		center = center ?? { this.center };
		this.move(move);
		this.scale(scale, center);
		this.rotate(rotate, center);
		this.z = z;
		if(reverse) { this.reversePositions; };
		^this;
		}
	
	transform { |move = 0, scale = 1, rotate = 0, reverse = false, scaleTimes = 1, center|
		this.transformPositions(move, scale, rotate, reverse, center);
		this.scaleTimes(scaleTimes);
		if(reverse) { this.reverseTimes; };
		^this;
		}
	
	dupTransform { |n = 2, move = 0, scale = 1, rotate = 0, 
			reverse = false, scaleTimes = 1, center|
		// first dup is not transformed
		var transformedWFSPath;
		transformedWFSPath = this.copy;
		^([this] ++ Array.fill(n - 1, { 
			transformedWFSPath = transformedWFSPath.copy
				.transform(move, scale, rotate, reverse, scaleTimes, center);
			transformedWFSPath }) ).asWFSPathArray;
		}
	
	round { |value = 0|
		^WFSPath( positions.collect( _.round(value) ), times, name);
		}
		
	explode { |amount = 0, center = 0| // adds amount to distance from center
		positions = WFSPointArray.
			fromAZArray( (positions.asAZArray.flop + [0, amount]).flop, center );
		}
		
	moveStartTo  { | aWFSPoint = 0 | ^this.move( aWFSPoint.asWFSPoint - positions.first ) }
	moveEndTo    { | aWFSPoint = 0 | ^this.move( aWFSPoint.asWFSPoint - positions.last ) }
	moveCenterTo { | aWFSPoint = 0 | ^this.move( aWFSPoint.asWFSPoint - this.center ) }

	xEnv { ^Env( this.x, times) }
	yEnv { ^Env( this.y, times) }
	zEnv { ^Env( this.z, times) }
	
	asEnvs { ^[ this.xEnv, this.yEnv, this.zEnv ] }

	atTime { |time = 0| 
		^WFSPoint( *this.asEnvs.collect( _.at(time) ) ); 
		}
		
	asTimeIndexEnv { ^Env( [0] ++ times.collect({ |time, i| i+1 }), times ); }
	
	indexAtTime2 { |time = 0|
		^this.asTimeIndexEnv.at( time );
		}
		
	atTime2 { |time = 0, intType = 'linear', loop=true, extra|
		^this.intAt( this.indexAtTime2( time ), intType, loop, extra );
		}
		
	atCurrentTime { |intType = 'linear', loop=false, extra| 
		^this.atTime2( ( currentTime ? 0 ).max(0), intType, loop, extra ); }
	
	indexAtTime { |time = 0| // rounded index at time
		^((this.timeLine.detectIndex({ |item| item > time }) ? this.size) - 1).max(0);
		}
	
	lastTimeBefore { |time = 0|
		^this.timeLine[ this.indexAtTime( time ) ];
		}

	lastPointBefore { |time = 0|
		^this.positions[ this.indexAtTime( time ) ];
		}
	
	nextTimeAfter { |time = 0|
		^this.timeLine[ (this.indexAtTime( time ) + 1).min( this.size ) ];
		}
	
	nextPointAfter { |time = 0|
		^this.positions[ (this.indexAtTime( time ) + 1).min( this.size ) ];
		}
	
	resample { |nSamples = 20| // number of equal times
		// linear interpolation (done by Env)
		var envs, timeUnit;
		envs = this.asEnvs;
		timeUnit = this.length / nSamples;
		times = timeUnit.dup(nSamples);
		positions = Array.fill(nSamples + 1, { |i|
			WFSPoint( *envs.collect({ |env| env.at(i * timeUnit) }) );
			});	
		^this;
		}
		
	append { |aWFSPath, crossTime, newName| 
		aWFSPath = aWFSPath.asWFSPath;
		crossTime = crossTime ? defaultTime;
		^WFSPath( positions ++ aWFSPath.positions,
			times ++ crossTime ++ aWFSPath.times, newName ? "Combi_*" )
		}
	
	appendSameSpeed { |aWFSPath, newName|
		// use last speed for crosstime
		^this.append( aWFSPath, 
			( aWFSPath.positions.first.dist( positions.last ) ) / this.speeds.last,
			newName );
		}
	
	++ { |aWFSPath| ^this.append( aWFSPath ) }
	
	loop { |n=1, crossTime = \sameSpeed|
		var outWFSPath;
		outWFSPath = this;
		n.do({ 
			if( crossTime == \sameSpeed )
				{ outWFSPath = outWFSPath.appendSameSpeed( outWFSPath, "Temp" ) }
				{ outWFSPath = outWFSPath.append( outWFSPath, crossTime, "Temp" )  }; 
			});
		outWFSPath.name = (this.name ++ '_L' ++ n).asSymbol;
		^outWFSPath;
		}
				
	glue { |aWFSPath, newName| 
		// connect to another WFSPath, of which the start point is moved to the
		// end point of this one
		aWFSPath = aWFSPath.asWFSPath;
		^WFSPath( positions ++ 
			aWFSPath.copy.moveStartTo( positions.last ).positions[1..],
			times ++ aWFSPath.times, newName ? "Combi_*" )
		}
	
	repeat { |n=1|  // uses glue
		var outWFSPath;
		outWFSPath = this;
		n.do({ outWFSPath = outWFSPath.glue( outWFSPath ) });
		outWFSPath.name = (this.name ++ '_R' ++ n).asSymbol;
		^outWFSPath;
		}
	
	repeatUntil { |time|
		var nRep, out;
		time = time ? this.length;
		nRep = (time / this.length).ceil;
		out = this.repeat( nRep - 1 );
		^out.stopAtTime( time );
		}
		
	blend { |aWFSPointArray, blend=0.5|	
		positions = positions.asWFSPointArray.blend( 
			aWFSPointArray.asWFSPointArray, blend );
		^this; }
		
	loadBuffers { |server, xyzBufnum, tBufnum, loadedAction| // creates buffers for xyz and time
		var posXYZBuffer, timesBuffer;
		
		// server can be array of servers
		buffers = [nil, nil];
		{
		server.asCollection.do({ |oneServer|
			
			buffers[0] = buffers[0].asCollection.add( 
				Buffer.sendCollection( oneServer, positions.asArray.repeatLast(2).flat, 
							// last point is repeated twice for correct interpolation
					3, 
					action: { |thisBuffer|
						buffersLoaded[0] = true;
						if( WFSPan2D.silent.not )
							{  ("XYZ buffer (" ++ 
								thisBuffer.bufnum ++  ") loaded for path" ++ name ).postln; };
						if( buffersLoaded.every( _.value ) )
							{ loadedAction.value };
							} )
					);
							
			buffers[1] =  buffers[1].asCollection.add( 
				Buffer.sendCollection( oneServer, times ++ [inf], // last time is inf; stay at endpoint
					1, 
					action: { |thisBuffer|
						buffersLoaded[1] = true;
						if( WFSPan2D.silent.not ) 
							{("Times buffer (" ++ 
								thisBuffer.bufnum ++  ") loaded for path" ++ name ).postln;  };
						if( buffersLoaded.every( _.value ) )
							{ loadedAction.value };
						} )
					);
				});
		}.fork;
		^this;
		}
	
	buffersLoaded { ^buffersLoaded.every( _.value ) }
	
	timesBuffer { ^buffers[1]; }
	positionsBuffer { ^buffers[0]; }
	
	freeBuffers { buffers.flat.do( _.free );
		buffers = [nil, nil];
		buffersLoaded = [false, false];
		}
	
	resetBuffers {
		if( this.buffersLoaded ) { "WFSPath '%' buffers might have been loaded but lost\n"
				.postf( name ) };
		buffers = [nil, nil];
		buffersLoaded = [false, false];

		}
		
	test { |server, doAtStart, doWhenCanceled, conf| // gives a dialog first
		var def, synth;
			server = server ? Server.default;
			//def = WFSSynthDef( 'linear_blip', conf );
			//def.load( server );
			def = 'linear_blip';

			synth = WFSSynth.play( def, this, server );
			
			SCAlert("play WFSPath" + name.asString.pad($') ++ "?", 
				[ [ "cancel" ], [ "ok" ] ],
				[ 	{ synth.freeBuffers; doWhenCanceled.value; },
					{ synth.run; doAtStart.value; } ] );
			^synth;
		}
		
		
	playWithSoundFile { |path = "sounds/a11wlk01-44_1.aiff", 
			rate = 1, level = 1, loop = false, adjustLength = false, 
			server, doWhenFinished, doWhenCanceled |
		
		// defs need to be loaded ( WFSSynthDef.allTypes.do( _.load ) )
		
		/////////  OLD!!
			
		var def, synth, copiedPath, playFunc, soundFile;
		
		server = server ? Server.default;
		//def = WFSSynthDef( 'linear_buf', conf );
		//def.load( server );
		def = 'linear_buf';
		copiedPath = this.copy;
		
		playFunc = { 
			path = path.standardizePath;
			if( ( soundFile = SoundFile.openRead( path ) ) != false )
				{
				
				if( adjustLength ) { copiedPath.length = soundFile.duration };
				
				synth = WFSSynth.play( def, copiedPath, server, 
					path, rate, level, loop.binaryValue ); 
				
				WFSSynth.clock.sched( 1.01 + copiedPath.length, doWhenFinished );
				
				/*
				SCAlert("play WFSPath" + name.asString.pad($') +"?", 
					[ [ "cancel" ], [ "ok" ] ],
					[ 	{ synth.freeBuffers; doWhenCanceled.value; },
						{ synth.run; doAtStart.value; } ] );
				*/ 
				
				synth;	
				}
				{ "sorry, soundfile not found".postln;  }
			};
				
		if( path.isNil )
			{ CocoaDialog.getPaths(
				 { |paths| path = paths[0]; playFunc.value; },
				 { doWhenCanceled.value; } );
			}
			{ ^playFunc.value;  }
		
		}
							
		
	writeWFSFile { |path, overwrite=false, ask=true|
		 ^[ this ].writeWFSFile(path, name.asString, overwrite, ask)
		 }
		 
	rename {
		SCRequestString( name.asString, "WFSPath : enter a new name",
			{ |string| name = string.asSymbol } );
			}
			
	sortTimes { |func| times.sort( func ); ^this; }
			
	/// sort positions
	
	sort { |func|
		positions.sort( func ); ^this; }
			
	distSort { |wfsPoint = 0| // sort array as absolute distance to point
		positions.distSort( wfsPoint ); ^this;
		}
	
	angleSort { |wfsPoint = 0| // sort array as clockwise angle to point
		positions.angleSort( wfsPoint ); ^this;
		}
		
	angleSort2 { |wfsPoint = 0, angle = 0| // sort array as closest to specified angle from point
		positions.angleSort2( wfsPoint, angle ); ^this;		}
		
	angleSort3 { |wfsPoint = 0, angle = 0| // sort array as closest to specified angle from point
		positions.angleSort3( wfsPoint, angle ); ^this;
		}
		
	nearestPoint { |wfsPoint = 0|
		^positions.nearestPoint( wfsPoint ); }
	
	nearestPointSort { |startPoint|  // destructive -- use .undo to undo
		positions = positions.nearestPointSort( startPoint ); ^this;		}
		
	smallestAngleSort { |startPoint| // destructive -- use .undo to undo
		positions = positions.smallestAngleSort( startPoint ); ^this;
		}	

	
	storeArgs { ^[positions, times, name] }
	
	printOn { arg stream;
			stream << this.class.name << "( '" << name << "', " 
				<< this.length << " )";
		}
	
	flippedPositions { |scale = 1, move = 0|
		^( positions.collect( _.flipY ) * scale ) + move
		}
	
	asSVGPolyLine { |scale = 1, move = 0, strokeColor = "black"| 
		^SVGPolyLine( this.flippedPositions( scale, move )
				.collect( _.asPoint ), name, strokeColor, nil, 1  ); }

	asSVGPath { |scale = 1, move = 0, strokeColor = "black", curve = false|
		^SVGPath.fromSVGPolyLine( this.asSVGPolyLine( scale, move, strokeColor ), curve );
		}
				
	asSVGCircles { |scale = 1, move = 0, r = 3|
		var fillColorArray, flippedPoints;
		flippedPoints = this.flippedPositions( scale, move ).collect( _.asPoint );
		
		fillColorArray = Array.fill(flippedPoints.size, {|i|
					 Color.new(
							(((1 - (i/flippedPoints.size)) * 2) - 0.8).max(0).min(1),
							((i/flippedPoints.size) * 2).fold2(1), 
							(((i/(flippedPoints.size)) * 2 ) - 0.8).max(0).min(1) )
					});
				
		^SVGGroup( flippedPoints.collect({ |point, i|
			SVGCircle( point.x, point.y, r, 
				("p" ++ (i+1) ++ ": (" ++ 
					point.x.round(0.001) ++ ", " ++
					point.y.round(0.001) ++ ")"),
				"none", fillColorArray[i] ) }), "points of " ++ name ); 
		
		}
	
	*centerAsSVGGroup { |scale = 1, move = 0, strokeColor = "gray"|
			var p1, p2, pc;
			scale = scale.asPoint; move = move.asPoint;
			#p1, p2, pc = [Point(1,1), Point(-1,-1), Point(0,0)]
				.collect({ |point| (point * scale) + move; });
			^SVGGroup( [
				SVGCircle( pc.x, pc.y, 0.1 * scale.x, "center", strokeColor, nil, 1),
				SVGLine( p1.x, pc.y, p2.x, pc.y, "centerY(0,0)", strokeColor, nil, 1 ),  
				SVGLine( pc.x, p1.y, pc.x, p2.y, "centerX(0,0)", strokeColor, nil, 1 ) ],
				"center" );
			}
	
	*scaleMessage { |scale = 1|
		^SVGText( ["scale:" + scale ++ "px = 1m"], 0, 12, name: "scale" );
		}
			
	asSVGGroup { |scale = 1, move = 0, includeCenter = true, curve = true|
		^SVGGroup( ( [ this.asSVGCircles( scale, move ), 
					this.asSVGPath( scale, move, curve: curve ) ] ++ 
			( if( includeCenter ) 
				{ [ WFSPath.centerAsSVGGroup( scale, move ) ] }
				{ [] } ) ).reverse,
			name );
		}
	
}