# Mail Sync - Sync options and history
# Registers mail:sync

get lib style-tag

tell '.mail-sync-layout' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.mail-sync-status' [
 object [
  background-color '#1e1e22'
  border-radius 4px
  margin-bottom 12px
  padding 16px
 ]
]

tell '.mail-sync-last-time' [
 object [
  color '#4a9eff'
  font-size 18px
  font-weight bold
 ]
]

tell '.mail-sync-last-count' [
 object [
  color '#808080'
  font-size 14px
  margin-top 4px
 ]
]

tell '.mail-sync-options' [
 object [
  margin-bottom 12px
 ]
]

tell '.mail-sync-option-row' [
 object [
  align-items center
  display flex
  margin-bottom 8px
 ]
]

tell '.mail-sync-interval' [
 object [
  background-color '#1e1e22'
  border '1px solid #333337'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  margin-left 8px
  padding '6px 10px'
  width 60px
 ]
]

tell '.mail-sync-now-btn' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 14px
  padding '10px 20px'
 ]
]

tell '.mail-sync-history' [
 object [
  flex-grow 1
  overflow-y auto
 ]
]

tell '.mail-sync-history-table' [
 object [
  border-collapse collapse
  width '100%'
 ]
]

tell '.mail-sync-history-table th' [
 object [
  background-color '#333337'
  color '#e0e0d0'
  font-size 12px
  padding '8px 12px'
  text-align left
 ]
]

tell '.mail-sync-history-table td' [
 object [
  border-bottom '1px solid #333337'
  color '#808080'
  font-size 13px
  padding '8px 12px'
 ]
]

