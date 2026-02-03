# Tests for POST /api/sessions - Create session

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './tests/api/test-data-create'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load the route handler
set api-sessions-create [ load ./sessions-create.cr, point ]

# Clean up test data before and after
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

get describe, call 'POST /api/sessions' [
 function [
  get it, call 'should create a new session with default name Untitled' [
   function [
    set response-data [ object [ status null, body null, mime null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
      set response-data mime [ get mime ]
     ]
    ]
    set mock-request [ object ]
    
    get api-sessions-create, call [ get mock-request ] [ get mock-respond ]
    
    # Check response status
    get expect, call [ get to-equal ] [ get response-data status ] 201
    
    # Check response has JSON content type
    get expect, call [ get to-equal ] [ get response-data mime ] application/json
    
    # Parse response body
    set parsed [ global JSON parse, call [ get response-data body ] ]
    
    # Check session has id
    get expect, call [ get to-be-defined ] [ get parsed id ]
    
    # Check default name is Untitled
    get expect, call [ get to-equal ] [ get parsed name ] 'Untitled'
    
    # Check archived is false
    get expect, call [ get to-equal ] [ get parsed archived ] false
    
    # Check createdAt exists
    get expect, call [ get to-be-defined ] [ get parsed createdAt ]
   ]
  ]
  
  get it, call 'should add session id to sessions.json' [
   function [
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-sessions-create, call [ object ] [ get mock-respond ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    set session-id [ get parsed id ]
    
    # Check sessions.json contains the id
    set sessions-file [ template '%0/sessions.json' [ get test-data-path ] ]
    set sessions [ get ij, call [ get sessions-file ] ]
    
    set found [ object [ value false ] ]
    get sessions, each [
     function id [
      get id, is [ get session-id ], true [
       set found value true
      ]
     ]
    ]
    get expect, call [ get to-be-true ] [ get found value ]
   ]
  ]
  
  get it, call 'should create metadata file for session' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-sessions-create, call [ object ] [ get mock-respond ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    set session-id [ get parsed id ]
    
    # Check metadata file exists
    set metadata-file [ template '%0/sessions/%1/metadata.json' [ get test-data-path ] [ get session-id ] ]
    get expect, call [ get to-be-true ] [ get file-exists, call [ get metadata-file ] ]
    
    # Check metadata content
    set metadata [ get ij, call [ get metadata-file ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Untitled'
    get expect, call [ get to-equal ] [ get metadata archived ] false
   ]
  ]
 ]
]

# Cleanup after tests
get cleanup, call
