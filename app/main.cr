# function route() {
#  const page = window.location.hash.substring(1)
#  console.log("page", page)
# }
# route()
# window.addEventListener("hashchange", route)
log Civil Commons

set package [
 function name parts [
  set bundle [ object ]
  get parts, each [
   function x [
    set bundle [ get x ] [
     load [ template ./%0/%1.cr [ get name ] [ get x ] ], point
    ]
   ]
  ]
  get bundle
 ]
]

set lib [
 get package
 call lib [
  list style-tag
 ]
]

set components [
 get package
 call components [
  list action-bar menu
 ]
]

set main-toolbar [
 get components action-bar, call
]

set commons [ get components menu, call ]
get commons add, call About

get main-toolbar add, call 'Civil Commons' [
 get commons toggle
]

global document body appendChild, call [ get main-toolbar element ]
