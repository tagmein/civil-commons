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
 ]
]

# Track open document windows by ID
set open-documents [ object ]

# Create and open a document window
set open-document-window [ function doc-id [
 set doc-service [ get main document-service ]
 
 # Check if already open
 get open-documents [ get doc-id ], true [
  # Focus the existing window (bring to front)
  # For now, just return - could implement window focus later
  value undefined
 ]
 
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
 
 # Create status bar
 set status [
  global document createElement, call div
 ]
 get status classList add, call document-status
 set status textContent 'Ready'
 get content appendChild, call [ get status ]
 
 # Auto-save on blur
 get textarea addEventListener, call blur [
  function [
   set status textContent 'Saving...'
   set result [ get doc-service save-document, call [ get doc-id ] [ get textarea value ] ]
   get result, true [
    set status textContent 'Saved'
   ], false [
    set status textContent 'Error saving'
   ]
  ]
 ]
 
 # Track focused document
 get textarea addEventListener, call focus [
  function [
   get doc-service set-current-document-id, call [ get doc-id ]
  ]
 ]
 
 # Listen for rename events to update window title
 get doc-service on, call documentRenamed [
  function data [
   get data id, is [ get doc-id ], true [
    # Update window title
    set doc-window title-bar textContent [ get data name ]
   ]
  ]
 ]
 
 # Store reference and set up cleanup
 set open-documents [ get doc-id ] [ get doc-window ]
 
 # Override close to clean up
 set original-close [ get doc-window close ]
 set doc-window close [ function [
  # Remove from open documents
  set open-documents [ get doc-id ] null
  # Call original close
  get original-close, call
 ] ]
 
 get doc-window fill, call [ get content ]
 get main stage place-window, call [
  get doc-window
 ] [ get main status ]
 
 # Focus textarea
 global setTimeout, call [
  function [
   get textarea focus, call
  ]
 ] 50
 
 # Set as current document
 get doc-service set-current-document-id, call [ get doc-id ]
] ]

# Register document:open action
get conductor register, call document:open [
 function doc-id [
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
   # Dispatch document:open so it gets logged for replay
   get conductor dispatch, call document:open [ get doc id ]
  ]
 ]
]
