# *Live 4 Life* ![Licence](https://licensebuttons.net/l/by-nc-sa/3.0/88x31.png)


To come soon!


| [**Overview**](#overview) | [**Usage**](#usage) | [**Requirements**](#requirements) | [**Installation**](#installation) | [**References**](#references) | [**Contribute**](#contribute) | [**Licence**](#licence) |


## Overview

The **spatial performance tool** *Live 4 Life*, which is in constant development under the Mac platform, aims to simplify the creation and control in real time of mass of spatialised sound objects on various kinds of loudspeaker configurations (particularly stereo, quadriphonic or octophonic setups, as well as domes of 16, 24 or 32 loudspeakers...). 

I have been developing in **SuperCollider** since 2011, to play the place and the music at the same time.


<p align="center">
<b>The performance tool in context with all its controllers</b>
<!--<a href="#> <b>The performance tool in context with all its controllers</b> </a> <br> -->
<img src="images/Controllers2021bis.jpg" />
</p>

<p align="center">
<b>One of the views of the GUI to choose among dozens of sequences and global parameters</b>
<img src="images/ViewGlobal.jpg" />
</p>

<p align="center">
<b>Another view of the GUI to compose the details of sequences of spatialised sound events</b>
<img src="images/ViewSeq.jpg" />
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

* although the code is available here, the interface and the setup are relatively complex, as this tool is not meant to be a simple graphic user interface (GUI) for a casual, untrained user of SuperCollider, but focused to allow the creation of a lot of combinations tailored to my creative dreams.

* it is designed for a specific screen size (1920×1200) and an AZERTY keyboard.

* ...


### Platform support

*Live 4 Life* has only been tested with macOS 10.14.6 Mojave on a MacBook Pro 15". 
It will soon be optimized for MacOS M1 16".

The reason why I do not switch from Mac to Linux is that I often used [Dante](https://www.audinate.com/products) to send multiple channels via ethernet in some concert halls. Since Dante virtual sound cards are not available for linux, you need to buy specific expensive sound cards to use Dante.

It might work for Linux and Windows platforms after solving some issues. 
Several years ago, I succeeded to make it work on Linux: I remember I had to change and limit `numWireBufs_` to some values, like 800, in the file `1_Init Buffer Synths`, since MacOS seem to accept very high values without generating errors. Since then, there may probably be other errors on Linux.
For Windows, I do not know, since currently I do not have a simple access to both of them.
Let me know. I might maybe help.


## Requirements

* [SuperCollider 3.12.1](https://supercollider.github.io/download)

* many Quarks:

  - Twister 


## Installation


## Contribute


## References

*Live 4 Life* has been presented many times during conferences ([JIM 2017](https://jim2017.sciencesconf.org/data/Lengele2017aa.pdf), [ICMC 2018](https://quod.lib.umich.edu/cgi/p/pod/dod-idx/live-4-life-a-spatial-performance-tool-focused-on-rhythm.pdf?c=icmc;idno=bbp2372.2018.057;format=pdf), ICMC 2021), concerts (ICMC 2017, [JIM 2019](https://www.youtube.com/watch?v=NfWXF6copEs)), festivals (Ultrasons from 2016 to 2021, Akousma 2021), or in the  Journal of Music and Technology [Organised Sound](https://doi.org/10.1017/S135577182100008X).

All the papers are also published on [Researchgate](https://www.researchgate.net/profile/Christophe-Lengele), as well as my doctoral thesis, soon to be published about realtime creation of spatialised polyrhythms via this tool.

Several performances are available either on [YouTube](https://www.youtube.com/channel/UCOv5kb3IQBmgyOQPu5DOZ4g) or [Vimeo](https://vimeo.com/christophexon).


## Licence

© 2011-2021 Christophe Lengelé

*Live 4 Life* is an open source software: you can redistribute it and/or modify it under the terms of **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license** (CC BY-NC-SA 4.0). 

You may **not** use it for commercial purposes.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY. 

I wish it would be used in the spirit of *Free Party*. Unfortunately, *Free* does not mean free in this commercial world, but invites to contribute to the costs and labor according to one's ability to give. I do not want this tool to be used, by any means, for personal profit.

Moreover, I would **not** like that this tool to be used by [Société des Arts Technologiques](https://sat.qc.ca) without my consent, since this organization never helped me in diffusing my spatial creation and research despite my proposals. If these wishes are not respected, your souls will be damned for eternity.

See the [License](/LICENCE.md) for more details.
