# Tests for PATCH /api/sessions/:sessionId/dictionaries/:dictId - Update dictionary

set fs [ global import, call fs/promises ]

set test-data-path './test-data-dicts-update'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-dictionaries-update [ load ./dictionaries-update.cr, point ]

set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

set session-id 'test-session-update'
set dict-id 'dict-xyz'
get ensure-dir, call [ template '%0/sessions/%1/dictionaries/%2' [ get test-data-path ] [ get session-id ] [ get dict-id ] ]
get oj, call [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] [
 object [ name 'Original', archived false, createdAt [ global Date now, call ] ]
]
get oj, call [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] [ object ]

get describe, call 'PATCH /api/sessions/:sessionId/dictionaries/:dictId' [
 function [
  get it, call 'should update dictionary name' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    set body [ object [ name 'Renamed Dictionary' ] ]

    get api-dictionaries-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get dict-id ] [ get body ]

    set parsed [ global JSON parse, call [ get response-data body ] ]
    get expect, call [ get to-equal ] [ get parsed name ] 'Renamed Dictionary'

    set metadata [ get ij, call [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] ]
    get expect, call [ get to-equal ] [ get metadata name ] 'Renamed Dictionary'
   ]
  ]

  get it, call 'should update dictionary entries' [
   function [
    set response-data [ object [ body null ] ]
    set mock-respond [
     function status body mime [
      set response-data body [ get body ]
     ]
    ]
    set body [ object [ entries [ object [ key1 [ object [ type value, id 'v1' ] ] ] ] ] ]

    get api-dictionaries-update, call [ object ] [ get mock-respond ] [ get session-id ] [ get dict-id ] [ get body ]

    set entries [ get ij, call [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get test-data-path ] [ get session-id ] [ get dict-id ] ] ]
    get expect, call [ get to-equal ] [ get entries key1 type ] 'value'
    get expect, call [ get to-equal ] [ get entries key1 id ] 'v1'
   ]
  ]
 ]
]

get cleanup, call
