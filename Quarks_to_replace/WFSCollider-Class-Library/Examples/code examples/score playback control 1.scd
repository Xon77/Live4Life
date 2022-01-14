//play 3 seconds and stop by itself
(
z = UScore( UChain(0,0,3,\sine, \wfsSource ).fadeOut_(1).fadeIn_(1) );
y = z.gui;
fork{
	z.prepareAndStart(ULib.servers,0);
}
)


//play 3.5 seconds and stop;
(
z = UScore( UChain(0,0,10,\sine, \wfsStaticPoint).fadeOut_(1).fadeIn_(1) );
y = z.gui;
fork{
	z.prepareAndStart(ULib.servers,0);
	0.5.wait;
	if(z.isPlaying != true){ "error ! isPlaying should be true".throw };
	3.wait;
	z.stop;
	if(z.isPlaying != false){ "error ! isPlaying should be false".throw };
}
)

//play 3 seconds and pause for 1 seconds then stop;
//note that the pause will not stop the chain from playing, but does halt the timeline
(
z = UScore( UChain(0,0,10,\sine, \wfsStaticPoint).fadeOut_(1).fadeIn_(1) );
y = z.gui;
fork{
	z.prepareAndStart(ULib.servers,0);
	3.wait;
	z.pause;
	if(z.isPaused != true){ "error ! isPaused should be true".throw };
	1.wait;
	z.stop;
}
)

// should play 2 tones, the lower tone stop after 5 seconds, the hight tone stops after 8 seconds
// 'releaseSelf' for the first UChain is set to false, which means that the score timeline
// decides when the event stops.
(
r = UChain(0,0,5,false,[\sine, [\freq, 956]], \wfsSource).fadeOut_(1).fadeIn_(1);
v = UChain(0,1,5,true, [\sine, [\freq, 400]], \wfsSource).fadeOut_(1).fadeIn_(1);
z = UScore(r,v);
y = z.gui;
fork{
	z.prepareAndStart(ULib.servers,0);
	3.wait;
	z.pause;
	if(z.isPaused != true){ "error ! isPaused should be true".throw };
	3.wait;
	z.resume;
	if(z.isPaused != false){ "error ! isPaused should be true".throw };
}
)

// play some sound files.
// the looped files will become infinite duration events, which are only stopped when the
// score ends
(
z = UScore(
	*12.collect({ |i|
		BufSndFile("@resources/sounds/a11wlk01-44_1.aiff", 
			rate: (i-6).midiratio, loop: [true,false].wrapAt(i) ).makeUChain( \wfsSource )
				.startTime_(i/2).track_(i).fadeOut_(1).fadeIn_(1);
	})
);
y = z.gui;
z.prepareAndStart;
)


