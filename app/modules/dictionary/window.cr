# Dictionary Window - Two-panel layout: term list (left) and term document (right)

get lib style-tag

tell '.dictionary-layout' [
 object [
  display flex
  flex-direction row
  height '100%'
  width '100%'
 ]
]

tell '.dictionary-term-list' [
 object [
  border-right '1px solid #444448'
  display flex
  flex-direction column
  min-width 200px
  width 250px
 ]
]

tell '.dictionary-term-list-header' [
 object [
  border-bottom '1px solid #444448'
  display flex
  flex-wrap wrap
  gap 8px
  padding 10px
 ]
]

tell '.dictionary-term-list-sort-btn' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 12px
  padding '6px 12px'
 ]
]

tell '.dictionary-term-list-sort-btn:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.dictionary-term-list-filter' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  flex 1
  font-size 13px
  min-width 80px
  padding '6px 10px'
 ]
]

tell '.dictionary-term-list-add-btn' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 12px
  padding '6px 12px'
 ]
]

tell '.dictionary-term-list-add-btn:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.dictionary-term-list-delete-btn' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 12px
  padding '6px 12px'
 ]
]

tell '.dictionary-term-list-delete-btn:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.dictionary-term-list-items' [
 object [
  flex-grow 1
  overflow-y auto
  padding 8px
 ]
]

tell '.dictionary-term-item' [
 object [
  cursor pointer
  padding '8px 12px'
  border-radius 4px
  margin-bottom 4px
 ]
]

tell '.dictionary-term-item:hover' [
 object [
  background-color '#333337'
 ]
]

tell '.dictionary-term-item.selected' [
 object [
  background-color '#3a5a3a'
  color '#88cc88'
 ]
]

tell '.dictionary-term-document' [
 object [
  display flex
  flex-direction column
  flex-grow 1
  overflow hidden
  padding 20px
  gap 20px
 ]
]

tell '.dictionary-picker-area' [
 object [
  background-color '#1a1a1e'
  border '1px solid #444448'
  border-radius 6px
  display flex
  flex-direction column
  gap 16px
  padding 16px
 ]
]

tell '.dictionary-picker-section' [
 object [
  display flex
  flex-direction column
  gap 8px
 ]
]

tell '.dictionary-picker-row' [
 object [
  display flex
  gap 10px
  align-items center
  flex-wrap wrap
 ]
]

tell '.dictionary-picker-label' [
 object [
  color '#a0a0a0'
  font-size 13px
  min-width 80px
 ]
]

tell '.dictionary-type-select' [
 object [
  appearance none
  -webkit-appearance none
  -moz-appearance none
  background-color '#1e1e22'
  background-image "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23a0a0a0' d='M2 4l4 4 4-4'/%3E%3C/svg%3E\")"
  background-repeat no-repeat
  background-position right 10px center
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 13px
  padding '8px 32px 8px 12px'
  outline none
  min-width 140px
 ]
]

tell '.dictionary-type-select:hover' [
 object [
  border-color '#55555a'
 ]
]

tell '.dictionary-type-select:focus' [
 object [
  border-color '#4a9eff'
 ]
]

tell '.dictionary-picker-btn' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 13px
  padding '8px 14px'
 ]
]

tell '.dictionary-picker-btn:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.dictionary-picker-btn-primary' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 13px
  padding '8px 14px'
 ]
]

tell '.dictionary-picker-btn-primary:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.dictionary-display-text' [
 object [
  color '#b0b0a0'
  font-family 'Consolas, Monaco, monospace'
  font-size 13px
  flex 1
 ]
]

tell '.dictionary-no-ref' [
 object [
  color '#606070'
  font-size 13px
  font-style italic
  padding '8px 0'
 ]
]

tell '.dictionary-value-editor-wrap' [
 object [
  margin-top 4px
 ]
]

tell '.dictionary-preview' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 6px
  color '#e0e0d0'
  flex-grow 1
  font-family 'Consolas, Monaco, monospace'
  font-size 13px
  line-height 1.5
  min-height 120px
  overflow auto
  padding 14px
 ]
]

