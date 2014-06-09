
slideshow () {
    node slideshow-cli.js "$@"
}

slideshow powerpoint boot
slideshow powerpoint open sample.pptx
slideshow powerpoint start
slideshow powerpoint goto 2
sleep 2
slideshow powerpoint stop
slideshow powerpoint close
slideshow powerpoint quit

