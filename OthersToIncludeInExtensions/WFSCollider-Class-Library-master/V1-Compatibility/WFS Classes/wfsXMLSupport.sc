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

+ WFSPath_Old {
	asDOMElement { arg d, root;
		 	// var wfsPath;
			var wfsPathString = "", wfsPathTag;
		    	var lastTime = 0, rawValues, t;
		    //	wfsPath = this;
		   		rawValues = (this.asXYZArray.flop ++ [this.timeLine]).flop;
		    		rawValues.do({ arg line;
		    			var lineString = "";
		    			line.do({ arg item;
		   				lineString = lineString ++ 
		   					(item.round(1e-12).asString ++ ",")
		   						.extend( 
		   							21.max( item.round(1e-12).asString.size + 1 ), $ ); });
					wfsPathString = wfsPathString ++ "\n\t" ++ lineString;
		   			});
		    		wfsPathTag = d.createElement("path");
		    		wfsPathTag.setAttribute( "name" , name.asString );
		    		wfsPathTag.setAttribute( "dur" , this.length.asString );
		    		wfsPathTag.setAttribute( "size" , this.size.asString );
		    		wfsPathTag.setAttribute( "type" , "absolute" );
		    		t = d.createTextNode(wfsPathString ++ "\n        "); 
		   		wfsPathTag.appendChild(t); 
		    		^root.appendChild(wfsPathTag); 
			}
			
	*fromDOMElement { arg tag;
				var values, positions, times, newWFSPath;
				values = ("[" ++ tag.getText ++ "]").interpret.clump(4).flop;
				positions = values.at([0,1]).flop;
				newWFSPath = this.new(positions, name: tag.getAttribute("name")); 
				times = values[3];
				if(tag.getAttribute("type").asSymbol == 'absolute')
					{ newWFSPath.timeLine = times }
					{ newWFSPath.times = times };
				^newWFSPath; 
			}
		
		}

+ WFSPoint {

	asDOMElement { arg d, root;
			var  wfsPointTag;
			wfsPointTag = d.createElement("point");
		    	wfsPointTag.setAttribute( "x" , x.asString );
		    	wfsPointTag.setAttribute( "y" , y.asString );
		    	wfsPointTag.setAttribute( "z" , z.asString );
		    	^root.appendChild( wfsPointTag ); 
			}
		
	*fromDOMElement { arg tag;
		^this.new( 
			tag.getAttribute("x").interpret ? 0,
			tag.getAttribute("y").interpret ? 0, 
			tag.getAttribute("z").interpret ? 0 );
		}
	}
		
+ WFSPlane {

	asDOMElement { arg d, root;
			var  wfsPointTag;
			wfsPointTag = d.createElement("plane");
		    	wfsPointTag.setAttribute( "angle" , this.angle.asString );
		    	wfsPointTag.setAttribute( "distance" , distance.asString );
		    	^root.appendChild( wfsPointTag ); 
			}
	
	*fromDOMElement { arg tag;
		    	^this.new(
		    		tag.getAttribute("angle").interpret ? 0,
				tag.getAttribute("distance").interpret ? 0
		    		);
			}
			
		}
		
+ WFSPathArray {
	
	*readWFSFile {arg path = "~/scwork/wfsPathsTest.xml";
		var document, file, wfsPaths, lastTime = 0;
		document = DOMDocument.new;
		file = File(path.standardizePath, "r");
		document.read(file);
		
		wfsPaths = 
			(document.getDocumentElement.getElementsByTagName("path") ++
			 document.getDocumentElement.getElementsByTagName("movement"))
			 	.collect({ |tag| WFSPath_Old.fromDOMElement( tag ) });
		^super.with(*wfsPaths)
		}
		
	writeWFSFile {arg path = "~/scwork/wfsPathsTest.xml", name="example", 
			overwrite= false, ask= true;
		var root, wfsPathsTag, wfsPathTag;
		var nameTag,d,f;
		d = DOMDocument.new; // create empty XML document
		root = d.createElement("xml:wfs");
		d.appendChild(root);
		nameTag = d.createElement("name");
		nameTag.appendChild(d.createTextNode(name));
		root.appendChild(nameTag);
		
		this.asDOMElement( d, root );
			
		if(path.notNil)
			{ File.checkDo( 
				PathName(path).extension_( "xml").fullPath, //force xml extension
				{ |f| d.write(f); }, overwrite, ask) // output to file with default formatting
			};
		^d.format;
		}
		
	asDOMElement { arg d, root;
			var wfsPathsTag;
			wfsPathsTag = d.createElement("patharray");
			this.do({ arg wfsPath, index;
				wfsPath.asDOMElement( d, wfsPathsTag );		    		});
			^root.appendChild(wfsPathsTag);			
		}
	
	*fromDOMElement { |tag|
		super.with( *(
			tag.getElementsByTagName("path") ++ 
			tag.getElementsByTagName("movement"))
			 	.collect({ |subtag| WFSPath_Old.fromDOMElement( subtag ) }) );
		}
		
	}
	
	
