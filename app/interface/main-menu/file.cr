# Menu: File

set file [ get components menu, call File ]

get file add, call 'Rename' [
 function item event [
  set last [ get main last-interacted ]
  get last type, is document, true [
   get conductor dispatch, call document:rename [ get last id ]
  ]
  get last type, is session, true [
   get conductor dispatch, call session:rename
  ]
  get last type, is value, true [
   get conductor dispatch, call value:rename [ get last id ]
  ]
 ]
]

get file add, call 'Archive session' [
 function item event [
  get conductor dispatch, call session:archive
 ]
]

get file add, call 'Close session' [
 function item event [
  set current-id [ get main session-service get-current-session-id, call ]
  get current-id, true [
   get main session-service close-session, call [ get current-id ]

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

get file
