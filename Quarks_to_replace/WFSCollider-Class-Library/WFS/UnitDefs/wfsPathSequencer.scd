/*
\wfsPathSequencer

** wfsPathSequencer is deprecated and will be removed at some point. Please use combinations of 'line_trajectory' and 'trajectory' UMaps, or a 'select_8_point' UMap with an 'envelope' umap on the index instead. This Udef has a built-in function which makes it replace itself by an appropriate combination of UMaps, which is automaticaly inserted at the correct places when it is found in a saved .uscore file or created via code **

A player for multiple spatial trajectories in sequence. A crossfade time can be applied to smoothly transition between each of the trajectories. The WFSPathGUI can be called up via the [edit] button in the UChain window, for each of the trajectories.

This signal can be used by the wfsDynamicPoint and wfsDynamicPlane udefs, by checking their 'pointFromBus' argument.

Each WFSPath can be timed by using its 'delay' setting.

wfsPath: a WFSPathBuffer object. This object creates and points to a buffer with the data of the trajectory. This buffer is either filled with data sent directly, or data read from a .wfspath file (generated via the [write data] button in the GUI). Data from file is usually more reliable than sending via network. This is the first path to be played

fadeTime1, fadeTime2 etc.: the duration of the crossfade to the next trajectory.
fadePos1, fadePos2 etc.: the position of the crossfade on the time line. 
	0 means: before the start of the trajectory
	1 means: after the start of the trajectory
	
wfsPath1, wfsPath2 etc.: WFSPathBuffer objects for each node in the sequence. The 'delay' parameter can be used to set the start time of each path. Paths may overlap, but there will always be only one of them audible (except during the fadeTime).

numPaths: the total number of paths. This may range from 2 to 8. The actual value of this argument is 'wfsPathSequencer%', where % is the number. In the GUI this shows up as numbers in a popup menu. The default number is 2.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/
(
var defs, def;
var makeUMap;
defs = (2..8).collect({ |n|
	var def;
	def = HiddenUdef( ("wfsPathSequencer" ++ n).asSymbol, {
		var sig, sweep, startPos;
		sig = WFSPathBufferPlayer.kr( \wfsPath );
		startPos = \u_startPos.kr(0);
		sweep = Sweep.kr + startPos;
		//sweep.poll;
		(n-1).do({ |i|
			var fadeTime, fadePos, startFade, endFade, path, delay, fade;
			i = i+1;
			fadeTime = ("fadeTime" ++ i).asSymbol.kr(0.1).max(1.0e-6);
			fadePos = ("fadePos" ++ i).asSymbol.kr(0);
			path = WFSPathBufferPlayer.kr( "wfsPath" ++ i );
			delay = ("wfsPath" ++ i).asSymbol.kr( [ 0, 0, 1, 0, 0 ] )[4] + startPos;
			startFade = delay - (fadeTime * (1-fadePos));
			endFade = startFade + fadeTime;
			fade = SinOsc.kr( 0, sweep.linlin(startFade, endFade, -0.5pi, 0.5pi, \minmax) );
			//fade.poll( label: i.asString );
			sig = LinXFade2.kr( sig, path, fade );
		});
		UMixOut.kr( 0, sig );
	})
		.category_( \wfs_control )
		.setSpec( \wfsPath, WFSPathSpec())
		.setDefault( \wfsPath, WFSPathSpec().default )
		.setControlOutName( [0,1], ['x', 'y'] );
	
	(n-1).do({ |i|
		i = i+1;
		def.setSpec( ("fadeTime" ++ i).asSymbol, SMPTESpec() );
		def.setSpec( ("fadePos" ++ i).asSymbol, [0,1].asSpec );
		def.setSpec( ("wfsPath" ++ i).asSymbol, WFSPathSpec() );
		def.setDefault( ("wfsPath" ++ i).asSymbol, WFSPathSpec().default );
	});
	def;
});

def = MultiUdef( \wfsPathSequencer, defs, 'private', \numPaths, false );

makeUMap = { |unit|
	// function to convert a \wfsPathSequencer to appropriate UMap
	var numPaths, times, levels;
	numPaths = (unit.numPaths ? \wfsPathSequencer2).asString.last.asString.interpret;
	if( numPaths == 2) {
		UMap( \line_trajectory, [
			\a, [ \trajectory, [ \trajectory, unit.wfsPath ] ],
			\b, [ \trajectory, [ \trajectory, unit.wfsPath1 ] ],
			\duration, unit.fadeTime1,
			\delay, unit.wfsPath1.delay - (unit.fadeTime1 * (1-unit.fadePos1))
		]);
	} {
		levels = numPaths.collect({ |i| i; }).stutter(2);
		times = [ 0 ] ++ (1..(numPaths - 1)).collect({ |i|
			var wfsPath, fadeTime, fadePos;
			wfsPath = unit.get( ("wfsPath" ++ i).asSymbol ).postln;
			fadeTime = unit.get( ("fadeTime" ++ i).asSymbol );
			fadePos = unit.get( ("fadePos" ++ i).asSymbol );
			[
				wfsPath.delay - (fadeTime * (1-fadePos)),
				wfsPath.delay + (fadeTime * fadePos),
			]
		}).flatten(1) ++ [
			unit.get( ("wfsPath" ++ (numPaths-1) ).asSymbol ).delay + 
			unit.get( ("wfsPath" ++ (numPaths-1) ).asSymbol ).wfsPath.dur ? 7
		];
		times = times.max(0);
		#times, levels = [ times, levels ].flop.sort({ |a,b|
			if( a[0] == b[0] ) {
				a[1] <= b[1];
			} {
				a[0] < b[0];
			};
		}).flop;
		levels = levels[..(levels.differentiate.detectIndex(_.isNegative) ? levels.size)-1];
		times = times[..levels.size-1];
		times = times.differentiate[1..];
		
		UMap( \select_8_point, ([
			\index, [ \envelope, [ \env, EnvM( levels, times ) ] ],
			\point0, [ \trajectory, [ \trajectory, unit.wfsPath.deepCopy ] ],
		] ++ (1..(numPaths - 1)).collect({ |i|
			[ ("point" ++ i).asSymbol, [ \trajectory, [ \trajectory, 
				unit.get( ("wfsPath" ++ i).asSymbol ).deepCopy 
			] ] ];
		}).flatten(1))
		);
	};
};

def.uchainInitFunc_({ |unit, chain|
	// this function removes or replaces the wfsPathSequencer unit in the chain
	// by the currently used UMaps at load time.
	var outputs, removeMe = false;
	var umaps, newUMap;	
	
	outputs = unit.controlOuts.collect({ |item|
		unit.getControlOut( item );
	}).asInteger;
	newUMap = makeUMap.value(unit);
	umaps = chain.units.collect({ |unit| 
		(unit.getAllUMaps ? []).select({ |umap| 
			(umap.defName === \map_control_point) && { [umap.bus_x, umap.bus_y].asInteger == outputs; }
		})
	}).flatten(1);
	
	if( umaps.size < 2 ) {
		// if only used once, directly insert at that spot
		umaps.do({ |umap|
			umap.def = newUMap.def;
			umap.set( *newUMap.args );
			removeMe = true;
		});
	} {
		// if used multiple times, use a \shared_point
		umaps.do({ |umap|
			umap.def = \shared_point_in.asUdef(UMapDef);
			umap.point = newUMap;
			umap.id = outputs[0] / 2;
		});
	};
	
	if( removeMe ) { 
		chain.units.remove( unit );
		chain.units = chain.units; // update GUI / re-init
	} {
		unit.def = \shared_point.asUdef;
		unit.point = newUMap;
		unit.id = outputs[0] / 2;
	};
});

def.argSpecs.last.spec.labels = (2..8).collect(_.asSymbol);

def
)