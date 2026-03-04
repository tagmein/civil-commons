# Tests for GET /api/sessions/:sessionId/scripts - List scripts

set fs [ global import, call fs/promises ]
set test-data-path './test-data-scripts-list'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-scripts-list [ load ./scripts-list.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  value undefined
 ]
] ]

get cleanup, call

set session-id 'test-session-scripts'

get describe, call 'GET /api/sessions/:sessionId/scripts' [
 function [
  get it, call 'should return empty array when no scripts' [
   function [
    get ensure-dir, call [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]

    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]

    get api-scripts-list, call [ object ] [ get mock-respond ] [ get session-id ]

    get expect, call [ get to-equal ] [ get response-data status ] 200

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-be-array ] [ get parsed ]
    get expect, call [ get to-equal ] [ get parsed length ] 0
   ]
  ]

  get it, call 'should return scripts with metadata' [
   function [
    set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
    get ensure-dir, call [ get session-dir ]

    set script-ids [ list 'script-1' 'script-2' ]
    get oj, call [ template '%0/scripts.json' [ get session-dir ] ] [ get script-ids ]

    get ensure-dir, call [ template '%0/scripts/script-1' [ get session-dir ] ]
    get oj, call [ template '%0/scripts/script-1/metadata.json' [ get session-dir ] ] [
     object [ name 'First Script', createdAt 1000 ]
    ]
    get o, call [ template '%0/scripts/script-1/content.cr' [ get session-dir ] ] 'log hello'

    get ensure-dir, call [ template '%0/scripts/script-2' [ get session-dir ] ]
    get oj, call [ template '%0/scripts/script-2/metadata.json' [ get session-dir ] ] [
     object [ name 'Second Script', createdAt 2000 ]
    ]
    get o, call [ template '%0/scripts/script-2/content.cr' [ get session-dir ] ] ''

    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-scripts-list, call [ object ] [ get mock-respond ] [ get session-id ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed length ] 2
    get expect, call [ get to-equal ] [ get parsed, at 0, at name ] 'First Script'
    get expect, call [ get to-equal ] [ get parsed, at 1, at name ] 'Second Script'
   ]
  ]
 ]
]

get cleanup, call
