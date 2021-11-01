/*
	DHMM - Discrete Hidden Markov Model library
	Copyright (C) 2006-2009:
			Daniel Roggen, droggen@gmail.com
			Institute für Elektronik, ETH Zürich, Switzerland
							
	
	All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*
   Assumption:
   - Probabilities sum up to 1 (transition or observations)
   - No dead states (i.e. states without observations).
      - [Can we have states without observations??]
   - Always a transition in a state... no states without transitions (end states?)
   - Never more than one transition to another identical state
   - At least one state (for Viterbi)


*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#pragma hdrstop; 

#include "dhmm.h"

inline double randomdouble()
{
    return ((double)rand())/((double)RAND_MAX);
}


Tensor::Tensor(unsigned x,unsigned y,unsigned z)
{
	resize(x,y,z);
}
void Tensor::resize(unsigned x,unsigned y,unsigned z)
{
	X=x;
	Y=y;
	Z=z;	
	
	data.clear();
	data.resize(X*Y*Z,0.0);
}
double Tensor::get(unsigned x,unsigned y,unsigned z)
{
	return data[z*Y*X+y*X+x];
}
void Tensor::set(unsigned x,unsigned y,unsigned z,double v)
{
   data[z*Y*X+y*X+x]=v;
}
void Tensor::Print()
{
	for(unsigned x=0;x<X;x++)	// this is the T in the impl... just print in this order to compare to matlab
	{
		printf("t=%d\n",x);
		for(unsigned y=0;y<Y;y++)
		{
			for(unsigned z=0;z<Z;z++)
				printf("%lf \t",get(x,y,z));
			printf("\n");
		}				
		//printf("\n");
	}
}


/*******************************************************************************
********************************************************************************

class State   class State   class State   class State   class State   class Stat

********************************************************************************
*******************************************************************************/


State::State(unsigned numstates,unsigned numsymbols)
{
   NumStates = numstates;
   NumSymbols = numsymbols;
   
   //printf("State(%p) %d\n",this,numsymbols);

   Clear();
}

/*State::State(const State &s)
{
   printf("copy const\n");
}*/
void State::Print()
{
   printf("State(%p) ID %d\n",this,ID);
   printf("ObservationProbability(%d): ",ObservationProbability.size());
   for(unsigned i=0;i<ObservationProbability.size();i++)
      printf("%.05lf ",ObservationProbability[i]);
   printf("\n");
   printf("TransitionProbability(%d):  ",TransitionProbability.size());
   for(unsigned i=0;i<TransitionProbability.size();i++)
      printf("%.05lf ",TransitionProbability[i]);
   printf("\n");
   printf("TransitionExist(%d):        ",TransitionExist.size());
   for(unsigned i=0;i<TransitionExist.size();i++)
      printf("%d       ",(int)TransitionExist[i]);
   printf("\n");
   /*printf("TransitionState(%d): ",TransitionState.size());
   for(unsigned i=0;i<TransitionState.size();i++)
      printf("%d ",TransitionState[i]);
   printf("\n");*/
}

void State::SetTransitionProbability(unsigned to,double p)
{
   // Only the existing transitions are stored in vectors.
//   TransitionProbability.push_back(p);
//   TransitionState.push_back(to);

   // Distinguish existing low probability transitions (Exist=true) and no transitions (Exist=false).
   TransitionProbability[to] = p;
   TransitionExist[to] = true;
};
void State::Clear()
{
   ObservationProbability.clear();
   ObservationProbability.resize(NumSymbols,0.0);

   TransitionProbability.clear();
   TransitionProbability.resize(NumStates,0);
   TransitionExist.clear();
   TransitionExist.resize(NumStates,false);
}

void State::Initialise() {
    
    int i; 
    
    double recip1 = 1.0/NumStates; 
    double recip2 = 1.0/NumSymbols;
    
    for (i=0; i<NumStates; ++i) 
        SetTransitionProbability(i,recip1 + randomdouble()); 
    
    for (i=0; i<NumSymbols; ++i) 
        ObservationProbability[i] = recip2+ randomdouble();
    
    NormalizeObservation(); 
    NormalizeTransition(); 
    
}


void State::NormalizeObservation()
{
	Normalize(ObservationProbability);
}
void State::NormalizeTransition()
{
	Normalize(TransitionProbability);
}
void State::Normalize(vector<double> &v)
{
	double sum=0;
	double mult;

	for(unsigned i=0;i<v.size();i++)
		sum+=v[i];
	if(sum!=0)
	{
		mult = 1.0/sum;					// Inverse of division, because not sure the compiler will get it to optimize
		for(unsigned i=0;i<v.size();i++)
			v[i]=v[i]*mult;
	}
}

/*******************************************************************************
********************************************************************************

class DHMM   class DHMM   class DHMM   class DHMM   class DHMM   class DHMM   cl

********************************************************************************
*******************************************************************************/

