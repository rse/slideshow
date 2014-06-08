--
--  slideshow -- Observe and Control Slideshow Applications
--  Copyright (c) 2014 Ralf S. Engelschall <http://engelschall.com>
--
--  This Source Code Form is subject to the terms of the Mozilla Public
--  License (MPL), version 2.0. If a copy of the MPL was not distributed
--  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
--  File:     connector-osx-keynote.js
--  Purpose:  connector engine for Apple Keynote under Mac OS X
--  Language: AppleScript
--

--  utility function
on offsetOf(theString, subString)
    if theString does not contain subString then
        return 0
    end if
    set stringCharacterCount    to (get count of characters in theString)
    set substringCharacterCount to (get count of characters in subString)
    set lastCharacter to (stringCharacterCount - substringCharacterCount + 1)
    repeat with n from 1 to lastCharacter
        set m to (n + substringCharacterCount) - 1
        set currentSubstring to (get characters n thru m of theString) as string
        if currentSubstring is subString then
            return n
        end if
    end repeat
    return 0
end offsetOf

--  get Apple Keynote current slide
on knGetCurSlide()
    try
        tell application "Keynote"
            return (get slide number of current slide of front document)
        end tell
    on error errMsg
        return 0
    end try
end knGetCurSlide

--  get Apple Keynote maximum slide
on knGetMaxSlide()
    try
        tell application "Keynote"
            return (get count of slides of front document)
        end tell
    on error errMsg
        return 0
    end try
end knGetMaxSlide

--  get Apple Keynote current slide
on knGetSlideInfo()
    try
        tell application "Keynote"
            set thePresentation to front document
            set slideCount to (get count of slides of thePresentation)
            set slideInfo to "[ "
            repeat with slideNum from 1 to slideCount
                set theSlide to slide slideNum of thePresentation
                set theNote to ""
                repeat with theChars in (presenter notes of theSlide)
                    set theText to ("" & (theChars as string) & "")
                    set offStart to my offsetOf(theText, "TK<")
                    if offStart is not 0 then
                        set offStart to (offStart + 3)
                        set tmp to (get characters offStart thru ((get count of characters in theText)) of theText) as string
                        set offEnd to my offsetOf(tmp, ">")
                        if offEnd is not 0 and offENd is not 1 then
                            set theNote to (get characters offStart thru (offStart + (offEnd - 1) - 1) of theText) as string
                            exit repeat
                        end if
                    end if
                end repeat
                if slideInfo is "[ " then
                    set slideInfo to (slideInfo & "\"" & theNote & "\"")
                else
                    set slideInfo to (slideInfo & ", \"" & theNote & "\"")
                end if
            end repeat
            set slideInfo to (slideInfo & " ]")
            return slideInfo
        end tell
    on error errMsg
        return "[]"
    end try
end knGetSlideInfo

--  get Apple Keynote slide titles
on knGetSlideTitles()
    -- try
        tell application "Keynote"
            set thePresentation to front document
            set slideCount to (get count of slides of thePresentation)
            set slideTitles to "[ "
            repeat with slideNum from 1 to slideCount
                set theSlide to slide slideNum of thePresentation
                set theTitle to object text of default title item of theSlide
                if slideTitles is "[ " then
                    set slideTitles to (slideTitles & "\"" & theTitle & "\"")
                else
                    set slideTitles to (slideTitles & ", \"" & theTitle & "\"")
                end if
            end repeat
            set slideTitles to (slideTitles & " ]")
            return slideTitles
        end tell
    -- on error errMsg
        return 0
    -- end try
end knGetCurSlide

--  control slide show
on knSlideShowControl(command, arg)
    tell application "Keynote"
        if command is "START" then
            start (front document) from (slide 1 of front document)
        else if command is "NEXT" then
            show next
        else if command is "GOTO" then
            show slide (arg as integer) of front document
        else if command is "PREV" then
            show previous
        else if command is "STOP" then
            stop front document
        end if
    end tell
end knSlideShowControl

--  main procedure
on run argv
    set cmd to item 1 of argv
    set arg to ""
    if count of argv is 2 then
        set arg to item 2 of argv
    end if
    if cmd is "STAT" then
        set curSlide to knGetCurSlide()
        set maxSlide to knGetMaxSlide()
        set output to ("{ \"curSlide\": " & curSlide & ", \"maxSlide\": " & maxSlide & " }")
    else if cmd is "INFO" then
        set slideInfo to knGetSlideInfo()
        set output to ("{ \"slideInfo\": " & slideInfo & " }")
    else if cmd is "TITLES" then
        set theTitles to knGetSlideTitles()
        set output to ("{ \"titles\": " & theTitles & " }")
    else if cmd is "START" or cmd is "NEXT" or cmd is "GOTO" or cmd is "PREV" or cmd is "STOP" then
        my knSlideShowControl(cmd, arg)
        set output to "{}"
    end if
    copy output to stdout
end run

