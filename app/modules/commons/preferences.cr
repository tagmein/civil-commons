# Preferences modal - tabbed (Windows, etc.) with Log Preferences

get lib style-tag

tell '.preferences-content' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.preferences-tab-content' [
 object [
  padding-top 16px
 ]
]

tell '.preferences-section' [
 object [
  margin-bottom 20px
 ]
]

tell '.preferences-section-title' [
 object [
  font-size 16px
  font-weight bold
  margin '0 0 10px 0'
  color '#e0e0d0'
 ]
]

tell '.preferences-checkbox-label' [
 object [
  display flex
  align-items center
  cursor pointer
  color '#e0e0d0'
  font-size 14px
 ]
]

tell '.preferences-checkbox' [
 object [
  margin-right 10px
  cursor pointer
 ]
]

tell '.preferences-input-label' [
 object [
  display block
  color '#e0e0d0'
  font-size 14px
  margin '0 0 6px 0'
 ]
]

tell '.preferences-input' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding '8px 10px'
  width '100%'
  box-sizing border-box
 ]
]

tell '.preferences-input:focus' [
 object [
  border-color '#4a9eff'
  outline none
 ]
]

tell '.preferences-input-wrap' [
 object [
  display flex
  align-items center
  gap 8px
 ]
]

tell '.preferences-input-wrap .preferences-input' [
 object [
  flex 1
  min-width 0
 ]
]

tell '.preferences-visibility-toggle' [
 object [
  background none
  border none
  color '#808080'
  cursor pointer
  padding 8px
  display flex
  align-items center
  justify-content center
  border-radius 4px
 ]
]

tell '.preferences-visibility-toggle:hover' [
 object [
  color '#e0e0d0'
 ]
]

