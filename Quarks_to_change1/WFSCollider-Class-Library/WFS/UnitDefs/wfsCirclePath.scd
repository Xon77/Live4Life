/*
\wfsCirclePath

** wfsCirclePath is deprecated and will be removed at some point. Please use the \circle_trajectory UMapDef instead. This Udef has a built-in function which makes it replace itself by a \circle_trajectory UMap which is automaticaly inserted at the correct places, when it is found in a saved .uscore file or created via code **

Generates a circular or elliptical control signal.

This signal can be used by the wfsDynamicPoint and wfsDynamicPlane udefs, by checking their 'pointFromBus' argument.
speed: frequency (cycles per second).startAngle: starting angle of the path in degrees.clockwise: select to turn clockwise, otherwise the path turns anti-clockwise.center: the center of the circle (Point).radius: x and y radius of the circle/ellipse (Point).
lag: a smoothing time for changes in the startAngle, center and radius. This uses a second-order filter, which may cause slight oscillations at beginnings and endings of movements. Changing the lag time during playback may cause audible artifacts.


--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef( \wfsCirclePath, { |
		speed = 0.1, 
		startAngle = 0,
		clockwise = 1, 
		center = #[0,0],
		radius = #[10,10],
		lag = 0,
		u_startPos = 0|
	var circle;
	circle = SinOsc.kr(  
		speed * clockwise.linlin(0,1,-1,1), 
		[ 0, 0.5pi ] + (((LPFLag.kr( startAngle, lag ) / 360) + (u_startPos * speed)) * 2pi),
		LPFLag.kr( radius, lag ),
		LPFLag.kr( center, lag )
	);
	UMixOut.kr( 0, circle );
})
	.category_( 'private' )
	.uchainInitFunc_({	 |unit, chain|
		// this function removes or replaces the wfsCirclePath unit in the chain
		// by the currently used UMaps at load time.
		var outputs, removeMe = false;
		var umaps, copy;
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
				umap.def = \circle_trajectory.asUdef(UMapDef);
				umap.set( *unit.storeArgs[1] );
				umap.set( \startAngle, unit.startAngle.linlin(-180,180,-pi,pi) );
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
			copy = unit.deepCopy; // in any case, replace by a \shared_point
			unit.def = \shared_point.asUdef;
			unit.point = [ \circle_trajectory, copy.storeArgs[1] ? [] ];
			unit.point.set( \startAngle, copy.startAngle.linlin(-180,180,-pi,pi) );
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
	.setSpec( \startAngle, [-180,180,\lin,1,0].asSpec )
	.setSpec( \clockwise, BoolSpec( true ) )
	.setSpec( \center, WFSPointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, WFSRadiusSpec( 200, 0.1@0.1 ) )
	.setSpec( \lag, [ 0, 1, \lin, 0, 0].asSpec )
	.setControlOutName( [0,1], ['x', 'y'] );