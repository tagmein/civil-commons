# Tests for PATCH /api/sessions/:sessionId/documents/:documentId - Update document

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './test-data-docs-update'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load the route handler
set api-documents-update [ load ./documents-update.cr, point ]

# Clean up test data
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-update'
set doc-id 'test-doc-update'

# Create test document
set doc-dir [ template '%0/sessions/%1/documents/%2' [ get test-data-path ] [ get session-id ] [ get doc-id ] ]
get ensure-dir, call [ get doc-dir ]
get oj, call [ template '%0/metadata.json' [ get doc-dir ] ] [
 object [ name 'Original Name', archived false, createdAt 10000 ]
]
get o, call [ template '%0/content.txt' [ get doc-dir ] ] 'Original content'

get describe, call 'PATCH /api/sessions/:sessionId/documents/:documentId' [
 function [
  get it, call 'should return 404 for non-existent document' [
   function [
    set response-data [ object [ status null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
     ]
    ]
    
    get api-documents-update, call [ object ] [ get mock-respond ] [ get session-id ] 'nonexistent' [ object [ name 'New' ] ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 404
   ]
  ]
  
  get it, call 'should update document name' [
   function [
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get doc-id ] [
     object [ name 'Updated Name' ]
    ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Updated Name'
    
    # Verify file was updated
    set metadata [ get ij, call [ template '%0/metadata.json' [ get doc-dir ] ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Updated Name'
   ]
  ]
  
  get it, call 'should update document archived status' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get doc-id ] [
     object [ archived true ]
    ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed archived ] true
   ]
  ]
  
  get it, call 'should update document content' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get doc-id ] [
     object [ content 'New content here' ]
    ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed content ] 'New content here'
    
    # Verify file was updated
    set content [ get i, call [ template '%0/content.txt' [ get doc-dir ] ] ]
    get expect, call [ get to-equal ] [ get content ] 'New content here'
   ]
  ]
 ]
]

get cleanup, call
