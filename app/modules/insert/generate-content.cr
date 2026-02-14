# Generate Content - AI content generation via Gemini, insert into open documents
# Same pattern as commons/about.cr: single file, register one callback that opens the window
# Keep app-main ref so event handlers can reach Gemini fn without scope/current-value issues

set app-main [ get main ]

set app-main generate-content-gemini-base 'https://generativelanguage.googleapis.com/v1beta'

set app-main generate-content-call-gemini [ function api-key model prompt [
 set base [ get app-main generate-content-gemini-base ]
 set url [ template '%0/models/%1:generateContent' [ get base ] [ get model ] ]
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

get conductor register, call insert:generate-content [
 function [
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
  set insert-btn textContent 'Insert'
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
    set url '/api/gemini-generate'
    set body [ object [ apiKey [ get api-key ], model [ get model ], prompt [ get prompt ] ] ]
    set fetch-opts [ object [ method 'POST', headers [ object [ Content-Type 'application/json' ] ], body [ global JSON stringify, call [ get body ] ] ] ]
    try [
     set response [ global fetch, call [ get url ] [ get fetch-opts ] ]
     set response-data [ get response json, call ]
     set candidates [ get response-data candidates, default [ list ] ]
     set first [ get candidates, at 0 ]
     set parts [ get first content parts, default [ list ] ]
     set part0 [ get parts, at 0 ]
     set out-text [ get part0 text, default '' ]
     set outcome [ object [ ok false, error 'Request failed' ] ]
     get out-text, true [
      set outcome ok [ value true ]
      set outcome text [ get out-text ]
     ], false [
      get response ok, false [
       set err [ get response-data error, default [ object ] ]
       set msg [ get err message, default [ get err ] ]
       set outcome [ object [ ok false, error [ get msg, default 'Request failed' ] ] ]
      ]
     ]
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
    ] [
     set generate-btn disabled false
     set result-block textContent 'Error: Request failed'
     set result-section style display 'block'
     set insert-section style display 'none'
    ]
   ]
  ]

  get insert-btn addEventListener, call click [
   function [
    set selected [ get content querySelector, call 'input[name="generate-content-doc"]:checked' ]
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
 ]
]

get lib style-tag

tell '.generate-content-root' [
 object [
  display flex
  flex-direction column
  height '100%'
  gap 16px
 ]
]

tell '.generate-content-section' [
 object [
  margin-bottom 8px
 ]
]

tell '.generate-content-label' [
 object [
  display block
  color '#e0e0d0'
  font-size 14px
  margin '12px 0 6px 0'
 ]
]

tell '.generate-content-textarea' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding 10px
  width '100%'
  min-height 80px
  box-sizing border-box
  resize vertical
  font-family inherit
 ]
]

tell '.generate-content-select' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding '8px 10px'
  min-width 200px
 ]
]

tell '.generate-content-button' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color '#111114'
  cursor pointer
  font-size 14px
  font-weight bold
  padding '10px 20px'
 ]
]

tell '.generate-content-button:hover' [
 object [
  background-color '#6bb3ff'
 ]
]

tell '.generate-content-button:disabled' [
 object [
  background-color '#444448'
  color '#808080'
  cursor not-allowed
 ]
]

tell '.generate-content-result' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding 12px
  max-height 200px
  overflow auto
  white-space pre-wrap
  word-break break-word
 ]
]

tell '.generate-content-insert-section' [
 object [
  border-top '1px solid #444448'
  padding-top 16px
  margin-top 8px
 ]
]

tell '.generate-content-doc-list' [
 object [
  display flex
  flex-direction column
  gap 8px
  margin '8px 0 12px 0'
 ]
]

tell '.generate-content-doc-option' [
 object [
  display flex
  align-items center
  cursor pointer
  color '#e0e0d0'
  font-size 14px
 ]
]

tell '.generate-content-doc-option input' [
 object [
  margin-right 10px
  cursor pointer
 ]
]
