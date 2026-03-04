# Script Window - Opens a window for editing Crown script source
# Registers script:open and !script:new actions

get lib style-tag

tell '.script-content' [
 object [
  display flex
  flex-direction column
  height '100%'
  padding 0
 ]
]

tell '.script-textarea' [
 object [
  background-color '#1e1e22'
  border none
  color '#e0e0d0'
  flex 1
  font-family 'Consolas, Monaco, monospace'
  font-size 14px
  line-height 1.5
  padding 16px
  resize none
  outline none
 ]
]

tell '.script-textarea:focus' [
 object [
  background-color '#222226'
 ]
]

tell '.script-status' [
 object [
  background-color '#333337'
  border-top '1px solid #444448'
  color '#808080'
  font-size 12px
  padding '4px 12px'
  flex-shrink 0
  display flex
  justify-content space-between
  align-items center
 ]
]

tell '.script-status-id' [
 object [
  color '#606070'
  font-size 11px
  margin-left 8px
 ]
]

set open-scripts [ object ]
set main open-scripts-ref [ object [ current [ get open-scripts ] ] ]

set open-script-window [ function script-id [
 set script-service [ get main script-service ]
 set session-service [ get main session-service ]

 get open-scripts [ get script-id ], true [
  value undefined
 ]

 set script [ get script-service fetch-script, call [ get script-id ] ]
 get script, false [
  log Script not found: [ get script-id ]
  value undefined
 ]

 set script-window [
  get components window, call [ get script name, default 'Untitled Script' ] 500 400
 ]

 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [
   set script-window logEntryId [ get log-entry id ]
  ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [
   set script-window logEntryId [ get replay-ev id ]
  ]
 ]

 set content [ global document createElement, call div ]
 get content classList add, call script-content

 set textarea [ global document createElement, call textarea ]
 get textarea classList add, call script-textarea
 set textarea value [ get script content, default '' ]
 set textarea placeholder '# Crown script - scope: window, runId, sessionId, platform. Use get platform listDocuments, call [ get sessionId ] to list docs; get window content appendChild, call [ get element ] to add UI. See docs/script-platform-api.md'
 get content appendChild, call [ get textarea ]

 set status [ global document createElement, call div ]
 get status classList add, call script-status
 set status-left [ global document createElement, call span ]
 set status-left textContent 'Ready'
 get status appendChild, call [ get status-left ]
 set status-id [ global document createElement, call span ]
 get status-id classList add, call script-status-id
 set status-id textContent [ get script-id ]
 get status appendChild, call [ get status-id ]
 get content appendChild, call [ get status ]

 get textarea addEventListener, call blur [
  function [
   set status-left textContent 'Saving...'
   set result [ get script-service save-script, call [ get script-id ] [ get textarea value ] ]
   get result, true [
    set status-left textContent 'Saved'
   ], false [
    set status-left textContent 'Error saving'
   ]
  ]
 ]

 get textarea addEventListener, call focus [
  function [
   get script-service set-current-script-id, call [ get script-id ]
   get main set-last-interacted-element, call [ get script-window element ]
  ]
 ]

 get script-service on, call scriptRenamed [
  function data [
   get data id, is [ get script-id ], true [
    set script-window title-text textContent [ get data name ]
   ]
  ]
 ]

 set script-window textarea [ get textarea ]
 set script-window script-id [ get script-id ]
 set open-scripts [ get script-id ] [ get script-window ]

 set original-close [ get script-window close ]
 set script-window close [ function [
  get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
   get script-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get script-window logEntryId ]
   ], false [
    get session-service mark-last-event-with-action-skipped-on-replay, call 'script:open'
   ]
  ]
  set open-scripts [ get script-id ] null
  get original-close, call
 ] ]
 get script-window logEntryId, true [
  set script-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
  set script-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
 ]

 get script-window fill, call [ get content ]
 get main stage place-window, call [ get script-window ] [ get main status ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev minimized, true [
   get script-window minimize-window, tell
  ]
 ]

 global setTimeout, call [
  function [
   get textarea focus, call
  ]
 ] 50

 get script-service set-current-script-id, call [ get script-id ]
 get main set-last-interacted-element, call [ get script-window element ]

 get script-window element addEventListener, call mousedown [
  function [
   get script-service set-current-script-id, call [ get script-id ]
   get main set-last-interacted-element, call [ get script-window element ]
  ]
 ]
] ]

get conductor register, call script:open [
 function arg [
  set script-id [ get arg id, default [ get arg ] ]
  get open-script-window, call [ get script-id ]
 ]
]

get conductor register, call '!script:new' [
 function [
  set script-service [ get main script-service ]
  set script [ get script-service create-script, call ]
  get script, true [
   get conductor dispatch, call script:open [ object [ id [ get script id ], name [ get script name, default 'Untitled Script' ] ] ]
  ]
 ]
]

# Run the last-active script in a new window (window binding available to script)
# Passes window, runId, sessionId for script-data persistence (runId persists across page reloads)
# Arg may be scriptId string, { id: scriptId }, or nothing (use last-interacted). Only proceed when script-id is a string.
# Use ref so script-id persists (Crown true/false blocks run in cloned scope so set inside them doesn't persist).
get conductor register, call 'script:run' [
 function arg [
  set script-id-ref [ object [ value null ] ]
  get arg, true [
   set script-id-ref value [ get arg id, default [ get arg ] ]
  ]
  get script-id-ref value, false [
   set last [ get main last-interacted ]
   get last type, is script, true [
    set script-id-ref value [ get last id ]
   ]
  ]
  set script-id [ get script-id-ref value ]
  get script-id, true [
   set script-service [ get main script-service ]
   set session-service [ get main session-service ]
   set script-id-str [ get script-id, at toString, call ]
   set script [ get script-service fetch-script, call [ get script-id-str ] ]
   get script, true [
    set run-id [ get script-id-str ]
    set session-id [ get main session-service get-current-session-id, call ]
    set run-window [ get components window, call 'Script Output' 400 300 ]
    set run-content [ global document createElement, call div ]
    get run-window fill, call [ get run-content ]

    set log-entry [ get conductor getLastLoggedEntry, call ]
    get log-entry, true [
     get log-entry id, true [
      set run-window logEntryId [ get log-entry id ]
     ]
    ]
    set replay-ev [ get conductor getReplayEvent, call ]
    get replay-ev, true [
     get replay-ev id, true [
      set run-window logEntryId [ get replay-ev id ]
     ]
    ]

    set original-close [ get run-window close ]
    set run-window close [ function [
     get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
      get run-window logEntryId, true [
       get session-service mark-event-skipped-on-replay, call [ get run-window logEntryId ]
      ], false [
       get session-service mark-last-event-with-action-skipped-on-replay, call 'script:run'
      ]
     ]
     get original-close, call
    ] ]
    get run-window logEntryId, true [
     set run-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
     set run-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
    ]

    get main stage place-window, call [ get run-window ] [ get main status ]
    get runScript, call [
     object [
      window [ get run-window ]
      runId [ get run-id ]
      sessionId [ get session-id ]
      platform [ get main script-platform ]
     ]
    ] [ get script content, default '' ]

    set replay-ev [ get conductor getReplayEvent, call ]
    get replay-ev, true [
     get replay-ev minimized, true [
      get run-window minimize-window, tell
     ]
    ]
   ]
  ]
 ]
]
