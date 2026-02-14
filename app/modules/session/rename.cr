# Session Rename Window
# Opens a window with a form to rename the current session

get lib style-tag

tell '.rename-form' [
 object [
  padding 20px
 ]
]

tell '.rename-form label' [
 object [
  display block
  margin-bottom 8px
  color '#e0e0d0'
 ]
]

tell '.rename-form input' [
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

tell '.rename-form input:focus' [
 object [
  outline none
  border-color '#4a9eff'
 ]
]

tell '.rename-form-buttons' [
 object [
  display flex
  gap 10px
  justify-content flex-end
 ]
]

tell '.rename-form-error' [
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

tell '.rename-form-error.visible' [
 object [
  display block
 ]
]

tell '.rename-form button' [
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

tell '.rename-form button:hover' [
 object [
  background-color '#555558'
 ]
]

tell '.rename-form button.primary' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.rename-form button.primary:hover' [
 object [
  background-color '#5aafff'
 ]
]

get conductor register, call session:rename [
 function [
  set session-service [ get main session-service ]
  set current-id [ get session-service get-current-session-id, call ]

  get current-id, false [
   log No current session to rename
   value undefined
  ]

  # Fetch current session info - default name to Untitled if not found
  # Using reference pattern to avoid Crown scoping issues
  set name-ref [ object [ name 'Untitled' ] ]
  try [
   set session [ get session-service fetch-session, call [ get current-id ] ]
   get session name, true [
    set name-ref name [ get session name ]
   ]
  ] [
   # Failed to fetch, use default
  ]
  set session-name [ get name-ref name ]

  set rename-window [
   get components window, call 'Rename Session' 220 350
  ]

  # Create form
  set form [
   global document createElement, call div
  ]
  get form classList add, call rename-form

  set label [
   global document createElement, call label
  ]
  set label textContent 'Session name:'
  get form appendChild, call [ get label ]

  set input [
   global document createElement, call input
  ]
  set input type text
  set input value [ get session-name ]
  set input placeholder 'Enter session name'
  get form appendChild, call [ get input ]

  # Error message element
  set error-msg [
   global document createElement, call div
  ]
  get error-msg classList add, call rename-form-error
  get form appendChild, call [ get error-msg ]

  set buttons [
   global document createElement, call div
  ]
  get buttons classList add, call rename-form-buttons

  set cancel-btn [
   global document createElement, call button
  ]
  set cancel-btn textContent 'Cancel'
  get cancel-btn addEventListener, call click [
   function [
    # Close window properly (removes from minimap too)
    get rename-window close, call
   ]
  ]
  get buttons appendChild, call [ get cancel-btn ]

  set save-btn [
   global document createElement, call button
  ]
  set save-btn textContent 'Save'
  get save-btn classList add, call primary
  get save-btn addEventListener, call click [
   function [
    set new-name [ get input value, at trim, call ]
    get new-name length, > 0, true [
     # Hide any previous error
     get error-msg classList remove, call visible

     # Disable button while saving
     set save-btn disabled true
     set save-btn textContent 'Saving...'

     # Rename via API with error handling
     set rename-result [ object [ success false, error null ] ]
     try [
      set response [ get session-service rename-session, call [ get current-id ] [ get new-name ] ]
      get response, true [
       set rename-result success true
      ], false [
       set rename-result error 'Failed to rename session'
      ]
     ] [
      set rename-result error 'Network error: Could not reach server'
     ]

     get rename-result success, true [
      # Close window properly (removes from minimap too)
      get rename-window close, call
     ], false [
      # Show error message
      set error-msg textContent [ get rename-result error ]
      get error-msg classList add, call visible

      # Re-enable button
      set save-btn disabled false
      set save-btn textContent 'Save'
     ]
    ]
   ]
  ]
  get buttons appendChild, call [ get save-btn ]

  get form appendChild, call [ get buttons ]

  # Handle Enter key
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

  # Focus input after a small delay to ensure DOM is ready
  global setTimeout, call [
   function [
    get input focus, call
    get input select, call
   ]
  ] 50
 ]
]
