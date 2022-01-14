/*
this example for WFSCollider demonstrates how to program midi control for your score. It creates a very simple score with a sine wave in the center of the room, with infinite duration. The frequency of the sine wave is controlled via the modulation wheel (cc 1), mapped to the whole frequency range (20-20000Hz).

Items with multiple lines in between brackets ( () ) are meant to be executed together. Double click one of the brackets to select the whole block. Other items can be executed as single lines.

Note that this is an alternative to the 'midi' UMapDefs (midi_bend, midi_cc etc..).
*/

// define a simple score
x = UScore( UChain( [ \sine, [ \lag, 0.1 ] ], [ \wfsSource, [ \point, \lag_point ] ] ) );

// open the score editor to see it:
x.gui;

// play the score (or hit play button in editor)
x.prepareAndStart;

// couple controller 1 (modulation wheel) on any channel to the frequency of the sine wave
MIDIIn.connectAll; // needs to be runned once

(
m = MIDIFunc.cc({ |val, num, chan, src|
	x[0][0].freq = val.linexp(0,127,20,20000); // points to first unit of first chain in the score
}, 1 ); // <- the '1' here filters for controller number 1
)

// if no midi controller is connected, use the lines below to 
MIDIIn.doControlAction(1, 1, 1, 50); // spoof a cc (value 50)
MIDIIn.doControlAction(1, 1, 1, 70); // spoof a cc (value 70)

// remove the action (cmd-. also removes it)
m.free; 

// stop the score
x.stop;


// other ways to do the same:

(
// using .set on the UChain will find all units with the 'freq' parameter name, and set those
m = MIDIFunc.cc({ |val, num, chan, src|
	x[0].set( \freq, val.linexp(0,127,20,20000) );
}, 1 );
)

(
// via mapSet the associated ControlSpec of \freq can be used to scale the value from the (0-1) range
m = MIDIFunc.cc({ |val, num, chan, src|
	x[0][0].mapSet( \freq, val.linlin(0,127,0,1) );
}, 1 );
)

(
// using the built-in midi_cc UMapDef the score would be created like this:
y = UScore( 
	UChain(
		[ 'sine', [ 'freq', 
			[ 'midi_cc', [ 'active', true, 'cc', 1, 'toRange', [ 20, 20000 ] ] ] ] ], 
		[ 'wfsSource', [ 'point', 'lag_point' ] ]
	)
);
y.gui;
)
