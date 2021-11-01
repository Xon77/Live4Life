/*
\wfsServerIn

Input audio sent digitally from the master computer on the server. 

Using this Udef in your UChain will make the UChain play only on the servers. It is meant to use together with another UChain that holds a wfsMasterOut. Together, these can make a bridge between the master computer and the servers, typically needed for feeding live audio into the system and distributing it over the servers. On the Game of Life WFS system there are 8 buses available for this.

bus: number of the hardware input bus (0-7).
numChannels: number of channels (1-8)

--
this is an Udef definition file
part of the WFSCollider Class Library default Udefs set
*/


var def, maxInput = 8;
if( WFSSpeakerConf.serverGroups[0].notNil ) { 
	maxInput = WFSSpeakerConf.serverGroups[0].choose.options.numInputBusChannels;
};
def = MultiChannelUdef( \wfsServerIn, { |bus = 0| // same as soundIn, but only plays on servers 
	var input;
	input = ((..Udef.numChannels - 1) + bus).collect({ |item| SoundIn.ar( item ) });
	input = input.collect({ |input|
		input * if( bus > (NumInputBuses.ir - 1), 0, 1 );
	});
	UOut.ar( 0, input );
}, channels: (1..8))
	.category_( \wfs_io )
	.shouldPlayOnFunc_({ |unit, target|
		if( WFSSpeakerConf.includesServer( target.asTarget.server ) ) {
			nil;
		} {
			false;
		};
	});

def.udefs.do({ |item|
	item.setSpec( \bus, IntegerSpec( 0, 0, maxInput - item.numChannels ) 
	);
});

def;