//This code is part of an extension set for SuperCollider 3 (http://supercollider.sourceforge.net/). We follow the same license terms for SuperCollider 3, releasing under GNU GPL 3 
//all non-GHMM code here by Nick Collins http://www.cogs.susx.ac.uk/users/nc81/index.html
//GHMM code from http://home.gna.org/dhmm/ and by Daniel Roggen, modified BSD, license at top of the dhmm.h and .cpp files


#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "dhmm.h"



//arguments
//mode 0 create and train
//0, int numstates, int numsymbols, input filename (training sequences), out model filename

//mode 1 generate state sequence:
//1, model filename, output filename 

//mode 2 most likely state sequence given observation sequence:
//2, model filename, input filename, output filename 

//mode 3 observation sequence probability 
//3, model filename, input filename, output filename 


//can also calculate probability of a given state sequence; may need to pass a set of them, to find most likely


int main (int argc, char * const argv[]) {
 
    int i,j;
    
	DHMM *hmm;
    
    //unsigned int nbData=0;
	//char filename[256];
	
	int calltype = atoi(argv[1]); 	
	
	int numstates; //number hidden states
	int numsymbols; //number of observable symbols (assumes discrete observation data, eg vector quantised feature vectors into single nonnegative integers)
    
	if (calltype ==0) {
		
		numstates = atoi(argv[2]); 	
		numsymbols = atoi(argv[3]); 	
        
        //std::cout << "numstates" << numstates << " "  << "numsymbols" << numsymbols << std::endl; 
		
        
        hmm = new DHMM(numstates, numsymbols); 
        
        
        //hmm->Print();
        
        
		//sprintf(filename,argv[3]); //"/Applications/SuperCollider/SuperCollider3.4/gmminput.temp");

		std::cout << "Learning the HMM model" << std::endl; 
		
        //dataset = g.loadDataFile(filename); 	
		
        //LOAD TRAINING DATA
        
		//sprintf(filename,argv[4]); //"/Applications/SuperCollider/SuperCollider3.4/gmminput.temp");
		
        FILE * fpinput;
		
		fpinput = fopen(argv[4], "rb");
		
		//float * inputdata = new int[numfeatures]; 
		
        int numsequences; 
        
		fread(&numsequences, sizeof(int), 1, fpinput);
		
        vector<Observation> obsinput; 
        
        for (i=0; i<numsequences; ++i) {
                
            int seqlength; 
            
            fread(&seqlength, sizeof(int), 1, fpinput);
            
            unsigned int * pint = new unsigned int[seqlength]; 
            //int * pint = new int[seqlength]; 
            
            fread(pint, sizeof(unsigned int), seqlength, fpinput);
            
            vector<unsigned int> vec; 
            
            vec.assign(pint, pint + seqlength);
            
            obsinput.push_back(vec); 
            
            delete [] pint; 
            
        };
        
		fclose(fpinput); 

        
       // cout << obsinput << nl; 
        
//        vector<Observation>::iterator itr2; 
//       
//        for ( itr2 = obsinput.begin(); itr2 < obsinput.end(); ++itr2 ) {
//            
//            Observation::iterator itr;
//            
//            for ( itr = (*itr2).begin(); itr < (*itr2).end(); ++itr ) {
//                
//                int val = *itr; 
//                
//                cout << val << " ";
//                
//            }
//
//            cout << std::endl; 
//            
//        };
        
        
        int numstates = hmm->GetNumStates(); 
        
        for(int k=0; k<numstates; ++k) 
            hmm->GetState(k).Initialise();
    
        int numiterations = atoi(argv[6]);
        
        hmm->BaumWelch(obsinput,numiterations); 
        
        //hmm->test(); 

        //hmm->Print();
        
        //need to have vector<Observation>
        //sprintf(filename,argv[5]); //"/Applications/SuperCollider/SuperCollider3.4/gmminput.temp");
		        
        std::cout << "saving the result to " << argv[5] << std::endl;

		hmm->Save(argv[5]);
		std::cout << "ok" << std::endl;
	} 
	
	else if (calltype ==1) {
        
        //sprintf(filename,argv[2]); 
		
        hmm = new DHMM(1,1); 
        
		hmm->Load(argv[2]);	
		
        //hmm->Print();
        
        int steps = atoi(argv[3]); 
        
        //typedef vector<Symbol> Observation;
        
        Observation obs = hmm->GenerateSequence(steps); 
        
        FILE * fpoutput = fopen(argv[4], "wb");
		
        int size = obs.size(); 
        
        fwrite(&size, sizeof(int), 1, fpoutput);
        
        Observation::iterator itr;
        
        for ( itr = obs.begin(); itr < obs.end(); ++itr ) {
            
            int val = *itr; 
            
            fwrite(&val, sizeof(int), 1, fpoutput);
        
        }
        
		//std::cout << "\n " << argv[3] << " "; 
		//fwrite(&minindex, sizeof(int), 1, fpoutput); 
		
		//fwrite(probs, sizeof(float), numstates, fpoutput); 
		
		fclose(fpoutput); 

    }
    
    //Viterbi, find best matching hidden state sequence
    else if (calltype ==2) {

        
        hmm = new DHMM(1,1); 
        
		hmm->Load(argv[2]);	
		
        FILE * fpinput;
		
		fpinput = fopen(argv[3], "rb");
		
        int seqlength; 
        
        fread(&seqlength, sizeof(int), 1, fpinput);
        
        unsigned int * pint = new unsigned int[seqlength]; 

        fread(pint, sizeof(unsigned int), seqlength, fpinput);
        
        vector<unsigned int> vec; 
        
        vec.assign(pint, pint + seqlength);

        delete [] pint; 

		fclose(fpinput);
        
        //typedef vector<Symbol> Observation;
        
        Observation obs = hmm->GetProbableStateSequence(vec); 
        
        FILE * fpoutput = fopen(argv[4], "wb");
		
        int size = obs.size(); 
        
        fwrite(&size, sizeof(int), 1, fpoutput);
        
        Observation::iterator itr;
        
        for ( itr = obs.begin(); itr < obs.end(); ++itr ) {
            
            int val = *itr; 
            
            fwrite(&val, sizeof(int), 1, fpoutput);
            
        }
        
    }
        
        else if (calltype ==3) {
 
            hmm = new DHMM(1,1); 
            
            hmm->Load(argv[2]);	
            
            FILE * fpinput;
            
            fpinput = fopen(argv[3], "rb");
            
            int seqlength; 
            
            fread(&seqlength, sizeof(int), 1, fpinput);
            
            unsigned int * pint = new unsigned int[seqlength]; 
            
            fread(pint, sizeof(unsigned int), seqlength, fpinput);
            
            vector<unsigned int> vec; 
            
            vec.assign(pint, pint + seqlength);
            
            delete [] pint; 
            
            fclose(fpinput);
            
            //typedef vector<Symbol> Observation;
            
            //or should be log prob? 
            double prob = hmm->GetObservationSequenceProbability(vec);
             
            FILE * fpoutput = fopen(argv[4], "wb");

            fwrite(&prob, sizeof(double), 1, fpoutput);
             
			fclose(fpoutput); 
		
	}
	
	
	//calls to compare probability of different states
	
	
	delete hmm; 
	
	
	
    return 0;
}
