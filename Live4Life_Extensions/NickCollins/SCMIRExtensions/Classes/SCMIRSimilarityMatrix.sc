//compare two sequences (or one to itself)

//does not assume sequences already at desired size for analysis: can reduce at calculate stage via external

//first input sequence is always longer, since greater width in screen space for plotting, and greater time along x axis


SCMIRSimilarityMatrix {
	var <rows, <columns; //rows is size of source2, columns size of source 1
	var <dimensions; //number of features in source vectors
	//var <file1, <file2; //source audio files may not exist, if using this as a general similarity matrix tool
	var <sequence1, <sequence2; //actual vector sequences compared
	var <self; //flag for self similarity, saves on some calculation
	var <matrix;
	var <reductionfactor; //for storing reduction factor in calculation
	var <reducedrows, <reducedcolumns;

	//basic mode is to extract from files
	//symmetric flag cuts off file2 to be same legnth as file1 (wlog), leading to a square matrix
	//*new {|file1, file2, symmetric=true|
	//
	//		//must have at least features in first file?
	//
	//		//if (file2.isNil,{ ^nil});
	//
	//		^super.new.initSCMIRSimilarityMatrix(sequence1, sequence2);
	//
	//	}


	*newFromMatrix {|data, r, c|

		//check perfect square
		//if(data.size == (data.size.sqrt.asInteger**2)) {
		//
		//			}

		^super.new.initSCMIRSimilarityMatrix2(data,r,c);

	}



	initSCMIRSimilarityMatrix2 {|data r c|

		if(data.class != FloatArray) {

			data = FloatArray.newFrom(data);

		};

		matrix = data;

		dimensions = 1;

		if(rows.isNil) {
			r = data.size.sqrt.asInteger;
			c = r;
		};

		reducedcolumns = columns = c;
		reducedrows = rows = r;

	}


	*new {|dimensions, sequence1, sequence2|

		if (sequence1.isNil) {
			"SCMIRSimilarityMatrix:new: no first sequence passed in".postln; ^nil;
		};

		^super.new.initSCMIRSimilarityMatrix(dimensions, sequence1, sequence2);

	}


	initSCMIRSimilarityMatrix {|dim, seq1, seq2|
		var temp;

		dimensions = dim;

		sequence1 = seq1;

		//must be RawArray for file write out
		if(not(sequence1.isKindOf(FloatArray)) ) {
			sequence1 = FloatArray.newFrom(sequence1);
		};

		self = 0;

		//comparison or self similarity
		sequence2 = seq2 ?? {self = 1;  sequence1};

		//must be RawArray for file write out
		if(not(sequence2.isKindOf(FloatArray)) ) {
			sequence2 = FloatArray.newFrom(sequence2);
		};



		//but if do this will get confused in interpreting results?
		//swap if needed so always have columns >= rows
		if (sequence1.size<sequence2.size) {

			temp= sequence1;

			sequence1 = sequence2;

			sequence2 = temp;

			"Swapped sequence1 and sequence2, since sequence2 was longer than sequence1".postln;

		};

		//must allow for dimensions amongst the input data array
		columns = (sequence1.size).div(dimensions);
		rows = (sequence2.size).div(dimensions);

	}


	calculate {|unit=1, metric=2, prepost=0, reductiontype=1|

		var file;
		var temp;
		var bytescheck;
		var outputfilename, inputfilename;

		//var tempdir;
		//tempdir = if(SCMIR.tempdir.notNil){SCMIR.tempdir}{""};

		//unit is framesperblock, must be integer
		unit = unit.asInteger;

		if (unit<1) {"SCMIRSimilarityMatrix:calculate: unit less than 1".postln; ^nil};

		//since rows <= columns
		if (unit>rows) {unit=rows; };

		reductionfactor = unit;

		//write out binary file with input data
		//tempdir+

		inputfilename = SCMIR.getTempDir ++ "similaritymatrix2input";
		outputfilename = SCMIR.getTempDir ++ "similaritymatrix2output";

		//"similaritymatrix2input"
		file = SCMIRFile(inputfilename,"wb");

		file.putInt32LE(columns);
		file.putInt32LE(rows);
		file.putInt32LE(dimensions);

		file.writeLE(sequence1);

		if (self==0) {
			//"now crash? 2".postln;
			file.writeLE(sequence2);
		};

		file.close;

		//call auxilliary program
		temp = SCMIR.executabledirectory++"similaritymatrix" + metric + unit + prepost + reductiontype + self + outputfilename + inputfilename;

		//"similaritymatrix2output"+ "similaritymatrix2input";
		//temp = SCMIR.executabledirectory++"similaritymatrix2" + metric + unit + prepost + reductiontype + self + (tempdir++"similaritymatrix2output")+ (tempdir++"similaritymatrix2input");

		temp.postln;

		//unixCmd(temp);
		//SCMIR.processWait("similaritymatrix2");

		SCMIR.external(temp);

		//read result back in //tempdir++
		//"similaritymatrix2output"
		file = SCMIRFile(outputfilename,"rb");

		reducedcolumns = columns.div(unit); //file.getInt32LE;
		reducedrows = rows.div(unit); //file.getInt32LE;

		temp = reducedrows*reducedcolumns;
		matrix= FloatArray.newClear(temp);

		//"matrix size check 1".postln;
		//		matrix.size.postln;

		file.readLE(matrix);


		if((matrix.size) != temp) {

			//[\bytereadissue, matrix.size, temp].postln;
			file.close;

			matrix=nil;

			SCMIR.clearResources;

			file = SCMIRFile(outputfilename,"rb");

			matrix= FloatArray.newClear(temp);

			file.readLE(matrix);

			//[\bytereadissue2, matrix.size, temp].postln;
		};




		//bytescheck =
		//bytescheck.postln;

		//if((4*bytescheck) != temp) {
		//
		//			[\bytereadissue, bytescheck, 4*bytescheck, temp].postln;
		//
		//		};
		//
		//need debug code; if matrix read in has different size, must re-read. Not sure why this happens, must be issue with operating system file read or _FileReadRawLE

		//"matrix size check 2".postln;
		//		matrix.size.postln;
		//		temp.size.postln;
		//		[reducedrows,reducedcolumns].postln;


		file.close;



	}


	//may need some way to check original audio file lengths for time positions accurately in seconds
	//will crash if matrix is not a symmetric matrix as an array of arrays
	//no axes drawn, just direct plot with fixed border of 20
	plot {|stretch=1, power=5, path, drawlabels=false, tickstep=10, tickoffset=0|

		var window, uview, background=Color.white;
		var xsize = reducedcolumns*stretch;
		var ysize = reducedrows*stretch;
		var border = 20;
		var xaxisy, origin;
		var totalx = xsize + (2*border);
		var totaly = ysize + (2*border);
		var font;

		//just need path, not [score, path]
		if(path.notNil){ if(path.size==2){path = path[1];}};

		window = Window("Similarity matrix", Rect(100,100,totalx,totaly));

		window.view.background_(background);

		uview = UserView(window, window.view.bounds).focusColor_(Color.clear);

		xaxisy = totaly- border;
		origin = border@xaxisy;

		uview.drawFunc_({

			Pen.use {
				Pen.width_(1);
				//.alpha_(0.4)
				//Color.white.setFill;
				Color.black.setStroke;

				//Pen.fillRect(Rect(0,0,xsize,ysize));

				Pen.moveTo(origin);
				Pen.lineTo((border+xsize)@(xaxisy));

				Pen.moveTo(origin);
				Pen.lineTo(border@border);

				Pen.stroke;

				reducedcolumns.do{|i|

					var pos;
					var x = (i*stretch)+border;

					pos = reducedrows*i;

					reducedrows.do{|j|

						var y = border + ((reducedrows-j-1)*stretch);
						Pen.color = Color.grey(0.2+(0.8*((1.0-(matrix[pos+j]))**power)));
						Pen.addRect(Rect(x,y,stretch,stretch));
						Pen.fill;

					}

				};

				if(path.notNil){

					Pen.color = Color.blue(0.9,0.5); //partially transparent

					path.do{|coord|

						var x = (coord[0]*stretch)+border;
						var y = border + ((reducedrows-coord[1]-1)*stretch);
						Pen.addRect(Rect(x,y,stretch,stretch));
						Pen.fill;

					}


				};

			};

			//draw text labels

			if(drawlabels) {

				//based on room in border
				font = Font("Arial", (border.div(2)).min(14).max(6));

				Color.black.setStroke;
				//x ticks

				[tickstep, reducedcolumns,(0,tickstep..reducedcolumns)].postln;

				(0,tickstep..reducedcolumns).do{|i|

					var x = (i*stretch)+border;

					Pen.moveTo(x@xaxisy);

					Pen.lineTo(x@totaly);

					(i+tickoffset).asString.drawAtPoint((x+2)@xaxisy,font, Color.blue);

				};

				Pen.stroke;

				(0,tickstep..reducedrows).do{|j|
					var y;
					var tmpx, tmpy;

					y = xaxisy- (j*stretch);

					Pen.moveTo(border@y);

					Pen.lineTo(0@y);

					tmpx = (border*0.5).asInteger;
					tmpy = y; //+(0.1*halfbordery);

					Pen.rotate(-pi*0.5,tmpx,tmpy);
					(j+tickoffset).asString.drawAtPoint((tmpx+2)@(y-3),font, Color.blue);
					Pen.rotate(pi*0.5,tmpx,tmpy);

				};

				Pen.stroke;



			}




		});

		window.front;

	}


}
