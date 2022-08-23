//aka VGS, p.6 in VOGUE paper
//but assumes input sequences are always just integer sequences e.g., [0,3,4,2,3,2,0,4,0..]
//assumes 2-sequences only, really

VariableGapSequenceMining {
	var <>minsupport,<>maxgap,<>maxsubseqsize;
	var <alphabet,<alphabetindexlookup;
	var <subsequences;
	var <sequence;
	var <alphabetprob; //alphabetprob1-sequence occurence probabilities

	*new {|minsupport=2,maxgap=2,maxsubseqsize=2|

		^super.newCopyArgs(minsupport,maxgap,maxsubseqsize).initVariableGapSequenceMining();
	}

	initVariableGapSequenceMining {

		subsequences = Dictionary(); //Dictionary keyed by sequence arrays
	}

	//just up to 2-sequences now
	train{|seqinput|

		var seq;

		//reset
		this.initVariableGapSequenceMining;

		//unique symbols
		alphabet = seqinput.asSet.asArray.sort;

		alphabetindexlookup = Dictionary();
		alphabet.do{|val,i|  alphabetindexlookup[val] = i; };

		//convert to indexed numbers 0-alphabetsize
		seq = seqinput.collect{|val| alphabetindexlookup[val] };
		sequence = seq;

		//only need to process for up to length 2 subsequences for now since that is the main VOGUE implementation tested in the paper

		//1-sequences easier
		//2-sequences

		//initialise: just put all the possibilities in dictionary with count 0, since only alphabetsize + alphabetsize.squared options

		alphabet.size.do{|symbol|

			subsequences[[symbol]] = [0,nil,nil]; //no gap size distribution, no gap symbol distribution

			alphabet.size.do{|symbol2|

				subsequences[[symbol,symbol2]] = [0,[0,0,0],0!(alphabet.size)];
			}

		};


		alphabetprob = 0!(alphabet.size);

		seq.do{|symbol,i|

			var temp;

			//symbol is 1-sequence itself
			temp = subsequences[[symbol]][0];
			subsequences[[symbol]][0] = temp+1;
			alphabetprob[symbol] = alphabetprob[symbol] + 1;

			//symbol 2-seq

			((i+maxgap+1).min(seq.size-1)-i).do {|gap|
				var nextsymbol = seq[i+gap+1];
				var entry = subsequences[[symbol,nextsymbol]];

				entry[0] = entry[0]+1;
				entry[1][gap] = entry[1][gap] + 1;
				gap.do{|j|
					//used to be case that were working with disparate symbols, now just indices to symbols internally
					//var inbetween = alphabetindexlookup[seq[i+j+1]];
					var inbetween = seq[i+j+1];

					entry[2][inbetween] = entry[2][inbetween] + 1;
				};

			}

		};


		alphabetprob = alphabetprob.normalizeSum;

		//cull anything with frequency less than minsupport
		subsequences = subsequences.select{|val|    val[0]>=minsupport};

	}

	statedata {

		var n1list = List[];
		var n2list = List[];
		var gapcount = 0;
		var gapconnects = List[];

		subsequences.keysValuesDo{|key,val|

			if(key.size>1) {
				n1list.add(key[0]);
				n2list.add(key[1]);

				if(val[1].copyRange(1,maxgap).sum>0) {gapcount = gapcount+1;   gapconnects.add(key);};
			};

		};

		//^[this.symbolArrayToIndices(n1list.asSet.asArray.sort),this.symbolArrayToIndices(gapconnects),this.symbolArrayToIndices(n2list.asSet.asArray.sort)];

^[n1list.asSet.asArray.sort,gapconnects,n2list.asSet.asArray.sort];

	}

	gapdata {

		var list= List[];

		subsequences.keysValuesDo{|key,val|

			if(key.size>1) {

				if(val[1].copyRange(1,maxgap).sum>0) {
					list.add(val[1].copyRange(1,maxgap));
				};
			};

		};

^list.asArray
	}

	//relative probability all starting points
	freqqs1 {|numqs1|
		var n1list = 0!numqs1;
		var temp;

		subsequences.keysValuesDo{|key,val|

			if(key.size>1) {

				temp = key[0];

				n1list[temp] = n1list[temp] + val[0];

			};

		};

		^n1list/(n1list.sum);
	}




	symbolArrayToIndices {|array|

		^array.collect{|val|  alphabetindexlookup[val] };

	}

	indicesToSymbolArray {|array|

		^array.collect{|i|  alphabet[i] };

	}

	freqab {|arrayab|

		^arrayab.collect{|ab|

			subsequences[ab][2].normalizeSum;

		};

	}


	//transitions between states; anything starting with a to any other alphabet
	freqaj {|a|

		var temp;
		var total=0;
		var probs = 0!(alphabet.size); //one for each possible continuation

		subsequences.keysValuesDo{|key,val|

			//[key,val].postcs;

			if(key.size>1) {

				if(key[0]==a) {

					temp = val[1]; //gap information

					//[\temp,temp,temp.sum,temp[0],temp.copyRange(1,2)].postln;

					total = total + (temp.sum);

					probs[key[1]] = [temp[0], temp.copyRange(1,maxgap).sum];

					//[\temp,temp,temp.sum,temp[0],temp.copyRange(1,2)].postln;

				}
			};

		};

		^probs/total;

	}

	freqjb {|j|

		var temp;
		var totalj=0;
		var all=0;

		subsequences.keysValuesDo{|key,val|

			if(key.size>1) {

				all = all + val[0]; //count for this duplet

				if(key[0]==j) {

					temp = val[1]; //gap information

					totalj = totalj + (temp.sum); //isn't temp.sum always equal to val[0]?

				}
			};

		};

		^totalj/all;
	}




	save {}

	load {}



}