# Script Platform API
# Injected into script run scope as "platform". Use sessionId from scope when calling.
# Example: get platform listDocuments, call [ get sessionId ]


set main script-platform [ object [
 listSessions [ function [
  set url '/api/sessions'
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 listDocuments [ function session-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/documents' [ get session-id, default [ get sessionId ] ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 getDocument [ function session-id doc-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/documents/%1' [ get session-id, default [ get sessionId ] ] [ get doc-id ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 updateDocument [ function session-id doc-id body [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/documents/%1' [ get session-id, default [ get sessionId ] ] [ get doc-id ] ]
  set body-str [ global JSON stringify, call [ get body ] ]
  set resp [ global fetch, call [ get url ] [
   object [
    method 'PATCH',
    headers [ object [ Content-Type 'application/json' ] ],
    body [ get body-str ]
   ]
  ] ]
  get resp json, call
 ] ]
 listScripts [ function session-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/scripts' [ get session-id, default [ get sessionId ] ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 getScript [ function session-id script-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/scripts/%1' [ get session-id, default [ get sessionId ] ] [ get script-id ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 updateScript [ function session-id script-id body [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/scripts/%1' [ get session-id, default [ get sessionId ] ] [ get script-id ] ]
  set body-str [ global JSON stringify, call [ get body ] ]
  set resp [ global fetch, call [ get url ] [
   object [
    method 'PATCH',
    headers [ object [ Content-Type 'application/json' ] ],
    body [ get body-str ]
   ]
  ] ]
  get resp json, call
 ] ]
 listValues [ function session-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/values' [ get session-id, default [ get sessionId ] ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 getValue [ function session-id value-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/values/%1' [ get session-id, default [ get sessionId ] ] [ get value-id ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 updateValue [ function session-id value-id body [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/values/%1' [ get session-id, default [ get sessionId ] ] [ get value-id ] ]
  set body-str [ global JSON stringify, call [ get body ] ]
  set resp [ global fetch, call [ get url ] [
   object [
    method 'PATCH',
    headers [ object [ Content-Type 'application/json' ] ],
    body [ get body-str ]
   ]
  ] ]
  get resp json, call
 ] ]
 listDictionaries [ function session-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/dictionaries' [ get session-id, default [ get sessionId ] ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 getDictionary [ function session-id dict-id [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/dictionaries/%1' [ get session-id, default [ get sessionId ] ] [ get dict-id ] ]
  set resp [ global fetch, call [ get url ] ]
  get resp json, call
 ] ]
 updateDictionary [ function session-id dict-id body [
  set sessionId [ get main session-service get-current-session-id, call ]
  set url [ template '/api/sessions/%0/dictionaries/%1' [ get session-id, default [ get sessionId ] ] [ get dict-id ] ]
  set body-str [ global JSON stringify, call [ get body ] ]
  set resp [ global fetch, call [ get url ] [
   object [
    method 'PATCH',
    headers [ object [ Content-Type 'application/json' ] ],
    body [ get body-str ]
   ]
  ] ]
  get resp json, call
 ] ]
 getWindowCount [ function [
  get main stage get-window-count, call
 ] ]
] ]
