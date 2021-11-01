//A Variable Order Hidden Markov Model with Duration based on Frequent Sequence Mining
//Mohammed J. Zaki et al. ACM Transactions on Knowledge Discovery from Data 4(1)
//for 2-sequences only. Doesn't model 1-sequences either

VOGUE {

	var <vgs; //required for training
	var <alphabetsize;

	var <numstates,<numqs1,<numqs2,<numqg,<numqu,<qindices;
	var <currentstate;
	var <qs1, <qs2; //symbol indices associated with each state

	var <emissionprobabilitymatrix;
	var <statetransitionmatrix;
	var <statedurationprobabilities;
	var <initialstateprobabilities;

	*new {|vgs|

		^super.newCopyArgs(vgs).initVOGUE();
	}

	initVOGUE {

		var temp;

		alphabetsize = vgs.alphabet.size;

		temp = vgs.statedata;

		numqs1 = temp[0].size;
		numqs2 = temp[2].size;
		numqg = temp[1].size;
		numqu = 1; //not used in practice
		numstates = numqs1+numqg+numqs2+numqu;

		//jumping straight to the state indices
		qindices = [0,numqs1,numqs1+numqg,numqs1+numqg+numqs2];

		emissionprobabilitymatrix = {0.0!alphabetsize}!numstates;
		statetransitionmatrix = {0.0!numstates}!numstates;
		statedurationprobabilities = {0!(vgs.maxgap)}!numstates;
		initialstateprobabilities = 0.0!numstates;
	}

	train {

		var offset, temp;
		var statedata = vgs.statedata;
		var uniform = (1.0/alphabetsize)!alphabetsize;
		var alpha = 0.99;

		//3.2.3 symbol emission probabilities

		"calculating symbol emission probabilities".postln;

		//Qs1, Qs2, just one symbol per state

		numqs1.do{|i| emissionprobabilitymatrix[i][statedata[0][i]] = 1.0;  };

		offset = qindices[2];
		numqs2.do{|i| emissionprobabilitymatrix[offset+i][statedata[2][i]] = 1.0;  };

		temp = vgs.freqab(statedata[1]);
		offset = qindices[1];

		numqg.do{|i|

			//already have the solution in temp for symbol emission probability for a given gap state
			emissionprobabilitymatrix[offset+i] = (temp[i] *0.99) + (uniform*0.01);
		};

		offset = qindices[3];
		temp = vgs.alphabetprob;
		emissionprobabilitymatrix[offset] = temp*0.99 + (uniform*0.01);


		//3.2.4 transition probability matrix

		"calculating transition probability matrix".postln;

		"transition from first states".postln;

		//transition from first states
		numqs1.do {|i|

			var a = statedata[0][i];

			var freqcounts = vgs.freqaj(a);

			temp = 0!numstates;

			//to gaps
			offset = qindices[1];
			numqg.do {|j|
				var now = statedata[1][j];

				if(now[0]==a) {

					temp[offset+j] = freqcounts[now[1]][1];
				};

			};

			//to second states
			offset = qindices[2];

			//[\freqcounts,freqcounts].postcs;
			//[\statedata2,statedata[2]].postcs;

			numqs2.do {|j|

				var b = statedata[2][j];
				var counts = freqcounts[b];

				//[j,b,freqcounts[b]].postcs;

				if(counts.size>1) {
				temp[offset+j] = freqcounts[b][0];
				};

				//else transition doesn't occur, zero probability already assigned

			};

			statetransitionmatrix[i] = temp;

		};

		"transitions from gap states".postln;

		//transitions from gap states
		numqg.do{|i|

			var gap = statedata[1][i];

			temp = 0!numstates;

			temp[qindices[2]+gap[1]] = 1.0;

			statetransitionmatrix[qindices[1]+i] = temp;
		};

		"transitions from second states".postln;

		//transitions from second states and universal involve same calculation

		temp = 0!numstates;

		numqs1.do {|i|

			var firstsymbol = statedata[0][i];

			temp[i] = alpha * vgs.freqjb(firstsymbol);
		};

		temp[qindices[3]] = 1 - alpha;

		numqs2.do {|i|

		statetransitionmatrix[qindices[2]+i] = temp;

		};

		//transitions from universal gap
		statetransitionmatrix[qindices[3]] = temp;


		//3.2.5 state duration probabilities

		"calculating state duration probabilities".postln;

		numqs1.do{|i|
			statedurationprobabilities[i][0]=1.0;
		};

		offset =  qindices[2];

		numqs2.do{|i|
			statedurationprobabilities[offset+i][0]=1.0;
		};

		//gaps
		offset =  qindices[1];

		temp = vgs.gapdata;

		numqg.do{|i|

			var now = temp[i];

			statedurationprobabilities[offset+i] = now/(now.sum);

		};

		statedurationprobabilities[qindices[3]][0]=1.0;

		//3.2.6 initial state probabilities

		"calculating initial state probabilities".postln;

		temp = vgs.freqqs1(numqs1);

		numqs1.do{|i|
			initialstateprobabilities[i]=alpha*temp[i];  //TO SORT
		};

		initialstateprobabilities[qindices[3]]=1.0-alpha;

	}

	//output sequence of a certain length
	generate {|n=1|

		var statenow = 0;
		var output = List[];
		var temp;
		var duration = 1;
		var allstates = (0..(numstates-1));
		var allsymbols = (0..(alphabetsize-1));
		var alldurations = (1..(vgs.maxgap));

		//create initial state
		statenow = allstates.wchoose(initialstateprobabilities);

		//generate n output tokens following hidden state transitions and emissions probabilities

		n.do {|i|

			//emit symbol

			temp = allsymbols.wchoose(emissionprobabilitymatrix[statenow]);

			output.add(temp);

			if(duration>1) {duration = duration-1;}
			{
			//update state

				statenow = allstates.wchoose(statetransitionmatrix[statenow]);

				duration = alldurations.wchoose(statedurationprobabilities[statenow]);
			};

			//[i, \statenow, statenow, \duration, duration, \temp, temp].postcs;

		};

		^vgs.indicesToSymbolArray(output.asArray);
	}

}
	