# DELETE /api/sessions/:sessionId/contacts/:contactId - Delete a contact
# Expects io module variables to be available (data-path, ij, oj)

function request respond session-id contact-id [
 set contacts-file [ template '%0/sessions/%1/contacts.json' [ get data-path ] [ get session-id ] ]
 set contacts [ list ]

 try [
  set contacts [ get ij, call [ get contacts-file ] ]
 ] [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Contact not found' ]
   ]
  ] application/json
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
  get contacts splice, call [ get found-index value ] 1
  get oj, call [ get contacts-file ] [ get contacts ]
  get respond, call 200 [
   global JSON stringify, call [
    object [ success true ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Contact not found' ]
   ]
  ] application/json
 ]
]
