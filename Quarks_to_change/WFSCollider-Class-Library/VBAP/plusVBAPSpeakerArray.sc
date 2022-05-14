+ VBAPSpeakerArray {

    //create the matrices only once and send to multiple servers
	sendToBufferMulti {|servers|
        var x = this.getSetsAndMatrices;
        ^servers.asCollection.collect{  |s|
            Buffer.sendCollection(s, x );
        };
	}

	sendToBuffer {|server|
		^Buffer.sendCollection(server, this.getSetsAndMatrices);
	}

    //create the matrices only once and load to multiple servers
    loadToBufferMulti {|servers|
        var x = this.getSetsAndMatrices;
        ^servers.asCollection.collect{  |s|
            Buffer.loadCollection(s, x );
        };
	}
}