# "Generate" tab for the Generate Content window

function session-service doc-window-api add-to-history refresh-history [
 set container [ global document createElement, call div ]
 get container classList add, call generate-content-tab-content

 set padding-container [
  global document createElement, call div
 ]
 set padding-container style padding '20px'
 get container appendChild, call [ get padding-container ]

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

 set result-header [
  global document createElement, call div
 ]
 set result-header style display flex
 set result-header style justify-content space-between
 set result-header style align-items center
 get result-section appendChild, call [ get result-header ]

 set result-label [
  global document createElement, call div
 ]
 get result-label classList add, call generate-content-label
 set result-label textContent 'Generated content'
 get result-header appendChild, call [ get result-label ]

 set view-mode-select [
  global document createElement, call select
 ]
 get view-mode-select classList add, call generate-content-select
 set view-modes [ list Source Preview ]
 get view-modes, each [
  function mode [
   set opt [ global document createElement, call option ]
   set opt value [ get mode ]
   set opt textContent [ get mode ]
   get view-mode-select appendChild, call [ get opt ]
  ]
 ]
 get result-header appendChild, call [ get view-mode-select ]

 set result-block [
  global document createElement, call div
 ]
 get result-block classList add, call generate-content-result
 get result-section appendChild, call [ get result-block ]

 set preview-block [
  global document createElement, call div
 ]
 get preview-block classList add, call generate-content-preview
 get result-section appendChild, call [ get preview-block ]

 set update-result-visibility [ function [
  set is-preview [ get view-mode-select value, is 'Preview' ]
  get is-preview, true [
   get result-block style display 'none'
   get preview-block style display 'block'
   get lib markdown, call [ get preview-block ] [ get result-block textContent ]
  ], false [
   get result-block style display 'block'
   get preview-block style display 'none'
  ]
 ] ]

 get view-mode-select addEventListener, call change [
  function [
   get update-result-visibility, call
  ]
 ]

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
    get update-result-visibility, call
    set result-section style display 'block'
    set insert-section style display 'none'
    value undefined
   ]
   set prompt [ get prompt-textarea value ]
   get prompt, false [
    set result-block textContent 'Enter a prompt first.'
    get update-result-visibility, call
    set result-section style display 'block'
    set insert-section style display 'none'
    value undefined
   ]
   set generate-btn disabled true
   set result-block textContent 'Generating...'
   get update-result-visibility, call
   set result-section style display 'block'
   set model [ get model-select value ]
   set url '/api/gemini-generate'
   set body [ object [ apiKey [ get api-key ], model [ get model ], prompt [ get prompt ] ] ]
   set fetch-opts [ object [ method 'POST', headers [ object [ Content-Type 'application/json' ] ], body [ global JSON stringify, call [ get body ] ] ] ]
   try [
    set response [ global fetch, call [ get url ] [ get fetch-opts ] ]
    set status [ get response status ]
    set response-data [ get response json, call ]

    get response ok, true [
     set candidates [ get response-data candidates, default [ list ] ]
     set first [ get candidates, at 0 ]

     get first, true [
      set parts [ get first content parts, default [ list ] ]
      set part0 [ get parts, at 0 ]
      get part0, true [
       set text [ get part0 text ]
       get text, true [
        set state generated-text [ get text ]
        get add-to-history, call [ get prompt ] [ get model ] [ get text ] [ get status ]
        get refresh-history, call
       ]
      ]
     ]

     get state generated-text, true [
      set out-text [ get state generated-text ]
      set result-block textContent [ get out-text ]
      get update-result-visibility, call
      get refresh-doc-list, call
      set insert-section style display 'block'
     ], false [
      set result-block textContent 'Error: No content generated in response'
      get update-result-visibility, call
      set insert-section style display 'none'
     ]
    ], false [
     set err [ get response-data error, default [ object ] ]
     set msg [ get err message, default 'Request failed' ]
     set result-block textContent [ template 'Error: %0' [ get msg ] ]
     get update-result-visibility, call
     set insert-section style display 'none'
    ]
    set generate-btn disabled false
   ] [
    set generate-btn disabled false
    set result-block textContent [ template 'Error: %0' [ current_error ] ]
    get update-result-visibility, call
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

 object [
  element [ get container ]
  prompt-textarea [ get prompt-textarea ]
 ]
]
