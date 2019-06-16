/*
**  slideshow -- Observe and Control Slideshow Applications
**  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
**
**  This Source Code Form is subject to the terms of the Mozilla Public
**  License (MPL), version 2.0. If a copy of the MPL was not distributed
**  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

/* global module: true */
module.exports = function (grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON("package.json"),
        jshint: {
            options: {
                jshintrc: "jshint.json"
            },
            gruntfile:   [ "Gruntfile.js" ],
            sourcefiles: [ "slideshow-*.js" ]
        },
        eslint: {
            options: {
                configFile: "eslint.json"
            },
            target: [ "slideshow-*.js" ]
        },
        clean: {
            clean:     [ ],
            distclean: [ "node_modules" ]
        }
    });

    grunt.loadNpmTasks("grunt-contrib-jshint");
    grunt.loadNpmTasks("grunt-contrib-clean");
    grunt.loadNpmTasks("grunt-eslint");

    grunt.registerTask("default", [ "jshint", "eslint" ]);
};

