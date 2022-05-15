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

// WFSPathsArray is an array containing only WFSPath objects.
// These objects can be stored in a standardized XML file format
// or converted to SVG (write only) for export to apps like Illustrator


WFSPathArray[slot]: RawArray { 

	isValid { ^this.every( _.isWFSPath ) }
	
	add { arg item; ^super.add(item.asWFSPath) }
	
	put { |index, item| ^super.put(index, item.asWFSPath) }
	
	insert { |index, item| ^super.insert(index, item.asWFSPath) }
	
	++ { |anArray| ^super ++ anArray.asWFSPathArray }
	
	x { ^this.collect( _.x ); }
	y { ^this.collect( _.y ); }
	z { ^this.collect( _.z ); }
	
	times { ^this.collect( _.times ); }
	timeLine {  ^this.collect( _.timeLine ); }
	timeLines {  ^this.timeLine; } // same as above
	
	name { ^this.collect( _.names ); }
	names { ^this.name; } // same as above

	
	fix { ^this.do( _.fix ) }
	undo { ^this.do( _.undo ) }
	backup { ^this.collect( _.backup ) }
	
	glue { // glue all WFSPaths to one
		var out;
		out = this.first;
		this[1..].do({ |item| out = out.glue(item); });
		out.name = ('Glued_' ++ this.size).asSymbol;
		^out;
		}
		
	asWFSPathArray { ^this }
		
	edit { WFSPathEditor.addAll( this ) }
	
	asRect { var outRect;
		outRect = ( this[0] ? Rect(0,0,0,0) ).asRect;
		this.do({ |wfsPath|
			outRect = outRect.union( wfsPath.asRect );
			});
		^outRect;
		}
		
	
	plotSmooth { |lineOnly = false, div = 10, speakerConf = \default, toFront = true|		
		var path, path2;
		var window;
		var fromRect;
		var originalCurrentTimes;
		var maxDuration;
		var routine;
		
		/*
		window = SCWindow("WFSPathArray", Rect(128, 64, 400, 400)).front;
		window.view.background_(Color.black );
		*/
		
		window = WFSPlotSmooth( "WFSPathArray", toFront: toFront, removeButtons: false );
		
		window.onClose_({ if( routine.notNil ) { routine.stop } });
		
		originalCurrentTimes = this.collect( _.currentTime);
		maxDuration = this.collect({ |item| item.length - item.currentTime; }).maxItem;
		
		//if( window.view.children.asCollection.select({ |vw| vw.class == RoundButton })[0].isNil )
		if( WFSPlotSmooth.playButton.isNil )
			{ WFSPlotSmooth.playButton = RoundButton(window, 
						Rect( window.view.bounds.width - 25,5,20,20) )
				.states_( [ 
					[ \play, Color.white,Color.white.alpha_(0.25)],
					[ \stop, Color.white,Color.red.alpha_(0.25) ],					[ \return, Color.white,Color.green.alpha_(0.25)]
					] )
				.resize_( 3 );
			};
	
		WFSPlotSmooth.playButton
			.action_({ |button|
				case { button.value == 1 }
				{ routine = Routine({ ((maxDuration / 0.05) + 1).do({ |i|
						this.do({ |item| item.currentTime = item.currentTime + 0.05; });
						{ window.refresh }.defer;
						0.05.wait; });
						{ button.value = 2 }.defer;
					}).play; }
					
				{ button.value == 2 }
					{ routine.stop; }
				{ button.value == 0 }
				{  this.do({ |item, i| item.currentTime = originalCurrentTimes[i]; });
					window.refresh; }
				})
			.resize_( 3 ); 
					
		this.do( _.resetTempPlotPath );
		fromRect = this.asRect;
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
		
		window.drawHook = { var tempPath, tempPath2, firstPoint, bounds;
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
			
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };
			
			this.do({ |wfsPath|
				wfsPath.plotSmoothInput( bounds, lineOnly: lineOnly, div: div, 
					fromRect: fromRect  ); 
				});
			};
			
		window.refresh;
	
		}
	
	*fromEditor { ^WFSPathEditor.paths; }
}