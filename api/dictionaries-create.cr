# POST /api/sessions/:sessionId/dictionaries - Create a new dictionary in a session
# Expects io module variables to be available (data-path, oj, ensure-dir, generate-id)

function request respond session-id [
 set dict-id [ get generate-id, call ]

 get ensure-dir, call [ template '%0/sessions/%1/dictionaries' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/dictionaries/%2' [ get data-path ] [ get session-id ] [ get dict-id ] ]

 set metadata [
  object [
   name 'Untitled Dictionary'
   archived false
   createdAt [ global Date now, call ]
  ]
 ]

 get oj, call [
  template '%0/sessions/%1/dictionaries/%2/metadata.json' [ get data-path ] [ get session-id ] [ get dict-id ]
 ] [ get metadata ]

 set entries [ object ]
 get oj, call [
  template '%0/sessions/%1/dictionaries/%2/entries.json' [ get data-path ] [ get session-id ] [ get dict-id ]
 ] [ get entries ]

 set dicts-file [ template '%0/sessions/%1/dictionaries.json' [ get data-path ] [ get session-id ] ]
 set dictionaries [ list ]
 try [
  set dictionaries [ get ij, call [ get dicts-file ] ]
 ] [
  # File doesn't exist yet
 ]

 get dictionaries push, call [ get dict-id ]
 get oj, call [ get dicts-file ] [ get dictionaries ]

 get respond, call 201 [
  global JSON stringify, call [
   object [
    id [ get dict-id ]
    name [ get metadata name ]
    archived [ get metadata archived ]
    createdAt [ get metadata createdAt ]
   ]
  ]
 ] application/json
]
