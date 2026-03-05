# History helpers for the Generate Content window

set history-api [ object [
 get-history-url [ function [
  set session-id [ get main session-service get-current-session-id, call ]
  template '/api/sessions/%0/ai/history' [ get session-id ]
 ] ],
 get-history [ function [
  try [
   set url [ get history-api get-history-url, call ]
   set response [ global fetch, call [ get url ] ]
   get response json, call
  ] [
   # Fallback to empty list
   list
  ]
 ] ],
 add-to-history [ function prompt model result status [
  set url [ get history-api get-history-url, call ]
  set body [ object [ prompt [ get prompt ], model [ get model ], result [ get result ], status [ get status ] ] ]
  set opts [ object [
   method 'POST'
   headers [ object [ Content-Type 'application/json' ] ]
   body [ global JSON stringify, call [ get body ] ]
  ] ]
  try [
   global fetch, call [ get url ] [ get opts ]
  ] [ ]
 ] ]
] ]
get history-api