+ WFSScore {
	
	asDOMElement { arg d, root;
		var wfsScoreTag, nameTag;
		wfsScoreTag = d.createElement("score");
		
		wfsScoreTag.setAttribute( "name", name );
		
	 
		if( clickTrackPath.notNil ) // clicktrack support added 29/10/08 ws
			{ wfsScoreTag.setAttribute( "clickTrackPath", clickTrackPath ); };
		
		events.do({ arg event; event.asDOMElement( d,  wfsScoreTag ); });
		
		^root.appendChild(wfsScoreTag); 
		}
	
	*fromDOMElement { arg tag;
		var name, events;
		var clickTrackPath; // 29/10/08 ws
		name = tag.getAttribute( "name" );
		clickTrackPath = tag.getAttribute( "clickTrackPath" );  // 29/10/08 ws
		events = tag.getChildNodes.select({ |subTag| subTag.getNodeName == "event" })
			.collect({ |subtag| WFSEvent.fromDOMElement( subtag ); });
		^this.new( *events ).name_( name ).clickTrackPath_( clickTrackPath );  // 29/10/08 ws
		}
		
	writeWFSFile {arg path = "~/scwork/wfsScoreTest.xml",
			overwrite= false, ask= true;
		var root, wfsScoreTag, wfsPathTag;
		var d,f;
		d = DOMDocument.new; // create empty XML document
		root = d.createElement("xml:wfs");
		d.appendChild(root);
			
		this.asDOMElement( d, root );
			
		if(path.notNil)
			{ File.checkDo( 
				PathName(path).extension_( "xml").fullPath, //force xml extension
				{ |f| d.write(f); }, overwrite, ask) // output to file with default formatting
			};
		^d.format;
		}
		
	*readWFSFile {arg path = "~/scwork/wfsScoreTest.xml";
		var document, file, element, lastTime = 0;
		document = DOMDocument.new;
		file = File(path.standardizePath, "r");
		document.read(file);
		
		element = document.getDocumentElement.getElement("score");
		
		if( element.notNil )
			{ ^this.fromDOMElement( element ).filePath_(path) }
			{ "WFSScore-readWFSFile: file doesn't contain a valid <score/> element"
				^nil };
		
		}
	}
	
	
+ WFSEvent {

	asDOMElement { |d, root|
		var wfsEventTag, t;
		wfsEventTag = d.createElement("event");
		wfsEventTag.setAttribute( "startTime" , startTime.asString );
		wfsEventTag.setAttribute( "dur" , this.dur.asString );
		wfsEventTag.setAttribute( "track" , track.asString );
		wfsSynth.asDOMElement( d, wfsEventTag );
		^root.appendChild(wfsEventTag); 
		}
		
	*fromDOMElement { |tag|
		var startTime, wfsSynth, track;
		var scoreTag;
		
		startTime = tag.getAttribute( "startTime" ).interpret;
		track = tag.getAttribute( "track" ).interpret;
		scoreTag = tag.getElement( "score" ); // check if a score is available
		if( scoreTag.notNil )
			{ wfsSynth = WFSScore.fromDOMElement( scoreTag ); }
			{ wfsSynth = WFSSynth.fromDOMElement( tag.getElement( "synth" ) ); };
		
		^this.new( startTime, wfsSynth, track );
		}
	}
	
+ Number { // for 'index' typed events
	
	asWFSDOMElement { |d, root|
		var wfsNumberTag, t;
		wfsNumberTag = d.createElement("number");
		wfsNumberTag.appendChild( d.createTextNode( this.asString ) );
		^root.appendChild( wfsNumberTag ); 
		}
		 
	*fromWFSDOMElement { |tag| // to do
		^tag.getText.interpret;
		}
	
	}
	
