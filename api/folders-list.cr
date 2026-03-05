# GET /api/sessions/:sessionId/folders
function request respond session-id [
 set folders-file [ template '%0/sessions/%1/folders.json' [ get data-path ] [ get session-id ] ]
 set folder-ids [ list ]
 try [
  set folder-ids [ get ij, call [ get folders-file ] ]
 ] [
  # File doesn't exist yet
 ]

 set folders [ list ]
 get folder-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/folders/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   get file-exists, call [ get metadata-file ], true [
    set metadata [ get ij, call [ get metadata-file ] ]
    set [ get metadata ] id [ get id ]
    get folders push, call [ get metadata ]
   ]
  ]
 ]

 get respond, call 200 [
  global JSON stringify, call [ get folders ]
 ]
]
