//1-dimensional SARDNET which does not store sequences, but learns maps from sequences 
 
SARDNET {		 
		 
	var <dimensions;  
	var <maxiterations; 
	var <learningrate;	//contraction in influence over time 
	var <neighbourrate; //contraction in influence over neighbours 
	var <numrepresentatives; 
	var <dimension;  
		 
	var <representatives; 
	//var <lists; //store old samples and times at which found 
	var <iteration; 
	var <neighbourinfluence; 
	var <t; //current interpolation parameter 
	var <available;  
	var <activated; //once activated, no longer available to be picked. Array holds index, and also activation score	 
		 
	*new {arg dimensions, initialreps, maxiter=100, lrate=0.0, nrate=1; 
			 
		^super.newCopyArgs(dimensions, maxiter,lrate,nrate).initSARDNET(initialreps); 
	} 
		 
		 
	initSARDNET {arg initreps; 
			 
		//make random start vectors if not passed in 
		representatives= if(initreps.isKindOf(SimpleNumber),{Array.fill(initreps,{Array.rand(dimensions,0.0,1.0);}); },{initreps ? { Array.fill(10, {Array.rand(dimensions,0.0,1.0);}); }}); 
			 
		numrepresentatives=representatives.size; 
			 
		//List for each representative, will contain [time, vector] pairs 
		//lists= Array.fill(numrepresentatives, {List.new}); 
			 
		iteration=0; 
			 
	} 
		 
	 
	//trains as it goes, online learning whenever this is called 
	train {arg sequence; 
		var which, lower, higher, spread; 
			 
		//no calculation if past maxiterations 
		if(iteration<maxiterations,{ 
				 
			t = iteration/(maxiterations); 
				 
			//t = t ** learningrate;  
				 
			t = learningrate + ((1-learningrate)* t); //map to [learning rate, 1] 
				 
				 
			available = (0..(numrepresentatives-1)).asList; 
			activated = List[];  
				 
			//sequence is list of feature vectors, one for each time step 
			sequence.do{|featurevector| 
					 
				//find Best Matching Unit 
					 
				which=this.getMatch(featurevector); 
					 
				//update 
									 	 
				activated.do {|unitactive| 
						 
					unitactive[1] = unitactive[1] * 0.75; //d = 0.75 in activation drop off equation  
				};  
					 
				activated.add([which,1.0]); 
					 
				available.remove(which);  
					 
				//representatives[which]= ((1-t)*sample) + (t*representatives[which]); //interpolation of old vector and new  
					 
					 
				//spread of activation to neighbours 
					 
					 
				//find neighbours, linear fall off either side 
				spread=numrepresentatives*(1-t); 
				lower= (which-(spread)).max(0).round(1.0).asInteger; 
				higher=(which+(spread)).min(numrepresentatives-1).round(1.0).asInteger; 
					 
				//index lower to higher in representatives for update 
					 
				//for loop updating appropriate units 
				for (lower, higher, {arg index;  
						 
					var dist, localt;  
						 
					dist= abs(index-which)/(spread+1);  
					dist = dist ** neighbourrate; //must be between 0 and 1 
						 
					//distt = neighbourrate + ((1-neighbourrate)* dist); //map to [neighbour rate, 1] 
						 
					localt= t+ (dist*(1-t)); //i.e. position reached due to learningrate, proportion of remainder 
						 
					//squared falloff? 
						 
					//[localt,dist, t, index, which].postln; 
						 
					//TO SORT  
					//representatives[index]= ((1-localt)*sample) + (localt*representatives[index]); //interpolation of old vectors and new  
						 
						 
					representatives[index]= ((1-localt)*featurevector) + (localt*representatives[index]);  
						 
				});  

					 
			};	 
				 
			//lists[which].add(sample); 
				 
				 
			iteration= (iteration+1).min(maxiterations); 
				 
		}); 
			 
	} 
		 
		 
	test {arg sequence; 
		
		var which, lower, higher, spread; 
			  
		available = (0..(numrepresentatives-1)).asList; 
		
		activated = List[];  
			 
		//sequence is list of feature vectors, one for each time step 
		sequence.do{|featurevector| 
				 
			//find Best Matching Unit 	 
			which=this.getMatch(featurevector); 
				 
			//update 
				 
			activated.do {|unitactive| 
					 
				unitactive[1] = unitactive[1] * 0.75; //d = 0.75 in activation drop off equation  
			};  
				 
			activated.add([which,1.0]); 
				 
			available.remove(which);  
		 
		};	 
		
		^activated; //this is the pattern in response to the input feature vector 	 
	} 
		 
		 
	getMatch {arg vector; 
			 
		var which, best, tmp; 
			 
		which=0; 
		best=99999; 
			 
		//representatives.do {arg val,i; var tmp; tmp= abs(val-vector).sum;  if(tmp<best, {best=tmp; which=i});  } ; 
			 
		available.do {arg i;  
				 
			var rep = representatives[i];  
				 
			tmp = (rep-vector).squared.sum; //Euclidean 
				 
			//tmp= abs(val-vector).sum;  //Manhattan metric	 
			if(tmp<best, {best=tmp; which=i});  
				 
		}; 
			 
		^which; 
	} 
		 
		 
		 
} 
