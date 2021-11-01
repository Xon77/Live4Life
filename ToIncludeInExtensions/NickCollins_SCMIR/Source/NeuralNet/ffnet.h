/*
 *  ffnet.h
 *  NeuralNet
 *
 *  Created by Chris Kiefer on 05/11/2007.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */
 
class FeedForwardNetwork
{
	public:
	
		int nIn, nHidden, nOut;
		double learningRate, initWeight;
		
		double *biasH, *biasO;
		double **weightsH;
		double **weightsO;
		double *outputH, *outputO;
		double *dk, *dh;
	
		void init(int nIn, int nHidden, int nOut, double learningRate, double initWeight);
		double* calculate(double *inputs);
		void train1(double *inputs, double *target);
		void train(double** inputs, double** targets, int numTrainingSets, double errorTarget, double maxEpochs);
		void viewNN();
		void dumpNN();
};