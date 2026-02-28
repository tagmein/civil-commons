# GET /api/sessions/:sessionId/values/:valueId - Get a value's metadata

function request respond session-id val-id [
 set metadata-file [ template '%0/sessions/%1/values/%2/metadata.json' [ get data-path ] [ get session-id ] [ get val-id ] ]
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
     id [ get val-id ]
     name [ get metadata name ]
     type [ get metadata type ]
     value [ get metadata value ]
     archived [ get metadata archived ]
     createdAt [ get metadata createdAt ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Value not found' ]
   ]
  ] application/json
 ]
]
