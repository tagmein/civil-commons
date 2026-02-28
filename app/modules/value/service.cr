# Value Service - Value management within a session

set listeners [ object [
 change [ list ]
 valueRenamed [ list ]
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

set current-val-ref [ object [ id null ] ]

set get-current-value-id [ function [
 get current-val-ref id
] ]

set set-current-value-id [ function id [
 set current-val-ref id [ get id ]
 set main last-interacted [ object [ type value, id [ get id ] ] ]
 get emit, call change [ get id ]
] ]

set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

set fetch-all-values [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ vals [ list ] ] ]
 get session-id, true [
  try [
   set result-ref vals [
    global fetch, call [ template '/api/sessions/%0/values' [ get session-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref vals
] ]

set fetch-value [ function val-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values/%1' [ get session-id ] [ get val-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref val
] ]

set create-value [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values' [ get session-id ] ] [
     object [ method 'POST' ]
    ]
    at json, call
   ]
  ] [
   # Failed to create
  ]
 ]
 get result-ref val
] ]

set rename-value [ function val-id new-name [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values/%1' [ get session-id ] [ get val-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
     ]
    ]
    at json, call
   ]
   get emit, call valueRenamed [ object [ id [ get val-id ], name [ get new-name ] ] ]
  ] [
   # Failed to rename
  ]
 ]
 get result-ref val
] ]

set update-value [ function val-id new-type new-value [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values/%1' [ get session-id ] [ get val-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ type [ get new-type ], value [ get new-value ] ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to update
  ]
 ]
 get result-ref val
] ]

set archive-value [ function val-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values/%1' [ get session-id ] [ get val-id ] ] [
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
 get result-ref val
] ]

set restore-value [ function val-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [
    global fetch, call [ template '/api/sessions/%0/values/%1' [ get session-id ] [ get val-id ] ] [
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
 get result-ref val
] ]

object [
 on
 get-current-value-id
 set-current-value-id
 fetch-all-values
 fetch-value
 create-value
 rename-value
 update-value
 archive-value
 restore-value
]
