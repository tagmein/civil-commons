# GET /api/sessions - List all sessions with metadata
# Expects io module variables to be available (data-path, ij)

function request respond [
 # Load sessions list
 set sessions-file [ template '%0/sessions.json' [ get data-path ] ]
 set session-ids [ list ]
 
 # Try reading the file directly
 try [
  set session-ids [ get ij, call [ get sessions-file ] ]
 ] [
  # File doesn't exist or can't be read
 ]
 
 # Load metadata for each session
 set sessions [ list ]
 get session-ids, each [
  function id [
   set metadata-file [ template '%0/sessions/%1/metadata.json' [ get data-path ] [ get id ] ]
   try [
    set metadata [ get ij, call [ get metadata-file ] ]
    get sessions push, call [
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
 
 # Respond with sessions array
 get respond, call 200 [
  global JSON stringify, call [ get sessions ]
 ] application/json
]
