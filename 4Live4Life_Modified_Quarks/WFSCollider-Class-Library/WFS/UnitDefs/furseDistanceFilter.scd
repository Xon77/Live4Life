/*
\furseDistanceFilter

** if a furseDistanceFilter is used in combination with a wfsDynamicPoint or wfsStaticPoint in a chain, the next time the score is opened it will be removed and replaced by a 'distanceFilter' setting in on the panner unit **

The furseDistanceFilter is a filter that applies distance filtering according to a formula by Richard W. Furse (http://www.muse.demon.co.uk/vspace/model.html): 

cutoff = 100000 / distance

where cutoff is Hz and distance is in metres.

point: a Point from which the distance to the center of the room (0,0) is determined
amount: strength of the effect. A cubed multiplier for the distance. 0 means no filtering, 1 means normal, 2 means the distance in the formula is multiplied by 8 (2**3).

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

Udef( \furseDistanceFilter, { 
	var sig, point = (0@0), freq;
	point = \point.kr( point.asArray ).asPoint;
	sig = UIn.ar(0);
	freq = (100000 / ( point.rho * \amount.kr(1).cubed )).clip(0,100000);
	sig = OnePole.ar( sig, ( -2pi * (freq / SampleRate.ir) ).exp );
	UOut.ar( 0, sig );
}).category_( \filter )
	.prepareArgsFunc_({ |argPairs|
		var point;
		if( argPairs.notNil) {
			if( argPairs.pairsAt( \pointFromBus ) == true ) {
				if( argPairs.includes( \u_i_kr_0_bus ) or: { 
					argPairs.includes( \u_i_kr_1_bus ) 
				} ) {
					argPairs = [ \point, [ \map_control_point, [ 
						\bus_x, argPairs.pairsAt( \u_i_kr_0_bus ) ? 0,
						\bus_y, argPairs.pairsAt( \u_i_kr_1_bus ) ? 1
						] 
					], \pointFromBus, false ] ++ argPairs;
				} {
					argPairs = [ \point, \map_control_point, \pointFromBus, false ] ++ argPairs;
				};
			};
		};
	})
	.uchainInitFunc_({	 |unit, chain|
		var removeMe = false;
		
		chain.units.select({ |item| 
			([ \wfsDynamicPoint, \wfsStaticPoint ].includes( item.defName )) && {
				if( item.point.isUMap && unit.point.isUMap ) {
					(item.point.defName == unit.point.defName) && {
						item.point.args == unit.point.args;
					};
				} {
					item.point == unit.point;
				};
			} && {
				unit.getAudioOut(0) == item.getAudioIn(0)
			}
		}).do({ |item|
			item.distanceFilter = unit.amount;
			removeMe = true;
		});
					
		if( removeMe ) { 
			chain.units.remove( unit );
			chain.units = chain.units; // update GUI / re-init
		};
	})
	.setSpec( \amount, [0,2,\lin,0,1].asSpec )
	.setSpec( \point, WFSPointSpec(200, 0.1) );