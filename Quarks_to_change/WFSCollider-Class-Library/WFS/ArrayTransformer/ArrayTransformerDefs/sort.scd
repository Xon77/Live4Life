ArrayTransformerDef( \sort, 
	{ |f, obj| 
		var sorted, old, type;
		type = f.get( \sort );
		if( type != \scramble ) { f.environment[ \seed ] = nil; };
		switch( type,
			\up, {
				obj.sort({ |a,b|
					a.rho <= b.rho;
				});
			},
			\down, {
				obj.sort({ |a,b|
					a.rho >= b.rho;
				});
			},
			\scramble, {
				if( f.environment[ \seed ].isNil ) {
					f.environment[ \seed ] = 1569325056.rand;
				};
				thisThread.randSeed = f.environment[ \seed ];
				obj.scramble;
			},
			\nearest, {
				old = obj.deepCopy.reverse;
				sorted = Array( old.size );
				sorted.add( old.pop );
				old.size.do({ 
					old.sort({ |a,b|
						a.absdif( sorted.last ) >= b.absdif( sorted.last )
					});
					sorted.add( old.pop );
				});
				sorted;
			},
			{ obj }
		);
	}, 
	[ \sort, \off ]
)
	.setSpec( \sort, ListSpec( [ \off, \up, \down, \scramble, \nearest ] ) );