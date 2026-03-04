# Tests for POST /api/sessions/:sessionId/scripts - Create script

set fs [ global import, call fs/promises ]
set test-data-path './test-data-scripts-create'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-scripts-create [ load ./scripts-create.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  value undefined
 ]
] ]

get cleanup, call

set session-id 'test-session-scripts-create'
get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]

get describe, call 'POST /api/sessions/:sessionId/scripts' [
 function [
  get it, call 'should create a new script with default name' [
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

    get api-scripts-create, call [ get mock-request ] [ get mock-respond ] [ get session-id ]

    get expect, call [ get to-equal ] [ get response-data status ] 201
    get expect, call [ get to-equal ] [ get response-data mime ] application/json

    set parsed [ global JSON parse, call [ get response-data body ] ]

    get expect, call [ get to-be-defined ] [ get parsed id ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Untitled Script'
    get expect, call [ get to-be-defined ] [ get parsed createdAt ]
   ]
  ]

  get it, call 'should add script id to scripts.json' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-scripts-create, call [ object ] [ get mock-respond ] [ get session-id ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    set script-id [ get parsed id ]

    set scripts-file [ template '%0/sessions/%1/scripts.json' [ get test-data-path ] [ get session-id ] ]
    set scripts [ get ij, call [ get scripts-file ] ]

    set found [ object [ value false ] ]
    get scripts, each [
     function id [
      get id, is [ get script-id ], true [ set found value true ]
     ]
    ]
    get expect, call [ get to-be-true ] [ get found value ]
   ]
  ]

  get it, call 'should create metadata and content files' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-scripts-create, call [ object ] [ get mock-respond ] [ get session-id ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    set script-id [ get parsed id ]
    set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]

    set metadata [ get ij, call [ template '%0/scripts/%1/metadata.json' [ get session-dir ] [ get script-id ] ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Untitled Script'
    get expect, call [ get to-be-defined ] [ get metadata createdAt ]

    set content [ get i, call [ template '%0/scripts/%1/content.cr' [ get session-dir ] [ get script-id ] ] ]
    get expect, call [ get to-equal ] [ get content length ] 0
   ]
  ]
 ]
]

get cleanup, call
