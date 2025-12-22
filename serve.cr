set fs [ global import, call fs/promises ]
set http [ global import, call node:http ]

set port [ global process env PORT, default 4567 ]

set i [ function x [
 get fs readFile, call [ get x ]
] ]

set handler [
 function request response [
  set respond [
   function status value mimeType [
    set [ get response ] statusCode [ get status ]
    get mimeType, true [
     get response setHeader, call Content-Type [ get mimeType ]
    ]
    get response end, call [ get value ]
   ]
  ]

  log [ get request method ] [ get request url ]

  try [
   # Routes
   get request url, pick [
    is /
    get respond, call 200 [ get i, call index.html ] text/html
   ] [
    is /favicon.ico
    get respond, call 200 [ get i, call favicon.ico ] image/x-icon
   ] [
    is /crown.js
    get respond, call 200 [
     get i, call crown, 
     at toString, call utf-8
     at split, call '/* UNIFIED */ ', at 1
    ] application/javascript
   ] [
    do [ at startsWith, call /app ]
    get respond, call 200 [
     get i, call [
     template '.%0' [ get request url ]
    ] ] text/plain
   ] [
    true 
    get respond, call 404 [ object [ error 'Not Found' ] ]
   ]
  ] [
   get respond, call 500 [ object [ error [ current_error ] ] ]
  ]
 ]
]

set server [
 get http createServer, call [ get handler ]
]

get server listen, call [ get port ] [
 function [
  log server listening on port [ get port ]
 ]
]
