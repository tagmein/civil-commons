# GET /api/sessions/:sessionId/dictionaries - List all dictionaries in a session
# Expects io module variables to be available (data-path, ij)

function request respond session-id [
 set dicts-file [ template '%0/sessions/%1/dictionaries.json' [ get data-path ] [ get session-id ] ]
 set dict-ids [ list ]

 try [
  set dict-ids [ get ij, call [ get dicts-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]

 set dictionaries [ list ]
 get dict-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get dictionaries push, call [
     object [
      id [ get id ]
      name [ get metadata name ]
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
  global JSON stringify, call [ get dictionaries ]
 ] application/json
]
