//It is possible to call out to sonic annotator (http://www.omras2.org/SonicAnnotator/), a command line tool to run vamp plugins on audio files, and then to load in output data files. 

//Check paths for inputs and outputs, and the location of the sonic annotator executable, in the following before you run code, and adjust to fit your machines paths. 


(
{
	var inputfilename = "/data/audio/mirdata/synthpop/Architecture & Morality/01 The New Stone Age.wav".asUnixPath; 
	var outputdirectory = "/Users/nickcollins/Desktop/vampexamples"; 
	var sonicannotatorlocation = "/Users/nickcollins/Desktop/tosort/qmul/sonic-annotator-0.6-osx-i386/sonic-annotator"; 
	
SCMIR.external(sonicannotatorlocation + "-d vamp:qm-vamp-plugins:qm-barbeattracker:bars "+inputfilename+"-w csv --csv-basedir "+outputdirectory);

}.fork
)

x = CSVFileReader.read("/Users/nickcollins/Desktop/vampexamples/01 The New Stone Age_vamp_qm-vamp-plugins_qm-barbeattracker_bars.csv", true).postcs;

//format is bar start time, and then bar number (can reconstruct since index+1 gives it back anyway) 

//median bar length
x.collect{|val|  val[0].asFloat}.differentiate.median; //1.880816326 seconds



//Melodia melody extraction plugin: http://mtg.upf.edu/technologies/melodia?p=Download%20and%20installation
//Various ways to call: 
//./sonic-annotator -d vamp:mtg-melodia:melodia:melody AUDIOFILE_PATH -w csv
//
//./sonic-annotator -d vamp:mtg-melodia:melodiaviz:OUTPUT_TYPE AUDIOFILE_PATH -w csv
//where OUTPUT_TYPE can be "saliencefunction", "contoursall" or "contoursmelody".


//faster than realtime but not perfectly quick; 45 secs for 3m23 song 

(
{
	var inputfilename = "/data/audio/mirdata/synthpop/Architecture & Morality/01 The New Stone Age.wav".asUnixPath; 
	var outputdirectory = "/Users/nickcollins/Desktop/vampexamples"; 
	var sonicannotatorlocation = "/Users/nickcollins/Desktop/tosort/qmul/sonic-annotator-0.6-osx-i386/sonic-annotator"; 
	
SCMIR.external(sonicannotatorlocation+"-d vamp:mtg-melodia:melodia:melody "+inputfilename+" -w csv --csv-basedir "+outputdirectory);

}.fork
)


//output text file is frame time, frequency estimate list, where some frequencies come out as negative, and 0 is none




//chord detection
//Chordino: http://isophonics.net/nnls-chroma
//SCMIR.external(sonicannotatorlocation+"-d vamp:nnls-chroma:chordino:simplechord "+inputfilename+"-w csv --csv-basedir "+outputfilename);



//chord extract takes about 50 secs for an average pop song on old NNLS Chroma extraction, faster with latest Chordino: 17 seconds (since for about 700 files, 700 mins about 12hours, this can take us to a third of calculation time) 

//demo with one song: 
(
{
	var inputfilename = "/data/audio/mirdata/synthpop/Architecture & Morality/01 The New Stone Age.wav".asUnixPath; 
	var outputdirectory = "/Users/nickcollins/Desktop/vampexamples"; 
	var sonicannotatorlocation = "/Users/nickcollins/Desktop/tosort/qmul/sonic-annotator-0.6-osx-i386/sonic-annotator"; 
	
SCMIR.external(sonicannotatorlocation+"-d vamp:nnls-chroma:chordino:simplechord "+inputfilename+" -w csv --csv-basedir "+outputdirectory);

}.fork
)



//test run using speak & spell tracks only 

( 
{ 
	var sonicannotatorlocation = "/Users/nickcollins/Desktop/tosort/qmul/sonic-annotator-0.6-osx-i386/sonic-annotator";  
	var outputdirectory = "/Users/nickcollins/Desktop/vampexamples";  
	 
		 
	//synth pop directory contains lots of subfolders, each with a classic synth pop album, see (2010) "Computational Analysis of Musical Influence: A Musicological Case Study Using MIR Tools". International Society for Music Information Retrieval conference (ISMIR), Utrecht (available at http://www.sussex.ac.uk/Users/nc81/research.html)  
	 
	p = PathName("/data/audio/mirdata/synthpop"); 
	 
	~albums=p.entries; 
	 
	~tracks = ~albums.collect{|album| album.entries};  
	 
	~tracks.size.postln; 
	 
	//Depeche Mode Speak & Spell, 1981 
	~tracks[24].do{|trackname| 
		var inputfilename = trackname.fullPath.asUnixPath;  
		 
		trackname.fullPath.postln;	 
			 
		"chord detection".postln; 
			 
		SCMIR.external(sonicannotatorlocation+"-d vamp:nnls-chroma:chordino:simplechord "+inputfilename+"-w csv --csv-basedir "+outputdirectory); 
		 
		//	"bar locations".postln;  
		//	 
		//SCMIR.external(sonicannotatorlocation++"-d vamp:qm-vamp-plugins:qm-barbeattracker:bars "+inputfilename+"-w csv --csv-basedir "+outputfilename); 
		 
	};  
	 
}.fork 
)


