//SuperCollider is under the GNU GPL; and so is this class.  
//Nick Collins Oct 2007

//fully connected MultilayerPerceptron (one hidden layer) trained through back propagation, online learning (updates after one training example and not after set)
//see Tom Mitchell, Machine Learning, McGraw-hill, 1996, p.98

//could precalculate large table for sigmoid function with interpolation? 

//biases for units can be represented as the 0th term; the input here is always 1, and only the weight is adjusted
//In this implementation, to avoid creating [1]++[input] every time, the biases are just represented as weights; but must still be updated according to backpropagation


NeuralNet {
	var <nin, <nhidden, <nout;  //fixed when network created
	var <>learningrate;
	var <>weightsh, <>weightso, <>biash, <>biaso;  //weights is an array of arrays   
	var <dk, <dh;  //for backpropagation algorithm
	var <input, <hiddenoutput, <output; //for calculation
	var <trainingepoch;
	var <>isTraining;
	
	classvar <>pathToNeuralNetBinary = "/usr/local/bin/";
	
	//added for SCMIR compatibility
	*initClass {
	
		Class.initClassTree(SCMIR);

		pathToNeuralNetBinary = SCMIR.executabledirectory; 
			
	}
	
	
	*new {arg nin, nhidden, nout, learningrate=0.05, initweight=0.05; 
	 	^super.newCopyArgs(nin, nhidden, nout, learningrate).initNeuralNet(initweight);
	 }
	 
	 *newExisting {arg params;
	 	^super.new.setNN(params);
	 } 
	 
	 //initialise weights randomly
	 initNeuralNet {|initweight|
	 	
		 //between -0.05 and 0.05 recommended
		 weightsh = Array.fill(nhidden,{Array.fill(nin,{initweight.rand2})});
		 weightso = Array.fill(nout,{Array.fill(nhidden,{initweight.rand2})});
		 
		 biash=Array.fill(nhidden,{initweight.rand2});
		 biaso=Array.fill(nout,{initweight.rand2});
		 
		 isTraining=false;
		 
	 }
	 
	 //test : (1 + (Array.fill(200,{|i| (i-100)/10}).neg.exp)).reciprocal.plot;
	 sigmoid {|val|
	 
	 ^(1.0 + (val.neg.exp)).reciprocal;
	 }
	 
	 //given an input, calculate the network output, uses sigmoid function for hidden and output layers
	 calculate {|inputdata|
		var unitinput;
		 
		input=inputdata;
		 
		hiddenoutput = Array.fill(nhidden, {|j|
			 
			//unitinput=0.0;
			 
//			[input, weightsh[j], input *weightsh[j], biash[j]].postln;
		
			unitinput = (input * weightsh[j]).sum + biash[j];
			
			this.sigmoid(unitinput); 
		});
		
		output = Array.fill(nout, {|j|
		 	
			//unitinput=0.0;
			 
			//[hiddenoutput, weightso[j], (hiddenoutput) * (weightso[j]) , biaso[j]].postln; 
			 
			unitinput = (((hiddenoutput) * (weightso[j]) ).sum) + (biaso[j]);
			
			//unitinput.postln;
			
			this.sigmoid(unitinput); 
		});
		
		^output;

	 }
	 
	 train1 {|inputdata, target|
	 	var tmp, tmp2;
	 	
	 	this.calculate(inputdata);
	 
	 	//now back propogation of error from output-target
	 	
	 	//errors
	 	dk= Array.fill(nout,{|k| tmp=output[k]; tmp*(1-tmp)*((target[k])-tmp)});
	 
	 	dh= Array.fill(nhidden,{|h| 
		 	
		 	tmp2=0.0;
		 	nout.do {|k| tmp2= tmp2+ ((weightso[k][h]) * (dk[k])); };
		 	
		 	tmp=hiddenoutput[h]; 
		 	
		 	tmp*(1-tmp)*(tmp2);

	 	});
	 
	 	//updates - can be made more efficient by multiplying arrays? 
	 
	 	weightsh = Array.fill(nhidden,{|h| tmp2=learningrate*(dh[h]);  
	 		
		 	Array.fill(nin,{|i| tmp= weightsh[h][i];

		 	tmp + (tmp2*(input[i]))  
		 	 
		 	});
		 	 
	 	 });
	 	weightso = Array.fill(nout,{|k| 
	 	
	 		tmp2=learningrate*(dk[k]);  
	 		
		 	Array.fill(nhidden,{|h|  
		 		tmp= weightso[k][h]; 
			 	tmp + (tmp2* (hiddenoutput[h]))  
		 	
		 	});
		 	
	 	});
	 	
		 biash=biash + (dh * learningrate); 
		 biaso=biaso + (dk * learningrate);
	 
	 }
	 
	 //could add differentiated training and validation sets later
	 //conditions on stopping with number of epochs or error
	 trainASAP {|trainingset, errortarget=0.05, maxepochs=100, status=true|
	 	var error, errortotal;
	 	
	 	error=2*errortarget;
	 	
	 	isTraining=true;
	 	
	 	if (trainingset.isNil,{"no training set!".postln; ^nil});
	 	
	 	trainingepoch=0;
	 
	 	//could make a routine with wait times to amortise; would be safer, properly interruptable!
	 	while({(trainingepoch<maxepochs) && (error>errortarget) && (isTraining)},{
	 	
	 	errortotal=0.0;
	 	
	 	trainingset.do{|example| 
	 	
	 	//assumes in separable form
	 	this.train1(example[0],example[1]);
	 	
	 	errortotal = errortotal + ((output-(example[1])).squared.sum); 
	 	};
	 	
	 	error=errortotal; //(trainingset.size) would give average error per training example
	 	
	 	if(status,{ [trainingepoch, error].postln;});
	 	
	 	trainingepoch=trainingepoch+1;
	 	});
	 	
	 	isTraining=false;
	 	
	 }
	
	//uses a routine, interruptable, can set slower waittime for amortisation
	 train {|trainingset, errortarget=0.05, maxepochs=100, status=true, waittime=0.01, betweenexamples= 0.001|
	 	var error, errortotal;
	 	
	 	error=2*errortarget;
	 	
	 	isTraining=true;
	 	
	 	if (trainingset.isNil,{"no training set!".postln; ^nil});
	 	
	 	trainingepoch=0;
	 
	 	//could make a routine with wait times to amortise; safer, properly interruptable!
	 	trainingset.postln;
	 	
	 	{
	 	maxepochs.do {
	 	
		 	if ( ((trainingepoch<maxepochs) && (error>errortarget) && (isTraining)),{
		 	
			 	errortotal=0.0;
			 	
			 	trainingset.do{|example| 
			 	
				 	//assumes in separable form
				 	this.train1(example[0],example[1]);
				 	
				 	betweenexamples.wait;
				 	
				 	errortotal = errortotal + ((output-(example[1])).squared.sum); 
			 	};
			 	
			 	error=errortotal; //(trainingset.size) would give average error per training example
			 	
			 	if(status,{ [trainingepoch, error].postln;});
			
			 	trainingepoch=trainingepoch+1;
		 	},{
		 	
			 	//"stop!".postln;
			 	isTraining=false;
			 	nil.yield;
			 	
		 	});
		 	
		 	waittime.wait;
	 	}
	 	
	 	}.fork;
	 	
	 	
	 }
	 
	 
	 test {|testset|
	 
	 	var errortotal=0.0;
	 	
	 	testset.do{|example| 
	 	
	 	//assumes in separable form
	 	this.calculate(example[0]);
	 	
	 	errortotal = errortotal + ((output-(example[1])).squared.sum); 
	 	};
	 
	 	^errortotal;
	
	 }
	 
	getNN {
		^[nin,nhidden,nout,weightsh, biash, weightso, biaso, learningrate];
	} 
	
	
	//WARNING, overwrites existing parameters
	setNN {|params|
		
		nin= params[0];
		nhidden=params[1];
		nout=params[2];
		weightsh=params[3];
		biash=params[4];
		weightso=params[5];
		biaso=params[6];
		learningrate=params[7];
		
	} 
	
	/*Train externally using the c++ version of this code, use this for quick training.
	The pathToNeuralNetBinary classvar needs to point to the folder containing the NeuralNet binary
	*/
	trainExt {|trainingset, errortarget=0.05, maxepochs=100|
		var cmdFileName = "/tmp/" ++ TempoClock.default.seconds;
		var cmdFile, pipeCmd, pipe, line;
		
		//write a command script for training the net
		cmdFile = File(cmdFileName, "w");
		cmdFile.write("set\n");
		cmdFile.write(format("%\n%\n%\n%\n", nin, nhidden, nout, learningrate));
		weightsh.do{
			|weights|
			weights.do {|v|
				cmdFile.write(v.asString ++ "\n");
			}
		};
		biash.do { |v|
			cmdFile.write(v.asString ++ "\n");
		};
		weightso.do{
			|weights|
			weights.do {|v|
				cmdFile.write(v.asString ++ "\n");
			}
		};
		biaso.do { |v|
			cmdFile.write(v.asString ++ "\n");
		};
		cmdFile.write("train\n");
		cmdFile.write(maxepochs.asString ++ "\n");
		cmdFile.write(errortarget.asString ++ "\n");
		cmdFile.write(trainingset.size.asString ++ "\n");
		trainingset.do {
			|example|
			example[0].do {
				|v|
				cmdFile.write(v.asString ++ "\n");
			};
			example[1].do {
				|v|
				cmdFile.write(v.asString ++ "\n");
			};
		};
		cmdFile.write("dump\n");
		cmdFile.write("quit\n");
		cmdFile.close;
		
		//pipe the script to the NeuralNet binary
		pipeCmd = format("cat % | %NeuralNet", cmdFileName, pathToNeuralNetBinary);

		//post the results
		pipe = Pipe.new(pipeCmd, "r");
		line = pipe.getLine;								
		while({line != "trained"}, {line.postln; line = pipe.getLine; });
		
		//read the new values for the weights and biases
		(nhidden).do {|i|
			(nin).do { |j|
				line = pipe.getLine;
				weightsh[i][j] = line.asFloat;
			};
		};
		(nhidden).do {|i| line = pipe.getLine; biash[i] = line.asFloat;};
		(nout).do {|i|
			(nhidden).do { |j|
				line = pipe.getLine;
				weightso[i][j] = line.asFloat;
			};
		};
		(nout).do {|i| line = pipe.getLine; biaso[i] = line.asFloat;};
		
		//clean up
		pipe.close;
		("rm " ++ cmdFileName).unixCmd;

		"Done".postln;
		
		
		
	}
	
	//efficiency for later?- fix n inputs as last time, only change m
	
	
	
	save { |filename| 
		var a;   

		filename = filename?? {SCMIR.tempdir++"neuralnet"++".scmirZ"}; 
	
		a = SCMIRZArchive.write(filename);  

		a.writeItem(nin);
		a.writeItem(nhidden);  
		a.writeItem(nout);
		a.writeItem(learningrate);  
		a.writeItem(weightsh);  
		a.writeItem(weightso);  
		a.writeItem(biash);  
		a.writeItem(biaso);  
		a.writeItem(dk);  
		a.writeItem(dh);  
		a.writeItem(input);  
		a.writeItem(hiddenoutput);
		a.writeItem(output);
		a.writeItem(trainingepoch);
		a.writeItem(isTraining);
		
		a.writeClose;  		  
	}  
	  
	  
	load { |filename| 
		var a;   
		  
		filename = filename?? {SCMIR.tempdir++"neuralnet"++".scmirZ"};    
		  
		a = SCMIRZArchive.read(filename);  

		nin = a.readItem;   
		nhidden = a.readItem;   
		nout = a.readItem;    
		learningrate= a.readItem;  
		weightsh= a.readItem;  
		weightso= a.readItem;  
		biash= a.readItem;  
		biaso= a.readItem;  
		dk= a.readItem;  
		dh= a.readItem;  
		input= a.readItem;  
		hiddenoutput= a.readItem;
		output= a.readItem;
		trainingepoch= a.readItem;
		isTraining= a.readItem;	
			  
		a.close;  
		  
	}  
	
	
}



