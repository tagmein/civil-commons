# GET /api/sessions/:sessionId/documents - List all documents in a session
# Expects io module variables to be available (data-path, ij)

function request respond session-id [
 # Load documents list for this session
 set docs-file [ template '%0/sessions/%1/documents.json' [ get data-path ] [ get session-id ] ]
 set doc-ids [ list ]
 
 # Try reading the file directly
 try [
  set doc-ids [ get ij, call [ get docs-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]
 
 # Load metadata for each document
 set documents [ list ]
 get doc-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/documents/%2/metadata.json' [ get data-path ] [ get session-id ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get documents push, call [
     object [
      id [ get id ]
      name [ get metadata name ]
      archived [ get metadata archived ]
      createdAt [ get metadata createdAt ]
     ]
    ]
   ] [
    # Metadata file doesn't exist
   ]
  ]
 ]
 
 # Respond with documents array
 get respond, call 200 [
  global JSON stringify, call [ get documents ]
 ] application/json
]
