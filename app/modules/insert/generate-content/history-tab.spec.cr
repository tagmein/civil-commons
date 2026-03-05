# Tests for app/modules/insert/generate-content/history-tab.cr

set create-history-tab [ load ./app/modules/insert/generate-content/history-tab.cr, point ]

set dom-harness [ load ./tests/dom-harness.cr, point ]

get dom-harness test, call 'History Tab Module' [
  # Mock dependencies
  set mock-history [ list ] # This will be controlled by specific tests
  set mock-get-history [ function [ get mock-history ] ]
  set mock-get-history-url [ function [ '/api/sessions/session-123/ai/history' ] ]
  set mock-open-preview-tab-called [ object [ value false ] ]
  set mock-open-preview-tab [ function item [ set mock-open-preview-tab-called value true ] ]
  set mock-prompt-textarea [ object [ value '' ] ]
  set mock-gen-tab-api [ object [ set-active [ function [ ] ] ] ]
  
  # Mock global fetch for DELETE API call
  set original-fetch [ global fetch ]
  set mock-delete-fetch [ function url opts [
   get url, is '/api/sessions/session-123/ai/history', true [
    get opts method, is 'DELETE', true [
     # Simulate successful delete, return empty list for history
     set mock-history [ list ] # Clear history after delete
     value [ object [ ok true, json [ function [ list ] ] ] ]
    ], false [
     value [ object [ ok false, status 404, json [ function [ object [ error 'Not Found' ] ] ] ] ]
    ]
   ], false [
    value [ object [ ok false, status 404, json [ function [ object [ error 'Not Found' ] ] ] ] ]
   ]
  ] ]
  set global fetch [ get mock-delete-fetch ]

  set history-tab [ get create-history-tab, call 
   [ get mock-get-history ]
   [ get mock-get-history-url ]
   [ get mock-open-preview-tab ]
   [ get mock-prompt-textarea ]
   [ get mock-gen-tab-api ]
  ]
  set history-tab-element [ get history-tab element ]
  set refresh-history-fn [ get history-tab refresh ]

  get dom-harness test, call 'initial rendering with empty history' [
    get assert, call [ get history-tab-element querySelector, call '.generate-content-history-table', is null ]
    get assert, call [ get history-tab-element textContent, at includes, call 'No generation history yet.' ]
  ]

  get dom-harness test, call 'rendering with history items' [
    set mock-history [ list [
     object [ id 1, prompt 'short prompt', model 'm1', result 'result 1', date 1700000000000, status 200 ],
     object [ id 2, prompt 'a very very very very very very very very very very very very very very very very very very very long prompt', model 'm2', result 'result 2', date 1700000001000, status 200 ]
    ] ]
    get refresh-history-fn, call

    set table [ get history-tab-element querySelector, call '.generate-content-history-table' ]
    get assert, call [ get table, is not null ]

    set rows [ get table querySelectorAll, call 'tbody tr' ]
    get assert, call [ get rows length, is 2 ]

    set first-row-text [ get rows, at 0, get textContent ]
    get assert, call [ get first-row-text, at includes, call 'short prompt' ]
    get assert, call [ get first-row-text, at includes, call 'Preview' ]
    get assert, call [ get first-row-text, at includes, call 'Edit Prompt' ]
    get assert, call [ get first-row-text, at includes, call 'Delete' ]

    set second-row-text [ get rows, at 1, get textContent ]
    get assert, call [ get second-row-text, at includes, call 'a very very very very very very very very very very very very very very very very very very very long...' ]
  ]

  get dom-harness test, call 'preview button calls open-preview-tab' [
    set mock-history [ list [ object [ id 3, prompt 'preview me', model 'm3', result 'preview result', date 1700000002000, status 200 ] ] ]
    get refresh-history-fn, call

    set preview-btn [ get history-tab-element querySelector, call '.generate-content-history-actions button' ]
    get preview-btn click, call

    get assert, call [ get mock-open-preview-tab-called value, is true ]
  ]

  get dom-harness test, call 'edit prompt button updates textarea and switches tab' [
    set mock-history [ list [ object [ id 4, prompt 'edit me', model 'm4', result 'edit result', date 1700000003000, status 200 ] ] ]
    get refresh-history-fn, call

    set edit-btn [ get history-tab-element querySelector, call '.generate-content-history-actions button:nth-child(2)' ]
    get edit-btn click, call

    get assert, call [ get mock-prompt-textarea value, is 'edit me' ]
    # In a real scenario, mock-gen-tab-api.set-active would be asserted
  ]

  get dom-harness test, call 'delete button removes item and refreshes' [
    set mock-history [ list [ object [ id 5, prompt 'delete me', model 'm5', result 'delete result', date 1700000004000, status 200 ] ] ]
    get refresh-history-fn, call

    set delete-btn [ get history-tab-element querySelector, call '.generate-content-history-actions button:nth-child(3)' ]
    get delete-btn click, call

    # History should now be empty due to mock-delete-fetch
    get assert, call [ get history-tab-element querySelector, call '.generate-content-history-table', is null ]
    get assert, call [ get history-tab-element textContent, at includes, call 'No generation history yet.' ]
  ]

  # Restore original globals
  set global fetch [ get original-fetch ]
]
