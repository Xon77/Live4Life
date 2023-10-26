//just pitch based, no timings included

MarkovPool {
	var <order;
	var <poolsize;
	var <numobjects;
	var <transitiontables;
	var <windowsize;

	*new {|numobjects,poolsize,windowsize|
		^super.new.initMarkovPool(numobjects,poolsize,windowsize);
	}

	 //hard coded for MIDI pitches initially, and pitch classes for selection of table
	initMarkovPool { |numob,ps,ws|

		order = 2;

		poolsize = ps ? 12; //number of pitch classes

		numobjects = numob ?  24;

		transitiontables = Array.fill(poolsize,{Array.fill(numobjects*numobjects,{1!numobjects})});

		windowsize = ws ? 20; //up to 20 events in the past can influence now (should dynamically adjust by timings in general)


	}

	train {|array|


		array.size.do{|i|
			var now = array.copyRange(i-windowsize,i);

			this.learnFromSegment(now);

			//[3,4,5,6].copyRange(-20+2,2)

		};


	}


	learnFromSegment{|array|

		var context,lastthree;

		if(array.size>3) {

			//copyRange is inclusive
			context = array.copyRange(0,array.size-4);

			lastthree = array.copyRange(array.size-3,array.size-1);

			context.do{|val|

				var pitchclass = val%poolsize;
				var index = lastthree[0]*numobjects+lastthree[1];

				transitiontables[pitchclass][index][lastthree[2]] = transitiontables[pitchclass][index][lastthree[2]] + 1;

			}

		};

	}


	//in general, weights by distance of events in the past, decay
	scoreOptions {|array|

		var context,lasttwo;
		var sum = 0.0!numobjects;

		if(array.size>2) {

			context = array.copyRange(array.size-2-windowsize,array.size-3);

			lasttwo = array.copyRange(array.size-2,array.size-1);

			context.do{|val,j|

				var pitchclass = val%poolsize;
				var index = lasttwo[0]*numobjects+lasttwo[1];
				var prop = ((j+1)/(context.size));

				sum = sum + ((transitiontables[pitchclass][index]).normalizeSum * prop);


			};

			//sum.postln;

			//alternatives include rolling dice for each component in sum, and doing a majority vote, or rolling dice on sum.normalizeSum

			^sum;

		} {

			^nil;
		};



	}

	generate {|array,n=1|

		var output = List[];
		var next;

		if(array.size>2) {

			n.do{

				var next = this.scoreOptions(array);

				//"here".postln;
				//next.postln;

				//alternatives include rolling dice for each component in sum, and doing a majority vote, or rolling dice on sum.normalizeSum

				//next = next.maxIndex;

				next = (0..(next.size-1)).wchoose(next.normalizeSum);


				output.add(next);

				array = array.copyRange(1,array.size-1) ++ [next];
			};

		};

		^output.asArray;

	}

	save { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"markovpool"++".scmirZ"};

		a = SCMIRZArchive.write(filename);

		a.writeItem(order);
		a.writeItem(poolsize);
		a.writeItem(numobjects);
		a.writeItem(transitiontables);
		a.writeItem(windowsize);

		a.writeClose;
	}


	load { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"markovpool"++".scmirZ"};

		a = SCMIRZArchive.read(filename);

		order = a.readItem;
		poolsize = a.readItem;
		numobjects = a.readItem;
		transitiontables = a.readItem;
		windowsize = a.readItem;

		a.close;

	}


}
