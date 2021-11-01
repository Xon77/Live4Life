/*
 *  ffnet.cpp
 *  NeuralNet
 *
 *  Created by Chris Kiefer on 05/11/2007.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "ffnet.h"
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <iostream>
#include <iomanip>

using namespace std;

//generates a psuedo-random double between 0.0 and max
inline double randdouble(double max)
{
    return rand()/(double(RAND_MAX)+1) * max;
} 

inline double sigmoid (double val) {
	 return 1 / (1.0 + exp(-1 * val));
}

/*
Initialise the network
*/
void FeedForwardNetwork::init(int nIn, int nHidden, int nOut, double learningRate, double initWeight)
{
	this->nIn = nIn;
	this->nHidden = nHidden;
	this->nOut = nOut;
	this->learningRate = learningRate;
	this->initWeight = initWeight;
	
	//reserve some memory
	biasH = new double[nHidden];
	outputH = new double[nHidden];
	dh = new double[nHidden];
	biasO = new double[nOut];
	outputO = new double[nOut];
	dk = new double[nOut];
	weightsH = new double* [nHidden];
	weightsO = new double* [nOut];
	
	//init weights etc
	srand((unsigned)(time(0))); 
	int i,j;
	for(i=0; i<nHidden; i++) {
		double * weightSet = new double[nIn];
		for(j=0; j<nIn; j++) {weightSet[j] = randdouble(initWeight * 2) - initWeight;}
		weightsH[i] = weightSet;
		biasH[i] = randdouble(initWeight * 2) - initWeight;
	}
	for(i=0; i<nOut; i++) {
		double * weightSet = new double[nHidden];
		for(j=0; j<nHidden; j++) {weightSet[j] = randdouble(initWeight * 2) - initWeight;}
		weightsO[i] = weightSet;
		biasO[i] = randdouble(initWeight * 2) - initWeight;
	}
}

double* FeedForwardNetwork::calculate(double *inputs)
{
	double unitInput;
	for(int i = 0; i < nHidden; i++) {
		unitInput = 0.0;
		//sum inputs and weights
		for(int j=0; j<nIn; j++) {
			unitInput += (inputs[j] * weightsH[i][j]);
		}
		unitInput += biasH[i];
		outputH[i] = sigmoid(unitInput);
	}
	for(int i = 0; i < nOut; i++) {
		unitInput = 0.0;
		//sum inputs and weights
		for(int j=0; j<nHidden; j++) {
			unitInput += (outputH[j] * weightsO[i][j]);
		}
		unitInput += biasO[i];
		outputO[i] = sigmoid(unitInput);
	}

	return outputO;
}

/*
Train the network with one example
*/
void FeedForwardNetwork::train1(double *inputs, double *target)
{
	double* output = calculate(inputs);
	double tmp, tmp2;
	
	for(int i = 0; i < nOut; i++) {
		tmp = output[i];
		dk[i] = tmp * (1 - tmp) * (target[i] - tmp);
	}
	
	for(int i = 0; i < nHidden; i++) {
		tmp2 = 0.0;
		for (int j=0; j < nOut; j++) {
			tmp2 += (weightsO[j][i] * dk[j]);
		}
		tmp = outputH[i];
		dh[i] = tmp * (1 - tmp) * tmp2;
	}
	
	for(int i = 0; i < nHidden; i++) {
		tmp2 = learningRate * dh[i];
		for(int j=0; j < nIn; j++) {
			tmp = weightsH[i][j];
			weightsH[i][j] = tmp + (tmp2 * inputs[j]);
		}
	}
	
	for(int i = 0; i < nOut; i++) {
		tmp2 = learningRate * dk[i];
		for(int j=0; j < nHidden; j++) {
			tmp = weightsO[i][j];
			weightsO[i][j] = tmp + (tmp2 * outputH[j]);
		}
	}
	
	for (int i = 0; i < nHidden; i++) {
		biasH[i] += (dh[i] * learningRate);
	}

	for (int i = 0; i < nOut; i++) {
		biasO[i] += (dk[i] * learningRate);
	}
	
}

/*
For testing
*/
void showArray(double f[], int len)
{
	cout << "[";
	for(int k=0; k<len;k++){
		cout << f[k] << ",";
	}
	cout << "]\n";
}

/*
Train the network with a set of examples
*/
void FeedForwardNetwork::train(double** inputs, double** targets, int numTrainingSets, double errorTarget, double maxEpochs)
{
	double error = 2.0 * errorTarget;
	double errorTotal;
	int epoch = 0;
	while (1) {
		errorTotal = 0.0;
		for (int i = 0; i < numTrainingSets; i++) {
			train1(inputs[i], targets[i]);
			for(int out=0; out<nOut; out++) {
				double outputError = outputO[out] - targets[i][out];
				outputError = outputError * outputError;
				errorTotal += outputError;
			}
		}
		error = errorTotal;
		cout << "Epoch: " << epoch << ",  Error: " << errorTotal << endl;
		epoch++;
		if ((epoch >= maxEpochs) || (error < errorTarget)) {
			break;
		}
	}
}

/*
For testing
*/
void FeedForwardNetwork::viewNN()
{
	cout << "Weights: ";
	for(int i=0;i<nHidden;i++) {showArray(weightsH[i],nIn);}
	cout << "BiasH: ";
	showArray(biasH, nHidden);
	cout << "dh: ";
	showArray(dh, nHidden);
	cout << "outputH: ";
	showArray(outputH, nHidden);
	cout << "WeightsO: ";
	for(int i=0;i<nOut;i++) {showArray(weightsO[i],nHidden);}
	cout << "BiasO: ";
	showArray(biasO, nOut);
	cout << "dk: ";
	showArray(dk, nOut);
	cout << "outputO	: ";
	showArray(outputO, nOut);
}

/*
Output the values of the weights and biases
*/
void FeedForwardNetwork::dumpNN()
{
	for(int i=0;i<nHidden;i++) {
		for(int j = 0; j < nIn; j++) {
			cout << setprecision(15) << weightsH[i][j] << endl;
		}
	}
	for(int i=0;i<nHidden;i++) {
		cout << setprecision(15) << biasH[i] << endl;
	}
	for(int i=0;i<nOut;i++) {
		for(int j = 0; j < nHidden; j++) {
			cout << setprecision(15) << weightsO[i][j] << endl;
		}
	}
	for(int i=0;i<nOut;i++) {
		cout << setprecision(15) << biasO[i] << endl;
	}
}


