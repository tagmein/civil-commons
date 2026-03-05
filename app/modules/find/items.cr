# Find Items Window - Singleton for picking items (Dictionary, Document, Session, Value)
# Used by Dictionary window when "Select existing" is clicked

get lib style-tag

set find-window-ref [ object [ window null, target null, filter-type all, render-list null ] ]

tell '.find-items' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.find-items-header' [
 object [
  border-bottom '1px solid #444448'
  display flex
  flex-wrap wrap
  gap 8px
  padding 10px
 ]
]

tell '.find-items-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.find-items-item' [
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

tell '.find-items-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.find-items-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.find-items-badge' [
 object [
  border-radius 3px
  font-size 11px
  margin-right 10px
  padding '2px 6px'
 ]
]

tell '.find-items-badge-document' [
 object [
  background-color '#3a5a3a'
  color '#88cc88'
 ]
]

tell '.find-items-badge-session' [
 object [
  background-color '#3a3a5a'
  color '#8888cc'
 ]
]

tell '.find-items-badge-value' [
 object [
  background-color '#5a3a3a'
  color '#cc8888'
 ]
]

tell '.find-items-badge-dictionary' [
 object [
  background-color '#5a3a5a'
  color '#ccaa88'
 ]
]

tell '.find-items-badge-script' [
 object [
  background-color '#3a3a2a'
  color '#cccc88'
 ]
]

tell '.find-items-badge-folder' [
 object [
  background-color '#3a4a5a'
  color '#88aacc'
 ]
]

tell '.find-items-date' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.find-items-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.find-items-select' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.find-items-select:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.find-items-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

set ensure-find-window [ function [
 get find-window-ref window, true [
  value undefined
 ]

 set session-service [ get main session-service ]
 set doc-service [ get main document-service ]
 set val-service [ get main value-service ]
 set dict-service [ get main dictionary-service ]
 set folder-service [ get main folder-service ]
 set script-service [ get main script-service ]

 set find-window [ get components window, call 'Find Items' 450 500 ]
 set find-window-ref window [ get find-window ]

 set list-container [ global document createElement, call div ]
 get list-container classList add, call find-items-list

 set filter-select [ global document createElement, call select ]
 set filter-select value [ get find-window-ref filter-type ]
 list all dictionary document folder script session value, each [
  function t [
   set opt [ global document createElement, call option ]
   set opt value [ get t ]
   set opt textContent [ get t ]
   get filter-select appendChild, call [ get opt ]
  ]
 ]

 set search-input [ global document createElement, call input ]
 set search-input placeholder 'Search...'
 set search-input style flex 1
 set search-input style minWidth '120px'

 set sort-asc-ref [ object [ value true ] ]
 set sort-btn [ global document createElement, call button ]
 set sort-btn textContent 'A-Z'
 get sort-btn addEventListener, call click [
  function [
   set sort-asc-ref value [ get sort-asc-ref value, not ]
   set sort-btn textContent [ pick [ get sort-asc-ref value ] [ value 'A-Z' ], [ value true ] [ value 'Z-A' ] ]
   get render-list, call
  ]
 ]

 set header [ global document createElement, call div ]
 get header classList add, call find-items-header
 get header appendChild, call [ get filter-select ]
 get header appendChild, call [ get search-input ]
 get header appendChild, call [ get sort-btn ]

 get filter-select addEventListener, call change [
  function [
   set find-window-ref filter-type [ get filter-select value ]
   get render-list, call
  ]
 ]
 get search-input addEventListener, call input [
  function [
   get render-list, call
  ]
 ]

 set format-date [ function timestamp [
  global Date, new [ get timestamp ]
  at toLocaleDateString, call
 ] ]

 set render-list [ function [
  set filter-type [ get find-window-ref filter-type ]
  set search-text [ get search-input value, default '', at toLowerCase, call ]
  set all-items [ list ]

  get filter-type, is session, false [
   get filter-type, is value, false [
    get filter-type, is dictionary, false [
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

  get filter-type, is document, false [
   get filter-type, is value, false [
    get filter-type, is dictionary, false [
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

  get filter-type, is document, false [
   get filter-type, is session, false [
    get filter-type, is dictionary, false [
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

  get filter-type, is document, false [
   get filter-type, is session, false [
   get filter-type, is value, false [
   get filter-type, is folder, false [
     set dicts [ get dict-service fetch-all-dictionaries, call ]
     get dicts, each [
      function d [
       get all-items push, call [
        object [
         id [ get d id ]
         name [ get d name, default 'Untitled Dictionary' ]
         kind dictionary
         date [ get d createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
   ]
  ]

  get filter-type, is document, false [
   get filter-type, is session, false [
   get filter-type, is value, false [
   get filter-type, is dictionary, false [
   get filter-type, is script, false [
     set folders [ get folder-service fetch-all-folders, call ]
     get folders, each [
      function f [
       get all-items push, call [
        object [
         id [ get f id ]
         name [ get f name, default 'Untitled Folder' ]
         kind folder
         createdAt [ get f createdAt ]
        ]
       ]
      ]
     ]
    ]
   ]
   ]
   ]
  ]

  get filter-type, is document, false [
   get filter-type, is session, false [
   get filter-type, is value, false [
   get filter-type, is dictionary, false [
   get filter-type, is folder, false [
     set scripts [ get script-service fetch-all-scripts, call ]
     get scripts, each [
      function s [
       get s archived, false [
        get all-items push, call [
         object [
          id [ get s id ]
          name [ get s name, default 'Untitled Script' ]
          kind script
          createdAt [ get s createdAt ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
   ]
   ]
  ]

  set filtered [ get all-items, filter [
   function item [
    get search-text length, = 0, true [
     value true
    ], false [
     get item name, at toLowerCase, call, at includes, call [ get search-text ]
    ]
   ]
  ] ]
  set sorted [ get filtered, at slice, call 0 ]
  get sorted, at sort, call [
   function a b [
    set a-name [ get a name, default '' ]
    set b-name [ get b name, default '' ]
    get a-name, at localeCompare, call [ get b-name ]
   ]
  ]
  get sort-asc-ref value, false [
   get sorted, at reverse, call
  ]
  set display-items [ get sorted ]

  set list-container innerHTML ''
  get display-items length, = 0, true [
   set empty [ global document createElement, call div ]
   get empty classList add, call find-items-empty
   set empty textContent 'No items found'
   get list-container appendChild, call [ get empty ]
  ], false [
   get display-items, each [
    function item [
     set row [ global document createElement, call div ]
     get row classList add, call find-items-item

     set name [ global document createElement, call span ]
     get name classList add, call find-items-name
     set name textContent [ get item name ]
     get row appendChild, call [ get name ]

     set badge [ global document createElement, call span ]
     get badge classList add, call find-items-badge
     get badge classList add, call [ template 'find-items-badge-%0' [ get item kind ] ]
     set badge textContent [ get item kind ]
     get row appendChild, call [ get badge ]

     set date [ global document createElement, call span ]
     get date classList add, call find-items-date
     set date textContent [ get format-date, call [ get item createdAt ] ]
     get row appendChild, call [ get date ]

     get find-window-ref target, true [
      set select-btn [ global document createElement, call button ]
      get select-btn classList add, call find-items-btn
      get select-btn classList add, call find-items-select
      set select-btn textContent 'Select'
      get select-btn addEventListener, call click [
       function event [
        get event stopPropagation, call
        set target [ get find-window-ref target ]
        get target, call [ object [ type [ get item kind ], id [ get item id ], name [ get item name ] ] ]
        set find-window-ref target null
        get find-window close, call
       ]
      ]
      get row appendChild, call [ get select-btn ]
     ]

     get list-container appendChild, call [ get row ]
    ]
   ]
  ]
 ] ]

 set container [ global document createElement, call div ]
 get container classList add, call find-items
 get container appendChild, call [ get header ]
 get container appendChild, call [ get list-container ]

 set find-window-ref render-list [ get render-list ]

 set original-close [ get find-window close ]
 set find-window close [ function [
  set find-window-ref window null
  set find-window-ref target null
  set find-window-ref render-list null
  get original-close, call
 ] ]

 get find-window fill, call [ get container ]
 get main stage place-window, call [ get find-window ] [ get main status ]
 get render-list, call
] ]

set open-or-update-find [ function arg [
 get ensure-find-window, call

 get find-window-ref window, true [
  get main stage place-window, call [ get find-window-ref window ] [ get main status ]
 ]

 set filter-type [ get arg filterType, default all ]
 get filter-type, true [
  set find-window-ref filter-type [ get filter-type ]
  get find-window-ref window, true [
   set sel [ get find-window-ref window element, at querySelector, call 'select' ]
   get sel, true [
    set sel value [ get filter-type ]
   ]
  ]
 ]

 set target [ get arg target ]
 get target, true [
  set find-window-ref target [ get target ]
 ]

 get find-window-ref render-list, true [
  get find-window-ref render-list, call
 ]
] ]

get conductor register, call find:open [
 function arg [
  get arg, true [
   get open-or-update-find, call [ get arg ]
  ], false [
   get ensure-find-window, call
   get main stage place-window, call [ get find-window-ref window ] [ get main status ]
  ]
 ]
]
