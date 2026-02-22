# POST /api/sessions/:sessionId/mail/threads - Create a new mail thread
# Expects io module variables to be available (data-path, ij, oj, o, ensure-dir, generate-id)
# Request body: { subject?, from?, to?, body?, folder? }

function request respond session-id body [
 # Generate unique thread ID
 set thread-id [ get generate-id, call ]

 # Ensure directories exist
 get ensure-dir, call [ template '%0/sessions/%1/mail' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/mail/threads' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/mail/threads/%2' [ get data-path ] [ get session-id ] [ get thread-id ] ]

 # Build participants from from + to
 set from [ get body from, default '' ]
 set to [ get body to, default [ list ] ]
 set participants [ list ]
 get from, true [
  get participants push, call [ get from ]
 ]
 get to, true [
  get to, each [
   function addr [
    get addr, true [
     get participants push, call [ get addr ]
    ]
   ]
  ]
 ]

 # Create first message
 set msg-id [ get generate-id, call ]
 set messages [
  list [
   object [
    id [ get msg-id ]
    from [ get from ]
    to [ get body to, default [ list ] ]
    body [ get body body, default '' ]
    timestamp [ global Date now, call ]
   ]
  ]
 ]

 # Create metadata
 set metadata [
  object [
   id [ get thread-id ]
   subject [ get body subject, default '(No subject)' ]
   folder [ get body folder, default 'drafts' ]
   createdAt [ global Date now, call ]
   participants [ get participants ]
  ]
 ]

 # Write metadata
 get oj, call [
  template '%0/sessions/%1/mail/threads/%2/metadata.json' [ get data-path ] [ get session-id ] [ get thread-id ]
 ] [ get metadata ]

 # Write messages
 get oj, call [
  template '%0/sessions/%1/mail/threads/%2/messages.json' [ get data-path ] [ get session-id ] [ get thread-id ]
 ] [ get messages ]

 # Load or initialize threads list for this session
 set threads-file [ template '%0/sessions/%1/mail/threads.json' [ get data-path ] [ get session-id ] ]
 set threads [ list ]
 try [
  set threads [ get ij, call [ get threads-file ] ]
 ] [
  # File doesn't exist yet
 ]

 # Add new thread ID to list
 get threads push, call [ get thread-id ]
 get oj, call [ get threads-file ] [ get threads ]

 # Respond with the new thread
 get respond, call 201 [
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
]
