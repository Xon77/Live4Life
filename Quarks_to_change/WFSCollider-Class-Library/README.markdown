GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
===============================================================================

GameOfLife WFSCollider is an adapted version of SuperCollider, the audio synthesis engine and programming language, for Wave Field Synthesis spatialization.

It's currently being used in the 192 speakers system of the [Game Of Life Foundation](http://gameoflife.nl/en), based in The Hague, the Netherlands.

WFSCollider consists of an audio spatialization engine that places individual sound sources in space according to the principles of [Wave Field Synthesis](http://en.wikipedia.org/wiki/Wave_field_synthesis).

The system allows soundfiles, live input and synthesis processes to be placed in a score editor where start times, and durations can be set and trajectories or positions assigned to each event. It also allows realtime changement of parameters and on the fly starting and stopping of events via GUI or OSC control. Each event can be composed of varous objects ("units") in a processing chain.

Score files are saved as executable SuperCollider code. The system is setup in a modular way and can be scripted and expanded using the SuperCollider language.

## System Requirements ##

Mac OS X 10.6 or greater
Depends on:

* the MathLib, NetLib, PopUpTreeMenu, VectorSpace, wslib and XML quarks.
* Unit Lib.
* sc3plugins.

## Download ##

A prepackaged version is available from [SourceForge](https://sourceforge.net/projects/wfscollider/).

## Installation ##

To install, just drag the application to your applications folder.

## Building ##

Get the source:

	git clone --recursive git://github.com/GameOfLife/WFSCollider.git

switch to the wfscurrent branch

	git checkout wfscurrent

Then build according to the general SuperCollider instructions (see readme): In XCode, first build the Synth project, then the plugins project and finally in the language project build the target "WFSCollider". You should then have the application ready in the build folder.

## Acknowledgments ##
WFSCollider was conceived by the Game Of Life Foundation, and developed by W. Snoei, R. Ganchrow and J. Truetzler and M. Negrão.

## License ##
Both SuperCollider and the WFSCollider library are licensed under the GNU GENERAL PUBLIC LICENSE Version 3.  

