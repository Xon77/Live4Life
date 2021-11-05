//structural change analysis following
//Matthias Mauch and Mark Levy (2011) Structural Change on Multiple Time Scales as a Correlate of Musical Complexity. ISMIR 2011.


SCMIRStructuralSummary {

	//http://en.wikipedia.org/wiki/Kullback–Leibler_divergence#Definition
	//symmetrised K-L is Jenson-Shannon divergence http://en.wikipedia.org/wiki/Jensen–Shannon_divergence
	//checked code from https://github.com/lastfm/StructuralChange
	//log2 along with probability distribution normalisation guarantees result between 0.0 and 1.0
	//assumes size a and b the same size
	*jensonShannon {|a,b|

		var asum = a.sum;
		var bsum = b.sum;
		var avalid = false;
		var bvalid = false;
		var answer = 0.0; 	//will return 0.0 if gets into trouble
		var m;

		//if(a.size!=b.size) ^nil;

		//if(asum<=0.0) ^nil;
		//if(bsum<=0.0) ^nil;

		if((asum>0.0) && (bsum>0.0)) {

			//can normalize and actually calculate

			a = a/asum;
			b= b/bsum;

			m = (a+b)*0.5;

			m.do{|val,i|

				var ai = a[i];
				var bi= b[i];

				//if a[i] >0 then m[i] also >0.0 so division safe
				//assumption is that 0 (log 0) is 0, so can bypass that eventuality (ie no contribution to sum, so no need to do anything!)
				if(ai>0.0) {answer = answer + (ai * log2(ai / val)) };
				if(bi>0.0) {answer = answer + (bi * log2(bi / val)) };

			}

		};

		^answer;

	}


	//data in form of features as block featuresframe1, featuresframe2, etc.

	//m is dimensionality of featurevector
	*structuralChange {|data,m,numframes,windowsizes|

		var cumulative = Array.fill(numframes+1,nil);
		var change = Array.fill(windowsizes.size,nil);

		if( (m*numframes) != (data.size)) {

			["size error in data provided!",m,numframes,m*numframes,data.size].postln;

		};


		cumulative[0] = 0.0!m; //zeroes at beginning for ease of calculation below
		cumulative[1] = data[0..(m-1)];

		(numframes-1).do{|i|
			var index = (i+1)*m;

			//as vectors, easier for later calculations
			cumulative[i+2] = (cumulative[i+1].copy) + (data[index..(index+m-1)]);

			//
			//		m.do{|j|
			//
			//		cumulative[index] = cumulative[index-m]+data[index];
			//
			//		};
			//
		};

		//cumulative.postcs;

		windowsizes.do{|windowsize,i|

			var startindex = windowsize;
			var endindex = numframes - windowsize;
			var numcalc = endindex-startindex+1;
			var changearray;

			//for some sort of logging as proceed
			//[\windowsize,windowsize].postln;

			changearray = Array.fill(numframes,0.0);

			//test in case window too big for data
			if((startindex<numframes) && (endindex>=0)) {

				numcalc.do{|j|

					var framenow = startindex + j;
					var firstframe = framenow-windowsize;
					var lastframe = framenow+windowsize-1;
					var s1,s2;

					//get means via cumulative

					//[framenow,firstframe,lastframe+1,framenow].postln;

					s1 = cumulative[framenow] - cumulative[firstframe];
					s2 = cumulative[lastframe+1] - cumulative[framenow];

					//COULD take mean of s1 and s2 properly, eg divide by windowsize. But normalisation in ~jensenshannon makes that an irrelevant operation

					//[s1,s2].postln;

					changearray[framenow] = SCMIRStructuralSummary.jensonShannon(s1,s2);

				};


			};


			change[i] = changearray;

		};

		^change;
	}

	*structuralSummary {|data,m,numframes,windowsizes|

		var tracks;

		tracks = SCMIRStructuralSummary.structuralChange(data,m,numframes,windowsizes);

		//var results = Array.fill(windowsizes.size*2,0.0);

		^ ((tracks.collect{|val|   val.mean}) ++ (tracks.collect{|val|   val.median}));

	}

}




+ SCMIRAudioFile {

	structuralSummary {|windowsizes|

		^SCMIRStructuralSummary.structuralSummary(featuredata,numfeatures,numframes,windowsizes);

	}

}


