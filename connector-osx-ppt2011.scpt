--
--  slideshow -- Observe and Control Slideshow Applications
--  Copyright (c) 2014-2019 Dr. Ralf S. Engelschall <http://engelschall.com>
--
--  This Source Code Form is subject to the terms of the Mozilla Public
--  License (MPL), version 2.0. If a copy of the MPL was not distributed
--  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
--  File:     connector-osx-ppt2011.js
--  Purpose:  connector engine for Microsoft PowerPoint 2011 under Mac OS X
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
on pptGetState()
    set state to "closed"
    tell application "System Events"
        set is_running to (exists (some process whose name is "Microsoft PowerPoint"))
    end tell
    if is_running then
       try
            set state to "running"
            tell application "Microsoft PowerPoint"
                set theState to (slide state of slide show view of slide show window of active presentation)
                if theState is (slide show state running) or theState is (slide show state paused) then
                    set state to "viewing"
                else if (exists active presentation) then
                    set state to "editing"
                end if
            end tell
        on error errMsg
        end try
    end if
    return state
end pptGetState

--  get current slide
on pptGetCurSlide()
    try
        tell application "Microsoft PowerPoint"
            if slide state of slide show view of slide show window of active presentation is slide show state running then
                --  currently in running slide show mode (for production)
                set curSlide to (slide number of slide of slide show view of slide show window of active presentation)
            else
                --  currently in editing mode (for testing)
                set curSlide to (slide number of slide range of selection of document window 1)
            end if
            return curSlide
        end tell
    on error errMsg
        return 0
    end try
end pptGetCurSlide

--  get maximum slide
on pptGetMaxSlide()
    try
        tell application "Microsoft PowerPoint"
            set maxSlide to (get count of slides of presentation of document window 1)
            return maxSlide
        end tell
    on error errMsg
        return 0
    end try
end pptGetMaxSlide

--  the STATE command
on cmdSTATE()
    set state to pptGetState()
    if state is "closed" then
        set position to 0
        set slides to 0
    else
        set position to pptGetCurSlide()
        set slides to pptGetMaxSlide()
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
    if pptGetMaxSlide() is 0 then
        error "still no active presentation"
    end if
    tell application "Microsoft PowerPoint"
        set thePresentation to presentation of document window 1
        set theTitles to ""
        set theNotes to ""
        set slideCount to (get count of slides of thePresentation)
        repeat with slideNum from 1 to slideCount
            set theSlide to slide slideNum of thePresentation

            set theTitle to ""
            repeat with t_shape in (get shapes of theSlide)
                set aType to (placeholder type of t_shape)
                if (aType is placeholder type center title placeholder) or (aType is placeholder type title placeholder) then
                    tell t_shape to if has text frame then tell its text frame to if has text then
                        set theText to (content of its text range as string) as string
                        set theText to (my filterText(theText, my asciiCharset()))
                        if theTitle is not "" then
                            set theTitle to (theTitle & " ")
                        end if
                        set theTitle to (theTitle & theText)
                    end if
                end if
            end repeat
            if theTitles is not "" then
                set theTitles to (theTitles & ", ")
            end if
            set theTitles to (theTitles & "\"" & (my replaceText(theTitle, "\"", "\\\"")) & "\"")

            set theNote to ""
            repeat with t_shape in (get shapes of notes page of theSlide)
                set aType to (placeholder type of t_shape)
                if (aType is placeholder type body placeholder) then
                    tell t_shape to if has text frame then tell its text frame to if has text then
                        set theText to (content of its text range as string) as string
                        set theText to (my filterText(theText, my asciiCharset()))
                        if theNote is not "" then
                            set theNote to (theNote & " ")
                        end if
                        set theNote to (theNote & theText)
                    end if
                end if
            end repeat
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
    set state to pptGetState()
    if command is "BOOT" then
        if state is not "closed" then
            error "application already running"
        end if
        tell application "Microsoft PowerPoint"
            activate
        end tell
    else if command is "QUIT" then
        if state is "closed" then
            error "application already closed"
        end if
        tell application "Microsoft PowerPoint"
            quit
        end tell
    else if command is "OPEN" then
        if state is "editing" or state is "viewing" then
            error "active presentation already existing"
        end if
        tell application "Microsoft PowerPoint"
            tell application "Finder" to set thePath to ¬
                POSIX file (POSIX path of (container of (path to me) as string) & (arg)) as alias
            open thePath
        end tell
    else if command is "CLOSE" then
        if state is "closed" or state is "running" then
            error "still no active presentation"
        end if
        tell application "Microsoft PowerPoint"
            close active presentation
        end tell
    else if command is "START" then
        if state is "closed" or state is "running" then
            error "still no active presentation"
        end if
        if state is "viewing" then
            error "active presentation already viewing"
        end if
        tell application "Microsoft PowerPoint"
            set slideShowSettings to slide show settings of active presentation
            set slideShowSettings's starting slide to 1
            set slideShowSettings's ending slide to 1
            set slideShowSettings's range type to slide show range
            set slideShowSettings's show type to slide show type speaker
            set slideShowSettings's advance mode to slide show advance manual advance
            run slide show slideShowSettings -- BUGGY: starts blank
        end tell
    else if command is "STOP" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            exit slide show (slideshow view of slide show window 1)
        end tell
    else if command is "PAUSE" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            set slide state of (slideshow view of slide show window 1) to (slide show state black screen)
        end tell
    else if command is "RESUME" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            -- set slide state of (slideshow view of slide show window 1) to (slide show state paused)
            go to slide (view of document window 1) number ¬
                (slide number of slide of slide show view of slide show window of active presentation)
        end tell
    else if command is "FIRST" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            go to first slide (slideshow view of slide show window 1)
        end tell
    else if command is "LAST" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            go to last slide (slideshow view of slide show window 1)
        end tell
    else if command is "GOTO" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            go to slide (view of document window 1) number (arg as integer) -- BUGGY: does not do anything
        end tell
    else if command is "PREV" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            go to previous slide (slideshow view of slide show window 1)
        end tell
    else if command is "NEXT" then
        if state is not "viewing" then
            error "no active slideshow"
        end if
        tell application "Microsoft PowerPoint"
            go to next slide (slideshow view of slide show window 1)
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

