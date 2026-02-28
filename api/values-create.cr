# POST /api/sessions/:sessionId/values - Create a new value in a session

function request respond session-id [
 set val-id [ get generate-id, call ]

 get ensure-dir, call [ template '%0/sessions/%1/values' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/values/%2' [ get data-path ] [ get session-id ] [ get val-id ] ]

 set metadata [
  object [
   name 'Untitled Value'
   type string
   value ''
   archived false
   createdAt [ global Date now, call ]
  ]
 ]

 get oj, call [
  template '%0/sessions/%1/values/%2/metadata.json' [ get data-path ] [ get session-id ] [ get val-id ]
 ] [ get metadata ]

 set vals-file [ template '%0/sessions/%1/values.json' [ get data-path ] [ get session-id ] ]
 set values [ list ]
 try [
  set values [ get ij, call [ get vals-file ] ]
 ] [
  # File doesn't exist yet
 ]

 get values push, call [ get val-id ]
 get oj, call [ get vals-file ] [ get values ]

 get respond, call 201 [
  global JSON stringify, call [
   object [
    id [ get val-id ]
    name [ get metadata name ]
    type [ get metadata type ]
    value [ get metadata value ]
    archived [ get metadata archived ]
    createdAt [ get metadata createdAt ]
   ]
  ]
 ] application/json
]
