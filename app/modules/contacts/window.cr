# Contacts Window - List and manage contacts

get lib style-tag

tell '.contacts-layout' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.contact-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.contact-item' [
 object [
  align-items center
  background-color '#333337'
  border-radius 4px
  display flex
  margin-bottom 8px
  padding '10px 15px'
 ]
]

tell '.contact-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.contact-item-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.contact-item-email' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.contact-item-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.contact-item-delete' [
 object [
  background-color '#aa4444'
  color white
 ]
]

tell '.contact-item-delete:hover' [
 object [
  background-color '#bb5555'
 ]
]

tell '.contact-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

tell '.contact-add' [
 object [
  border-top '1px solid #333337'
  flex-shrink 0
  padding 12px
 ]
]

tell '.contact-add-input' [
 object [
  background-color '#1e1e22'
  border '1px solid #333337'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  margin-right 8px
  padding '8px 12px'
  width 120px
 ]
]

tell '.contact-add-btn' [
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

tell '.contact-add-btn:hover' [
 object [
  background-color '#5aafff'
 ]
]

get conductor register, call contacts:open [
 function [
  set contact-service [ get main contact-service ]
  set session-service [ get main session-service ]

  set contacts-window [
   get components window, call Contacts 400 450
  ]

  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set contacts-window logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set contacts-window logEntryId [ get replay-ev id ]
   ]
  ]

  set container [ global document createElement, call div ]
  get container classList add, call contacts-layout

  set list-el [ global document createElement, call div ]
  get list-el classList add, call contact-list

  set render-list [ function [
   set list-el innerHTML ''
   set contacts [ get contact-service fetch-contacts, call ]
   get contacts length, = 0, true [
    set empty [ global document createElement, call div ]
    get empty classList add, call contact-empty
    set empty textContent 'No contacts'
    get list-el appendChild, call [ get empty ]
   ], false [
    get contacts, each [
     function c [
      set item [ global document createElement, call div ]
      get item classList add, call contact-item
      set name-el [ global document createElement, call span ]
      get name-el classList add, call contact-item-name
      set name-el textContent [ get c name, default '' ]
      get item appendChild, call [ get name-el ]
      set email-el [ global document createElement, call span ]
      get email-el classList add, call contact-item-email
      set email-el textContent [ get c email, default '' ]
      get item appendChild, call [ get email-el ]
      set delete-btn [ global document createElement, call button ]
      get delete-btn classList add, call contact-item-btn
      get delete-btn classList add, call contact-item-delete
      set delete-btn textContent 'Delete'
      get delete-btn addEventListener, call click [
       function [
        get contact-service delete-contact, call [ get c id ]
        get render-list, call
       ]
      ]
      get item appendChild, call [ get delete-btn ]
      get list-el appendChild, call [ get item ]
     ]
    ]
   ]
  ] ]

  get render-list, call

  set add-section [ global document createElement, call div ]
  get add-section classList add, call contact-add
  set name-input [ global document createElement, call input ]
  get name-input classList add, call contact-add-input
  get name-input placeholder 'Name'
  get add-section appendChild, call [ get name-input ]
  set email-input [ global document createElement, call input ]
  get email-input classList add, call contact-add-input
  get email-input placeholder 'Email'
  get add-section appendChild, call [ get email-input ]
  set add-btn [ global document createElement, call button ]
  get add-btn classList add, call contact-add-btn
  set add-btn textContent 'Add'
  get add-btn addEventListener, call click [
   function [
    set name [ get name-input value ]
    set email [ get email-input value ]
    get name length, > 0, true [
     get contact-service create-contact, call [ get name ] [ get email ]
     set name-input value ''
     set email-input value ''
     get render-list, call
    ]
   ]
  ]
  get add-section appendChild, call [ get add-btn ]

  get container appendChild, call [ get list-el ]
  get container appendChild, call [ get add-section ]

  set original-close [ get contacts-window close ]
  set contacts-window close [ function [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get contacts-window logEntryId, true [
     get session-service mark-event-skipped-on-replay, call [ get contacts-window logEntryId ]
    ], false [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'contacts:open'
    ]
   ]
   get original-close, call
  ] ]
  get contacts-window logEntryId, true [
   set contacts-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set contacts-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  get contacts-window fill, call [ get container ]
  get main stage place-window, call [
   get contacts-window
  ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get contacts-window minimize-window, tell
   ]
  ]
 ]
]