DHMM::DHMM(int numstates,int numsymbols) : ximatrix(1,1,1)
{
	Resize(numstates,numsymbols);

}
/*
	The clear are necessary to ensure with reinit all the elements of the vector with elements of the new size (e.g. for State, for the DHMM::Load function)
*/
void DHMM::Resize(int numstates,int numsymbols)
{
	NumStates = numstates;
   NumSymbols = numsymbols;
   CurrentState=0;   
   //printf("DHMM(%p) %d %d\n",this,numstates,numsymbols);

   States.clear();
   States.resize(numstates,State(numstates,numsymbols));
   for(unsigned i=0;i<NumStates;i++)
      States[i].ID=i;


   // By default we assume we start with state 0.
   StartingStateProbabilities.clear();
   StartingStateProbabilities.resize(numstates,0);
   StartingStateProbabilities[0]=1.0;
}

DHMM::~DHMM()
{

}
void DHMM::test()
{
   for(unsigned i=0;i<NumStates;i++)
   {
      printf("State %d. %p. %d\n",i,&(States[i]),States[i].ObservationProbability.size());
   }
}


void DHMM::Reset()
{
   CurrentState=0;
   
}
Symbol DHMM::GenerateObservation(State s)
{
   double r;
   double cr;
   unsigned i;

   //printf("in GenerateObservation\n");
   
   if(s.ObservationProbability.size()==0)
   {
      printf("No observations in this state!\n");
      return NoSymbol;
   }

   r = frand();
   // We have a random number uniformly distributed.
   for(i=0, cr=0.0;i<s.ObservationProbability.size();i++)
   {
      cr += s.ObservationProbability[i];
      if(r<cr)
      {
         return (Symbol)i;
      }
   }
   // At this stage: either the probabilities do not sum to 1 because of rounding errors
   // or there is effectively the possibility of not always outputting a symbol....
   //return NoSymbol;      // We can output no symbol
   printf("GenerateObservation: critical return\n");
   return (Symbol)i-1;       // We assume that we have rounding errors and we output the last one
}
unsigned DHMM::GenerateTransition(State s)
{
   double r;
   double cr;
   unsigned i;

   if(s.TransitionProbability.size()==0)
   {
      printf("No transitions in this state! Neither the self transition! Is it dead?\n");
      return NoSymbol;
   }

   r = frand();
   // We have a random number uniformly distributed.
   for(i=0, cr=0.0;i<s.TransitionProbability.size();i++)
   {
      if(s.TransitionExist[i] == false)
         continue;

      cr += s.TransitionProbability[i];
      if(r<cr)
      {
         //return s.TransitionState[i];      // Stored in Probability + State
         return i;                           // Stored in Probability + Exist
      }
   }
   // At this stage: either the probabilities do not sum to 1 because of rounding errors
   // or there is effectively the possibility of not always outputting a symbol....
   //return s.ID;             // No transitions... we assume that we stay in the same state
   //return s.TransitionState[i]; // We assume that we have rounding errors and we go in the last state.

   // BUG: potentially if rounding errors occur but the last state does not exist,
   // we can still go in that state due to this implementation (we should go in the last known existing state)
   printf("GenerateTransition: critical return\n");
   return i-1;

}
unsigned DHMM::GenerateFirstState()
{
   double r;
   double cr;
   unsigned i;

  // printf("DHMM::GenerateFirstState\n");

   r = frand();
//   printf("r: %f\n",r);
   for(i=0, cr=0.0;i<StartingStateProbabilities.size();i++)
   {
      cr += StartingStateProbabilities[i];
  //    printf("cr: %f\n",cr);
      if(r<cr)
         return i;
   }
   //printf("GenerateFirstState critical return. Returning %d\n",i);
   return i-1;		// We have to return i-1 to account for the last i++ in the for loop
}

Observation DHMM::GenerateSequence(int length,Observation &states)
{
   Observation obs;
   Symbol s;

   states.clear();
   
   obs.resize(length,0);
   states.resize(length,0);

   // Set the starting state.
   CurrentState = GenerateFirstState();
   //printf("DHMM::GenerateSequence starting in state %d\n",CurrentState);

   // Generate the sequence starting from CurrentState
   for(int i=0;i<length;i++)
   {
	   //printf("GenerateSequence. i: %d. CurrentState: %d. Len(obs): %d. Len(stat): %d\n",i,CurrentState,obs.size(),states.size());
      // Store the state which generates the observation
      states[i]=CurrentState;

      // Generate an observation
      obs[i]=GenerateObservation(States[CurrentState]);

      // Generate a transition
      CurrentState = GenerateTransition(States[CurrentState]);

   }
   return obs;
}
Observation DHMM::GenerateSequence(int length)
{
   Observation states;
   return GenerateSequence(length,states);
}

double DHMM::frand()
{
   double r;
   r=((double)rand())/((double)RAND_MAX);
   return r;
}

void DHMM::AddState(State s)
{
   States[s.ID] = s;
}

State &DHMM::GetState(unsigned n)
{
   return States[n];
}
State &DHMM::operator [](unsigned n)
{
   return States[n];
}

/*
   Compute the probability of a state sequence s.
   Example:
   S={S3,S3,S3,S1,S1,S3,S2,S3}
   P(S|model) = P[S3,S3,S3,S1,S1,S3,S2,S3|model)
         = P[S3] * P[S3|S3] * P[S3|S3] * P[S1|S3] * P[S1|S1] * P[S3|S1] * P[S2|S3] * P[S3|S2]
         = pi3 * a33 * a33 * a31 * a11 * a13 * a32 * a23
*/

