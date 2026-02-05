# Tests for GET /api/sessions/:sessionId/documents/:documentId - Get document

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './test-data-docs-get'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load the route handler
set api-documents-get [ load ./documents-get.cr, point ]

# Clean up test data
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-get'
set doc-id 'test-doc-get'

get describe, call 'GET /api/sessions/:sessionId/documents/:documentId' [
 function [
  get it, call 'should return 404 for non-existent document' [
   function [
    get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
    
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-get, call [ object ] [ get mock-respond ] [ get session-id ] 'nonexistent'
    
    get expect, call [ get to-equal ] [ get response-data status ] 404
   ]
  ]
  
  get it, call 'should return document with metadata and content' [
   function [
    set doc-dir [ template '%0/sessions/%1/documents/%2' [ get test-data-path ] [ get session-id ] [ get doc-id ] ]
    get ensure-dir, call [ get doc-dir ]
    
    get oj, call [ template '%0/metadata.json' [ get doc-dir ] ] [
     object [ name 'Test Doc', archived false, createdAt 12345 ]
    ]
    get o, call [ template '%0/content.txt' [ get doc-dir ] ] 'Hello World'
    
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-get, call [ object ] [ get mock-respond ] [ get session-id ] [ get doc-id ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed id ] [ get doc-id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Test Doc'
    get expect, call [ get to-equal ] [ get parsed archived ] false
    get expect, call [ get to-equal ] [ get parsed content ] 'Hello World'
   ]
  ]
 ]
]

get cleanup, call
