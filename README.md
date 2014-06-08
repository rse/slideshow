
Slideshow
=========

Observe and Control Slideshow Applications

<p/>
<img src="https://nodei.co/npm/slideshow.png?downloads=true&stars=true" alt=""/>

<p/>
<img src="https://david-dm.org/rse/slideshow.png" alt=""/>

Abstract
--------

Slideshow is a [Node](http://nodejs.org/)/JavaScript API for observing and controlling
the presentation applications
[Microsoft PowerPoint 2010/2013 for Windows](http://office.microsoft.com/en-us/powerpoint/),
[Microsoft PowerPoint 2011 for Mac OS X](http://www.microsoft.com/mac/powerpoint) and
[Apple KeyNote 5/6 for Mac OS X](http://www.apple.com/mac/keynote/).
It can determine the current state of the application, gather information
about the slides and control the application's slideshow mode.
It is implemented as a thin Node/JavaScript API layer on
top of platform-specific WSH/JScript and AppleScript connectors.
No native code is required.

Architecture
------------

The architecture of Slideshow fulfills the following constraints:

1. *No Native Code*: There should be no native code required because
   this is nasty (especially under Windows) during module installation
   time (because a compiler is required). The solution is to leverage
   the scripting environment of the particular platform (Windows
   Scripting Host and AppleScript).

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

Installation
------------

Use the Node Package Manager (NPM) to install this module
locally (default) or globally (with option `-g`):

    $ npm install [-g] slideshow

License
-------

Copyright (c) 2014 Ralf S. Engelschall &lt;http://engelschall.com&gt;

This Source Code Form is subject to the terms of the Mozilla Public
License (MPL), version 2.0. If a copy of the MPL was not distributed
with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

