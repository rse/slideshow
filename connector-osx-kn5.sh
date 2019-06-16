#!/bin/sh
##
##  slideshow -- Observe and Control Slideshow Applications
##  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
##
##  This Source Code Form is subject to the terms of the Mozilla Public
##  License (MPL), version 2.0. If a copy of the MPL was not distributed
##  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
##
##  File:     connector-osx-kn5.sh
##  Purpose:  connector wrapper for Apple Keynote 5 under Mac OS X
##  Language: Bourne-Shell
##

#   determine base directory
case "$0" in
    /*  ) basedir=`echo $0 | sed -e 's;/[^/][^/]*$;;'` ;;
    */* ) basedir="`pwd`/`echo $0 | sed -e 's;/[^/][^/]*$;;'`" ;;
    * )
        OIFS=$IFS; IFS=":"
        for dir in $PATH; do
            IFS=$OIFS
            if [ -x "$dir/$0" ]; then
                basedir=$dir
                break
            fi
        done
        IFS=$OIFS
        ;;
esac
basedir=`echo "$basedir" | sed -e 's;/\.$;;g'`
basedir=`echo "$basedir" | sed -e 's;/\./;/;g'`
basedir=`echo "$basedir" | sed -e 's;/[^/][^/]*/\.\./;/;g'`
basedir=`echo "$basedir" | sed -e 's;/[^/][^/]*/\.\.$;;g'`

#   provide the stdin loop
#   (because AppleScript is not easily able to do this)
while true; do
    #   read request
    read request
    if [ ".$request" = . ]; then
        break
    fi
    command=`echo "$request" | sed -e 's;^.*command": *"\([^"]*\)".*$;\1;'`

    #   let AppleScript produce the response
    osascript "$basedir/connector-osx-kn5.scpt" $command
done

