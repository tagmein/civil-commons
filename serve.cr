set ( fs, http ) [ global import, call ( fs/promises, node:http ) ]

set port [ global process env PORT, default 4567 ]

set i [ function x [
 get fs readFile, call [ get x ]
] ]

set get-mime-type [
 function path [
  get path, pick [
   value [ at endsWith, call .svg ]
   value 'image/svg+xml'
  ] [
   value [ at endsWith, call .html ]
   value 'text/html'
  ] [
   value [ at endsWith, call .css ]
   value 'text/css'
  ] [
   value [ at endsWith, call .js ]
   value 'application/javascript'
  ] [
   value [ at endsWith, call .json ]
   value 'application/json'
  ] [
   value [ at endsWith, call .png ]
   value 'image/png'
  ] [
   value [ at endsWith, call .jpg ]
   value 'image/jpeg'
  ] [
   value [ at endsWith, call .jpeg ]
   value 'image/jpeg'
  ] [
   value [ at endsWith, call .gif ]
   value 'image/gif'
  ] [
   value [ at endsWith, call .ico ]
   value 'image/x-icon'
  ] [
   value [ at endsWith, call .cr ]
   value 'text/plain'
  ] [
   true
   value 'application/octet-stream'
  ]
 ]
]

set handler [
 function request response [
  set respond [
   function status value mimeType [
    set response statusCode [ get status ]
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
    is /web.cr
    get respond, call 200 [
     get i, call ./web.cr ] text/plain
   ] [
    value [ at startsWith, call /app ]
    set file-path [
     template '.%0' [ get request url ]
    ]
    set mime-type [
     get get-mime-type, call [ get file-path ]
    ]
    get respond, call 200 [
     get i, call [ get file-path ]
    ] [ get mime-type ]
   ] [
    value [ at startsWith, call /core ]
    set file-path [
     template '.%0' [ get request url ]
    ]
    set mime-type [
     get get-mime-type, call [ get file-path ]
    ]
    get respond, call 200 [
     get i, call [ get file-path ]
    ] [ get mime-type ]
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
