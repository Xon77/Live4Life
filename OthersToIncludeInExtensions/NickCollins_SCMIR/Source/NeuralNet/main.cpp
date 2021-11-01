/*
 *  main.cpp
 *  NeuralNet
 *
 *  Created by Chris Kiefer on 05/11/2007.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 * This code passes commands and data to the neural network
 *
 */
 
#include <iostream>
#include <string>
#include <sstream>
#include "ffnet.h"

using namespace std;

FeedForwardNetwork *net;

//string to int, see http://www.codeguru.com/forum/showthread.php?t=231054
template <class T>
bool from_string(T& t, 
                 const std::string& s, 
                 std::ios_base& (*f)(std::ios_base&))
{
  std::istringstream iss(s);
  return !(iss >> f >> t).fail();
}

void init(int getInitWeight) throw(int)
{
	string input;
	int nIn, nHidden, nOut;
	double learningRate, initWeight = 1.0;
	//num inputs
	cin >> input;
	if(!from_string<int>(nIn, input, std::dec)) {throw(-1);	}
	cin >> input;
	if(!from_string<int>(nHidden, input, std::dec)) {throw(-1);	}
	cin >> input;
	if(!from_string<int>(nOut, input, std::dec)) {throw(-1);	}
	cin >> input;
	if(!from_string<double>(learningRate, input, std::dec)) {throw(-1);	}
	if (getInitWeight == 1) {
		cin >> input;
		if(!from_string<double>(initWeight, input, std::dec)) {throw(-1);	}
	};
	
	net->init(nIn, nHidden, nOut, learningRate, initWeight);
	
	cout << "initialised\n";
}

void calculate() throw(int)
{
	string input;
	double *inputs = new double[net->nIn];
	for(int i = 0; i < net->nIn; i++) {
		cin >> input;
		if(!from_string<double>(inputs[i], input, std::dec)) {throw(-1);	}
	}
	cout << "calculating...\n";
	
	double* result = net->calculate(inputs);
	
	cout << "Result: [";
	for(int i = 0; i < net->nOut; i++) {
		cout << (i>0?",":"");
		cout << result[i];
	}
	cout << "]" << endl;
}

void train1() throw(int)
{
	string input;
	double *inputs = new double[net->nIn];
	for(int i = 0; i < net->nIn; i++) {
		cin >> input;
		if(!from_string<double>(inputs[i], input, std::dec)) {throw(-1);	}
	}
	double *targets = new double[net->nOut];
	for(int i = 0; i < net->nOut; i++) {
		cin >> input;
		if(!from_string<double>(targets[i], input, std::dec)) {throw(-1);	}
	}
	
	cout << "training...\n";
	net->train1(inputs,targets);
	cout << "trained\n";
	
}

void train() throw(int)
{
	string input;
	int sets, maxEpochs;
	double errorTarget;
	cin >> input;
	if(!from_string<int>(maxEpochs, input, std::dec)) {throw(-1);}
	cin >> input;
	if(!from_string<double>(errorTarget, input, std::dec)) {throw(-1);}
	cin >> input;
	if(!from_string<int>(sets, input, std::dec)) {throw(-1);}

	double **inputs = new double* [sets];
	double **targets = new double* [sets];
	
	for(int set = 0; set < sets; set++) {
		double *inputVector = new double[net->nIn];
		inputs[set] = inputVector;
		for(int i = 0; i < net->nIn; i++) {
			cin >> input;
			if(!from_string<double>(inputVector[i], input, std::dec)) {throw(-1);	}
		}

		double *targetVector = new double[net->nOut];
		targets[set] = targetVector;
		for(int i = 0; i < net->nOut; i++) {
			cin >> input;
			if(!from_string<double>(targetVector[i], input, std::dec)) {throw(-1);	}
		}
	}
	
	cout << "training...\n";
	net->train(inputs, targets, sets, errorTarget, maxEpochs);
	cout << "trained\n";
}

/*
Specify the weights and biases
*/
void set() throw (int)
{
	init(0);
	string input;
	double val;
	cout << "Loading network values\n";
	for(int i = 0; i < net->nHidden; i++) {
		for(int j = 0; j < net->nIn; j++) {
			cin >> input;
			if(!from_string<double>(val, input, std::dec)) {throw(-1);	}
			net->weightsH[i][j] = val;
			cout << val << endl;
		}
	}
	for(int i = 0; i < net->nHidden; i++) {
		cin >> input;
		if(!from_string<double>(val, input, std::dec)) {throw(-1);	}
		net->biasH[i] = val;
			cout << val << endl;
	}
	for(int i = 0; i < net->nOut; i++) {
		for(int j = 0; j < net->nHidden; j++) {
			cin >> input;
			if(!from_string<double>(val, input, std::dec)) {throw(-1);	}
			net->weightsO[i][j] = val;
			cout << val << endl;
		}
	}
	for(int i = 0; i < net->nOut; i++) {
		cin >> input;
		if(!from_string<double>(val, input, std::dec)) {throw(-1);	}
		net->biasO[i] = val;
			cout << val << endl;
	}
	cout << "Loaded\n";
	net->viewNN();
}

int main (int argc, char * const argv[]) {
    // insert code here...
    std::cout << "Neural Network v0.1\n";
	net = new FeedForwardNetwork;

	string cmd;
	int loop=1;

	//process commands
	while(loop) {
		cin >> cmd;
		if (cmd.compare("quit") == 0) {
			loop=0;
		}
		else 
		if (cmd.compare("init") == 0) {
			init(1);
		}
		else
		if (cmd.compare("calc") == 0) {
			calculate();
		}
		else
		if (cmd.compare("train1") == 0) {
			train1();
		}
		else
		if (cmd.compare("train") == 0) {
			train();
		}
		else
		if (cmd.compare("set") == 0) {
			set();
		}
		else
		if (cmd.compare("view") == 0) {
			net->viewNN();
		}
		else
		if (cmd.compare("dump") == 0) {
			net->dumpNN();
		}
		else
		{
			cout << "Sorry i don't understand\n";
		}
	};
	
    return 0;
}