/*
// Storage in Probability + State
double DHMM::GetStateSequenceProbability(vector<unsigned int> seq)
{
   double p;

   p = StartingStateProbabilities[seq[0]];
//   printf("p in start prob: %lf\n",p);
   for(unsigned i=1;i<seq.size();i++)
   {
      // We transition from state s[i-1] to state s[i].

      // We have to find in state s the transition to state id s[i].
      State &s = operator[](seq[i-1]);                                                                   // Get the previous state
      vector<unsigned>::iterator it = find(s.TransitionState.begin(),s.TransitionState.end(),seq[i]);    // Find if the transitions exists
      if(it==s.TransitionState.end())                                                                    // If not: impossible sequence
      {
         printf("Did not find transition from state %d to %d\n",seq[i-1],seq[i]);
         return 0.0;
      }
      //printf("offset: %d\n",it-s.TransitionState.begin());

      p*=s.TransitionProbability[it-s.TransitionState.begin()];                                          // If yes update probability
  }
  return p;
}*/
// Storage in Probability + Exist
double DHMM::GetStateSequenceProbability(vector<unsigned int> seq)
{
   double p;

   p = StartingStateProbabilities[seq[0]];
//   printf("p in start prob: %lf\n",p);
   for(unsigned i=1;i<seq.size();i++)
   {
      // We transition from state s[i-1] to state s[i].

      // We have to find in state s the transition to state id s[i].
      State &s = operator[](seq[i-1]);                                                                   // Get the previous state
      if(s.TransitionExist[seq[i]] == false)
      {
         printf("Did not find transition from state %d to %d\n",seq[i-1],seq[i]);
         return 0.0;
      }
      //printf("offset: %d\n",it-s.TransitionState.begin());

      p*=s.TransitionProbability[seq[i]];                                          // If yes update probability
  }
  return p;
}

/*
	Hardcore non-optimized alpha... should avoid it if possible.
	
   Returns the forward variable alphaT(I).
   Can be optimized since we compute anyway alphaT(for all i) so we could
   return alphaT(0), alphaT(1), ... alphaT(N-1)

   Also, if we need alphaT(i) and then alphaT+1(i) we could only do the incremental
   update from T to T+1... here we recompute from T=0.
*/
double DHMM::Forward(unsigned T,unsigned I,Observation obs)
{
   vector<double> alpha,alpha2;      // alpha: forward variable.
   double tp;

   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
   alpha.resize(NumStates,0.0);
   alpha2.resize(NumStates,0.0);

   // 1) Initialization
   // a1(i) = PIi * bi(O1) for 1<=i<=N
   for(unsigned i=0;i<NumStates;i++)
      alpha[i] = StartingStateProbabilities[i]*operator[](i).ObservationProbability[obs[0]];

   if(T==0)
      return alpha[I];

   // 2) Induction: find probabilities for time T+1 from time T
   for(unsigned t=1;t<T;t++)                 // Iterate all the observations (i.e. time steps)
   {
      for(unsigned i=0;i<NumStates;i++)      // Iterate the states at T+1
      {
         tp=0;
         for(unsigned j=0;j<NumStates;j++)   // Iterate the states at T
            tp+=alpha[j] * operator[](j).TransitionProbability[i];

         alpha2[i] = tp*operator[](i).ObservationProbability[obs[t]];
      }
      for(unsigned i=0;i<NumStates;i++)
         alpha[i]=alpha2[i];
   }
   return alpha[I];
}
/*
	In this implementation we compute all the forward variables and store them in the alphamatrix.
*/
void DHMM::Forward(Observation obs)
{
   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
   alphamatrix.resize(obs.size(), vector<double>(NumStates,0.0) );

   // 1) Initialization
   // a1(i) = PIi * bi(O1) for 1<=i<=N
   for(unsigned i=0;i<NumStates;i++)
      alphamatrix[0][i] = StartingStateProbabilities[i]*operator[](i).ObservationProbability[obs[0]];

   // 2) Induction: find probabilities for time T+1 from time T
   for(unsigned t=1;t<obs.size();t++)                 // Iterate all the observations (i.e. time steps)
   {
      for(unsigned j=0;j<NumStates;j++)      			// Iterate the states at T+1
      {
         alphamatrix[t][j] = 0.0;

         for(unsigned i=0;i<NumStates;i++)   			// Iterate the states at T
            alphamatrix[t][j] += alphamatrix[t-1][i] * operator[](i).TransitionProbability[j];
			
         alphamatrix[t][j] *= operator[](j).ObservationProbability[obs[t]];
      }
      

      Normalize(alphamatrix[t]); // norm just to try
    
   }


   // pfuiii!
}




