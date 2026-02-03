# Tests for GET /api/sessions/:id - Get single session

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './tests/api/test-data-get'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load route handlers
set api-sessions-create [ load ./sessions-create.cr, point ]
set api-sessions-get [ load ./sessions-get.cr, point ]

# Clean up test data
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

get describe, call 'GET /api/sessions/:id' [
 function [
  get it, call 'should return session metadata for valid id' [
   function [
    # Create a session first
    set create-response [ object [ body null ] ]
    set create-respond [
     function status body mime [
      set create-response body [ get body ]
     ]
    ]
    get api-sessions-create, call [ object ] [ get create-respond ]
    
    set created [ global JSON parse, call [ get create-response body ] ]
    set session-id [ get created id ]
    
    # Get the session
    set response-data [ object [ status null, body null, mime null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
      set response-data mime [ get mime ]
     ]
    ]
    
    get api-sessions-get, call [ object ] [ get mock-respond ] [ get session-id ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    get expect, call [ get to-equal ] [ get response-data mime ] application/json
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed id ] [ get session-id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Untitled'
    get expect, call [ get to-equal ] [ get parsed archived ] false
   ]
  ]
  
  get it, call 'should return 404 for non-existent session' [
   function [
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-sessions-get, call [ object ] [ get mock-respond ] 'nonexistent-id'
    
    get expect, call [ get to-equal ] [ get response-data status ] 404
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed error ] 'Session not found'
   ]
  ]
 ]
]

get cleanup, call
