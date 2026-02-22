# PATCH /api/sessions/:sessionId/contacts/:contactId - Update a contact
# Expects io module variables to be available (data-path, ij, oj)
# Request body can contain: name, email

function request respond session-id contact-id body [
 set contacts-file [ template '%0/sessions/%1/contacts.json' [ get data-path ] [ get session-id ] ]
 set found [ object [ value false ] ]
 set contacts [ list ]

 try [
  set contacts [ get ij, call [ get contacts-file ] ]
 ] [
  # File doesn't exist
 ]

 set found-index [ object [ value -1 ] ]
 set index-ref [ object [ i 0 ] ]
 get contacts, each [
  function c [
   get c id, is [ get contact-id ], true [
    set found-index value [ get index-ref i ]
   ]
   set index-ref i [ get index-ref i, add 1 ]
  ]
 ]

 get found-index value, >= 0, true [
  set contact [ get contacts, at [ get found-index value ] ]
  get body name, true [
   set contact name [ get body name ]
  ]
  get body email, true [
   set contact email [ get body email ]
  ]
  get oj, call [ get contacts-file ] [ get contacts ]
  get respond, call 200 [
   global JSON stringify, call [ get contact ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Contact not found' ]
   ]
  ] application/json
 ]
]
