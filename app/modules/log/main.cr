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
  align-items center
  justify-content space-between
  padding '8px 12px'
  margin-bottom 8px
  background-color '#333337'
  border-radius 4px
  border-left '3px solid #4a9eff'
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

tell '.log-event-delete' [
 object [
  background-color '#aa4444'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 12px
  padding '4px 8px'
  margin-left 12px
  flex-shrink 0
 ]
]

tell '.log-event-delete:hover' [
 object [
  background-color '#cc5555'
 ]
]

get conductor register, call log:open [
 function [
  set session-service [ get main session-service ]
  
  set log-window [
   get components window, call 'Event Log' 400 500
  ]
  
  # Create content container
  set content [
   global document createElement, call div
  ]
  get content classList add, call log-content
  
  # Function to render the log
  set render-log [ function [
   # Clear content
   set content innerHTML ''
   
   # Get event log
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
      
      get content appendChild, call [ get event-el ]
      
      set index-ref i [ get current-index, add 1 ]
     ]
    ]
   ]
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
 ]
]
