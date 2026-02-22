set main-menu [
 get components action-bar, call
]

list commons contacts document edit file insert layout log mail page presentation session view window, each [
 function item [
  set menu [
   load [ template ./main-menu/%0.cr [ get item ] ], point
  ]
  get main-menu add, call [ get menu label ] [
   get menu toggle
  ]
 ]
]

global document body appendChild, call [ get main-menu element ]

get main-menu
