# function route() {
#  const page = window.location.hash.substring(1)
#  console.log("page", page)
# }
# route()
# window.addEventListener("hashchange", route)
log Civil Commons

set components [ object ]
list action-bar menu, each [
 function x [
  set components [ get x ] [
   load [ template ./components/%0.cr [ get x ] ], point
  ]
 ]
]

set toolbar [
 get components action-bar, call
]

set commons [ get components menu, call ]
get commons add, call About

get toolbar add, call 'Civil Commons' [
 get commons toggle
]

global document body appendChild, call [ get toolbar element ]
