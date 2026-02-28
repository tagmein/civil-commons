# Log Window - Displays all dispatched events for the current session
# Allows deleting events one at a time

get lib style-tag

tell '.log-content' [
 object [
  padding 16px
  overflow-y auto
  height '100%'
  box-sizing border-box
 ]
]

tell '.log-empty' [
 object [
  color '#808080'
  font-style italic
  padding 20px
  text-align center
 ]
]

tell '.log-event' [
 object [
  display flex
  flex-wrap wrap
  align-items center
  justify-content space-between
  padding '8px 12px'
  margin-bottom 8px
  background-color '#333337'
  border-radius 4px
  border-left '3px solid #4a9eff'
 ]
]

tell '.log-event-tags' [
 object [
  width '100%'
  flex-basis '100%'
  margin-top 6px
  padding-top 6px
  border-top '1px solid #444'
  display flex
  flex-wrap wrap
  gap 6px
 ]
]

tell '.log-event-minimized-tag' [
 object [
  background-color '#555533'
  border-radius 4px
  color '#c0c0a0'
  font-size 11px
  padding '2px 4px 2px 8px'
  display inline-flex
  align-items center
  gap 4px
 ]
]

tell '.log-event-minimized-tag-remove' [
 object [
  background none
  border none
  border-radius 2px
  color '#c0c0a0'
  cursor pointer
  padding 2px
  margin-top 2px
  display inline-flex
  align-items center
  justify-content center
 ]
]

tell '.log-event-minimized-tag-remove:hover' [
 object [
  background-color '#666644'
  color white
 ]
]

tell '.log-event.skipped-on-replay' [
 object [
  border-left-color '#666633'
  opacity 0.9
 ]
]

tell '.log-event:hover' [
 object [
  background-color '#3a3a3f'
 ]
]

tell '.log-event-info' [
 object [
  flex 1
  min-width 0
 ]
]

tell '.log-event-action' [
 object [
  color '#4a9eff'
  font-weight bold
  font-size 14px
  margin-bottom 4px
 ]
]

tell '.log-event-time' [
 object [
  color '#808080'
  font-size 12px
 ]
]

tell '.log-event-skip-wrap' [
 object [
  align-items center
  display flex
  flex-shrink 0
  margin-left 12px
 ]
]

tell '.log-event-skip-label' [
 object [
  align-items center
  color '#a0a0a0'
  cursor pointer
  display flex
  font-size 12px
  margin-right 6px
  user-select none
  white-space nowrap
 ]
]

tell '.log-event-skip-checkbox' [
 object [
  cursor pointer
  margin 0
  margin-right 2px
  opacity 0.65
 ]
]

tell '.log-event-delete' [
 object [
  background-color '#aa4444'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 12px
  padding '4px 8px'
  margin-left 8px
  flex-shrink 0
 ]
]

tell '.log-event-delete:hover' [
 object [
  background-color '#cc5555'
 ]
]

tell '.log-event-detail' [
 object [
  color '#a0a0a0'
  font-size 13px
  margin-top 2px
 ]
]

tell '.log-event-skipped' [
 object [
  background-color '#666633'
  border-radius 4px
  color '#c0c0a0'
  font-size 11px
  font-weight bold
  margin-top 4px
  padding '2px 6px'
  display inline-block
 ]
]

