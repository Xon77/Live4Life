//integrates gmm-gmr 
//Copyright (c) 2008 Florent D'halluin , Sylvain Calinon, 
//LASA Lab, EPFL, CH-1015 Lausanne, Switzerland, 
//http://www.calinon.ch, http://lasa.epfl.ch
//The program is free for non-commercial academic use. 

//This code is part of an extension set for SuperCollider 3 (http://supercollider.sourceforge.net/). We follow the same license terms for SuperCollider 3, releasing under GNU GPL 3 
//all non-gmm-gmr code here by Nick Collins http://www.cogs.susx.ac.uk/users/nc81/index.html


//#include <iostream>

#include "MathLib.h"
#include "gmr.h"



//arguments
//mode 0 train:
//0, numstates, input filename, out model filename
//mode 1 test:
//1, model filename, input filename, output filename 


int main (int argc, char * const argv[]) {
    // insert code here...
    
	GaussianMixture g;
	
	Matrix dataset;
	//unsigned int nbData=0;
	char filename[256];
	
	int calltype = atoi(argv[1]); 	
	
	int numstates; 
	
	if (calltype ==0) {
		
		numstates = atoi(argv[2]); 	
		
		//for (unsigned int i = 0; i < NBSAMPLES; i++){
		sprintf(filename,argv[3]); //"/Applications/SuperCollider/SuperCollider3.4/gmminput.temp");
		dataset = g.loadDataFile(filename); 	
		
		std::cout << "Learning the GMM model" << std::endl; 
		g.initEM_TimeSplit(numstates,dataset); // initialize the model; fitting NBSTATES Gaussians to the data, which is one instance per row (counter for time in first colummn)
		g.doEM(dataset); // performs EM
		std::cout << "saving the result to " << filename << std::endl;
		
		//NEED TO PASS FILENAME	
		sprintf(filename,argv[4]); //"/Applications/SuperCollider/SuperCollider3.4/gmminput.temp");
		
		g.saveParams(filename);
		std::cout << "ok" << std::endl;
	} 
	
	else {
		
		int i; 
		
		sprintf(filename,argv[2]); 
		
		g.loadParams(filename);	
		
		numstates = g.nState; 
		
		int numfeatures = g.dim; 
		
		//std::cout << "loaded model " << numstates <<" " << numfeatures << std::endl;

		
		//sprintf(filename,argv[3]); 
		
		FILE * fpinput;
		FILE * fpoutput;
		
		fpinput = fopen(argv[3], "rb");
		
		float * inputdata = new float[numfeatures]; 
		
		fread(inputdata, sizeof(float), numfeatures, fpinput);
		
	//	for (i=0; i<numfeatures; ++i) {
//			
//			std::cout << i << " " << inputdata[i] << std::endl;
//			
//		}
				
		fclose(fpinput); 

		Vector testinput(inputdata,numfeatures); 
		
		delete [] inputdata; 
		
		int minindex=0; 
		float maxprob = 0.0f; 
		
		float * probs = new float[numstates]; 
		
		for (i=0; i<numstates; ++i) {
			
			float prob = g.pdfState(testinput,i);
			
			probs[i] = prob; 
			
			if (prob>maxprob) {
				maxprob = prob; 
				minindex = i; 
			}
			
			//std::cout << i << " " << prob << std::endl;
		}
		
		fpoutput = fopen(argv[4], "wb");
		
		//std::cout << "\n " << argv[3] << " "; 
		fwrite(&minindex, sizeof(int), 1, fpoutput); 
		
		fwrite(probs, sizeof(float), numstates, fpoutput); 
		
		fclose(fpoutput); 
		
		delete [] probs; 
		
		//float test[10] = { 2.2368574142456, 2.0947415828705, 2.4590134620667, 1.9261083602905, 2.7772326469421, 1.9098069667816, 2.1310169696808, 1.6191737651825, 1.7091503143311, 2.1181514263153 }; 
		
		
		
	}
	
	
	//calls to compare probability of different states
	
	
	
	
	
	
    return 0;
}
