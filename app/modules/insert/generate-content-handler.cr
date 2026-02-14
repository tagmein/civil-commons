# Handler and Gemini API for Generate Content - loaded before generate-content.cr
# Defines handler and call-gemini so generate-content.cr can register with minimal brackets

set GEMINI_BASE 'https://generativelanguage.googleapis.com/v1beta'

set call-gemini [ function api-key model prompt [
 set url [ template '%0/models/%1:generateContent' [ get GEMINI_BASE ] [ get model ] ]
 set body [ object [
  contents [ list [ object [ parts [ list [ object [ text [ get prompt ] ] ] ] ] ]
 ] ]
 set opts [ object [
  method 'POST'
  headers [ object [
   Content-Type 'application/json'
   'x-goog-api-key' [ get api-key ]
  ] ]
  body [ global JSON stringify, call [ get body ] ]
 ] ]
 set response [ global fetch, call [ get url ] [ get opts ] ]
 set json [ get response json, call ]
 get response ok, true [
  set candidates [ get json candidates, default [ list ] ]
  get candidates length, > 0, true [
   set first [ get candidates, at 0 ]
   set content [ get first content, default [ object ] ]
   set parts [ get content parts, default [ list ] ]
   get parts length, > 0, true [
    set text-part [ get parts, at 0 ]
    set text [ get text-part text, default '' ]
    value [ object [ ok true, text [ get text ] ] ]
   ], false [
    value [ object [ ok false, error 'No response text' ] ]
   ]
  ], false [
   set err [ get json error, default [ object ] ]
   set msg [ get err message, default 'Unknown error' ]
   value [ object [ ok false, error [ get msg ] ] ]
  ]
 ], false [
  set err [ get json error, default [ object ] ]
  set msg [ get err message, default 'Request failed' ]
  value [ object [ ok false, error [ get msg ] ] ]
 ]
] ]

set handler [ function arg [
 do [
 set session-service [ get main session-service ]
 set doc-window-api [ get main document-window-api ]
 set gen-window [
  get components window, call 'Generate Content' 520 480
 ]

 set content [
  global document createElement, call div
 ]
 get content classList add, call generate-content-root
 set padding-container [
  global document createElement, call div
 ]
 set padding-container style padding '20px'
 get content appendChild, call [ get padding-container ]

 set prompt-label [
  global document createElement, call label
 ]
 get prompt-label classList add, call generate-content-label
 set prompt-label textContent 'Prompt'
 get padding-container appendChild, call [ get prompt-label ]

 set prompt-textarea [
  global document createElement, call textarea
 ]
 get prompt-textarea classList add, call generate-content-textarea
 set prompt-textarea placeholder 'Describe the content you want to generate...'
 get padding-container appendChild, call [ get prompt-textarea ]

 set model-label [
  global document createElement, call label
 ]
 get model-label classList add, call generate-content-label
 set model-label textContent 'Model'
 get padding-container appendChild, call [ get model-label ]

 set model-select [
  global document createElement, call select
 ]
 get model-select classList add, call generate-content-select
 set opt1 [ global document createElement, call option
 ]
 set opt1 value 'gemini-2.0-flash'
 set opt1 textContent 'Gemini 2.0 Flash'
 get model-select appendChild, call [ get opt1 ]
 get padding-container appendChild, call [ get model-select ]

 set generate-btn [
  global document createElement, call button
 ]
 get generate-btn classList add, call generate-content-button
 set generate-btn textContent 'Generate'
 get padding-container appendChild, call [ get generate-btn ]

 set result-section [
  global document createElement, call div
 ]
 get result-section classList add, call generate-content-section
 set result-label [
  global document createElement, call div
 ]
 get result-label classList add, call generate-content-label
 set result-label textContent 'Generated content'
 get result-section appendChild, call [ get result-label ]
 set result-block [
  global document createElement, call div
 ]
 get result-block classList add, call generate-content-result
 get result-section appendChild, call [ get result-block ]
 set result-section style display 'none'
 get padding-container appendChild, call [ get result-section ]

 set insert-section [
  global document createElement, call div
 ]
 get insert-section classList add, call generate-content-insert-section
 set insert-title [
  global document createElement, call div
 ]
 get insert-title classList add, call generate-content-label
 set insert-title textContent 'Insert into document'
 get insert-section appendChild, call [ get insert-title ]
 set doc-list [
  global document createElement, call div
 ]
 get doc-list classList add, call generate-content-doc-list
 get insert-section appendChild, call [ get doc-list ]
 set insert-btn [
  global document createElement, call button
 ]
 get insert-btn classList add, call generate-content-button
 get insert-btn textContent 'Insert'
 set insert-section style display 'none'
 get insert-section appendChild, call [ get insert-btn ]
 get padding-container appendChild, call [ get insert-section ]

 set state [ object [ generated-text '' ] ]

 set refresh-doc-list [ function [
  set doc-list innerHTML ''
  get doc-window-api, true [
  set open-docs [ get doc-window-api get-open-document-ids, call ]
  get open-docs length, = 0, true [
   set none-msg [ global document createElement, call div
   ]
   set none-msg textContent 'No documents open. Open a document first.'
   set none-msg style color '#808080'
   get doc-list appendChild, call [ get none-msg ]
  ], false [
   get open-docs, each [
    function doc [
     set wrap [ global document createElement, call label
     ]
     get wrap classList add, call generate-content-doc-option
     set radio [
      global document createElement, call input
     ]
     set radio type 'radio'
     set radio name 'generate-content-doc'
     set radio value [ get doc id ]
     get wrap appendChild, call [ get radio ]
     set name-el [ global document createElement, call span
     ]
     set name-el textContent [ get doc name ]
     get wrap appendChild, call [ get name-el ]
     get doc-list appendChild, call [ get wrap ]
    ]
   ]
  ]
  ], false [
   set none-msg [ global document createElement, call div ]
   set none-msg textContent 'No documents open. Open a document first.'
   set none-msg style color '#808080'
   get doc-list appendChild, call [ get none-msg ]
  ]
 ] ]

 get generate-btn addEventListener, call click [
  function [
   set api-key [ get session-service get-preference, call 'geminiApiKey' ]
   get api-key, false [
    set result-block textContent 'Error: Set your Gemini API key in Commons > Preferences > General.'
    set result-section style display 'block'
    set insert-section style display 'none'
    value undefined
   ]
   set prompt [ get prompt-textarea value ]
   get prompt, false [
    set result-block textContent 'Enter a prompt first.'
    set result-section style display 'block'
    set insert-section style display 'none'
    value undefined
   ]
   set generate-btn disabled true
   set result-block textContent 'Generating...'
   set result-section style display 'block'
   set model [ get model-select value ]
   set outcome [ get call-gemini, call [ get api-key ] [ get model ] [ get prompt ] ]
   set generate-btn disabled false
   get outcome ok, true [
    set text [ get outcome text ]
    set state generated-text [ get text ]
    set result-block textContent [ get text ]
    get refresh-doc-list, call
    set insert-section style display 'block'
   ], false [
    set result-block textContent [ template 'Error: %0' [ get outcome error ] ]
    set insert-section style display 'none'
   ]
  ]
 ]

 get insert-btn addEventListener, call click [
  function [
   set selected [ global document querySelector, call [ get content ] 'input[name="generate-content-doc"]:checked' ]
   get selected, false [
    value undefined
   ]
   set doc-id [ get selected value ]
   set text [ get state generated-text ]
   get doc-window-api, true [
   get text, true [
    get doc-window-api append-to-document, call [ object [ doc-id [ get doc-id ], text [ get text ] ] ]
   ]
   ]
  ]
 ]

 get gen-window fill, call [ get content ]
 get main stage place-window, call [
  get gen-window
 ] [ get main status ]
 ]
] ]
]
set main generate-content-handler-ref value [ get handler ]
