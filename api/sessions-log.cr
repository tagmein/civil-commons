# API: Session Event Log
# GET /api/sessions/:id/log - Get all logged events for a session
# POST /api/sessions/:id/log - Add an event to the log
# DELETE /api/sessions/:id/log/:index - Delete an event at specific index

# Get log file path for a session
set get-log-path [ function session-id [
 template '%0/sessions/%1/log.json' [ get data-path ] [ get session-id ]
] ]

# GET handler - returns array of events; backfill id for any event that lacks one (old log format)
set get-handler [ function session-id [
 set log-path [ get get-log-path, call [ get session-id ] ]

 set result-ref [ object [ log [ list ] ] ]
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, true [
  try [
   set result-ref log [ get ij, call [ get log-path ] ]
   # Backfill id so old log entries can be toggled in the UI
   set needs-save [ object [ value false ] ]
   get result-ref log, each [
    function ev [
     get ev id, true [
      value undefined
     ], false [
      set ev id [ get generate-event-id, call ]
      set needs-save value true
     ]
    ]
   ]
   get needs-save value, true [
    get oj, call [ get log-path ] [ get result-ref log ]
   ]
  ] [
   value undefined
  ]
 ]
 get result-ref log
] ]

# Generate a unique id for a new log event (no Node require; works in Crown/Node and browser)
set generate-event-id [ function [
 template 'ev-%0-%1' [ global Date now, call ] [ global Math random, call ]
] ]

# POST handler - adds event to log (each event gets id)
set post-handler [ function session-id body [
 set log-path [ get get-log-path, call [ get session-id ] ]
 set session-dir [ template '%0/sessions/%1' [ get data-path ] [ get session-id ] ]

 # Ensure session directory exists
 get ensure-dir, call [ get session-dir ]

 # Get existing log or create empty array
 set log-ref [ object [ log [ list ] ] ]
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, true [
  try [
   set log-ref log [ get ij, call [ get log-path ] ]
   # Backfill id for any event that lacks one so the log file always has ids
   get log-ref log, each [
    function ev [
     get ev id, true [
      value undefined
     ], false [
      set ev id [ get generate-event-id, call ]
     ]
    ]
   ]
  ] [
   # Parse failed, keep empty list
  ]
 ]

 # Add new event with id and timestamp
 set event [ object [
  id [ get generate-event-id, call ]
  action [ get body action ]
  arg [ get body arg ]
  timestamp [ global Date now, call ]
 ] ]
 get log-ref log push, call [ get event ]

 # Save log
 get oj, call [ get log-path ] [ get log-ref log ]

 # Return the added event with its index
 object [
  index [ get log-ref log length, subtract 1 ]
  event [ get event ]
 ]
] ]

# DELETE handler - removes event at index
set delete-handler [ function session-id index [
 set log-path [ get get-log-path, call [ get session-id ] ]

 # Use reference pattern for result
 set result-ref [ object [ result null ] ]

 # Check if log file exists
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, false [
  set result-ref result [ object [ error 'Log not found', status 404 ] ]
 ], true [
  set log [ get ij, call [ get log-path ] ]

  # Validate index
  set idx [ global parseInt, call [ get index ] 10 ]
  get idx, < 0, true [
   set result-ref result [ object [ error 'Invalid index', status 400 ] ]
  ], false [
   get idx, >= [ get log length ], true [
    set result-ref result [ object [ error 'Index out of bounds', status 400 ] ]
   ], false [
    # Remove event at index
    get log splice, call [ get idx ] 1

    # Save updated log
    get oj, call [ get log-path ] [ get log ]

    set result-ref result [ object [ success true, remaining [ get log length ] ] ]
   ]
  ]
 ]

 get result-ref result
] ]

