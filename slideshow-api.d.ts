/*!
**  slideshow -- Observe and Control Slideshow Applications
**  Copyright (c) 2014-2023 Dr. Ralf S. Engelschall <http://engelschall.com>
**
**  This Source Code Form is subject to the terms of the Mozilla Public
**  License (MPL), version 2.0. If a copy of the MPL was not distributed
**  with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
**
**  File:     slideshow-api.d.ts
**  Purpose:  Application Programming Interface (API) Defimition
**  Language: TypeScript
*/

export default class Slideshow {
    constructor (application: string)
    request (request: any):     Promise<any>
    stat    ():                 Promise<{ state: string, position: number, slides: number }>
    info    ():                 Promise<{ titles: string[], notes: string[] }>
    boot    ():                 Promise<"OK">
    quit    ():                 Promise<"OK">
    open    (filename: string): Promise<"OK">
    close   ():                 Promise<"OK">
    start   ():                 Promise<"OK">
    stop    ():                 Promise<"OK">
    pause   ():                 Promise<"OK">
    resume  ():                 Promise<"OK">
    first   ():                 Promise<"OK">
    last    ():                 Promise<"OK">
    goto    (slide: number):    Promise<"OK">
    prev    ():                 Promise<"OK">
    next    ():                 Promise<"OK">
    end     ():                 void
}

