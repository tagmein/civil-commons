# Preferences modal - tabbed (Windows, etc.) with Log Preferences

get lib style-tag

tell '.preferences-content' [
 object [
  display flex
  flex-direction column
  height '100%'
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

  # Tab bar: Windows (and optionally General later)
  set tabs [ get components tab-bar, call ]

  set windows-content [
   global document createElement, call div
  ]
  set windows-content style display 'block'

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

  set windows-tab [
   get tabs add, call 'Windows' [
    function tab event [
     set windows-content style display 'block'
    ]
   ]
  ]

  get padding-container appendChild, call [ get tabs element ]
  get padding-container appendChild, call [ get windows-content ]
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
