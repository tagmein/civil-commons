# Session Archive Confirmation Window
# Opens a window asking if user wants to archive the current session

get lib style-tag

tell '.archive-confirm' [
 object [
  padding 20px
  text-align center
 ]
]

tell '.archive-confirm p' [
 object [
  color '#e0e0d0'
  font-size 14px
  line-height 1.6
  margin '0 0 20px 0'
 ]
]

tell '.archive-confirm .session-name' [
 object [
  color '#4a9eff'
  font-weight bold
 ]
]

tell '.archive-confirm-buttons' [
 object [
  display flex
  gap 10px
  justify-content center
 ]
]

tell '.archive-confirm button' [
 object [
  background-color '#444448'
  border none
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 14px
  padding '8px 20px'
 ]
]

tell '.archive-confirm button:hover' [
 object [
  background-color '#555558'
 ]
]

tell '.archive-confirm button.danger' [
 object [
  background-color '#cc4444'
  color '#ffffff'
 ]
]

tell '.archive-confirm button.danger:hover' [
 object [
  background-color '#dd5555'
 ]
]

get conductor register, call session:archive [
 function [
  set session-service [ get main session-service ]
  set current-id [ get session-service get-current-session-id, call ]
  
  get current-id, false [
   log No current session to archive
   value undefined
  ]
  
  # Fetch current session info
  set session [ get session-service fetch-session, call [ get current-id ] ]
  
  set archive-window [
   get components window, call 'Archive Session' 180 350
  ]
  
  # Create confirmation content
  set content [
   global document createElement, call div
  ]
  get content classList add, call archive-confirm
  
  set message [
   global document createElement, call p
  ]
  set message innerHTML [
   template 'Are you sure you want to archive the session <span class="session-name">%0</span>?<br><br>The session will be removed from your tabs but can be reopened later from Recent.' [ get session name ]
  ]
  get content appendChild, call [ get message ]
  
  set buttons [
   global document createElement, call div
  ]
  get buttons classList add, call archive-confirm-buttons
  
  set cancel-btn [
   global document createElement, call button
  ]
  set cancel-btn textContent 'Cancel'
  get cancel-btn addEventListener, call click [
   function [
    # Close window properly (removes from minimap too)
    get archive-window close, call
   ]
  ]
  get buttons appendChild, call [ get cancel-btn ]
  
  set archive-btn [
   global document createElement, call button
  ]
  set archive-btn textContent 'Archive'
  get archive-btn classList add, call danger
  get archive-btn addEventListener, call click [
   function [
    # Archive via API
    get session-service archive-session, call [ get current-id ]
    
    # If no more sessions, create a new one
    set open-ids [ get session-service get-open-session-ids, call ]
    get open-ids length, = 0, true [
     get session-service create-session, call
    ]
    
    # Close window properly (removes from minimap too)
    get archive-window close, call
   ]
  ]
  get buttons appendChild, call [ get archive-btn ]
  
  get content appendChild, call [ get buttons ]
  
  get archive-window fill, call [ get content ]
  get main stage place-window, call [
   get archive-window
  ] [ get main status ]
 ]
]
