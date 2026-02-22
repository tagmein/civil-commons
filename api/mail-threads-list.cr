# GET /api/sessions/:sessionId/mail/threads - List all mail threads in a session
# Optional query param: folder (inbox|sent|drafts|archived)
# Expects io module variables to be available (data-path, ij)

function request respond session-id [
 # Load threads list for this session
 set threads-file [ template '%0/sessions/%1/mail/threads.json' [ get data-path ] [ get session-id ] ]
 set thread-ids [ list ]

 try [
  set thread-ids [ get ij, call [ get threads-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]

 # Load metadata for each thread
 set threads [ list ]
 get thread-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/mail/threads/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get threads push, call [
     object [
      id [ get id ]
      subject [ get metadata subject, default '(No subject)' ]
      folder [ get metadata folder, default 'inbox' ]
      createdAt [ get metadata createdAt ]
      participants [ get metadata participants, default [ list ] ]
     ]
    ]
   ] [
    # Metadata file doesn't exist
   ]
  ]
 ]

 # Filter by folder if query param present (parse from request url)
 set url [ get request url ]
 set has-folder [ get url, at includes, call 'folder=' ]
 get has-folder, true [
  set query-part [ get url, at split, call '?', at 1 ]
  get query-part, true [
   set params [ get query-part, at split, call '&' ]
   set folder-ref [ object [ value null ] ]
   get params, each [
    function param [
     get param, at startsWith, call 'folder=', true [
      set folder-ref value [ get param, at substring, call 7 ]
     ]
    ]
   ]
   get folder-ref value, true [
    set filtered [ list ]
    get threads, each [
     function t [
      get t folder, is [ get folder-ref value ], true [
       get filtered push, call [ get t ]
      ]
     ]
    ]
    set threads [ get filtered ]
   ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get threads ]
 ] application/json
]
