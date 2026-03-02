# GET /api/sessions/:sessionId/dictionaries/:dictId - Get a dictionary's metadata and entries
# Expects io module variables to be available (data-path, ij)

function request respond session-id dict-id [
 set metadata-file [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get data-path ] [ get session-id ] [ get dict-id ] ]
 set entries-file [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get data-path ] [ get session-id ] [ get dict-id ] ]
 set found [ object [ value false ] ]

 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]

 get found value, true [
  set entries [ object ]
  try [
   set entries [ get ij, call [ get entries-file ] ]
  ] [
   # Entries file doesn't exist, use empty object
  ]

  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get dict-id ]
     name [ get metadata name ]
     archived [ get metadata archived ]
     createdAt [ get metadata createdAt ]
     entries [ get entries ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Dictionary not found' ]
   ]
  ] application/json
 ]
]
