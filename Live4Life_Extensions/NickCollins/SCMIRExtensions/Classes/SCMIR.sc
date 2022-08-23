//central class for music information retrieval operations in SC
//class variables and methods only, singleton class

SCMIR {

	//for auxilliary operations
	classvar <soundfile;
	classvar <tempdir; //location for temp files; if none given, same path as soundfile input
	classvar <samplingrate; //assumed 44100 for now
	classvar <framehop, <hoptime, <framerate; //<framesize,
	classvar <executabledirectory;
	classvar <globalfeaturenorms;
	classvar <>lamelocation;
	classvar <>nrtoutputfilename;
	classvar <>nrtanalysisfilename;

	*initClass {

		soundfile = SoundFile.new;

		samplingrate = 44100;
		//framesize = 1024;
		framehop = 1024;
		framerate = samplingrate/framehop;
		hoptime = framerate.reciprocal;

		//		if (( Main.scVersionMajor == 3) && (Main.scVersionMinor<5)) {
		//			executabledirectory = SCMIR.filenameSymbol.asString.dirname.escapeChar($ )++"/scmirexec/";
		//
		//		}

		//used to be packaged with scmirexec in classes directory, no longer
		executabledirectory = SCMIR.filenameSymbol.asString.dirname.escapeChar($ )++"/../scmirexec/";



		//tempdir = SCMIR.filenameSymbol.asString.dirname++"/scmirtemp/";

		tempdir = "/tmp/";	//user should always have write permission here?

		SCMIR.initGlobalFeatureNorms;

		lamelocation = "/usr/local/bin/lame";

		nrtoutputfilename = "/dev/null";
		nrtanalysisfilename = tempdir++"NRTanalysis";


		//if no unix filenames support
		if(thisProcess.platform.name.class == \windows) {
			nrtoutputfilename = "NRToutput";
		};


	}



	//warning: this method can invalidate all previous SCMIR method calls, and conflict with saved information
	//for individual files, can check using numframes and duration versus current SCMIR.framerate*duration
	*setFrameHop {|hopsize|

		if ((hopsize!= 1024) && (hopsize!=512)) {

			"SCMIR:setFrameHop: only hopsize of 1024 or 512 supported".postln;

			^nil};

		framehop = hopsize;

		framerate = samplingrate/framehop;

		hoptime = framerate.reciprocal;

	}

	//frame hop length in seconds
	//	hopTime {
	//
	//		^hoptime; //framerate.reciprocal;
	//
	//	}


	//COMPENSATION REQUIRED since triggering on chromafft, will be storing values based on initial delay of 4096 samples
	//should associate value with 2048 samples in halfway through window
	*frameTime{|whichframe| ^(framehop*whichframe+2048)/samplingrate}


	*setTempDir {|tmpdirectory|

		//can do further tests here
		tempdir = tmpdirectory; //if nil, will construct as go from paths passed in

		if(tempdir.notNil,{
			if(tempdir.last!=$/,{
				tempdir = tempdir++"/";
			});
		});

	}

	*getTempDir {

		//return empty string as prefix otherwise
		^ tempdir?"";

	}


	*setExecutableDir {|execdir|

		//can do further tests here
		executabledirectory = execdir; //if nil, will construct as go from paths passed in

		if(executabledirectory.notNil,{
			if(executabledirectory.last!=$/,{
				executabledirectory = executabledirectory++"/";
			});
		});

	}



	//try to force garbage collection, close all pipes, wait for a moment
	*clearResources {
		var temp;

		//"clear resources".postln;

		Pipe.closeAll; //safety over long haul?

		//UnixFILE.openFiles.postln;
		UnixFILE.closeAll;

		temp = 0!100;

		temp = nil;

		temp = 0!100; //hopefully force garbage collection round

		if(thisThread.class==Routine) {

			//really pause
			1.0.wait;

		};
	}




	//return true if in Routine, else in Main thread and .wait not valid
	*waitStatus {

		^(thisThread.class==Routine); //Thread
	}


	*waitIfRoutine {|time|

		if(thisThread.class==Routine) {
			time.wait;
		}


	}
	*external {|command, scorerender=false, limit=2000|

		//command.postln;


		if(thisThread.class==Routine) {

			SCMIR.waitOnUnixCmd(command, limit);

			if(scorerender) {
				//safety first, file not being written out quickly enough
				0.1.wait;
			};

			//unworkable since blocks SC even if within separate thread
			//		if(scorerender) {
			//			systemCmd(command);
			//		} {
			//			SCMIR.waitOnUnixCmd(command, limit);
			//
			//		};

		} {

			if(scorerender) {
				systemCmd(command);
			} {
				SCMIR.pipe(command);
			};

		}
	}

	//wait on process, assumed within Routine
	*processWait {|processname, limit=2000|

		var a, count;
		var checkstring = "ps -xc | grep '"++processname++"'";

		count=0;

		0.01.wait; //make sure process running first (can be zero but better safe than sorry)

		while({
			a=checkstring.systemCmd; //256 if not running, 0 if running

			if(count%10==0,{(processname+"running for"+(count.div(10))+"seconds").postln});

			(a==0) and: {(count = count+1) <limit }
			},{
				0.1.wait;
		});

		0.01.wait;

	}

	*pipe {|command|
		var pipe, line;
		//var timinginfo;

		//SCMIR.waitOnUnixCmd(command);

		//can't run while unix process blocks the app, so no updates
		//timinginfo = {var time= 1; 0.wait; inf.do{("waiting"++time+"s").postln; time = time+1; 0.1.wait;} }.fork(SystemClock);
		pipe = Pipe(command, "r");
		line = pipe.getLine;

		//"Pipe here".postln;
		// get the first line
		while({line.notNil}, {line.postln; line = pipe.getLine; });		// post until l = nil
		pipe.close;
		//timinginfo.stop;

	}



	//would only run with {}.fork due to no calls of .wait on main Thread
	//added external to force wait, but doesn't allow time for postln
	*waitOnUnixCmd {|command, limit=2000|
		var ps;
		var count=1;
		var checkstring,checkreturn;
		var processname = command.split($ )[0]; //assumption here if piping, but will do for now

		//[command.class, processname.class, processname=="exec"].postln;

		//missing scsynth invocations because exec command used with scsynth as second argument!
		if (processname == "exec" && (command.contains("scsynth"))) {processname = "scsynth"};

		//"wait here!".postln;
		ps = command.unixCmd;

		//[\pscheck,ps,processname,command].postln;

		//bigger wait safer here, since can take a moment to establish new thread with command running, pid seen by system; don't want a false recording of process finished when it hasn't started!
		//0.05.wait;
		0.1.wait; //even longer for even safer!

		checkstring = "ps -ax | grep '"++ps++" ' ";

		//"now here!".postln;

		//0.01.wait;

		while({

			//{"test this".postln;}.defer;

			checkreturn = checkstring.unixCmdGetStdOut;

			//command
			//[checkreturn,checkreturn.contains(command), checkreturn.split($\n)].postln;

			if(count%10==0,{("SCMIR: calculation running for"+(count.div(10))+"seconds").postln});
			//("SCMIR: calculation running for"+(count)+"tenth of seconds").postln;

			//[checkreturn,processname].postln;

			//(checkreturn.split($\n).size)>3
			(checkreturn.contains(processname)) and: {(count = count+1) <limit }
			},{

				0.1.wait;

				//doesn't post since blocked by first process!
				//replace with call to external that simply forces a wait for specified time
				//(SCMIR.executabledirectory++"waitinmain 100" + count).systemCmd;


		});
		0.01.wait;
	}



	//given one dimensional curve, typically already normalized 0.0 to 1.0, find peak locations
	*peakPick {|curve, reach=15, exaggeration = 5, threshold = 1.0, minseparation=20|

		var peakcurve;
		var maxindex = curve.size-1;
		var list;
		var sep=0;

		peakcurve = Array.fill(curve.size,{|i|

			var below, above;
			var sum = 0.0;
			var now = curve[i];

			below = (i-reach).max(0);
			above= (i+reach).min(maxindex);


			for(below, above,{|j|
				var temp;

				temp = now - curve[j];

				//increase penalty if not local maximum
				if(temp<0.0) {temp = exaggeration*temp; };

				sum = sum + (temp);

			});

			sum

		});

		list = List[];

		peakcurve.do{|val,i|  if(sep>0,{sep= sep-1;}); if ((val>threshold) and: (sep==0)) {list.add(i); sep= minseparation; } };

		^[list, peakcurve]

	}


	*initGlobalFeatureNorms {

		globalfeaturenorms = nil;

	}

	//expert use implied
	*setGlobalFeatureNorms {|norms|

		globalfeaturenorms = norms;

	}



	//could make a dictionary over all observations ever, just a bit trickier?
	//*lookupGlobalFeatureNorm {|featuretype,normalizationtype|
	//
	//	}

	//assumes you know what you're doing, that format of featureinfo used to extract globals is same as that now being used
	//and that values do exist
	*lookupGlobalFeatureNorms {|which|
		^[globalfeaturenorms[0][which],globalfeaturenorms[1][which]];
	}

	*saveGlobalFeatureNorms {|filename|

		var archive;

		filename = filename ?? { (SCMIR.getTempDir)++"globalfeaturenorms.scmirZ" };

		archive = SCMIRZArchive.write(filename);

		archive.writeItem(globalfeaturenorms);

		archive.writeClose;

	}

	*loadGlobalFeatureNorms {|filename|

		var archive;

		filename = filename ?? {(SCMIR.getTempDir)++"globalfeaturenorms.scmirZ"};

		archive = SCMIRZArchive.read(filename);

		globalfeaturenorms = archive.readItem;

		archive.close;
	}

	//run normalization procedures for all standard features over all filenames in list, obtaining global max and min, and mean and stddev
	*findGlobalFeatureNorms {|filenamelist, featureinfo, normalizationtype=0,filestart=0,filedur=0,numquantiles=10,whichchannel|

		var e;
		var norms;
		var framesum = 0, framesumr;
		var temp1, temp2;
		var durations;

		norms= nil!(filenamelist.size);
		durations = 0.0!(filenamelist.size);

		filenamelist.do {|filename,j|

			[j,filename].postln;

			e = SCMIRAudioFile(filename,featureinfo, normalizationtype,filestart,filedur);

			//if nil passed in, will pass on nil and thence go with standard behaviour
			e.extractFeatures(false,whichchannel:whichchannel);

			norms[j] = [e.normalize(e.featuredata, true), e.numframes];

			norms[j].postln;

			durations[j] = e.duration;

			framesum = framesum + e.numframes;

		};

		switch(normalizationtype,0,{

			//normalize
			temp1 = norms[0][0][0];
			temp2 = norms[0][0][1];

			norms.do{|val|

				temp1 = min(val[0][0],temp1);
				temp2 = max(val[0][1],temp2);

			};

			//combine
			globalfeaturenorms = [temp1,temp2];

		},1,{

			//standardize
			framesumr = 1.0/framesum;

			temp1 = 0.0;
			temp2 = 0.0;

			norms.do{|val|

				temp1 = temp1 + (val[0][0]*val[1]*framesumr);
				temp2 = temp2 + (val[0][1]*val[1]*framesumr);

			};

			globalfeaturenorms = [temp1,temp2.sqrt]; //to stddev from variance at this point

		},{

			//quantilisation
				var lastworking = 0;

				globalfeaturenorms = {[]}!(norms[0][0][0].size);

				//accumulate all data over files
				norms.do{|val|

					var rawdata = val[0][0];
					//var numframes = val[1];

					rawdata.do{|datapoints,i|

						if(datapoints.notNil) {

							globalfeaturenorms[i] = globalfeaturenorms[i] ++ datapoints;

							};

					};

				};

				//find quantiles, could be slow for larger array and sorting
				globalfeaturenorms = globalfeaturenorms.collect{|datapoints,i|

					("finding quantile "++ i).postln;

					if(datapoints.notNil,{

						datapoints.percentile((1.0/numquantiles)*(0,1..numquantiles));

					},nil);

				};

				//copies for connected features in groups
				globalfeaturenorms.do{|info,i|

					if(info.isNil) {
						globalfeaturenorms[i] = globalfeaturenorms[lastworking];
					} {
						lastworking = i;
					}

				};

				//required for compatibility with the way norm and standardisation achieved
				globalfeaturenorms = [globalfeaturenorms,[]];

		});


		^durations
	}


	//for adding multiple sound file feature instances to
	*createARFF {|filename,numfeatures,classes|

		var file;

		filename = filename ?? {(SCMIR.getTempDir)++"features.arff"};

		numfeatures  = numfeatures ? 1;

		classes = classes ? ["class1","class2"];

		file = File(filename,"w");

		file.write("@RELATION SCMIR\n");

		numfeatures.do{|i|

			file.write("@ATTRIBUTE"+i+"NUMERIC\n");

		};

		file.write("@ATTRIBUTE class {");

		classes.do{|class,i|

			file.write(class.asString);

			if((i+1)<classes.size) {
				file.write(",");
			}

		};

		file.write("}\n");

		file.write("@DATA\n");

		^file;
	}



	*saveArchive {|filename,datatosave|
		var a;

		a = SCMIRZArchive.write(filename);
		a.writeItem(datatosave);
		a.writeClose;

	}

	*loadArchive {|filename|
		var a, b;

		a = SCMIRZArchive.read(filename);
		b = a.readItem;
		a.close

		^b;
	}



}









