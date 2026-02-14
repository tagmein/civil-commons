# function route() {
#  const page = window.location.hash.substring(1)
#  console.log("page", page)
# }
# route()
# window.addEventListener("hashchange", route)
set version 0.0.0
log Civil Commons [ get version ]

set package [
 function name parts [
  set bundle [ object ]
  get parts, each [
   function x [
    set bundle [ get x ] [
     load [
      template ./%0/%1.cr [ get name ] [ get x ]
     ], point
    ]
   ]
  ]
  get bundle
 ]
]

set lib [
 get package
 call lib [
  list bounds drag-handler style-tag svg-icon
 ]
]

set components [
 get package
 call components [
  list action-bar stage menu window window-title-buttons minimap tab-bar
 ]
]

set main [ object ]

# Load session service first (needed by tabs and other modules)
set main session-service [
 load ./modules/session/service.cr, point
]

# Load document service (needed by document modules)
set main document-service [
 load ./modules/document/service.cr, point
]

list tabs menu stage status startup, each [
 function x [
  set main [ get x ] [
   load [
    template ./interface/main-%0.cr [ get x]
   ], point
  ]
 ]
]

list commons/about commons/preferences log/main session/rename session/archive session/recent document/window document/window-api document/recent document/rename insert/generate-content, each [
 function x [
  load [ template ./modules/%0.cr [ get x ] ], point
 ]
]

# All handlers are now registered
# Set up event logging and replay saved events
get main session-service setup-event-logging, call
get main session-service replay-events, call

get main stage resize, tell
