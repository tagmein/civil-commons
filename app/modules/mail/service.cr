# Mail Service - Thread and message management within a session

set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

set fetch-threads [ function folder [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ threads [ list ] ] ]
 get session-id, true [
  try [
   set url-ref [ object [ val '' ] ]
   get folder, true [
    set url-ref val [ template '/api/sessions/%0/mail/threads?folder=%1' [ get session-id ] [ get folder ] ]
   ], false [
    set url-ref val [ template '/api/sessions/%0/mail/threads' [ get session-id ] ]
   ]
   set raw [
    global fetch, call [ get url-ref val ]
    at json, call
   ]
   get raw error, true [
    # API returned error object, keep default empty list
   ], false [
    set result-ref threads [ get raw ]
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref threads
] ]

set fetch-thread [ function thread-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ thread null ] ]
 get session-id, true [
  try [
   set result-ref thread [
    global fetch, call [ template '/api/sessions/%0/mail/threads/%1' [ get session-id ] [ get thread-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref thread
] ]

set create-thread [ function subject from to body [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ thread null ] ]
 get session-id, true [
  try [
   set result-ref thread [
    global fetch, call [ template '/api/sessions/%0/mail/threads' [ get session-id ] ] [
     object [
      method 'POST'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [
       object [
        subject [ get subject ]
        from [ get from ]
        to [ get to ]
        body [ get body ]
        folder 'drafts'
       ]
      ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to create
  ]
 ]
 get result-ref thread
] ]

set update-thread [ function thread-id updates [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ thread null ] ]
 get session-id, true [
  try [
   set result-ref thread [
    global fetch, call [ template '/api/sessions/%0/mail/threads/%1' [ get session-id ] [ get thread-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ get updates ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to update
  ]
 ]
 get result-ref thread
] ]

set move-to-folder [ function thread-id folder [
 get update-thread, call [ get thread-id ] [ object [ folder [ get folder ] ] ]
] ]

set append-message [ function thread-id message [
 get update-thread, call [ get thread-id ] [ object [ appendMessage [ get message ] ] ]
] ]

set fetch-accounts [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ accounts [ list ] ] ]
 get session-id, true [
  try [
   set raw [ global fetch, call [ template '/api/sessions/%0/mail/accounts' [ get session-id ] ], at json, call ]
   get raw error, false [ set result-ref accounts [ get raw ] ]
  ] [
  ]
 ]
 get result-ref accounts
] ]

set get-google-auth-url [ function [
 set session-id [ get get-session-id, call ]
 get session-id, false [ value null ], true [
  set resp [ global fetch, call [ template '/api/auth/google?sessionId=%0' [ get session-id ] ] ]
  set raw [ get resp json, call ]
  get raw error, true [ value null ], false [ get raw authUrl ]
 ]
] ]

set create-account [ function account [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ account null ] ]
 get session-id, true [
  try [
   set result-ref account [
    global fetch, call [ template '/api/sessions/%0/mail/accounts' [ get session-id ] ] [
     object [
      method 'POST'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ get account ] ]
     ]
    ]
    at json, call
   ]
  ] [
  ]
 ]
 get result-ref account
] ]

set fetch-sync-settings [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ settings null ] ]
 get session-id, true [
  try [
   set result-ref settings [
    global fetch, call [ template '/api/sessions/%0/mail/sync-settings' [ get session-id ] ]
    at json, call
   ]
  ] [
  ]
 ]
 get result-ref settings
] ]

set update-sync-settings [ function updates [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ settings null ] ]
 get session-id, true [
  try [
   set result-ref settings [
    global fetch, call [ template '/api/sessions/%0/mail/sync-settings' [ get session-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ get updates ] ]
     ]
    ]
    at json, call
   ]
  ] [
  ]
 ]
 get result-ref settings
] ]

set fetch-sync-history [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ history [ list ] ] ]
 get session-id, true [
  try [
   set raw [ global fetch, call [ template '/api/sessions/%0/mail/sync-history' [ get session-id ] ], at json, call ]
   get raw error, false [ set result-ref history [ get raw ] ]
  ] [
  ]
 ]
 get result-ref history
] ]

set add-sync-record [ function record [
 set session-id [ get get-session-id, call ]
 get session-id, true [
  try [
   global fetch, call [ template '/api/sessions/%0/mail/sync-history' [ get session-id ] ] [
    object [
     method 'POST'
     headers [ object [ Content-Type 'application/json' ] ]
     body [ global JSON stringify, call [ get record ] ]
    ]
   ]
  ] [
  ]
 ]
] ]

set sync-now [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ count 0, error false ] ]
 get session-id, true [
  try [
   set count [ value 0 ]
   get add-sync-record, call [ object [ accountId 'local' result 'success' count [ get count ] ] ]
   get update-sync-settings, call [ object [
    lastSyncAt [ global Date now, call ]
    lastSyncCount [ get count ]
    lastSyncAccount 'local'
   ] ]
  ] [
   set result-ref error true
  ]
 ]
 get result-ref
] ]

object [
 fetch-threads
 fetch-thread
 create-thread
 update-thread
 move-to-folder
 append-message
 fetch-accounts
 get-google-auth-url
 create-account
 fetch-sync-settings
 update-sync-settings
 fetch-sync-history
 add-sync-record
 sync-now
]
