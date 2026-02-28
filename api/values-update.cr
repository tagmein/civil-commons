# PATCH /api/sessions/:sessionId/values/:valueId - Update value metadata
# Request body can contain: name, type, value, archived

function request respond session-id val-id body [
 set metadata-file [ template '%0/sessions/%1/values/%2/metadata.json' [ get data-path ] [ get session-id ] [ get val-id ] ]
 set found [ object [ value false ] ]

 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]

 get found value, true [
  get body name, true [
   set metadata name [ get body name ]
  ]
  get body type, true [
   set metadata type [ get body type ]
  ]
  # value can be null/false/0/"", so check if key exists via hasOwnProperty
  get body hasOwnProperty, call value, true [
   set metadata value [ get body value ]
  ]
  get body archived, true [
   set metadata archived [ get body archived ]
  ]
  # Handle archived: false explicitly
  get body hasOwnProperty, call archived, true [
   set metadata archived [ get body archived ]
  ]

  get oj, call [ get metadata-file ] [ get metadata ]

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
