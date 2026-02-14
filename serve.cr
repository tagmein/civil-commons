set ( fs, http ) [ global import, call ( fs/promises, node:http ) ]

set port [ global process env PORT, default 4567 ]

# Load shared I/O module - variables cascade to loaded API routes
set io [ load ./api/io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]

# Load API route handlers
set api-sessions-create [ load ./api/sessions-create.cr, point ]
set api-sessions-list [ load ./api/sessions-list.cr, point ]
set api-sessions-get [ load ./api/sessions-get.cr, point ]
set api-sessions-update [ load ./api/sessions-update.cr, point ]
set api-sessions-log [ load ./api/sessions-log.cr, point ]

# Document API route handlers
set api-documents-list [ load ./api/documents-list.cr, point ]
set api-documents-create [ load ./api/documents-create.cr, point ]
set api-documents-get [ load ./api/documents-get.cr, point ]
set api-documents-update [ load ./api/documents-update.cr, point ]
set api-gemini-generate [ load ./api/gemini-generate.cr, point ]

# Helper to read raw file (without toString for binary files)
set i-raw [ function x [
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

# Read request body as string
set read-body [ function request [
 global Promise, new [
  function resolve reject [
   set chunks [ list ]
   get request on, call data [
    function chunk [
     get chunks push, call [ get chunk ]
    ]
   ]
   get request on, call end [
    function [
     set body-string [
      global Buffer concat, call [ get chunks ]
      at toString, call utf-8
     ]
     get resolve, call [ get body-string ]
    ]
   ]
   get request on, call error [
    function err [
     get reject, call [ get err ]
    ]
   ]
  ]
 ]
] ]

# Parse JSON body safely
set parse-json-body [ function body [
 set result [ object [ data null, error null ] ]
 get body length, > 0, true [
  try [
   set result data [ global JSON parse, call [ get body ] ]
  ] [
   set result error 'Invalid JSON'
  ]
 ]
 get result
] ]

# Extract session ID from URL path like /api/sessions/abc123
set extract-session-id [ function url [
 get url, at split, call /, at 3
] ]

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
   # API Routes - handle /api/sessions endpoints
   set handled [ object [ value false ] ]
   
   get request url, is /api/sessions, true [
    get request method, is POST, true [
     set handled value true
     get api-sessions-create, call [ get request ] [ get respond ]
    ], false [
     get request method, is GET, true [
      set handled value true
      get api-sessions-list, call [ get request ] [ get respond ]
     ]
    ]
   ]
   
   get handled value, false [
    get request url, at startsWith, call /api/sessions/, true [
     set session-id [ get extract-session-id, call [ get request url ] ]
     
     # Parse URL parts: /api/sessions/:id/...
     set url-parts [ get request url, at split, call / ]
     set sub-resource [ get url-parts, at 4 ]
     
     # Check for documents endpoint: /api/sessions/:id/documents
     get sub-resource, is documents, true [
      set handled value true
      set doc-id [ get url-parts, at 5 ]
      
      get doc-id, true [
       # Single document operations: /api/sessions/:id/documents/:docId
       get request method, is GET, true [
        get api-documents-get, call [ get request ] [ get respond ] [ get session-id ] [ get doc-id ]
       ], false [
        get request method, is PATCH, true [
         set body-text [ get read-body, call [ get request ] ]
         set parsed [ get parse-json-body, call [ get body-text ] ]
         get parsed error, true [
          get respond, call 400 [
           global JSON stringify, call [ object [ error [ get parsed error ] ] ]
          ] application/json
         ], false [
          get api-documents-update, call [ get request ] [ get respond ] [ get session-id ] [ get doc-id ] [ get parsed data ]
         ]
        ]
       ]
      ], false [
       # Collection operations: /api/sessions/:id/documents
       get request method, is GET, true [
        get api-documents-list, call [ get request ] [ get respond ] [ get session-id ]
       ], false [
        get request method, is POST, true [
         get api-documents-create, call [ get request ] [ get respond ] [ get session-id ]
        ]
       ]
      ]
     ]
     
     # Check if this is a log endpoint: /api/sessions/:id/log or /api/sessions/:id/log/:index
     get handled value, false [
      get sub-resource, is log, true [
       set handled value true
       get request method, is GET, true [
        # GET /api/sessions/:id/log
        set result [ get api-sessions-log get-handler, call [ get session-id ] ]
        get respond, call 200 [
         global JSON stringify, call [ get result ]
        ] application/json
       ], false [
        get request method, is POST, true [
         get url-parts, at 5, is 'skip-last', true [
          # POST /api/sessions/:id/log/skip-last - mark last event with action as skipped
          set body-text [ get read-body, call [ get request ] ]
          set parsed [ get parse-json-body, call [ get body-text ] ]
          get parsed error, true [
           get respond, call 400 [
            global JSON stringify, call [ object [ error [ get parsed error ] ] ]
           ] application/json
          ], false [
           set result [ get api-sessions-log skip-last-handler, call [ get session-id ] [ get parsed data ] ]
           get result error, true [
            get respond, call [ get result status ] [
             global JSON stringify, call [ object [ error [ get result error ] ] ]
            ] application/json
           ], false [
            get respond, call 200 [
             global JSON stringify, call [ get result ]
            ] application/json
           ]
          ]
         ], false [
          # POST /api/sessions/:id/log
          set body-text [ get read-body, call [ get request ] ]
          set parsed [ get parse-json-body, call [ get body-text ] ]
          get parsed error, true [
           get respond, call 400 [
            global JSON stringify, call [ object [ error [ get parsed error ] ] ]
           ] application/json
          ], false [
           set result [ get api-sessions-log post-handler, call [ get session-id ] [ get parsed data ] ]
           get respond, call 201 [
            global JSON stringify, call [ get result ]
           ] application/json
          ]
         ]
        ], false [
         get request method, is 'PATCH', true [
          get url-parts, at 5, is 'by-index', true [
           # PATCH /api/sessions/:id/log/by-index/:index
           set index [ get url-parts, at 6 ]
           set body-text [ get read-body, call [ get request ] ]
           set parsed [ get parse-json-body, call [ get body-text ] ]
           get parsed error, true [
            get respond, call 400 [
             global JSON stringify, call [ object [ error [ get parsed error ] ] ]
            ] application/json
           ], false [
            set result [ get api-sessions-log patch-by-index-handler, call [ get session-id ] [ get index ] [ get parsed data ] ]
            get result error, true [
             get respond, call [ get result status ] [
              global JSON stringify, call [ object [ error [ get result error ] ] ]
             ] application/json
            ], false [
             get respond, call 200 [
              global JSON stringify, call [ get result ]
             ] application/json
            ]
           ]
          ], false [
           # PATCH /api/sessions/:id/log/:eventId
           set event-id [ get url-parts, at 5 ]
           set body-text [ get read-body, call [ get request ] ]
           set parsed [ get parse-json-body, call [ get body-text ] ]
           get parsed error, true [
            get respond, call 400 [
             global JSON stringify, call [ object [ error [ get parsed error ] ] ]
            ] application/json
           ], false [
            set result [ get api-sessions-log patch-handler, call [ get session-id ] [ get event-id ] [ get parsed data ] ]
            get result error, true [
             get respond, call [ get result status ] [
              global JSON stringify, call [ object [ error [ get result error ] ] ]
             ] application/json
            ], false [
             get respond, call 200 [
              global JSON stringify, call [ get result ]
             ] application/json
            ]
           ]
          ]
         ], false [
          get request method, is DELETE, true [
           # DELETE /api/sessions/:id/log/:index
           set event-index [ get url-parts, at 5 ]
           set result [ get api-sessions-log delete-handler, call [ get session-id ] [ get event-index ] ]
           get result error, true [
            get respond, call [ get result status ] [
             global JSON stringify, call [ object [ error [ get result error ] ] ]
            ] application/json
           ], false [
            get respond, call 200 [
             global JSON stringify, call [ get result ]
            ] application/json
           ]
          ]
         ]
        ]
       ]
      ]
     ]
     
     # Regular session endpoint (no sub-resource)
     get handled value, false [
      get sub-resource, false [
       get request method, is GET, true [
        set handled value true
        get api-sessions-get, call [ get request ] [ get respond ] [ get session-id ]
       ], false [
        get request method, is PATCH, true [
         set handled value true
         set body-text [ get read-body, call [ get request ] ]
         set parsed [ get parse-json-body, call [ get body-text ] ]
         get parsed error, true [
          get respond, call 400 [
           global JSON stringify, call [ object [ error [ get parsed error ] ] ]
          ] application/json
         ], false [
          get api-sessions-update, call [ get request ] [ get respond ] [ get session-id ] [ get parsed data ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
   
   get request url, is /api/gemini-generate, true [
    get request method, is POST, true [
     set handled value true
     get api-gemini-generate, call [ get request ] [ get respond ]
    ]
   ]
   
   # Static routes
   get handled value, false [
    get request url, pick [
     is /
    get respond, call 200 [ get i-raw, call index.html ] text/html
   ] [
    is /favicon.ico
    get respond, call 200 [ get i-raw, call favicon.ico ] image/x-icon
   ] [
    is /crown.js
    get respond, call 200 [
     get i-raw, call crown, 
     at toString, call utf-8
     at split, call '/* UNIFIED */ ', at 1
    ] application/javascript
   ] [
    is /web.cr
    get respond, call 200 [
     get i-raw, call ./web.cr ] text/plain
   ] [
    value [ at startsWith, call /app ]
    set file-path [
     template '.%0' [ get request url ]
    ]
    set mime-type [
     get get-mime-type, call [ get file-path ]
    ]
    get respond, call 200 [
     get i-raw, call [ get file-path ]
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
     get i-raw, call [ get file-path ]
    ] [ get mime-type ]
   ] [
    true 
    get respond, call 404 [
     global JSON stringify, call [ object [ error 'Not Found' ] ]
    ] application/json
   ]
   ]
  ] [
   log Error: [ current_error ]
   get respond, call 500 [
    global JSON stringify, call [ object [ error [ current_error ] ] ]
   ] application/json
  ]
 ]
]

# Check if running in test mode
# is_test is set by tests.cr before loading spec files
set test-mode [ get is_test, default false ]

# Only start the server if NOT in test mode
get test-mode, = true, false [
 set server [
  get http createServer, call [ get handler ]
 ]

 get server listen, call [ get port ] [
  function [
   log server listening on port [ get port ]
  ]
 ]
]

# Export object with testable functions (always returned)
object [
 get-mime-type
 parse-json-body
 extract-session-id
 handler
]
