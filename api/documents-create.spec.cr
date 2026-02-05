# Tests for POST /api/sessions/:sessionId/documents - Create document

set fs [ global import, call fs/promises ]

# Setup test data directory
set test-data-path './test-data-docs-create'

# Load io module and override data-path
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

# Load the route handler
set api-documents-create [ load ./documents-create.cr, point ]

# Clean up test data before and after
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

# Create a test session first
set session-id 'test-session-123'
get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]

get describe, call 'POST /api/sessions/:sessionId/documents' [
 function [
  get it, call 'should create a new document with default name' [
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
    
    get api-documents-create, call [ get mock-request ] [ get mock-respond ] [ get session-id ]
    
    get expect, call [ get to-equal ] [ get response-data status ] 201
    get expect, call [ get to-equal ] [ get response-data mime ] application/json
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    
    get expect, call [ get to-be-defined ] [ get parsed id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Untitled Document'
    get expect, call [ get to-equal ] [ get parsed archived ] false
    get expect, call [ get to-be-defined ] [ get parsed createdAt ]
   ]
  ]
  
  get it, call 'should add document id to documents.json' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-create, call [ object ] [ get mock-respond ] [ get session-id ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    set doc-id [ get parsed id ]
    
    set docs-file [ template '%0/sessions/%1/documents.json' [ get test-data-path ] [ get session-id ] ]
    set docs [ get ij, call [ get docs-file ] ]
    
    set found [ object [ value false ] ]
    get docs, each [
     function id [
      get id, is [ get doc-id ], true [
       set found value true
      ]
     ]
    ]
    get expect, call [ get to-be-true ] [ get found value ]
   ]
  ]
  
  get it, call 'should create metadata file for document' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-create, call [ object ] [ get mock-respond ] [ get session-id ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    set doc-id [ get parsed id ]
    
    set metadata-file [ template '%0/sessions/%1/documents/%2/metadata.json' [ get test-data-path ] [ get session-id ] [ get doc-id ] ]
    get expect, call [ get to-be-true ] [ get file-exists, call [ get metadata-file ] ]
    
    set metadata [ get ij, call [ get metadata-file ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Untitled Document'
    get expect, call [ get to-equal ] [ get metadata archived ] false
   ]
  ]
  
  get it, call 'should create empty content file' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    
    get api-documents-create, call [ object ] [ get mock-respond ] [ get session-id ]
    
    set parsed [ global JSON parse, call [ get response-data body ] ]
    set doc-id [ get parsed id ]
    
    set content-file [ template '%0/sessions/%1/documents/%2/content.txt' [ get test-data-path ] [ get session-id ] [ get doc-id ] ]
    get expect, call [ get to-be-true ] [ get file-exists, call [ get content-file ] ]
    
    set content [ get i, call [ get content-file ] ]
    get expect, call [ get to-equal ] [ get content ] ''
   ]
  ]
 ]
]

get cleanup, call