# PATCH handler - update event by id (e.g. set skippedOnReplay)
set patch-handler [ function session-id event-id body [
 set log-path [ get get-log-path, call [ get session-id ] ]

 set result-ref [ object [ result null ] ]
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, false [
  set result-ref result [ object [ error 'Log not found', status 404 ] ]
 ], true [
  set log [ get ij, call [ get log-path ] ]
  set found-ref [ object [ index -1 ] ]
  set index-ref [ object [ i 0 ] ]
  get log, each [
   function ev [
    get ev id, is [ get event-id ], true [
     set found-ref index [ get index-ref i ]
    ]
    set index-ref i [ get index-ref i, add 1 ]
   ]
  ]
  get found-ref index, >= 0, true [
   set ev [ get log, at [ get found-ref index ] ]
   get body hasOwnProperty, call 'skippedOnReplay', true [
    get body skippedOnReplay, true [ set ev skippedOnReplay true ], false [ set ev skippedOnReplay false ]
   ]
   get body hasOwnProperty, call 'minimized', true [
    get body minimized, true [ set ev minimized true ], false [ set ev minimized false ]
   ]
   get body hasOwnProperty, call 'tags', true [
    set ev tags [ get body tags ]
   ]
   get oj, call [ get log-path ] [ get log ]
   set result-ref result [ object [ success true, event [ get ev ] ] ]
  ], false [
   set result-ref result [ object [ error 'Event not found', status 404 ] ]
  ]
 ]
 get result-ref result
] ]

# PATCH by index: update event at index (backfill id if missing, set skippedOnReplay)
set patch-by-index-handler [ function session-id index body [
 set log-path [ get get-log-path, call [ get session-id ] ]
 set result-ref [ object [ result null ] ]
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, false [
  set result-ref result [ object [ error 'Log not found', status 404 ] ]
 ], true [
  set log [ get ij, call [ get log-path ] ]
  set idx [ global parseInt, call [ get index ] 10 ]
  get idx, < 0, true [
   set result-ref result [ object [ error 'Invalid index', status 400 ] ]
  ], false [
   get idx, >= [ get log length ], true [
    set result-ref result [ object [ error 'Index out of bounds', status 400 ] ]
   ], false [
    set ev [ get log, at [ get idx ] ]
    get ev id, true [ value undefined ], false [
     set ev id [ get generate-event-id, call ]
    ]
    get body hasOwnProperty, call 'skippedOnReplay', true [
     get body skippedOnReplay, true [ set ev skippedOnReplay true ], false [ set ev skippedOnReplay false ]
    ]
    get body hasOwnProperty, call 'minimized', true [
     get body minimized, true [ set ev minimized true ], false [ set ev minimized false ]
    ]
    get body hasOwnProperty, call 'tags', true [
     set ev tags [ get body tags ]
    ]
    get oj, call [ get log-path ] [ get log ]
    set result-ref result [ object [ success true, event [ get ev ] ] ]
   ]
  ]
 ]
 get result-ref result
] ]

# POST skip-last: body { action: "commons:preferences" } - find last log entry with that action, set skippedOnReplay true
set skip-last-handler [ function session-id body [
 set log-path [ get get-log-path, call [ get session-id ] ]
 set result-ref [ object [ result null ] ]
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, false [
  set result-ref result [ object [ error 'Log not found', status 404 ] ]
 ], true [
  set log [ get ij, call [ get log-path ] ]
  set action [ get body action ]
  set last-match [ object [ ev null ] ]
  get log, each [
   function ev [
    set ev-action-str [ get ev action, at toString, call ]
    set action-str [ get action, at toString, call ]
    get ev-action-str, is [ get action-str ], true [
     set last-match ev [ get ev ]
    ]
   ]
  ]
  get last-match ev, true [
   set ev [ get last-match ev ]
   get ev id, true [ value undefined ], false [
    set ev id [ get generate-event-id, call ]
   ]
   set ev skippedOnReplay true
   get oj, call [ get log-path ] [ get log ]
   set result-ref result [ object [ success true, event [ get ev ] ] ]
  ], false [
   set result-ref result [ object [ error 'No matching event', status 404 ] ]
  ]
 ]
 get result-ref result
] ]

object [
 get-handler
 post-handler
 delete-handler
 patch-handler
 patch-by-index-handler
 skip-last-handler
]
