/*
\wfsMasterIn

Input audio from a hardware input of the master audio interface of the system (if there is one). 

Using this Udef in a UChain will cause the whole UChain to be played on the master computer instead of the servers.

bus: number of the hardware input bus (starting at 0).
numChannels: number of channels (*)

(*) only the following numbers of channels are allowed:
1,2,3,4,5,6,7,8,10,12,16,24,32

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

MultiChannelUdef( \wfsMasterIn, { |bus = 0|
	var input;
	input = ((..Udef.numChannels - 1) + bus).collect({ |item| SoundIn.ar( item ) });
	input = input.collect({ |input|
		input * if( bus > (NumInputBuses.ir - 1), 0, 1 );
	});
	UOut.ar( 0, input );
} ).setSpec( \bus, PositiveIntegerSpec( 0 ) )
	.category_( \private )
	.uchainInitFunc_({ |unit, chain|
		// this function replaces the wfsPoint unit in the chain
		// by a \shared_point, and any of \map_control_point UMaps
		// further in the chain by corresponding \shared_point_in
		unit.def = \soundIn.asUdef;
	})
	.shouldPlayOnFunc_({ |unit, target|
		target.asTarget.server == WFSServers.default.m;
	});