// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/changeBus-td5761366.html#a5768052

FadeBusOut : AbstractOut {
	*ar { arg outBus = 0, signal = 0.0, maxFadeTime = 0.02, fadeTime = 0.02;
 		var changed, newOut, oldOut, initTrig;

		initTrig = Impulse.kr(0);
 		outBus = K2A.ar(outBus);
		changed = HPZ1.ar(outBus).abs;
		newOut = Delay1.ar(outBus);
 		oldOut = DelayN.ar(outBus, maxFadeTime, fadeTime);

		OffsetOut.ar(newOut, signal * EnvGen.ar(Env([0, 0, 1], [0, fadeTime], \lin), gate: changed + initTrig));
 		OffsetOut.ar(oldOut, signal * EnvGen.ar(Env([0, 1, 0], [0, fadeTime], \lin), gate: changed));
		^0.0;
 	}
}