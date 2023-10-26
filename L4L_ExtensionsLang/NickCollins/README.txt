README

SuperCollider Music Information Retrieval (SCMIR) library
by Nick Collins
composerprogrammer.com

For SuperCollider 3, all code under GNU GPL 3 license, see COPYING file.

Version 1.5+ tested on SC 3.7
Version 1.2+ tested on SC 3.6
Version 0.9+ tested on SC 3.5 (and basic tests on 3.6)
Version up to 0.8 tested extensively under SC3.4.4 on OS X

Installation:
See the InstallMac file for instructions for Mac.
See the InstallLinux file for additional instructions for Linux from Martin Marier.

Compilation:
You only need to compile things if you are on Linux, or have a desire to change from the precompiled executables for Mac. Instructions are in the files above.

Note:
There is a small bug in the SC MFCC code in SuperCollider 3.4. Fixed in developer core and for later versions from SC 3.5. If you are on 3.4 and have source files with perfect noise floor of 0.0 values, the MFCC then leads to infs, messing up normalization. Mac Intel build of MachineListening plugins included as a drop in replacement for those who this is an issue for (swap the plugin in your plugins folder in the app directory).


Change Log and Announcements:


1.5

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.5

Fixes for SC 3.7 and other miscellaneous bug fixes

added KNearestNeighbour class

'quantile normalisation'/histrogram equalisation/percentiles as normalisation method (normalisationtype 2; you can choose the number of quantiles by putting a negative number as normalisationtype, e.g. -15 gives 15 quantiles)

Now at composerprogrammer.com:
http://composerprogrammer.com/code.html
http://composerprogrammer.com/code/SCMIR.zip



1.4

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.4

CustomFeature: use any closed function definition for feature extraction. See customfeature.scd in examples

Segmentation aggregation of feature vectors ('texture windows') now can be by minimum and standard deviation rather than just max and mean

Additional similarity matrix display options (numerical axis tick labels)


Now at composerprogrammer.com:
http://composerprogrammer.com/code.html
http://composerprogrammer.com/code/SCMIR.zip



1.3

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.3

Added extractFeaturesWithWindowing() function to directly call window size and hop size aggregation for features
Coverage for some extra third party features
SCMIRLive feature clip option and load bug fix; always allocates unique IDs for OSC response now
General fixes

Now at composerprogrammer.com:
http://composerprogrammer.com/code.html
http://composerprogrammer.com/code/SCMIR.zip


1.2

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.2

save and load for MarkovPool
extra options for Chromagram to match new arguments made available in SCMIRPlugins
NeuralNet save/load, extra segmentation option via start and end times per segment, additional features


1.1

Latest release of SCMIR

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.1

new additions and changes:
Machine learning classes:
MarkovPool: context based committe of Markov models
SOM: 1-dimensional self organising map
SARDNET: self organising map reacting to temporal sequences
VOGUE: variable order Markov model based on a durational HMM for frequently occuring length 2 subsequences

Tweak to exposed arguments in SCMIRAudioFile feature handling

Reworked internal code directory structure to better match public release format
Slight fix for linux support

First Durham release:
http://www.dur.ac.uk/nick.collins/code.html
http://www.dur.ac.uk/nick.collins/code/SCMIR.zip



1.0

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis: version 1.0

new additions and changes:
Miscellaneous bug fixes and rationalisations, some convenience methods added

http://www.sussex.ac.uk/Users/nc81/code.html
http://www.sussex.ac.uk/Users/nc81/code/SCMIR.zip



0.9.3
Fix for segmentation bug
Added HMM class and external


0.9.2
Fix for recurrent NRT calculation problem for SC 3.5 and later
Added SpectralEntropy UGen


0.9.1

Small fixes for Linux compatibility (thanks Martin Marier):
NRTanalysis OSC file now uses temp directory location to avoid permissions problem
Avoid OS X specific SCWindow, SCUserView, use generic windowing classes


version 0.9

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.9
new additions and changes:

Compatibility for SC 3.5 including new schelp system
SCMIR plugins now separately in sc3-plugins; pre-built plugins included in package for Mac
Miscellaneous bug fixes and refinements
CMake for building executables, also includes NeuralNet class
Extra examples