/*
	Hardcore non-optimized beta

   Returns the backward variable betaT(I).
   Can be optimized to return a matrix!
*/
double DHMM::Backward(unsigned T,unsigned I,Observation obs)
{
   vector<double> beta,beta2;      // beta: backward variable.
   double tp;

   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
   beta.resize(NumStates,0.0);
   beta2.resize(NumStates,0.0);

   // 1) Initialization
   // betaT(i) = 1
   for(unsigned i=0;i<NumStates;i++)
      beta[i] = 1.0;						

   // 2) Induction: find probabilities for time T from time T+1
   for(int t=T-1;t>=t;t--)                 // Iterate all the observations (i.e. time steps)
   {
      for(unsigned i=0;i<NumStates;i++)      // Iterate the states at T+1
      {
         tp=0;
         for(unsigned j=0;j<NumStates;j++)   // Iterate the states at T
            tp+=operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t]] * beta[j];

         beta2[i] = tp;
      }
      for(unsigned i=0;i<NumStates;i++)
         beta[i]=beta2[i];
   }
   return beta[I];
}
/*
	In this implementation we compute all the forward variables and store them in the betamatrix.
	
*/
void DHMM::Backward(Observation obs)
{
   unsigned maxT;					// 

   maxT = obs.size()-1;
   
   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
	betamatrix.resize(obs.size(), vector<double>(NumStates,0.0) );
   
   // 1) Initialization
   // betaT(i) = 1
   for(unsigned i=0;i<NumStates;i++)
      betamatrix[maxT][i] = 1.0;						

   // 2) Induction: find probabilities for time T from time T+1
   for(unsigned t=maxT;t>=1;t--)                 // Iterate all the observations (i.e. time steps) (maxT or maxT-1??????????)
   {
      for(unsigned i=0;i<NumStates;i++)      // Iterate the states at T+1
      {
         betamatrix[t-1][i]=0;
         
         for(unsigned j=0;j<NumStates;j++)   // Iterate the states at T
            betamatrix[t-1][i]+=operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t]] * betamatrix[t][j];
      }
		Normalize(betamatrix[t-1]); // norm just to try
   }

}   
   	
/*******************************************************************************
GetObservationSequenceProbability
Seems OK with matlab HMM
TODO: normalization
*******************************************************************************/
double DHMM::GetObservationSequenceProbability(Observation obs)
{
   vector<double> alpha,alpha2;      // alpha: forward variable.
   double tp;

   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
   alpha.resize(NumStates,0.0);
   alpha2.resize(NumStates,0.0);

   // 1) Initialization
   // a1(i) = PIi * bi(O1) for 1<=i<=N
   for(unsigned i=0;i<NumStates;i++)
      alpha[i] = StartingStateProbabilities[i]*operator[](i).ObservationProbability[obs[0]];
      
	//for(unsigned i=0;i<NumStates;i++) printf("%f ",alpha[i]); printf("\n");

   // 2) Induction: find probabilities for time T+1 from time T
   for(unsigned t=1;t<obs.size();t++)        // Iterate all the observations (i.e. time steps)
   {
      for(unsigned i=0;i<NumStates;i++)      // Iterate the states at T+1
      {
         tp=0;
         for(unsigned j=0;j<NumStates;j++)   // Iterate the states at T
            tp+=alpha[j] * operator[](j).TransitionProbability[i];

         alpha2[i] = tp*operator[](i).ObservationProbability[obs[t]];
      }
      for(unsigned i=0;i<NumStates;i++)
         alpha[i]=alpha2[i];
		//for(unsigned i=0;i<NumStates;i++) printf("%f ",alpha[i]); printf("\n");
   }

   // 3) Termination: collect all the probabilities in alpha

   tp=0;
   for(unsigned i=0;i<NumStates;i++)
      tp+=alpha[i];

   return tp;


};
/*
	Returns log of probability
	Does only work when there is more than one observation (T>1)
	
	Seems to be correct.
	Could be optimized by removing the normalization at each iteration and comparing the sum with a threshold, and multiplying by a constant (e.g. EXP) all the factors and incrementing the scale. 
	For another time :)
*/
double DHMM::GetObservationSequenceProbabilityL(Observation obs)
{
   vector<double> alpha,alpha2;      // alpha: forward variable.
   double tp;
   double scale;
   double logscale;
   

   // alpha[i]: probability of observing the correct symbols up to current time
   // and ending up in state i.
   alpha.resize(NumStates,0.0);
   alpha2.resize(NumStates,0.0);
   
   scale = 1.0;
   logscale=0.0;

   // 1) Initialization
   // a1(i) = PIi * bi(O1) for 1<=i<=N
   for(unsigned i=0;i<NumStates;i++)
      alpha[i] = StartingStateProbabilities[i]*operator[](i).ObservationProbability[obs[0]];

	// we could also scale here... but overkill.
      
   // 2) Induction: find probabilities for time T+1 from time T
   for(unsigned t=1;t<obs.size();t++)        // Iterate all the observations (i.e. time steps)
   {
      for(unsigned i=0;i<NumStates;i++)      // Iterate the states at T+1
      {
         tp=0;
         for(unsigned j=0;j<NumStates;j++)   // Iterate the states at T
            tp+=alpha[j] * operator[](j).TransitionProbability[i];

         alpha2[i] = tp*operator[](i).ObservationProbability[obs[t]];
      }
      for(unsigned i=0;i<NumStates;i++)
         alpha[i]=alpha2[i];
		// here matlab normalizes alpha
		
		double tt=Normalize(alpha);
		//printf("t=%d. scale: %lf, tt: %lf\n",t,scale,tt);
		//scale *= tt;                // This generates errors in BC++
		logscale -= log(tt);
		
		//scale*=Normalize(alpha);
   }

   // 3) Termination: collect all the probabilities in alpha
	// But we know the sum is equal to one since we normalized, so all the info we need is in scale.
   //tp=0;
   //for(unsigned i=0;i<NumStates;i++)
      //tp+=alpha[i];

   // Normalize one final time, FORCING!
   //printf("scale: %lf\n",scale);
   double tt=Normalize(alpha,true);
   scale*=tt;
   logscale-=log(tt);

	//return -log(scale);
	return logscale;
   //return tp;


};

