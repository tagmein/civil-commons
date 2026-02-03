# Tests for PATCH /api/sessions/:id - Update session

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './test-data-update'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load route handlers
set api-sessions-create [ load ./sessions-create.cr, point ]
set api-sessions-update [ load ./sessions-update.cr, point ]
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

get describe, call 'PATCH /api/sessions/:id' [
 function [
  get it, call 'should update session name' [
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
    
    # Update the session name
    set response-data [ object [ status null, body null, mime null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
      set response-data mime [ get mime ]
     ]
    ]
    
    set update-body [ object [ name 'My New Session Name' ] ]
    get api-sessions-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get update-body ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    get expect, call [ get to-equal ] [ get response-data mime ] application/json
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed name ] 'My New Session Name'
   ]
  ]
  
  get it, call 'should update session archived status' [
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
    
    # Archive the session
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    set update-body [ object [ archived true ] ]
    get api-sessions-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get update-body ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed archived ] true
   ]
  ]
  
  get it, call 'should update both name and archived' [
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
    
    # Update both fields
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    set update-body [ object [ name 'Archived Session', archived true ] ]
    get api-sessions-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get update-body ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Archived Session'
    get expect, call [ get to-equal ] [ get parsed archived ] true
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
    
    set update-body [ object [ name 'New Name' ] ]
    get api-sessions-update, call [ object ] [ get mock-respond ] 'nonexistent-id' [ get update-body ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 404
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed error ] 'Session not found'
   ]
  ]
  
  get it, call 'should persist changes to metadata file' [
   function [
    # Create a session
    set create-response [ object [ body null ] ]
    set create-respond [
     function status body mime [
      set create-response body [ get body ]
     ]
    ]
    get api-sessions-create, call [ object ] [ get create-respond ]
    
    set created [ global JSON parse, call [ get create-response body ] ]
    set session-id [ get created id ]
    
    # Update the session
    set mock-respond [ function status body mime [ ] ]
    set update-body [ object [ name 'Persisted Name' ] ]
    get api-sessions-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get update-body ]
    
    # Read the metadata file directly
    set metadata-file [ template '%0/sessions/%1/metadata.json' [ get test-data-path ] [ get session-id ] ]
    set metadata [ get ij, call [ get metadata-file ] ]
    
    get expect, call [ get to-equal ] [ get metadata name ] 'Persisted Name'
   ]
  ]
 ]
]

get cleanup, call
