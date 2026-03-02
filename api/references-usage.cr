# GET /api/sessions/:sessionId/references/:type/:refId/usage - Find where a reference is used in dictionaries
# Returns list of { dictionaryId, key } where this ref is used
# Expects io module variables to be available (data-path, ij)

function request respond session-id ref-type ref-id [
 set dicts-file [ template '%0/sessions/%1/dictionaries.json' [ get data-path ] [ get session-id ] ]
 set dict-ids [ list ]

 try [
  set dict-ids [ get ij, call [ get dicts-file ] ]
 ] [
  # File doesn't exist
 ]

 set usage [ list ]

 get dict-ids, each [
  function d-id [
   set entries-file [ template '%0/sessions/%1/dictionaries/%2/entries.json' [ get data-path ] [ get session-id ] [ get d-id ] ]
   set entries [ object ]
   try [
    set entries [ get ij, call [ get entries-file ] ]
   ] [
    # Entries file doesn't exist
   ]

   set keys [ global Object keys, call [ get entries ] ]
   get keys, each [
    function k [
     set entry [ get entries [ get k ] ]
     get entry, true [
      get entry type, is [ get ref-type ], true [
       get entry id, is [ get ref-id ], true [
        get usage push, call [
         object [
          dictionaryId [ get d-id ], key [ get k ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get usage ]
 ] application/json
]
