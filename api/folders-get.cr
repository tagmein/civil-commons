# GET /api/sessions/:sessionId/folders/:folderId
function request respond session-id folder-id [
 set metadata-file [ template '%0/sessions/%1/folders/%2/metadata.json' [ get data-path ] [ get session-id ] [ get folder-id ] ]
 get file-exists, call [ get metadata-file ], true [
  set metadata [ get ij, call [ get metadata-file ] ]
  set [ get metadata ] id [ get folder-id ]
  get respond, call 200 [
   global JSON stringify, call [ get metadata ]
  ]
 ], false [
  get respond, call 404 [
   global JSON stringify, call [ object [ error 'Folder not found' ] ]
  ]
 ]
]
