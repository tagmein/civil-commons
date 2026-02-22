# GET /api/auth/google?sessionId=xxx - Returns auth URL for Google OAuth
# Expects data-path, ensure-dir. Uses GOOGLE_CLIENT_ID from env.
# Returns { authUrl } or { error } if not configured

function request respond [
 set client-id [ global process env GOOGLE_CLIENT_ID, default '' ]
 get client-id length, = 0, true [
  get respond, call 400 [
   global JSON stringify, call [ object [ error 'Google OAuth not configured. Set GOOGLE_CLIENT_ID.' ] ]
  ] application/json
 ], false [
  set url-obj [ global URL, new [ get request url ] [ template 'http://%0' [ get request headers host, default 'localhost:4567' ] ] ]
  set session-id [ get url-obj searchParams get, call sessionId ]
  get session-id, false [
   get respond, call 400 [
    global JSON stringify, call [ object [ error 'sessionId required' ] ]
   ] application/json
  ], true [
   set host [ get request headers host, default 'localhost:4567' ]
   set redirect-uri [ template 'http://%0/api/auth/google/callback' [ get host ] ]
   set redirect-encoded [ global encodeURIComponent, call [ get redirect-uri ] ]
   set scope 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
   set scope-encoded [ global encodeURIComponent, call [ get scope ] ]
   set auth-url [ template 'https://accounts.google.com/o/oauth2/v2/auth?client_id=%0&redirect_uri=%1&response_type=code&scope=%2&state=%3&access_type=offline&prompt=consent' [ get client-id ] [ get redirect-encoded ] [ get scope-encoded ] [ get session-id ] ]
   get respond, call 200 [
    global JSON stringify, call [ object [ authUrl [ get auth-url ] ] ]
   ] application/json
  ]
 ]
]