# GET /api/sessions/:sessionId/fs/*
function request respond session-id [
 set url-parts [ get request url, at split, call / ]
 set fs-path [ get url-parts, at slice, call 5, at join, call / ] # e.g. "lib/build.cr" or "build.cr"
 
 # We need to split fs-path into directory and filename
 set path-parts [ get fs-path, at split, call / ]
 set filename [ get path-parts pop, call ] # "build.cr"
 set dir-path [ get path-parts, at join, call / ] # "lib" or ""
 
 # Load folders
 set folders-file [ template '%0/sessions/%1/folders.json' [ get data-path ] [ get session-id ] ]
 set folder-ids [ list ]
 try [
  set folder-ids [ get ij, call [ get folders-file ] ]
 ] [
  # File doesn't exist yet
 ]

 set found-script-id [ object [ value null ] ]

 get folder-ids, each [
  function f-id [
   get found-script-id value, false [
    set f-meta-file [ template '%0/sessions/%1/folders/%2/metadata.json' [ get data-path ] [ get session-id ] [ get f-id ] ]
    get file-exists, call [ get f-meta-file ], true [
     set f-meta [ get ij, call [ get f-meta-file ] ]
     
     # Check if folder path matches
     set f-path [ get f-meta path, default '' ]
     # normalize f-path (remove leading ./)
     get f-path, at startsWith, call './', true [
      set f-path [ get f-path, at slice, call 2 ]
     ]
     get f-path, at startsWith, call '/', true [
      set f-path [ get f-path, at slice, call 1 ]
     ]
     
     set target-dir [ get dir-path ]
     get target-dir, at startsWith, call './', true [ set target-dir [ get target-dir, at slice, call 2 ] ]
     get target-dir, at startsWith, call '/', true [ set target-dir [ get target-dir, at slice, call 1 ] ]

     get f-path, is [ get target-dir ], true [
      # Folder matches! Now look for item
      set items [ get f-meta items, default [ list ] ]
      get items, each [
       function item [
        get found-script-id value, false [
         get item type, is 'script', true [
          # Check script name
          set s-meta-file [ template '%0/sessions/%1/scripts/%2/metadata.json' [ get data-path ] [ get session-id ] [ get item id ] ]
          get file-exists, call [ get s-meta-file ], true [
           set s-meta [ get ij, call [ get s-meta-file ] ]
           set s-name [ get s-meta name ]
           
           # Matches if s-name == filename OR s-name + '.cr' == filename
           get s-name, is [ get filename ], true [
            set found-script-id value [ get item id ]
           ]
           get filename, is [ template '%0.cr' [ get s-name ] ], true [
            set found-script-id value [ get item id ]
           ]
          ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 get found-script-id value, true [
  set content-file [ template '%0/sessions/%1/scripts/%2/content.cr' [ get data-path ] [ get session-id ] [ get found-script-id value ] ]
  get file-exists, call [ get content-file ], true [
   set content [ get i, call [ get content-file ] ]
   get respond, call 200 [ get content ] 'text/plain'
  ], false [
   get respond, call 404 [ template 'Script content not found for %0' [ get filename ] ] 'text/plain'
  ]
 ], false [
  get respond, call 404 [ template 'File %0 not found in path %1' [ get filename ] [ get dir-path ] ] 'text/plain'
 ]
]
