# Value Window - Opens a window for viewing/editing a value

get lib style-tag

tell '.value-content' [
 object [
  display flex
  flex-direction column
  height '100%'
  padding 16px
  box-sizing border-box
  gap 12px
 ]
]

tell '.value-status' [
 object [
  background-color '#333337'
  border-top '1px solid #444448'
  color '#808080'
  font-size 12px
  padding '4px 12px'
  flex-shrink 0
  display flex
  justify-content space-between
  align-items center
 ]
]

tell '.value-status-id' [
 object [
  color '#606070'
  font-size 11px
  margin-left 8px
 ]
]

set open-values [ object ]

set build-input [ get lib value-editor build-input ]

set open-value-window [ function val-id [
 set val-service [ get main value-service ]
 set session-service [ get main session-service ]

 set existing [ get main stage get-registered-window, call value [ get val-id ] ]
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
 set val [ get val-service fetch-value, call [ get val-id ] ]
 get val, false [
  log Value not found: [ get val-id ]
  value undefined
 ]

 set val-window [
  get components window, call [ get val name ] 280 350
 ]

 set log-entry [ get conductor getLastLoggedEntry, call ]
 get log-entry, true [
  get log-entry id, true [
   set val-window logEntryId [ get log-entry id ]
  ]
 ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev id, true [
   set val-window logEntryId [ get replay-ev id ]
  ]
 ]

 set content [ global document createElement, call div ]
 get content classList add, call value-content

 # Type selector row
 set type-row [ global document createElement, call div ]
 get type-row classList add, call value-type-row

 set type-label [ global document createElement, call span ]
 get type-label classList add, call value-type-label
 set type-label textContent 'Type'
 get type-row appendChild, call [ get type-label ]

 set type-select [ global document createElement, call select ]
 get type-select classList add, call value-type-select

 list string integer float boolean null undefined, each [
  function t [
   set opt [ global document createElement, call option ]
   set opt value [ get t ]
   set opt textContent [ get t ]
   get type-select appendChild, call [ get opt ]
  ]
 ]
 set type-select value [ get val type, default string ]
 get type-row appendChild, call [ get type-select ]
 get content appendChild, call [ get type-row ]

 # Input container (rebuilt when type changes)
 set input-container [ global document createElement, call div ]
 set input-container style flex 1
 set input-container style display flex
 set input-container style flexDirection column
 get content appendChild, call [ get input-container ]

 # State ref for current value
 set state [ object [
  type [ get val type, default string ]
  value [ get val value ]
 ] ]

 set status-left-ref [ object [ el null ] ]

 set on-change [ function new-type new-value [
  set state type [ get new-type ]
  set state value [ get new-value ]
  get status-left-ref el, true [
   set status-left-ref el textContent 'Saving...'
  ]
  set result [ get val-service update-value, call [ get val-id ] [ get new-type ] [ get new-value ] ]
  get result, true [
   get status-left-ref el, true [
    set status-left-ref el textContent 'Saved'
   ]
  ], false [
   get status-left-ref el, true [
    set status-left-ref el textContent 'Error saving'
   ]
  ]
 ] ]

 get build-input, call [ get input-container ] [ get val type, default string ] [ get val value ] [ get on-change ]

 get type-select addEventListener, call change [
  function [
   set new-type [ get type-select value ]
   # Convert value for new type or reset
   set new-value [ value null ]
   get new-type, is string, true [ set new-value '' ]
   get new-type, is integer, true [ set new-value 0 ]
   get new-type, is float, true [ set new-value 0 ]
   get new-type, is boolean, true [ set new-value false ]
   set state type [ get new-type ]
   set state value [ get new-value ]
   get build-input, call [ get input-container ] [ get new-type ] [ get new-value ] [ get on-change ]
   get on-change, call [ get new-type ] [ get new-value ]
  ]
 ]

 # Status bar
 set status [ global document createElement, call div ]
 get status classList add, call value-status
 set status-left [ global document createElement, call span ]
 set status-left textContent 'Ready'
 set status-left-ref el [ get status-left ]
 get status appendChild, call [ get status-left ]
 set status-id [ global document createElement, call span ]
 get status-id classList add, call value-status-id
 set status-id textContent [ get val-id ]
 get status appendChild, call [ get status-id ]
 get content appendChild, call [ get status ]

 # Track focused value
 set val-window val-id [ get val-id ]
 set open-values [ get val-id ] [ get val-window ]
 get main stage register-window, call value [ get val-id ] [ get val-window ]

 get val-service on, call valueRenamed [
  function data [
   get data id, is [ get val-id ], true [
    set val-window title-text textContent [ get data name ]
   ]
  ]
 ]

 set original-close [ get val-window close ]
 set val-window close [ function [
  get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
   get val-window logEntryId, true [
    get session-service mark-event-skipped-on-replay, call [ get val-window logEntryId ]
   ], false [
    get session-service mark-last-event-with-action-skipped-on-replay, call 'value:open'
   ]
  ]
  set open-values [ get val-id ] null
  get main stage unregister-window, call value [ get val-id ]
  get original-close, call
 ] ]
 get val-window logEntryId, true [
  set val-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
  set val-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
 ]

 get val-window fill, call [ get content ]
 get main stage place-window, call [
  get val-window
 ] [ get main status ]
 set replay-ev [ get conductor getReplayEvent, call ]
 get replay-ev, true [
  get replay-ev minimized, true [
   get val-window minimize-window, tell
  ]
 ]

 get val-service set-current-value-id, call [ get val-id ]
 get main set-last-interacted-element, call [ get val-window element ]

 get val-window element addEventListener, call mousedown [
  function [
   get val-service set-current-value-id, call [ get val-id ]
   get main set-last-interacted-element, call [ get val-window element ]
  ]
 ]
 ]
] ]

get conductor register, call value:open [
 function arg [
  set val-id [ get arg id, default [ get arg ] ]
  get open-value-window, call [ get val-id ]
 ]
]

get conductor register, call '!value:new' [
 function [
  set val-service [ get main value-service ]
  set val [ get val-service create-value, call ]
  get val, true [
   get conductor dispatch, call value:open [ object [ id [ get val id ], name [ get val name, default 'Untitled Value' ] ] ]
  ]
 ]
]
