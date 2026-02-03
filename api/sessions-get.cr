# GET /api/sessions/:id - Get a single session's metadata
# Expects io module variables to be available (data-path, ij)
# Expects session-id to be set by serve.cr before calling

function request respond session-id [
 # Try to read session metadata
 set metadata-file [ template '%0/sessions/%1/metadata.json' [ get data-path ] [ get session-id ] ]
 set found [ object [ value false ] ]
 
 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]
 
 get found value, true [
  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get session-id ]
     name [ get metadata name ]
     archived [ get metadata archived ]
     createdAt [ get metadata createdAt ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Session not found' ]
   ]
  ] application/json
 ]
]
