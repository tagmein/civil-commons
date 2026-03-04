# Script Service - Script (Crown code) management within a session
# Provides functions for creating, loading, updating, and running scripts

set listeners [ object [
 change [ list ]
 scriptRenamed [ list ]
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

set current-script-ref [ object [ id null ] ]

set get-current-script-id [ function [
 get current-script-ref id
] ]

set set-current-script-id [ function id [
 set current-script-ref id [ get id ]
 set main last-interacted [ object [ type script, id [ get id ] ] ]
 get emit, call change [ get id ]
] ]

set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

set fetch-all-scripts [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ scripts [ list ] ] ]
 get session-id, true [
  try [
   set result-ref scripts [
    global fetch, call [ template '/api/sessions/%0/scripts' [ get session-id ] ]
    at json, call
   ]
  ] [
   value undefined
  ]
 ]
 get result-ref scripts
] ]

set fetch-script [ function script-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ script null ] ]
 get session-id, true [
  try [
   set result-ref script [
    global fetch, call [ template '/api/sessions/%0/scripts/%1' [ get session-id ] [ get script-id ] ]
    at json, call
   ]
  ] [
   value undefined
  ]
 ]
 get result-ref script
] ]

set create-script [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ script null ] ]
 get session-id, true [
  try [
   set result-ref script [
    global fetch, call [ template '/api/sessions/%0/scripts' [ get session-id ] ] [
     object [ method 'POST' ]
    ]
    at json, call
   ]
  ] [
   value undefined
  ]
 ]
 get result-ref script
] ]

set rename-script [ function script-id new-name [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ script null ] ]
 get session-id, true [
  try [
   set result-ref script [
    global fetch, call [ template '/api/sessions/%0/scripts/%1' [ get session-id ] [ get script-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
     ]
    ]
    at json, call
   ]
   get emit, call scriptRenamed [ object [ id [ get script-id ], name [ get new-name ] ] ]
  ] [
   value undefined
  ]
 ]
 get result-ref script
] ]

set save-script [ function script-id content [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ script null ] ]
 get session-id, true [
  try [
   set result-ref script [
    global fetch, call [ template '/api/sessions/%0/scripts/%1' [ get session-id ] [ get script-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ content [ get content ] ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   value undefined
  ]
 ]
 get result-ref script
] ]

set archive-script [ function script-id [
 set session-id [ get get-session-id, call ]
 get session-id, true [
  global fetch, call [ template '/api/sessions/%0/scripts/%1' [ get session-id ] [ get script-id ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ archived true ] ] ]
   ]
  ]
 ]
]
]

set restore-script [ function script-id [
 set session-id [ get get-session-id, call ]
 get session-id, true [
  global fetch, call [ template '/api/sessions/%0/scripts/%1' [ get session-id ] [ get script-id ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ archived false ] ] ]
   ]
  ]
 ]
]
]

object [
 on
 get-current-script-id
 set-current-script-id
 fetch-all-scripts
 fetch-script
 create-script
 rename-script
 save-script
 archive-script
 restore-script
]
