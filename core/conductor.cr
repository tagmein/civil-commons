set registry [ object ]

# Flag to prevent recording events during replay
set replay-mode [ object [ active false ] ]

# Hook for logging events - can be set by session service
set event-hook [ object [ callback null ] ]

set dispatch [
 function action arg [
  # Check if action starts with ! (skip on replay)
  set skip-on-replay [ get action, at startsWith, call '!' ]
  
  # Use reference pattern to track if we should execute
  set should-execute [ object [ value true ] ]
  
  # In replay mode, skip actions prefixed with !
  get replay-mode active, true [
   get skip-on-replay, true [
    log CONDUCTOR REPLAY SKIP [ get action ]
    set should-execute value false
   ]
  ]
  
  # Only execute if not skipped
  get should-execute value, true [
   set handler [ get registry [ get action ] ]
   get handler, false [
    log CONDUCTOR WARNING NO MATCH FOR [ get action ]
   ], true [ 
    log CONDUCTOR DISPATCH [ get action ]
    
    # Forward to event hook if set and not in replay mode
    get replay-mode active, false [
     get event-hook callback, true [
      get event-hook callback, call [ get action ] [ get arg ]
     ]
    ]
    
    # Call the handler
    get handler, call [ get arg ]
   ]
  ]
 ]
]

set register [
 function name callback [
  set registry [ get name ] [ get callback ]
  log CONDUCTOR REGISTERED [ get name ]
 ]
]

# Check if an action is registered
set is-registered [ function name [
 get registry [ get name ], true [ value true ], false [ value false ]
] ]

# Set the event logging hook
set set-event-hook [ function callback [
 set event-hook callback [ get callback ]
] ]

# Enable replay mode (prevents event logging)
set start-replay [ function [
 set replay-mode active true
] ]

# Disable replay mode
set end-replay [ function [
 set replay-mode active false
] ]

object [
 dispatch
 register
 is-registered
 set-event-hook
 start-replay
 end-replay
]