get conductor register, call mail:sync [
 function [
  set mail-service [ get main mail-service ]
  set session-service [ get main session-service ]

  set sync-window [
   get components window, call 'Mail Sync' 520 480
  ]

  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [ set sync-window logEntryId [ get log-entry id ] ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [ set sync-window logEntryId [ get replay-ev id ] ]
  ]

  set container [ global document createElement, call div ]
  get container classList add, call mail-sync-layout

  set status-el [ global document createElement, call div ]
  get status-el classList add, call mail-sync-status

  set last-time-el [ global document createElement, call div ]
  get last-time-el classList add, call mail-sync-last-time

  set last-count-el [ global document createElement, call div ]
  get last-count-el classList add, call mail-sync-last-count

  set options-el [ global document createElement, call div ]
  get options-el classList add, call mail-sync-options

  set mode-ref [ object [ value 'manual' ] ]
  set interval-ref [ object [ value 15 ] ]

  set refresh [ function [
   set settings [ get mail-service fetch-sync-settings, call ]
   get settings, true [
    set last-time [ get settings lastSyncAt ]
    set last-count [ get settings lastSyncCount ]
    set last-account [ get settings lastSyncAccount, default '' ]
    get last-time, true [
     set d [ global Date, new [ get last-time ] ]
     set last-time-el textContent [ template 'Last sync: %0' [ get d at toLocaleString, call ] ]
    ], false [
     set last-time-el textContent 'Last sync: Never'
    ]
    set last-count-el textContent [ template 'Items synced: %0' [ get last-count, default 0 ] ]
    set mode-ref value [ get settings mode, default 'manual' ]
    set interval-ref value [ get settings intervalMinutes, default 15 ]
   ]
  ] ]

  get refresh, call

  set mode-row [ global document createElement, call div ]
  get mode-row classList add, call mail-sync-option-row
  set mode-label [ global document createElement, call div ]
  set mode-label textContent 'Sync mode: '
  get mode-row appendChild, call [ get mode-label ]
  set manual-btn [ global document createElement, call button ]
  set manual-btn textContent 'Manual'
  get manual-btn addEventListener, call click [
   function [
    set mode-ref value 'manual'
    get mail-service update-sync-settings, call [ object [ mode 'manual' ] ]
   ]
  ]
  get mode-row appendChild, call [ get manual-btn ]
  set auto-btn [ global document createElement, call button ]
  set auto-btn textContent 'Automatic'
  get auto-btn addEventListener, call click [
   function [
    set mode-ref value 'automatic'
    get mail-service update-sync-settings, call [ object [ mode 'automatic' ] ]
   ]
  ]
  get mode-row appendChild, call [ get auto-btn ]

  set interval-row [ global document createElement, call div ]
  get interval-row classList add, call mail-sync-option-row
  set interval-label [ global document createElement, call div ]
  set interval-label textContent 'Interval (min): '
  get interval-row appendChild, call [ get interval-label ]
  set interval-input [ global document createElement, call input ]
  get interval-input classList add, call mail-sync-interval
  get interval-input setAttribute, call 'type' 'number'
  get interval-input setAttribute, call 'value' '15'
  get interval-input addEventListener, call change [
   function [
    set v [ get interval-input value ]
    get v, true [
     set n [ global parseInt, call [ get v ] 10 ]
     set interval-ref value [ get n ]
     get mail-service update-sync-settings, call [ object [ intervalMinutes [ get n ] ] ]
    ]
   ]
  ]
  get interval-row appendChild, call [ get interval-input ]

  get options-el appendChild, call [ get mode-row ]
  get options-el appendChild, call [ get interval-row ]

  set sync-now-btn [ global document createElement, call button ]
  get sync-now-btn classList add, call mail-sync-now-btn
  set sync-now-btn textContent 'Sync now'
  get sync-now-btn addEventListener, call click [
   function [
    set result [ get mail-service sync-now, call ]
    get refresh, call
    set history [ get mail-service fetch-sync-history, call ]
    get history-table-el, true [
     set history-table-el innerHTML ''
     set thead [ global document createElement, call thead ]
     set tr [ global document createElement, call tr ]
     set th1 [ global document createElement, call th ]
     set th1 textContent 'Items'
     get tr appendChild, call [ get th1 ]
     set th2 [ global document createElement, call th ]
     set th2 textContent 'Account'
     get tr appendChild, call [ get th2 ]
     set th3 [ global document createElement, call th ]
     set th3 textContent 'Result'
     get tr appendChild, call [ get th3 ]
     get thead appendChild, call [ get tr ]
     get history-table-el appendChild, call [ get thead ]
     get history, each [
      function h [
       set row [ global document createElement, call tr ]
       set td1 [ global document createElement, call td ]
       set td1 textContent [ get h count, default 0 ]
       get row appendChild, call [ get td1 ]
       set td2 [ global document createElement, call td ]
       set td2 textContent [ get h accountId, default '' ]
       get row appendChild, call [ get td2 ]
       set td3 [ global document createElement, call td ]
       set td3 textContent [ get h result, default '' ]
       get row appendChild, call [ get td3 ]
       get history-table-el appendChild, call [ get row ]
      ]
     ]
    ]
   ]
  ]
  get options-el appendChild, call [ get sync-now-btn ]

  get status-el appendChild, call [ get last-time-el ]
  get status-el appendChild, call [ get last-count-el ]
  get container appendChild, call [ get status-el ]
  get container appendChild, call [ get options-el ]

  set history-section [ global document createElement, call div ]
  get history-section classList add, call mail-sync-history
  set history-table-el [ global document createElement, call table ]
  get history-table-el classList add, call mail-sync-history-table
  set history [ get mail-service fetch-sync-history, call ]
  get history length, > 0, true [
   set thead [ global document createElement, call thead ]
   set tr [ global document createElement, call tr ]
   set th1 [ global document createElement, call th ]
   set th1 textContent 'Items'
   get tr appendChild, call [ get th1 ]
   set th2 [ global document createElement, call th ]
   set th2 textContent 'Account'
   get tr appendChild, call [ get th2 ]
   set th3 [ global document createElement, call th ]
   set th3 textContent 'Result'
   get tr appendChild, call [ get th3 ]
   get thead appendChild, call [ get tr ]
   get history-table-el appendChild, call [ get thead ]
   get history, each [
    function h [
     set row [ global document createElement, call tr ]
     set td1 [ global document createElement, call td ]
     set td1 textContent [ get h count, default 0 ]
     get row appendChild, call [ get td1 ]
     set td2 [ global document createElement, call td ]
     set td2 textContent [ get h accountId, default '' ]
     get row appendChild, call [ get td2 ]
     set td3 [ global document createElement, call td ]
     set td3 textContent [ get h result, default '' ]
     get row appendChild, call [ get td3 ]
     get history-table-el appendChild, call [ get row ]
    ]
   ]
  ]
  get history-section appendChild, call [ get history-table-el ]
  get container appendChild, call [ get history-section ]

  set original-close [ get sync-window close ]
  set sync-window close [ function [
   get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
    get sync-window logEntryId, true [
     get session-service mark-event-skipped-on-replay, call [ get sync-window logEntryId ]
    ], false [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'mail:sync'
    ]
   ]
   get original-close, call
  ] ]
  get sync-window logEntryId, true [
   set sync-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set sync-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  get sync-window fill, call [ get container ]
  get main stage place-window, call [ get sync-window ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [ get sync-window minimize-window, tell ]
  ]
 ]
]
