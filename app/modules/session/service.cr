# Session Service - Central session management for frontend
# Provides functions for creating, loading, updating, and managing sessions

set STORAGE_KEY 'civil-commons-open-sessions'
set CURRENT_KEY 'civil-commons-current-session'
set PREFS_KEY 'civil-commons-prefs'

# Event listeners for session changes
set listeners [ object [
 change [ list ]
 tabsChange [ list ]
 sessionRenamed [ list ]
 logChanged [ list ]
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

# Get a preference value (from localStorage)
set get-preference [ function key [
 set stored [ global localStorage getItem, call [ get PREFS_KEY ] ]
 set ref [ object [ prefs [ object ] ] ]
 get stored, true [
  try [
   set ref prefs [ global JSON parse, call [ get stored ] ]
  ] [
   value undefined
  ]
 ]
 get ref prefs [ get key ]
] ]

# Set a preference value (to localStorage)
set set-preference [ function key value [
 set stored [ global localStorage getItem, call [ get PREFS_KEY ] ]
 set prefs-ref [ object [ prefs [ object ] ] ]
 get stored, true [
  try [
   set prefs-ref prefs [ global JSON parse, call [ get stored ] ]
  ] [
   value undefined
  ]
 ]
 set prefs-ref prefs [ get key ] [ get value ]
 global localStorage setItem, call [ get PREFS_KEY ] [
  global JSON stringify, call [ get prefs-ref prefs ]
 ]
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

# ==========================================
# Event Log Functions
# ==========================================

# Log an event to the current session; returns the created event (with id) so conductor can store it
set log-event [ function action arg [
 set session-id [ get get-current-session-id, call ]
 set result-ref [ object [ event null ] ]
 get session-id, true [
  set response [ global fetch, call [ template '/api/sessions/%0/log' [ get session-id ] ] [
   object [
    method 'POST'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ action [ get action ], arg [ get arg ] ] ] ]
   ]
  ] ]
  set body [ get response json, call ]
  get body event, true [
   set result-ref event [ get body event ]
  ]
  get emit, call logChanged null
 ]
 get result-ref event
] ]

# Get the event log for the current session (returns array of events, not a Promise)
set get-event-log [ function [
 set session-id [ get get-current-session-id, call ]
 set result-ref [ object [ log [ list ] ] ]
 get session-id, true [
  try [
   set response [ global fetch, call [ template '/api/sessions/%0/log' [ get session-id ] ] ]
   set result-ref log [ get response json, call ]
  ] [
   # Failed to fetch log, keep empty
  ]
 ]
 get result-ref log
] ]

# Delete an event from the current session's log
set delete-event [ function index [
 set session-id [ get get-current-session-id, call ]
 set result-ref [ object [ result null ] ]
 get session-id, true [
  try [
   set result-ref result [
    global fetch, call [ template '/api/sessions/%0/log/%1' [ get session-id ] [ get index ] ] [
     object [ method 'DELETE' ]
    ]
    at json, call
   ]
   # Emit logChanged event so UI can update
   get emit, call logChanged null
  ] [
   # Failed to delete
  ]
 ]
 get result-ref result
] ]

# Mark a log entry as skipped on replay (e.g. when user closed the window). Awaits the request so close handlers can rely on persistence.
set mark-event-skipped-on-replay [ function event-id [
 get set-event-skipped-on-replay, call [ get event-id ] true
] ]

# Set a log entry's skippedOnReplay flag (true or false). Used by log UI checkbox. Awaits the request.
set set-event-skipped-on-replay [ function event-id value [
 set session-id [ get get-current-session-id, call ]
 get session-id, true [
  get event-id, true [
   set response [ global fetch, call [ template '/api/sessions/%0/log/%1' [ get session-id ] [ get event-id ] ] [
    object [
     method 'PATCH'
     headers [ object [ Content-Type 'application/json' ] ]
     body [ global JSON stringify, call [ object [ skippedOnReplay [ get value ] ] ] ]
    ]
   ] ]
   get emit, call logChanged null
  ]
 ]
] ]

# Set skippedOnReplay by log index (for events without id). Backfill id on server. Awaits the request.
set set-event-skipped-on-replay-by-index [ function index value [
 set session-id [ get get-current-session-id, call ]
 get session-id, true [
  set response [ global fetch, call [ template '/api/sessions/%0/log/by-index/%1' [ get session-id ] [ get index ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ skippedOnReplay [ get value ] ] ] ]
   ]
  ] ]
  get emit, call logChanged null
 ]
] ]

# Set a log entry's minimized flag (true or false). Used when window is minimized/restored and in log UI.
set set-event-minimized [ function event-id value [
 set session-id [ get get-current-session-id, call ]
 get session-id, true [
  get event-id, true [
   set response [ global fetch, call [ template '/api/sessions/%0/log/%1' [ get session-id ] [ get event-id ] ] [
    object [
     method 'PATCH'
     headers [ object [ Content-Type 'application/json' ] ]
     body [ global JSON stringify, call [ object [ minimized [ get value ] ] ] ]
    ]
   ] ]
   get emit, call logChanged null
  ]
 ]
] ]

# Set minimized by log index (for events without id). Backfill id on server. Awaits the request.
set set-event-minimized-by-index [ function index value [
 set session-id [ get get-current-session-id, call ]
 get session-id, true [
  set response [ global fetch, call [ template '/api/sessions/%0/log/by-index/%1' [ get session-id ] [ get index ] ] [
   object [
    method 'PATCH'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ minimized [ get value ] ] ] ]
   ]
  ] ]
  get emit, call logChanged null
 ]
] ]

# Mark the most recent log entry with the given action as skipped (fallback when logEntryId wasn't set)
# Uses server-side skip-last endpoint. Awaits the request so close handlers can rely on persistence before closing.
set mark-last-event-with-action-skipped-on-replay [ function action [
 set session-id [ get get-current-session-id, call ]
 get session-id, true [
  set response [ global fetch, call [ template '/api/sessions/%0/log/skip-last' [ get session-id ] ] [
   object [
    method 'POST'
    headers [ object [ Content-Type 'application/json' ] ]
    body [ global JSON stringify, call [ object [ action [ get action ] ] ] ]
   ]
  ] ]
  get emit, call logChanged null
 ]
] ]

# Replay all events in the current session's log (skip entries marked skippedOnReplay)
# This is called at startup after all handlers are registered
# Documents left open at reload are reincarnated via this replay
set replay-events [ function [
 set log [ get get-event-log, call ]
 
 # Tell conductor we're in replay mode (don't re-log these events)
 get conductor start-replay, call
 
 # Dispatch each event that is not marked skipped on replay
 get log, each [
  function event [
   get event skippedOnReplay, true [
    value undefined
   ], false [
    get conductor setReplayEvent, call [ get event ]
    get conductor dispatch, call [ get event action ] [ get event arg ]
    get conductor setReplayEvent, call null
   ]
  ]
 ]
 
 # Exit replay mode
 get conductor end-replay, call
] ]

# Set up the conductor event hook to log events
set setup-event-logging [ function [
 get conductor set-event-hook, call [
  function action arg [
   get log-event, call [ get action ] [ get arg ]
  ]
 ]
] ]

# Export service object
object [
 on
 get-preference
 set-preference
 get-open-session-ids
 mark-event-skipped-on-replay
 set-event-skipped-on-replay
 set-event-skipped-on-replay-by-index
 set-event-minimized
 set-event-minimized-by-index
 mark-last-event-with-action-skipped-on-replay
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
 log-event
 get-event-log
 delete-event
 replay-events
 setup-event-logging
]