+ WFSSynth {
	
	asDOMElement { |d, root|
		var wfsSynthTag, pathElement, argsElement;
		wfsSynthTag = d.createElement("synth");
		wfsSynthTag.setAttribute( "defName" , wfsDefName.asString );
		wfsSynthTag.setAttribute( "dur" , dur.asString );
		wfsSynthTag.setAttribute( "level" , level.asString );
		wfsSynthTag.setAttribute( "fadein" , this.fadeInTime.asString );
		wfsSynthTag.setAttribute( "fadeout" , this.fadeOutTime.asString );
		if( this.useSwitch )
			{ wfsSynthTag.setAttribute( "useSwitch" , this.useSwitch.asString ); };
			
		if( this.prefServer.notNil )
			{ wfsSynthTag.setAttribute( "prefServer" , this.prefServer.asString ); };
		
		if( this.useFocused.not )
			{ wfsSynthTag.setAttribute( "useFocused" , this.useFocused.asString ); };
			
		argsElement = d.createElement("args");
			([ pbRate: pbRate, loop: loop, input: input ] ++ args)
				.pairsDo({ |argName, argValue|
					argsElement.setAttribute( argName.asString, argValue.asString )
			});
			
		wfsSynthTag.appendChild( argsElement );
		
		if( filePath.size > 0 ) 
			{ 	pathElement = d.createElement( "filePath" );
				if( startFrame.notNil && {startFrame != 0} )
					{ pathElement.setAttribute( "startFrame", startFrame.asString ); };
				if( sfNumFrames.notNil && { sfNumFrames != -1 } )
					{ pathElement.setAttribute( "numFrames", sfNumFrames.asString ); };
				if( sfSampleRate.notNil && { sfSampleRate != 44100 } )
					{ pathElement.setAttribute( "sampleRate", sfSampleRate.asString ); };
				pathElement.appendChild( d.createTextNode( filePath.asString ) ); 
				wfsSynthTag.appendChild( pathElement ); };
			
		if( wfsPath.isNumber )
			{ wfsPath.asWFSDOMElement( d, wfsSynthTag ); }
			{ wfsPath.asDOMElement( d, wfsSynthTag ); };
		
		^root.appendChild( wfsSynthTag ); 
		}
		
	*fromDOMElement { |tag|
		var defName, dur, wfsPath, level = 1, fadeTimes, filePath = "";
		var pbRateLoopInput, args, fileElement, startFrame = 0;
		var sfNumFrames, sfSampleRate;
		var useSwitch, prefServer, useFocused;
		
		fadeTimes = [0,0];
		
		pbRateLoopInput = [1,1.0,0]; //initial values for pbRate, loop and input args
		args = [];
		defName = tag.getAttribute( "defName" );
		dur = tag.getAttribute( "dur" ).interpret;
		level = tag.getAttribute( "level" ).interpret;
		fadeTimes[0] = tag.getAttribute( "fadein" ).interpret ? 0;
		fadeTimes[1] = tag.getAttribute( "fadeout" ).interpret ? 0;
		useSwitch = (tag.getAttribute( "useSwitch" ) ? "false").interpret;
		prefServer = (tag.getAttribute( "prefServer" ) ? "nil").interpret;
		useFocused =  (tag.getAttribute( "useFocused" ) ? "true").interpret;
		
		if( (fileElement = tag.getElement( "filePath" )).notNil )
			{ filePath = fileElement.getText;
			  startFrame = fileElement.getAttribute( "startFrame" ).interpret ? 0;
			  sfNumFrames = fileElement.getAttribute( "numFrames" ).interpret;
			  sfSampleRate = fileElement.getAttribute( "sampleRate" ).interpret;
			};
			
		tag.getElement( "args" ).getAttributes
			.keysValuesDo({ |key, value, i|
				var index;
				index = ['pbRate', 'loop', 'input']
					.indexOf( key.asSymbol );
				if( index.notNil )
					{ pbRateLoopInput[ index ] = value.getNodeValue.interpret;  }
					{ args = args ++ [ key.asSymbol, value.getNodeValue.interpret ]; };
				});
		
		if( defName.split( $_ ).first.asSymbol != 'WFS' )
			{ defName = "WFS_" ++ defName; };
			
		case { ( defName.wfsIntType === 'linear') or: ( defName.wfsIntType === 'cubic')}
			{ wfsPath = WFSPath_Old.fromDOMElement( tag.getElement( "path" ) ); }
			{ ( defName.wfsIntType === 'static') }
			{ wfsPath = WFSPoint.fromDOMElement( tag.getElement( "point" ) ); }
			{ ( defName.wfsIntType === 'plane') }
			{ wfsPath = WFSPlane.fromDOMElement( tag.getElement( "plane" ) ); }
			{ ( defName.wfsIntType === 'index') }
			{ wfsPath = Number.fromWFSDOMElement( tag.getElement( "number" ) ); };

		^this.new( defName, wfsPath, nil, filePath, dur, level, 
			pbRateLoopInput[0], pbRateLoopInput[1], pbRateLoopInput[2], args,
			fadeTimes, startFrame ).sfNumFrames_( sfNumFrames ).sfSampleRate_( sfSampleRate )
				.useSwitch_( useSwitch ).prefServer_( prefServer ).useFocused_( useFocused );
		
		}
	
	
	}