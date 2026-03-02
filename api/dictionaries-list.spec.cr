# Tests for GET /api/sessions/:sessionId/dictionaries - List dictionaries

set fs [ global import, call fs/promises ]

set test-data-path './test-data-dicts-list'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-dictionaries-list [ load ./dictionaries-list.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-list'
get ensure-dir, call [ template '%0/sessions/%1/dictionaries' [ get test-data-path ] [ get session-id ] ]
get ensure-dir, call [ template '%0/sessions/%1/dictionaries/dict1' [ get test-data-path ] [ get session-id ] ]
get oj, call [ template '%0/sessions/%1/dictionaries/dict1/metadata.json' [ get test-data-path ] [ get session-id ] ] [
 object [ name 'Dict One', archived false, createdAt [ global Date now, call ] ]
]
get oj, call [ template '%0/sessions/%1/dictionaries/dict1/entries.json' [ get test-data-path ] [ get session-id ] ] [ object ]
get oj, call [ template '%0/sessions/%1/dictionaries.json' [ get test-data-path ] [ get session-id ] ] [ list 'dict1' ]

get describe, call 'GET /api/sessions/:sessionId/dictionaries' [
 function [
  get it, call 'should return list of dictionaries' [
   function [
    set response-data [ object [ status null, body null ] ]
    set mock-respond [
     function status body mime [
      set response-data status [ get status ]
      set response-data body [ get body ]
     ]
    ]

    get api-dictionaries-list, call [ object ] [ get mock-respond ] [ get session-id ]

    get expect, call [ get to-equal ] [ get response-data status ] 200

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed length ] 1
    get expect, call [ get to-equal ] [ get parsed, at 0, at id ] 'dict1'
    get expect, call [ get to-equal ] [ get parsed, at 0, at name ] 'Dict One'
   ]
  ]
 ]
]

get cleanup, call
