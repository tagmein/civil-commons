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
  list bounds style-tag svg-icon
 ]
]

set components [
 get package
 call components [
  list action-bar stage menu window window-title-buttons minimap
 ]
]

set main [ object ]

list tabs menu stage status startup, each [
 function x [
  set main [ get x ] [
   load [
    template ./interface/main-%0.cr [ get x]
   ], point
  ]
 ]
]

list commons/about log/main, each [
 function x [
  load [ template ./modules/%0.cr [ get x ] ], point
 ]
]

get main stage resize, tell
