# Document Rename Window
# Opens a window with a form to rename the current document

get lib style-tag

tell '.rename-doc-form' [
 object [
  padding 20px
 ]
]

tell '.rename-doc-form label' [
 object [
  display block
  margin-bottom 8px
  color '#e0e0d0'
 ]
]

tell '.rename-doc-form input' [
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

tell '.rename-doc-form input:focus' [
 object [
  outline none
  border-color '#4a9eff'
 ]
]

tell '.rename-doc-form-buttons' [
 object [
  display flex
  gap 10px
  justify-content flex-end
 ]
]

tell '.rename-doc-form-error' [
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

tell '.rename-doc-form-error.visible' [
 object [
  display block
 ]
]

tell '.rename-doc-form button' [
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

tell '.rename-doc-form button:hover' [
 object [
  background-color '#555558'
 ]
]

tell '.rename-doc-form button.primary' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.rename-doc-form button.primary:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.rename-doc-form-id' [
 object [
  color '#808080'
  font-size 12px
  margin-bottom 12px
 ]
]

get conductor register, call document:rename [
 function arg [
  set doc-service [ get main document-service ]
  set session-service [ get main session-service ]
  set current-id [ get arg, default [ get doc-service get-current-document-id, call ] ]

  get current-id, false [
   log No current document to rename
   value undefined
  ]

  # Ensure this document is current (e.g. when reopened via replay)
  get doc-service set-current-document-id, call [ get current-id ]

  # Fetch current document info - default name to Untitled Document if not found
  # Using reference pattern to avoid Crown scoping issues
  set name-ref [ object [ name 'Untitled Document' ] ]
  try [
   set doc [ get doc-service fetch-document, call [ get current-id ] ]
   get doc name, true [
    set name-ref name [ get doc name ]
   ]
  ] [
   # Failed to fetch, use default
  ]
  set doc-name [ get name-ref name ]

  set rename-window [
   get components window, call 'Rename Document' 220 350
  ]

  # Attach log entry id so we can mark skipped on replay when window is closed
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

  # Override close to optionally mark log entry skipped on replay
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

  # Create form
  set form [
   global document createElement, call div
  ]
  get form classList add, call rename-doc-form

  # Document ID (shown at top)
  set doc-id-el [ global document createElement, call div ]
  get doc-id-el classList add, call rename-doc-form-id
  set doc-id-el textContent [ template 'Document ID: %0' [ get current-id ] ]
  get form appendChild, call [ get doc-id-el ]

  set label [
   global document createElement, call label
  ]
  set label textContent 'Document name:'
  get form appendChild, call [ get label ]

  set input [
   global document createElement, call input
  ]
  set input type text
  set input value [ get doc-name ]
  set input placeholder 'Enter document name'
  get form appendChild, call [ get input ]

  # Error message element
  set error-msg [
   global document createElement, call div
  ]
  get error-msg classList add, call rename-doc-form-error
  get form appendChild, call [ get error-msg ]

  set buttons [
   global document createElement, call div
  ]
  get buttons classList add, call rename-doc-form-buttons

  set cancel-btn [
   global document createElement, call button
  ]
  set cancel-btn textContent 'Cancel'
  get cancel-btn addEventListener, call click [
   function [
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

     # Rename via service with error handling
     set rename-result [ object [ success false, error null ] ]
     try [
      set response [ get doc-service rename-document, call [ get current-id ] [ get new-name ] ]
      get response, true [
       set rename-result success true
      ], false [
       set rename-result error 'Failed to rename document'
      ]
     ] [
      set rename-result error 'Network error: Could not reach server'
     ]

     get rename-result success, true [
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
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get rename-window minimize-window, tell
   ]
  ]

  # Focus input after a small delay to ensure DOM is ready
  global setTimeout, call [
   function [
    get input focus, call
    get input select, call
   ]
  ] 50
 ]
]
