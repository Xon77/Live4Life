//create novelty curve from similarity matrix (only for self similarity)
//Foote method is checkerboard kernel; may need to take account of different separations
//from 1 to 3 seconds say

+ SCMIRAudioFile {

	novelty {|matrix, kernelsize=10|

		^matrix.novelty(kernelsize);
	}


	noveltyOld {|matrix, kernelsize=10|

		var file;
		var temp;
		var numcols;  //should be exact
		var noveltycurve;
		var data;
		var outputfilename, inputfilename;

		data = matrix.matrix;

		if (matrix.isNil){
			"SCMIRAudioFile:novelty: no similarity matrix passed in".postln; ^nil
		};

		if (matrix.reducedcolumns != matrix.reducedrows){
			"SCMIRAudioFile:novelty: similiarity matrix not square".postln; ^nil
		};

		numcols = matrix.reducedcolumns; //should be same as reducedrows //matrix.size.sqrt.asInteger;

		inputfilename = SCMIR.getTempDir ++ "noveltyinput";
		outputfilename = SCMIR.getTempDir ++ "noveltyoutput";

		file = SCMIRFile(inputfilename,"wb");

		file.putInt32LE(data.size);
		file.putInt32LE(numcols);

		file.writeLE(data);

		file.close;

		temp = ((SCMIR.executabledirectory)++"noveltycurve") + kernelsize + inputfilename + outputfilename; //"noveltyinput"+ "noveltyoutput";

		//unixCmd(temp);
		//SCMIR.processWait("noveltycurve");

		SCMIR.external(temp);

		file = SCMIRFile(outputfilename,"rb");

		noveltycurve= FloatArray.newClear(numcols);

		//file.readLE(noveltycurve) ;

			numcols.do{|j|
				noveltycurve[j] = file.getFloatLE;
			};


		file.close;

		^noveltycurve;


	}


	//must occur within a Routine
	findSections {|metric=0, unit= 10, kernelsize= 43|

		var matrix, noveltycurve;
		var list, detectioncurve;
		var convertedtimes, conversion;
		//features are every 1024 samples at 44.1kHz
		//(1024/44100)*10 = 0.23219954648526

		conversion = (SCMIR.framerate.reciprocal)*unit; //(1024.0/44100)*unit;

		matrix = this.similarityMatrix(unit, metric);

		//taking account of about 10 second window around a given point
		noveltycurve = this.novelty(matrix,kernelsize);

		//could add values in to remove zeroes here

		#list,detectioncurve= SCMIR.peakPick(noveltycurve.normalize);

		//remove any from list within kernelsize of start or end, to avoid artefact jump from zeroes

		list = list.select{|val|  (val>kernelsize) && (val<(noveltycurve.size-kernelsize))};


		convertedtimes = if(featuresbysegments) {

			//list has beat times, look up in beatdata
			//list.collect{|listtime|
//				var index;
//				index =listtime*unit;
//
//				if(index>=numbeats,{index = numbeats-1});
//
//				[index,listtime, index].postln;
//				 beatdata[index];  }


				//list has beat times, look up in beatdata
			list.collect{|listtime|
				var index;
				index =listtime*unit;

				if(index>=numsegments,{index = numsegments-1});

				//[index,listtime, index].postln;
				 segmenttimes[index];  }


			} {list*conversion};

		^(convertedtimes); //convert to actual times in seconds (accurate only roughly)
	}


}












