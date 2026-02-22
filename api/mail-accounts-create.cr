# POST /api/sessions/:sessionId/mail/accounts - Add mail account
# Body: { type: 'gmail'|'smtp', email, label?, host?, port? }
# Expects io (data-path, ij, oj, ensure-dir, generate-id)

function request respond session-id body [
 get ensure-dir, call [ template '%0/sessions/%1/mail' [ get data-path ] [ get session-id ] ]
 set file [ template '%0/sessions/%1/mail/accounts.json' [ get data-path ] [ get session-id ] ]
 set accounts [ list ]
 try [
  set accounts [ get ij, call [ get file ] ]
 ] [
 ]
 set new [ object [
  id [ get generate-id, call ]
  type [ get body type, default 'smtp' ]
  email [ get body email, default '' ]
  label [ get body label, default '' ]
  host [ get body host, default '' ]
  port [ get body port, default 587 ]
 ] ]
 get accounts push, call [ get new ]
 get oj, call [ get file ] [ get accounts ]
 get respond, call 201 [
  global JSON stringify, call [ get new ]
 ] application/json
]
