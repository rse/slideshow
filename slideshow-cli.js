#!/usr/bin/env node
/*
**  slideshow -- Observe and Control Slideshow Applications
**  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
**
**  This Source Code Form is subject to the terms of the Mozilla Public
**  License (MPL), version 2.0. If a copy of the MPL was not distributed
**  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
**
**  File:     slideshow-cli.js
**  Purpose:  Command Line Interface (CLI)
**  Language: Node/JavaScript
*/

/* global require: false */
/* global console: false */
/* global process: false */

/*  external requirements  */
var readline  = require("readline");
var chalk     = require("chalk");
var slideshow = require("./slideshow-api");

/*  define the known applications  */
var apps = {
    "powerpoint":     true,
    "powerpoint2011": true,
    "powerpoint2013": true,
    "powerpoint2016": true,
    "keynote":        true,
    "keynote5":       true,
    "keynote6":       true
};

/*  define the known commands (and their argument)  */
var commands = {
    /*  CLI-specific  */
    "help":   [],
    "use":    [ "application-type" ],

    /*  API-derived  */
    "stat":   [],
    "info":   [],
    "boot":   [],
    "quit":   [],
    "open":   [ "presentation-filename" ],
    "close":  [],
    "start":  [],
    "stop":   [],
    "pause":  [],
    "resume": [],
    "first":  [],
    "last":   [],
    "goto":   [ "slide-number" ],
    "prev":   [],
    "next":   []
};

/*  the interactive CLI variant  */
var cliInteractive = function () {
    /*  start with a non-existing slideshow  */
    var ss = null;

    /*  create the stdin/stdout based readline interface  */
    var rl = readline.createInterface({
        input:  process.stdin,
        output: process.stdout
    });

    /*  provide CLI  */
    rl.setPrompt("slideshow> ");
    rl.prompt();
    rl.on("line", function (line) {
        /*  determine command  */
        var argv = line.trim().split(/\s+/);
        var info = commands[argv[0]];
        var prompt = true;
        if (typeof info === "undefined")
            console.log(chalk.red("ERROR: invalid command (use \"help\" for usage)"));
        else if (info.length !== (argv.length - 1))
            console.log(chalk.red("ERROR: invalid number of arguments (expected: " + info.join(" ") + ")"));
        else {
            /*  process CLI-specific commands  */
            if (argv[0] === "help")
                Object.keys(commands).forEach(function (cmd) {
                    console.log(chalk.green("    " + cmd + " " + (
                        commands[cmd].map(function (arg) { return "<" + arg + ">"; }).join(" ")
                    )));
                });
            else if (argv[0] === "use") {
                if (typeof apps[argv[1]] === "undefined")
                    console.log(chalk.red("ERROR: invalid argument (expected: " + Object.keys(apps).join(", ") + ")"));
                else {
                    if (ss !== null)
                        ss.end();
                    ss = new slideshow(argv[1]);
                    rl.setPrompt("slideshow(" + argv[1] + ")> ");
                }
            }

            /*  process API-derived commands  */
            else {
                if (ss === null)
                    console.log(chalk.red("ERROR: you have to choose with \"use\" an application first"));
                else {
                    ss[argv[0]](argv[1]).then(function (response) {
                        console.log(chalk.green(JSON.stringify(response, null, "    ")));
                        rl.prompt();
                    }, function (error) {
                        console.log(chalk.red("ERROR: " + error));
                        rl.prompt();
                    });
                    prompt = false;
                }
            }
        }

        /*  provide prompt for next iteration  */
        if (prompt)
            rl.prompt();
    });

    /*  gracefully stop CLI  */
    rl.on("close", function() {
        console.log("");
        process.exit(0);
    });
};

/*  the batch CLI variant  */
var cliBatch = function (argv) {
    if (argv.length === 1 && argv[0] === "help") {
        Object.keys(commands).forEach(function (cmd) {
            if (cmd !== "use" && cmd !== "help") {
                console.log(chalk.green("slideshow <application> " + cmd + " " + (
                    commands[cmd].map(function (arg) { return "<" + arg + ">"; }).join(" ")
                )));
            }
        });
        process.exit(0);
    }
    if (argv.length < 2) {
        console.log(chalk.red("ERROR: invalid number of arguments (use \"help\" for usage)"));
        process.exit(1);
    }
    if (typeof apps[argv[0]] === "undefined") {
        console.log(chalk.red("ERROR: invalid application (expected: " + Object.keys(apps).join(", ") + ")"));
        process.exit(1);
    }
    var ss = new slideshow(argv[0]);
    var info = commands[argv[1]];
    if (typeof info === "undefined") {
        console.log(chalk.red("ERROR: invalid connector command (use \"help\" for usage)"));
        process.exit(1);
    }
    else if (info.length !== (argv.length - 2)) {
        console.log(chalk.red("ERROR: invalid number of connector arguments (expected: " + info.join(" ") + ")"));
        process.exit(1);
    }
    ss[argv[1]](argv[2]).then(function (response) {
        console.log(chalk.green(JSON.stringify(response, null, "    ")));
        process.exit(0);
    }, function (error) {
        console.log(chalk.red("ERROR: " + error));
        process.exit(1);
    });
};

/*  dispatch according to type of operation  */
if (process.argv.length === 2)
    cliInteractive();
else
    cliBatch(process.argv.splice(2));

