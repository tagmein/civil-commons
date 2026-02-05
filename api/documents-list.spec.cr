# Tests for GET /api/sessions/:sessionId/documents - List documents

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './test-data-docs-list'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load the route handler
set api-documents-list [ load ./documents-list.cr, point ]

# Clean up test data
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-list'

get describe, call 'GET /api/sessions/:sessionId/documents' [
 function [
  get it, call 'should return empty array when no documents' [
   function [
    get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
    
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-list, call [ object ] [ get mock-respond ] [ get session-id ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 200
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-be-array ] [ get parsed ]
    get expect, call [ get to-equal ] [ get parsed length ] 0
   ]
  ]
  
  get it, call 'should return documents with metadata' [
   function [
    # Create documents.json and document metadata
    set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
    get ensure-dir, call [ get session-dir ]
    
    set doc-ids [ list 'doc-1' 'doc-2' ]
    get oj, call [ template '%0/documents.json' [ get session-dir ] ] [ get doc-ids ]
    
    # Create metadata for doc-1
    get ensure-dir, call [ template '%0/documents/doc-1' [ get session-dir ] ]
    get oj, call [ template '%0/documents/doc-1/metadata.json' [ get session-dir ] ] [
     object [ name 'First Doc', archived false, createdAt 1000 ]
    ]
    
    # Create metadata for doc-2
    get ensure-dir, call [ template '%0/documents/doc-2' [ get session-dir ] ]
    get oj, call [ template '%0/documents/doc-2/metadata.json' [ get session-dir ] ] [
     object [ name 'Second Doc', archived true, createdAt 2000 ]
    ]
    
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-list, call [ object ] [ get mock-respond ] [ get session-id ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed length ] 2
    get expect, call [ get to-equal ] [ get parsed, at 0, at name ] 'First Doc'
    get expect, call [ get to-equal ] [ get parsed, at 1, at name ] 'Second Doc'
    get expect, call [ get to-equal ] [ get parsed, at 1, at archived ] true
   ]
  ]
 ]
]

get cleanup, call
