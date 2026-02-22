# Mail Window - 2-panel mail client and thread viewer
# Registers mail:open action (no arg = main window, arg.threadId = thread window)

get lib style-tag

tell '.mail-layout' [
 object [
  display flex
  flex-direction row
  height '100%'
  width '100%'
 ]
]

tell '.mail-folders' [
 object [
  background-color '#1e1e22'
  border-right '1px solid #333337'
  display flex
  flex-direction column
  flex-shrink 0
  padding 8px
  width 160px
 ]
]

tell '.mail-folder' [
 object [
  background-color transparent
  border none
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 14px
  padding '10px 12px'
  text-align left
 ]
]

tell '.mail-folder:hover' [
 object [
  background-color '#333337'
 ]
]

tell '.mail-folder.active' [
 object [
  background-color '#4a9eff'
  color white
 ]
]

tell '.mail-thread-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 8px
 ]
]

tell '.mail-thread-item' [
 object [
  background-color '#333337'
  border-radius 4px
  cursor pointer
  margin-bottom 8px
  padding '12px 14px'
 ]
]

tell '.mail-thread-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.mail-thread-subject' [
 object [
  color '#e0e0d0'
  font-size 14px
  font-weight bold
  margin-bottom 4px
 ]
]

tell '.mail-thread-preview' [
 object [
  color '#808080'
  font-size 12px
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
 ]
]

tell '.mail-thread-date' [
 object [
  color '#606070'
  font-size 11px
  margin-top 4px
 ]
]

tell '.mail-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

tell '.mail-thread-view' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.mail-thread-header' [
 object [
  border-bottom '1px solid #333337'
  flex-shrink 0
  padding 16px
 ]
]

tell '.mail-thread-header .mail-thread-subject' [
 object [
  color '#e0e0d0'
  font-size 16px
  font-weight bold
  margin-bottom 8px
 ]
]

tell '.mail-thread-header .mail-thread-meta' [
 object [
  color '#808080'
  font-size 12px
 ]
]

tell '.mail-thread-messages' [
 object [
  flex-grow 1
  overflow-y auto
  padding 12px
 ]
]

tell '.mail-message' [
 object [
  border-bottom '1px solid #333337'
  margin-bottom 12px
  padding-bottom 12px
 ]
]

tell '.mail-message-meta' [
 object [
  color '#808080'
  font-size 12px
  margin-bottom 6px
 ]
]

tell '.mail-message-body' [
 object [
  color '#e0e0d0'
  font-size 14px
  line-height 1.5
  white-space pre-wrap
 ]
]

tell '.mail-compose' [
 object [
  border-top '1px solid #333337'
  flex-shrink 0
  padding 12px
 ]
]

tell '.mail-compose-textarea' [
 object [
  background-color '#1e1e22'
  border '1px solid #333337'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  height 80px
  margin-bottom 8px
  padding 8px
  resize vertical
  width '100%'
 ]
]

tell '.mail-send-btn' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 14px
  padding '8px 16px'
 ]
]

tell '.mail-send-btn:hover' [
 object [
  background-color '#5aafff'
 ]
]

# Track open thread windows by ID
set open-threads [ object ]

set open-thread-window [ load ./thread-window.cr, point ]

