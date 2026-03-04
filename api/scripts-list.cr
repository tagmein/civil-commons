# GET /api/sessions/:sessionId/scripts - List all scripts in a session
# Expects io module variables to be available (data-path, ij)

function request respond session-id [
 set scripts-file [ template '%0/sessions/%1/scripts.json' [ get data-path ] [ get session-id ] ]
 set script-ids [ list ]

 try [
  set script-ids [ get ij, call [ get scripts-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]

 set scripts [ list ]
 get script-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/scripts/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get scripts push, call [
     object [
      id [ get id ]
      name [ get metadata name ]
      archived [ get metadata archived, default false ]
      createdAt [ get metadata createdAt ]
     ]
    ]
   ] [
    # Metadata file doesn't exist
   ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get scripts ]
 ] application/json
]
