# Menu: Session
# Provides session management options

set session [ get components menu, call Session ]

# New session - creates a new session and switches to it
get session add, call 'New session' [
 function item event [
  get main session-service create-session, call
 ]
]

# Rename session - opens rename window
get session add, call 'Rename session' [
 function item event [
  get conductor dispatch, call session:rename
 ]
]

# Archive session - opens archive confirmation window
get session add, call 'Archive session' [
 function item event [
  get conductor dispatch, call session:archive
 ]
]

# Close session - closes tab but doesn't archive
get session add, call 'Close session' [
 function item event [
  set current-id [ get main session-service get-current-session-id, call ]
  get current-id, true [
   get main session-service close-session, call [ get current-id ]
   
   # If no more sessions, create a new one after a 250ms delay
   set open-ids [ get main session-service get-open-session-ids, call ]
   get open-ids length, = 0, true [
    global setTimeout, call [
     function [
      get main session-service create-session, call
     ]
    ] 250
   ]
  ]
 ]
]

# Recent - opens recent sessions window
get session add, call 'Recent' [
 function item event [
  get conductor dispatch, call session:recent
 ]
]

get session
