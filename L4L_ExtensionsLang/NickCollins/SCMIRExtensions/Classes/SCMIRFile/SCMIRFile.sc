//to cope with binary files in Little and Big Endian, e.g., Intel or PPC

SCMIRFile : File { 
	 
	//for auxilliary operations 
	classvar <>littleendian; //0 = little endian (Intel) = default
	
	*initClass { 
	
		littleendian = true; 
				 		
	} 
	
	*new { arg pathName, mode;
		^super.new(pathName, mode).initSCMIRFile(pathName, mode);
	}
	
	initSCMIRFile {|path1,mode1|

		//could try multiple times?
		if(not(this.isOpen)) {
			
			//try again
			this.close; 
			
			SCMIR.clearResources; 
					
			this.open(path1,mode1);
			
			}
	}

	
	
	//return boolean based on reading of LE binary file with one entry; file created dynamically by tiny test C executable
	*testEndianness {
		var def, ugenindex; 
		var testfilename, duration= 0.1; 
		var auxfile, serveroptions; 
		var temp, score; 
		
		//test via FeatureSave	
		def = SynthDef(\SCMIREndianTest,{     
			   
			FeatureSave.kr(SinOsc.ar(0,0.5pi), Impulse.kr(1));    
			  
		}); 
		
		//find synth index for FeatureSave
		
		def.children.do{|val,i| if(val.class==FeatureSave,{ugenindex = val.synthIndex})};
		def.writeDefFile;     
		
		testfilename = "endiantest.data";   
			  
		score = [         
		[0.0, [ \s_new, \SCMIREndianTest, 1000, 0, 0]], 
		[0.01,[\u_cmd, 1000, ugenindex, "createfile",testfilename]], //can't be at 0.0, needs allocation time for synth before calling u_cmd on it  
		[duration,[\u_cmd, 1000, ugenindex, "closefile"]],     
		[duration, [\c_set, 0, 0]]      
		];     

		serveroptions = ServerOptions.new;    
		serveroptions.numOutputBusChannels = 1; // mono output     
		  
		Score.recordNRTSCMIR(score,SCMIR.nrtanalysisfilename,SCMIR.nrtoutputfilename, nil,44100, "WAV", "int16", serveroptions); // synthesize   
		  
		//LOAD FEATURES  
		//Have to be careful; Little Endian is standard for Intel processors  
		auxfile = File(testfilename,"rb");  
		  
		auxfile.getInt32LE;   
		  
		//[\numframes,numframes].postln;  
		  
		temp = auxfile.getInt32LE;  
		temp = (1==temp); 
				  
		auxfile.close;   
		
		^temp;
	}
	
	*setEndianness {
	
		littleendian = SCMIRFile.testEndianness(); 	
		
	}
	
	
	//only these calls used by SCMIR, so only ones overwritten
	getInt32LE { ^if(littleendian){super.getInt32LE}{super.getInt32} }
	getFloatLE { ^if(littleendian){super.getFloatLE}{super.getFloat} }
	getDoubleLE { ^if(littleendian){super.getDoubleLE}{super.getDouble} }
	putInt32LE {arg anInteger; ^if(littleendian){super.putInt32LE(anInteger)}{super.putInt32(anInteger)} }
	putFloatLE {arg aFloat; ^if(littleendian){super.putFloatLE(aFloat)}{super.putFloat(aFloat)} }
	readLE {arg buffer; ^if(littleendian){super.readLE(buffer)}{super.read(buffer)} }
	writeLE {arg item; ^if(littleendian){super.writeLE(item)}{super.write(item)} }

		 
} 
 
 
 
 
 
 
 
 
 
