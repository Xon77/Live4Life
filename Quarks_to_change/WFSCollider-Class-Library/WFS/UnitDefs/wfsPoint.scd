/*
\wfsPoint

** deprecated (will be removed soon), please use 'shared_point' instead. When loaded in a score file or created via code this Udef will auto-replace itself by a shared_point, and automatically insert shared_point_in UMaps at the appropriate places **

a Udef generating a single spatial position. Use this if you want to change your point live, and feed the location to multiple units in your chain (such as \furseDistanceFilter or reverbs).

This signal can be used by the wfsDynamicPoint and wfsDynamicPlane udefs, by checking their 'pointFromBus' argument.

point: a Point object, specifying the position produced by this udef
lag: a smoothing time for changes in the position. This uses a second-order filter, which may cause slight oscillations at beginnings and endings of movements. Changing the lag time during playback may cause audible artifacts.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef(\wfsPoint,
    { |point = #[0,0], lag = 0| 
        point = LPFLag.kr( point, lag );
        UOut.kr(0, point) 
}, [
    [ \point: 0@0, WFSPointSpec( 200, 0.1 ) ],
    [ \lag: 0, [ 0, 1, \lin, 0, 0].asSpec ]
]
).category_( 'private' )
	.uchainInitFunc_({ |unit, chain|
		// this function replaces the wfsPoint unit in the chain
		// by a \shared_point, and any of \map_control_point UMaps
		// further in the chain by corresponding \shared_point_in
		var outputs, removeMe = false;
		var umaps, point;	
		
		outputs = unit.controlOuts.collect({ |item|
			unit.getControlOut( item );
		}).asInteger;
		
		chain.units.collect({ |unit| 
			(unit.getAllUMaps ? []).select({ |umap| 
				(umap.defName === \map_control_point) && { 
					[umap.bus_x, umap.bus_y].asInteger == outputs; 
				}
			})
		}).flatten(1).do({ |umap|
			umap.def = \shared_point_in.asUdef(UMapDef);
			umap.id = outputs[0] / 2;
		});
			
		unit.def = \shared_point.asUdef;
		unit.id = outputs[0] / 2;
	})
.setControlOutName( [0,1], ['x', 'y'] );
