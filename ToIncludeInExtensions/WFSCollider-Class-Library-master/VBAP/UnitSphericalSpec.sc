
UnitSphericalSpec : Spec {

	var <step, <>default, <>units;

	*new { |step, default, units|
		^super.newCopyArgs( step ? UnitSpherical(0,0), default ? UnitSpherical(0,0), units ? "" );
	}

	*testObject { |obj|
		^obj.class == UnitSpherical;
	}

	step_ { |inStep| step = inStep.asUnitSpherical }

	roundToStep { |value|
		value = value.asUnitSpherical;
		value.theta = value.theta.round( step.theta );
		value.phi = value.phi.round( step.phi );
		^value;
	}

	constrain { |value|
		^this.roundToStep( value );
	}

	map { |value|
		^this.constrain( value );
	}

	unmap { |value|
		^this.constrain( value );
	}
	
	
    	makeView { |parent, bounds, label, action, resize|
		var vws, view, labelWidth;
		var localStep;
		var startVal;
		vws = ();

		vws[ \val ] = UnitSpherical(0,0);

		localStep = step.copy;
		if( step.theta == 0 ) { localStep.theta = 1 };
		if( step.phi == 0 ) { localStep.phi = 1 };

		bounds.isNil.if{bounds= 160@20};

		#view, bounds = EZGui().prMakeMarginGap.prMakeView( parent, bounds );
		 vws[ \view ] = view;

		if( label.notNil ) {
			labelWidth = (RoundView.skin ? ()).labelWidth ? 80;
			vws[ \labelView ] = StaticText( vws[ \view ], labelWidth @ bounds.height )
				.string_( label.asString ++ " " )
				.align_( \right )
				.resize_( 4 )
				.applySkin( RoundView.skin );
		} {
			labelWidth = 0;
		};

		vws[ \theta ] = SmoothNumberBox( vws[ \view ], Rect( labelWidth + 2, 0, 40, bounds.height ) )
			.action_({ |nb|
				vws[ \val ] = UnitSpherical( nb.value, vws[ \phi ].value );
				action.value( vws, vws[ \val ]);
			})
			//.step_( localStep.theta )
			.scroll_step_( localStep.theta )
			.value_(0);

		vws[ \thetaphi ] = XYView( vws[ \view ],
			Rect( labelWidth + 2 + 42, 0, bounds.height, bounds.height ) )
			.action_({ |xy|
				startVal = startVal ?? { vws[ \val ].copy; };
				vws[ \theta ].value = (startVal.theta + (xy.x * localStep.theta));
				vws[ \phi ].value = (startVal.phi + (xy.y * localStep.phi.neg));
				action.value( vws, UnitSpherical( vws[ \theta ].value, vws[ \phi ].value ) );
			})
			.mouseUpAction_({
				vws[ \val ] = UnitSpherical( vws[ \theta ].value, vws[ \phi ].value );
				startVal = nil;
			});

		vws[ \phi ] = SmoothNumberBox( vws[ \view ],
				Rect( labelWidth + 2 + 42 + bounds.height + 2, 0, 40, bounds.height ) )
			.action_({ |nb|
				vws[ \val ] = UnitSpherical( vws[ \theta ].value, nb.value );
				action.value( vws,  vws[ \val ] );
			})
			//.step_( localStep.phi )
			.scroll_step_( localStep.phi )
			.value_(0);

		^vws;
	}

	setView { |view, value, active = false|
		var constrained;
		constrained = this.constrain( value );
		view[ \theta ].value = constrained.theta;
		view[ \phi ].value = constrained.phi;
		view[ \val ] = constrained;
		if( active ) { view[ \theta ].doAction };
	}

	mapSetView { |view, value, active = false|
		var mapped;
		mapped = this.map( value );
		view[ \x ].value = mapped.theta;
		view[ \y ].value = mapped.phi;
		view[ \val ] = mapped;
		if( active ) { view[ \x ].doAction };
	}

	storeArgs {
	    ^[step, default, units]
	}

}
