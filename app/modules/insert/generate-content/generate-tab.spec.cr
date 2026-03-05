# Tests for app/modules/insert/generate-content/generate-tab.cr

set create-generate-tab [ load ./app/modules/insert/generate-content/generate-tab.cr, point ]

set dom-harness [ load ./tests/dom-harness.cr, point ]

get dom-harness test, call 'Generate Tab Module' [
  # Mock dependencies
  set mock-session-service [ object [
   get-preference [ function key [
    get key, is 'geminiApiKey', true [ 'test-api-key' ]
   ] ]
  ] ]
  set mock-doc-window-api [ object [
   get-open-document-ids [ function [ list [ object [ id 'doc-1', name 'Document 1' ] ] ] ],
   append-to-document [ function opts [
    # Simulate appending to document
    get assert, call [ get opts doc-id, is 'doc-1' ]
    get assert, call [ get opts text, is 'generated text' ]
   ] ]
  ] ]
  set mock-add-to-history [ function prompt model result status [
   get assert, call [ get prompt, is 'test prompt' ]
   get assert, call [ get model, is 'gemini-2.0-flash' ]
   get assert, call [ get result, is 'generated text' ]
   get assert, call [ get status, is 200 ]
  ] ]
  set mock-refresh-history [ function [ ] ] # Placeholder
  set mock-gen-tab-api [ object [ set-active [ function [ ] ] ] ]
  
  # Mock global fetch for Gemini API call
  set original-fetch [ global fetch ]
  set mock-gemini-fetch [ function url opts [
   get url, is '/api/gemini-generate', true [
    value [ object [ ok true, status 200, json [ function [ 
     object [ candidates [ list [ object [ content [ object [ parts [ list [ object [ text 'generated text' ] ] ] ] ] ] ] ] ] ] ] ]
   ], false [
    value [ object [ ok false, status 404, json [ function [ object [ error 'Not Found' ] ] ] ] ]
   ]
  ] ]
  set global fetch [ get mock-gemini-fetch ]
  set original-lib-markdown [ get lib markdown ]
  set lib markdown [ function el text [ set el innerHTML [ template '<p>%0</p>' [ get text ] ] ] ]

  set generate-tab [ get create-generate-tab, call 
   [ get mock-session-service ]
   [ get mock-doc-window-api ]
   [ get mock-add-to-history ]
   [ get mock-refresh-history ]
  ]
  set generate-tab-element [ get generate-tab element ]

  get dom-harness test, call 'initial rendering' [
    get assert, call [ get generate-tab-element querySelector, call '.generate-content-textarea', get value, is '' ]
    get assert, call [ get generate-tab-element querySelector, call '.generate-content-button', get textContent, is 'Generate' ]
  ]

  get dom-harness test, call 'generate content successfully' [
    set prompt-textarea [ get generate-tab-element querySelector, call '.generate-content-textarea' ]
    set generate-btn [ get generate-tab-element querySelector, call '.generate-content-button' ]
    set result-block [ get generate-tab-element querySelector, call '.generate-content-result' ]
    set insert-section [ get generate-tab-element querySelector, call '.generate-content-insert-section' ]

    set prompt-textarea value 'test prompt'
    get generate-btn click, call

    get assert, call [ get result-block textContent, is 'generated text' ]
    get assert, call [ get insert-section style display, is 'block' ]
  ]

  get dom-harness test, call 'toggle view mode' [
    set prompt-textarea [ get generate-tab-element querySelector, call '.generate-content-textarea' ]
    set generate-btn [ get generate-tab-element querySelector, call '.generate-content-button' ]
    set result-block [ get generate-tab-element querySelector, call '.generate-content-result' ]
    set preview-block [ get generate-tab-element querySelector, call '.generate-content-preview' ]
    set view-mode-select [ get generate-tab-element querySelector, call '.generate-content-select' ]

    set prompt-textarea value 'test prompt'
    get generate-btn click, call # Generate first

    set view-mode-select value 'Preview'
    get view-mode-select dispatchEvent, call [ global Event, new 'change' ]

    get assert, call [ get result-block style display, is 'none' ]
    get assert, call [ get preview-block style display, is 'block' ]
    get assert, call [ get preview-block innerHTML, is '<p>generated text</p>' ]

    set view-mode-select value 'Source'
    get view-mode-select dispatchEvent, call [ global Event, new 'change' ]

    get assert, call [ get result-block style display, is 'block' ]
    get assert, call [ get preview-block style display, is 'none' ]
  ]

  get dom-harness test, call 'insert into document' [
    set prompt-textarea [ get generate-tab-element querySelector, call '.generate-content-textarea' ]
    set generate-btn [ get generate-tab-element querySelector, call '.generate-content-button' ]
    set insert-btn [ get generate-tab-element querySelector, call '.generate-content-button:last-of-type' ]
    set doc-radio [ get generate-tab-element querySelector, call 'input[name="generate-content-doc"]']

    set prompt-textarea value 'test prompt'
    get generate-btn click, call # Generate first
    get doc-radio checked true # Select document
    get insert-btn click, call

    # Assertions are within mock-doc-window-api.append-to-document
  ]

  # Restore original globals
  set global fetch [ get original-fetch ]
  set lib markdown [ get original-lib-markdown ]
]