/*
   Viterbi
*/

/*
   Matches the matlab version as long as scaled=0 in the matlab viterbi implementation... ????
example:
   GetObservationSequenceProbabilityTest(0.1,0.2);
   hmm[0].SetObservationProbability(0,.9);
   hmm[0].SetObservationProbability(1,.1);
   hmm[0].SetTransitionProbability(0,1.0-p01);
   hmm[0].SetTransitionProbability(1,p01);

   hmm[1].SetObservationProbability(0,.1);
   hmm[1].SetObservationProbability(1,.9);
   hmm[1].SetTransitionProbability(1,1.0-p10);
   hmm[1].SetTransitionProbability(0,p10);

   hmm.StartingStateProbabilities[0]=.9;
   hmm.StartingStateProbabilities[1]=.1;

   sequence state/obs: 0011000011   
   
*/
Observation DHMM::GetProbableStateSequence(Observation obs,double &prob)
{
   Observation Path;
   vector<double> delta,delta2;
   vector<vector<unsigned> > psi;


   // delta t(i): best score (highest probability) along a single path at time t ending in state i
   delta.resize(NumStates,0.0);
   delta2.resize(NumStates,0.0);

   psi.resize(obs.size(),vector<unsigned>(NumStates,0));

   //printf("psi.size: %d\n",psi.size());
   //printf("psi[0].size: %d\n",psi[0].size());
   //printf("psi[0][0]: %d\n",psi[0][0]);



   // Initialisation
   for(unsigned i=0;i<NumStates;i++)
   {
      delta[i] = StartingStateProbabilities[i]*operator[](i).ObservationProbability[obs[0]];
      psi[0][i] = 0;
   }
   //printf("Initialisation\n");
   //printf("delta: ");
   //for(unsigned i=0;i<NumStates;i++)
   //   printf("%lf ",delta[i]);
   //printf("\n");


   // Recursion
   //printf("Recursion\n");
   for(unsigned t=1;t<obs.size();t++)        // Iterate the observations (time steps)
   {
      //printf("t=%d\n",t);
      for(unsigned i=0;i<NumStates;i++)      // Iterates the states at T+1
      {
         double p;
         unsigned argmax;

         p = -1;
         for(unsigned j=0;j<NumStates;j++)   // Find the most likely transition
         {
            double pt;
            pt = delta[j]*operator[](j).TransitionProbability[i];
            if(pt>p)
            {
               p=pt;
               argmax=j;
            }
         }
         // Store the highest probability
         delta2[i] = p*operator[](i).ObservationProbability[obs[t]];

         // Store the trace
         // should have all times...
         psi[t][i] = argmax;
      }
      for(unsigned i=0;i<NumStates;i++)
         delta[i]=delta2[i];

      //printf("delta: ");
      //for(unsigned i=0;i<NumStates;i++)
      //   printf("%lf ",delta[i]);
      //printf("\n");
      //printf("psi: ");
      //for(unsigned i=0;i<NumStates;i++)
      //   printf("%d ",psi[t][i]);
      //printf("\n");

   }


   // Termination.
   //printf("Termination\n");
   // We have the probabilities of all the path ending at time T in state i with correct observations; select the last hop.
   double P;                  // Overall probability of the state sequence
   unsigned argmax;           // Ending state
   P=-1;
   for(unsigned i=0;i<NumStates;i++)
   {
      if(delta[i]>P)
      {
         P=delta[i];
         argmax=i;
      }
   }

   // Path backtracking

   //printf("Path backtracking\n");
   Path.resize(obs.size(),0);

   //printf("Size of path: %d\n",Path.size());
   // psi[0] does not exist! data are [psi(1), psi(2)....psi(obs.size()), argmax].
   for(unsigned t=obs.size()-1;t>=1;t--)
   {
     // printf("t=%d, argmax: %d\n",t,argmax);
      Path[t] = argmax;
      argmax = psi[t][argmax];
   }
   Path[0]=argmax;


   //printf("Returning path\n");

   prob=P;
   return Path;
}
Observation DHMM::GetProbableStateSequence(Observation obs)
{
   double p;
   return GetProbableStateSequence(obs,p);
}



