# POST /api/sessions - Create a new session
# Expects io module variables to be available (data-path, ij, oj, ensure-dir, generate-id)

function request respond [
 # Generate unique session ID
 set session-id [ get generate-id, call ]
 
 # Ensure data directories exist
 get ensure-dir, call [ get data-path ]
 get ensure-dir, call [ template '%0/sessions' [ get data-path ] ]
 get ensure-dir, call [ template '%0/sessions/%1' [ get data-path ] [ get session-id ] ]
 
 # Create session metadata
 set metadata [
  object [
   name 'Untitled'
   archived false
   createdAt [ global Date now, call ]
  ]
 ]
 
 # Write session metadata
 get oj, call [
  template '%0/sessions/%1/metadata.json' [ get data-path ] [ get session-id ]
 ] [ get metadata ]
 
 # Load or initialize sessions list
 set sessions-file [ template '%0/sessions.json' [ get data-path ] ]
 set sessions [ list ]
 try [
  set sessions [ get ij, call [ get sessions-file ] ]
 ] [
  # File doesn't exist yet
 ]
 
 # Add new session ID to list
 get sessions push, call [ get session-id ]
 get oj, call [ get sessions-file ] [ get sessions ]
 
 # Respond with the new session
 get respond, call 201 [
  global JSON stringify, call [
   object [
    id [ get session-id ]
    name [ get metadata name ]
    archived [ get metadata archived ]
    createdAt [ get metadata createdAt ]
   ]
  ]
 ] application/json
]