(

~tracks[24].do{|trackname|
	var inputfilename = trackname.fullPath.asUnixPath; 
	
	
}; 
	
}


//analyze chords, create numerical data on chords from string representations 

( 
var outputdirectory = "/Users/nickcollins/Desktop/vampexamples/";   
//generate all possible chord types in advance in dictionary and just do string lookup 
var chorddictionary;  
var chordtemplates;  
 
 	 
chordtemplates = [ 
[0,4,7], 
[0,3,7], 
[0,4,7,10], 
[0,4,7,11], 
[0,3,7,10], 
[0,3,6,9], 
[0,4,7,9], 
]; 


chorddictionary = Dictionary();  
 
["C","D","E","F","G","A","B"].do{|diatonicnotename,k|  
		  
	for(0,2,{|i| 
		var accidental; 
			 
		accidental =  
		switch(i, 
		0,{"b"}, 
		1,{""}, 
		2,{"#"} 
		); 
			 
		//chordtypes 
		for(0,6,{|j| 
			var postfix; 
			var pitch;  
			var chord;  
				 
			postfix =  
			switch(j, 
			0,{""}, 
			1,{"m"}, 
			2,{"7"}, 
			3,{"maj7"}, 
			4,{"min7"}, 
			5,{"dim"}, 
			6,{"6"} 
			);  
				 
			pitch = (([0,2,4,5,7,9,11][k])+(i-1))%12;  
				 
			chord = ((chordtemplates[j]+pitch)%12).sort; 
				 
			chorddictionary[diatonicnotename++accidental++postfix] = [pitch,j,chord];  
				 
		});  
			 
			 
	});  
		 
}; 

 	 
e = List[];  
 
~tracks[24].do {|pathname|  
		 
	c = CSVFileReader.read(outputdirectory++(pathname.fileNameWithoutExtension)++"_vamp_nnls-chroma_chordino_simplechord.csv");  
	 
	//d = chorddictionary;  
	 
	c.do{|timechord|  
		var time = timechord[0].asFloat;  
		var chord = (timechord[1]);   
		var chordtype=0;	//0 = major, 1 = minor, 2 = 7th 3 = maj7, 4= min7 5= dim 6 = 6    /ignored for over bass note for now 
		var chordpitch=0;   
		 
		chord = chord.copyRange(1,chord.size-2);  
		 
		//[chord, chord.class, chord[1]].postln; 
		 
		chord= chord.split($\/); 
		 
		//if(chord.size>1){"what?".postln;  chord.postln;}; 
		 
		chord = chord[0];  
		 
		//get rid of second over bass bit 
		// 
		//"hello".split($\\) 
		// 
		//"D\\F#".split($\\) 
		 
		if(chord!="N") {  
			 
			//chord.postln	 
			chord.postln; 
			chorddictionary[chord].postln; 
			 
			e.add([time,chorddictionary[chord]]);  
			 
		}  	  
	} 
	 	 
};  

)

e.size //num chords overall collected = 1242

//now using PPMC to model chord changes
//coding for single numbers is pitch class * type 


(
{
e = e.select{|val| val[1].notNil};

g = e.collect{|val| var chord = val[1]; chord.postln;  (chord[0]*7)+(chord[1]) }; 

m = PPMC(3); 	//order =2 (last 2 states predict next)

//sequence for training; can be array of integers, or a String (as Array of characters)
m.train(g);

m.save("/Users/nickcollins/Desktop/vampexamples/PPMC3speakandspellchordmodel1"); 
}.fork; 
)

(
//can reload later
m = PPMC(3); 	

m.load("/Users/nickcollins/Desktop/vampexamples/PPMC3speakandspellchordmodel1"); 
)


//make sure server on
//generate new sequence and convert to form usable for Patterns (actual MIDInotes array)
(

var templates = [
[0,4,7],
[0,3,7],
[0,4,7,10],
[0,4,7,11],
[0,3,7,10],
[0,3,6,9],
[0,4,7,9],
];

//create novel sequence using the trained PPMC model of 200 chords, starting from chords 37 then 0 
b = m.generateN(200); //m.generateN(200,List[37,0]) starting sequence corresponds to F7 then C

h = b.collect{ |val|  var type = val%7; var pitch = val.div(7);     
	
	((((templates[type]) + pitch)%12).sort) ++ [pitch-24]
}; 

Pbind(\midinote, Pstutter(4,60+ Pseq(h)), \dur, 0.25).play

)








