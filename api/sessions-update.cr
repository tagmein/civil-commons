# PATCH /api/sessions/:id - Update a session's metadata (name and/or archived)
# Expects io module variables to be available (data-path, ij, oj)
# Expects session-id and body to be set by serve.cr before calling

function request respond session-id body [
 # Try to read session metadata
 set metadata-file [ template '%0/sessions/%1/metadata.json' [ get data-path ] [ get session-id ] ]
 set found [ object [ value false ] ]
 set metadata null
 
 try [
  set metadata [ get ij, call [ get metadata-file ] ]
  set found value true
 ] [
  # File doesn't exist
 ]
 
 get found value, true [
  # Use reference object to avoid Crown scoping issues
  set updates [ object [
   name [ get metadata name ]
   archived [ get metadata archived, default false ]
   createdAt [ get metadata createdAt ]
  ] ]
  
  # Update name if provided in body
  get body name, true [
   set updates name [ get body name ]
  ]
  
  # Update archived if it's a boolean in body
  get body archived, typeof, is boolean, true [
   set updates archived [ get body archived ]
  ]
  
  # Save updated metadata
  get oj, call [ get metadata-file ] [ get updates ]
  
  # Respond with updated session
  get respond, call 200 [
   global JSON stringify, call [
    object [
     id [ get session-id ]
     name [ get updates name ]
     archived [ get updates archived ]
     createdAt [ get updates createdAt ]
    ]
   ]
  ] application/json
 ], false [
  get respond, call 404 [
   global JSON stringify, call [
    object [ error 'Session not found' ]
   ]
  ] application/json
 ]
]