/*
	Returns xi(i,j) based on the forward and backward variables
	
	We can assume we preprocessed the input
*/
double DHMM::xi(unsigned i,unsigned j,unsigned t,Observation obs)
{
	//
	
	double num,den;
	
	//num = Forward(t,i,obs) * operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t+1]] * Backward(t+1,j,obs);

	num = alphamatrix[t][i] * operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t+1]] * betamatrix[t+1][j];

	
	den=0;
	for(unsigned ii=0;ii<NumStates;ii++)
	{
		for(unsigned jj=0;jj<NumStates;jj++)
		{
			//den += Forward(t,ii,obs)* operator[](ii).TransitionProbability[jj] * operator[](jj).ObservationProbability[obs[t+1]] * Backward(t+1,jj,obs);
			den += alphamatrix[t][ii]* operator[](ii).TransitionProbability[jj] * operator[](jj).ObservationProbability[obs[t+1]] * betamatrix[t+1][jj];
		}
	}
	
	return num/den;
	
}
/*
	Compute all the xi 3d matrix.
*/
void DHMM::xi(Observation obs)
{
	double num,den;
   
   // Create the xi matrix.
	ximatrix.resize(obs.size()-1,NumStates,NumStates);
	
	// Compute all the xi matrix entries
	//for(unsigned i=0;i<NumStates;i++)
	for(unsigned t=0;t<obs.size()-1;t++)
	{
		// Compute the denominator which is constant for a given t.
	
		den=0;
		for(unsigned ii=0;ii<NumStates;ii++)
		{
			for(unsigned jj=0;jj<NumStates;jj++)
			{	
				//den += Forward(t,ii,obs)* operator[](ii).TransitionProbability[jj] * operator[](jj).ObservationProbability[obs[t+1]] * Backward(t+1,jj,obs);
				den += alphamatrix[t][ii]* operator[](ii).TransitionProbability[jj] * operator[](jj).ObservationProbability[obs[t+1]] * betamatrix[t+1][jj];
			}
		}		
		
		
		//for(unsigned j=0;j<NumStates;j++)
		for(unsigned i=0;i<NumStates;i++)
		{
			//for(unsigned t=0;t<obs.size();t++)
			for(unsigned j=0;j<NumStates;j++)
			{
				//num = Forward(t,i,obs) * operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t+1]] * Backward(t+1,j,obs);
				num = alphamatrix[t][i] * operator[](i).TransitionProbability[j] * operator[](j).ObservationProbability[obs[t+1]] * betamatrix[t+1][j];
	
				ximatrix.set(t,i,j,num/den);
				
			}
		}
	}
}

void DHMM::gamma(Observation obs)
{
   // compute the gamma matrix
   // Compute it from Xi for t=1...T-1 and from alpha and beta for t=T

   //
   gammamatrix.resize(obs.size(), vector<double>(NumStates,0.0) );

   // t=1...T-1
   for(unsigned t=0;t<obs.size()-1;t++)
   {
      for(unsigned i=0;i<NumStates;i++)
      {
         double s;
         s=0.0;
         for(unsigned j=0;j<NumStates;j++)
         {
            s+=ximatrix.get(t,i,j);
         }
         gammamatrix[t][i] = s;
      }
   }
   // t=T
   double den;
   den=0.0;
   for(unsigned i=0;i<NumStates;i++)
			den+=alphamatrix[obs.size()-1][i]*betamatrix[obs.size()-1][i];
   for(unsigned i=0;i<NumStates;i++)
	   gammamatrix[obs.size()-1][i] = alphamatrix[obs.size()-1][i]*betamatrix[obs.size()-1][i]/den;	

   
}

