//tries good in general for reTRIEval type operations

//each individual node of trie is a Dictionary where entries are keyed by string characters/integers and hold one of a count (terminal node/leaf) or [count,Node]

//note maxorder is maximal Markov order, i.e. size of context: the actual strings considering in training or probability calculation are D+1 long including the resultant e.g. context of D characters, one character for symbol now

//I use context below for context + symbol and also for context prefix to symbol, based on... context

//no implementation of exclusion mechanism at present but do have escape mechanism


//Journal of New Music Research
//Volume 33, Issue 4, 2004
//Improved Methods for Statistical Modelling of Monophonic Music
//Marcus Pearcea & Geraint Wiggins
//PPM also mentioned in D Conklin 1996 multiple viewpoints
//we use variant AX of C (add one to all numerators and denominators in calculating counts) from the Pearce and Wiggins 2004 paper herein to get around the situation where previously unseen context!


PPMC {
	var <maxorder;
	var <trie;


	*new {|maxorder=3|

		^super.new.initPPMC(maxorder);
	}

	initPPMC {|mord|

		maxorder = mord;

		//removes old structure
		trie = Dictionary[];
	}





	//can keep adding data
	train {|data|


		data.do {|latest,i|

			var context;
			var pastsize = min(i,maxorder);
			var trienow = trie;

			context = data[(i-pastsize)..i];

			//a = Dictionary[];
			//a.put(9,56)
			//a[9]

			context.do {|pastval,j|

				var node = trienow[pastval];


				//[pastval, trienow, node].postln;


				if(node.notNil) {

					//increment and continue
					node[0] = node[0] +1 ;

					trienow = node[1];

					} {

					//if Dictionary remains empty, leaf
					node = [1,Dictionary[]];

					//["here", node].postln;

					trienow.put(pastval,node);

					trienow = node[1];

					//["here2", trie, trienow, node].postln;


				}

			}

		}

	}


	chooseatnode {|node|
		var elements = Array.fill(node.size,0), counts= Array.fill(node.size,0);
		var i=0;

		//node is a Dictionary to create a weighted distribution over
		node.keysValuesDo{ |key, value|

			elements[i] = key;
			counts[i] = value[0];

			i = i+1;
		};

		^elements.wchoose(counts/(counts.sum));
	}


	generateN {|n, startingpoint, contextsize = 3|
		var lastvals; // = List[];
		var b;
		var temp;

		startingpoint = startingpoint??{[this.generate()]};

		lastvals = startingpoint.asList.reverse;

		b  = Array.fill(n,{

			var nextval = this.generate(lastvals.reverse);

			//may need to reduce context to find a solution
			while({nextval.isNil},{

				if(lastvals.size>0) {
				lastvals.pop;
				this.generate(lastvals.reverse);
				} {
					nextval = this.generate(); //bare generation, must find some non nil thing

				}

			});

			if(lastvals.size<contextsize) {lastvals.addFirst(nextval);} {

				lastvals.addFirst(nextval);
				lastvals.pop;

				};

			nextval;
		});

		^b


	}


	//use context up to maxorder size to find predicted next symbol according to PPM model
	generate {|testseq|

		var seqnow;
		var trienow;
		var stillgoing;
		var prob; 	//if no solutions ever, will remain nil
		var temp;

		if(testseq.isNil){^this.chooseatnode(trie)};

		if(testseq.isEmpty){^this.chooseatnode(trie)};

		if(testseq.size>maxorder) {

			testseq = testseq.copyRange(testseq.size-maxorder,testseq.size-1);

		};

		seqnow = testseq; //may need to update recursively due to definition of P(sigma|D size context) eqn (3) in Begleiter et al 2004 paper

		trienow = trie;

		stillgoing = true;

		while ({
			(seqnow.size>0) && (stillgoing);
			},{

			block {|break|

				seqnow.do {|pastval,j|

					var node = trienow[pastval];

					if(node.notNil) {

						//if just tested sigma, being the symbol with respect to context
						if(j == 	(seqnow.size-1)) {

							^this.chooseatnode(node[1]);
						};


						//continue hunt
						trienow = node[1];

					}

					{

						if(seqnow.size==1) {

							//no matches, just randomise
							^this.chooseatnode(trie);

							} {

							//no matches so far but can shorten context
							seqnow = seqnow.copyRange(1,seqnow.size-1);

							//BREAK!
							break.();
						}




					}

				}

			}

		});

		//just in case nothing resolved

		^this.chooseatnode(trie);
	}



	sumNode {|node|
		var card;
		var sum = 0;
		//var where = 0;

		card = node.size;

		node.do{|val|

			//[\sum, where, card, sum, val,].postln;

			sum = sum + (val[0]); 	//first entry is count

			//where = where + 1;
		};

		^[card, sum];

	}


	//will be called recursively
	probability{|testseq|

		var seqnow;
		var trienow;
		var stillgoing;
		var prob; 	//if no solutions ever, will remain nil
		var temp;

		//"probability".postln;
		//testseq.postln;


		if(testseq.isEmpty){^nil};

		//empty context, 1/numsymbols at top level in trie (could take frequency counts too)
		if(testseq.size==1) {^1.0/(trie.size)};


		if(testseq.size>(maxorder+1)) {

			//not permitted?

			//^nil;

			//shrink context

			testseq = testseq.copyRange(testseq.size-maxorder-1,testseq.size-1);

		};

		seqnow = testseq; //may need to update recursively due to definition of P(sigma|D size context) eqn (3) in Begleiter et al 2004 paper

		//"seqnow".postln;
		//seqnow.postln;


		trienow = trie;

		stillgoing = true;

		while ({
			(seqnow.size>0) && (stillgoing);
			},{



			//"seqnownow".postln;
			//seqnow.postln;

			block {|break|


				if(seqnow.size==1) {

					^1.0/(trie.size);
				};



				seqnow.do {|pastval,j|

					var node = trienow[pastval];


					//[\node, node].postln;

					//if just tested sigma, being the symbol with respect to context
					if(j == 	(seqnow.size-1)) {


						//["sigmapos",trienow].postcs;

						temp = this.sumNode(trienow);

						if(node.notNil) {

							//prob normal calc

							prob = (node[0]+1)/((temp[0])+(temp[1])+1);

						}
						{

							//escape and recurse

							prob = (temp[0]+1)/((temp[0])+(temp[1])+1);

							prob = prob* (this.probability(seqnow.copyRange(1,seqnow.size-1)));

						};

						stillgoing = false;

						//BREAK!
						break.();

						} {


						if(node.notNil) {

							//continue hunt
							trienow = node[1];

							} {

							//no matches, shorten context

							seqnow = seqnow.copyRange(1,seqnow.size-1);

							//BREAK!
							break.();
						}




					}

				};


			};

		});


		^prob;
	}


	averagelogloss {|testsequence|

		var sum = 0.0;

		testsequence.do {|latest,i|

			var context;
			var pastsize = min(i,maxorder);

			context = testsequence[(i-pastsize)..i];

			sum = sum + log2(this.probability(context));
		};

		^((sum.neg)/(testsequence.size));
	}


	logloss {|testsequence|

		var sum = 0.0;

		^testsequence.collect {|latest,i|

			var context;
			var pastsize = min(i,maxorder);

			context = testsequence[(i-pastsize)..i];

			log2(this.probability(context));
		};
	}





	checkTrie {|dictionary, depth=0|
		var size = dictionary.size;

		if(size>0) {

		dictionary.keysValuesDo {|key,value|

			if((key.isNil) || ((value[0]).isNil)) {

				"aaargh!".postcs;
				[key, value].postcs;

			};

			this.checkTrie(value[1],depth+1);

			}

		};

	}


	printTrieCounts {|dictionary, depth=0|
		var size = dictionary.size;

		if(size>0) {

		dictionary.keysValuesDo {|key,value|

			value[0].postcs;

			this.printTrieCounts(value[1],depth+1);

			}

		};

	}






	//recursive save and load functions; to cope with nesting level to maxorder+1 of the trie
	saveDictionary {|archive, dictionary, depth=0|

		var size = dictionary.size;

		//archive.writeItem(size);

		archive.putInt32LE(size);

		if(size>0) {

		dictionary.keysValuesDo {|key,value|


			archive.putInt32LE(key);

			//archive.writeItem(key);


			archive.putInt32LE(value[0]);

			//archive.writeItem(value[0]);

			//if(value[1].size=0)

			this.saveDictionary(archive,value[1],depth+1);

			}

		};

	}

	loadDictionary {|archive, depth=0|

		var size, dictionary;

		//size = archive.readItem;

		size = archive.getInt32LE;

		dictionary = Dictionary[];

		if(size==0) {^dictionary }; //[a.readItem, dictionary]

		size.do {|i|
			var key,count, dict;

			//key = archive.readItem;

			//count = archive.readItem;

			key = archive.getInt32LE;

			count = archive.getInt32LE;

			dict = this.loadDictionary(archive,depth+1);

			dictionary.put(key,[count,dict]);

		};

		^dictionary;
	}


//ZArchive persistently failing on very big nested tries, so just going with ascii file format at expense of size
	save { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"PPMC"++".scmirZ"};

		//a = SCMIRZArchive.write(filename);

		a = SCMIRFile(filename,"w");

		//a.writeItem(maxorder);

		a.putInt32LE(maxorder);

		this.saveDictionary(a,trie,0);

		//a.writeItem(trie);

		a.close;

		//a.writeClose;
	}


	load { |filename|
		var a;

		filename = filename?? {SCMIR.tempdir++"PPMC"++".scmirZ"};


		a = SCMIRFile(filename,"r");

		//a = SCMIRZArchive.read(filename);

		//examples of use of File in SCMIRAudioFile
		maxorder = a.getInt32LE; //a.readItem;

		//trie = a.readItem;

		trie = this.loadDictionary(a,0);

		a.close;

	}



}





/*

//old, could simplify construction

if(i>=1) {


	var temp = trie[pastval];

	context = data[i-pastsize,i-1];


	//[11,14,17].reverseDo{|val,i|   [val,i].postln;}



	context.reverseDo {|pastval,j|



		if(temp.notNil) {

			//increment and continue

			} {


		}

	}


	} {

	//first entry, just add and increment count				trie.add(latest,[1,Dictionary[]]);

}



*/




