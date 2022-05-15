/*
\wfsRandomPath

** wfsRandomPath is deprecated and will be removed at some point. Please use the \random_trajectory UMapDef instead. This Udef has a built-in function which makes it replace itself by a \random_trajectory UMap which is automaticaly inserted at the correct places, when it is found in a saved .uscore file or created via code **

a Udef generating a random trajectory as a control signal.

This signal can be used by the wfsDynamicPoint and wfsDynamicPlane udefs, by checking their 'pointFromBus' argument.

speed: frequency by which new random positions are generated, in Hz.center: (Point) the center of the rectangle within which a random path can be generated. radius: (Point) x and y radius of the rectangle within which the random path is generated.
lag: a smoothing time for changes in the center and radius. This uses a second-order filter, which may cause slight oscillations at beginnings and endings of movements. Changing the lag time during playback may cause audible artifacts.seed: Use this to generate a different random path. Paths with the same seed are exactly the same.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef( \wfsRandomPath, { |
		speed = 0.1, 
		center = #[0,0],
		radius = #[10,10],
		lag = 0,
		seed = 12345
		|
	var random;
	URandSeed.ir(seed);
	random = LFDNoise3.kr(  
		speed.dup,
		LPFLag.kr( radius, lag ),
		LPFLag.kr( center, lag )
	);
	UMixOut.kr( 0, random );
})
	.category_( 'private' )
	.uchainInitFunc_({ |unit, chain|
		// this function removes or replaces the wfsRandomPath unit in the chain
		// by the currently used UMaps at load time.
		var outputs, removeMe = false;
		var umaps, args;	
		var newUMap, mixOut;	
		
		outputs = unit.controlOuts.collect({ |item|
			unit.getControlOut( item );
		}).asInteger;
		
		mixOut = unit.controlOuts.collect({ |item|
			unit.getControlMixOutLevel( item );
		});
		
		args = [ 
			\speed, unit.speed, 
			\center, unit.center, 
			\radius, unit.radius, 
			\seed, unit.seed 
		];
		
		umaps = chain.units.collect({ |unit| 
			(unit.getAllUMaps ? []).select({ |umap| 
				(umap.defName === \map_control_point) && { 
					[umap.bus_x, umap.bus_y].asInteger == outputs; 
				}
			})
		}).flatten(1);
		
		if( umaps.size < 2 ) {
			// if only used once, directly insert at that spot
			umaps.do({ |umap|
				umap.def = \random_trajectory.asUdef(UMapDef);
				umap.set( *args );
				newUMap = umap;
				removeMe = true;
			});
		} {
			// if used multiple times, use a \shared_point
			umaps.do({ |umap|
				umap.def = \shared_point_in.asUdef(UMapDef);
				umap.id = outputs[0] / 2;
			});
		};
		
		if( removeMe ) { 
			chain.units.remove( unit );
			chain.units = chain.units; // update GUI / re-init
		} {
			unit.def = \shared_point.asUdef;
			unit.point = [ \random_trajectory, args ];
			unit.id = outputs[0] / 2;
			newUMap = unit.point;
		};
		
		case { mixOut == [1,1] && { newUMap.center == (0@0) } } {
			newUMap.center = [ \map_control_point, 
				[ \bus_x, outputs[0], \bus_y, outputs[1] ] 
			];
		} { mixOut.any(_ != 0) } {
			newUMap.center = [ \scale_point, [
				\scale, mixOut.asPoint,
				\move, newUMap.center,
				\point, [ \map_control_point, [ \bus_x, outputs[0], \bus_y, outputs[1] ] ]
			] ];
		};
	})
	.setSpec( \speed, [ 0, 100, 99.squared.log, 0, 0.1 ].asSpec )
	.setSpec( \center, WFSPointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, WFSRadiusSpec( 200, 0.1@0.1 ) )
	.setSpec( \lag, [ 0, 1, \lin, 0, 0].asSpec )
	.setSpec( \seed, PositiveIntegerSpec(12345) )
	.setControlOutName( [0,1], ['x', 'y'] )