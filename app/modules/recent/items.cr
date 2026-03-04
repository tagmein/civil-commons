# Unified Recent Items Window
# Handles recent:all, recent:documents, recent:dictionaries, recent:sessions, recent:values, recent:scripts

get lib style-tag

tell '.recent-items' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.recent-items .tab-bar' [
 object [
  background-color transparent
 ]
]

tell '.recent-items-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.recent-items-item' [
 object [
  align-items center
  background-color '#333337'
  border-radius 4px
  cursor pointer
  display flex
  margin-bottom 8px
  padding '10px 15px'
 ]
]

tell '.recent-items-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.recent-items-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.recent-items-badge' [
 object [
  border-radius 3px
  font-size 11px
  margin-right 10px
  padding '2px 6px'
 ]
]

tell '.recent-items-badge-document' [
 object [
  background-color '#3a5a3a'
  color '#88cc88'
 ]
]

tell '.recent-items-badge-session' [
 object [
  background-color '#3a3a5a'
  color '#8888cc'
 ]
]

tell '.recent-items-badge-value' [
 object [
  background-color '#5a3a3a'
  color '#cc8888'
 ]
]

tell '.recent-items-badge-dictionary' [
 object [
  background-color '#5a3a5a'
  color '#cc88cc'
 ]
]

tell '.recent-items-badge-script' [
 object [
  background-color '#3a4a5a'
  color '#88aacc'
 ]
]

tell '.recent-items-date' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.recent-items-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.recent-items-open' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.recent-items-open:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.recent-items-archive' [
 object [
  background-color '#666668'
  color '#e0e0d0'
 ]
]

tell '.recent-items-archive:hover' [
 object [
  background-color '#777778'
 ]
]

tell '.recent-items-restore' [
 object [
  background-color '#44aa44'
  color '#ffffff'
 ]
]

tell '.recent-items-restore:hover' [
 object [
  background-color '#55bb55'
 ]
]

tell '.recent-items-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

