# Mail Accounts - Gmail/SMTP accounts for syncing
# Registers mail-accounts:open

get lib style-tag

tell '.mail-accounts-layout' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.mail-accounts-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 12px
 ]
]

tell '.mail-account-item' [
 object [
  background-color '#333337'
  border-radius 4px
  margin-bottom 8px
  padding '12px 16px'
 ]
]

tell '.mail-account-type' [
 object [
  color '#4a9eff'
  font-size 12px
  text-transform uppercase
 ]
]

tell '.mail-account-email' [
 object [
  color '#e0e0d0'
  font-size 14px
  margin-top 4px
 ]
]

tell '.mail-accounts-add' [
 object [
  border-top '1px solid #333337'
  flex-shrink 0
  padding 12px
 ]
]

tell '.mail-accounts-add-btn' [
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

tell '.mail-accounts-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

get conductor register, call mail-accounts:open [
 function [
  set mail-service [ get main mail-service ]
  set session-service [ get main session-service ]

  set accounts-window [
   get components window, call 'Mail Accounts' 420 380
  ]

  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [ set accounts-window logEntryId [ get log-entry id ] ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [ set accounts-window logEntryId [ get replay-ev id ] ]
  ]

  set container [ global document createElement, call div ]
  get container classList add, call mail-accounts-layout

  set list-el [ global document createElement, call div ]
  get list-el classList add, call mail-accounts-list

  set render-list [ function [
   set list-el innerHTML ''
   set accounts [ get mail-service fetch-accounts, call ]
   get accounts length, = 0, true [
    set empty [ global document createElement, call div ]
    get empty classList add, call mail-accounts-empty
    set empty textContent 'No accounts connected. Add Gmail or SMTP to sync.'
    get list-el appendChild, call [ get empty ]
   ], false [
    get accounts, each [
     function a [
      set item [ global document createElement, call div ]
      get item classList add, call mail-account-item
      set type-el [ global document createElement, call div ]
      get type-el classList add, call mail-account-type
      set type-label [ get a type, default 'smtp' ]
      set type-el textContent [ get type-label ]
      get item appendChild, call [ get type-el ]
      set email-el [ global document createElement, call div ]
      get email-el classList add, call mail-account-email
      set email-el textContent [ get a email, default '' ]
      get item appendChild, call [ get email-el ]
      get list-el appendChild, call [ get item ]
     ]
    ]
   ]
  ] ]

  get render-list, call

  set add-section [ global document createElement, call div ]
  get add-section classList add, call mail-accounts-add
  set add-btn [ global document createElement, call button ]
  get add-btn classList add, call mail-accounts-add-btn
  set add-btn textContent 'Add account'
  set open-add-modal [ load ./add-account-modal.cr, point ]
  get add-btn addEventListener, call click [
   function [
    get open-add-modal, call [ get mail-service ] [ function [ get render-list, call ] ]
   ]
  ]
  get add-section appendChild, call [ get add-btn ]

  get container appendChild, call [ get list-el ]
  get container appendChild, call [ get add-section ]

  set original-close [ get accounts-window close ]
  set accounts-window close [ function [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get accounts-window logEntryId, true [
     get session-service mark-event-skipped-on-replay, call [ get accounts-window logEntryId ]
    ], false [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'mail-accounts:open'
    ]
   ]
   get original-close, call
  ] ]
  get accounts-window logEntryId, true [
   set accounts-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set accounts-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  get accounts-window fill, call [ get container ]
  get main stage place-window, call [ get accounts-window ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [ get accounts-window minimize-window, tell ]
  ]
 ]
]
