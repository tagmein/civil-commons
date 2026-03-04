# Document Window - Opens a window for viewing/editing a document
# Registers document:open action for opening documents by ID
# Registers document:new action for creating and opening new documents

get lib style-tag

tell '.document-content' [
 object [
  display flex
  flex-direction column
  height '100%'
  padding 0
 ]
]

tell '.document-textarea' [
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

tell '.document-preview' [
 object [
  background-color '#1e1e22'
  border none
  color '#e0e0d0'
  flex 1
  font-family 'Adwaita Sans', 'Noto Sans', sans-serif
  font-size 15px
  line-height 1.6
  padding 16px
  overflow-y auto
  display none
 ]
]

tell '.document-preview h1, .document-preview h2, .document-preview h3, .document-preview h4, .document-preview h5, .document-preview h6' [
 object [
  margin-top 0
  margin-bottom 16px
 ]
]

tell '.document-preview p' [
 object [
  margin-top 0
  margin-bottom 16px
 ]
]

tell '.document-preview pre' [
 object [
  background-color '#000000'
  padding 12px
  border-radius 4px
  overflow-x auto
 ]
]

tell '.document-preview code' [
 object [
  font-family 'Consolas, Monaco, monospace'
  background-color '#000000'
  padding '2px 4px'
  border-radius 3px
 ]
]

tell '.document-textarea:focus' [
 object [
  background-color '#222226'
 ]
]

tell '.document-status' [
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

tell '.document-status-id' [
 object [
  color '#606070'
  font-size 11px
  margin-left 8px
 ]
]

tell '.document-mode-select' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 3px
  color '#e0e0d0'
  font-size 11px
  outline none
  padding '1px 4px'
  cursor pointer
 ]
]

tell '.document-mode-select:hover' [
 object [
  border-color '#606070'
 ]
]

# Track open document windows by ID
set open-documents [ object ]
set main open-documents-ref [ object [ current [ get open-documents ] ] ]

