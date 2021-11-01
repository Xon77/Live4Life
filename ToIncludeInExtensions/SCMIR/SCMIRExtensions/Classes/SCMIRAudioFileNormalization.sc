+ SCMIRAudioFile {

	//requires MathLib extension quark
	featureQuantiles {|array which=0 num=1 numquantiles=10|

		var target;

		target = Array.fill(num,{|i| array[which+i,numfeatures+which+i..]}).flatten;

		//(numquantiles-1)
		^target.percentile((1.0/numquantiles)*(0,1..numquantiles));

	}



	featureRange {|array,which=0,num=1|

		var val, minval, maxval;
		var temp;
		var top= num-1;

		temp = which;

		minval = array[temp];
		maxval = array[temp];

		for(0,numframes-1,{|i|

			for(temp,temp+top,{|j|

				val = array[j];

				if (val>maxval,{maxval= val;});
				if (val<minval,{minval= val;});


			});

			temp = temp + numfeatures;
		});


		^[minval, maxval];

	}


	featureMean {|array,which=0,num=1|
		var mean;
		var temp, val;
		var top= num-1;

		mean = 0.0;


		temp = which;
		for(0,numframes-1,{|i|

			for(temp,temp+top,{|j|

				val = array[j];

				mean = mean + val;
			});

			temp = temp+ numfeatures;
		});

		^mean/numframes;
	}

	featureVariance {|array,which=0,num=1,mean=0.0|
		var variance;
		var temp, val;
		var top= num-1;

		variance = 0.0;

		temp = which;
		for(0,numframes-1,{|i|

			for(temp,temp+top,{|j|

				val = array[j];

				variance = variance + ((val-mean).squared);

			});

			temp = temp+ numfeatures;
		});

		^variance/numframes;
	}



	standardizeFeature { |array, which=0, num=1, useglobal=false|

		var mean, standarddeviation, stddevr;
		var top= num-1;
		var temp, val;

		if(useglobal){

			#mean,standarddeviation = SCMIR.lookupGlobalFeatureNorms(which);

		} {
			mean = this.featureMean(array,which,num);
			standarddeviation = this.featureVariance(array,which,num,mean).sqrt;
		};

		stddevr = (standarddeviation.reciprocal)/6.0;

		temp = which;

		for(0,numframes-1,{|i|

			for(temp,temp+top,{|j|

				val = array[j];

				//plain standardisation
				//array[j] = (val-mean)*stddevr;

				//by default centre on 0.5 and allow for +-3 stddev
				//NOTE /6.0 above too!!!!!!!!!!!
				array[j] = 0.5+((val-mean)*stddevr);


			});

			temp = temp+ numfeatures;
		});

		^array;
	}


	normalizeFeature { |array, which=0, num=1, useglobal=false|

		var maxval, minval, maxminusminr;
		var top= num-1;
		var temp, val;


		if(useglobal){

			#minval, maxval = SCMIR.lookupGlobalFeatureNorms(which);
		} {

			#minval, maxval = this.featureRange(array,which,num);
		};


		if(maxval!=minval) {

			maxminusminr = 1.0/(maxval-minval);

			temp = which;

			for(0,numframes-1,{|i|

				for(temp,temp+top,{|j|

					val = array[j];

					array[j] = (val-minval)*maxminusminr;

				});

				temp = temp+ numfeatures;
			});

		} {

			//everything is already just one value, leave array alone

		};

		^array;
	}


	quantileFeature { |array, which=0, num=1, numquantiles=10, useglobal=false|

		var percentiles, numqr;
		//maxminusminr, minval, maxval;
		var top = num-1;
		var temp, val;

		if(useglobal){

			percentiles = SCMIR.lookupGlobalFeatureNorms(which)[0];
			numquantiles = percentiles.size-1;

		} {

			percentiles = this.featureQuantiles(array,which,num,numquantiles);
		};

		//minval = percentiles[0];
		//maxval = percentiles[percentiles.size-1];

		///if(maxval!=minval) {

		//maxminusminr = 1.0/(maxval-minval);

		numqr = numquantiles.reciprocal;

		temp = which;

		//[which,num, percentiles].postcs;

		for(0,numframes-1,{|i|

			for(temp,temp+top,{|j|

				val = array[j];

				//can floor if aiming for discrete classes as output; actually easy to convert later via histo/floor
				array[j] =  percentiles.indexInBetween(val)/numquantiles; //(val-minval)*maxminusminr;

			});

			temp = temp+ numfeatures;
		});

		//}

		//{

		//everything is already just one value, leave array alone

		//};

		^array;
	}




	//also called as part of extract features
	//quantilecalculationproportion=1.0 could throwaway some of the calculating data, should always keep max and min Item?
	normalize { |array, getstats=false, useglobal=false|

		var offset;
		var temp1, temp2, stats;

		offset=0;

		//numframes = 	SCMIR.soundfile.numFrames-1;

		if(getstats) {

			//if( (normalizationtype == 0) or: (normalizationtype == 1)) {

			//not needed for normtype 2 but preserved for sake of other code
				stats = [nil!numfeatures,nil!numfeatures];
			//}
			//{
				//stats = nil!numfeatures; //providing whole set of numbers for quantile normalisation
			//};

		};

		featureinfo.do{|featurenow|

			var numberlinked = 1;
			var numfeaturesnow = 1;

			//featurenow.postln;

			//normtype now preset; just Chromagram as multi feature norm

			switch(featurenow[0].asSymbol,
				\MFCC,{
					numfeaturesnow = featurenow[1];

					//this means do overall normalization
					if(featurenow.size>=3,{

						numfeaturesnow = 1;
						numberlinked = featurenow[1];
					});
				},
				\Chromagram,{

					numberlinked = featurenow[1];
				},
				\SpectralEntropy,{

					//numberlinked = featurenow[1];
					//don't inter-link by default
					numfeaturesnow = featurenow[1];
				},
				\Tartini,{
					numfeaturesnow = if(featurenow.size==1,1,2);
				},
				\OnsetStatistics,{
					numfeaturesnow = 3;
				},
				\BeatStatistics,{
					numfeaturesnow = 4;
				},
				\CustomFeature,{
					//1 output only if nil, else supplied
					numfeaturesnow = (featurenow[2]?1);

					//this means do overall normalization
					if(featurenow.size>=4,{

						numberlinked = numfeaturesnow;
						numfeaturesnow = 1;

					});

				},
				\PolyPitch,{

					numfeaturesnow = (2*featurenow[1])+1;
				},
				\PianoPitch,{

					numfeaturesnow = 88;
				}
			);


			if(getstats) {

				numfeaturesnow.do{|i|

					switch(normalizationtype,0,{

						//normalize

						#temp1, temp2 = this.featureRange(array,offset,numberlinked);

						stats[0][offset..(offset+numberlinked-1)] = temp1;
						stats[1][offset..(offset+numberlinked-1)] = temp2;

								//[temp1, temp2];
						},1,{

							//standardize

							temp1 = this.featureMean(array,offset,numberlinked);
							temp2 = this.featureVariance(array,offset,numberlinked,temp1).sqrt;

							//stats[offset..(offset+numberlinked-1)] = [temp1, temp2];
							stats[0][offset..(offset+numberlinked-1)] = temp1;
							stats[1][offset..(offset+numberlinked-1)] = temp2;

						},{
							//default as last function in switch


							//[featurenow,numberlinked, numfeaturesnow, stats.size].postln;

							//quantile; take negative of normalizationtype for number of quantiles, default 10

							//var numquantiles = 10; //10% quantiles
							//var target;
							//if(normalizationtype.isInteger && normalizationtype<0) {numquantiles = normalizationtype.neg; };


							temp1 = Array.fill(numberlinked,{|j| array[offset+j,numfeatures+offset+j..]}).flatten;

							//temp1 = this.featureQuantiles(array,offset,numberlinked,numquantiles);
							//..(offset+numberlinked-1)
							stats[0][offset] = temp1; //[temp1,numquantiles]; //nils in other entries for linked since no use, will need to write back later once have results

							//if(numberlinked>1) {
							//stats[offset+1..(offset+numberlinked-1)] = nil;
							//};

							//target = Array.fill(numberlinked,{|i| array[offset+i,numfeatures+offset+i..]}).flatten;

							//requires MathLib extension quark

							//(numquantiles-1)
							//stats[offset..(offset+numberlinked-1)] = target.percentile((1.0/numquantiles)*(0,1..numquantiles));
							//after normalisation top always 1.0?

					});

					offset = offset + numberlinked;
				};


			} {

				numfeaturesnow.do{|i|

					switch(normalizationtype,0,{

						//normalize

						array = this.normalizeFeature(array,offset,numberlinked,useglobal);

						},1,{

							//standardize

							array = this.standardizeFeature(array,offset,numberlinked,useglobal);

						},{

							//quantile
							var numquantiles = 10; //10% quantiles

							if(normalizationtype.isInteger && normalizationtype<0) {numquantiles = normalizationtype.neg; };

							array = this.quantileFeature(array,offset,numberlinked,numquantiles,useglobal);

					});

					offset = offset + numberlinked;
				}

			}

		}

		^if(getstats){stats}{array};
	}




	//ASSUMES OLD STRUCTURES, DITCH
	//done as part of extract features
	//normalisation: feature wise, feature group wise, max-min norm or standardisation
	//0 = max-min, 1 = standardisation
	//2 = max-min feature-wise, 3= standardisation feature-wise
	//only 0 or 2 supported for now
	normalizeOld { |array|

		var normtype, normfeatures, normnow;
		var maxval, minval; //LATER:, meanval, stddev;
		var offset, offsettop, temp, val, maxminusminr;

		offset=0;

		//numframes = 	SCMIR.soundfile.numFrames-1;

		featureinfo.do{|featurenow|

			var numbersweeps = 1;

			normtype = featurenow[1];

			normfeatures = 1;

			if((featurenow[0]==MFCC) || (featurenow[0]==Chromagram) || (featurenow[0]==SpectralEntropy)) {

				normfeatures = featurenow[2];

				if (normtype>=2) {

					numbersweeps = normfeatures;
					normfeatures = 1;

					normtype = normtype-2;
				}

			};

			//always separate normalization
			if(featurenow[0]==Tartini) {

				numbersweeps = 2;
				normfeatures = 1;

			};

			numbersweeps.do{

				offsettop = offset+normfeatures-1;

				//find maxItem, minItem, mean, stddev
				//array = FloatArray.newClear(SCMIR.soundfile.numFrames*normfeatures);

				maxval = array[offset];
				minval = array[offset];
				//mean = 0.0;

				//find stats
				for(0,numframes-1,{|i|

					temp = i*numfeatures; //SCMIR.soundfile.numChannels;

					for(offset,offsettop,{|j|

						val = array[temp+j];

						if (val>maxval,{maxval= val;});
						if (val<minval,{minval= val;});


					});

				});


				maxminusminr = 1.0/(maxval-minval);

				//[offset, maxval, minval, maxminusminr].postln;

				//apply stats
				for(0,numframes-1,{|i|

					temp = i*numfeatures;

					for(offset,offsettop,{|j|

						array[temp+j] = (array[temp+j] - minval)*maxminusminr;

					});

				});

				offset = offset +  normfeatures;

			}
		}

		^array;
	}






}
