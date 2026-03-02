# Dictionary Service - Dictionary management within a session

set listeners [ object [
 change [ list ]
 dictionaryRenamed [ list ]
] ]

set emit [ function event-name data [
 get listeners [ get event-name ], each [
  function callback [
   get callback, call [ get data ]
  ]
 ]
] ]

set on [ function event-name callback [
 get listeners [ get event-name ] push, call [ get callback ]
] ]

set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

set fetch-all-dictionaries [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dicts [ list ] ] ]
 get session-id, true [
  try [
   set result-ref dicts [
    global fetch, call [ template '/api/sessions/%0/dictionaries' [ get session-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref dicts
] ]

set fetch-dictionary [ function dict-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref dict
] ]

set create-dictionary [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries' [ get session-id ] ] [
     object [ method 'POST' ]
    ]
    at json, call
   ]
  ] [
   # Failed to create
  ]
 ]
 get result-ref dict
] ]

set rename-dictionary [ function dict-id new-name [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
     ]
    ]
    at json, call
   ]
   get emit, call dictionaryRenamed [ object [ id [ get dict-id ], name [ get new-name ] ] ]
  ] [
   # Failed to rename
  ]
 ]
 get result-ref dict
] ]

set update-dictionary [ function dict-id entries [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ entries [ get entries ] ] ] ]
     ]
    ]
    at json, call
   ]
   get emit, call change [ get dict-id ]
  ] [
   # Failed to update
  ]
 ]
 get result-ref dict
] ]

set archive-dictionary [ function dict-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ archived true ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to archive
  ]
 ]
 get result-ref dict
] ]

set restore-dictionary [ function dict-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ dict null ] ]
 get session-id, true [
  try [
   set result-ref dict [
    global fetch, call [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ archived false ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to restore
  ]
 ]
 get result-ref dict
] ]

set check-reference-usage [ function ref-type ref-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ usage [ list ] ] ]
 get session-id, true [
  try [
   set result-ref usage [
    global fetch, call [ template '/api/sessions/%0/references/%1/%2/usage' [ get session-id ] [ get ref-type ] [ get ref-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref usage
] ]

object [
 on
 fetch-all-dictionaries
 fetch-dictionary
 create-dictionary
 rename-dictionary
 update-dictionary
 archive-dictionary
 restore-dictionary
 check-reference-usage
]
