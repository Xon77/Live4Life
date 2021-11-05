//currently normalizes with respect to individual transitions with just respect to local changes, rather than globally against frequency counts over all transitions
 
 
MarkovModel { 
		 
	var <numstates;  
	var <order;  
	var <lookupaids; //indexing multipliers to help locate a given transition  
	var <transitioncounts;  
	var <transitionprobabilities;  
	var <minimalprob; //for case where asked to assess a transition that is not in the model and need to avoid zero 
		 
		 
	*new {|numstates=4,order=1| 
			 
		^super.new.initMarkovModel(numstates,order);	 
	} 
	 
	initMarkovModel {|ns, ord| 
			 
		numstates = ns;  
		order = ord;  
			 
		//transitioncounts = 0!(ns**(ord+1));  
			 
		lookupaids = Array.fill(ord+1,{|i| (ns**i).asInteger}).reverse; 
		
			 
		//initialise all to 1 for safety and to avoid 0 chance transitions?  	 
		transitioncounts = 0!((numstates**(order+1)).asInteger); //reset 
					 
		transitionprobabilities = 0.0!(numstates**(order+1)); 
			 
	} 
		 
	
	//if norm false can keep adding data	 
	train {|data, norm=true|  
		 
		(data.size - order).do {|i|  
				 
			var subseq = data[i..(i+order)]; 
			//var consequent 
			var index;  
				 
			index = (subseq*lookupaids).sum;  
				 
			//			i.postln; 
			//			subseq.postln; 
			//			(subseq*lookupaids).postln; 
			//			index.postln; 
				 
			transitioncounts[index] = transitioncounts[index]+1;   
				 
		};  
	 
	 
	 	if(norm) {this.calculateProbabilities};
	}
	
	
	//normalize relative to whole or relative to part? relative to local herein presently
	calculateProbabilities {
		
	  	var temp = 1.0;  
		
		((numstates**order).asInteger).do{|j| 
				 
			var index = j*numstates;  
			var local = transitioncounts[index..(index+numstates-1)]; 
			var total = local.sum;  	 
				 
			if(total>0.0000000000001) {  
				
				local = local/total; 
				
				for(0,numstates-1,{|k|
					
					transitionprobabilities[index+k] = local[k]
				}); 
				
				//transitionprobabilities[index..(index+numstates-1)] = local/total;  
			} 
				 
		}; 
	 
		//minimalprob = min(transitionprobabilities over 0)*0.1;  
		minimalprob = 1.0;  
			 
		transitionprobabilities.do{|val|    
				 
			if(val>0.0000000000001) { 
					 
				if(val<minimalprob) { 
						 
					minimalprob = val; 	 
				} 
					 
			} 
				 
		}; 
			 
		minimalprob = minimalprob*0.1; 	 
			 
	} 
	
	
	distribution {|inputsequence| 
		
		var indexstart; 
		var input; 
		
		input = if(inputsequence.size>order,{
		
			inputsequence.copyRange(inputsequence.size-order,inputsequence.size-1); 
			
		},inputsequence); 
		
		
		
		if(input.size<order) {^nil}; 
		
		 indexstart = ((input++[0])*lookupaids).sum;  
		 
		 ^transitionprobabilities.copyRange(indexstart,indexstart+numstates-1);
	} 
	
		 
		 
		 
	averagelogloss {|testsequence| 
			 
		var sum = 0.0; 
			 
		(testsequence.size - order).do {|i|  
				 
			var subseq = testsequence[i..(i+order)]; 
			//var consequent 
			var index;  
			var prob;  
				 
			index = (subseq*lookupaids).sum;  
				 
			prob = transitionprobabilities[index];  
				 
			if(prob<0.0000000000001) {prob = minimalprob};  
				 
			sum = sum + log2(prob);  
				 
		}; 
			 
		^((sum.neg)/(testsequence.size));  
	} 
		
		
	
	
	save { |filename| 
		var a;   

		filename = filename?? {SCMIR.tempdir++"MarkovModel"++".scmirZ"}; 
	
		a = SCMIRZArchive.write(filename);  

		a.writeItem(numstates);
		a.writeItem(order);  
		a.writeItem(lookupaids);
		a.writeItem(transitioncounts);  
		a.writeItem(transitionprobabilities);  
		a.writeItem(minimalprob);  
		
		a.writeClose;  		  
	}  
	  
	  
	load { |filename| 
		var a;   
		  
		filename = filename?? {SCMIR.tempdir++"MarkovModel"++".scmirZ"};    
		  
		a = SCMIRZArchive.read(filename);  

		numstates = a.readItem;   
		order = a.readItem;   
		lookupaids = a.readItem; 
		transitioncounts = a.readItem;   
		transitionprobabilities = a.readItem; 
		minimalprob = a.readItem;  
				  
		a.close;  
		  
	}  	
		
		 
		 
} 
