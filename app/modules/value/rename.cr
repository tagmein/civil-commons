# Value Rename Window

get lib style-tag

tell '.rename-val-form' [
 object [
  padding 20px
 ]
]

tell '.rename-val-form label' [
 object [
  display block
  margin-bottom 8px
  color '#e0e0d0'
 ]
]

tell '.rename-val-form input' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding '8px 12px'
  width '100%'
  box-sizing border-box
  margin-bottom 16px
 ]
]

tell '.rename-val-form input:focus' [
 object [
  outline none
  border-color '#4a9eff'
 ]
]

tell '.rename-val-form-buttons' [
 object [
  display flex
  gap 10px
  justify-content flex-end
 ]
]

tell '.rename-val-form-error' [
 object [
  background-color '#442222'
  border '1px solid #aa4444'
  border-radius 4px
  color '#ff8888'
  display none
  font-size 13px
  margin-bottom 12px
  padding '8px 12px'
 ]
]

tell '.rename-val-form-error.visible' [
 object [
  display block
 ]
]

tell '.rename-val-form button' [
 object [
  background-color '#444448'
  border none
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 14px
  padding '8px 16px'
 ]
]

tell '.rename-val-form button:hover' [
 object [
  background-color '#555558'
 ]
]

tell '.rename-val-form button.primary' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.rename-val-form button.primary:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.rename-val-form-id' [
 object [
  color '#808080'
  font-size 12px
  margin-bottom 12px
 ]
]

get conductor register, call value:rename [
 function arg [
  set val-service [ get main value-service ]
  set session-service [ get main session-service ]
  set current-id [ get arg, default [ get val-service get-current-value-id, call ] ]

  get current-id, false [
   log No current value to rename
   value undefined
  ]

  get val-service set-current-value-id, call [ get current-id ]

  set name-ref [ object [ name 'Untitled Value' ] ]
  try [
   set val [ get val-service fetch-value, call [ get current-id ] ]
   get val name, true [
    set name-ref name [ get val name ]
   ]
  ] [
   # Failed to fetch, use default
  ]
  set val-name [ get name-ref name ]

  set rename-window [
   get components window, call 'Rename Value' 220 350
  ]

  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set rename-window logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set rename-window logEntryId [ get replay-ev id ]
   ]
  ]

  set original-close [ get rename-window close ]
  set rename-window close [ function [
   get rename-window logEntryId, true [
    get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
     get session-service mark-event-skipped-on-replay, call [ get rename-window logEntryId ]
    ]
   ]
   get original-close, call
  ] ]
  get rename-window logEntryId, true [
   set rename-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set rename-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  set form [ global document createElement, call div ]
  get form classList add, call rename-val-form

  set val-id-el [ global document createElement, call div ]
  get val-id-el classList add, call rename-val-form-id
  set val-id-el textContent [ template 'Value ID: %0' [ get current-id ] ]
  get form appendChild, call [ get val-id-el ]

  set label [ global document createElement, call label ]
  set label textContent 'Value name:'
  get form appendChild, call [ get label ]

  set input [ global document createElement, call input ]
  set input type text
  set input value [ get val-name ]
  set input placeholder 'Enter value name'
  get form appendChild, call [ get input ]

  set error-msg [ global document createElement, call div ]
  get error-msg classList add, call rename-val-form-error
  get form appendChild, call [ get error-msg ]

  set buttons [ global document createElement, call div ]
  get buttons classList add, call rename-val-form-buttons

  set cancel-btn [ global document createElement, call button ]
  set cancel-btn textContent 'Cancel'
  get cancel-btn addEventListener, call click [
   function [
    get rename-window close, call
   ]
  ]
  get buttons appendChild, call [ get cancel-btn ]

  set save-btn [ global document createElement, call button ]
  set save-btn textContent 'Save'
  get save-btn classList add, call primary
  get save-btn addEventListener, call click [
   function [
    set new-name [ get input value, at trim, call ]
    get new-name length, > 0, true [
     get error-msg classList remove, call visible
     set save-btn disabled true
     set save-btn textContent 'Saving...'

     set rename-result [ object [ success false, error null ] ]
     try [
      set response [ get val-service rename-value, call [ get current-id ] [ get new-name ] ]
      get response, true [
       set rename-result success true
      ], false [
       set rename-result error 'Failed to rename value'
      ]
     ] [
      set rename-result error 'Network error: Could not reach server'
     ]

     get rename-result success, true [
      get rename-window close, call
     ], false [
      set error-msg textContent [ get rename-result error ]
      get error-msg classList add, call visible
      set save-btn disabled false
      set save-btn textContent 'Save'
     ]
    ]
   ]
  ]
  get buttons appendChild, call [ get save-btn ]

  get form appendChild, call [ get buttons ]

  get input addEventListener, call keydown [
   function event [
    get event key, is Enter, true [
     get save-btn click, call
    ]
   ]
  ]

  get rename-window fill, call [ get form ]
  get main stage place-window, call [
   get rename-window
  ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get rename-window minimize-window, tell
   ]
  ]

  global setTimeout, call [
   function [
    get input focus, call
    get input select, call
   ]
  ] 50
 ]
]
