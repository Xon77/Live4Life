//adapts code from Dan Stowell's MP3 Quark, readToBuffer function, simplified and recast using SCMIR constructions. Similar assumption on lame location, hard coded here 

+ SCMIRAudioFile {
	
	//nonunique added to save disk space when working over a big corpus, only creates one wav at a time
	resolveMP3 {|inputfilename, usehash=false, nonunique=true|

	//"/tmp/
	var outputfilename;
	var inputprefix; 
	
	inputprefix = PathName(inputfilename).fileNameWithoutExtension;
	
	outputfilename = SCMIR.tempdir ++ inputprefix ++ ".wav"; 
	
	if(usehash) {
		outputfilename = SCMIR.tempdir ++ "sc3mp3read-" ++ (this.hash) ++ ".wav";
	};
	
	if(nonunique) {
	outputfilename = SCMIR.tempdir ++ "conversionfrommp3" ++ ".wav";
	};
	
	//outputfilename = SCMIR.tempdir ++ "sc3mp3read-" ++ (if(unique,{this.hash},{"temp"})) ++ ".wav";
	
	"Creating temporary .wav from MP3".postln; 
	
	//"/usr/local/bin/lame"
	SCMIR.external((SCMIR.lamelocation) + "--decode" + "\"" ++ inputfilename ++ "\"" + "\""++ outputfilename ++"\"");
	
	//	if(().systemCmd == 0, {
//			^Buffer.read(server,tmpPath,startFrame,numFrames, {("rm" + tmpPath).unixCmd} <> action, bufnum);
//		}, {
//			("MP3: unable to read file:" + path).warn;
//			("rm" + tmpPath).unixCmd;
//		});


	"Created temporary .wav from MP3".postln; 

	^outputfilename; 	
	}
	
	
}