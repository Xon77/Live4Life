WFSPathGeneratorDef(
	\brown,
	{ |f, path, n| 
		var center, radius, minRadius, angleStep, step;
		var wx, wy;
		var wr, wa;
		center = f.get( \center );
		radius = f.get( \radius );
		angleStep = (f.get( \angleStep ) / 360) * 2pi;
		step = f.get( \step );
		thisThread.randSeed = f.get( \seed );
		wr = Pbrown( 0, 1, step ).asStream;
		wa = Pseries( 0, Pwhite( angleStep.neg, angleStep ) ).asStream;
		path.positions = n.collect({ 
			(Polar( wr.next, wa.next ).asPoint * radius) + center
		});
		path;
	},
	[  \center, 0@0, \radius, 10@10,
		\angleStep, 20, \step, 0.125, \seed, 12345 ]
)
	.changesT_( false )
	.setSpec( \seed, PositiveIntegerSpec(12345) )
	.setSpec( \center, PointSpec( 200, 0.1@0.1 ) )
	.setSpec( \radius, PointSpec( Rect(0,0,200,200), 0.1@0.1 ) )
	.setSpec( \angleStep, [0,360].asSpec )
	.setSpec( \step, [0,1].asSpec );
