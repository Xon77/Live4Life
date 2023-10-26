KNearestNeighbour {

	var <k;
	var <data;
	var <range;

	*new {|k,data,range|

		^super.newCopyArgs(k,data,range);

	}

	findClosestK {|inputvector|

		var closest = List[];
		var maxmin = 9999999999999.9;

		data.collect{|point, index|

			var testvector = point[0];
			var tag = point[1];

			var dist = (testvector - inputvector).squared.sum;

			if(dist<maxmin) {

				if(closest.size==k) {

					closest.pop;
				};

				closest.addFirst([dist,index]);

				closest.sort({|a,b| a[0]<b[0]});

				maxmin = (closest.last)[0]; //closest.collect{|val| val[0]}.maxItem;

			};

		};

		^closest;

	}

	findClosest {|inputvector|

		^data[this.findClosestK(inputvector)[0][1]][1]; //absolute closest
	}


	test {|inputvector|
		var winner;
		var options;

		winner = this.findClosestK(inputvector).collect{|val| data[val[1]][1] }; //closest[0][1]; //.collect{|val| val[1]};

		//winner.postln;

		//majority vote
		options = 0!range;

		//options.postln;

		winner.do{|index| options[index] = options[index] + 1; };

		//options.postln;

		^options.maxIndex;

	}

	testWeighted {|inputvector,weights|
		var winner;
		var options;

		winner = this.findClosestK(inputvector).collect{|val| data[val[1]][1] };

		weights = weights ?? {Array.fill(k,{|i| 1.0/(i+1)}).normalizeSum;};

		options = 0!range;

		winner.do{|index,j| options[index] = options[index] + (weights[j]); };

		^options.maxIndex;
	}

}