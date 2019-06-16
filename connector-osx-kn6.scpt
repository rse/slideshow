--
--  slideshow -- Observe and Control Slideshow Applications
--  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
--
--  This Source Code Form is subject to the terms of the Mozilla Public
--  License (MPL), version 2.0. If a copy of the MPL was not distributed
--  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
--  File:     connector-osx-kn6.scpt
--  Purpose:  connector engine for Apple Keynote 6 under Mac OS X
--  Language: AppleScript
--

--  utility function
on filterText(this_text, allowed_chars)
   set new_text to ""
   repeat with this_char in this_text
       set x to the offset of this_char in allowed_chars
       if x is not 0 then
           set new_text to (new_text & this_char) as string
       end if
   end repeat
   return new_text
end filterText

--  utility function
on replaceText(this_text, search_string, replacement_string)
   set AppleScript's text item delimiters to the search_string
   set the item_list to every text item of this_text
   set AppleScript's text item delimiters to the replacement_string
   set this_text to the item_list as string
   set AppleScript's text item delimiters to ""
   return this_text
end replace_chars

--  utility function
on asciiCharset()
    set charset to " \"'!#$%()*+,-./:;<=>?@[\\]^_{|}~"
    set charset to (charset & "0123456789")
    set charset to (charset & "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    set charset to (charset & "abcdefghijklmnopqrstuvwxyz")
    return charset
end asciiCharset

--  get application state
on knGetState()
    set state to "closed"
    tell application "System Events"
        set is_running to (exists (some process whose name is "Keynote"))
    end tell
    if is_running then
       try
            set state to "running"
            tell application "Keynote"
                if false then -- FIXME: how to detect play mode?
                    set state to "viewing"
                else if (get count of slides of front document) > 0 then
                    set state to "editing"
                end if
            end tell
        on error errMsg
        end try
    end if
    return state
end knGetState

--  get Apple Keynote current slide
on knGetCurSlide()
    try
        tell application "Keynote"
            if false then -- FIXME: how to detect play mode?
                return (get slide number of current slide of front document) -- FIXME: wrong!
            else
                return (get slide number of current slide of front document)
            end if
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

--  the STATE command
on cmdSTATE()
    set state to knGetState()
    if state is "closed" then
        set position to 0
        set slides to 0
    else
        set position to knGetCurSlide()
        set slides to knGetMaxSlide()
    end if
    return ("{ \"response\": { " & ¬
        "\"state\": \"" & state & "\", " & ¬
        "\"position\": " & position & ", " & ¬
        "\"slides\": " & slides & " " & ¬
    "} }")
end cmdSTATE

--  the INFO command
on cmdINFO()
    set output to ""
    if knGetMaxSlide() is 0 then
        error "still no active presentation"
    end if
    tell application "Keynote"
        set thePresentation to front document
        set theTitles to ""
        set theNotes to ""
        set slideCount to (get count of slides of thePresentation)
        repeat with slideNum from 1 to slideCount
            set theSlide to slide slideNum of thePresentation

            set theTitle to (get object text of default title item of theSlide) as string
            if theTitles is not "" then
                set theTitles to (theTitles & ", ")
            end if
            set theTitles to (theTitles & "\"" & (my replaceText(theTitle, "\"", "\\\"")) & "\"")

            set theNote to (presenter notes of theSlide) as string
            set theNote to (my filterText(theNote, my asciiCharset()))
            if theNotes is not "" then
                set theNotes to (theNotes & ", ")
            end if
            set theNotes to (theNotes & "\"" & (my replaceText(theNote, "\"", "\\\"")) & "\"")

        end repeat
        set theTitles to ("[ " & theTitles & " ]")
        set theNotes to ("[ " & theNotes & " ]")
        set output to ("{ \"response\": { \"titles\": " & theTitles & ", \"notes\": " & theNotes & " } }")
    end tell
    return output
end cmdINFO

--  the control commands
on cmdCTRL(command, arg)
    set state to knGetState()
    if command is "BOOT" then
        if state is not "closed" then
            error "application already running"
        end if
        tell application "Keynote"
            activate
        end tell
    else if command is "QUIT" then
        if state is "closed" then
            error "application already closed"
        end if
        tell application "Keynote"
            quit
        end tell
    else if command is "OPEN" then
        if state is "editing" or state is "viewing" then
            error "active presentation already existing"
        end if
        tell application "Keynote"
            tell application "Finder" to set thePath to ¬
                POSIX file (POSIX path of (container of (path to me) as string) & (arg)) as alias
            open thePath
        end tell
    else if command is "CLOSE" then
        if state is "closed" or state is "running" then
            error "still no active presentation"
        end if
        tell application "Keynote"
            close front document
        end tell
    else if command is "START" then
        if state is "closed" or state is "running" then
            error "still no active presentation"
        end if
        if state is "viewing" then
            error "active presentation already viewing"
        end if
        tell application "Keynote"
            start front document from (slide 1 of front document)
        end tell
    else if command is "STOP" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            stop front document
        end tell
    else if command is "PAUSE" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            activate
            tell application "System Events" to keystroke "b"
        end tell
    else if command is "RESUME" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            activate
            tell application "System Events" to keystroke "b"
        end tell
    else if command is "FIRST" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            repeat with i from 1 to (my knGetMaxSlide())
                try
                    show previous
                on error errMsg
                    exit repeat
                end try
                delay 0.02
            end repeat
        end tell
    else if command is "LAST" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            repeat with i from 1 to ((my knGetMaxSlide()) - 1)
                try
                    show next
                on error errMsg
                    exit repeat
                end try
                delay 0.02
            end repeat
        end tell
    else if command is "GOTO" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            repeat with i from 1 to (my knGetMaxSlide())
                try
                    show previous
                on error errMsg
                    exit repeat
                end try
                delay 0.02
            end repeat
            repeat with i from 1 to ((arg as integer) - 1)
                try
                    show next
                end try
                delay 0.02
            end repeat
        end tell
    else if command is "PREV" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            show previous
        end tell
    else if command is "NEXT" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Keynote"
            show next
        end tell
    end if
    return "{ \"response\": \"OK\" }"
end cmdCTRL

--  main procedure
on run argv
    set cmd to item 1 of argv
    set arg to ""
    if count of argv is 2 then
        set arg to item 2 of argv
    end if
    try
        if cmd is "STAT" then
            set output to cmdSTATE()
        else if cmd is "INFO" then
            set output to cmdINFO()
        else if cmd is "BOOT" ¬
            or cmd is "QUIT" ¬
            or cmd is "OPEN" ¬
            or cmd is "CLOSE" ¬
            or cmd is "START" ¬
            or cmd is "STOP" ¬
            or cmd is "PAUSE" ¬
            or cmd is "RESUME" ¬
            or cmd is "FIRST" ¬
            or cmd is "LAST" ¬
            or cmd is "GOTO" ¬
            or cmd is "PREV" ¬
            or cmd is "NEXT" then
            set output to cmdCTRL(cmd, arg)
        else
            set output to "{ \"error\": \"invalid command\" }"
        end if
    on error errMsg
        set output to ("{ \"error\": \"" & errMsg & "\" }")
    end try
    copy output to stdout
end run

