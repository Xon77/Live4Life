WFSPathTransformerDef( \clip, { |f, path|
	var range;
	var obj, center;
	if( f.get( \clip ) != \off ) {
		center =  f.get( \clipCenter );
		obj = path.positions.collect( _ - center );
		range = f.get( \clipRadius );
		if( f.get( \polar ) == true ) {	
			range = range.clip(1.0e-12, inf);
			obj = obj.collect({ |item| item = (item / range).asPolar; [item.rho, item.theta] }).flop;
			obj[0] = switch( f.get( \clip ),
				\softClip, { obj[0].softclip2(1, f.get( \clipSoftness ) ) },
				\sineClip, { obj[0].sineclip2(1, f.get( \clipSoftness ) ); },
				\fold, { obj[0].softfold2(1, f.get( \clipSoftness ) ); },
				\wrap, { obj[0].softwrap2(1, f.get( \clipSoftness ) ); },
				\excess, { obj[0].softexcess2(1, f.get( \clipSoftness ) ); },
				{ obj[0] }
			);
			obj = obj.flop.collect({ |item| Polar( item[0], item[1] ).asPoint * range });
		} {	
			obj = switch( f.get( \clip ),
				\softClip, { obj.softclip2(range, f.get( \clipSoftness ) * range ) },
				\sineClip, { obj.sineclip2(range, f.get( \clipSoftness ) * range ); },
				\fold, { obj.softfold2(range, f.get( \clipSoftness ) * range ); },
				\wrap, { obj.softwrap2(range, f.get( \clipSoftness ) ); },
				\excess, { obj.softexcess2(range, f.get( \clipSoftness ) * range ); },
				{ obj }
			);
		};
		path.positions = obj.collect( _ + center );
	};
}, [ \clip, \off, \clipSoftness, 0.0, \clipCenter, 0@0, \clipRadius, 5@5, \polar, false ] )
	.setSpec( \clipCenter, PointSpec(200) )
	.setSpec( \clipRadius, PointSpec(Rect(0,0,200,200)) )
	.setSpec( \clip, ListSpec( [ \softClip, \sineClip, \fold, \wrap, \excess, \off ] ) )
	.setSpec( \polar, BoolSpec( false ) )
	.setSpec( \clipSoftness,[0,1].asSpec );