get conductor register, call log:open [
 function [
  set session-service [ get main session-service ]
  set doc-service [ get main document-service ]
  set mail-service [ get main mail-service ]

  set log-window [
   get components window, call 'Event Log' 400 500
  ]
  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set log-window logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set log-window logEntryId [ get replay-ev id ]
   ]
  ]
  get log-window logEntryId, true [
   set log-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set log-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]

  # Create content container
  set content [
   global document createElement, call div
  ]
  get content classList add, call log-content

  # Function to render the log
  set render-log [ function [
   # Preserve scroll position across re-render
   set saved-scroll [ get content scrollTop ]

   set content innerHTML ''

   set log [ get session-service get-event-log, call ]

   get log length, = 0, true [
    # Show empty message
    set empty-msg [
     global document createElement, call div
    ]
    get empty-msg classList add, call log-empty
    set empty-msg textContent 'No events logged yet'
    get content appendChild, call [ get empty-msg ]
   ], false [
    # Render each event
    set index-ref [ object [ i 0 ] ]
    get log, each [
     function event [
      set current-index [ get index-ref i ]

      set event-el [
       global document createElement, call div
      ]
      get event-el classList add, call log-event
      get event skippedOnReplay, true [
       get event-el classList add, call skipped-on-replay
      ]

      # Event info section
      set info [
       global document createElement, call div
      ]
      get info classList add, call log-event-info

      set action-el [
       global document createElement, call div
      ]
      get action-el classList add, call log-event-action
      set action-el textContent [ get event action ]
      get info appendChild, call [ get action-el ]

      # For document:open show document name and id (use current name from API when available, e.g. after rename)
      get event action, is 'document:open', true [
       get event arg, true [
        set detail-el [ global document createElement, call div ]
        get detail-el classList add, call log-event-detail
        set doc-id [ get event arg id, default [ get event arg ] ]
        set doc-name [ get event arg name, default [ get doc-id ] ]
        set current-doc [ get doc-service fetch-document, call [ get doc-id ] ]
        get current-doc, true [
         get current-doc name, true [ set doc-name [ get current-doc name ] ]
        ]
        set detail-el textContent [ template '%0 (id: %1)' [ get doc-name ] [ get doc-id ] ]
        get info appendChild, call [ get detail-el ]
       ]
      ]

      # For mail:open with threadId show thread subject
      get event action, is 'mail:open', true [
       get event arg threadId, true [
        set detail-el [ global document createElement, call div ]
        get detail-el classList add, call log-event-detail
        set thread-id [ get event arg threadId ]
        set thread [ get mail-service fetch-thread, call [ get thread-id ] ]
        set subject [ get thread subject, default [ get thread-id ] ]
        set detail-el textContent [ template '%0 (id: %1)' [ get subject ] [ get thread-id ] ]
        get info appendChild, call [ get detail-el ]
       ]
      ]

      # Skipped on replay badge
      get event skippedOnReplay, true [
       set skipped-el [ global document createElement, call span ]
       get skipped-el classList add, call log-event-skipped
       set skipped-el textContent 'Skipped on replay'
       get info appendChild, call [ get skipped-el ]
      ]

      set time-el [
       global document createElement, call div
      ]
      get time-el classList add, call log-event-time
      set time-str [
       global Date, new [ get event timestamp ]
       at toLocaleString, call
      ]
      set time-el textContent [ get time-str ]
      get info appendChild, call [ get time-el ]

      get event-el appendChild, call [ get info ]

      # Skip on replay checkbox (to the left of Delete); label "Skip" to the right of the checkbox. Always enabled; use event id or index.
      set skip-wrap [ global document createElement, call div ]
      get skip-wrap classList add, call log-event-skip-wrap
      set skip-label [ global document createElement, call label ]
      get skip-label classList add, call log-event-skip-label
      set skip-cb [ global document createElement, call input ]
      set skip-cb type 'checkbox'
      get skip-cb classList add, call log-event-skip-checkbox
      get event skippedOnReplay, true [
       set skip-cb checked true
      ]
      get skip-label appendChild, call [ get skip-cb ]
      set skip-text [ global document createElement, call span ]
      set skip-text textContent 'Skip'
      get skip-label appendChild, call [ get skip-text ]
      get skip-cb addEventListener, call change [
       function [
        get event id, true [
         get session-service set-event-skipped-on-replay, call [ get event id ] [ get skip-cb checked ]
        ], false [
         get session-service set-event-skipped-on-replay-by-index, call [ get current-index ] [ get skip-cb checked ]
        ]
        get render-log, call
       ]
      ]
      get skip-wrap appendChild, call [ get skip-label ]
      get event-el appendChild, call [ get skip-wrap ]

      # Delete button
      set delete-btn [
       global document createElement, call button
      ]
      get delete-btn classList add, call log-event-delete
      set delete-btn textContent 'Delete'
      get delete-btn addEventListener, call click [
       function [
        get session-service delete-event, call [ get current-index ]
        get render-log, call
       ]
      ]
      get event-el appendChild, call [ get delete-btn ]

      # Minimized tag (for window-opening events only); show below everything; click to remove
      set window-opening-actions [ list 'document:open' 'mail:open' 'contacts:open' 'session:recent' 'document:recent' 'commons:about' 'commons:preferences' 'document:rename' 'log:open' ]
      set is-window-opening [ get window-opening-actions indexOf, call [ get event action ], >= 0 ]
      get event minimized, true [
       get is-window-opening, true [
        set tags-row [ global document createElement, call div ]
        get tags-row classList add, call log-event-tags
        set min-tag [ global document createElement, call span ]
        get min-tag classList add, call log-event-minimized-tag
        set min-text [ global document createElement, call span ]
        set min-text textContent 'Minimized'
        get min-tag appendChild, call [ get min-text ]
        set min-remove [ global document createElement, call button ]
        get min-remove classList add, call log-event-minimized-tag-remove
        get min-remove appendChild, call [ get lib svg-icon, call /app/icons/close.svg ]
        get min-remove addEventListener, call click [
         function ev [
          get ev stopPropagation, call
          get event id, true [
           get session-service set-event-minimized, call [ get event id ] false
          ], false [
           get session-service set-event-minimized-by-index, call [ get current-index ] false
          ]
          get render-log, call
         ]
        ]
        get min-tag appendChild, call [ get min-remove ]
        get tags-row appendChild, call [ get min-tag ]
        get event-el appendChild, call [ get tags-row ]
       ]
      ]

      get content appendChild, call [ get event-el ]

      set index-ref i [ get current-index, add 1 ]
     ]
    ]
   ]

   set content scrollTop [ get saved-scroll ]
  ] ]

  # Initial render
  get render-log, call

  # Listen for log changes
  get session-service on, call logChanged [
   function [
    get render-log, call
   ]
  ]

  get log-window fill, call [ get content ]
  get main stage place-window, call [
   get log-window
  ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get log-window minimize-window, tell
   ]
  ]
 ]
]
