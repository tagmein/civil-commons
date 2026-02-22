# POST /api/sessions/:sessionId/contacts - Create a new contact
# Expects io module variables to be available (data-path, ij, oj, ensure-dir, generate-id)
# Request body: { name?, email? }

function request respond session-id body [
 set session-dir [ template '%0/sessions/%1' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ get session-dir ]

 set contacts-file [ template '%0/sessions/%1/contacts.json' [ get data-path ] [ get session-id ] ]
 set contacts [ list ]
 try [
  set contacts [ get ij, call [ get contacts-file ] ]
 ] [
  # File doesn't exist yet
 ]

 set contact-id [ get generate-id, call ]
 set contact [
  object [
   id [ get contact-id ]
   name [ get body name, default '' ]
   email [ get body email, default '' ]
  ]
 ]
 get contacts push, call [ get contact ]
 get oj, call [ get contacts-file ] [ get contacts ]

 get respond, call 201 [
  global JSON stringify, call [ get contact ]
 ] application/json
]
