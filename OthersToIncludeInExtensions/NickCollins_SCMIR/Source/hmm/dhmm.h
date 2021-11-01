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

#ifndef __DHMM_H
#define __DHMM_H

#include <vector>

using namespace std;

typedef unsigned int Symbol;
#define NoSymbol ((Symbol)(unsigned int)-1)

typedef vector<Symbol> Observation;
typedef vector<double> vectord;
typedef vector<int> vectori;



struct State
{
   State(unsigned numstates,unsigned numsymbols);
//   State(const State&);

   unsigned NumStates;
   unsigned NumSymbols;

   unsigned ID;
   vector<double> ObservationProbability;

   /*
      Alternative storage:
         // Only the existing transitions are stored in vectors.
            vector<double> TransitionProbability;
            vector<unsigned> TransitionState;

         // Only the existing transitions are stored in a map.
            map<unsigned,double> TransitionProbability;

         // All the transitions are stored. Those that do not exist have 0 probability.
            vector<double> TransitionProbability;

         // Distinguish existing low probability transitions (Exist=true) and no transitions (Exist=false).
            vector<double> TransitionProbability;
            vector<bool> TransitionProbabilityExist;
   */
   vector<double> TransitionProbability;
   //vector<unsigned> TransitionState;
   vector<bool> TransitionExist;

   
   virtual void Print();
   // This should reset the transitions and obs prob (i.e. no obs, no trans?)
   virtual void Clear();

    //Nick Collins addition for convenience to avoid problem states when training
   virtual void Initialise(); //set to near equal transition and emission probabilities
    
   virtual inline void SetObservationProbability(unsigned obs,double p) {ObservationProbability[obs]=p;};
   virtual void SetTransitionProbability(unsigned to,double p);
   virtual void NormalizeObservation();
   virtual void NormalizeTransition();
   virtual void Normalize(vector<double> &v);
};

//vector <vector<int> > mat;

class Tensor
{
   private:
   	vector<double> data;
	   unsigned X,Y,Z;

   public:
   	Tensor(unsigned x,unsigned y,unsigned z);
	   virtual double get(unsigned x,unsigned y,unsigned z);
   	virtual void set(unsigned x,unsigned y,unsigned z,double v);
   	virtual void resize(unsigned x,unsigned y,unsigned z);
   	virtual void Print();
};


class DHMM
{
   private:

      unsigned NumStates;
      unsigned NumSymbols;
      unsigned CurrentState;

      vector <State> States;

//      vector<vectord> TransitionProbability;    // Probability of transition from state i to j
//      vector<vectori> TransitionState;          // State number after the transition

      virtual Symbol GenerateObservation(State s);
      virtual unsigned GenerateTransition(State s);

      virtual unsigned GenerateFirstState();

      // Store locally the alpha and beta for all i,t in order to efficiently compute xi and gamma
      // Format: matrix[t][i];
		vector<vector<double> > alphamatrix;
		vector<vector<double> > betamatrix;
		
		// Format: matrix[t][i][j]
      //Tensor ximatrix;


   public:
   	vector<vector<double> > gammamatrix;
   	// Format: matrix[t][i][j]
   	Tensor ximatrix;
   
      DHMM(int numstates,int numsymbols);
      virtual ~DHMM();

      vector<double> StartingStateProbabilities;

      int toto;

      void test();

      virtual void Resize(int numstates,int numsymbols);
      
      virtual unsigned GetCurrentState() {return CurrentState;};
      virtual void AddState(State s);
      virtual State &GetState(unsigned n);
      virtual State &operator[](unsigned n);

      virtual double Normalize(vector<double> &v, bool force=false);
      virtual void Normalize(vector<vector<double> > &v);
      
      virtual unsigned GetNumStates() { return NumStates;};
      virtual unsigned GetNumSymbols() { return NumSymbols;};
      
      virtual void Save(char *file);
      virtual void Load(char *file);


      // The basic stuff
      virtual double GetStateSequenceProbability(vector<unsigned int> s);
      // Forward algorithm
      virtual double GetObservationSequenceProbability(Observation obs);
      virtual double GetObservationSequenceProbabilityL(Observation obs);		// Log version
      // Viterbi algorithm
      virtual Observation GetProbableStateSequence(Observation obs);
      virtual Observation GetProbableStateSequence(Observation obs,double &prob);
      // Baum-Welch
      virtual double BaumWelch(Observation obs,unsigned max_iter=1);
      virtual double BaumWelch(vector<Observation> obs,unsigned max_iter=1);
      
      

      virtual void Reset();

      virtual double Forward(unsigned t,unsigned i,Observation obs);
      virtual void Forward(Observation obs);
      virtual double Backward(unsigned t,unsigned i,Observation obs);
      virtual void Backward(Observation obs);
      
      virtual double xi(unsigned i,unsigned j,unsigned t,Observation obs);
      void xi(Observation obs);
      void gamma(Observation obs);

		virtual void PrintAlpha();
		virtual void PrintBeta();
		virtual void Print();


      virtual Observation GenerateSequence(int length,Observation &states);
      virtual Observation GenerateSequence(int length);

      virtual double frand();
};



#endif
