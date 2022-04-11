# Welcome to ***Live 4 Life*** ! &nbsp;&nbsp; ![Licence](https://licensebuttons.net/l/by-nc-sa/3.0/88x31.png) &nbsp;&nbsp; <span class="badge-buymeacoffee"><a href="https://ko-fi.com/live4life" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a></span> &nbsp;&nbsp; <span class="badge-patreon"><a href="https://patreon.com/live4life" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>

---
| [**Overview**](#overview) | [**Usage**](#usage) | [**Requirements**](#requirements) | [**Installation**](#installation) | [**References**](#references) | [**Contribute**](#contribute) | [**Acknowledgements**](#acknowledgements) | [**Licence**](#licence) |


## Overview

The **spatial performance tool** ***Live 4 Life*** aims to simplify the creation and control in real time of mass of spatialised sound objects on various kinds of loudspeaker configurations (particularly stereo, quadriphonic or octophonic setups, as well as domes of 16, 24 or 32 loudspeakers...) with many controllers (currently, you can control it with the GUI and the keyboard, and you can also add an [Akai APC Mini](https://www.akaipro.com/apc-mini), 2 tablets with [Lemur App](https://liine.net/en/products/lemur/), 2 [MIDI Fighter Twister](https://www.midifighter.com/#Twister) and a [Sensel Morph](https://morph.sensel.com)). 

I have been developing in [**SuperCollider**](https://supercollider.github.io) since 2011, "to play the place and the music at the same time". Currently, it is the only project I use to create with sounds and space. Although I hope to develop the tool with other spatial controls and algorithms during the rest of my life, rhythm and synthesis are now prioritized over spatial development, which is a bit paused because of several reasons (mainly due to the pandemic and the difficulty to find residencies or perform spatial improvisations in concert halls or festivals without an appropriate allowance).

What makes the difference with other spatialisation tools ?

1. It is not only a spatialisation tool, but **a whole sound creation system** to play with sequences of parameters (rhythm, sound and space), **integrating spatialisation at the heart of each sound synthesis**.
2. Contrary to most tools with input/track-based spatialisation, it is **a layer- and event-based spatialisation,** where sequences of **spatialised sound particles or choruses** (copies or echoes of the same event with micro-delays or spectral/spatial variations) meet **a multichannel effect system**.
3. It includes **a library of different abstract and concrete spatialisation techniques and rendering algorithms** (see section 1.2 of [ICMC 2018 paper](https://quod.lib.umich.edu/cgi/p/pod/dod-idx/live-4-life-a-spatial-performance-tool-focused-on-rhythm.pdf?c=icmc;idno=bbp2372.2018.057;format=pdf) for definitions and the figure 4 of [ICMC 2021 paper](https://www.researchgate.net/publication/354526907_The_story_and_the_insides_of_a_spatial_performance_tool_Live_4_Life) for the details of the spatial structure), **mixing channel- and object-based paradigms** to be used on every sound event (to take advantage of the strengths of each approach). It has also the effect that sequences integrating channel-based or a multichannel effect system are different according to the number of loudspeakers available and cannot be reproduced in the same way on different loudspeaker configurations.
4. It is first thought for spatial performance with several **global, high-level (indirect) control strategies**, e.g. by swinging among scenes of spatialised events or by changing masses of parameters, particularly playback speeds with different mappings according to each controller. 


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

* currently, the code can be incorrectly highlighted in Github due to a [bug](https://github.com/supercollider/language-supercollider/issues/4), but it is ok in SuperCollider.

* it is currently designed for both Mac 15" specific screen size (1920×1200) and Mac 16" specific screen size (2056×1329) and an AZERTY keyboard (Français - Numérique). Scaling of the GUI and other keyboard options will be added in the future.

* although the code is available here, the interface and the setup are relatively complex, as this tool is not meant to be a simple graphic user interface (GUI) for a casual, untrained user of SuperCollider, but focused to allow the creation of a lot of combinations tailored to my creative dreams to map sound with space of speakers.

* due to the fact I almost began learning SuperCollider with this experimental project and that I am not a professional developer, the code is relatively raw with lots of old comments and I have developed over time my own coding strategies, which might be old, bad or unoptimized. Even though there are some bugs, the tool works well for me with my workflow. But I cannot guarantee it will work for you the way you want.

* changing drastically effect parameters can produce very loud sounds. So, monitor the volume and change sliders and parameters slowly if you do not know the effect or what (kind of parameter) you are changing.


### Platform support

***Live 4 Life*** has been mainly tested with macOS 10.14.6 Mojave on a MacBook Pro 15" and the GUI has been adapted for macOS 12.1 Monterey on a MacBook Pro M1 16".

The reason why I do not switch from Mac to Linux is that I often used [Dante](https://www.audinate.com/products) to send multiple channels via ethernet in some concert halls. Since Dante virtual sound cards are not available for linux, you need to buy specific expensive sound cards to use Dante.

It might work for Linux and Windows platforms after solving some issues. 
Several years ago, I succeeded to make it work on Linux: I remember I had to change and limit `numWireBufs_` to some values, like 800, in the file [_1_Init_BuffersSynths_128.scd](/4Live4Life_Project/_1_Init_BuffersSynths_128.scd#L75), since MacOS seem to accept very high values without generating errors. Since then, there may probably be other errors on Linux.
For Windows, I do not know, since currently I do not have a simple access to both of them.
Let me know. I might maybe help.


## Requirements

* [SuperCollider 3.12.2](https://supercollider.github.io/downloads) or above,

* [sc3-plugins](https://supercollider.github.io/sc3-plugins/),

* many [Quarks](https://github.com/supercollider-quarks):
  - [adclib](https://github.com/supercollider-quarks/adclib) (for adcVerb),
  - [APCmini](https://github.com/andresperezlopez/APCmini) (for Akai MIDI controller),
  - [atk-sc3](https://github.com/ambisonictoolkit/atk-sc3) (for ambisonic spatialisation: currently only FOA is used, HOA-ATK will be updated in the future. Install also [ATK dependencies](https://github.com/ambisonictoolkit/atk-sc3/blob/master/README.md#kernels-matrices--soundfiles), i.e. Kernels and Matrices. This Quark will also install automatically other Quarks, like e.g. [wslib](https://github.com/supercollider-quarks/wslib) for GUI, [Mathlib](https://github.com/supercollider-quarks/MathLib) or [XML](https://github.com/supercollider-quarks/XML).),
  - [Automation](https://github.com/neeels/Automation) (for saving and recalling actions on main GUIs),
  - [Bjorklund](https://github.com/redFrik/Bjorklund) (for Euclidean algorithm),
  - [Connection](https://github.com/scztt/Connection.quark) (for [MVC](https://en.wikipedia.org/wiki/Model–view–controller) and NumericControlValue),
  - [crucialviews](https://github.com/crucialfelix/crucialviews) (for GUI BoxMatrix),
  - [Ctk](https://github.com/supercollider-quarks/Ctk) (for Sam Potter extensions and chaotic envelopes),
  - [FPLib](https://github.com/miguel-negrao/FPLib) (for functional programming to get back to previous presets. This Quark will also install automatically [JITLibExtensions](https://github.com/supercollider-quarks/JITLibExtensions) and [Modality-toolkit](https://github.com/ModalityTeam/Modality-toolkit) for some MIDI controllers.),
  - ([KMeans](https://github.com/supercollider-quarks/KMeans)),
  - [PopUpTreeMenu](https://github.com/redFrik/PopUpTreeMenu) (for GUI),
  - ([redSampler](https://github.com/redFrik/redSampler): not necessary; I only use it to play specific sound files.),
  - [ServerTools](https://github.com/supercollider-quarks/ServerTools) (for server status),
  - [SpeakersCorner](https://github.com/supercollider-quarks/SpeakersCorner) (for GUI),
  - [TabbedView2](https://github.com/jmuxfeldt/TabbedView2) (for GUI),
  - [TabbedView2_QT](https://github.com/jmuxfeldt/TabbedView2_QT) (for GUI),
  - [Twister](https://github.com/scztt/Twister.quark) (for MIDI Fighter Twister controllers; since it is not in the Quarks directory, you can install it via `Quarks.install("https://github.com/scztt/Twister.quark")`.),
  - [Unit-Lib](https://github.com/GameOfLife/Unit-Lib) (for the 2D trajectory editor),
  - [WFSCollider-Class-Library](https://github.com/GameOfLife/WFSCollider-Class-Library) (for the 2D trajectory editor),
  - [WarpExt](https://github.com/supercollider-quarks/WarpExt) (for warp synths),
  - [WindowHandleView](https://github.com/scztt/WindowHandleView.quark) (for GUI),
  - [ZArchive](https://github.com/crucialfelix/ZArchive) (for saving and recalling presets).


## Installation

1. [Install SuperCollider](https://supercollider.github.io/downloads). 
2. Put [sc3-plugins](https://supercollider.github.io/sc3-plugins#insrallation) in your SuperCollider Extensions folder.
3. [Install the Quarks](https://github.com/supercollider-quarks/quarks#installing-a-quark) mentioned above and recompile. 
4. If you use some controllers, such as the [MIDI TouchBar](https://urbanlienert.com/miditouchbar) on previous MacBook Pros or the UC-33 MIDI controller, put the files available within the folder [`Modality_desc_to_add`](/Modality_desc_to_add) in the folder `MKtlDescriptions` within the Quark Modality.
5. Replace the Quark [APCmini](https://github.com/andresperezlopez/APCmini) (if you have the controller), and also the Quark [WFSCollider-Class-Library](https://github.com/GameOfLife/WFSCollider-Class-Library) with the versions available within the folder [`Quarks_to_replace`](/Quarks_to_replace). Concerning this last Quark, it is just a small change, commenting the lines 220 and 223 of the file [`/Quarks_to_replace/WFSCollider-Class-Library/WFS/GUI/WFSPath/WFSPathGUI.sc`](/Quarks_to_replace/WFSCollider-Class-Library/WFS/GUI/WFSPath/WFSPathGUI.sc#L220), to avoid an error in the post window by closing the trajectory editor. 
6. Put the folder [`4Live4Life_Extensions`](/4Live4Life_Extensions) in your SuperCollider Extensions folder and recompile again.


### Setup

In order to launch the tool, follow the steps and coming instructions of the file [`_0_Init_Live4Life.scd`](/4Live4Life_Project/_0_Init_Live4Life.scd) in the folder [`4Live4Life_Project`](/4Live4Life_Project).

The code does not take the form of a SuperCollider quark (i.e. external library) or classes, since I would have been unable to build this tool if I had to recompile the programme each time I had to change the code. Due to this experimental nature based on trial and error, it consists of environment variables collecting arrays, dictionaries and functions spread roughly in three main files within the folder [`4Live4Life_Project`](/4Live4Life_Project) to execute for:

1. initializing a collection of thousands of synthDefs, with a few dozen synthesis types for each envelope type and for each spatial algorithm and a library of trajectories for some algorithms (the first time, a folder of synthDefs for each specific spatial configuration will be created in SuperCollider user support directory for each of the two servers that can be currently created, the next times, scsyndef files will be more quickly loaded.),

2. initializing a collection of thousands of mono and stereo buffers of max. 2 GB, hierarchically organized by category in dozens of folders (:warning: To play easily with sound files, prepare one folder gathering a collection of subfolders labelled e.g. like : `DL 1Kick`, `DM 2Snare`, `DH 3Hat`, `EL Earth`, `EM Water` `EH Fire`, `IL Bass`, `IM Gong`, `IH Piano` ..., containing dozens of sound files. The first two letters allow to gather together the categories of folders for each of the letter, e.g. the first letter `D` for Drums, `E` for sounds of the elements, `I` for instruments, and the second letter `L`, `M`, or `H` for e.g. a specific color or register. To speed up setup and creation process, I am preparing in this [folder](https://github.com/Xon77/L4LSoundsDataBase) a collection of drum sounds specifically sorted for this tool.),

3. opening a GUI with different tabs like a Sequence view for the composition and the Global view for the performance (see below figures), as well as views for global multichannel and ambisonic effects,

4. initializing a pattern function, that triggers sound events with sequences of parameters for each track, and a routine updating the GUI.

A wiki, tutorials and code examples to automate some utility functions will be added over time, and hopefully real spatial workshops...


## References

***Live 4 Life*** has been presented several times during conferences ([JIM 2017](https://jim2017.sciencesconf.org/data/Lengele2017aa.pdf), [ICMC 2018](https://quod.lib.umich.edu/cgi/p/pod/dod-idx/live-4-life-a-spatial-performance-tool-focused-on-rhythm.pdf?c=icmc;idno=bbp2372.2018.057;format=pdf), [ICMC 2021](https://www.researchgate.net/publication/354526907_The_story_and_the_insides_of_a_spatial_performance_tool_Live_4_Life)), concerts (ICMC 2017, [JIM 2019](https://www.youtube.com/watch?v=NfWXF6copEs)), festivals (Ultrasons from 2016 to 2021, Akousma 2021), or in the  Journal of Music and Technology [Organised Sound](https://doi.org/10.1017/S135577182100008X) (April 2021).

All the papers are also published on [Researchgate](https://www.researchgate.net/profile/Christophe-Lengele) or [ORCID](https://orcid.org/my-orcid?orcid=0000-0002-9114-6632), as well as my doctoral thesis, soon to be published (in french, sorry) about spatial improvisations based on polyrhythms and sequences of parameters in loop via this tool.

Several performances are available either on [YouTube](https://www.youtube.com/channel/UCOv5kb3IQBmgyOQPu5DOZ4g) or [Vimeo](https://vimeo.com/christophexon).


## Contribute

I have a lot of features I would like to improve or develop, such as the collection of synthDefs (with e.g. [some mutable instruments eurorack modules](https://github.com/v7b1/mi-UGens/tree/v0.0.1) or [plugins from Mads Kjeldgaard](https://github.com/madskjeldgaard/portedplugins)), as well as the rhythmic pattern generator from [Eurorack module Grids by Mutable Instruments](https://github.com/capital-G/sc-grids)...

If you would like to contribute, please get in touch with me in order to organise further development. The code management or installation process can be greatly improved, but for now I prefer to focus on rhythmic music features and performance.

Feel free to post an issue, and you can also send me a mail first since it might be a functionality not explained (a more complete wiki will come), or try to send a pull request, since depending on my priorities I may not have not the time or the ability to solve it.

<mark> You can also support thanks to donations via [**Ko-fi**](https://ko-fi.com/live4life) or get specific support and courses via [**Patreon**](https://www.patreon.com/live4life)</mark>. :grin:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Z8Z1C1NDP)

[![Support me on Patreon](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fshieldsio-patreon.vercel.app%2Fapi%3Fusername%3DLive4Life%26type%3Dpatrons&style=for-the-badge)](https://patreon.com/Live4Life)

<!-- Introduire un un bouton Patreon
https://shieldsio-patreon.vercel.app
https://github.com/endel/shieldsio-patreon/blob/master/README.md
-->

<!-- Introduire un gif...
![](https://giphy.com/gifs/devonstern-water-c4d-ripple-ToMjGpjm9vQhsB4cqVa)
<img src="https://media.giphy.com/media/vFKqnCdLPNOKc/giphy.gif" width="40" height="40" />
-->


## Acknowledgements

***Live 4 Life*** grew little by little, by gluing and restructuring a lot of code from others and integrating several systems and quarks. I would have been unable to build this tool without the help of the SuperCollider online community, who always answered my questions and even provided me with some examples of codes and classes.

So, Big Thanks to (including previous and current developers):

[James Harkins](https://github.com/jamshark70), [Daniel Mayer](https://github.com/dkmayer), [Fredrik Olofsson](https://github.com/redFrik), [Julian Rohrhuber](https://github.com/telephon), [Josh Parmenter](https://github.com/joshpar), [Wouter Snoei](https://github.com/woutersnoei), [Nick Collins](https://github.com/sicklincoln), [Jakob Leben](https://github.com/jleben), [Chris Sattinger](https://github.com/crucialfelix), [Dan Stowell](https://github.com/danstowell), [Scott Wilson](https://github.com/muellmusik), [Joseph Anderson](https://github.com/joslloand), [Miguel Negrão](https://github.com/miguel-negrao), [Scott Carver](https://github.com/scztt), [Alberto de Campo](https://github.com/adcxyz), [Marije Baalman](https://github.com/sensestage), [Brian Heim](https://github.com/mossheim), [Marcin Pączkowski](https://github.com/dyfer) ...


The list might be long. Sorry for those I forgot to mention. I cannot quote all of them.

By giving soon this tool, it is my way to contribute to SuperCollider.
And I encourage anyone (DSP developers or any user) to support this beautiful environment.


## Licence

© 2011-2022 Christophe Lengelé

***Live 4 Life*** is an open source software: you can redistribute it and/or modify it under the terms of **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license** (CC BY-NC-SA 4.0). 

You may **not** use it for commercial purposes.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY. 

I wish it would be used in the spirit of *Free Party*. Unfortunately, *Free* does not mean free in this commercial world, but invites to contribute to the costs and labor according to one's ability to give. I do not want this tool to be used, by any means, for personal profit.

Moreover, I would **not** like that this tool to be used by [Société des Arts Technologiques](https://sat.qc.ca) and its Metalab without my consent, since this organization never helped me in diffusing my spatial creation and research in their dome despite my proposals. If these wishes are not respected, your souls will be damned for eternity.

See the [License](/LICENCE.md) for more details.
