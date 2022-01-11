WFSPathGeneratorDef(
	\lineTime,
	{ |f, path, n| 
		var start, end, curve, dur, nx;
		start = f.get( \start );
		end = f.get( \end );
		curve = f.get( \curve );
		dur = path.times.sum;
		nx = path.times.size - 1;
		path.times = path.times.collect({ |item, i|
			i.lincurve( 0, nx, start, end, curve ) * item			}).normalizeSum( dur ) * dur;
	},
	[ \start, 0.5, \end, 2, \curve, 0 ]
)
	.changesX_( false )
	.changesY_( false )
	.setSpec( \start, [0.01, 100, \exp, 0, 0.5].asSpec )
	.setSpec( \end, [0.01, 100, \exp, 0, 2].asSpec )
	.setSpec( \curve, [-16, 16, \lin, 0, 0].asSpec );
