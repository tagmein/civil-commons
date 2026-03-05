# PATCH /api/sessions/:sessionId/folders/:folderId
function request respond session-id folder-id body [
 set metadata-file [ template '%0/sessions/%1/folders/%2/metadata.json' [ get data-path ] [ get session-id ] [ get folder-id ] ]
 get file-exists, call [ get metadata-file ], true [
  set metadata [ get ij, call [ get metadata-file ] ]
  
  get body name, typeof, is string, true [
   set [ get metadata ] name [ get body name ]
  ]
  get body path, typeof, is string, true [
   set [ get metadata ] path [ get body path ]
  ]
  get body items, typeof, is object, true [
   set [ get metadata ] items [ get body items ]
  ]

  get oj, call [ get metadata-file ] [ get metadata ]
  get respond, call 200 [ global JSON stringify, call [ object [ success true ] ] ]
 ], false [
  get respond, call 404 [ global JSON stringify, call [ object [ error 'Folder not found' ] ] ]
 ]
]
