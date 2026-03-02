# Tests for POST /api/sessions/:sessionId/dictionaries - Create dictionary

set fs [ global import, call fs/promises ]

set test-data-path './test-data-dicts-create'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-dictionaries-create [ load ./dictionaries-create.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-dict'
get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]

get describe, call 'POST /api/sessions/:sessionId/dictionaries' [
 function [
  get it, call 'should create a new dictionary with default name' [
   function [
    set response-data [ object [ status null, body null, mime null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
      set response-data mime [ get mime ]
     ]
    ]

    get api-dictionaries-create, call [ object ] [ get mock-respond ] [ get session-id ]

    get expect, call [ get to-equal ] [ get response-data status ] 201
    get expect, call [ get to-equal ] [ get response-data mime ] application/json

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-be-defined ] [ get parsed id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Untitled Dictionary'
    get expect, call [ get to-equal ] [ get parsed archived ] false
    get expect, call [ get to-be-defined ] [ get parsed createdAt ]
   ]
  ]

  get it, call 'should add dictionary id to dictionaries.json' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-dictionaries-create, call [ object ] [ get mock-respond ] [ get session-id ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    set dict-id [ get parsed id ]

    set dicts-file [ template '%0/sessions/%1/dictionaries.json' [ get test-data-path ] [ get session-id ] ]
    set dicts [ get ij, call [ get dicts-file ] ]

    set found [ object [ value false ] ]
    get dicts, each [
     function id [
      get id, is [ get dict-id ], true [
       set found value true
      ]
     ]
    ]
    get expect, call [ get to-be-true ] [ get found value ]
   ]
  ]

  get it, call 'should create metadata and entries files' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-dictionaries-create, call [ object ] [ get mock-respond ] [ get session-id ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    set dict-id [ get parsed id ]

    set metadata-file [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ]
    get expect, call [ get to-be-true ] [ get file-exists, call [ get metadata-file ] ]

    set entries-file [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ]
    get expect, call [ get to-be-true ] [ get file-exists, call [ get entries-file ] ]

    set metadata [ get ij, call [ get metadata-file ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Untitled Dictionary'

    set entries [ get ij, call [ get entries-file ] ]
    set keys [ global Object keys, call [ get entries ] ]
    get expect, call [ get to-equal ] [ get keys length ] 0
   ]
  ]
 ]
]

get cleanup, call
