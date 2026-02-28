# Recent Values Window

get lib style-tag

tell '.recent-values' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.recent-values .tab-bar' [
 object [
  background-color transparent
 ]
]

tell '.recent-val-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.recent-val-item' [
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

tell '.recent-val-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.recent-val-item-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.recent-val-item-type' [
 object [
  background-color '#444448'
  border-radius 3px
  color '#a0a0a0'
  font-size 11px
  margin-right 10px
  padding '2px 6px'
 ]
]

tell '.recent-val-item-date' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.recent-val-item-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.recent-val-item-open' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.recent-val-item-open:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.recent-val-item-archive' [
 object [
  background-color '#666668'
  color '#e0e0d0'
 ]
]

tell '.recent-val-item-archive:hover' [
 object [
  background-color '#777778'
 ]
]

tell '.recent-val-item-restore' [
 object [
  background-color '#44aa44'
  color '#ffffff'
 ]
]

tell '.recent-val-item-restore:hover' [
 object [
  background-color '#55bb55'
 ]
]

tell '.recent-val-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

get conductor register, call value:recent [
 function [
  set val-service [ get main value-service ]
  set session-service [ get main session-service ]

  set recent-window [
   get components window, call 'Recent Values' 400 450
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
  set original-close [ get recent-window close ]
  set recent-window close [ function [
   get recent-window logEntryId, true [
    get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
     get session-service mark-event-skipped-on-replay, call [ get recent-window logEntryId ]
    ]
   ], false [
    get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'value:recent'
    ]
   ]
   get original-close, call
  ] ]
  get recent-window logEntryId, true [
   set recent-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set recent-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  set all-values [ get val-service fetch-all-values, call ]

  set active-values [ list ]
  set archived-values [ list ]

  get all-values, each [
   function v [
    get v archived, true [
     get archived-values push, call [ get v ]
    ], false [
     get active-values push, call [ get v ]
    ]
   ]
  ]

  set container [ global document createElement, call div ]
  get container classList add, call recent-values

  set tabs [ get components tab-bar, call ]

  set active-tab [
   get tabs add, call [ template 'Active (%0)' [ get active-values length ] ] [
    function tab event [
     get render-list, call [ get active-values ] [ value false ]
    ]
   ]
  ]

  set archived-tab [
   get tabs add, call [ template 'Archived (%0)' [ get archived-values length ] ] [
    function tab event [
     get render-list, call [ get archived-values ] [ value true ]
    ]
   ]
  ]

  get tabs set-active, call [ get active-tab ]
  get container appendChild, call [ get tabs element ]

  set list-container [ global document createElement, call div ]
  get list-container classList add, call recent-val-list
  get container appendChild, call [ get list-container ]

  set format-date [ function timestamp [
   global Date, new [ get timestamp ]
   at toLocaleDateString, call
  ] ]

  set render-list [ function values show-archived [
   set list-container innerHTML ''

   get values length, = 0, true [
    set empty [ global document createElement, call div ]
    get empty classList add, call recent-val-empty
    set empty textContent [
     get show-archived, true [
      value 'No archived values'
     ], false [
      value 'No active values'
     ]
    ]
    get list-container appendChild, call [ get empty ]
   ], false [
    get values, each [
     function v [
      set item [ global document createElement, call div ]
      get item classList add, call recent-val-item

      set name [ global document createElement, call span ]
      get name classList add, call recent-val-item-name
      set name textContent [ get v name, default 'Untitled Value' ]
      get item appendChild, call [ get name ]

      set type-badge [ global document createElement, call span ]
      get type-badge classList add, call recent-val-item-type
      set type-badge textContent [ get v type, default 'string' ]
      get item appendChild, call [ get type-badge ]

      set date [ global document createElement, call span ]
      get date classList add, call recent-val-item-date
      set date textContent [ get format-date, call [ get v createdAt ] ]
      get item appendChild, call [ get date ]

      set open-btn [ global document createElement, call button ]
      get open-btn classList add, call recent-val-item-btn
      get open-btn classList add, call recent-val-item-open
      set open-btn textContent 'Open'
      get open-btn addEventListener, call click [
       function event [
        get event stopPropagation, call
        get show-archived, true [
         get val-service restore-value, call [ get v id ]
        ]
        get conductor dispatch, call value:open [ object [ id [ get v id ], name [ get v name, default 'Untitled Value' ] ] ]
        get recent-window close, call
       ]
      ]
      get item appendChild, call [ get open-btn ]

      get show-archived, false [
       set archive-btn [ global document createElement, call button ]
       get archive-btn classList add, call recent-val-item-btn
       get archive-btn classList add, call recent-val-item-archive
       set archive-btn textContent 'Archive'
       get archive-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         get val-service archive-value, call [ get v id ]
         set idx [ get active-values indexOf, call [ get v ] ]
         get idx, >= 0, true [
          get active-values splice, call [ get idx ] 1
         ]
         set v archived true
         get archived-values push, call [ get v ]
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-values length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-values length ] ]
         get render-list, call [ get active-values ] [ value false ]
        ]
       ]
       get item appendChild, call [ get archive-btn ]
      ]

      get show-archived, true [
       set restore-btn [ global document createElement, call button ]
       get restore-btn classList add, call recent-val-item-btn
       get restore-btn classList add, call recent-val-item-restore
       set restore-btn textContent 'Restore'
       get restore-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         get val-service restore-value, call [ get v id ]
         set idx [ get archived-values indexOf, call [ get v ] ]
         get idx, >= 0, true [
          get archived-values splice, call [ get idx ] 1
         ]
         set v archived false
         get active-values push, call [ get v ]
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-values length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-values length ] ]
         get render-list, call [ get archived-values ] [ value true ]
        ]
       ]
       get item appendChild, call [ get restore-btn ]
      ]

      get list-container appendChild, call [ get item ]
     ]
    ]
   ]
  ] ]

  get render-list, call [ get active-values ] [ value false ]

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
 ]
]