/*
   Baum-Welch parameter reestimation procedure

   
   Beware: we handle only one observation currently. Handling more require changes.
   
   Before updating the b and a, we should compute the expected emissions, transitions, states for ALL observations and then 
   update the variables. To compute the expected emissions we need for each emission to recompute the xi and gamma variables.
   
*/
double DHMM::BaumWelch(Observation obs,unsigned max_iter)
{
	vector<Observation> obsvect(1,obs);
	
	return BaumWelch(obsvect,max_iter);
	
	
}
/*
	This version is working.... (just beware it works only with one observation)
	Commented out to try the new multi-observation method with a-posteriori normalizing.
*/
/*
double DHMM::BaumWelch(vector<Observation> obsvect)
{
   // Assume for now that we treat only the first observation
	Observation obs;
	
	obs=obsvect[0];

	// Initialize the new estimated model parameters
   vector<double> e_pi;
   vector<vector<double> > e_a;
   vector<vector<double> > e_b;

   e_pi.resize(NumStates,0);
   e_a.resize(NumStates,vector<double>(NumStates,0.0));
   e_b.resize(NumStates,vector<double>(NumSymbols,0.0));
   
   for(unsigned o=0;o<obsvect.size();o++)
   {
	   obs=obsvect[o];
	   
   
	
	   // Compute the tables that will be needed for the update
	   Forward(obs);
	   Backward(obs);
	   xi(obs);
	   gamma(obs);

   
	   // Reestimate pi
	   // As in Matlab: summation on all observations of the expected frequency in state Si at time t=1
	   // Will need to be normalized (somehow).
	   for(unsigned i=0;i<NumStates;i++)
	      e_pi[i] += gammamatrix[0][i];
	
	   // Reestimate transition probability
	   for(unsigned i=0;i<NumStates;i++)
	   {
	      double sg;
	      sg=0.0;
	      // Sum gammat(i) on all t
	      for(unsigned t=0;t<obs.size()-1;t++)
	         sg += gammamatrix[t][i];
			
			printf("sg: %lf\n",sg);
	         
	      for(unsigned j=0;j<NumStates;j++)
	      {
	         double sxi;
	         sxi=0.0;
	         for(unsigned t=0;t<obs.size()-1;t++)
	            sxi+=ximatrix.get(t,i,j);
	         e_a[i][j] = sxi/sg;
	      }
	   }
	
	   // Reestimate observation probability
	   for(unsigned j=0;j<NumStates;j++)
	   {
	      double den;
	
	      den=0.0;
	      for(unsigned t=0;t<obs.size();t++)			// We iterate till t because the gammamatrix luckily has been computed with a Dan's hack.
	         den += gammamatrix[t][j];
	
			// 
			printf("den(%d): %lf\n",j,den);
	         
	      for(unsigned k=0;k<NumSymbols;k++)
	      {
	         double num;
	         num=0.0;
	         //for(unsigned t=0;t<obs.size()-1;t++)
	         for(unsigned t=0;t<obs.size();t++)
	         {
	            if(obs[t] == k)
	               num+=gammamatrix[t][j];
	         }
	         e_b[j][k] = num/den;
	      }
	   }

	}		// For all observations
	
   // Copy the reestimated values
   // Actually this can be optimized because the trans, obs and pi can be modified in place since all is needed is in gamma and xi.
   
   // Pi
   for(unsigned i=0;i<NumStates;i++)
   	StartingStateProbabilities[i] = e_pi[i];
   	
   // aij
   for(unsigned i=0;i<NumStates;i++)
      for(unsigned j=0;j<NumStates;j++)
      	operator[](i).TransitionProbability[j] = e_a[i][j];

	// bj(k)
	for(unsigned i=0;i<NumStates;i++)
      for(unsigned k=0;k<NumSymbols;k++)
      	operator[](i).ObservationProbability[k] = e_b[i][k];
      	
	// Done!
 



   return 0.0;
}*/
/*
	Baum-Welch reestimation with multiple observation sequences and appropriate normalization in principle.
	
	Algorithm still matches Matlab with 1 observation sequence.
*/
double DHMM::BaumWelch(vector<Observation> obsvect,unsigned max_iter)
{
   // Assume for now that we treat only the first observation
	Observation obs;
	
	obs=obsvect[0];
	
	// we do here the big iteration loop.
	for(unsigned iter=0;iter<max_iter;iter++)
	{

	// Initialize the new estimated model parameters
   vector<double> e_pi;
   vector<vector<double> > e_a;
   vector<vector<double> > e_b;

   e_pi.resize(NumStates,0);
   e_a.resize(NumStates,vector<double>(NumStates,0.0));
   e_b.resize(NumStates,vector<double>(NumSymbols,0.0));
   
   for(unsigned o=0;o<obsvect.size();o++)
   {
	   obs=obsvect[o];
	   
   
	
	   // Compute the tables that will be needed for the update
	   Forward(obs);
	   Backward(obs);
	   xi(obs);
	   gamma(obs);

   
	   // Reestimate pi
	   // As in Matlab: summation on all observations of the expected frequency in state Si at time t=1
	   // Will need to be normalized (somehow).
	   for(unsigned i=0;i<NumStates;i++)
	      e_pi[i] += gammamatrix[0][i];
	
	   // Reestimate transition probability
	   for(unsigned i=0;i<NumStates;i++)
	   {
	      //double sg;
	      //sg=0.0;
	      // Sum gammat(i) on all t
	      //for(unsigned t=0;t<obs.size()-1;t++)
	      //   sg += gammamatrix[t][i];
			
			//printf("sg: %lf\n",sg);
	         
	      for(unsigned j=0;j<NumStates;j++)
	      {
	         double sxi;
	         sxi=0.0;
	         for(unsigned t=0;t<obs.size()-1;t++)
	            sxi+=ximatrix.get(t,i,j);
	         //e_a[i][j] = sxi/sg;
	         e_a[i][j] += sxi;
	      }
	   }
	
	   // Reestimate observation probability
	   for(unsigned j=0;j<NumStates;j++)
	   {
	      double den;
	
	      den=0.0;
	      for(unsigned t=0;t<obs.size();t++)			// We iterate till t because the gammamatrix luckily has been computed with a Dan's hack.
	         den += gammamatrix[t][j];
	
			// 
			//printf("den(%d): %lf\n",j,den);
	         
	      for(unsigned k=0;k<NumSymbols;k++)
	      {
	         double num;
	         num=0.0;
	         //for(unsigned t=0;t<obs.size()-1;t++)
	         for(unsigned t=0;t<obs.size();t++)
	         {
	            if(obs[t] == k)
	               num+=gammamatrix[t][j];
	         }
	         //e_b[j][k] = num/den;
	         e_b[j][k] += num;
	      }
	   }

	}		// For all observations
	
   // Normalization 
   // Expected frequency in the starting state
   Normalize(e_pi,true);		// Force normalization
   // e_a
   Normalize(e_a);		// e_a[i][j] -> sum on j should be 1 (we always undergo a state transition)
   // e_b
   Normalize(e_b);		// e_b[j][k] -> sum on k should be 1 (we always emit a symbol)
   
	
	
	// Copy the reestimated values
   // Actually this can be optimized because the trans, obs and pi can be modified in place since all is needed is in gamma and xi.
   
   // Pi
   for(unsigned i=0;i<NumStates;i++)
   	StartingStateProbabilities[i] = e_pi[i];
   	
   // aij
   for(unsigned i=0;i<NumStates;i++)
      for(unsigned j=0;j<NumStates;j++)
      	operator[](i).TransitionProbability[j] = e_a[i][j];

	// bj(k)
	for(unsigned i=0;i<NumStates;i++)
      for(unsigned k=0;k<NumSymbols;k++)
      	operator[](i).ObservationProbability[k] = e_b[i][k];
      	
	// Done!
 

	}	// end iter

   return 0.0;
}

