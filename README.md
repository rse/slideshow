
Slideshow
=========

Observe and Control Slideshow Applications

<p/>
<img src="https://nodei.co/npm/slideshow.png?downloads=true&stars=true" alt=""/>

<p/>
<img src="https://david-dm.org/rse/slideshow.png" alt=""/>

Abstract
--------

Slideshow is a [Node](http://nodejs.org/)/JavaScript Application Programming Interface
(API) and Command Line Interface (CLI) for observing and controlling
the slideshow presentation applications
[Microsoft PowerPoint 2010/2013/2016 for Windows](http://office.microsoft.com/en-us/powerpoint/),
[Microsoft PowerPoint 2011/2016 for Mac OS X](http://www.microsoft.com/mac/powerpoint) and
[Apple KeyNote 5/6 for Mac OS X](http://www.apple.com/mac/keynote/).
It can determine the current state of the application, gather information
about the slides and control the application's slideshow mode.
It is implemented as a thin Node/JavaScript API layer on
top of platform-specific Windows WSH/JScript and Mac OS X Automator AppleScript/JavaScript connectors.
No native code is required.

Installation
------------

Use the Node Package Manager (NPM) to install this module
locally (default) or globally (with option `-g`):

    $ npm install [-g] slideshow

Usage
-----

```sh
#   CLI variant
slideshow powerpoint boot
slideshow powerpoint open sample.pptx
slideshow powerpoint start
slideshow powerpoint goto 2
sleep 2
slideshow powerpoint stop
slideshow powerpoint close
slideshow powerpoint quit
```

```js
//  API variant
var SlideShow = require("slideshow")
var slideshow = new SlideShow("powerpoint")
slideshow.boot()
.then(function () { slideshow.open("sample.pptx") })
.then(function () { slideshow.start() })
.then(function () { slideshow.goto(2) })
.delay(2*1000)
.then(function () { slideshow.stop() })
.then(function () { slideshow.close() })
.then(function () { slideshow.quit() })
.then(function () { slideshow.end() })
.done()
```

Architecture
------------

The architecture of Slideshow fulfills the following constraints:

1. *No Native Code*: There should be no native code required because
   this is nasty (especially under Windows) during module installation
   time (because a compiler is required). The solution is to leverage
   the scripting environment of the particular platform (Windows
   Scripting Host (WSH) under Windows and AppleScript under Mac OS X).

2. *Separate Platform Specifics*: The platform specific code should be kept separate
   (because else the infrastructure code would have to be duplicated).
   The solution is the splitting as seen below.

3. *Universal Platform Interface*: The communication between the Node process and the
   platform specific process should be universal
   (because else we need multiple communication variants).
   The solution is to use simple `stdio` based communication.

The architecture in particular looks like this:

    +-------------------------------------------------+
    |  node                                           |
    +-------------------------------------------------+
    +-------------------------------------------------+
    |  Slideshow CLI (slideshow-cli.js) or App        |
    +-------------------------------------------------+
    +-------------------------------------------------+
    |  Slideshow API (slideshow-api.js)               |
    +-------------------------------------------------+
    +-------------------------------------------------+
    |  Connector API (connector.js)                   |
    +-------------------------------------------------+
          |              |              |
    +------------+ +------------+ +------------+ +-- -
    |command.com | |sh          | |sh          | |
    +------------+ +------------+ +------------+ +-- -
    +------------+ +------------+ +------------+ +-- -
    |win-ppt.bat | |osx-ppt.sh  | |osx-kn.sh   | |
    +------------+ +------------+ +------------+ +-- -
          |             |             |
    +------------+ +------------+ +------------+ +-- -
    |cscript     | |osascript   | |osascript   | |
    +------------+ +------------+ +------------+ +-- -
    +------------+ +------------+ +------------+ +-- -
    |win-ppt.js  | |osx-ppt.scpt| |osx-kn.scpt | |
    +------------+ +------------+ +------------+ +-- -

Presentation Application Support Status
---------------------------------------

- **SUPPORTED**: Microsoft PowerPoint 2010 under Windows:<br/>
  Fully supported through `connector-win-ppt2010`, which uses
  Windows Scripting Host (WST)'s JScript engine and the
  Component Object Model (COM) of PowerPoint.

- **SUPPORTED**: Microsoft PowerPoint 2013 under Windows:<br/>
  Expected to be supported (but not tested by the author) through
  `connector-win-ppt2010`, which uses Windows Scripting Host (WST)'s JScript
  engine and the Component Object Model (COM) of PowerPoint.

- **SUPPORTED**: Microsoft PowerPoint 2016 under Windows:<br/>
  Expected to be supported (but not tested by the author) through
  `connector-win-ppt2010`, which uses Windows Scripting Host (WST)'s JScript
  engine and the Component Object Model (COM) of PowerPoint.

- **SUPPORTED**: Microsoft PowerPoint 2011 under Mac OS X:<br/>
  Fully supported through `connector-osx-ppt2011`, which uses AppleScript
  engine and the application Dictionary of the PowerPoint:mac variant.

- **SUPPORTED**: Microsoft PowerPoint 2016 under Mac OS X:<br/>
  Fully supported through `connector-osx-ppt2011`, which uses AppleScript
  engine and the application Dictionary of the PowerPoint:mac variant.

- **SUPPORTED**: Apple Keynote 5 under Mac OS X:<br/>
  Fully supported through `connector-osx-kn5`, which uses AppleScript
  engine and the application Dictionary of Keynote.

- **PARTIALLY SUPPORTED**: Apple Keynote 6 under Mac OS X:<br/>
  Partially supported through `connector-osx-kn6`, which uses AppleScript
  engine and the application Dictionary of Keynote. Currently partially
  broken up to at least Keynote 6.2.2 (August 2014), because the
  AppleScript support in Keynote 6 still lacks many things Keynote 5
  already supported. The main problem currently is that one cannot
  detect whether a slideshow is playing and that slide changing is
  reflected in AppleScript only once the Keynote window lost its focus.

- STILL UNSUPPORTED: LibreOffice 4 Impress under Windows/Mac OS X/Linux:<br/>
  Currently not supported, but there are two possible
  approaches for the future: the newer [LibreOffice Impress Remote Protocol](http://cgit.freedesktop.org/libreoffice/core/tree/sd/README_REMOTE)
  or the older [Universal Network Objects (UNO)](https://wiki.openoffice.org/wiki/Uno) Java interface.

- STILL UNSUPPORTED: OpenOffice 4 Impress under Windows/Mac OS X/Linux:<br/>
  Currently not supported, but there is one possible
  approach for the future: the [Universal Network Objects (UNO)](https://wiki.openoffice.org/wiki/Uno) Java interface.

License
-------

Copyright (c) 2014-2019 Dr. Ralf S. Engelschall &lt;http://engelschall.com&gt;

This Source Code Form is subject to the terms of the Mozilla Public
License (MPL), version 2.0. If a copy of the MPL was not distributed
with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

