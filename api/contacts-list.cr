# GET /api/sessions/:sessionId/contacts - List all contacts in a session
# Expects io module variables to be available (data-path, ij)

function request respond session-id [
 set contacts-file [ template '%0/sessions/%1/contacts.json' [ get data-path ] [ get session-id ] ]
 set contacts [ list ]

 try [
  set contacts [ get ij, call [ get contacts-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]

 get respond, call 200 [
  global JSON stringify, call [ get contacts ]
 ] application/json
]
