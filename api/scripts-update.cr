# PATCH /api/sessions/:sessionId/scripts/:scriptId - Update script metadata and/or content
# Expects io module variables to be available (data-path, ij, oj, o)

function request respond session-id script-id body [
 set metadata-file [ template '%0/sessions/%1/scripts/%2/metadata.json' [ get data-path ] [ get session-id ] [ get script-id ] ]
 set content-file [ template '%0/sessions/%1/scripts/%2/content.cr' [ get data-path ] [ get session-id ] [ get script-id ] ]
 set result-ref [ object [ result null ] ]

 try [
  set metadata [ get ij, call [ get metadata-file ] ]
 ] [
  set result-ref result [ object [ error 'Script not found', status 404 ] ]
 ]

 get result-ref result, false [
  get body hasOwnProperty, call 'name', true [
   set metadata name [ get body name ]
  ]
  get body hasOwnProperty, call archived, true [
   set metadata archived [ get body archived ]
  ]
  get oj, call [ get metadata-file ] [ get metadata ]
  get body hasOwnProperty, call 'content', true [
   get o, call [ get content-file ] [ get body content ]
  ]
  set result-ref result [ object [
   id [ get script-id ]
   name [ get metadata name ]
   archived [ get metadata archived, default false ]
   createdAt [ get metadata createdAt ]
  ] ]
 ]

 get result-ref result status, true [
  get respond, call [ get result-ref result status ] [
   global JSON stringify, call [ get result-ref result ]
  ] application/json
 ], false [
  get respond, call 200 [
   global JSON stringify, call [ get result-ref result ]
  ] application/json
 ]
]
