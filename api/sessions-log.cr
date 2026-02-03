# API: Session Event Log
# GET /api/sessions/:id/log - Get all logged events for a session
# POST /api/sessions/:id/log - Add an event to the log
# DELETE /api/sessions/:id/log/:index - Delete an event at specific index

# Get log file path for a session
set get-log-path [ function session-id [
 template '%0/sessions/%1/log.json' [ get data-path ] [ get session-id ]
] ]

# GET handler - returns array of events
set get-handler [ function session-id [
 set log-path [ get get-log-path, call [ get session-id ] ]
 
 # Use reference pattern to avoid Crown scoping issues
 set result-ref [ object [ log [ list ] ] ]
 
 # Check if log file exists
 set exists [ get file-exists, call [ get log-path ] ]
 get exists, true [
  try [
   set result-ref log [ get ij, call [ get log-path ] ]
  ] [
   # Read failed, keep empty list
  ]
 ]
 
 get result-ref log
] ]

# POST handler - adds event to log
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
  ] [
   # Parse failed, keep empty list
  ]
 ]
 
 # Add new event with timestamp
 set event [ object [
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

object [
 get-handler
 post-handler
 delete-handler
]
