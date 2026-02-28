# Document Service - Document management within a session
# Provides functions for creating, loading, updating, and managing documents

# Event listeners for document changes
set listeners [ object [
 change [ list ]
 documentRenamed [ list ]
] ]

# Trigger event listeners
set emit [ function event-name data [
 get listeners [ get event-name ], each [
  function callback [
   get callback, call [ get data ]
  ]
 ]
] ]

# Subscribe to document changes
set on [ function event-name callback [
 get listeners [ get event-name ] push, call [ get callback ]
] ]

# Track the currently focused document ID
set current-doc-ref [ object [ id null ] ]

# Get current document ID
set get-current-document-id [ function [
 get current-doc-ref id
] ]

# Set current document ID
set set-current-document-id [ function id [
 set current-doc-ref id [ get id ]
 set main last-interacted [ object [ type document, id [ get id ] ] ]
 get emit, call change [ get id ]
] ]

# Get the current session ID from session service
set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

# Fetch all documents for the current session
set fetch-all-documents [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ docs [ list ] ] ]
 get session-id, true [
  try [
   set result-ref docs [
    global fetch, call [ template '/api/sessions/%0/documents' [ get session-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref docs
] ]

# Fetch a single document
set fetch-document [ function doc-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref doc
] ]

# Create a new document
set create-document [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents' [ get session-id ] ] [
     object [ method 'POST' ]
    ]
    at json, call
   ]
  ] [
   # Failed to create
  ]
 ]
 get result-ref doc
] ]

# Rename a document
set rename-document [ function doc-id new-name [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
     ]
    ]
    at json, call
   ]
   # Emit documentRenamed event
   get emit, call documentRenamed [ object [ id [ get doc-id ], name [ get new-name ] ] ]
  ] [
   # Failed to rename
  ]
 ]
 get result-ref doc
] ]

# Archive a document
set archive-document [ function doc-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ archived true ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to archive
  ]
 ]
 get result-ref doc
] ]

# Restore a document (unarchive)
set restore-document [ function doc-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ archived false ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to restore
  ]
 ]
 get result-ref doc
] ]

# Save document content
set save-document [ function doc-id content [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ doc null ] ]
 get session-id, true [
  try [
   set result-ref doc [
    global fetch, call [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ object [ content [ get content ] ] ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to save
  ]
 ]
 get result-ref doc
] ]

# Export service object
object [
 on
 get-current-document-id
 set-current-document-id
 fetch-all-documents
 fetch-document
 create-document
 rename-document
 archive-document
 restore-document
 save-document
]
