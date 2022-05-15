WFSPathGeneratorDef(
	\align,
	{ |f, path, n| 
		var direction, amount, mode;
		var current, mean, extent, size;
		current = path.positions.deepCopy;
		direction = f.get( \direction );
		mode = f.get( \mode );
		switch( mode,
			\line, {
				current = current.collect(_.rotate( direction * 0.5pi) );
				mean = current.collect(_.x).mean;
				current = current.collect({ |item|
					item.x = mean;
					item.rotate( direction * -0.5pi );
				});
			}, 
			\circle, {
				current = current.collect(_.asPolar);
				mean = current.collect(_.rho).mean;
				current = current.collect({ |item|
					item.rho = mean;
					item.asPoint;
				});
			}, 
			\spacing, {
				current = current.collect(_.rotate( direction * 0.5pi) );
				size = current.size;
				extent = [ current[0].y, current.last.y ];
				current = current.collect({ |item, i|
					item.y = i.linlin(0, size-1, extent[0], extent[1] );
					item.rotate(  direction * -0.5pi );				});
			},
			\spacing_nearest, {
				current = current.collect(_.rotate( direction * 0.5pi) );
				extent = 	current.collect(_.y);
				size = extent.size;
				extent = [ extent.minItem, extent.maxItem ];
				current = current.collect({ |item, i|
					[ item, i ]
				}).sort( { |a,b| a[0].y <= b[0].y }).collect({ |item, i|
					item[0].y = i.linlin(0, size-1, *extent );
					[ item[0].rotate(  direction * -0.5pi ), item[1] ]
				}).sort( { |a,b| a[1] <= b[1] } ).collect(_[0]);
			},
		);
		path.positions = current;
	},
	[ \direction, 0.0, \mode, \line ]
)	
	.changesT_( false )
	.setSpec( \direction, ControlSpec(0,1) )
	.setSpec( \mode, ListSpec([\line, \circle, \spacing, \spacing_nearest]) );