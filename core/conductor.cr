set registry [ object ]

# Flag to prevent recording events during replay
set replay-mode [ object [ active false ] ]

# Hook for logging events - can be set by session service
set event-hook [ object [ callback null ] ]

set dispatch [
 function action arg [
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

set register [
 function name callback [
  set registry [ get name ] [ get callback ]
  log CONDUCTOR REGISTERED [ get name ]
 ]
]

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
 set-event-hook
 start-replay
 end-replay
]
