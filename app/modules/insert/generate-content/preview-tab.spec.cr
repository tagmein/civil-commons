# Tests for app/modules/insert/generate-content/preview-tab.cr

set create-preview-tab [ load ./app/modules/insert/generate-content/preview-tab.cr, point ]

set dom-harness [ load ./tests/dom-harness.cr, point ]

get dom-harness test, call 'Preview Tab Module' [
  # Mock dependencies
  set mock-tabs-add-called [ object [ value false ] ]
  set mock-tabs-remove-called [ object [ value false ] ]
  set mock-tabs-set-active-called [ object [ value false ] ]
  set mock-tabs [ object [
   add [ function name cb [
    set mock-tabs-add-called value true
    # Simulate a tab object
    object [ id name, element ( global document createElement, call div ) ]
   ] ],
   remove [ function tab [
    set mock-tabs-remove-called value true
   ] ],
   set-active [ function tab [
    set mock-tabs-set-active-called value true
   ] ]
  ] ]
  set mock-hist-tab-api [ object [ tab [ object [ id 'history-tab' ] ] ] ]

  set original-lib-markdown [ get lib markdown ]
  set lib markdown [ function el text [ set el innerHTML [ template '<p>%0</p>' [ get text ] ] ] ]

  set open-preview-tab [ get create-preview-tab, call [ get mock-tabs ] [ get mock-hist-tab-api ] ]

  get dom-harness test, call 'open-preview-tab creates and activates a new tab' [
    set item [ object [ id 1, prompt 'test', model 'm1', result '**markdown** result', date 100, status 200 ] ]
    get open-preview-tab, call [ get item ]

    get assert, call [ get mock-tabs-add-called value, is true ]
    get assert, call [ get mock-tabs-set-active-called value, is true ]
    # Further assertions would involve inspecting the DOM if the element were directly accessible
  ]

  get dom-harness test, call 'close button removes tab and activates history tab' [
    set item [ object [ id 2, prompt 'test2', model 'm2', result 'result2', date 200, status 200 ] ]
    get open-preview-tab, call [ get item ]
    
    # Simulate clicking the close button in the dynamically created preview tab
    set preview-tab-content [ global document querySelector, call '.generate-content-tab-content' ]
    get preview-tab-content, true [
     set close-btn [ get preview-tab-content querySelector, call '.generate-content-button' ]
     get close-btn, true [
      get close-btn click, call
      get assert, call [ get mock-tabs-remove-called value, is true ]
      get assert, call [ get mock-tabs-set-active-called value, is true ] # Should be called for history tab
     ]
    ]
  ]

  # Restore original globals
  set lib markdown [ get original-lib-markdown ]
]
