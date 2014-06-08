
var slideshow = require("./slideshow")

var ss = new slideshow("powerpoint")

setInterval(function () {
    ss.stat().then(function (response) {
        console.log("STAT: " + JSON.stringify(response))
    })
    ss.info().then(function (response) {
        console.log("INFO: " + JSON.stringify(response))
    })
}, 1000)

