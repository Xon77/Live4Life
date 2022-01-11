# Welcome to *Live 4 Life* ! To come soon in January 2022 ! &nbsp;&nbsp; ![Licence](https://licensebuttons.net/l/by-nc-sa/3.0/88x31.png)


| [**Overview**](#overview) | [**Usage**](#usage) | [**Requirements**](#requirements) | [**Installation**](#installation) | [**References**](#references) | [**Contribute**](#contribute) | [**Acknowledgements**](#acknowledgements) | [**Licence**](#licence) |


## Overview

The **spatial performance tool** *Live 4 Life* aims to simplify the creation and control in real time of mass of spatialised sound objects on various kinds of loudspeaker configurations (particularly stereo, quadriphonic or octophonic setups, as well as domes of 16, 24 or 32 loudspeakers...). 

I have been developing in **SuperCollider** since 2011, "to play the place and the music at the same time". Currently, it is the only project I use to create with space and sounds. Although I hope to develop it during the rest of my life, development is paused because of several reasons (mainly due to the pandemic and the difficulty to perform spatial improvisations in large concert halls without appropriate retribution – not even a beer).


<p align="center">
<b>The performance tool in context with all its controllers in 2021</b>
<!--<a href="#> <b>The performance tool in context with all its controllers</b> </a> <br> -->
<img src="Images/Controllers2021b.jpg" />
</p>

<p align="center">
<b>One of the views of the GUI to choose among dozens of sequences and global parameters</b>
<img src="Images/ViewGlobal.jpg" />
</p>

<p align="center">
<b>Another view of the GUI to compose sequences of parameters of spatialised sound events</b>
<img src="Images/ViewSeq.jpg" />
</p>

<!--
<p align="center">
  <b>Some Links:</b><br>
  <a href="#">Link 1</a> |
  <a href="#">Link 2</a> |
  <a href="#">Link 3</a>
  <br><br>
  <img src="http://s.4cdn.org/image/title/105.gif">
</p>
-->


## Usage

:warning: Please note that:

* it is designed for a specific screen size (1920×1200) and an AZERTY keyboard.

* although the code is available here, the interface and the setup are relatively complex, as this tool is not meant to be a simple graphic user interface (GUI) for a casual, untrained user of SuperCollider, but focused to allow the creation of a lot of combinations tailored to my creative dreams.

* due to the fact I almost began learning SuperCollider with this project and that I am not a professional developer, I have developed my own coding strategies, which might be bad or unoptimized. Even though there are some bugs, the tool works well for me with my workflow. But I cannot guarantee it will work for you the way you want.

* changing drastically effect parameters can produce very loud sounds. So, monitor the volume.


### Platform support

*Live 4 Life* has been tested with macOS 10.14.6 Mojave on a MacBook Pro 15".
Although it works well for Apple Silicon with macOS 12.1 Monterey, it will soon be optimized for M1 16".

The reason why I do not switch from Mac to Linux is that I often used [Dante](https://www.audinate.com/products) to send multiple channels via ethernet in some concert halls. Since Dante virtual sound cards are not available for linux, you need to buy specific expensive sound cards to use Dante.

It might work for Linux and Windows platforms after solving some issues. 
Several years ago, I succeeded to make it work on Linux: I remember I had to change and limit `numWireBufs_` to some values, like 800, in the file `1_Init Buffer Synths`, since MacOS seem to accept very high values without generating errors. Since then, there may probably be other errors on Linux.
For Windows, I do not know, since currently I do not have a simple access to both of them.
Let me know. I might maybe help.


## Requirements

* [SuperCollider 3.12.1](https://supercollider.github.io/download) or above,

* [sc3-plugins](https://supercollider.github.io/sc3-plugins/),

* many [Quarks](https://github.com/supercollider-quarks):
  - [adclib](https://github.com/supercollider-quarks/adclib) (for adcVerb),
  - [atk-sc3](https://github.com/ambisonictoolkit/atk-sc3) (for ambisonic spatialisation: currently only FOA is used, HOA-ATK will be updated in the future. Install also [ATK dependencies](https://github.com/ambisonictoolkit/atk-sc3/blob/master/README.md#kernels-matrices--soundfiles), i.e. Kernels and Matrices. This Quark will also install automatically other Quarks, like e.g. [wslib](https://github.com/supercollider-quarks/wslib) for GUI, [Mathlib](https://github.com/supercollider-quarks/MathLib) or [XML](https://github.com/supercollider-quarks/XML).),
  - [Automation](https://github.com/neeels/Automation) (for saving and recalling actions on main GUIs),
  - [Bjorklund](https://github.com/redFrik/Bjorklund) (for Euclidean algorithm),
  - [Connection](https://github.com/scztt/Connection.quark) (for [MVC](https://en.wikipedia.org/wiki/Model–view–controller) and NumericControlValue),
  - [Ctk](https://github.com/supercollider-quarks/Ctk) (for Sam Potter extensions and chaotic envelopes),
  - [FPLib](https://github.com/miguel-negrao/FPLib) (for functional programming to get back to previous presets. This Quark will also install automatically [JITLibExtensions](https://github.com/supercollider-quarks/JITLibExtensions) and [Modality-toolkit](https://github.com/ModalityTeam/Modality-toolkit) for some MIDI controllers.),
  - [PopUpTreeMenu](https://github.com/redFrik/PopUpTreeMenu) (for GUI),
  - ([redSampler](https://github.com/redFrik/redSampler): not necessary; I only use it to play specific sound files.),
  - [ServerTools](https://github.com/supercollider-quarks/ServerTools) (for server status),
  - [SpeakersCorner](https://github.com/supercollider-quarks/SpeakersCorner) (for GUI),
  - [TabbedView2](https://github.com/jmuxfeldt/TabbedView2) (for GUI),
  - [TabbedView2_QT](https://github.com/jmuxfeldt/TabbedView2_QT) (for GUI),
  - [Twister](https://github.com/scztt/Twister.quark) (for MIDI Fighter Twister controllers; since it is not in the Quarks directory, you can install via `Quarks.install("https://github.com/scztt/Twister.quark")`.),
  - [Unit-Lib](https://github.com/GameOfLife/Unit-Lib) (for the 2D trajectory editor of the modified version of [WFSCollider-Class-Library](https://github.com/GameOfLife/WFSCollider-Class-Library), available within the [folder](/4Live4Life_Extensions) `4Live4Life_Extensions`. It is just a small add-on[^Traj] to avoid an error in the post window by closing the trajectory editor. If you already have [WFSCollider-Class-Library](https://github.com/GameOfLife/WFSCollider-Class-Library), replace it with this one.),
  - [WarpExt](https://github.com/supercollider-quarks/WarpExt) (for warp synths),
  - [ZArchive](https://github.com/crucialfelix/ZArchive) (for saving and recalling presets).

Concerning some extensions, [APCmini](https://github.com/andresperezlopez/APCmini)


## Installation

1. [Install SuperCollider](https://supercollider.github.io/download). 
2. Put [sc3-plugins](https://supercollider.github.io/sc3-plugins#insrallation) in your SuperCollider Extensions folder.
3. [Install the Quarks](https://github.com/supercollider-quarks/quarks#installing-a-quark) mentioned above and recompile. If you use the [MIDI TouchBar](https://urbanlienert.com/miditouchbar) on previous MacBook Pros, put the file `Controllers/TouchBar/gestionnaire-iac.desc.scd` in the folder `MKtlDescriptions` within the Quark Modality.
4. Put the folder `4Live4Life_Extensions` in your SuperCollider Extensions folder and recompile again.


### Setup

The code does not take the form of a SuperCollider quark (i.e. external library) or classes, since I would have been unable to build this tool if I had to recompile the programme each time I had to change the code. Due to this experimental nature based on trial and error, it consists of environment variables collecting arrays, dictionaries and functions spread roughly in three files to execute for:

* initializing a collection of thousands of synthDefs, with a few dozen synthesis types for each envelope type and for each spatial algorithm and a library of trajectories for some algorithms,

* initializing a collection of thousands of mono and stereo buffers of max. 2 GB, hierarchically organized by category in dozens of folders and subfolders,

* opening a GUI with a Sequence view for the composition and the Global view for the performance,

* initializing a pattern function, that triggers sound events with different parameters for each track, and a routine updating the GUI.


## Contribute

I have a lot of features I would like to improve or develop, such as ...

If you would like to contribute, please get in touch with me in order to organise further development.

If you report an issue, please try to send a pull request, since depending on my priorities I may not have not the time or the ability to solve it.


## References

*Live 4 Life* has been presented many times during conferences ([JIM 2017](https://jim2017.sciencesconf.org/data/Lengele2017aa.pdf), [ICMC 2018](https://quod.lib.umich.edu/cgi/p/pod/dod-idx/live-4-life-a-spatial-performance-tool-focused-on-rhythm.pdf?c=icmc;idno=bbp2372.2018.057;format=pdf), [ICMC 2021](https://www.researchgate.net/publication/354526907_The_story_and_the_insides_of_a_spatial_performance_tool_Live_4_Life)), concerts (ICMC 2017, [JIM 2019](https://www.youtube.com/watch?v=NfWXF6copEs)), festivals (Ultrasons from 2016 to 2021, Akousma 2021), or in the  Journal of Music and Technology [Organised Sound](https://doi.org/10.1017/S135577182100008X).

All the papers are also published on [Researchgate](https://www.researchgate.net/profile/Christophe-Lengele), as well as my doctoral thesis, soon to be published (in french, sorry) about spatial improvisations based on polyrhythms and sequences of parameters in loop via this tool.

Several performances are available either on [YouTube](https://www.youtube.com/channel/UCOv5kb3IQBmgyOQPu5DOZ4g) or [Vimeo](https://vimeo.com/christophexon).


## Acknowledgements

*Live 4 Life* grew little by little, by gluing and restructuring a lot of code from others and integrating several systems and quarks. I would have been unable to build this tool without the help of the SuperCollider online community, who always answered my questions and even provided me with some examples of codes and classes.

So, Big Thanks to (including previous and current developers):

[James Harkins](https://github.com/jamshark70), [Daniel Mayer](https://github.com/dkmayer), [Fredrik Olofsson](https://github.com/redFrik), [Julian Rohrhuber](https://github.com/telephon), [Josh Parmenter](https://github.com/joshpar), [Wouter Snoei](https://github.com/woutersnoei), [Nick Collins](https://github.com/sicklincoln), [Jakob Leben](https://github.com/jleben), [Chris Sattinger](https://github.com/crucialfelix), [Dan Stowell](https://github.com/danstowell), [Scott Wilson](https://github.com/muellmusik), [Joseph Anderson](https://github.com/joslloand), [Miguel Negrão](https://github.com/miguel-negrao), [Scott Carver](https://github.com/scztt), [Alberto de Campo](https://github.com/adcxyz), [Marije Baalman](https://github.com/sensestage), [Brian Heim](https://github.com/mossheim), [Marcin Pączkowski](https://github.com/dyfer) ...


The list might be long. Sorry for those I forgot to mention. I cannot quote all of them.

By giving soon this tool, it is my way to contribute to SuperCollider.
And I encourage anyone (DSP developers or any user) to support this beautiful environment.


## Licence

© 2011-2021 Christophe Lengelé

*Live 4 Life* is an open source software: you can redistribute it and/or modify it under the terms of **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license** (CC BY-NC-SA 4.0). 

You may **not** use it for commercial purposes.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY. 

I wish it would be used in the spirit of *Free Party*. Unfortunately, *Free* does not mean free in this commercial world, but invites to contribute to the costs and labor according to one's ability to give. I do not want this tool to be used, by any means, for personal profit.

Moreover, I would **not** like that this tool to be used by [Société des Arts Technologiques](https://sat.qc.ca) without my consent, since this organization never helped me in diffusing my spatial creation and research despite my proposals. If these wishes are not respected, your souls will be damned for eternity.

See the [License](/LICENCE.md) for more details.
