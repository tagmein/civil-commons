# PATCH /api/sessions/:sessionId/documents/:documentId - Update document metadata or content
# Expects io module variables to be available (data-path, ij, oj, o)
# Request body can contain: name, archived, content

function request respond session-id doc-id body [
 # Try to read existing document metadata
 set metadata-file [ template '%0/sessions/%1/documents/%2/metadata.json' [ get data-path ] [ get session-id ] [ get doc-id ] ]
 set content-file [ template '%0/sessions/%1/documents/%2/content.txt' [ get data-path ] [ get session-id ] [ get doc-id ] ]
 set found [ object [ value false ] ]
 
 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]
 
 get found value, true [
  # Update metadata fields if provided
  get body name, true [
   set metadata name [ get body name ]
  ]
  get body archived, true [
   set metadata archived [ get body archived ]
  ]
  
  # Save updated metadata
  get oj, call [ get metadata-file ] [ get metadata ]
  
  # Update content if provided
  get body content, true [
   get o, call [ get content-file ] [ get body content ]
  ]
  
  # Read current content for response
  set content-ref [ object [ content '' ] ]
  try [
   set content-ref content [ get i, call [ get content-file ] ]
  ] [
   # Content file doesn't exist
  ]
  
  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get doc-id ]
     name [ get metadata name ]
     archived [ get metadata archived ]
     createdAt [ get metadata createdAt ]
     content [ get content-ref content ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Document not found' ]
   ]
  ] application/json
 ]
]
