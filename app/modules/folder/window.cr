# Folder Window
get lib style-tag

tell '.folder-content' [
 object [
  display flex
  flex-direction column
  height '100%'
  padding 16px
  gap 12px
 ]
]

tell '.folder-label' [
 object [
  color '#a0a0a0'
  font-size 12px
  margin-bottom 4px
 ]
]

tell '.folder-input' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  outline none
  padding '6px 10px'
  width '100%'
  box-sizing border-box
 ]
]

tell '.folder-input:focus' [
 object [
  border-color '#4a9eff'
 ]
]

tell '.folder-items' [
 object [
  flex 1
  overflow-y auto
  border '1px solid #333337'
  border-radius 4px
  background-color '#1a1a1e'
  min-height 60px
 ]
]

tell '.folder-item' [
 object [
  align-items center
  border-bottom '1px solid #2a2a2e'
  color '#e0e0d0'
  display flex
  font-size 13px
  padding '8px 12px'
 ]
]

tell '.folder-item:last-child' [
 object [
  border-bottom none
 ]
]

tell '.folder-item-badge' [
 object [
  border-radius 3px
  font-size 10px
  margin-right 10px
  padding '2px 6px'
 ]
]

tell '.folder-item-badge-script' [
 object [
  background-color '#3a3a2a'
  color '#cccc88'
 ]
]

tell '.folder-item-badge-document' [
 object [
  background-color '#3a5a3a'
  color '#88cc88'
 ]
]

tell '.folder-item-badge-value' [
 object [
  background-color '#5a3a3a'
  color '#cc8888'
 ]
]

tell '.folder-item-badge-dictionary' [
 object [
  background-color '#5a3a5a'
  color '#ccaa88'
 ]
]

tell '.folder-item-badge-folder' [
 object [
  background-color '#3a4a5a'
  color '#88aacc'
 ]
]

tell '.folder-item-name' [
 object [
  flex 1
 ]
]

tell '.folder-item-remove' [
 object [
  background none
  border none
  color '#666'
  cursor pointer
  font-size 16px
  padding '0 4px'
 ]
]

tell '.folder-item-remove:hover' [
 object [
  color '#cc5555'
 ]
]

tell '.folder-empty' [
 object [
  color '#606060'
  font-size 13px
  padding 16px
  text-align center
 ]
]

tell '.folder-btn' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 13px
  padding '6px 14px'
  align-self flex-start
 ]
]

tell '.folder-btn:hover' [
 object [
  background-color '#444448'
 ]
]

set resolve-item-name [ function item [
 set item-type [ get item type ]
 set item-id [ get item id ]
 set name-ref [ object [ value [ get item-id ] ] ]
 try [
  get item-type, is script, true [
   set s [ get main script-service fetch-script, call [ get item-id ] ]
   get s name, true [ set name-ref value [ get s name ] ]
  ]
  get item-type, is document, true [
   set d [ get main document-service fetch-document, call [ get item-id ] ]
   get d name, true [ set name-ref value [ get d name ] ]
  ]
  get item-type, is value, true [
   set v [ get main value-service fetch-value, call [ get item-id ] ]
   get v name, true [ set name-ref value [ get v name ] ]
  ]
 ] [ ]
 get name-ref value
] ]

