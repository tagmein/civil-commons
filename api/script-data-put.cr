# PUT /api/sessions/:sessionId/script-data/:runId/:dataKey - Write script run data (JSON)
# Creates script-data/run_id folder and data key file if needed
# Expects io module variables (data-path, oj, ensure-dir)

function request respond session-id run-id data-key body [
 set dir [ template '%0/sessions/%1/script-data/%2' [ get data-path ] [ get session-id ] [ get run-id ] ]
 get ensure-dir, call [ get dir ]
 set has-json [ get data-key at endsWith, call .json ]
 set file [ get has-json, true [ template '%0/%1' [ get dir ] [ get data-key ] ], false [ template '%0/%1.json' [ get dir ] [ get data-key ] ] ]
 get oj, call [ get file ] [ get body ]
 get respond, call 200 [
  global JSON stringify, call [ object [ ok true ] ]
 ] application/json
]
