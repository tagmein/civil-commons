# GET /api/sessions/:sessionId/values - List all values in a session

function request respond session-id [
 set vals-file [ template '%0/sessions/%1/values.json' [ get data-path ] [ get session-id ] ]
 set val-ids [ list ]

 try [
  set val-ids [ get ij, call [ get vals-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]

 set values [ list ]
 get val-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/values/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get values push, call [
     object [
      id [ get id ]
      name [ get metadata name ]
      type [ get metadata type ]
      value [ get metadata value ]
      archived [ get metadata archived ]
      createdAt [ get metadata createdAt ]
     ]
    ]
   ] [
    # Metadata file doesn't exist
   ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get values ]
 ] application/json
]
