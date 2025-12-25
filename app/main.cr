# function route() {
#  const page = window.location.hash.substring(1)
#  console.log("page", page)
# }
# route()
# window.addEventListener("hashchange", route)
log Civil Commons

set components [ object ]
list action-bar, each [
 function x [
  set [ get components ] [ get x ] [
   load [ template ./components/%0.cr [ get x ] ], point
  ]
 ]
]

set toolbar [
 get components action-bar, call
]

global document body appendChild, call [ get toolbar element ]
