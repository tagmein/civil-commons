# Tests for app/modules/insert/generate-content/history.cr

set test-history-module [ load ./app/modules/insert/generate-content/history.cr, point ]

set dom-harness [ load ./tests/dom-harness.cr, point ]

get dom-harness test, call 'History Module' [
  # Mock global fetch and main app-main / session-service
  set original-fetch [ global fetch ]
  set original-main [ get main ]
  set original-date-now [ get global Date now ]

  # Helper to mock fetch responses
  set mock-fetch [ function url opts [
   get url, pick [
    at endsWith, call '/api/sessions/session-123/ai/history'
    get opts, true [
     get opts method, is 'GET', true [
      # Simulate fetching existing history
      value [ object [ ok true, json [ function [ list [ 
       object [id 1, prompt 'old prompt', model 'm1', result 'old result', date 100, status 200] ] ] ] ] ]
     ], false [
      get opts method, is 'POST', true [
       # Simulate adding new history
       set body [ global JSON parse, call [ get opts body ] ]
       value [ object [ ok true, json [ function [ list [ 
        object [id 2, prompt [ get body prompt ], model [ get body model ], result [ get body result ], date 200, status [ get body status ] ],
        object [id 1, prompt 'old prompt', model 'm1', result 'old result', date 100, status 200]
       ] ] ] ] ]
      ], false [
       get opts method, is 'DELETE', true [
        # Simulate deleting history
        value [ object [ ok true, json [ function [ list [ 
         object [id 1, prompt 'old prompt', model 'm1', result 'old result', date 100, status 200]
        ] ] ] ] ]
       ], false [
        value [ object [ ok false, status 404, json [ function [ object [ error 'Not Found' ] ] ] ] ]
       ]
      ]
     ]
    ], false [
     value [ object [ ok false, status 404, json [ function [ object [ error 'Not Found' ] ] ] ] ]
    ]
   ]
  ] ]
  set global fetch [ get mock-fetch ]

  # Mock main app-main and session-service for get-current-session-id and get-preference
  set mock-session-service [ object [
   get-current-session-id [ function [ 'session-123' ] ],
   get-preference [ function key [
    get key, is 'geminiApiKey', true [ 'test-api-key' ]
   ] ]
  ] ]
  set mock-main [ object [ session-service [ get mock-session-service ] ] ]
  set main [ get mock-main ]

  # Mock global Date.now() for predictable IDs
  set global Date now [ function [ 123456789 ] ]

  get dom-harness test, call 'get-history-url returns correct URL' [
    set url [ get test-history-module get-history-url, call ]
    get assert, call [ get url, is '/api/sessions/session-123/ai/history' ]
  ]

  get dom-harness test, call 'get-history fetches and parses history' [
    set history [ get test-history-module get-history, call ]
    get assert, call [ get history length, is 1 ]
    get assert, call [ get history, at 0, get id, is 1 ]
    get assert, call [ get history, at 0, get prompt, is 'old prompt' ]
  ]

  get dom-harness test, call 'add-to-history sends POST request and updates history' [
    set prompt 'new prompt'
    set model 'gemini-pro'
    set result 'new result'
    set status 200

    get test-history-module add-to-history, call [ get prompt ] [ get model ] [ get result ] [ get status ]

    # Verify history is updated (mocked response reflects this)
    set updated-history [ get test-history-module get-history, call ]
    get assert, call [ get updated-history length, is 2 ]
    get assert, call [ get updated-history, at 0, get prompt, is 'new prompt' ]
    get assert, call [ get updated-history, at 0, get status, is 200 ]
  ]

  # Restore original globals
  set global fetch [ get original-fetch ]
  set main [ get original-main ]
  set global Date now [ get original-date-now ]
]
