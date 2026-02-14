# POST /api/gemini-generate - Proxy to Gemini API (avoids CORS from browser)
# Body: { apiKey, model, prompt }
# Expects read-body, parse-json-body, respond from scope (serve.cr)

function request respond [
 set body-text [ get read-body, call [ get request ] ]
 set parsed [ get parse-json-body, call [ get body-text ] ]
 get parsed error, true [
  get respond, call 400 [
   global JSON stringify, call [ object [ error [ get parsed error ] ] ]
  ] application/json
 ], false [
  set api-key [ get parsed data apiKey ]
  set model [ get parsed data model ]
  set prompt [ get parsed data prompt ]
  get api-key, false [
   get respond, call 400 [
    global JSON stringify, call [ object [ error 'apiKey required' ] ]
   ] application/json
  ], true [
  set url [ template 'https://generativelanguage.googleapis.com/v1beta/models/%0:generateContent' [ get model ] ]
  set open-b [ global String fromCharCode, call 91 ]
  set close-b [ global String fromCharCode, call 93 ]
  set prompt-json [ global JSON stringify, call [ get prompt ] ]
  set body-inner [ template '%0%1%2%3%4%5%6%7%8%9' [ value '{"contents":' ] [ get open-b ] [ value '{"parts":' ] [ get open-b ] [ value '{"text":' ] [ get prompt-json ] [ value '}' ] [ get close-b ] [ value '}' ] [ get close-b ] [ value '}' ] ]
  set body-json [ template '%0%1' [ get body-inner ] [ value '}' ] ]
  set opts [ object [
   method 'POST'
   headers [ object [
    Content-Type 'application/json'
    'x-goog-api-key' [ get api-key ]
   ] ]
   body [ get body-json ]
  ] ]
  set response [ global fetch, call [ get url ] [ get opts ] ]
  set json [ get response json, call ]
  get response ok, true [
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
