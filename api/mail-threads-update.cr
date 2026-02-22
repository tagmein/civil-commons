# PATCH /api/sessions/:sessionId/mail/threads/:threadId - Update thread metadata or append message
# Expects io module variables to be available (data-path, ij, oj, o)
# Request body can contain: subject, folder, messages (replace), appendMessage (object to append)

function request respond session-id thread-id body [
 set metadata-file [ template '%0/sessions/%1/mail/threads/%2/metadata.json' [ get data-path ] [ get session-id ] [ get thread-id ] ]
 set messages-file [ template '%0/sessions/%1/mail/threads/%2/messages.json' [ get data-path ] [ get session-id ] [ get thread-id ] ]
 set found [ object [ value false ] ]

 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set messages [ get ij, call [ get messages-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]

 get found value, true [
  # Update metadata fields if provided
  get body subject, true [
   set metadata subject [ get body subject ]
  ]
  get body folder, true [
   set metadata folder [ get body folder ]
  ]
  get body participants, true [
   set metadata participants [ get body participants ]
  ]

  # Replace messages if provided
  get body messages, true [
   set messages [ get body messages ]
  ]

  # Append message if provided
  get body appendMessage, true [
   set new-msg [ get body appendMessage ]
   get new-msg id, false [
    set new-msg id [ get generate-id, call ]
   ]
   get new-msg timestamp, false [
    set new-msg timestamp [ global Date now, call ]
   ]
   get messages push, call [ get new-msg ]
  ]

  # Save updated metadata
  get oj, call [ get metadata-file ] [ get metadata ]

  # Save updated messages
  get oj, call [ get messages-file ] [ get messages ]

  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get thread-id ]
     subject [ get metadata subject ]
     folder [ get metadata folder ]
     createdAt [ get metadata createdAt ]
     participants [ get metadata participants ]
     messages [ get messages ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Thread not found' ]
   ]
  ] application/json
 ]
]