tell '.dictionary-preview pre' [
 object [
  margin 0
  white-space pre-wrap
  word-break break-word
 ]
]

tell '.dictionary-preview-badge' [
 object [
  color '#808080'
  font-size 11px
  margin-bottom 6px
  text-transform uppercase
  letter-spacing 0.5px
 ]
]

set open-dictionaries [ object ]

set open-dictionary-window [ function dict-id [
 set dict-service [ get main dictionary-service ]
 set session-service [ get main session-service ]
 set doc-service [ get main document-service ]
 set val-service [ get main value-service ]

 set existing [ get main stage get-registered-window, call dictionary [ get dict-id ] ]
 get existing, true [
  get existing raise-window, tell
  get main stage place-window, call [ get existing ] [ get main status ]
  get main set-last-interacted-element, call [ get existing element ]
  get existing element classList add, call window-flash
  global setTimeout, call [
   function [
    get existing element classList remove, call window-flash
   ]
  ] 1000
  value undefined
 ]
 get existing, false [
 set dict [ get dict-service fetch-dictionary, call [ get dict-id ] ]
 get dict, false [
  log Dictionary not found: [ get dict-id ]
  value undefined
 ]

 set dict-window [ get components window, call [ get dict name, default 'Untitled Dictionary' ] 680 520 ]

 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [
   set dict-window logEntryId [ get log-entry id ]
  ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [
   set dict-window logEntryId [ get replay-ev id ]
  ]
 ]

 set entries-ref [ object [ data [ get dict entries, default [ object ] ] ] ]
 set selected-key-ref [ object [ key null ] ]
 set sort-asc-ref [ object [ value true ] ]
 set filter-text-ref [ object [ value '' ] ]

 set layout [ global document createElement, call div ]
 get layout classList add, call dictionary-layout

 set left-panel [ global document createElement, call div ]
 get left-panel classList add, call dictionary-term-list

 set list-header [ global document createElement, call div ]
 get list-header classList add, call dictionary-term-list-header

 set sort-btn [ global document createElement, call button ]
 get sort-btn classList add, call dictionary-term-list-sort-btn
 set sort-btn textContent 'A-Z'
 get sort-btn addEventListener, call click [
  function [
   set sort-asc-ref value [ get sort-asc-ref value, not ]
   set sort-btn textContent [ pick [ get sort-asc-ref value ] [ value 'A-Z' ], [ value true ] [ value 'Z-A' ] ]
   get render-term-list, call
  ]
 ]
 get list-header appendChild, call [ get sort-btn ]

 set filter-input [ global document createElement, call input ]
 get filter-input classList add, call dictionary-term-list-filter
 set filter-input placeholder 'Filter...'
 set filter-input value [ get filter-text-ref value ]
 get filter-input addEventListener, call input [
  function [
   set filter-text-ref value [ get filter-input value ]
   get render-term-list, call
  ]
 ]
 get list-header appendChild, call [ get filter-input ]

 set add-btn [ global document createElement, call button ]
 get add-btn classList add, call dictionary-term-list-add-btn
 set add-btn textContent 'Add term'
 get add-btn addEventListener, call click [
  function [
   set key [ global prompt, call 'Enter term key:' '' ]
   get key, true [
    get key length, > 0, true [
     set entries [ get entries-ref data ]
     set temp [ global Object assign, call [ object ] [ get entries ] ]
     set temp [ get key ] [ object [ type null, id null ] ]
     set entries-ref data [ get temp ]
     get dict-service update-dictionary, call [ get dict-id ] [ get temp ]
     set selected-key-ref key [ get key ]
     get render-term-list, call
     get render-term-document, call
    ]
   ]
  ]
 ]
 get list-header appendChild, call [ get add-btn ]

 set delete-btn [ global document createElement, call button ]
 get delete-btn classList add, call dictionary-term-list-delete-btn
 set delete-btn textContent 'Delete selected'
 get delete-btn addEventListener, call click [
  function [
   set key [ get selected-key-ref key ]
   get key, true [
    set entries [ get entries-ref data ]
    set keys [ global Object keys, call [ get entries ] ]
    set new-entries [ object ]
    get keys, each [
     function k [
      get k, is [ get key ], false [
       set new-entries [ get k ] [ get entries [ get k ] ]
      ]
     ]
    ]
    set entries-ref data [ get new-entries ]
    get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
    set selected-key-ref key null
    get render-term-list, call
    get render-term-document, call
   ]
  ]
 ]
 get list-header appendChild, call [ get delete-btn ]

 get left-panel appendChild, call [ get list-header ]

 set list-container [ global document createElement, call div ]
 get list-container classList add, call dictionary-term-list-items
 get left-panel appendChild, call [ get list-container ]

 get layout appendChild, call [ get left-panel ]

 set right-panel [ global document createElement, call div ]
 get right-panel classList add, call dictionary-term-document

 set picker-area [ global document createElement, call div ]
 get picker-area classList add, call dictionary-picker-area

 set preview-area [ global document createElement, call div ]
 get preview-area classList add, call dictionary-preview

 get right-panel appendChild, call [ get picker-area ]
 get right-panel appendChild, call [ get preview-area ]

 get layout appendChild, call [ get right-panel ]

 set render-term-list [ function [
  set list-container innerHTML ''
  set entries [ get entries-ref data ]
  set keys [ global Object keys, call [ get entries ] ]
  set filtered [ get keys, filter [
   function k [
    get filter-text-ref value length, = 0, true [
     value true
    ], false [
     get k, at toLowerCase, call, at includes, call [ get filter-text-ref value, at toLowerCase, call ]
    ]
   ]
  ] ]
  set sorted [ get filtered, at sort, call ]
  get sort-asc-ref value, false [
   get sorted, at reverse, call
  ]
  get sorted, each [
   function k [
    set item [ global document createElement, call div ]
    get item classList add, call dictionary-term-item
    get k, is [ get selected-key-ref key ], true [
     get item classList add, call selected
    ]
    set item textContent [ get k ]
    get item addEventListener, call click [
     function [
      set selected-key-ref key [ get k ]
      get render-term-list, call
      get render-term-document, call
     ]
    ]
    get list-container appendChild, call [ get item ]
   ]
  ]
 ] ]

 set render-term-document [ function [
  set picker-area innerHTML ''
  set preview-area innerHTML ''
  set key [ get selected-key-ref key ]
  get key, false [
   set preview-area textContent 'Select a term'
   value undefined
  ]

  set entries [ get entries-ref data ]
  set entry [ get entries [ get key ] ]
  get entry, false [
   set preview-area textContent 'No entry for this term'
   value undefined
  ]
  get entry, true [
  set type-row [ global document createElement, call div ]
  get type-row classList add, call dictionary-picker-row
  set type-label [ global document createElement, call span ]
  get type-label classList add, call dictionary-picker-label
  set type-label textContent 'Value type'
  get type-row appendChild, call [ get type-label ]

  set type-select [ global document createElement, call select ]
  get type-select classList add, call dictionary-type-select
  list dictionary document session value, each [
   function t [
    set opt [ global document createElement, call option ]
    set opt value [ get t ]
    set opt textContent [ get t ]
    get type-select appendChild, call [ get opt ]
   ]
  ]
  set type-select value [ get entry type, default value ]
  get type-select addEventListener, call change [
   function [
    set entry type [ get type-select value ]
    set entries [ get entries-ref data ]
    set entries [ get key ] [ get entry ]
    set entries-ref data [ get entries ]
    get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
    get render-term-document, call
   ]
  ]
  get type-row appendChild, call [ get type-select ]
  get picker-area appendChild, call [ get type-row ]

  set picker-row [ global document createElement, call div ]
  get picker-row classList add, call dictionary-picker-row

  set select-btn [ global document createElement, call button ]
  get select-btn classList add, call dictionary-picker-btn
  set select-btn textContent 'Select existing'
  get select-btn addEventListener, call click [
   function [
    set target [ function selected [
     set entry type [ get selected type ]
     set entry id [ get selected id ]
     set entries [ get entries-ref data ]
     set entries [ get key ] [ get entry ]
     set entries-ref data [ get entries ]
     get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
     get render-term-document, call
    ] ]
    get conductor dispatch, call find:open [ object [ filterType [ get type-select value ], target [ get target ] ] ]
   ]
  ]
  get picker-row appendChild, call [ get select-btn ]

  set create-btn [ global document createElement, call button ]
  get create-btn classList add, call dictionary-picker-btn
  set create-btn textContent 'Create new'
  get create-btn addEventListener, call click [
   function [
    set t [ get type-select value ]
    get t, is value, true [
     set val [ get val-service create-value, call ]
     get val, true [
      set entry type value
      set entry id [ get val id ]
      set entries [ get entries-ref data ]
      set entries [ get key ] [ get entry ]
      set entries-ref data [ get entries ]
      get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
      get render-term-document, call
     ]
    ]
    get t, is document, true [
     set doc [ get doc-service create-document, call ]
     get doc, true [
      set entry type document
      set entry id [ get doc id ]
      set entries [ get entries-ref data ]
      set entries [ get key ] [ get entry ]
      set entries-ref data [ get entries ]
      get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
      get render-term-document, call
     ]
    ]
    get t, is dictionary, true [
     set new-dict [ get dict-service create-dictionary, call ]
     get new-dict, true [
      set entry type dictionary
      set entry id [ get new-dict id ]
      set entries [ get entries-ref data ]
      set entries [ get key ] [ get entry ]
      set entries-ref data [ get entries ]
      get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
      get render-term-document, call
     ]
    ]
    get t, is session, true [
     set sess [ get session-service create-session, call ]
     get sess, true [
      set entry type session
      set entry id [ get sess id ]
      set entries [ get entries-ref data ]
      set entries [ get key ] [ get entry ]
      set entries-ref data [ get entries ]
      get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
      get render-term-document, call
     ]
    ]
   ]
  ]
  get picker-row appendChild, call [ get create-btn ]

  get picker-area appendChild, call [ get picker-row ]

  get entry id, true [
   set display-row [ global document createElement, call div ]
   get display-row classList add, call dictionary-picker-row
   set display-text [ global document createElement, call span ]
   get display-text classList add, call dictionary-display-text
   set display-text textContent [ template '%0 (%1)' [ get entry id ] [ get entry type ] ]
   get display-row appendChild, call [ get display-text ]

   set open-btn [ global document createElement, call button ]
   get open-btn classList add, call dictionary-picker-btn-primary
   set open-btn textContent 'Open'
   get open-btn addEventListener, call click [
    function [
     get entry type, is dictionary, true [
      get conductor dispatch, call dictionary:open [ object [ id [ get entry id ] ] ]
     ]
     get entry type, is document, true [
      get conductor dispatch, call document:open [ object [ id [ get entry id ] ] ]
     ]
     get entry type, is value, true [
      get conductor dispatch, call value:open [ object [ id [ get entry id ] ] ]
     ]
     get entry type, is session, true [
      set url [ template '%0%1#session=%2' [ global location origin ] [ global location pathname ] [ get entry id ] ]
      global window open, call [ get url ] '_blank'
     ]
    ]
   ]
   get display-row appendChild, call [ get open-btn ]

   set clear-btn [ global document createElement, call button ]
   get clear-btn classList add, call dictionary-picker-btn
   set clear-btn textContent 'Clear'
   get clear-btn addEventListener, call click [
    function [
     set entry id null
     set entry type null
     set entries [ get entries-ref data ]
     set entries [ get key ] [ get entry ]
     set entries-ref data [ get entries ]
     get dict-service update-dictionary, call [ get dict-id ] [ get entries ]
     get render-term-document, call
    ]
   ]
   get display-row appendChild, call [ get clear-btn ]
   get picker-area appendChild, call [ get display-row ]
  ], false [
   set no-ref [ global document createElement, call div ]
   get no-ref classList add, call dictionary-no-ref
   set no-ref textContent [ template 'No %0 selected' [ get type-select value ] ]
   get picker-area appendChild, call [ get no-ref ]
  ]

  get entry type, is value, true [
   get entry id, true [
    set usage [ get dict-service check-reference-usage, call value [ get entry id ] ]
    get usage length, > 1, true [
     set warn [ global document createElement, call div ]
     get warn classList add, call dictionary-preview-badge
     set warn style color '#ccaa44'
     set warn textContent [ template 'Warning: This value is used in %0 dictionaries. Edits affect all references.' [ get usage length ] ]
     get picker-area appendChild, call [ get warn ]
    ]
    set val [ get val-service fetch-value, call [ get entry id ] ]
    get val, true [
     set input-container [ global document createElement, call div ]
     get input-container classList add, call dictionary-value-editor-wrap
     set on-change [ function new-type new-value [
      get val-service update-value, call [ get entry id ] [ get new-type ] [ get new-value ]
     ] ]
     get build-input, call [ get input-container ] [ get val type, default string ] [ get val value ] [ get on-change ]
     get picker-area appendChild, call [ get input-container ]
    ]
   ]
  ]

  get entry type, is document, true [
   get entry id, true [
    set doc [ get doc-service fetch-document, call [ get entry id ] ]
    get doc, true [
     set badge [ global document createElement, call div ]
     get badge classList add, call dictionary-preview-badge
     set badge textContent 'Preview'
     get preview-area appendChild, call [ get badge ]
     set pre [ global document createElement, call pre ]
     set pre textContent [ get doc content, default '' ]
     get preview-area appendChild, call [ get pre ]
    ]
   ]
  ]
  ]
 ] ]

 get render-term-list, call
 get render-term-document, call

 get dict-service on, call change [
  function changed-id [
   get changed-id, is [ get dict-id ], true [
    set dict [ get dict-service fetch-dictionary, call [ get dict-id ] ]
    get dict, true [
     set entries-ref data [ get dict entries, default [ object ] ]
     get render-term-list, call
     get render-term-document, call
    ]
   ]
  ]
 ]

 set original-close [ get dict-window close ]
 set dict-window close [ function [
  get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
   get dict-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get dict-window logEntryId ]
   ]
  ], false [
   get session-service mark-event-skipped-on-replay, call 'dictionary:open'
  ]
  set open-dictionaries [ get dict-id ] null
  get main stage unregister-window, call dictionary [ get dict-id ]
  get original-close, call
 ] ]

 set open-dictionaries [ get dict-id ] [ get dict-window ]
 get main stage register-window, call dictionary [ get dict-id ] [ get dict-window ]

 get dict-service on, call dictionaryRenamed [
  function data [
   get data id, is [ get dict-id ], true [
    set dict-window title-text textContent [ get data name ]
   ]
  ]
 ]

 get dict-window fill, call [ get layout ]
 get main stage place-window, call [ get dict-window ] [ get main status ]

 set main last-interacted [ object [ type dictionary, id [ get dict-id ] ] ]
 get main set-last-interacted-element, call [ get dict-window element ]

 get dict-window element addEventListener, call mousedown [
  function [
   set main last-interacted [ object [ type dictionary, id [ get dict-id ] ] ]
   get main set-last-interacted-element, call [ get dict-window element ]
  ]
 ]
 ]
] ]

get conductor register, call dictionary:open [
 function arg [
  set dict-id [ get arg id, default [ get arg ] ]
  get open-dictionary-window, call [ get dict-id ]
 ]
]

get conductor register, call '!dictionary:new' [
 function [
  set dict-service [ get main dictionary-service ]
  set dict [ get dict-service create-dictionary, call ]
  get dict, true [
   get conductor dispatch, call dictionary:open [ object [ id [ get dict id ], name [ get dict name, default 'Untitled Dictionary' ] ] ]
  ]
 ]
]

# Load value-editor last so it doesn't change current value during tell blocks above
set build-input [ get lib value-editor build-input ]