get conductor register, call commons:preferences [
 function [
  set session-service [ get main session-service ]

  set prefs-window [
   get components window, call 'Preferences' 450 400
  ]

  # Attach log entry id so we can mark skipped on replay when window is closed
  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set prefs-window logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set prefs-window logEntryId [ get replay-ev id ]
   ]
  ]

  # Override close: always mark this Preferences open as skipped on replay so it never reopens after reload
  set original-close [ get prefs-window close ]
  set prefs-window close [ function [
   get prefs-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get prefs-window logEntryId ]
   ], false [
    get session-service mark-last-event-with-action-skipped-on-replay, call 'commons:preferences'
   ]
   get original-close, call
  ] ]
  get prefs-window logEntryId, true [
   set prefs-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set prefs-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  set content [
   global document createElement, call div
  ]
  get content classList add, call preferences-content

  set padding-container [
   global document createElement, call div
  ]
  set padding-container style padding '20px'

  # Tab bar: Windows, General
  set tabs [ get components tab-bar, call ]

  set windows-content [
   global document createElement, call div
  ]
  get windows-content classList add, call preferences-tab-content
  set windows-content style display 'block'

  set general-content [
   global document createElement, call div
  ]
  get general-content classList add, call preferences-tab-content
  set general-content style display 'none'

  # Log Preferences section under Windows
  set log-prefs-section [
   global document createElement, call div
  ]
  get log-prefs-section classList add, call preferences-section

  set log-prefs-title [
   global document createElement, call h2
  ]
  get log-prefs-title classList add, call preferences-section-title
  set log-prefs-title textContent 'Log Preferences'
  get log-prefs-section appendChild, call [ get log-prefs-title ]

  set checkbox [
   global document createElement, call input
  ]
  set checkbox type 'checkbox'
  get checkbox classList add, call preferences-checkbox
  set initial [ get session-service get-preference, call 'skipClosedWindowsOnReplay' ]
  get initial, true [
   set checkbox checked true
  ]

  set label [
   global document createElement, call label
  ]
  get label classList add, call preferences-checkbox-label
  get label appendChild, call [ get checkbox ]
  set label-text [
   global document createElement, call span
  ]
  set label-text textContent 'Mark log entries that open windows as skipped on replay if the window is closed'
  get label appendChild, call [ get label-text ]

  get checkbox addEventListener, call change [
   function [
    get session-service set-preference, call 'skipClosedWindowsOnReplay' [ get checkbox checked ]
   ]
  ]

  get log-prefs-section appendChild, call [ get label ]
  get windows-content appendChild, call [ get log-prefs-section ]

  # General tab: Gemini API Key
  set api-section [
   global document createElement, call div
  ]
  get api-section classList add, call preferences-section

  set api-title [
   global document createElement, call h2
  ]
  get api-title classList add, call preferences-section-title
  set api-title textContent 'API'
  get api-section appendChild, call [ get api-title ]

  set api-key-label [
   global document createElement, call label
  ]
  get api-key-label classList add, call preferences-input-label
  set api-key-label-text [
   global document createElement, call span
  ]
  set api-key-label-text textContent 'Gemini API Key'
  get api-key-label appendChild, call [ get api-key-label-text ]

  set api-key-input [
   global document createElement, call input
  ]
  set api-key-input type 'password'
  get api-key-input classList add, call preferences-input
  set api-key-initial [ get session-service get-preference, call 'geminiApiKey' ]
  get api-key-initial, true [
   set api-key-input value [ get api-key-initial ]
  ]
  set api-key-input placeholder 'Enter your API key from aistudio.google.com/apikey'

  get api-key-input addEventListener, call change [
   function [
    set val [ get api-key-input value ]
    get session-service set-preference, call 'geminiApiKey' [ get val ]
   ]
  ]
  get api-key-input addEventListener, call blur [
   function [
    set val [ get api-key-input value ]
    get session-service set-preference, call 'geminiApiKey' [ get val ]
   ]
  ]

  set api-key-wrap [
   global document createElement, call div
  ]
  get api-key-wrap classList add, call preferences-input-wrap
  get api-key-wrap appendChild, call [ get api-key-input ]

  set visibility-toggle [
   global document createElement, call button
  ]
  set visibility-toggle type 'button'
  get visibility-toggle classList add, call preferences-visibility-toggle
  set visibility-toggle title 'Show API key'
  set eye-icon [ get lib svg-icon, call /app/icons/eye.svg ]
  set eye-off-icon [ get lib svg-icon, call /app/icons/eye-off.svg ]
  set eye-off-icon style display 'none'
  get visibility-toggle appendChild, call [ get eye-icon ]
  get visibility-toggle appendChild, call [ get eye-off-icon ]

  get visibility-toggle addEventListener, call click [
   function [
    get api-key-input type, is 'password', true [
     set api-key-input type 'text'
     set eye-icon style display 'none'
     set eye-off-icon style display 'block'
     set visibility-toggle title 'Hide API key'
    ], false [
     set api-key-input type 'password'
     set eye-icon style display 'block'
     set eye-off-icon style display 'none'
     set visibility-toggle title 'Show API key'
    ]
   ]
  ]

  get api-key-wrap appendChild, call [ get visibility-toggle ]
  get api-section appendChild, call [ get api-key-label ]
  get api-section appendChild, call [ get api-key-wrap ]
  get general-content appendChild, call [ get api-section ]

  set windows-tab [
   get tabs add, call 'Windows' [
    function tab event [
     set windows-content style display 'block'
     set general-content style display 'none'
    ]
   ]
  ]

  set general-tab [
   get tabs add, call 'General' [
    function tab event [
     set windows-content style display 'none'
     set general-content style display 'block'
    ]
   ]
  ]

  get padding-container appendChild, call [ get tabs element ]
  get padding-container appendChild, call [ get windows-content ]
  get padding-container appendChild, call [ get general-content ]
  get content appendChild, call [ get padding-container ]

  get tabs set-active, call [ get windows-tab ]

  get prefs-window fill, call [ get content ]
  get main stage place-window, call [
   get prefs-window
  ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get prefs-window minimize-window, tell
   ]
  ]
 ]
]
