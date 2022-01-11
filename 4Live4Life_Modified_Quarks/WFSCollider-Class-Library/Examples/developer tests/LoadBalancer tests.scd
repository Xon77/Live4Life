(
~lbs = 2.collect({ |i|
	LoadBalancer( *WFSServers.default.multiServers[i].servers );
});

ULib.servers = [ s ] ++ ~lbs;

UChain.defaultServers = [ s ] ++ ~lbs;
)

(
thisThread.randSeed = 12345;
r = 120.collect({ |i|
	UChain(rrand(0.5,2.0),i,2,true,
		[\sine,[\freq,rrand(200.0, 1000.0)]], 
		[ \wfsStaticPoint, [ 
				\point, 10.0.rand2 @ 10.0.rand2,
				\dbRollOff, -3 
			]
		]
	).fadeOut_(1.75).fadeIn_(0.001);
}).sort;

z = UScore(*r);
x = UScoreEditor(z);
y = UScoreEditorGUI(x);

)


(

thisThread.randSeed = 12345;
r = 60.collect({ |i|
	UChain( i.linlin(0,60,1,3),i,0.2,true,
		[\sine,[\freq,rrand(200.0, 1000.0)]], 
		[ \wfsStaticPoint, [ 
				\point, 10.0.rand2 @ 10.0.rand2,
				\dbRollOff, -3 
			]
		]
	).fadeOut_(0.01).fadeIn_(0.01);
}).sort;

z = UScore(*r);
x = UScoreEditor(z);
y = UScoreEditorGUI(x);

)


(

thisThread.randSeed = 12345;
r = 10.collect({ |i|
	UChain( i.linlin(0,60,1,3),i,2,true,
		[\sine,[\freq,rrand(200.0, 1000.0)]], 
		[ \wfsDynamicPoint, [ 
				\point, 10.0.rand2 @ 10.0.rand2,
				\dbRollOff, -3 
			]
		]
	).fadeOut_(0.01).fadeIn_(0.01);
}).sort;

z = UScore(*r);
x = UScoreEditor(z);
y = UScoreEditorGUI(x);

)


(

( // speakertest
r = (
192.collect({ |i|
	UChain( i.linlin(0,192,1,26),i%8,0.03,true,
		[\sine,
			[
				\freq, ([ 0, 2, 4, 5, 7, 9, 11, 12 ].reverse[i%8] + 64).midicps
			]
		], 
		[ \wfsStaticIndex, [ \index, i.asInteger ] ]
	).fadeOut_(0.02);
}) ++ (((..23) * 8) + 3).collect({ |i|
	UChain( i.linlin(0,192,1,26),8,0.5,true,
		[\sine, [ \freq, 60] ], 
		[ \wfsStaticIndex, [ \index, i.asInteger ] ]
	).fadeIn_(0).fadeOut_(0.45);
})
).sort;
);

z = UScore(*r);
x = UScoreEditor(z);
y = UScoreEditorGUI(x);

)

(
( // random rhythm
a = [ 0, 2, 4, 5, 7, 9, 11, 12 ].scramble;
r = (
192.collect({ |i|
	UChain( i.linlin(0,192,1,26),i%8,0.2,true,
		[ \sine, [
				\freq, (a[i%8] + 64).midicps
			]
		], 
		[ \wfsStaticPoint,[ 
				\point, 20.0.rand2 @ 20.0.rand2,
				\latencyComp, 1,
				\dbRollOff, 0  
			] 
		]
	).fadeIn_(0.1).fadeOut_(0.01);
})
).sort;
);

z = UScore(*r);
x = UScoreEditor(z);
y = UScoreEditorGUI(x);

)

LoadBalancer.all.collect(_.loads); 
// should be [ [ 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0 ] ]

LoadBalancer.all.collect(_.reset);
