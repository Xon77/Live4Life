
e = SCMIRAudioFile("/data/audio/mirdata/pixiesivebeentired.wav", [[Loudness],[SpecCentroid],[SpecPcile, 0.95],[SpecPcile, 0.8],[SpecFlatness],[FFTSpread],[FFTSlope]]);

e.extractFeatures()

e.numfeatures
e.numframes //9766, lots of training for a GMM

e.featuredata

//gather data by seconds

a= (0.0,1.0..(e.duration))

//averaging for each second
e.gatherFeaturesBySegments(a); 

e.numframes //181

g = GMM(7); //7 states

d = e.featuredata.clump(e.numfeatures)

d.size

g.train(d)

g.loadModel; 

d.do{|val|  g.test(val).postln;  }

