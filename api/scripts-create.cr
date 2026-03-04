# POST /api/sessions/:sessionId/scripts - Create a new script in a session
# Expects io module variables to be available (data-path, ij, oj, o, ensure-dir, generate-id)

function request respond session-id [
 set script-id [ get generate-id, call ]

 get ensure-dir, call [ template '%0/sessions/%1/scripts' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/scripts/%2' [ get data-path ] [ get session-id ] [ get script-id ] ]

 set metadata [
  object [
   name 'Untitled Script'
   archived false
   createdAt [ global Date now, call ]
  ]
 ]

 get oj, call [
  template '%0/sessions/%1/scripts/%2/metadata.json' [ get data-path ] [ get session-id ] [ get script-id ]
 ] [ get metadata ]

 get o, call [
  template '%0/sessions/%1/scripts/%2/content.cr' [ get data-path ] [ get session-id ] [ get script-id ]
 ] ''

 set scripts-file [ template '%0/sessions/%1/scripts.json' [ get data-path ] [ get session-id ] ]
 set scripts [ list ]
 try [
  set scripts [ get ij, call [ get scripts-file ] ]
 ] [
  value undefined
 ]
 get scripts push, call [ get script-id ]
 get oj, call [ get scripts-file ] [ get scripts ]

 get respond, call 201 [
  global JSON stringify, call [
   object [
    id [ get script-id ]
    name [ get metadata name ]
    createdAt [ get metadata createdAt ]
   ]
  ]
 ] application/json
]
