# Tests for GET /api/sessions/:sessionId/references/:type/:refId/usage

set fs [ global import, call fs/promises ]

set test-data-path './test-data-refs-usage'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-references-usage [ load ./references-usage.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-refs'
get ensure-dir, call [ template '%0/sessions/%1/dictionaries' [ get test-data-path ] [ get session-id ] ]
get ensure-dir, call [ template '%0/sessions/%1/dictionaries/d1' [ get test-data-path ] [ get session-id ] ]
get ensure-dir, call [ template '%0/sessions/%1/dictionaries/d2' [ get test-data-path ] [ get session-id ] ]
get oj, call [ template '%0/sessions/%1/dictionaries.json' [ get test-data-path ] [ get session-id ] ] [ list 'd1' 'd2' ]
get oj, call [ template '%0/sessions/%1/dictionaries/d1/entries.json' [ get test-data-path ] [ get session-id ] ] [
 object [ alpha [ object [ type value, id 'val-shared' ] ], beta [ object [ type value, id 'val-other' ] ] ]
]
get oj, call [ template '%0/sessions/%1/dictionaries/d2/entries.json' [ get test-data-path ] [ get session-id ] ] [
 object [ gamma [ object [ type value, id 'val-shared' ] ] ]
]

get describe, call 'GET /api/sessions/:sessionId/references/:type/:refId/usage' [
 function [
  get it, call 'should return usage list when ref is used in multiple dictionaries' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-references-usage, call [ object ] [ get mock-respond ] [ get session-id ] 'value' 'val-shared'

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed length ] 2

    set d1-found [ object [ value false ] ]
    set d2-found [ object [ value false ] ]
    get parsed, each [
     function u [
      get u dictionaryId, is 'd1', true [
       get expect, call [ get to-equal ] [ get u key ] 'alpha'
       set d1-found value true
      ]
      get u dictionaryId, is 'd2', true [
       get expect, call [ get to-equal ] [ get u key ] 'gamma'
       set d2-found value true
      ]
     ]
    ]
    get expect, call [ get to-be-true ] [ get d1-found value ]
    get expect, call [ get to-be-true ] [ get d2-found value ]
   ]
  ]

  get it, call 'should return empty list when ref is not used' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]

    get api-references-usage, call [ object ] [ get mock-respond ] [ get session-id ] 'value' 'val-unused'

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed length ] 0
   ]
  ]
 ]
]

get cleanup, call
