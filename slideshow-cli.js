/*
**  slideshow -- Observe and Control Slideshow Applications
**  Copyright (c) 2014 Ralf S. Engelschall <http://engelschall.com>
**
**  This Source Code Form is subject to the terms of the Mozilla Public
**  License (MPL), version 2.0. If a copy of the MPL was not distributed
**  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
**
**  File:     slideshow-cli.js
**  Purpose:  Command Line Interface (CLI)
**  Language: Node/JavaScript
*/

var slideshow = require("./slideshow-api");

var apps = {
    "powerpoint": true,
    "keynote":    true
};

var commands = {
    "use":    [ "application-type" ],
    "stat":   [],
    "info":   [],
    "boot":   [],
    "quit":   [],
    "open":   [ "presentation-filename" ],
    "close":  [],
    "start":  [],
    "stop":   [],
    "black":  [],
    "normal": [],
    "first":  [],
    "last":   [],
    "goto":   [ "slide-number" ],
    "prev":   [],
    "next":   []
};

var readline = require("readline");

var ss = null;

var rl = readline.createInterface({
    input:  process.stdin,
    output: process.stdout
});
rl.setPrompt("slideshow> ");
rl.prompt();
rl.on("line", function (line) {
    var argv = line.trim().split(/\s+/);
    var info = commands[argv[0]];
    if (typeof info === "undefined")
        console.log("slideshow: ERROR: invalid command");
    else if (info.length !== (argv.length - 1))
        console.log("slideshow: ERROR: invalid number of arguments (expected: " + info.join(" ") + ")");
    else {
        if (argv[0] === "use") {
            if (typeof apps[argv[1]] === "undefined")
                console.log("slideshow: ERROR: invalid argument (expected: " + Object.keys(apps).join(", ") + ")");
            else {
                if (ss !== null)
                    ss.end();
                ss = new slideshow(argv[1]);
                rl.setPrompt("slideshow(" + argv[1] + ")> ");
            }
        }
        else {
            slideshow[argv[0]](argv[1]).then(function (response) {
                console.log("slideshow: " + JSON.stringify(response));
            }, function (error) {
                console.log("slideshow: ERROR: " + error);
            })
        }
    }
    rl.prompt();
}).on("close", function() {
    console.log("");
    process.exit(0);
});