void DHMM::PrintAlpha()
{
	printf("alpha: \n");
	for(unsigned i=0;i<NumStates;i++)
	{
		for(unsigned t=0;t<alphamatrix.size();t++)
			printf("%lf ",alphamatrix[t][i]);
		printf("\n");
	}
}
void DHMM::PrintBeta()
{
	printf("beta: \n");
	for(unsigned i=0;i<NumStates;i++)
	{
		for(unsigned t=0;t<betamatrix.size();t++)
			printf("%lf ",betamatrix[t][i]);
		printf("\n");
	}
}


/*
	Normalize the vector so that the sum of it's elements are 1.
	
	Returns the multiplication factor (inverse of normalization factor).
*/
double DHMM::Normalize(vector<double> &v,bool force)
{
	double sum=0;
	double mult;

   if(0)
   {

	for(unsigned i=0;i<v.size();i++)
		sum+=v[i];
	if(sum!=0)
	{
		mult = 1.0/sum;					// Inverse of division, because not sure the compiler will get it to optimize
		for(unsigned i=0;i<v.size();i++)
			v[i]=v[i]*mult;
		return mult;
	}
	else
		return 1.0;

   }
   else
   {

	for(unsigned i=0;i<v.size();i++)
		sum+=v[i];

   if( sum!=0 )
   {
      if(force==true)
      {
   		mult = 1.0/sum;					// Inverse of division, because not sure the compiler will get it to optimize
	   	for(unsigned i=0;i<v.size();i++)
		   	v[i]=v[i]*mult;
         return mult;
      }
      // Try if we can set a user threshold.... we can!! 
		//Anyway, Rabiner sucks: the normalization is _much_ easier than hinted (and correct, contrarily to his normalization)
		mult=1.0;
      while(sum<0.001)                          
      {
         for(unsigned i=0;i<v.size();i++)
        		v[i]=v[i]*100;
         mult*=100;
         sum*=100;
      }
      return mult;
   }
   return 1.0;
   }
}
/*
	Normalizes the matrix v[i][j] so that: Sum j=1..N(v[i][j]) = 1
	
*/
void DHMM::Normalize(vector<vector<double> > &v)
{
	for(unsigned i=0;i<v.size();i++)
		Normalize(v[i],true);	
}

/*
	Prints nicely the model
*/
void DHMM::Print()
{
	printf("--- HMM model %p. States: %d. Symbols: %d ---\n",this,NumStates,NumSymbols);
	
	printf("Starting probabilities:    ");
   for(unsigned i=0;i<StartingStateProbabilities.size();i++)
   	printf("%.05lf ",StartingStateProbabilities[i]);
   printf("\n");   
   for(unsigned i=0;i<NumStates;i++)
   	operator[](i).Print();
}

void DHMM::Save(char *file)
{
	FILE *f = fopen(file,"wt");
	
	fprintf(f,"%d %d\n",NumStates,NumSymbols);
	for(unsigned i=0;i<StartingStateProbabilities.size();i++)
   	fprintf(f,"%.15lf ",StartingStateProbabilities[i]);
   fprintf(f,"\n");
   for(unsigned s=0;s<NumStates;s++)
   {
   	//operator[](i).Print();
   	// states at this level
   	fprintf(f,"%d\n",operator[](s).ID);
   	for(unsigned i=0;i<operator[](s).ObservationProbability.size();i++)
      	fprintf(f,"%.15lf ",operator[](s).ObservationProbability[i]);
   	fprintf(f,"\n");
	   for(unsigned i=0;i<operator[](s).TransitionProbability.size();i++)
   	   fprintf(f,"%.15lf ",operator[](s).TransitionProbability[i]);
   	fprintf(f,"\n");
   	for(unsigned i=0;i<operator[](s).TransitionExist.size();i++)
      	fprintf(f,"%d ",(int)operator[](s).TransitionExist[i]);
      fprintf(f,"\n");
	}	
	fclose(f);
}
void DHMM::Load(char *file)
{
	double t;
	int ti;
	FILE *f = fopen(file,"rt");
	
	fscanf(f,"%d %d\n",&NumStates,&NumSymbols);
	
	Resize(NumStates,NumSymbols);
	
	//fclose(f);
	//return;
	
	for(unsigned i=0;i<StartingStateProbabilities.size();i++)
	{
   	fscanf(f,"%lf ",&t);
   	StartingStateProbabilities[i]=t;
	}
   for(unsigned s=0;s<NumStates;s++)
   {
   	// states at this level
   	fscanf(f,"%d\n",&operator[](s).ID);
   	for(unsigned i=0;i<operator[](s).ObservationProbability.size();i++)
   	{
      	fscanf(f,"%lf ",&t);
      	operator[](s).ObservationProbability[i]=t;
   	}
	   for(unsigned i=0;i<operator[](s).TransitionProbability.size();i++)
   	{
      	fscanf(f,"%lf ",&t);
      	operator[](s).TransitionProbability[i]=t;
   	}
   	for(unsigned i=0;i<operator[](s).TransitionExist.size();i++)
      {
      	fscanf(f,"%d ",&ti);
      	operator[](s).TransitionExist[i]=ti;
   	}
	}	
	fclose(f);
}


