/*
\wfsMasterOut

Output audio from the master audio interface of the system (if there is one). 

Using this Udef in a UChain will cause the whole UChain to be played on the master computer instead of the servers. 

On the Game of Life WFS system it can be used either to send audio digitally from the master computer to the servers (for which there are 8 buses available Ð i.e. one ADAT cable), or to the analog outputs of the master audio interface (for example to send audio signals in sync with the WFS system to other speakers or headphones).

bus: number of a hardware output (starting at 0)
toServers: if true (default), the output is to the digital inputs of the servers. If not selected, it is sent to analog outputs.
numChannels: number of channels (1-8)

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/

MultiChannelUdef( \wfsMasterOut, { |bus = 0, toServers = 1, u_busOffset = 14|
	var minBus, maxBus, useGlobalGain;
	minBus = (u_busOffset * toServers);
	maxBus = if( toServers, NumOutputBuses.ir - 1, u_busOffset - 1 );
	bus = bus + minBus;
	useGlobalGain = 1 - toServers;
	bus = bus * InRange.kr( bus, minBus, maxBus );
	
	Out.ar( bus, UIn.ar( 0, Udef.numChannels ) * UEnv.kr( useGlobalGain: useGlobalGain ) );
}, channels: (1..8))
	.category_( \wfs_io )
	.setSpec( \u_busOffset, PositiveIntegerSpec( 14 ) )
	.setSpec( \bus, PositiveIntegerSpec( 0 ) )
	.setSpec( \toServers, BoolSpec( true ) )
	.shouldPlayOnFunc_({ |unit, target|
		target.asTarget.server == WFSServers.default.m;
	});