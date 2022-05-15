RadiationPatternSpec : Spec {
	
	var <>default;
	
	*new { |default = #[0,1,0,1]|
		^super.newCopyArgs( default );
	}
	
	*testObject { |obj|
		^(obj.isKindOf( ArrayedCollection ) ) && (obj.size == 4);
	}
	
	constrain { |value|
		value = value.asCollection;
		if( value.size != 4 ) {
			value = value.extend( 4, 0 );
		};
		^value.clip([0,0,0,1], [1, 1, 1, 8]).round([0,0,0,1]);
	}
	
	map { |value|
		^this.constrain( value );
	}
	
	unmap { |value|
		^this.constrain( value );
	}
	
	storeArgs {
	    ^[ default ]
	}
	
	// views
	
	viewNumLines { ^4 }
	
	makeView { |parent, bounds, label, action, resize|
		var view, vws, stp, labelWidth;
		var subViewHeight, subViewWidth;
		var getPoint;
		var angle = 0, angleCtrl, direction, currentUnit;
		
		vws = ();
		
		vws[ \val ] = default.copy;
		
		view = EZCompositeView( parent, bounds );
		vws[ \view ] = view.view;
		bounds = view.view.bounds;
		
		if( label.notNil ) {
			labelWidth = (RoundView.skin ? ()).labelWidth ? 80;
			vws[ \labelView ] = StaticText( view, labelWidth @ 14 )
				.string_( label.asString ++ " " )
				.align_( \right )
				.resize_( 4 )
				.applySkin( RoundView.skin );
		} {
			labelWidth = -4;
		};
		
		subViewHeight = bounds.height / 4;
		subViewWidth = bounds.width - (labelWidth + 4) - (subViewHeight * 3) - 2;
		
		currentUnit = UGUI.nowBuildingUnit;
		
		if( currentUnit.notNil ) {
			direction = currentUnit.get( \direction );
			if( direction.notNil ) {
				if( direction.isUMap.not ) { angle = direction; };
				angleCtrl = SimpleController( currentUnit )
					.put( \direction, { 
						direction = currentUnit.get( \direction );
						if( direction.isUMap.not ) { 
							angle = direction; 
						} {
							angle = 0;
						};
						{ vws[ \plot ].refresh }.defer;
					});
			};
			view.onClose_( { angleCtrl.remove } );
		};
		
		getPoint = { |inAngle = 0|
			var values, n;
			values = vws[ \val ][..2];
			values = values / values.abs.sum.max(1.0e-12);
			n = vws[ \val ][3];
			values[0] + values[1..].collect({ |sine, i|
				((inAngle + angle) * (i+1) * n).cos * sine;
			}).sum;
		};
		
		vws[ \plot ] = UserView( view, (subViewHeight@subViewHeight) * 3 )
			.background_( Color.gray(0.5) )
			.drawFunc_({ |vw|
				var radius, points, pos, n = 64;
				radius = (vw.bounds.width / 2) - 2;
				#points, pos = n.collect({ |i|
					var value;
					i = i.linlin(0,n,0,2pi);
					value = getPoint.( i );
					[
						Polar( value.abs * radius, i ).asPoint,
						value.isPositive.binaryValue
					] 
				}).flop;
				
				Pen.use({
					// grid
					Pen.width = 1;
					Pen.translate( *vw.bounds.moveTo(0,0).center.asArray );
					Pen.color = Color.black.alpha_(0.125);
					4.do({ |i|
						Pen.addArc( 0@0, radius * (0-(i*6)).dbamp, 0, 2pi );
					});
					4.do({ |i|
						i = i * 0.25pi;
						Pen.line( 
							Polar( radius, i ).asPoint,
							Polar( radius, i + pi ).asPoint
						);
					});
					Pen.stroke;
					
					Pen.width = 1.5;
					
					// plot
					Pen.color = Color.white.alpha_(0.5);
					Pen.line( points[0] * (1-pos[0]), points[1] * (1-pos[1]) );
					points[2..].do({ |pt, i| Pen.lineTo( pt * (1-pos[i+2]) ) });
					Pen.lineTo( points[0] * (1-pos[0]) );
					Pen.stroke;
					
					Pen.color = Color.black.alpha_(0.5);
					Pen.line( points[0] * pos[0], points[1] * pos[0] );
					points[2..].do({ |pt, i| Pen.lineTo( pt * pos[i+2] ) });
					Pen.lineTo( points[0] * pos[0] );
					Pen.stroke;
					
				});
			});
			
		vws[ \controls ] = CompositeView( view, 
			subViewWidth @ (subViewHeight * 3)
		).resize_(2);
		
		vws[ \controls ].addFlowLayout( 0@0, 2@2 );
		
		[ \omni, \dipole, \quadrupole ].do({ |name, i|
			vws[ name ] = EZSmoothSlider( vws[ \controls ], 
				subViewWidth @ (subViewHeight - 2),
				name.asString[0].asString, 
				[0,1].asSpec, 
				{ |vw|
					vws[ \val ][ i ] = vw.value;
		        		action.value( vws, vws[ \val ] );
		    		},
		    		vws[ \val ][ i ]
			).labelWidth_( 10 );
			vws[ name ].view.resize = 2;
		});
		
		view.view.decorator.nextLine;
		view.view.decorator.shift( labelWidth + 4 + (subViewHeight * 3), -2 );
		vws[ \n ] = EZSmoothSlider( view, 
			subViewWidth @ subViewHeight,
			"n", 
			[1,8,\lin,1,1].asSpec, 
			{ |vw|
				vws[ \val ][ 3 ] = vw.value;
	        		action.value( vws, vws[ \val ] );
	    		},
	    		vws[ \val ][ 3 ]
		).labelWidth_( 10 );
		vws[ \n ].view.resize = 2;
		^vws;	
	}
	
	setView { |vws, value, active = false|
		vws[ \val ] = value;
		[ \omni, \dipole, \quadrupole, \n ].do({ |name, i|
			vws[ name ].value = value[i];
		});
		{ vws[ \plot ].refresh }.defer;
		if( active ) { vws[ \omni ].doAction };
	}
	
	mapSetView { |vws, value, active = false|
		value = this.constrain( value );
		vws[ \val ] = value;
		[ \omni, \dipole, \quadrupole, \n ].do({ |name, i|
			vws[ name ].value = value[i];
		});
		{ vws[ \plot ].refresh }.defer;
		if( active ) { vws[ \omni ].doAction };
	}
	
	expandArgSpecs {
		^[[\o,0], [\d,1], [\q,0]].collect({ |item|
			ArgSpec( item[0], item[1], [0,1,\lin].asSpec );
		}) ++ [ ArgSpec( \n, 1, [1,8,\lin,1,1].asSpec ) ];
	}
}