# GET /api/sessions/:sessionId/mail/accounts - List mail accounts (Gmail, SMTP)
# Expects io module variables (data-path, ij)

function request respond session-id [
 set file [ template '%0/sessions/%1/mail/accounts.json' [ get data-path ] [ get session-id ] ]
 set accounts [ list ]
 try [
  set accounts [ get ij, call [ get file ] ]
 ] [
  # File doesn't exist
 ]
 get respond, call 200 [
  global JSON stringify, call [ get accounts ]
 ] application/json
]
