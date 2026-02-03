# Session Service - Central session management for frontend
# Provides functions for creating, loading, updating, and managing sessions

set STORAGE_KEY 'civil-commons-open-sessions'
set CURRENT_KEY 'civil-commons-current-session'

# Event listeners for session changes
set listeners [ object [
 change [ list ]
 tabsChange [ list ]
 sessionRenamed [ list ]
] ]

# Trigger event listeners
set emit [ function event-name data [
 get listeners [ get event-name ], each [
  function callback [
   get callback, call [ get data ]
  ]
 ]
] ]

# Subscribe to session changes
set on [ function event-name callback [
 get listeners [ get event-name ] push, call [ get callback ]
] ]

# Get open session IDs from sessionStorage
# Uses reference object to avoid Crown scoping issues with set in conditionals
set get-open-session-ids [ function [
 set stored [ global sessionStorage getItem, call [ get STORAGE_KEY ] ]
 set ref [ object [ result [ list ] ] ]
 get stored, true [
  try [
   set ref result [ global JSON parse, call [ get stored ] ]
  ] [
   # Parse failed, keep empty list
  ]
 ]
 # Ensure result is an array
 global Array isArray, call [ get ref result ], false [
  set ref result [ list ]
 ]
 get ref result
] ]

# Save open session IDs to sessionStorage
set save-open-session-ids [ function ids [
 global sessionStorage setItem, call [ get STORAGE_KEY ] [
  global JSON stringify, call [ get ids ]
 ]
] ]

# Get current session ID
set get-current-session-id [ function [
 global sessionStorage getItem, call [ get CURRENT_KEY ]
] ]

# Set current session ID
set set-current-session-id [ function id [
 global sessionStorage setItem, call [ get CURRENT_KEY ] [ get id ]
 get emit, call change [ get id ]
] ]

# Fetch all sessions from API
set fetch-all-sessions [ function [
 global fetch, call /api/sessions
 at json, call
] ]

# Fetch single session from API
set fetch-session [ function id [
 global fetch, call [ template '/api/sessions/%0' [ get id ] ]
 at json, call
] ]

# Create new session via API
set create-session [ function [
 set response [
  global fetch, call /api/sessions [
   object [ method 'POST' ]
  ]
 ]
 set session [ get response json, call ]
 
 # Add to open sessions
 set open-ids [ get get-open-session-ids, call ]
 get open-ids push, call [ get session id ]
 get save-open-session-ids, call [ get open-ids ]
 
 # Set as current
 get set-current-session-id, call [ get session id ]
 
 get emit, call tabsChange [ get open-ids ]
 get session
] ]

# Rename session via API
set rename-session [ function id new-name [
 set response [
  global fetch, call [ template '/api/sessions/%0' [ get id ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
   ]
  ]
 ]
 set session [ get response json, call ]
 # Emit sessionRenamed event so tabs can update their label directly
 get emit, call sessionRenamed [ object [ id [ get id ], name [ get new-name ] ] ]
 get session
] ]

# Archive session via API
set archive-session [ function id [
 set response [
  global fetch, call [ template '/api/sessions/%0' [ get id ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ archived true ] ] ]
   ]
  ]
 ]
 
 # Remove from open sessions
 set open-ids [ get get-open-session-ids, call ]
 set new-ids [ get open-ids, filter [ function x [ get x, is [ get id ], not ] ] ]
 get save-open-session-ids, call [ get new-ids ]
 
 # If archived session was current, switch to another
 get get-current-session-id, call, is [ get id ], true [
  get new-ids length, > 0, true [
   get set-current-session-id, call [ get new-ids, at 0 ]
  ], false [
   # No more open sessions - will trigger new session creation
   global sessionStorage removeItem, call [ get CURRENT_KEY ]
  ]
 ]
 
 get emit, call tabsChange [ get new-ids ]
 get response json, call
] ]

# Close session (remove from tabs but don't archive)
set close-session [ function id [
 set open-ids [ get get-open-session-ids, call ]
 set new-ids [ get open-ids, filter [ function x [ get x, is [ get id ], not ] ] ]
 get save-open-session-ids, call [ get new-ids ]
 
 # If closed session was current, switch to another
 get get-current-session-id, call, is [ get id ], true [
  get new-ids length, > 0, true [
   get set-current-session-id, call [ get new-ids, at 0 ]
  ], false [
   global sessionStorage removeItem, call [ get CURRENT_KEY ]
  ]
 ]
 
 get emit, call tabsChange [ get new-ids ]
] ]

# Open an existing session (add to tabs)
set open-session [ function id [
 set open-ids [ get get-open-session-ids, call ]
 
 # Check if already open
 set already-open [ object [ value false ] ]
 get open-ids, each [
  function existing-id [
   get existing-id, is [ get id ], true [
    set already-open value true
   ]
  ]
 ]
 
 get already-open value, false [
  get open-ids push, call [ get id ]
  get save-open-session-ids, call [ get open-ids ]
  get emit, call tabsChange [ get open-ids ]
 ]
 
 get set-current-session-id, call [ get id ]
] ]

# Initialize sessions on app load
set initialize [ function [
 set open-ids [ get get-open-session-ids, call ]
 set current-id [ get get-current-session-id, call ]
 
 get open-ids length, > 0, true [
  # Have open sessions - make sure current is valid
  get current-id, true [
   set has-current [ object [ value false ] ]
   get open-ids, each [
    function id [
     get id, is [ get current-id ], true [
      set has-current value true
     ]
    ]
   ]
   get has-current value, false [
    get set-current-session-id, call [ get open-ids, at 0 ]
   ]
  ], false [
   get set-current-session-id, call [ get open-ids, at 0 ]
  ]
 ], false [
  # No open sessions - fetch all and open first unarchived, or create new
  set sessions [ get fetch-all-sessions, call ]
  set found [ object [ session null ] ]
  get sessions, each [
   function session [
    get found session, false [
     get session archived, false [
      set found session [ get session ]
     ]
    ]
   ]
  ]
  get found session, true [
   get open-session, call [ get found session id ]
  ], false [
   # No sessions exist - create new one
   get create-session, call
  ]
 ]
] ]

# Export service object
object [
 on
 get-open-session-ids
 get-current-session-id
 set-current-session-id
 fetch-all-sessions
 fetch-session
 create-session
 rename-session
 archive-session
 close-session
 open-session
 initialize
]
