// The code below generates a series of test signals for each speaker of 
// the currently active setup. In the default settings this generates 
// short pink noise bursts, twice on each group of 8 speakers.

(
n = 8; // size of speaker groups
z = 1/4; // duration per burst
t = \pinkNoise; // udef name for sound generation
r = 2; // number of repeats per group
x = UScore();

(WFSSpeakerConf.default.speakerCount / n).ceil.do({ |i|
	var folder;
	folder = UScore( i * (r * (n + 1) * z) );
	x.add( folder );
	r.do({ |ii|
		n.do({ |iii|
			folder.add( UChain( ((ii * (n + 1)) + iii) * z, iii, z * (3/4), 
				[ t, [ \seed, 12345 ] ],
				[ \wfsIndex, [ \index, (i * 8) + iii, \gain, 0 ] ]
				)
			);
		});
	});
	folder.name = ([1,n] + (i*8)).join("-");  
});

x.gui;
)