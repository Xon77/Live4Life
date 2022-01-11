WFSPathGeneratorDef(
	\randTime,
	{ |f, path, n| 
		var min, max, seed, dur;
		min = f.get( \min );
		max = f.get( \max );
		seed = f.get( \seed );
		dur = path.times.sum;
		thisThread.randSeed = f.get( \seed );
		path.times = path.times.collect({ |item|
			(item * min) exprand: (item * max);
		}).normalizeSum( dur ) * dur;
	},
	[ \min, 0.5, \max, 2, \seed, 12345 ]
)
	.changesX_( false )
	.changesY_( false )
	.setSpec( \min, [0.01, 100, \exp, 0, 0.5].asSpec )
	.setSpec( \max, [0.01, 100, \exp, 0, 2].asSpec )
	.setSpec( \seed, PositiveIntegerSpec(12345) );