http://www.sussex.ac.uk/Users/nc81/code.html
http://www.sussex.ac.uk/Users/nc81/code/SCMIR.zip



version 0.8

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.8.
new additions and changes:

Symbolic time series analysis via variable order Prediction by Partial Match algorithm (PPMC class) and fixed order MarkovModel class
Support for feature extraction of Transient (WT_Transient from Wavelets code) and PolyPitch features
Various bug fixes, and greater robustness to long run times (e.g. a database of hundreds of files, over many hours)
Auto conversion of MP3s into temp directory wavs using lame: via code adapted from MP3 Quark (you don't need the MP3 Quark, but you must have /usr/local/bin/lame available or else adapt the path SCMIR.lamelocation (used in the SCMIRAudioFile:resolveMP3 method) to point to your lame installation)
differentiateFeature and sumMultiFeature methods: useable, but may be subject to a more general revision in a future version

http://www.sussex.ac.uk/Users/nc81/code.html
http://www.sussex.ac.uk/Users/nc81/code/SCMIR.zip










version 0.7

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.7.
new additions and changes:

SCMIRLive: use feature extraction in a live Synth, with or without normalization
NaiveBayes and GMM machine learning classes
Fixes for use of temp directory /tmp/ by default rather than application directory, particularly important for network installed SC
Endianness fix, use SCMIRFile.setEndianness if you are on PPC, and it should then work without issues

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip




version 0.6

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.6.
new additions and changes:
Can avoid {}.fork wrapper by running in main thread, though may lead to sclang too busy to interact with. Otherwise, continues to work with {}.fork with progress reporting.
Provided examples of use with external machine learning from weka java library, and some other standard MIR tasks
Time domain features RMS and ZCR

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip





version 0.5

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.5.
new additions and changes:
Refactored similiarity matrix with new SCMIRSimilarityMatrix class. Supports non-square distance matrices and between file comparison.
Added dynamic time warping capability, with plotting of path.
Support 512 sample hop as well as 1024 to give two basic available frame rates.

A few bug fixes:
Fixed bug where not having certain extension plugins installed on system leads to annoying 'Execution warning: Class 'SuperFeature' not found' message, even if not directly trying to use SuperFeature
Miscellanous fixes; DTW algorithm now more robust than early development version and similarity matrix code tidied.

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip



version 0.4

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.4.
new additions and changes:
Extract onset locations
Onsets raw detection function can be extracted as features
Tidied up aggregation of features for an arbitrary segmentation
Input feature info format changed from confusing [Feature,Normtype,additional args] to [Feature, additional args] where normtype is global/assumed  (some specific feature extractors allow options).
Support for a choice of normalization and standardization (must choose only one normalization type per file, experimental global normalisation allowed with respect to values over a whole database of files).

best,
Nick

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip





version 0.3

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.3.
new additions:
beat tracking via AutoTrack and BeatRoot, beat segmentation based feature analysis and similarity
SensoryDissonance UGen
some tidying (camelCase for method names in particular), bug fixes, additional feature extraction plugins supported
export feature data as ARFF, plot feature trails as curves

best,
Nick

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip



version 0.2

Latest alpha release of SCMIR.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.2.
new additions:
novelty curve extraction from similarity matrix, followed by section detection
accompanying external programs (pre-compiled for OS X, source enclosed) as language extensions to speed up similarity matrix construction (cosine, Manhattan and Euclidean metrics now supported) and novelty curve calculation.

best,
Nick

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip


version 0.1

I'd like to announce an alpha release of SCMIR, which might have a few useful components for people.

SCMIR: SuperCollider Music Information Retrieval Library for audio content analysis; version 0.1.
NRT feature extraction, plotting features, similarity matrix.
Also includes Chromagram and FeatureSave plugins (pre-built for Mac, plus source):
Chromagram: for nTET tuning systems with any base reference
FeatureSave: storing feature data in NRT mode (writes file from plugin itself, more effective than using Logger especially when dealing with >22 features/channels)

best,
Nick

http://www.cogs.susx.ac.uk/users/nc81/code.html
http://www.cogs.susx.ac.uk/users/nc81/code/SCMIR.zip




