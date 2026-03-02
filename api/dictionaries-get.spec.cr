# Tests for GET /api/sessions/:sessionId/dictionaries/:dictId - Get dictionary

set fs [ global import, call fs/promises ]

set test-data-path './test-data-dicts-get'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-dictionaries-get [ load ./dictionaries-get.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-get'
set dict-id 'dict-abc'
get ensure-dir, call [ template '%0/sessions/%1/dictionaries/%2' [ get test-data-path ] [ get session-id ] [ get dict-id ] ]
get oj, call [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] [
 object [ name 'Test Dict', archived false, createdAt [ global Date now, call ] ]
]
get oj, call [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] [
 object [ term1 [ object [ type 'value', id 'val-123' ] ], term2 [ object [ type 'document', id 'doc-456' ] ] ]
]

get describe, call 'GET /api/sessions/:sessionId/dictionaries/:dictId' [
 function [
  get it, call 'should return dictionary with metadata and entries' [
   function [
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]

    get api-dictionaries-get, call [ object ] [ get mock-respond ] [ get session-id ] [ get dict-id ]

    get expect, call [ get to-equal ] [ get response-data status ] 200

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed id ] [ get dict-id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Test Dict'
    get expect, call [ get to-equal ] [ get parsed entries term1 type ] 'value'
    get expect, call [ get to-equal ] [ get parsed entries term1 id ] 'val-123'
    get expect, call [ get to-equal ] [ get parsed entries term2 type ] 'document'
    get expect, call [ get to-equal ] [ get parsed entries term2 id ] 'doc-456'
   ]
  ]

  get it, call 'should return 404 for non-existent dictionary' [
   function [
    set response-data [ object [ status null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
     ]
    ]

    get api-dictionaries-get, call [ object ] [ get mock-respond ] [ get session-id ] 'nonexistent'

    get expect, call [ get to-equal ] [ get response-data status ] 404
   ]
  ]
 ]
]

get cleanup, call
