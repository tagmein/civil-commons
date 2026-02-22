# GET /api/sessions/:sessionId/mail/sync-history - List sync history
# POST /api/sessions/:sessionId/mail/sync-history - Append sync record
# Body: { accountId, result, count, error? }

function request respond session-id body [
 set file [ template '%0/sessions/%1/mail/sync-history.json' [ get data-path ] [ get session-id ] ]
 set history [ list ]
 try [
  set history [ get ij, call [ get file ] ]
 ] [
 ]
 get request method, is POST, true [
  set record [ object [
   timestamp [ global Date now, call ]
   accountId [ get body accountId, default '' ]
   result [ get body result, default 'success' ]
   count [ get body count, default 0 ]
   error [ get body error, default '' ]
  ] ]
  get history push, call [ get record ]
  get ensure-dir, call [ template '%0/sessions/%1/mail' [ get data-path ] [ get session-id ] ]
  get oj, call [ get file ] [ get history ]
 ]
 get respond, call 200 [
  global JSON stringify, call [ get history ]
 ] application/json
]
