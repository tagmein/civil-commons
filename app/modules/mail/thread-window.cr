# Opens a thread window - header, messages, compose form for drafts

set open-thread-window [ function thread-id [
 set mail-service [ get main mail-service ]
 set session-service [ get main session-service ]
 set contact-service [ get main contact-service ]

 get open-threads [ get thread-id ], true [
  set existing [ get open-threads [ get thread-id ] ]
  get existing raise-window, tell
  get existing flash, true [ get existing flash, tell ]
  value undefined
 ]

 set thread [ get mail-service fetch-thread, call [ get thread-id ] ]
 get thread, false [
  log Thread not found: [ get thread-id ]
  value undefined
 ]

 set thread-window [
  get components window, call [ get thread subject, default '(No subject)' ] 560 520
 ]

 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [ set thread-window logEntryId [ get log-entry id ] ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [ set thread-window logEntryId [ get replay-ev id ] ]
 ]

 set container [ global document createElement, call div ]
 get container classList add, call mail-thread-view

 get container appendChild, call [ load ./thread-header.cr, point ]

 get container appendChild, call [ load ./thread-messages.cr, point ]

 get thread folder, is 'drafts', true [
  set create-compose [ load ./compose.cr, point ]
  set on-send [
   function data [
    set from-arr [ get data from, default [ list ] ]
    set from-val [ get from-arr length, > 0, true [ get from-arr, at 0 ], false [ value 'me' ] ]
    get mail-service append-message, call [ get thread-id ] [
     object [
      from [ get from-val ]
      to [ get data to, default [ list ] ]
      cc [ get data cc, default [ list ] ]
      bcc [ get data bcc, default [ list ] ]
      body [ get data body, default '' ]
     ]
    ]
    get mail-service update-thread, call [ get thread-id ] [
     object [ subject [ get data subject, default '(No subject)' ] ]
    ]
    get mail-service move-to-folder, call [ get thread-id ] 'sent'
    get thread-window close, tell
   ]
  ]
  set compose-obj [
   get create-compose, call [ get mail-service ] [ get contact-service ] [ get on-send ]
  ]
  get compose-obj setSubject, call [ get thread subject, default '' ]
  set msgs [ get thread messages, default [ list ] ]
  get msgs length, > 0, true [
   get compose-obj setBody, call [ get msgs, at 0, at body, default '' ]
  ]
  get container appendChild, call [ get compose-obj element ]
 ]

 set open-threads [ get thread-id ] [ get thread-window ]

 set original-close [ get thread-window close ]
 set thread-window close [ function [
  get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
   get thread-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get thread-window logEntryId ]
   ], false [
    get session-service mark-last-event-with-action-skipped-on-replay, call 'mail:open'
   ]
  ]
  set open-threads [ get thread-id ] null
  get original-close, call
 ] ]
 get thread-window logEntryId, true [
  set thread-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
  set thread-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
 ]

 get thread-window fill, call [ get container ]
 get main stage place-window, call [ get thread-window ] [ get main status ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev minimized, true [ get thread-window minimize-window, tell ]
 ]
] ]
get open-thread-window
