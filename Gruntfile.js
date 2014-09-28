
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
                config: "eslint.json"
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

