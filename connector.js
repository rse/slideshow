/*
**  slideshow -- Observe and Control Slideshow Applications
**  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
**
**  This Source Code Form is subject to the terms of the Mozilla Public
**  License (MPL), version 2.0. If a copy of the MPL was not distributed
**  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
**
**  File:     connector.js
**  Purpose:  low-level connector
**  Language: Node/JavaScript
*/

/*  thid-party requirements  */
var os       = require("os");
var path     = require("path");
var spawn    = require("child_process").spawn;
var es       = require("event-stream");
var Promise  = require("bluebird");

/*  the supported connectors  */
var connectors = {
    "darwin-keynote":        "connector-osx-kn5.sh",
    "darwin-keynote5":       "connector-osx-kn5.sh",
    "darwin-keynote6":       "connector-osx-kn6.sh",
    "darwin-powerpoint":     "connector-osx-ppt2011.sh",
    "darwin-powerpoint2011": "connector-osx-ppt2011.sh",
    "darwin-powerpoint2016": "connector-osx-ppt2011.sh",
    "win32-powerpoint":      "connector-win-ppt2010.bat",
    "win32-powerpoint2010":  "connector-win-ppt2010.bat",
    "win32-powerpoint2013":  "connector-win-ppt2010.bat"
};

/*  the connector API constructor  */
var connector = function (application) {
    /*  determine connector filename  */
    var id = os.platform() + "-" + application;
    var cn = connectors[id];
    if (typeof cn === "undefined")
        throw new Error("unsupported platform/application combination: " + id);
    var filename = path.join(__dirname, cn);

    /*  spawn the connector as a child process  */
    this.c = spawn(filename, [], {
        stdio: [ "pipe", "pipe", process.stderr ],
        env: { "CONNECTOR": "FIXME" }
    });

    /*  set the stdin/stdout pipes to UTF-8 encoding mode  */
    this.c.stdin.setEncoding("utf8");
    this.c.stdout.setEncoding("utf8");

    /*  create line-based duplex stream out of stdin/stdout piples  */
    this.io = es.duplex(
        this.c.stdin,
        this.c.stdout.pipe(es.split(/\r?\n/))
    );

    /*  connect to the stream for capturing responses  */
    this.responses = [];
    this.io.pipe(es.through(function onData (data) {
        if (typeof data === "undefined" || data === "")
            return;
        var response = this.responses.shift();
        if (typeof response === "function")
            response(data);
    }.bind(this), function onEnd () {
        /*  currently nothing to do?!  */
    }));
};

/*  the connector API methods  */
connector.prototype = {
    request: function (request) {
        var promise = Promise.pending();
        this.responses.push(function (response) {
            try {
                response = JSON.parse(response);
            }
            catch (ex) {
                promise.reject("Invalid response type from connector: " + ex);
            }
            if (typeof response.error === "string")
                promise.reject(response.error);
            else if (typeof response.response !== "undefined")
                promise.resolve(response.response);
            else
                promise.reject("Invalid response structure from connector");
        });
        this.io.write(JSON.stringify(request) + "\r\n");
        return promise.promise;
    },
    end: function () {
        this.io.end();
    }
};

/*  export the API  */
module.exports = connector;
