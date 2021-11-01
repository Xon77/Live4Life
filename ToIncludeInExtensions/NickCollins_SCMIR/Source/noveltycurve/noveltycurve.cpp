//This code is part of an extension set for SuperCollider 3 (http://supercollider.sourceforge.net/). We follow the same license terms for SuperCollider 3, releasing under GNU GPL 3 
//all code here by Nick Collins http://www.cogs.susx.ac.uk/users/nc81/index.html



#include <iostream>
#include <cstdio>
#include <cstdlib>

int main (int argc, char * const argv[]) {
    // insert code here...
    std::cout << "Calculating Novelty Curve\n";
	
	float * matrix; //if fvs2 NULL, 
	int matrixsize, numcols;
	
	FILE * fpinput;
	FILE * fpoutput;
	
	fpinput = fopen(argv[2], "rb");
	
	fread(&matrixsize, sizeof(int), 1, fpinput); 
	fread(&numcols, sizeof(int), 1, fpinput); 
	
	matrix = new float[matrixsize]; 
	
	fread(matrix, sizeof(float), matrixsize, fpinput); 
	
	fclose(fpinput); 
		
	int kernelsize = atoi(argv[1]); 
	int halfkernelsize = kernelsize/2; 
	
	
	//std::cout << halfkernelsize << " " << kernelsize <<" " << matrixsize << " " << numcols << "\n";
	
	
//	if(numcols<=kernelsize) {
//		
//		std::cout << "noveltycurve: \n";
//		
//		return 1; 
//		
//	}
	
	float * output; 

	output = new float[numcols]; 
		
	//initial and final zeroes when no room for curve?
	
	int i,j,k; 
	
	int top = numcols-halfkernelsize-1; 
	
	float sum, mult; 
	int colbaseindex; 
	
	for (i=0; i<numcols; ++i) {
	
		if((i>=halfkernelsize) && (i<=top)) {
			
			sum = 0.0; 
			
			//only need to calculate half, and above diagonal
			for (j=(i-halfkernelsize); j<(i+halfkernelsize); ++j) {
					
				colbaseindex = j * numcols; 
				
				for (k=(j+1); k<=(i+halfkernelsize);++k) {
				
					//hard checkerboard for now
					mult = ( (k<i) || (j>i) ) ? 1: (-1); 
					
					sum += matrix[colbaseindex+k]; 
					
				}
				
			}
			
			
//			//self consistency of sections either side of i ignored; only care about cross comparisons old section to new
//			for (j=(i-halfkernelsize); j<i; ++j) {
//				
//				colbaseindex = j * numcols; 
//				
//				for (k=(i+1); k<=(i+halfkernelsize);++k) {
//					
//					//hard checkerboard for now
//					mult = ( (k<i) || (j>i) ) ? 1: (-1); 
//					
//					sum += matrix[colbaseindex+k]; 
//					
//				}
//				
//			}
			
			
			output[i] = sum; 
			
			
		}
		
		else 
			output[i] = 0.0; //if no room to apply checkerboard, no sensible measurement 
		
		
		//std::cout << output[i] << " " ; 
	}
		 
	
	fpoutput = fopen(argv[3], "wb");
	
	//std::cout << "\n " << argv[3] << " "; 
	
	fwrite(output, sizeof(float), numcols, fpoutput); 
	
	fclose(fpoutput); 
	
	delete [] matrix; 
	
	delete [] output; 
	
	std::cout << "Calculated Novelty Curve\n";
	
    return 0;
}