# Create and open a document window
set open-document-window [ function doc-id [
 set doc-service [ get main document-service ]
 set session-service [ get main session-service ]

 # Check stage registry if already open - raise, focus, and flash
 set existing [ get main stage get-registered-window, call document [ get doc-id ] ]
 get existing, true [
  get existing raise-window, tell
  get main stage place-window, call [ get existing ] [ get main status ]
  get main set-last-interacted-element, call [ get existing element ]
  get existing element classList add, call window-flash
  global setTimeout, call [
   function [
    get existing element classList remove, call window-flash
   ]
  ] 1000
  value undefined
 ]
 get existing, false [
 # Fetch document data
 set doc [ get doc-service fetch-document, call [ get doc-id ] ]
 get doc, false [
  log Document not found: [ get doc-id ]
  value undefined
 ]

 # Create window with document name
 set doc-window [
  get components window, call [ get doc name ]
 ]

 # Attach log entry id so we can mark skipped on replay when window is closed
 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [
   set doc-window logEntryId [ get log-entry id ]
  ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [
   set doc-window logEntryId [ get replay-ev id ]
  ]
 ]

 # Create content container
 set content [
  global document createElement, call div
 ]
 get content classList add, call document-content

 # Create textarea for document content
 set textarea [
  global document createElement, call textarea
 ]
 get textarea classList add, call document-textarea
 set textarea value [ get doc content, default '' ]
 set textarea placeholder 'Start typing...'
 get content appendChild, call [ get textarea ]

 # Create preview container
 set preview [
  global document createElement, call div
 ]
 get preview classList add, call document-preview
 get content appendChild, call [ get preview ]

 # Create status bar (left: status text, center: mode select, right: document id)
 set status [
  global document createElement, call div
 ]
 get status classList add, call document-status
 set status-left [
  global document createElement, call span
 ]
 set status-left textContent 'Ready'
 get status appendChild, call [ get status-left ]

 # View Mode Select (Source / Preview)
 set view-mode-select [
  global document createElement, call select
 ]
 get view-mode-select classList add, call document-mode-select
 set view-modes [ list Source Preview ]
 get view-modes, each [
  function mode [
   set opt [ global document createElement, call option ]
   set opt value [ get mode ]
   set opt textContent [ get mode ]
   get view-mode-select appendChild, call [ get opt ]
  ]
 ]
 set view-mode-select value [ get doc markdownViewMode, default 'Source' ]
 get status appendChild, call [ get view-mode-select ]

 get view-mode-select addEventListener, call change [
  function [
   # Update view
   get update-visibility, call
   
   set status-left textContent 'Saving view mode...'
   set result [ get doc-service save-document-markdown-view-mode, call [ get doc-id ] [ get view-mode-select value ] ]
   get result, true [
    set status-left textContent 'Saved view mode'
   ], false [
    set status-left textContent 'Error saving view mode'
   ]
  ]
 ]

 # Mode Select
 set mode-select [
  global document createElement, call select
 ]
 get mode-select classList add, call document-mode-select
 set modes [ list CSV JSON Markdown 'Plain Text' YAML ]
 get modes, each [
  function mode [
   set opt [ global document createElement, call option ]
   set opt value [ get mode ]
   set opt textContent [ get mode ]
   get mode-select appendChild, call [ get opt ]
  ]
 ]
 # Default to document mode or Plain Text
 set mode-select value [ get doc mode, default 'Plain Text' ]
 get status appendChild, call [ get mode-select ]

 set update-visibility [ function [
  set is-markdown [ get mode-select value, is 'Markdown' ]
  
  get is-markdown, true [
   get view-mode-select style display 'inline-block'
   
   set is-preview [ get view-mode-select value, is 'Preview' ]
   get is-preview, true [
    get textarea style display 'none'
    get preview style display 'block'
    get lib markdown, call [ get preview ] [ get textarea value ]
   ], false [
    get textarea style display 'block'
    get preview style display 'none'
   ]
  ], false [
   get view-mode-select style display 'none'
   get textarea style display 'block'
   get preview style display 'none'
  ]
 ] ]

 # Initial visibility
 get update-visibility, call

 get mode-select addEventListener, call change [
  function [
   get update-visibility, call
   
   set status-left textContent 'Saving mode...'
   set result [ get doc-service save-document-mode, call [ get doc-id ] [ get mode-select value ] ]
   get result, true [
    set status-left textContent 'Saved mode'
   ], false [
    set status-left textContent 'Error saving mode'
   ]
  ]
 ]

 set status-id [
  global document createElement, call span
 ]
 get status-id classList add, call document-status-id
 set status-id textContent [ get doc-id ]
 get status appendChild, call [ get status-id ]
 get content appendChild, call [ get status ]

 # Auto-save on blur
 get textarea addEventListener, call blur [
  function [
   set status-left textContent 'Saving...'
   set result [ get doc-service save-document, call [ get doc-id ] [ get textarea value ] ]
   get result, true [
    set status-left textContent 'Saved'
   ], false [
    set status-left textContent 'Error saving'
   ]
  ]
 ]

 # Track focused document
 get textarea addEventListener, call focus [
  function [
   get doc-service set-current-document-id, call [ get doc-id ]
   get main set-last-interacted-element, call [ get doc-window element ]
  ]
 ]

 # Listen for rename events to update window title
 get doc-service on, call documentRenamed [
  function data [
   get data id, is [ get doc-id ], true [
    # Update window title
    set doc-window title-text textContent [ get data name ]
   ]
  ]
 ]

 # Store reference and set up cleanup (textarea and doc-id for AI insert)
 set doc-window textarea [ get textarea ]
 set doc-window doc-id [ get doc-id ]
 set open-documents [ get doc-id ] [ get doc-window ]
 get main stage register-window, call document [ get doc-id ] [ get doc-window ]

 # Override close to clean up and optionally mark log entry skipped on replay
 set original-close [ get doc-window close ]
 set doc-window close [ function [
  get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
   get doc-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get doc-window logEntryId ]
   ], false [
    get session-service mark-last-event-with-action-skipped-on-replay, call 'document:open'
   ]
  ]
  set open-documents [ get doc-id ] null
  get main stage unregister-window, call document [ get doc-id ]
  get original-close, call
 ] ]
 get doc-window logEntryId, true [
  set doc-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
  set doc-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
 ]

 get doc-window fill, call [ get content ]
 get main stage place-window, call [
  get doc-window
 ] [ get main status ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev minimized, true [
   get doc-window minimize-window, tell
  ]
 ]

 # Focus textarea
 global setTimeout, call [
  function [
   get textarea focus, call
  ]
 ] 50

 # Set as current document
 get doc-service set-current-document-id, call [ get doc-id ]
 get main set-last-interacted-element, call [ get doc-window element ]

 get doc-window element addEventListener, call mousedown [
  function [
   get doc-service set-current-document-id, call [ get doc-id ]
   get main set-last-interacted-element, call [ get doc-window element ]
  ]
 ]
 ]
] ]

# Register document:open action (arg can be doc-id string or object with id and name)
get conductor register, call document:open [
 function arg [
  set doc-id [ get arg id, default [ get arg ] ]
  get open-document-window, call [ get doc-id ]
 ]
]

# Register !document:new action (! prefix = skip on replay)
# Creating a new document should be logged but not replayed.
# We dispatch document:open which IS logged and replayed,
# so the same document reopens on page reload.
get conductor register, call '!document:new' [
 function [
  set doc-service [ get main document-service ]
  set doc [ get doc-service create-document, call ]
  get doc, true [
   get conductor dispatch, call document:open [ object [ id [ get doc id ], name [ get doc name, default 'Untitled' ] ] ]
  ]
 ]
 ]
