# GET /api/sessions/:sessionId/mail/threads/:threadId - Get a single thread with messages
# Expects io module variables to be available (data-path, ij)

function request respond session-id thread-id [
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
  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get thread-id ]
     subject [ get metadata subject ]
     folder [ get metadata folder ]
     createdAt [ get metadata createdAt ]
     participants [ get metadata participants, default [ list ] ]
     messages [ get messages, default [ list ] ]
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
