# GET /api/auth/google/callback?code=xxx&state=sessionId - OAuth callback
# Exchanges code for tokens, fetches profile, creates gmail account, redirects to /
# Expects data-path, ensure-dir, ij, oj, generate-id. Uses GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET from env.

function request respond response [
 set client-id [ global process env GOOGLE_CLIENT_ID, default '' ]
 set client-secret [ global process env GOOGLE_CLIENT_SECRET, default '' ]
 get client-id length, = 0, true [
  get respond, call 400 [
   global JSON stringify, call [ object [ error 'Google OAuth not configured' ] ]
  ] application/json
 ], false [
  get client-secret length, = 0, true [
   get respond, call 400 [
    global JSON stringify, call [ object [ error 'Google OAuth not configured' ] ]
   ] application/json
  ], false [
   set url-obj [ global URL, new [ get request url ] [ template 'http://%0' [ get request headers host, default 'localhost:4567' ] ] ]
   set code [ get url-obj searchParams get, call code ]
   set session-id [ get url-obj searchParams get, call state ]
   get code, false [
    get respond, call 400 [
     global JSON stringify, call [ object [ error 'Missing authorization code' ] ]
    ] application/json
   ], true [
    get session-id, false [
     get respond, call 400 [
      global JSON stringify, call [ object [ error 'Missing state' ] ]
     ] application/json
    ], true [
     set host [ get request headers host, default 'localhost:4567' ]
     set redirect-uri [ template 'http://%0/api/auth/google/callback' [ get host ] ]
     set code-enc [ global encodeURIComponent, call [ get code ] ]
     set redirect-enc [ global encodeURIComponent, call [ get redirect-uri ] ]
     set token-body [ template 'code=%0&client_id=%1&client_secret=%2&redirect_uri=%3&grant_type=authorization_code' [ get code-enc ] [ get client-id ] [ get client-secret ] [ get redirect-enc ] ]
     set token-opts [ object [
      method 'POST'
      headers [ object [ 'Content-Type' 'application/x-www-form-urlencoded' ] ]
      body [ get token-body ]
     ] ]
     set token-resp [ global fetch, call 'https://oauth2.googleapis.com/token' [ get token-opts ] ]
     set token-json [ get token-resp json, call ]
     get token-resp ok, false [
      get respond, call 401 [
       global JSON stringify, call [ object [ error 'Token exchange failed' ] ]
      ] application/json
     ], true [
      set access-token [ get token-json access_token ]
      set profile-resp [ global fetch, call 'https://www.googleapis.com/oauth2/v2/userinfo' [
       object [ headers [ object [ Authorization [ template 'Bearer %0' [ get access-token ] ] ] ] ]
      ] ]
      set profile [ get profile-resp json, call ]
      get profile-resp ok, false [
       get respond, call 401 [
        global JSON stringify, call [ object [ error 'Failed to fetch profile' ] ]
       ] application/json
      ], true [
       set email [ get profile email, default '' ]
       get email length, = 0, true [
        get respond, call 400 [
         global JSON stringify, call [ object [ error 'No email in profile' ] ]
        ] application/json
       ], false [
        get ensure-dir, call [ template '%0/sessions/%1/mail' [ get data-path ] [ get session-id ] ]
        set file [ template '%0/sessions/%1/mail/accounts.json' [ get data-path ] [ get session-id ] ]
        set accounts [ list ]
        try [
         set accounts [ get ij, call [ get file ] ]
        ] [
        ]
        set new [ object [
         id [ get generate-id, call ]
         type 'gmail'
         email [ get email ]
         label ''
         host ''
         port 587
        ] ]
        get accounts push, call [ get new ]
        get oj, call [ get file ] [ get accounts ]
        get response setHeader, call Location '/'
        get respond, call 302 ''
       ]
      ]
     ]
    ]
   ]
  ]
 ]
]