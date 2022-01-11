// load the "touchosc wfs" scene (in this folder) to your touchosc device, and play

NetAddr.langPort.postln; // make sure your touchosc device talks to this port

(
UScore(
	UChain( 
		'whiteNoise', 
		[ 'cutFilter', [ 'freq', [ 20, 800 ] ] ], 
		[ 'tremolo', [ 'speed', 5 ] ],
		[ 'wfsSource', [ 'point', 'lag_point' ] ] 
	).fadeIn_(1).fadeOut_(1)
).gui;
)

UScore.current.enableOSC; // or check the 'OSC' button in the gui

// manual controls (more than the touchosc patch can do)

y = NetAddr( "127.0.0.1", NetAddr.langPort );

// setting point x and y
y.sendMsg( '/untitled/0/3/point/point.x', 5);
y.sendMsg( '/untitled/0/3/point/point.y', -10);

// setting the whole point
y.sendMsg( '/untitled/0/3/point/point', 10, 5);

// start and stop the score
y.sendMsg( '/untitled/prepareAndStart');
y.sendMsg( '/untitled/stop');

// setting the amp for the whiteNoise (first) unit
y.sendMsg( '/untitled/0/0/amp', 0.125 );
y.sendMsg( '/untitled/0/0/amp' , 0.5 );

y.sendMsg( '/untitled/0/0/amp' , \lfo_sine ); // apply an UMap
y.sendMsg( '/untitled/0/0/amp' , 0.1 ); // remove it again

// control the chain playback individually
y.sendMsg( '/untitled/0/stop' );
y.sendMsg( '/untitled/0/prepareAndStart' );
y.sendMsg( '/untitled/0/release' );

UScore.current.disableOSC;