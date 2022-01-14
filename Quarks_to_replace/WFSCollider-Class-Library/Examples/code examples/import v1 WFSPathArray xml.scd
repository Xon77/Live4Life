// this file demonstrates how to import an xml file with trajectory
// data from WFSCollider version 1

(
Dialog.openPanel({ |file|
	var array;
	array = WFSPathArray.readWFSFile( file );
	UScore( *array.collect({ |path, i|
		UChain( 0, i, path.length, \bufSoundFile, [ \wfsSource, [ 
				\point, UMap( \trajectory, [ 
					\trajectory, WFSPathBuffer( path.asWFSPath2 ) ] ),
				\distanceFilter, 1
			]
		] )
	}) ).gui;
});
)