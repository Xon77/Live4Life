ArrayTransformerDef( \clip, { |f, obj|
	var range;
	range = f.get( \clip );
	if( (range[1] - range[0]) > 0 ) {	
		obj = obj.linlin( *range ++ [-1,1,'none'] );
		switch( f.get( \clipMode ),
			\clip, { obj.softclip2(1, f.get( \clipSoftness ) ); },
			\sineClip, { obj.sineclip2(1, f.get( \clipSoftness ) ); },
			\fold, { obj.softfold2(1, f.get( \clipSoftness ) ); },
			\wrap, { obj.softwrap2(1, f.get( \clipSoftness ) ); },
			\excess, { obj.softexcess2(1, f.get( \clipSoftness ) ); },
			{ obj }
		).linlin( *[-1,1] ++ range ++ [ 'none' ] ); 
	} {
		switch( f.get( \clipMode ),
			\clip, { obj.clip(*range); },
			\sineClip, { obj.clip(*range); },
			\fold, { obj.fold(*range); },
			\wrap, { obj.wrap(*range); },
			\excess, { obj },
			{ obj }
		);
	};
}, [ \clip, #[0,1], \clipMode, \clip, \clipSoftness, 0.0 ], { |f, obj|
	[ \clip, #[0,1], \clipMode, f.get( \clipMode ), \clipSoftness, 0.0 ]
} )
	.bypassFunc_({ |f, obj| f.get( \clipMode ) == \off })
	.mappedArgs_([\clip])
	.setSpec( \clip, [0,1].asSpec.asRangeSpec )
	.setSpec( \clipMode, ListSpec( [ \clip, \sineClip, \fold, \wrap, \excess, \off ] ) )
	.setSpec( \clipSoftness,[0,1].asSpec );