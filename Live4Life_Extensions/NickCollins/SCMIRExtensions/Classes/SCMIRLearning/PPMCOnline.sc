PPMCOnline : PPMC {
	var <received; 
	
	*new {|maxorder=3|     
		  
		^super.new(maxorder).initPPMCOnline;	     
	}     
	  
	initPPMCOnline {  
		 received = List[];       
	}     
	
	trainOnline {|latest| 
			
			var context;     
			var pastsize; 
			var trienow; 
			
			received.add(latest); 
			
			pastsize = min(received.size,maxorder);     
			
			if(received.size>maxorder) {
				
				//List[3,4,5].copyRange(1,2)
				
				received = received.copyRange(received.size-maxorder,received.size-1); 
				
			}; 
			
			trienow = trie;     
			  
			context = received[(received.size-pastsize)..(received.size-1)];      
			  
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