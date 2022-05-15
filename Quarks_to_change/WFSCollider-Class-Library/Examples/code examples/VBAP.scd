
Udef.defsFolders.add(WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs");

VBAPLib.startup;

VBAPSpeakerConf.default = VBAPSpeakerConf.fivePointOne;

//one can also just write the files to disk and not have to run this line again
VBAPSynthDef.generateDefs(5).do(_.send(ULib.servers));

//run this only once
VBAPSpeakerConf.default.sendBuffer(ULib.servers);




x = UChain(\blip, \wfsPathPlayer, [\vbap2D_Panner, [\pointFromBus, true]]);
x.prepareAndStart;
x.gui