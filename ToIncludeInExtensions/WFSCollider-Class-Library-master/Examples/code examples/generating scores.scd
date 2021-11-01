
//harmonic
//long
(
f = 60.collect({ |i| // generate 60 UChains
		var evt;
		var start = rrand(0.0,10.0);
		var dur = rrand(0.1,3.0);
		evt = UChain(start,0,dur,\pulse, \wfsSource).fadeOut_(0.1*dur).fadeIn_(0.1*dur);
		evt.units[0].set(\freq,100*rrand(1,10).postln );
		evt.units[1].set(\point, rrand(-5.0,5.0)@rrand(-5.0,5.0));
		evt;
	});
x = UScore(*f).cleanOverlaps; // put them in a score, cleanup overlapping tracks
x.gui;

)
//short
(
f = 120.collect({ |i|
		var evt;
		var start = rrand(0.0,10.0);
		var dur = rrand(0.1,0.5);
		evt = UChain(start,0,dur,\pulse, \wfsSource ).fadeOut_(0.1*dur).fadeIn_(0.1*dur);
		evt.units[0].set(\freq, 100*rrand(1,15) );
		evt.units[1].set(\point, rrand(-5.0,5.0)@rrand(-5.0,5.0));
		evt;
	});
x = UScore(*f).cleanOverlaps;
x.gui;

)

//long
(
f = 60.collect({ |i|
		var evt;
		var start = rrand(0.0,10.0);
		var dur = rrand(0.1,3.0);
		evt = UChain(start,0,dur,\pulse, \wfsSource ).fadeOut_(0.1*dur).fadeIn_(0.1*dur);
		evt.units[0].set(\freq, rrand(100.0,600.0) );
		evt.units[1].set(\point, rrand(-5.0,5.0)@rrand(-5.0,5.0));
		evt;
	});
x = UScore(*f).cleanOverlaps;
x.gui;

)
//short
(
f = 120.collect({ |i|
		var evt;
		var start = rrand(0.0,10.0);
		var dur = rrand(0.1,0.5);
		evt = UChain(start,0,dur,\pulse, \wfsSource ).fadeOut_(0.1*dur).fadeIn_(0.1*dur);
		evt.units[0].set(\freq, rrand(100.0,600.0) );
		evt.units[1].set(\point, rrand(-5.0,5.0)@rrand(-5.0,5.0));
		evt;
	});
x = UScore(*f).cleanOverlaps;
x.gui;

)
