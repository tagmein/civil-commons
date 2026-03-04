# GET /api/sessions/:sessionId/scripts/:scriptId - Get a script's metadata and content
# Expects io module variables to be available (data-path, ij, i)

function request respond session-id script-id [
 set metadata-file [ template '%0/sessions/%1/scripts/%2/metadata.json' [ get data-path ] [ get session-id ] [ get script-id ] ]
 set content-file [ template '%0/sessions/%1/scripts/%2/content.cr' [ get data-path ] [ get session-id ] [ get script-id ] ]
 set found [ object [ value false ] ]

 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  value undefined
 ]

 get found value, true [
  set content-ref [ object [ content '' ] ]
  try [
   set content-ref content [ get i, call [ get content-file ] ]
  ] [
   value undefined
  ]
  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get script-id ]
     name [ get metadata name ]
     createdAt [ get metadata createdAt ]
     content [ get content-ref content ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [ object [ error 'Script not found' ] ]
  ] application/json
 ]
]
