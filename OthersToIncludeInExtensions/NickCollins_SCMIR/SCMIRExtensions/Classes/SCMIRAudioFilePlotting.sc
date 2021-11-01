+ SCMIRAudioFile {


	plotFeatures {|xsize=800, ysize= 600, border =20, plotlines=false, resamplemethod=0|

		var resampledfeatures;
		var x, y, borderx, bordery, halfborderx, halfbordery;
		var framesperx, yperfeature;
		var temp;
		var window, uview, background=Color.white;
		var origin;
		var xticks, yticks, xpixelintime, xfont, yfont;
		var xtickspacing, ytickspacing;
		var xaxisy, yaxisx;

		//load feature data file
		//
		if(featuredata.isNil,{
			"SCMIRAudioFile:plotfeatures: no feature data available; did you extract features first?".postln;
			^false;
		});

		//x = FileReader.read("/Volumes/unix/mirdata/scmirtests/Full RinseFT.txt", true).postcs;

		x = xsize - border;

		framesperx = (numframes/x).roundUp;

		temp = (numframes/framesperx).roundUp;

		borderx= border;

		borderx = borderx + (x-temp);
		x = temp;

		xpixelintime = (framesperx)*SCMIR.hoptime; //(1024.asFloat/(SCMIR.samplingrate));
		xtickspacing = 50;
		xticks= x.div(xtickspacing)+1; //one each 50 pixels, starting from 0

	 	//[x, xticks, xtickspacing, xpixelintime].postln;

		y = ysize - border;

		if(numfeatures>y,{
			"plotfeatures: must be at least one pixel per feature on the y axis".postln;
			^false;
		});

		yperfeature = y.div(numfeatures);

		temp = numfeatures*yperfeature;

		bordery= border;

		bordery = bordery + (y-temp);
		y = temp;

		ytickspacing = 5*yperfeature;
		yticks= y.div(ytickspacing)+1;



		//[\framesperx, framesperx, \yperfeature, yperfeature].postln;

		//resample data; must combine framesperx

		if(framesperx!=1) {

			resampledfeatures =  FloatArray.newClear(x*numfeatures);


			//just taking max for now

			x.do {|i|

				var arraypos = i*numfeatures;
				var originalpos = i*(numfeatures*framesperx);

				//must watch for getting very near end; will need final values

				numfeatures.do {|j|

					var combinedval;
					var originalposnow;
					var numtocombine = framesperx;

					//case to handle leftover
					if(i==(x-1),{ numtocombine = numframes- ((x-1)*framesperx); });

					combinedval = 0.0;
					originalposnow = originalpos + j;

					numtocombine.do{|k|

						var valnow=  featuredata[originalposnow+(k*numfeatures)];

						//not for now, can also make more efficient I'm sure
						//switch(resamplemethod)

						if(valnow>combinedval) {combinedval = valnow;};

					};

					resampledfeatures[arraypos+j] = combinedval;

				};
			};



			} {

			resampledfeatures	= featuredata;

		};

		 //resampledfeatures.postcs;

		//draw in new window with UserView and Pen


		window = Window("Feature plot for "++basename, Rect(100,100,xsize,ysize));

		window.view.background_(background);

		uview = UserView(window, window.view.bounds).focusColor_(Color.clear);

 		halfborderx= borderx.div(2);
 		halfbordery= bordery.div(2);

 		//based on room in border
		xfont= Font("Arial", (halfbordery.div(2)).min(14).max(6));
		yfont= Font("Arial", (halfborderx.div(2)).min(14).max(6));


 		xaxisy = ysize-halfbordery;
				//yaxisx= halfborderx;

 		origin = halfborderx@xaxisy;

		uview.drawFunc_({

			Pen.use {
				Pen.width_(1);
				//.alpha_(0.4)
				//Color.white.setFill;
				Color.black.setStroke;

				//Pen.fillRect(Rect(0,0,xsize,ysize));


				Pen.moveTo(origin);
				Pen.lineTo((halfborderx+x)@(ysize-halfbordery));

				Pen.moveTo(origin);
				Pen.lineTo(halfborderx@halfbordery);

				Pen.stroke;

				if(plotlines) {

				  //one line at a time,

					numfeatures.do {|j|

						 var startval = resampledfeatures[j];
						var xpixelpos = halfborderx;
					 var valnow = resampledfeatures[j];
					 var invval = 1.0-valnow;
					 var linetemp =  (invval*yperfeature).round(1.0).asInteger;
					 var ypixelpos = halfbordery + ((numfeatures-1-j)*yperfeature) + linetemp;

					Pen.moveTo(xpixelpos@ypixelpos);

					x.do {|i|
					var arraypos = i*numfeatures;
					xpixelpos = i+halfborderx;
					 valnow = resampledfeatures[arraypos+j];
					 invval = 1.0-valnow;
					 linetemp =  (invval*yperfeature).round(1.0).asInteger;
					 ypixelpos = halfbordery + ((numfeatures-1-j)*yperfeature) + linetemp;

					//or just in black? some variation helps to read
					//Pen.color = Color.red(0.5+(0.5*valnow.sqrt));
					//Pen.addRect(Rect(xpixelpos,ypixelpos,1,1));
					//Pen.fill;

					Pen.lineTo(xpixelpos@ypixelpos);


					};

					Pen.stroke;

				}

				}

				{

				x.do {|i|

				var arraypos = i*numfeatures;
				var xpixelpos = i+halfborderx;

				//must watch for getting very near end; will need final values



				numfeatures.do {|j|

					 var ypixelpos = halfbordery + ((numfeatures-1-j)*yperfeature);
					 var valnow = resampledfeatures[arraypos+j];

					Pen.color = Color.green(0.3+(0.7*valnow.sqrt));
					Pen.addRect(Rect(xpixelpos,ypixelpos,1,yperfeature));
					Pen.fill;

//					Color.green(valnow).setStroke;
//					Pen.moveTo(xpixelpos@ypixelpos);
//					Pen.lineTo(xpixelpos@(ypixelpos+yperfeature));
//					Pen.stroke;

				}


				};



				};


				Color.black.setStroke;
				//ticks

				xticks.do{|i|
					var pixelnow;
					var timenow;
					var ylow;

					pixelnow = (i*xtickspacing) + halfborderx;
					timenow = i*xtickspacing*xpixelintime;
					ylow = xaxisy; //+halfbordery;

					Pen.moveTo(pixelnow@xaxisy);

					Pen.lineTo(pixelnow@ysize);

					timenow.round(0.01).asString.drawAtPoint((pixelnow+2)@ylow,xfont, Color.blue);
				};

				Pen.stroke;

				yticks.do{|j|
					var pixelnow;
					var numnow;
					var ylow;
					var tmpx, tmpy;

					pixelnow = xaxisy- (j*ytickspacing);
					numnow = j*5;
					ylow = xaxisy; //+halfbordery;


					Pen.moveTo(halfborderx@pixelnow);

					Pen.lineTo(0@pixelnow);


					tmpx= (halfborderx*0.5).asInteger;
					tmpy= pixelnow; //+(0.1*halfbordery);

					Pen.rotate(-pi*0.5,tmpx,tmpy);
					numnow.asString.drawAtPoint((tmpx+2)@(pixelnow-3),yfont, Color.blue);
					Pen.rotate(pi*0.5,tmpx,tmpy);

				};

				Pen.stroke;



			};
		});

		window.front;



		//add axis labels only if room

		//		xlabel.drawAtPoint((xsize*0.5)@(ysize-(border*0.5)),font, Color.red);
		//
		//		//border+(ypixels*0.8)
		//		Pen.rotate(-pi*0.5,border*0.3,ysize*0.6);
		//		ylabel.drawAtPoint((border*0.3)@(ysize*0.6),font, Color.red);
		//

		//optional extension: capture window via SCImage and write out PDF?

	}

	//single feature plot
	getFeatureTrail {|which=0, starttime=0.0, endtime|

		var array, index;
		var startframe, endframe;
		var timeperframe = SCMIR.hoptime; //0.023219954648526;

		endtime = endtime ? duration;

		if(starttime<0.0) {starttime = 0.0};
		if(starttime>duration) {starttime = 0.0};

		if(endtime>duration) {endtime = duration};

		if(endtime<starttime) { endtime = duration;};

		startframe = min((starttime/timeperframe).asInteger,numframes-1);

		endframe = min((endtime/timeperframe).asInteger,numframes-1);

		index = startframe*numfeatures + which;

		array= Array.fill(endframe- startframe+1,{|i|
			var value ;

			 value = featuredata[index];

			 index = index + numfeatures;

			  value;
			  });
		^array;
	}

	plotFeatureTrail {|which=0, starttime=0.0, endtime|

		this.getFeatureTrail(which,starttime,endtime).perform(if(Main.versionAtLeast(3,5),\plot,\plot2));
	}



	//fork included since won't be using for batch processing
	plotSelfSimilarity{|unit=10, stretch=1, metric=0|

		var matrix;
		//{

		matrix = this.similarityMatrix(unit,metric);

		matrix.plot(stretch);

		//}.fork(AppClock);

	}



	//deprecated
	//will crash if matrix is not a symmetric matrix as an array of arrays
	//no axes drawn, just direct plot with fixed border of 20
	//plotSimilarity {|matrix, stretch=1, power=4|
//
//		var window, uview, background=Color.white;
//		var matrixsize= matrix.size.sqrt.asInteger; //should be exact
//	  	var xsize = matrixsize*stretch;
//		var border= 20;
//		var xaxisy, origin;
//		var totalsize = xsize + (2*border);
//
//		window = SCWindow("Similarity matrix for "++basename, Rect(100,100,totalsize,totalsize));
//
//		window.view.background_(background);
//
//		uview = SCUserView(window, window.view.bounds).focusColor_(Color.clear);
//
// 		xaxisy = totalsize- border;
// 		origin = border@xaxisy;
//
//		uview.drawFunc_({
//
//			Pen.use {
//				Pen.width_(1);
//				//.alpha_(0.4)
//				//Color.white.setFill;
//				Color.black.setStroke;
//
//				//Pen.fillRect(Rect(0,0,xsize,ysize));
//
//				Pen.moveTo(origin);
//				Pen.lineTo((border+xsize)@(xaxisy));
//
//				Pen.moveTo(origin);
//				Pen.lineTo(border@border);
//
//				Pen.stroke;
//
//				//matrixsize.do{|i|
////					var x = (i*stretch)+border;
////					var column = matrix[i];
////
////					column.do{|valnow, j|
////					var y = border + ((matrixsize-j-1)*stretch);
////					Pen.color = Color.grey(0.2+(0.8*((1.0-valnow)**6)));
////					Pen.addRect(Rect(x,y,stretch,stretch));
////					Pen.fill;
////
////					}
////
////				}
//
//				matrixsize.do{|i|
//
//					var pos;
//					var x = (i*stretch)+border;
//
//					pos = matrixsize*i;
//
//					matrixsize.do{|j|
//
//					var y = border + ((matrixsize-j-1)*stretch);
//					Pen.color = Color.grey(0.2+(0.8*((1.0-(matrix[pos+j]))**power)));
//					Pen.addRect(Rect(x,y,stretch,stretch));
//					Pen.fill;
//
//					}
//
//				}
//
//
//			};
//		});
//
//		window.front;
//
//	}



}

