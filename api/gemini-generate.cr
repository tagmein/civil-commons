# POST /api/gemini-generate - Proxy to Gemini API
# Body: { apiKey, model, prompt }
# Expects read-body, parse-json-body, respond from scope (serve.cr)

function request respond [
 set body-text [ get read-body, call [ get request ] ]
 set parsed [ get parse-json-body, call [ get body-text ] ]
 set error [ get parsed error ]
 get error, true [
  get respond, call 400 [
   global JSON stringify, call [ object [ error [ get error ] ] ]
  ] application/json
 ], false [
  set data [ get parsed data ]
  set api-key [ get data apiKey ]
  set model [ get data model ]
  set prompt [ get data prompt ]
  
  get api-key, false [
   get respond, call 400 [
    global JSON stringify, call [ object [ error 'apiKey required' ] ]
   ] application/json
  ], true [
   set url [ template 'https://generativelanguage.googleapis.com/v1beta/models/%0:generateContent' [ get model ] ]
   set body-obj [ object [ contents [ list [ object [ parts [ list [ object [ text [ get prompt ] ] ] ] ] ] ] ] ]
   
   set opts [ object [
    method 'POST'
    headers [ object [
     Content-Type 'application/json'
     'x-goog-api-key' [ get api-key ]
    ] ]
    body [ global JSON stringify, call [ get body-obj ] ]
   ] ]
   
   set response [ global fetch, call [ get url ] [ get opts ] ]
   set json [ get response json, call ]
   set ok [ get response ok ]
   
   get ok, true [
    get respond, call 200 [
     global JSON stringify, call [ get json ]
    ] application/json
   ], false [
    get respond, call [ get response status ] [
     global JSON stringify, call [ get json ]
    ] application/json
   ]
  ]
 ]
]
