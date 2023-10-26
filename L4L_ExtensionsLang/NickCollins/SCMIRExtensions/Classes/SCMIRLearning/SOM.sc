//1-dimensional SOM which stores databases of sample vectors with each representative

SOM {		
	
	var maxiterations;
	var learningrate;	//contraction in influence over time
	var neighbourrate; //contraction in influence over neighbours
	var numunits;
	
	var <representatives;
	var <lists; //store old samples and times at which found
	var <iteration;
	var neighbourinfluence;
	var t; //current interpolation parameter
		
	
	*new {arg initialreps, maxiter=100, lrate=0.0, nrate=1;
	
		^super.newCopyArgs(maxiter,lrate,nrate).initSOM(initialreps);
	}
	
	
	initSOM {arg initreps;
		
		
		//make random start vectors if not passed in
		//actually buggy: needs to make a list of vectors, not just a vector, for multi dimensional representatives. Is initreps as a number to be interpreted as the number of representatives or the number of dimensions in a vector
		representatives= if (initreps.isKindOf(SimpleNumber),{Array.rand(initreps,0.0,1.0);},{initreps ? {Array.rand(10,0.0,1.0);}});
		
		numunits=representatives.size;
		
		//List for each representative, will contain [time, vector] pairs
		lists= Array.fill(numunits, {List.new});
		
		iteration=0;
		
	}
	

	//trains as it goes, online learning whenever this is called
	addsample {arg sample; 
		var which, lower, higher, spread;
		
		//no calculation if past maxiterations
		if(iteration<maxiterations,{
			
			t = iteration/(maxiterations);
			
			//t = t ** learningrate; 
			
			t = learningrate + ((1-learningrate)* t); //map to [learning rate, 1]
			
			//find Best Matching Unit
			which=this.getmatch(sample);
		
			//update
			lists[which].add(sample);
			
			//representatives[which]= ((1-t)*sample) + (t*representatives[which]); //interpolation of old vector and new 
			
			
			//find neighbours, linear fall off either side
			spread=numunits*(1-t);
			lower= (which-(spread)).max(0).round(1.0).asInteger;
			higher=(which+(spread)).min(numunits-1).round(1.0).asInteger;
			
			//index lower to higher in representatives for update
			
			//for loop updating appropriate units
			for (lower, higher, {arg index; 
			
			var dist, localt; 
			
			dist= abs(index-which)/(spread+1); 
			dist = dist ** neighbourrate; //must be between 0 and 1
			
			//distt = neighbourrate + ((1-neighbourrate)* dist); //map to [neighbour rate, 1]
			
			localt= t+ (dist*(1-t)); //i.e. position reached due to learningrate, proportion of remainder
			
			//squared falloff?
			
			[localt,dist, t, index, which].postln;
			
			representatives[index]= ((1-localt)*sample) + (localt*representatives[index]); //interpolation of old vectors and new 
			
			 }); 
					
			iteration= (iteration+1).min(maxiterations);
			
		});
			
	}
	
	
	getmatch {arg vector;
	
	var which, best;
	
		which=0;
		best=99999;
			
		//Manhattan metric	
		representatives.do {arg val,i; var tmp; tmp= abs(val-vector).sum;  if(tmp<best, {best=tmp; which=i});  } ;
			
		^which;
	}
	
	
	
}