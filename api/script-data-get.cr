# GET /api/sessions/:sessionId/script-data/:runId/:dataKey - Get script run data (JSON)
# Expects io module variables (data-path, ij, file-exists, respond)

function request respond session-id run-id data-key [
 set dir [ template '%0/sessions/%1/script-data/%2' [ get data-path ] [ get session-id ] [ get run-id ] ]
 set file [ template '%0/%1' [ get dir ] [ get data-key ] ]
 set has-json [ get data-key at endsWith, call '.json' ]
 get has-json, false [
  set file [ template '%0.json' [ get file ] ]
 ]

 set found [ object [ value false ] ]
 set data-ref [ object [ data null ] ]
 
 set exists [ get file-exists, call [ get file ] ]
 get exists, true [
  try [
   set data-ref data [ get ij, call [ get file ] ]
   set found value true
  ] [
   # Parsing error or other read error
  ]
 ]

 get found value, true [
  get respond, call 200 [
   global JSON stringify, call [ get data-ref data ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [ object [ error 'Not found' ] ]
  ] application/json
 ]
]
