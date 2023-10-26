//experimental code for differences and sums over multifeatures

+ SCMIRAudioFile {  
	  
	
	//acts in place, directly on data
	//first discrete derivative by default
	differentiateFeature {|featurelist=0,type=0|
		
		var featurecounts = this.resolveFeatureNumbers; 
		var numfeaturegroups = featureinfo.size; 
		
		if(featurelist.size==0) {featurelist = [featurelist]}; 
		
		featurelist.do {|which| 
		
		var startindex = featurecounts[which][0]; 	
		var groupsize = featurecounts[which][1];
		var top = groupsize - 1; 		
		var temp=0; 
		var valthen = 0!groupsize; 
		
		//always zero out first slots as no difference at start (to avoid massive starting transient)
		
		for(0,top,{|j|
			valthen[j] = featuredata[startindex+j]; 
			featuredata[startindex + j] = 0; 	
		}); 	
			
		
		temp = numfeatures + startindex; 
		
		 for(2,numframes-1,{|i|     

			for(0,top,{|j|     
				  
				var val = featuredata[temp+j];       
				var diff;
				
				//valthen[j] = data[temp+j-numfeatures];  
				  
				diff = val - (valthen[j]); 
				
				//only positive increases
				if(type==2) {diff= max(0,diff);};
				
				//just size of change
				if(type==1) {diff= diff.abs;};
				
				valthen[j] = val; 
	
				featuredata[temp+j] = diff; 
				  
			});   

			temp = temp+ numfeatures;  
		});   
		
			
		}; 

	}
	
	 
	 
	sumMultiFeature {|which|
		
		var featurecounts = this.resolveFeatureNumbers; 
		var numfeaturegroups = featureinfo.size;
		var groupindex = featurecounts[which][0]; 
		var groupsize = featurecounts[which][1];
		var newfeaturedata; 
		var correction = 1 - groupsize; 
		var newnumfeatures = numfeatures +correction; 
		
		newfeaturedata = FloatArray.newClear(numframes*newnumfeatures); 
		
		for(0,numframes-1,{|i|     

			var base = i*newnumfeatures; 
			var base2 = i*numfeatures; 
			var sum; 
			
			if(groupindex>0) {
			newfeaturedata[base..(base+groupindex-1)] = featuredata[base2..(base2+groupindex-1)]
			}; 
			
			
			sum = featuredata[(base2+groupindex)..(base2+groupindex+groupsize-1)].sum;

			newfeaturedata[base+groupindex] = sum; 
			
			if(groupindex<(numfeaturegroups-1)) {
			newfeaturedata[(base+groupindex+1)..(base+newnumfeatures-1)] = featuredata[(base2+(featurecounts[which+1]))..(base2+numfeatures-1)]
			}; 
			
			
		}); 
				  
		featuredata = newfeaturedata; 
		numfeatures = newnumfeatures; 
		
		featureinfo[which] = [\Summed];  
		
	} 
	 





}