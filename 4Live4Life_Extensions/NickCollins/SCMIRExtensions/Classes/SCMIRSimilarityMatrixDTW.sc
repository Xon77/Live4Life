//Dynamic Time Warping 

///following Sakoe and Chiba 1978, see also Dixon 2005 DAFX etc
//Sakoe and Chiba (1978) Dynamic Programming Algorithm Optimization for Spoken Word Recognition, IEEE TRANSACTIONS ON ACOUSTICS, SPEECH, AND SIGNAL PROCESSING, VOL. ASSP-26, NO. 1, FEBRUARY 1978
//symmetric algorithm, update a column at a time, only local paths of one horizontal, vertical or diagonal step (at 2*cost) allowed.  
 
+ SCMIRSimilarityMatrix {   
	 
	 
	//matrix is target, size is reducedcolumns by reducedrows 
	dtw {|leeway=10|   
		
		//var result; //[totalcost, path]
		
		var sizea = reducedcolumns; 
		var sizeb = reducedrows; 
		var gradient = sizeb/sizea;
		
		var previouscolumn, currentcolumn; //paths in progress
		var previoushighest;  
		var currentcentre; 
		var fitbelow, fitabove; 
		var temp; 
		var mincost; 
		var minindex;
				
		if(matrix.isNil) {"SCMIRSimilarityMatrix:dtw: no similarity matrix has been calculated to work with".postln;  ^nil };

		//easiest for indexing is if take same size as actual column, then use real indices as go
		previouscolumn = Array.fill(sizeb,{nil});
		currentcolumn = Array.fill(sizeb,{nil});
		 
		//previouscentre = 0; 
		fitbelow = 0; 
		fitabove = leeway.min(sizeb-1); 
		
		previouscolumn[0] = [matrix[0],List[[0,0]]]; 
		
		(fitabove).do{|j| var last = previouscolumn[j];  previouscolumn[j+1] = [matrix[j+1]+(last[0]),last[1].copy.add([0,j+1])]}; 

		//(fitabove+1).do{|j|  previouscolumn[j] = [matrix[j],List[[0,j]]]}; 

		//previouscolumn.postcs; 

		previoushighest = fitabove; 

		//using i for column, j for row following Sakoe and Chiba
		//since start with first column for free
		(sizea-1).do{|index| 
			
			var i = index+1; 
			var matrixbase = i*sizeb; 
		
			currentcentre = (gradient*i).asInteger; //rounds down
			fitbelow = (currentcentre-leeway).max(0); 
			fitabove = (currentcentre+leeway).min(sizeb-1); //because have to be valid indices
			
			
			for(fitbelow,fitabove,{|j|
				
				var newcosts; 
				var dij; 
				
				dij = matrix[matrixbase+j];
				
				//debugging
				if(dij.isNil) {
					"dij nil".postln;
					matrixbase.postln;
					[\i,i,\j,j, \fitbelow, fitbelow, \fitabove, fitabove, sizea, sizeb, matrix.size].postln; 
					matrix.postln;
				};
				
				mincost = 9999999999999.9; 
				minindex = 1; 
				
				//0 = from below in current column, from horiz in previous, from diagonal in previous
				newcosts = [0,0,0];
				
				//depends if accessible
				//must be a previous one there
				//at least one of these conditions is always true?
				newcosts[0] = if(j>fitbelow){currentcolumn[j-1][0] + dij}{mincost}; 
				newcosts[1] = if(j<=previoushighest) {previouscolumn[j][0] + dij}{mincost}; //i always valid since start second column if(i>0){}{mincost}; 
				newcosts[2] = if(j>0){previouscolumn[j-1][0] + (2*dij)}{mincost};
				
				newcosts.do{|val,k|  if(val<mincost){mincost = val; minindex = k; }; };
				
				//[j,newcosts,minindex].postln; 
					
				currentcolumn[j] = switch(minindex,
				0,{[newcosts[0],(currentcolumn[j-1][1]).copy.add([i,j])]},
				1,{[newcosts[1],(previouscolumn[j][1]).copy.add([i,j])]},
				2,{[newcosts[2],(previouscolumn[j-1][1]).copy.add([i,j])]}
				);	
				
				  
			}); 
			
			previoushighest = fitabove; 
			
			temp = previouscolumn; //to be reused	
			previouscolumn = currentcolumn; 
			currentcolumn = temp; 
			
			//[index, previoushighest].postln;
			
			//previouscolumn.postln;
			//currentcolumn.postln;
			
			//previouscolumn[previoushighest]; 
		};
		
		////take min cost in previouscolumn
//		mincost = 9999999999999.9; 
//		minindex = sizeb-1;
//		//currentcentre
//		
//		//"close".postln; 
//		//previouscolumn.postcs; 
//		
//		//previouscolumn.do{|val,k| if(val[0]<mincost){mincost = val[0]; minindex = k; }; }; 
//		
//		//only check 
//		for(fitbelow,fitabove,{|j| 
//			var now= previouscolumn[j];  
//			
//			if(now[0]<mincost){mincost = now[0]; minindex = j; }; 
//			
//			}); 
//		
		
		//previouscolumn.postcs;
		
		//answer is right there already?
		^previouscolumn[sizeb-1];	//previouscolumn[minindex]; //[sizeb-1];  
			 
	} 
		 
		 
		 
} 
 
 
