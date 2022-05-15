/*
\wfsPathPlayer

** wfsPathPlayer is deprecated and will be removed at some point. Please use the \trajectory UMapDef instead. This Udef has a built-in function which makes it replace itself by a \trajectory UMap which is automaticaly inserted at the correct places, when it is found in a saved .uscore file or created via code **

A player for spatial trajectories. The WFSPathGUI can be called up via the [edit] button in the UChain window.

This signal can be used by the wfsDynamicPoint and wfsDynamicPlane udefs, by checking their 'pointFromBus' argument.

wfsPath: a WFSPathBuffer object. This object creates and points to a buffer with the data of the trajectory. This buffer is either filled with data sent directly, or data read from a .wfspath file (generated via the [write data] button in the GUI). Data from file is usually more reliable than sending via network.

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef( \wfsPathPlayer, {
	var sig;
	sig = WFSPathBufferPlayer.kr( \wfsPath );
	UMixOut.kr( 0, sig );
}, [ [ \wfsPath, nil, WFSPathSpec() ] ] )
	.category_( 'private' )
	.uchainInitFunc_({	 |unit, chain|
		// this function removes or replaces the wfsPathPlayer unit in the chain
		// by the currently used UMaps at load time.
		var outputs, removeMe = false;
		var umaps, trajectory;
		var newUMap, mixOut;	
		
		outputs = unit.controlOuts.collect({ |item|
			unit.getControlOut( item );
		}).asInteger;
		
		mixOut = unit.controlOuts.collect({ |item|
			unit.getControlMixOutLevel( item );
		});
		
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
				umap.def = \trajectory.asUdef(UMapDef);
				umap.trajectory = unit.wfsPath;
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
			trajectory = unit.wfsPath; // in any case, replace by a \shared_point
			unit.def = \shared_point.asUdef;
			unit.point = [ \trajectory, [ \trajectory, trajectory ] ];
			unit.id = outputs[0] / 2;
			newUMap = unit.point;
		};
		
		case { mixOut == [1,1] } {
			newUMap.addPoint = [ \map_control_point, [ \bus_x, outputs[0], \bus_y, outputs[1] ] ];
		} { mixOut.any(_ != 0) } {
			newUMap.addPoint = [ \scale_point, [
				\scale, mixOut.asPoint,
				\point, [ \map_control_point, [ \bus_x, outputs[0], \bus_y, outputs[1] ] ]
			] ];
		};
	})
	.setControlOutName( [0,1], ['x', 'y'] );