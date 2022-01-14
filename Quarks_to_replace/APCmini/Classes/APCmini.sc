////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) Andrés Pérez López, March 2015
// www.andresperezlopez.com // contact@andresperezlopez.com
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; withot even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>
//
////////////////////////////////////////////////////////////////////////////
//
// APCmini.sc
//
// Wrapper for the Akai APC mini controller
//
////////////////////////////////////////////////////////////////////////////

APCmini {

	var <out; // midi destination

	var pads; // internal state

	var <>verbose = false;
	var faderMode = false;
	var sliderValues;
	var sliderColors;
	var defaultMode = \switch; // switch/hold
	var defaultSwitchNumStates = 4;

	// they follow the internal row/column numeration
	var <padInternalState; // array2d
	var <padFunction; // array of array2d
	var <padMode; // internal mode, array2d
	var <padHoldColor; // array2d
	var <padSwitchNumStates; // array2d
	var <padColorsOfStates; // array2d with dict

	var <horInternalState;
	var <horFunction;
	var <horMode;

	var <verInternalState;
	var <verFunction;
	var <verMode;

	var <sliderFunction;

	// colors
	var <black = 0;
	var <green = 1;
	var <blinkGreen = 2;
	var <red = 3;
	var <blinkRed = 4;
	var <orange = 5;
	var <blinkOrange = 6;
	var <defaultPadHoldColor = 1;
	var colors; // dict
	var defaultColorsOfStates;

	*new {
		^super.new.init;
	}

	init {


		//////////// SET UP CONNEXIONS

		var sources, destinations;
		var uid;

		// midi in
		// MIDIClient.init; // CL
		if (MIDIClient.initialized.not, {MIDIClient.init; }); // CL
		sources=MIDIClient.sources;

		// connect supercollider to controller

		destinations = MIDIClient.destinations;
		destinations.do { |dest, portNumber|
			if (dest.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/) { // CL
				out = MIDIOut.new(portNumber);
				out.latency_(0.001); // minimize latency; with 0 crashes
				// out.latency_(0);
				// autoconnect on Linux
				if ( thisProcess.platform.name == \linux /*thisProcess.platform.isKindOf(LinuxPlatform)*/ ) { // CL

					// get number of supercollider midi outs
					var n = 0;
					sources.do{|d| if (d.device.split($-)[0]=="APC MINI"/*"SuperCollider"*/) { n = n+1 } }; // CL

					// connect them all
					n.do{ |i| MIDIOut.connect(i,portNumber); };

				};
			};
		};

		// connect controller to supercollider
		if (sources.select{|d|d.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/}.size!=0) { // CL
			sources.do{|d|if (d.device=="APC MINI"/*"APC MINI-APC MINI MIDI 1"*/) {uid=d.uid}}; // CL
			if ( thisProcess.platform.name == \linux /*thisProcess.platform.isKindOf(LinuxPlatform)*/ ) { // CL
				MIDIIn.connectByUID(0,uid);
			};
			"Device connected".postln;

			// play animation
			// {this.playAnimation}.defer(0.2);
		} {
			"Device not connected".error
		};




		//////////// INIT VARIABLES

		sliderValues = Array.fill(9,0);
		sliderColors = [green,green,green,green,green,orange,orange,orange,red];

		padInternalState = Array2D.fromArray(8,8,0!64);

		padMode = Array2D.fromArray(8,8,defaultMode!64);

		padFunction = Array.fill(defaultSwitchNumStates,{Array2D.fromArray(8,8,nil!64)});

		padHoldColor = Array2D.fromArray(8,8,defaultPadHoldColor!64);

		padSwitchNumStates = Array2D.fromArray(8,8,defaultSwitchNumStates!64);

		colors = Dictionary.newFrom([\black,black, \green,green, \blinkGreen,blinkGreen,
			\red,red, \blinkRed,blinkRed, \orange,orange, \blinkOrange,blinkOrange]);

		defaultColorsOfStates = Dictionary.newFrom([0,black, 1,green, 2,red, 3,orange]);

		padColorsOfStates = Array2D.fromArray(8,8,defaultColorsOfStates!64);


		horInternalState = Array.fill(8,0);
		horFunction = Array2D.fromArray(2,8,nil!16);
		horMode = Array.fill(8,defaultMode);

		verInternalState = Array.fill(8,0);
		verFunction = Array2D.fromArray(2,8,nil!16);
		verMode = Array.fill(8,defaultMode);

		sliderFunction = Array.fill(9,nil);


		//////////// MIDI RESPONDERS

		MIDIdef.noteOn(\on, { |...args|
			var r,c;
			var note = args[1];

			if ( this.noteType(note) == \shift ) {

				if ( faderMode ) {
					faderMode = false;
					if (verbose) {"SLIDER MODE OFF".postln};
					this.redrawInternalState;
				} {
					faderMode = true;
					if (verbose) {"SLIDER MODE ON".postln};
					this.redrawSliderState;
				}
			}
			{
				if (faderMode.not) {

					switch ( this.noteType(note) )

					{ \pad } {

						var pad = note;
						#r,c = this.internalIndex(pad);

						switch ( padMode.at(r,c) )
						{\hold} {
							var state = 1;
							// change internal state
							padInternalState.put(r,c,state);
							// run function
							padFunction.at(state).at(r,c).value();
							// set light
							out.noteOn(0,pad,padHoldColor.at(r,c));
							// print
							if (verbose) {[\pad,r,c,state].postln};
						}
						{\switch} {
							// change internal state
							var state = this.incrementState(r,c);
							// run function
							padFunction.at(state).at(r,c).value();
							// set light
							out.noteOn(0,pad,padColorsOfStates.at(r,c).at(state));
							// print
							if (verbose) {[\pad,r,c,state].postln};
						};
					}
					{ \hor } {
						var i = note - 64;

						switch ( horMode.at(i) )
						{\hold} {
							var state = 1;
							// change internal state
							horInternalState.put(i,state);
							// run function
							horFunction.at(state,i).value();
							// set light
							out.noteOn(0,note,state);
							// print
							if (verbose) {[\hor,i,state].postln};
						}
						{\switch} {
							// change internal state
							var state;
							if ( horInternalState.at(i) == 0 ) {
								state = 1;
							} {
								state = 0;
							};
							horInternalState.put(i,state);
							// run function
							horFunction.at(state,i).value();
							// set light
							out.noteOn(0,note,state);
							// print
							if (verbose) {[\hor,i,state].postln};
						}
					}
					{ \ver } {
						var i = note - 82;

						switch ( verMode.at(i) )
						{\hold} {
							var state = 1;
							// change internal state
							verInternalState.put(i,state);
							// run function
							verFunction.at(state,i).value();
							// set light
							out.noteOn(0,note,state);
							// print
							if (verbose) {[\ver,i,state].postln};
						}
						{\switch} {
							// change internal state
							var state;
							if ( verInternalState.at(i) == 0 ) {
								state = 1;
							} {
								state = 0;
							};
							verInternalState.put(i,state);
							// run function
							verFunction.at(state,i).value();
							// set light
							out.noteOn(0,note,state);
							// print
							if (verbose) {[\ver,i,state].postln};

						}
					}
				};
			}


		}, srcID: uid /*1990386095*/); // CL

		MIDIdef.noteOff(\off, { |...args|
			var r,c;
			var note = args[1];

			switch ( this.noteType(note) )

			{ \pad } {

				var pad = note;
				#r,c = this.internalIndex(pad);

				switch ( padMode.at(r,c) )
				{\hold} {
					var state = 0;
					// change internal state
					padInternalState.put(r,c,state);
					// run function
					padFunction.at(state).at(r,c).value();
					// set light
					out.noteOn(0,pad,0);
					// print
					if (verbose) {[\pad,r,c,state].postln};
				}
				{\switch} {
					// nothing
				};
			}
			{ \hor } {
				var i = note - 64;

				switch ( horMode.at(i) )
				{\hold} {
					var state = 0;
					// change internal state
					horInternalState.put(i,state);
					// run function
					horFunction.at(state,i).value();
					// set light
					out.noteOn(0,note,state);
					// print
					if (verbose) {[\hor,i,state].postln};
				}
				{\switch} {
					// nothing
				}
			}
			{ \ver } {
				var i = note - 82;

				switch ( verMode.at(i) )
				{\hold} {
					var state = 0;
					// change internal state
					verInternalState.put(i,state);
					// run function
					verFunction.at(state,i).value();
					// set light
					out.noteOn(0,note,state);
					// print
					if (verbose) {[\ver,i,state].postln};
				}
				{\switch} {
					// nothing
				}

			};
		}, srcID: uid /*1990386095*/); // CL

		// sliders
		MIDIdef.cc(\cc, { |...args|
			var value = args[0];
			var num = args[1] - 48;

			// run function
			sliderFunction.at(num).value(num,value);

			//// FADER MODE

			if (faderMode) {
				// get the 8th-range in which new value is
				var range = (value / 127 * 8).round;
				var lastRange = (sliderValues[num] / 127 * 8).round;

				if ( num != 8 ) {
					if (range > lastRange) {
						out.noteOn(0,num+((range-1)*8),sliderColors[range]);
					};
					if (range < lastRange) {
						out.noteOn(0,num+((range)*8),black);
					};

				} {
					if (range > lastRange) {
						out.noteOn(0,90-range,1);
					};
					if (range < lastRange) {
						out.noteOn(0,89-range,0);
					};
				}
			};

			// print
			if (verbose) {[\slider,num,value].postln};

			// update internal state
			sliderValues.put(num,value);
		}, srcID: uid /*1990386095*/); // CL

	}




	//////////// MANAGE FUNCTIONS

	///// set function

	setPadFunction { |row, column, state, func|
		padFunction.at(state).put(row,column,func);
	}

	setButtonFunction { |type, num, state, func|
		switch(type)
		{\hor} {horFunction.put(state,num,func) }
		{\ver} { verFunction.put(state,num,func) }
	}

	setSliderFunction { |num,func|
		sliderFunction.put(num,func);
	}

	///// set mode

	setPadMode { |row,column,mode|
		padMode.put(row,column,mode);
	}

	setPadModeAll { |mode|
		padMode = Array2D.fromArray(8,8,mode!64);
	}

	setButtonMode { |type,num,mode|
		switch (type)
		{\hor} {
			horMode.put(num,mode);
		}
		{\ver} {
			/*hor*/verMode.put(num,mode); // Erreur à l'origine // CL
		}
	}

	setButtonModeAll { |mode|
		(0..7).do{ |i|
			horMode.put(i,mode);
			verMode.put(i,mode);
		}
	}

	///// pad hold color

	setPadHoldColor { |row, column, color|
		padHoldColor.put(row,column,colors.at(color));
	}

	setPadHoldColorAll { |color|
		padHoldColor = Array2D.fromArray(8,8,colors.at(color)!64);
	}

	///// pad states

	setNumStates { |row, column, n|
		padSwitchNumStates.put(row,column,n);
	}

	setNumStatesAll { |n|
		padSwitchNumStates = Array2D.fromArray(8,8,n!64);
	}

	setColorsOfStates { |row, column, array|
		// array in the form [0,\black,1,\red,2,\orange,3,\green]...

		// cast symbols to color codes
		array = array.collect{|e|if(e.class == Symbol/*isSymbol*/){colors.at(e)}{e}}; // CL
		padColorsOfStates.put(row,column,Dictionary.newFrom(array)/*.postln*/); // .postln retiré du Quark d'origine // CL
	}

	setColorsOfStatesAll { |array|
		// array in the form [0,\black,1,\red,2,\orange,3,\green]...

		// cast symbols to color codes
		array = array.collect{|e|if(e.class == Symbol/*isSymbol*/){colors.at(e)}{e}}; // CL
		padColorsOfStates = Array2D.fromArray(8,8,Dictionary.newFrom(array)!64);

	}

	sliderMode {
		^faderMode;
	}

	sliderMode_ { |bool|
		if (faderMode != bool) {
			faderMode = bool;
			if (faderMode) {
				if (verbose) {"SLIDER MODE ON".postln};
				this.redrawSliderState;
			} {
				if (verbose) {"SLIDER MODE OFF".postln};
				this.redrawInternalState;
			}
		};
	}

	playAnimation {
		Task{

			// cross

			5.do{ |j|
				[green,red,red,red,red,red,red,green].do{|c,i| out.noteOn(0,i,c); out.noteOn(0,i+56,c); }; 0.01.wait;
				[black,green,red,red,red,red,green,black].do{|c,i| out.noteOn(0,i+8,c); out.noteOn(0,i+48,c);}; 0.01.wait;
				[black,black,green,red,red,green,black,black].do{|c,i| out.noteOn(0,i+16,c); out.noteOn(0,i+40,c);}; 0.01.wait;
				[black,black,black,green,green,black,black,black].do{|c,i| out.noteOn(0,i+24,c); out.noteOn(0,i+32,c);}; 0.01.wait;
				(j*0.01).wait;
				//out
				64.do{ |i| out.noteOn(0,i,black) };

				[green,black,black,black,black,black,black,green].do{|c,i| out.noteOn(0,i,c); out.noteOn(0,i+56,c); }; 0.01.wait;
				[red,green,black,black,black,black,green,red].do{|c,i| out.noteOn(0,i+8,c); out.noteOn(0,i+48,c);}; 0.01.wait;
				[red,red,green,black,black,green,red,red].do{|c,i| out.noteOn(0,i+16,c); out.noteOn(0,i+40,c);}; 0.01.wait;
				[red,red,red,green,green,red,red,red].do{|c,i| out.noteOn(0,i+24,c); out.noteOn(0,i+32,c);}; 0.01.wait;
				((j*0.01)).wait;
				//out
				64.do{ |i| out.noteOn(0,i,black) };

				[green,orange,orange,orange,orange,orange,orange,green].do{|c,i| out.noteOn(0,i,c); out.noteOn(0,i+56,c); }; 0.01.wait;
				[black,green,orange,orange,orange,orange,green,black].do{|c,i| out.noteOn(0,i+8,c); out.noteOn(0,i+48,c);}; 0.01.wait;
				[black,black,green,orange,orange,green,black,black].do{|c,i| out.noteOn(0,i+16,c); out.noteOn(0,i+40,c);}; 0.01.wait;
				[black,black,black,green,green,black,black,black].do{|c,i| out.noteOn(0,i+24,c); out.noteOn(0,i+32,c);}; 0.01.wait;
				(j*0.01).wait;
				//out
				64.do{ |i| out.noteOn(0,i,black) };

				[green,black,black,black,black,black,black,green].do{|c,i| out.noteOn(0,i,c); out.noteOn(0,i+56,c); }; 0.01.wait;
				[orange,green,black,black,black,black,green,orange].do{|c,i| out.noteOn(0,i+8,c); out.noteOn(0,i+48,c);}; 0.01.wait;
				[orange,orange,green,black,black,green,orange,orange].do{|c,i| out.noteOn(0,i+16,c); out.noteOn(0,i+40,c);}; 0.01.wait;
				[orange,orange,orange,green,green,orange,orange,orange].do{|c,i| out.noteOn(0,i+24,c); out.noteOn(0,i+32,c);}; 0.01.wait;
				((j*0.01)).wait;
				//out
				64.do{ |i| out.noteOn(0,i,black) };
			};

			// rasta
			(64..72).do { |i| out.noteOn(0,i,1) };
			0.01.wait;
			(82..90).do { |i| out.noteOn(0,i,1) };
			0.01.wait;
			3.do{
				//fill
				8.do { |i|
					[0,1,2].do { |j| out.noteOn(0,j+(8*i),red) };
					[3,4].do { |j| out.noteOn(0,j+(8*i),orange) };
					[5,6,7].do { |j| out.noteOn(0,j+(8*i),green) };
					0.02.wait;
				};

				0.1.wait;
				//out
				64.do{ |i| out.noteOn(0,i,black) };
				0.1.wait;
			};


			this.redrawInternalState;

		}.play;
	}



	//////////// PRIVATE

	noteType { |note|
		var type;

		if ( note < 64 ) { type = \pad };
		if ( note >= 64 and:{ note < 72 } ) { type = \hor };
		if ( note > 72  and:{ note < 90 }) { type = \ver };
		if ( note == 98 ) { type = \shift };

		^type
	}

	redrawSliderState {
		8.do{ |slider|
			var range = (sliderValues[slider] / 127 * 8).round;
			var c = Array.fill(8,{|i| if(range > i) {1} {0} });
			var colors = c * sliderColors[1..sliderColors.size-1];
			8.do{ |i| out.noteOn(0,slider+(i*8),colors[i]) }
		}
	}

	redrawInternalState {
		// pads
		8.do { |r|
			8.do { |c|
				var pad = this.apcIndex(r,c);
				var state = padInternalState.at(r,c);
				var color = padColorsOfStates.at(r,c).at(state);
				out.noteOn(0,pad,color);
			}
		};
		// hor,ver
		8.do { |i|
			out.noteOn(0,i+64,horInternalState.at(i));
			out.noteOn(0,i+82,verInternalState.at(i));
		}
	}

	incrementState { |r,c|
		var state = padInternalState.at(r,c);
		var max = padSwitchNumStates.at(r,c);

		state = state + 1;
		if (state == max) {	state = 0 };

		padInternalState.put(r,c,state);

		^state;
	}

	// change from APC pad index to row/column internal index
	internalIndex { |pad|
		var row = 7 - floor((pad / 8));
		var column = pad % 8;
		^[row,column];
	}

	// change from row/column internal index to APC pad index
	apcIndex { |row,column|
		var pad = 56 - (row * 8) + column;
		^pad;

	}



	decrementState { |r,c|
		var state = padInternalState.at(r,c);
		var max = padSwitchNumStates.at(r,c);

		state = state - 1;
		if (state.isNegative) {	state = 0 };

		padInternalState.put(r,c,state);

		^state;
	}

	setState { |r,c,f|
		var state = f; // padInternalState.at(r,c);
		var max = padSwitchNumStates.at(r,c);

		// state = f;
		if (state == max) {	state = 0 };

		padInternalState.put(r,c,state);

		// set light
		out.noteOn(0,this.apcIndex(r,c);/*pad*/,padColorsOfStates.at(r,c).at(state));

		^state;
	}

}