set open-recent-window [ function filter-type [
 set session-service [ get main session-service ]
 set doc-service [ get main document-service ]
 set val-service [ get main value-service ]
 set dict-service [ get main dictionary-service ]
 set script-service [ get main script-service ]

 set title-ref [ object [ t 'Recent Items' ] ]
 get filter-type, is documents, true [ set title-ref t 'Recent Documents' ]
 get filter-type, is dictionaries, true [ set title-ref t 'Recent Dictionaries' ]
 get filter-type, is sessions, true [ set title-ref t 'Recent Sessions' ]
 get filter-type, is values, true [ set title-ref t 'Recent Values' ]
 get filter-type, is scripts, true [ set title-ref t 'Recent Scripts' ]

 set recent-window [
  get components window, call [ get title-ref t ] 450 500
 ]

 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [
   set recent-window logEntryId [ get log-entry id ]
  ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [
   set recent-window logEntryId [ get replay-ev id ]
  ]
 ]

 set action-name [ template 'recent:%0' [ get filter-type ] ]

 set original-close [ get recent-window close ]
 set recent-window close [ function [
  get recent-window logEntryId, true [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get session-service mark-event-skipped-on-replay, call [ get recent-window logEntryId ]
   ]
  ], false [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get session-service mark-last-event-with-action-skipped-on-replay, call [ get action-name ]
   ]
  ]
  get original-close, call
 ] ]
 get recent-window logEntryId, true [
  set recent-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
  set recent-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
 ]

 set active-items [ list ]
 set archived-items [ list ]

 set container [ global document createElement, call div ]
 get container classList add, call recent-items

 set tabs [ get components tab-bar, call ]

 set current-tab-state [ object [ archived false ] ]

 set active-tab [
  get tabs add, call [ template 'Active (%0)' [ get active-items length ] ] [
   function tab event [
    set current-tab-state archived false
    get render-list, call [ get active-items ] [ value false ]
   ]
  ]
 ]

 set archived-tab [
  get tabs add, call [ template 'Archived (%0)' [ get archived-items length ] ] [
   function tab event [
    set current-tab-state archived true
    get render-list, call [ get archived-items ] [ value true ]
   ]
  ]
 ]

 get tabs set-active, call [ get active-tab ]
 get container appendChild, call [ get tabs element ]

 set list-container [ global document createElement, call div ]
 get list-container classList add, call recent-items-list
 get container appendChild, call [ get list-container ]

 set format-date [ function timestamp [
  global Date, new [ get timestamp ]
  at toLocaleDateString, call
 ] ]

 set render-list [ function items show-archived [
  set list-container innerHTML ''

  get items length, = 0, true [
   set empty [ global document createElement, call div ]
   get empty classList add, call recent-items-empty
   set empty textContent 'No results'
   get list-container appendChild, call [ get empty ]
  ], false [
   get items, each [
    function item [
     set row [ global document createElement, call div ]
     get row classList add, call recent-items-item

     set name [ global document createElement, call span ]
     get name classList add, call recent-items-name
     set name textContent [ get item name ]
     get row appendChild, call [ get name ]

     set badge [ global document createElement, call span ]
     get badge classList add, call recent-items-badge
     get badge classList add, call [ template 'recent-items-badge-%0' [ get item kind ] ]
     set badge textContent [ get item kind ]
     get row appendChild, call [ get badge ]

     set date [ global document createElement, call span ]
     get date classList add, call recent-items-date
     set date textContent [ get format-date, call [ get item createdAt ] ]
     get row appendChild, call [ get date ]

     set open-btn [ global document createElement, call button ]
     get open-btn classList add, call recent-items-btn
     get open-btn classList add, call recent-items-open
     set open-btn textContent 'Open'
     get open-btn addEventListener, call click [
      function event [
       get event stopPropagation, call

       get show-archived, true [
        get item kind, is document, true [
         get doc-service restore-document, call [ get item id ]
        ]
        get item kind, is value, true [
         get val-service restore-value, call [ get item id ]
        ]
        get item kind, is dictionary, true [
         get dict-service restore-dictionary, call [ get item id ]
        ]
        get item kind, is session, true [
         global fetch, call [ template '/api/sessions/%0' [ get item id ] ] [
          object [
           method 'PATCH'
           headers [ object [ Content-Type 'application/json' ] ]
           body [ global JSON stringify, call [ object [ archived false ] ] ]
          ]
         ]
        ]
        get item kind, is script, true [
         get script-service restore-script, call [ get item id ]
        ]
       ]

       get item kind, is document, true [
        get conductor dispatch, call document:open [ object [ id [ get item id ], name [ get item name ] ] ]
       ]
       get item kind, is session, true [
        get session-service open-session, call [ get item id ]
       ]
       get item kind, is value, true [
        get conductor dispatch, call value:open [ object [ id [ get item id ], name [ get item name ] ] ]
       ]
       get item kind, is dictionary, true [
        get conductor dispatch, call dictionary:open [ object [ id [ get item id ], name [ get item name ] ] ]
       ]
       get item kind, is script, true [
        get conductor dispatch, call script:open [ object [ id [ get item id ], name [ get item name ] ] ]
       ]
      ]
     ]
     get row appendChild, call [ get open-btn ]

     get item kind, is script, true [
      set run-script-id [ get item id ]
      set run-btn [ global document createElement, call button ]
      get run-btn classList add, call recent-items-btn
      get run-btn classList add, call recent-items-open
      set run-btn textContent 'Run'
      get run-btn addEventListener, call click [
       function event [
        get event stopPropagation, call
        get conductor dispatch, call 'script:run' [ get run-script-id ]
       ]
      ]
      get row appendChild, call [ get run-btn ]
     ]

     get show-archived, false [
      set archive-btn [ global document createElement, call button ]
      get archive-btn classList add, call recent-items-btn
      get archive-btn classList add, call recent-items-archive
      set archive-btn textContent 'Archive'
      get archive-btn addEventListener, call click [
       function event [
        get event stopPropagation, call

        get item kind, is document, true [
         get doc-service archive-document, call [ get item id ]
        ]
        get item kind, is session, true [
         get session-service archive-session, call [ get item id ]
        ]
        get item kind, is value, true [
         get val-service archive-value, call [ get item id ]
        ]
        get item kind, is dictionary, true [
         get dict-service archive-dictionary, call [ get item id ]
        ]
        get item kind, is script, true [
         get script-service archive-script, call [ get item id ]
        ]

        set idx [ get active-items indexOf, call [ get item ] ]
        get idx, >= 0, true [
         get active-items splice, call [ get idx ] 1
        ]
        set item archived true
        get archived-items push, call [ get item ]

        get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-items length ] ]
        get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-items length ] ]
        get render-list, call [ get active-items ] [ value false ]
       ]
      ]
      get row appendChild, call [ get archive-btn ]
     ]

     get show-archived, true [
      set restore-btn [ global document createElement, call button ]
      get restore-btn classList add, call recent-items-btn
      get restore-btn classList add, call recent-items-restore
      set restore-btn textContent 'Restore'
      get restore-btn addEventListener, call click [
       function event [
        get event stopPropagation, call

        get item kind, is document, true [
         get doc-service restore-document, call [ get item id ]
        ]
        get item kind, is session, true [
         global fetch, call [ template '/api/sessions/%0' [ get item id ] ] [
          object [
           method 'PATCH'
           headers [ object [ Content-Type 'application/json' ] ]
           body [ global JSON stringify, call [ object [ archived false ] ] ]
          ]
         ]
        ]
        get item kind, is value, true [
         get val-service restore-value, call [ get item id ]
        ]
        get item kind, is dictionary, true [
         get dict-service restore-dictionary, call [ get item id ]
        ]
        get item kind, is script, true [
         get script-service restore-script, call [ get item id ]
        ]

        set idx [ get archived-items indexOf, call [ get item ] ]
        get idx, >= 0, true [
         get archived-items splice, call [ get idx ] 1
        ]
        set item archived false
        get active-items push, call [ get item ]

        get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-items length ] ]
        get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-items length ] ]
        get render-list, call [ get archived-items ] [ value true ]
       ]
      ]
      get row appendChild, call [ get restore-btn ]
     ]

     get list-container appendChild, call [ get row ]
    ]
   ]
  ]
 ] ]


 set refresh-data [ function [
 # Collect all items with their type tag
 set all-items [ list ]

 # Fetch documents (unless filtered to sessions, values, scripts or dictionaries only)
 get filter-type, is sessions, false [
  get filter-type, is values, false [
   get filter-type, is scripts, false [
    get filter-type, is dictionaries, false [
     set docs [ get doc-service fetch-all-documents, call ]
     get docs, each [
      function doc [
       get all-items push, call [
        object [
         id [ get doc id ]
         name [ get doc name, default 'Untitled Document' ]
         kind document
         archived [ get doc archived ]
         createdAt [ get doc createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 # Fetch sessions (unless filtered to documents, values, scripts or dictionaries only)
 get filter-type, is documents, false [
  get filter-type, is values, false [
   get filter-type, is scripts, false [
    get filter-type, is dictionaries, false [
     set sessions [ get session-service fetch-all-sessions, call ]
     get sessions, each [
      function s [
       get all-items push, call [
        object [
         id [ get s id ]
         name [ get s name, default 'Untitled' ]
         kind session
         archived [ get s archived ]
         createdAt [ get s createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 # Fetch values (unless filtered to documents, sessions, scripts or dictionaries only)
 get filter-type, is documents, false [
  get filter-type, is sessions, false [
   get filter-type, is scripts, false [
    get filter-type, is dictionaries, false [
     set vals [ get val-service fetch-all-values, call ]
     get vals, each [
      function v [
       get all-items push, call [
        object [
         id [ get v id ]
         name [ get v name, default 'Untitled Value' ]
         kind value
         archived [ get v archived ]
         createdAt [ get v createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 # Fetch dictionaries (unless filtered to documents, sessions, values or scripts only)
 get filter-type, is documents, false [
  get filter-type, is sessions, false [
   get filter-type, is values, false [
    get filter-type, is scripts, false [
     set dicts [ get dict-service fetch-all-dictionaries, call ]
     get dicts, each [
      function d [
       get all-items push, call [
        object [
         id [ get d id ]
         name [ get d name, default 'Untitled Dictionary' ]
         kind dictionary
         archived [ get d archived ]
         createdAt [ get d createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
  ]
 ]

 # Fetch scripts (when filter is scripts or all)
 get filter-type, is scripts, true [
  set script-list [ get script-service fetch-all-scripts, call ]
  get script-list, each [
   function s [
    get all-items push, call [
     object [
      id [ get s id ]
      name [ get s name, default 'Untitled Script' ]
      kind script
      archived [ get s archived, default false ]
      createdAt [ get s createdAt, default 0 ]
     ]
    ]
   ]
  ]
 ], false [
  get filter-type, is all, true [
   set script-list [ get script-service fetch-all-scripts, call ]
   get script-list, each [
    function s [
     get all-items push, call [
      object [
       id [ get s id ]
       name [ get s name, default 'Untitled Script' ]
       kind script
       archived [ get s archived, default false ]
       createdAt [ get s createdAt, default 0 ]
      ]
    ]
   ]
  ]
 ]
 ]

 get active-items splice, call 0 [ get active-items length ]
 get archived-items splice, call 0 [ get archived-items length ]

 get all-items, each [
  function item [
   get item archived, true [
    get archived-items push, call [ get item ]
   ], false [
    get active-items push, call [ get item ]
   ]
  ]
 ]

  get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-items length ] ]
  get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-items length ] ]

  get current-tab-state archived, true [
   get render-list, call [ get archived-items ] [ value true ]
  ], false [
   get render-list, call [ get active-items ] [ value false ]
  ]
 ] ]

 get refresh-data, call

 global window addEventListener, call 'recent-refresh' [ get refresh-data ]
 set final-close [ get recent-window close ]
 set recent-window close [ function [
  global window removeEventListener, call 'recent-refresh' [ get refresh-data ]
  get final-close, call
 ] ]

 get recent-window fill, call [ get container ]
 get main stage place-window, call [
  get recent-window
 ] [ get main status ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev minimized, true [
   get recent-window minimize-window, tell
  ]
 ]
] ]

get conductor register, call recent:all [
 function [
  get open-recent-window, call [ value 'all' ]
 ]
]

get conductor register, call recent:documents [
 function [
  get open-recent-window, call [ value 'documents' ]
 ]
]

get conductor register, call recent:dictionaries [
 function [
  get open-recent-window, call [ value 'dictionaries' ]
 ]
]

get conductor register, call recent:sessions [
 function [
  get open-recent-window, call [ value 'sessions' ]
 ]
]

get conductor register, call recent:values [
 function [
  get open-recent-window, call [ value 'values' ]
 ]
]

get conductor register, call recent:scripts [
 function [
  get open-recent-window, call [ value 'scripts' ]
 ]
]
