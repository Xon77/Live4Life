/*
\sinGrain

granular synthesis with sine tones.

This udef belongs to "user udef.uscore" (but can also be used elsewhere). The def will be loaded automatically if it is in the same folder as the score file, or a subfolder of it (as in this case). It will only be loaded if it (or another udef by the same name) is not already in the system.
*/

Udef( \sinGrain, { |freq = #[ 20, 20000 ], dens = 100, overlap = 1, amp = 0.1|
	var sig;
	URandSeed.ir(); // needed for Udefs with random elements
	sig = GrainSin.ar( 1, Dust.ar( dens ), overlap/dens, WhiteNoise.ar.exprange( *freq ) ) * amp;
	UOut.ar(0, sig );
})
	.category_( \synthesis )
	.setSpec( \freq, \freq.asSpec.asRangeSpec.default_( [20,20000] ) )
	.setSpec( \dens, [ 1, 1000, \exp, 0, 100 ].asSpec )
	.setSpec( \overlap, [ 0.1, 10, \exp, 0, 1 ].asSpec );
	

