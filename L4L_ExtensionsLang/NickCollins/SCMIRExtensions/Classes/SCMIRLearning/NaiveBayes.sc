//assumes all features conditionally independent, continuous features modeled via Gaussian distribution
//alternative would be to discretise via binning (possibly even histogram equalisation): assisted by having max/min normalisation already in place, and must  have at least 1 artificial count in each bin. Will work best for large training sets,

//P(C) product over i P(Fi/C)
//log P(C) + sum over i log P(Fi/C)

//by default, prior over classes is flat, equiprobable

NaiveBayes {
	var <numfeatures, <numclasses, nummodels;
	var <means,<stddevs; //for each class and feature combination


	*new {|numfeatures, numclasses|

		^super.new.initNaiveBayes(numfeatures, numclasses);
	}

	*newFromFile {|filename|

		^super.new.load(filename);

	}

	initNaiveBayes {|numf,numc|

		numfeatures = numf;
		numclasses = numc;

		nummodels = numfeatures*numclasses;
	}


	//data in form of array of [features array,class]
	//best estimators for classmeans and classstddevs from stats
	//need to cope if NO entries under a particular class and feature correspondence? can't occur if always have all of numclasses present with at least one example
	train {|data|
		var classcounts = 0!numclasses;
		var modeldata = {List[]}!nummodels;

		data.do{ |array|

			var classnow = array[1];
			var baseindex;

			classcounts[classnow] = classcounts[classnow] + 1;
			baseindex = classnow*numfeatures;

			array[0].do{|val,j|

				modeldata[baseindex+j].add(val);

			}
		};

		classcounts.do{|count,j| if(count==0) {("NaiveBayes:train No class examples for class"++j).postln;  ^nil} };


		//could get overflow here, but probably OK, especially if already normalised to 0.0 to 1.0

		means = modeldata.collect{|list,j|  list.mean};

		//using E(X**2) - u**2 formulation for variance
		stddevs = modeldata.collect{|list,j| var mu = means[j]; ((list.collect{|val| val.squared}).mean - mu.squared).sqrt; };

	}


	//given input, find most probable output
	test {|input|

		//use this log version to avoid underflow	in multiplication
		//log P(C) + sum over i log P(Fi/C)

 		var maxindex = 0;
 		var maxscore = -inf;

		numclasses.do {|classnow|
			var score;
			var baseindex = classnow*numfeatures;

			score = 0.0;

			numfeatures.do{|featureindex|
			var indexnow = baseindex +	featureindex;
			var mean = means[indexnow];
			var stddev = stddevs[indexnow];

			//log of Gaussian
			// - log(stddev) - ((val-mean)**2/2*stddev**2)

			score = score - log(stddev) - ((input[featureindex]-mean).squared/(2*(stddev.squared)));

			};

			if(score>maxscore) {

				maxscore = score;

				maxindex = classnow;
			};

		};

		^maxindex;
	}



	save { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"naivebayes"++".scmirZ"};

		a = SCMIRZArchive.write(filename);

		a.writeItem(numfeatures);
		a.writeItem(numclasses);
		a.writeItem(nummodels);
		a.writeItem(means);
		a.writeItem(stddevs);

		a.writeClose;
	}


	load { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"naivebayes"++".scmirZ"};

		a = SCMIRZArchive.read(filename);

		numfeatures = a.readItem;
		numclasses = a.readItem;
		nummodels = a.readItem;
		means = a.readItem;
		stddevs = a.readItem;

		a.close;

	}







		//given input, find probabilities of outputs
	calculate {|input|

		//use this log version to avoid underflow	in multiplication
		//log P(C) + sum over i log P(Fi/C)

		var probs = (0..(numclasses-1)).collect {|classnow|
			var score;
			var baseindex = classnow*numfeatures;

			score = 0.0;

			numfeatures.do{|featureindex|
			var indexnow = baseindex +	featureindex;
			var mean = means[indexnow];
			var stddev = stddevs[indexnow];

			//log of Gaussian
			// - log(stddev) - ((val-mean)**2/2*stddev**2)

			score = score - log(stddev) - ((input[featureindex]-mean).squared/(2*(stddev.squared)));

			};

			score

		};

		//or exp(probs?)
/*		probs = probs - (probs.minItem);
		probs.normalizeSum;

		//always values 0-1, always winner at 1
		^probs = probs/(probs.maxItem);
		*/
		^exp(probs);

	}





}
