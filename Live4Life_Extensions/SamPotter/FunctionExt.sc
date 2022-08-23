+ Function {
	note { |starttime, duration, addAction = 0, target = 1, server|
		^CtkSynthDef("tmp-def-" ++ rrand(1000000000, 9999999999), this).note(
			starttime, duration, addAction, target, server);
	}
}