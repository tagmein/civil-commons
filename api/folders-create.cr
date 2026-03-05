# POST /api/sessions/:sessionId/folders
function request respond session-id [
 set folder-id [ get generate-id, call ]
 get ensure-dir, call [ template '%0/sessions/%1/folders' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/folders/%2' [ get data-path ] [ get session-id ] [ get folder-id ] ]
 
 get oj, call [ template '%0/sessions/%1/folders/%2/metadata.json' [ get data-path ] [ get session-id ] [ get folder-id ] ] [
  object [
   name 'Untitled Folder'
   path ''
   items [ list ]
   createdAt [ global Date, new, at getTime, call ]
  ]
 ]

 set folders-file [ template '%0/sessions/%1/folders.json' [ get data-path ] [ get session-id ] ]
 set folders [ list ]
 try [
  set folders [ get ij, call [ get folders-file ] ]
 ] [
  # File doesn't exist yet
 ]
 get folders push, call [ get folder-id ]
 get oj, call [ get folders-file ] [ get folders ]

 get respond, call 200 [
  global JSON stringify, call [ object [ id [ get folder-id ] ] ]
 ]
]
