(
WFSPrePanSynthDefs.generateAll;
WFSArrayPanSynthDefs.generateAll( { |defs| d = defs } ); // takes apx 30s, watch post window
)

d; // these are all the array defs

// result: 104 files with a total size of 2.7MB
SynthDef.synthDefDir.openInFinder;

(	// loading goes quite fast
{
s.loadDirectory( SynthDef.synthDefDir );
s.sync;
"done".postln;
}.fork;
)

// higher numbers:
WFSArrayPanSynth.maxSize = 96; // default is 64
WFSArrayPanSynth.generateAllDefs( { |defs| d = defs }, 60 ); // takes apx 60s

// typical uses: (check cpu count)

( // 2 arrays double (focused and normal), cubic int (hi-q)
x = [
	Synth( "wfsa_fdc_48" ), 
	Synth( "wfsa_fdc_48" ), 
	Synth( "wfsa_ndc_48" ),
	Synth( "wfsa_ndc_48" ) 
];
)

( // 2 arrays double (focused and normal), linear int
x = [
	Synth( "wfsa_fdl_40" ), 
	Synth( "wfsa_fdl_56" ), 
	Synth( "wfsa_ndl_40" ),
	Synth( "wfsa_ndl_56" ) 
];
)

( // 2 arrays plane, cubic int (hi-q)
x = [ 
	Synth( "wfsa_pdc_48" ),
	Synth( "wfsa_pdc_48" ) 
];
)

( // 2 arrays static (highest possible for one server)
x = [ 
	Synth( "wfsa_usn_48" ),
	Synth( "wfsa_usn_48" )
];
)


/// here's a full example of dynamic panners, including
/// the pausing/unpausing of the array panners
(
c = WFSSpeakerConf.rect(48,48,5,5);
b = s.makeBundle( false, {
	var arrayConfs;
	var group;
	var prePanSynth;
	var normalSynths, focusSynths;
	var normalLevelBuses, focusLevelBuses;
	
	arrayConfs = c.getArrays(0,2); // first section of 2 systems

	normalLevelBuses = arrayConfs.collect({ |item, i| (i*2) + 2000 });
	focusLevelBuses = arrayConfs.collect({ |item, i| (i*2) + 2001 });
	
	group = Group(s);
	
	// make the panner synths, but don't send yet
	// these are normal and focused versions of dynamic c point
	normalSynths = arrayConfs.collect({ |item| Synth.basicNew( "wfsa_ndl_" ++ item.n, s ); }); 
	focusSynths = arrayConfs.collect({ |item| Synth.basicNew( "wfsa_fdl_" ++ item.n, s ); });
	
	// make the pre-panner synth (has to know the nodeID's of the panner synths)
	prePanSynth = Synth( "wfsp_d_" ++ arrayConfs.size, arrayConfs.collect({ |item,i|
		[ "arrayConf" ++ i, item.asArray, "cornerPoints" ++ i, item.asCornersArray ]
		}).flatten( 1 ) ++ [ 
			\normalLevelBuses, normalLevelBuses, 
			\focusLevelBuses, focusLevelBuses,
			\normalIDs, normalSynths.collect(_.nodeID),
			\focusIDs, focusSynths.collect(_.nodeID),
			//\normalIDs, normalSynths.collect(998), // override: non-existing id
			//\focusIDs, focusSynths.collect(998),
			\crossfadeLag, 0.2,
			\latencyComp, 0
			 // can only set at creation
		],
		group, addAction: \addToTail
	);
	
	// send the panner synths
	n = 0;
	normalSynths.do({ |sn, i|
		s.sendMsg( *sn.newMsg( group, [ 
				\arrayConf, arrayConfs[i], 
				\levelBus, normalLevelBuses[i],
				\outOffset, n
			], \addToTail ) 
		);
		n = n + arrayConfs[i].n;
	});
	
	n = 0;
	focusSynths.do({ |sn, i|
		s.sendMsg( *sn.newMsg( group, [ 
				\arrayConf, arrayConfs[i], 
				\levelBus, focusLevelBuses[i],
				\outOffset, n
			], \addToTail ) 
		);
		n = n + arrayConfs[i].n;
	});
	
	// assign to global vars
	p = prePanSynth; n = normalSynths; f = focusSynths;
	
});
);

// be sure to have the latest wslib!!
thisProcess.monitorOSC(true, [ '/wfs_masterInLevels', '/wfs_masterOutLevels' ] ); 

s.sendBundle(0.2, *b ); // and start

x = { PrivateOut.ar( 0, SinOsc.ar(440) ) }.play( addAction: \addToHead ); // make an input sound;

p.set( \u_gain, 40 );  // make audible on computer speakers (don't do this on wfs!!)

p.set( \point, [0,7] );  // get behind front array
p.set( \point, [0,0] );  // return to center

p.set( \pointLag, 0); // default
p.set( \pointLag, 0.5); // try changing the point again

p.set( \point, [0,5.01] ); // just behind array
p.set( \point, [0,4.99] ); // cross the array border
p.set( \crossfadeLag, 0.1 ); // longer crossfade time when crossing border
p.set( \pauseLag, 0.5 );

p.set( \dbRollOff, 0 ); // equal level for all points
p.set( \dbRollOff, -6 );

p.set( \pointFromBus, 1); // listen to bus (which is also set to point)
p.set( \pointFromBus, 0); // don't listen to bus

p.set( \dontPause, 1 ); // don't pause any panners (all run(1) )
p.set( \dontPause, 0 ); // pause silent panners (default)

( // make a circle outside arrays
a.free;
a = { ReplaceOut.kr( 1000, SinOsc.kr( 0.2, [0, 0.5pi] ).range( -15, 15); ) }.play( addAction: \addToHead );
)

( // make a circle inside arrays
a.free;
a = { ReplaceOut.kr( 1000, SinOsc.kr( 0.1, [0, 0.5pi] ).range( -4.5, 4.5 ); ) }.play( addAction: \addToHead );
)

a.free;

( // mix sum of array 1 and array 2 to left/right speakers
o.free;
o = { ReplaceOut.ar( 0, [ In.ar( 0, 40 ).sum/40, In.ar( 48, 40 ).sum/40 ] ) }.play( addAction: \addToTail );
)
Bus( \control, 1000, 2 ).set(0,0)
Bus( \control, 1000, 2 ).get; // see the point
Bus( \control, 2000, 4 ).get; // see the prepan fades

RootNode(s).dumpTree(true);

s.meter;

p.set( \u_doneAction, 14, \u_gate, 0, \u_fadeOut, 0.5 ); // release the whole group
