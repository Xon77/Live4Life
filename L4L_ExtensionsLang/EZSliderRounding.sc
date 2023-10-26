// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/EZSlider-issues-td7581060.html
// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/EZSlider-value-display-resolution-td7594744.html#a7594845

// Methods for analyzing step precision and adapting EZSliders

+Float {
	decimalStrings { |precision = 8|
		var precString = this.asStringPrec(precision), prePointString,
		postPointString,
		signString, manString, expString, posOfPoint, shift;

		#manString, expString = precString.split($e);
		(manString[0] == $-).if {
			manString = manString.drop(1);
			signString = "-";
		};

		expString.isNil.if {
			// no exponent
			posOfPoint = precString.find(".");
			posOfPoint.isNil.if {
				prePointString = precString;
			}{
				prePointString = precString.copyFromStart(posOfPoint-1);
				postPointString = precString.copyToEnd(posOfPoint+1);
			}
		}{
			// with exponent
			shift = expString.drop(1).asInteger;
			(expString[0] == $+).if {
				(manString.size == 1).if {
					// no comma
					prePointString = manString ++ ($0!shift).join;
				}{
					(shift < (manString.size-2)).if {
						prePointString = manString[0].asString ++ manString.copyRange(2,
							shift+1);
						postPointString = manString.copyToEnd(shift+1);
					}{
						prePointString = manString[0].asString ++ manString.copyToEnd(2)
						++
						($0 ! (shift - (manString.size-2))).join;	 }
				}
			}{
				prePointString = "0";
				(manString.size == 1).if {
					// no comma
					postPointString = ($0!(shift-1)).join ++ manString;
				}{
					postPointString = ($0!(shift-1)).join ++
					manString[0].asString ++ manString.copyToEnd(2);
				}
			}
		};
		^[signString, prePointString, postPointString]
	}

}

+SimpleNumber {
	decimalStrings { ^this.asFloat.decimalStrings }
}


+EZSlider {
	adaptToControlStep { |precision = 8|
		var stepString, range;
		stepString = controlSpec.step.decimalStrings(precision);
		this.round = 10 ** stepString.last.size.neg;
		(GUI.id == \qt).if {
			numberView.maxDecimals = stepString.last.size;
			controlSpec.warp.isKindOf(LinearWarp).if {
				range = controlSpec.constrain(controlSpec.clipHi) -
				controlSpec.constrain(controlSpec.clipLo);
				sliderView.step = 1 / (range / controlSpec.step).round;
			}
		}
		^this
	}
}





/*
Examples:

GUI.qt;

// jitter with Qt in this example disappears with
// uncommenting method for adaption to step size

(
a = [0, 10, \lin, 2, 0];

w = Window.new.front;
e = EZSlider(w, controlSpec: a.asSpec)
//	.adaptToControlStep;
)


// jitter with Qt and no numbers in neither kit
// you would have to set step (round, maxDecimals)

// with .adaptToControlStep no jitter in Qt and
// numbers displayed correctly in both GUIs

(
a = [0, 0.0001, \lin, 0.00001, 0];

w = Window.new.front();
e = EZSlider(w, controlSpec: a.asSpec, numberWidth: 90)
//	.adaptToControlStep;
)

// probably it will / should remain users responsibility to set
// appropriate numberWidth, as there is also Font ...


// bounds set correctly but jitter in Qt:

(
a = [10, 40, \exp, 5, 10];

w = Window.new.front;
e = EZSlider(w, controlSpec: a.asSpec)
)

// wrongs bounds

(
a = [10, 40, \exp, 6, 10];

w = Window.new.front;
e = EZSlider(w, controlSpec: a.asSpec)
)

An alternative and easy workaround for step precision adaption
is, of course, scaling of slider values afterwards ...


Greetings

Daniel
*/




















// This still doesn't handle step = 0 as expected, it could be like this:

+EZSlider {
	*new2 { arg parent, bounds, label, controlSpec, action, initVal,
		initAction=false, labelWidth=60,
		numberWidth=45,
		unitWidth=0, labelHeight=20, layout=\horz,
		gap, margin,
		precision = 8, stepEqualZeroDiv = 100;

		^this.new(parent, bounds, label, controlSpec, action,
			initVal, initAction, labelWidth, numberWidth,
			unitWidth, labelHeight, layout, gap, margin
		).adaptToControlStep(precision, stepEqualZeroDiv);
	}

	adaptToControlStep { |precisionSpan = 8, stepEqualZeroDiv =
		100|
		var stepString, range, estimatedControlStep;

		estimatedControlStep =  (controlSpec.step.abs  <  (10
			**  precisionSpan.neg)).if {
			(controlSpec.clipHi - controlSpec.clipLo) /
			stepEqualZeroDiv
		}{
			controlSpec.step
		};
		stepString = estimatedControlStep.decimalStrings(precisionSpan);
		this.round = 10 ** stepString.last.size.neg;
		range = controlSpec.constrain(controlSpec.clipHi) -
		controlSpec.constrain(controlSpec.clipLo);
		sliderView.step = 1 / (range /
			estimatedControlStep).round;
		(GUI.id == \qt).if { numberView.maxDecimals =
			stepString.last.size };
		^this
	}
}



/*
// division of 100 (stepEqualZeroDiv) for step = 0 and
// else by precision implicitely defined by step -
// the precision arg of adaptToControlStep indicates
// the span of decimals to be regarded for step

(
a = [0, 1, \lin, 0, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)

(
a = [0, 10, \lin, 0, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)

(
a = [0, 100, \lin, 0, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)

(
a = [0, 1000, \lin, 0, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)

(
a = [0, 1000, \lin, 0.1, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)

(
a = [0, 1, \lin, 0.1, 0];
e = EZSlider.new2(controlSpec: a.asSpec)
)


Greetings

Daniel
*/