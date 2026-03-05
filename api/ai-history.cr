# GET /api/sessions/:sessionId/ai/history - List history
# POST /api/sessions/:sessionId/ai/history - Append history record
# DELETE /api/sessions/:sessionId/ai/history/:id - Remove history record
# Body: { prompt, model, result }

function request respond session-id body [
 set file [ template '%0/sessions/%1/ai/history.json' [ get data-path ] [ get session-id ] ]
 set history [ list ]
 try [
  set history [ get ij, call [ get file ] ]
 ] [
 ]

 get request method, is POST, true [
  set record [ object [
   id [ global Date now, call ]
   prompt [ get body prompt ]
   model [ get body model ]
   result [ get body result ]
   date [ global Date now, call ]
   status [ get body status ]
  ] ]
  get history unshift, call [ get record ]
  get history length, > 50, true [
   get history splice, call 50 [ get history length ]
  ]
  get ensure-dir, call [ template '%0/sessions/%1/ai' [ get data-path ] [ get session-id ] ]
  get oj, call [ get file ] [ get history ]
 ]

 get request method, is DELETE, true [
  # For DELETE, we might need the ID from the URL. serve.cr handles params.
  # If ID is passed in body for simplicity since we are in a custom proxy:
  set delete-id [ get body id ]
  get delete-id, true [
   set new-history [ list ]
   get history, each [
    function item [
     get item id, is [ get delete-id ], false [
      get new-history push, call [ get item ]
     ]
    ]
   ]
   set history [ get new-history ]
   get ensure-dir, call [ template '%0/sessions/%1/ai' [ get data-path ] [ get session-id ] ]
   get oj, call [ get file ] [ get history ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get history ]
 ] application/json
]