set open-mail-window [ function [
 set mail-service [ get main mail-service ]
 set session-service [ get main session-service ]

 set mail-window [
  get components window, call Mail 600 450
 ]

 set container [ global document createElement, call div ]
 get container classList add, call mail-layout

 set folders [ global document createElement, call div ]
 get folders classList add, call mail-folders

 set list-container [ global document createElement, call div ]
 get list-container classList add, call mail-thread-list

 set folder-ref [ object [ current 'inbox' ] ]
 set all-threads-ref [ object [ val [ list ] ] ]
 set active-folder-btn [ object [ el null ] ]
 set format-date [ function ts [
  global Date, new [ get ts ]
  at toLocaleDateString, call
 ] ]

 set refresh-all [ function [
  set all [ get mail-service fetch-threads, call ]
  get all error, false [
   set all-threads-ref val [ get all ]
  ]
 ] ]

 set render-threads [ function [
  set list-el [ get list-container ]
  get list-el, true [
   set list-el innerHTML ''
   set all [ get all-threads-ref val ]
   set threads [ get all, filter [ function t [ get t folder, is [ get folder-ref current ] ] ] ]
   get threads length, = 0, true [
    set empty [ global document createElement, call div ]
    get empty classList add, call mail-empty
    set empty textContent 'No messages'
    get list-el appendChild, call [ get empty ]
   ], false [
    get threads, each [
     function t [
      set item [ global document createElement, call div ]
      get item classList add, call mail-thread-item
      set subj [ global document createElement, call div ]
      get subj classList add, call mail-thread-subject
      set subj textContent [ get t subject, default '(No subject)' ]
      get item appendChild, call [ get subj ]
      set preview [ global document createElement, call div ]
      get preview classList add, call mail-thread-preview
      set first-msg [ get t, default [ object ] ]
      set preview textContent [ get t subject, default '' ]
      get item appendChild, call [ get preview ]
      set date-el [ global document createElement, call div ]
      get date-el classList add, call mail-thread-date
      set date-el textContent [ get format-date, call [ get t createdAt ] ]
      get item appendChild, call [ get date-el ]
      get item addEventListener, call click [
       function [
        get conductor dispatch, call mail:open [ object [ threadId [ get t id ] ] ]
       ]
      ]
      get list-el appendChild, call [ get item ]
     ]
    ]
   ]
  ]
 ] ]

 set add-folder [ function label folder-key count [
  set btn [ global document createElement, call button ]
  get btn classList add, call mail-folder
  set label-text [ get label ]
  get count, true [
   get count, > 0, true [
    set label-text [ template '%0 (%1)' [ get label ] [ get count ] ]
   ]
  ]
  set btn textContent [ get label-text ]
  get btn addEventListener, call click [
   function [
    set folder-ref current [ get folder-key ]
    get active-folder-btn el, true [
     get active-folder-btn el classList remove, call active
    ]
    set active-folder-btn el [ get btn ]
    get btn classList add, call active
    get render-threads, call
   ]
  ]
  get folder-ref current, is [ get folder-key ], true [
   get btn classList add, call active
   set active-folder-btn el [ get btn ]
  ]
  get folders appendChild, call [ get btn ]
 ] ]

 set count-for-folder [ function folder-key [
  set all [ get all-threads-ref val ]
  set filtered [ get all, filter [ function t [ get t folder, is [ get folder-key ] ] ] ]
  get filtered length
 ] ]

 set new-btn [ global document createElement, call button ]
 get new-btn classList add, call mail-folder
 set new-btn textContent 'Compose'
 get new-btn addEventListener, call click [
  function [
   set thread [ get mail-service create-thread, call '(No subject)' '' [ list ] '' ]
   get thread, true [
    get conductor dispatch, call mail:open [ object [ threadId [ get thread id ] ] ]
   ]
  ]
 ]
 get folders appendChild, call [ get new-btn ]

 get refresh-all, call
 set inbox-count [ get count-for-folder, call 'inbox' ]
 set sent-count [ get count-for-folder, call 'sent' ]
 set drafts-count [ get count-for-folder, call 'drafts' ]
 set archived-count [ get count-for-folder, call 'archived' ]
 get add-folder, call 'Inbox' 'inbox' inbox-count
 get add-folder, call 'Sent' 'sent' sent-count
 get add-folder, call 'Drafts' 'drafts' drafts-count
 get add-folder, call 'Archived' 'archived' archived-count

 get container appendChild, call [ get folders ]
 get container appendChild, call [ get list-container ]

 get render-threads, call

 get mail-window fill, call [ get container ]
 get main stage place-window, call [
  get mail-window
 ] [ get main status ]
] ]

get conductor register, call mail:open [
 function arg [
  get arg, true [
   get arg threadId, true [
    get open-thread-window, call [ get arg threadId ]
   ], false [
    get open-mail-window, call
   ]
  ], false [
   get open-mail-window, call
  ]
 ]
]