get conductor register, call folder:open [
 function arg [
  set folder-id [ get arg id, default [ get arg ] ]
  set folder-service [ get main folder-service ]
  
  set folder [ get folder-service fetch-folder, call [ get folder-id ] ]
  get folder, false [ value undefined ]

  set win [ get components window, call [ get folder name, default 'Untitled Folder' ] 400 350 ]

  set content [ global document createElement, call div ]
  get content classList add, call folder-content

  set path-label [ global document createElement, call div ]
  get path-label classList add, call folder-label
  set path-label textContent 'Import Path'
  get content appendChild, call [ get path-label ]

  set path-input [ global document createElement, call input ]
  get path-input classList add, call folder-input
  set path-input value [ get folder path, default '' ]
  set path-input placeholder 'e.g. lib'
  get content appendChild, call [ get path-input ]

  get path-input addEventListener, call blur [
   function [
    get folder-service save-folder, call [ get folder-id ] [ object [ path [ get path-input value ] ] ]
   ]
  ]

  set items-label [ global document createElement, call div ]
  get items-label classList add, call folder-label
  set items-label textContent 'Items'
  get content appendChild, call [ get items-label ]

  set items-list [ global document createElement, call div ]
  get items-list classList add, call folder-items
  get content appendChild, call [ get items-list ]

  set render-items [ function [
   set items-list innerHTML ''
   set current-items [ get folder items, default [ list ] ]
   get current-items length, = 0, true [
    set empty [ global document createElement, call div ]
    get empty classList add, call folder-empty
    set empty textContent 'No items yet'
    get items-list appendChild, call [ get empty ]
   ], false [
    get current-items, each [
     function item index [
      set row [ global document createElement, call div ]
      get row classList add, call folder-item

      set badge [ global document createElement, call span ]
      get badge classList add, call folder-item-badge
      get badge classList add, call [ template 'folder-item-badge-%0' [ get item type ] ]
      set badge textContent [ get item type ]
      get row appendChild, call [ get badge ]

      set name-el [ global document createElement, call span ]
      get name-el classList add, call folder-item-name
      set name-el textContent [ get resolve-item-name, call [ get item ] ]
      get row appendChild, call [ get name-el ]

      set remove-btn [ global document createElement, call button ]
      get remove-btn classList add, call folder-item-remove
      set remove-btn textContent '×'
      set remove-btn title 'Remove from folder'
      get remove-btn addEventListener, call click [
       function [
        set items [ get folder items, default [ list ] ]
        set new-items [ get items, filter [
         function it idx [
          get idx, = [ get index ], not
         ]
        ] ]
        set folder items [ get new-items ]
        get render-items, call
        get folder-service save-folder, call [ get folder-id ] [ object [ items [ get new-items ] ] ]
       ]
      ]
      get row appendChild, call [ get remove-btn ]

      get items-list appendChild, call [ get row ]
     ]
    ]
   ]
  ] ]
  get render-items, call

  set add-btn [ global document createElement, call button ]
  get add-btn classList add, call folder-btn
  set add-btn textContent '+ Add Item'
  get content appendChild, call [ get add-btn ]

  get add-btn addEventListener, call click [
   function [
    get conductor dispatch, call find:open [ object [
     target [ function selected [
      set items [ get folder items, default [ list ] ]
      get items push, call [ object [ type [ get selected type ], id [ get selected id ] ] ]
      set folder items [ get items ]
      get render-items, call
      get folder-service save-folder, call [ get folder-id ] [ object [ items [ get items ] ] ]
     ] ]
    ] ]
   ]
  ]

  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set win logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set win logEntryId [ get replay-ev id ]
   ]
  ]

  set session-service [ get main session-service ]
  set original-close [ get win close ]
  set win close [ function [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get win logEntryId, true [
     get session-service mark-event-skipped-on-replay, call [ get win logEntryId ]
    ], false [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'folder:open'
    ]
   ]
   get original-close, call
  ] ]
  get win logEntryId, true [
   set win onMinimize [ function w [ get session-service set-event-minimized, call [ get w logEntryId ] true ] ]
   set win onRestore [ function w [ get session-service set-event-minimized, call [ get w logEntryId ] false ] ]
  ]

  get main script-service on, call scriptRenamed [
   function data [ get render-items, call ]
  ]

  get main document-service on, call documentRenamed [
   function data [ get render-items, call ]
  ]

  get main value-service on, call valueRenamed [
   function data [ get render-items, call ]
  ]

  get folder-service on, call folderItemsChanged [
   function changed-id [
    get changed-id, is [ get folder-id ], true [
     set updated [ get folder-service fetch-folder, call [ get folder-id ] ]
     get updated, true [
      set folder items [ get updated items, default [ list ] ]
      get render-items, call
     ]
    ]
   ]
  ]

  get folder-service set-current-folder-id, call [ get folder-id ]
  get main set-last-interacted-element, call [ get win element ]
  
  get win fill, call [ get content ]
  get main stage place-window, call [ get win ] [ get main status ]

  get win element addEventListener, call mousedown [
   function [
    get folder-service set-current-folder-id, call [ get folder-id ]
    get main set-last-interacted-element, call [ get win element ]
   ]
  ]

  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get win minimize-window, tell
   ]
  ]
 ]
]

get conductor register, call '!folder:new' [
 function [
  set folder-service [ get main folder-service ]
  set folder [ get folder-service create-folder, call ]
  get folder, true [
   get conductor dispatch, call folder:open [ object [ id [ get folder id ], name [ get folder name, default 'Untitled Folder' ] ] ]
  ]
 ]
]

get conductor register, call 'folder:add-item' [
 function arg [
  set folder-service [ get main folder-service ]
  set item-type [ get arg type ]
  set item-id [ get arg id ]

  set folders [ get folder-service fetch-all-folders, call ]
  get folders length, = 0, true [
   set new-folder [ get folder-service create-folder, call ]
   get new-folder, true [
    set folders [ list [ get new-folder ] ]
   ]
  ]

  get folders length, > 0, true [
   get conductor dispatch, call find:open [ object [
    filterType folder
    target [ function selected [
     set target-folder-id [ get selected id ]
     set target-folder [ get folder-service fetch-folder, call [ get target-folder-id ] ]
     get target-folder, true [
      set items [ get target-folder items, default [ list ] ]
      get items push, call [ object [ type [ get item-type ], id [ get item-id ] ] ]
      get folder-service save-folder, call [ get target-folder-id ] [ object [ items [ get items ] ] ]
      get folder-service emit-items-changed, call [ get target-folder-id ]
     ]
    ] ]
   ] ]
  ]
 ]
]
