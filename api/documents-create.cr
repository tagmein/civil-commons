# POST /api/sessions/:sessionId/documents - Create a new document in a session
# Expects io module variables to be available (data-path, ij, oj, ensure-dir, generate-id)

function request respond session-id [
 # Generate unique document ID
 set doc-id [ get generate-id, call ]
 
 # Ensure directories exist
 get ensure-dir, call [ template '%0/sessions/%1/documents' [ get data-path ] [ get session-id ] ]
 get ensure-dir, call [ template '%0/sessions/%1/documents/%2' [ get data-path ] [ get session-id ] [ get doc-id ] ]
 
 # Create document metadata
 set metadata [
  object [
   name 'Untitled Document'
   archived false
   createdAt [ global Date now, call ]
  ]
 ]
 
 # Write document metadata
 get oj, call [
  template '%0/sessions/%1/documents/%2/metadata.json' [ get data-path ] [ get session-id ] [ get doc-id ]
 ] [ get metadata ]
 
 # Write empty content file
 get o, call [
  template '%0/sessions/%1/documents/%2/content.txt' [ get data-path ] [ get session-id ] [ get doc-id ]
 ] ''
 
 # Load or initialize documents list for this session
 set docs-file [ template '%0/sessions/%1/documents.json' [ get data-path ] [ get session-id ] ]
 set documents [ list ]
 try [
  set documents [ get ij, call [ get docs-file ] ]
 ] [
  # File doesn't exist yet
 ]
 
 # Add new document ID to list
 get documents push, call [ get doc-id ]
 get oj, call [ get docs-file ] [ get documents ]
 
 # Respond with the new document
 get respond, call 201 [
  global JSON stringify, call [
   object [
    id [ get doc-id ]
    name [ get metadata name ]
    archived [ get metadata archived ]
    createdAt [ get metadata createdAt ]
   ]
  ]
 ] application/json
]
