# Tab Bar Component
# A reusable tab bar with active state highlighting
# Used for main session tabs and within windows like Recent Sessions

get lib style-tag

tell .tab-bar [
 object [
  display flex
  background-color '#222226'
  border-bottom '1px solid #444448'
  flex-shrink 0
  min-height 34px
 ]
]

tell '.tab-bar-tab' [
 object [
  align-items center
  background-color transparent
  border none
  border-bottom '2px solid transparent'
  color '#808080'
  cursor pointer
  display flex
  font-size 14px
  padding '0 16px'
  transition 'color 0.15s, border-color 0.15s'
  white-space nowrap
 ]
]

tell '.tab-bar-tab:hover' [
 object [
  color '#e0e0d0'
 ]
]

tell '.tab-bar-tab.active' [
 object [
  border-bottom-color '#4a9eff'
  color '#e0e0d0'
 ]
]

# Component factory function
# Returns: { element, add, remove, set-active, get-active, clear }
function [
 set tabs [ list ]
 # Use a reference object to avoid Crown scoping issues with set in closures
 set state [ object [ active-tab null ] ]
 
 set component [ object ]
 
 set component element [
  global document createElement, call div
 ]
 get component element classList add, call tab-bar
 
 # Add a new tab
 # label: string - the tab label
 # on-click: function(tab) - called when tab is clicked
 # Returns: { element, id, label }
 set component add [ function label on-click [
  set tab-element [
   global document createElement, call button
  ]
  get tab-element classList add, call tab-bar-tab
  set tab-element textContent [ get label ]
  
  set tab [
   object [
    element [ get tab-element ]
    id [ get tabs length ]
    label [ get label ]
   ]
  ]
  
  get tab-element addEventListener, call click [
   function event [
    # Set this tab as active
    get component set-active, call [ get tab ]
    
    # Call the click handler
    get on-click, true [
     get on-click, call [ get tab ] [ get event ]
    ]
   ]
  ]
  
  get tabs push, call [ get tab ]
  get component element appendChild, call [ get tab-element ]
  
  get tab
 ] ]
 
 # Remove a tab
 set component remove [ function tab [
  set idx [ get tabs indexOf, call [ get tab ] ]
  get idx, >= 0, true [
   get tabs splice, call [ get idx ] 1
   get component element removeChild, call [ get tab element ]
   
   # If removing active tab, clear active state
   get state active-tab, is [ get tab ], true [
    set state active-tab null
   ]
  ]
 ] ]
 
 # Set a tab as active
 set component set-active [ function tab [
  # Remove active class from current active tab
  get state active-tab, true [
   get state active-tab element classList remove, call active
  ]
  
  # Set new active tab
  set state active-tab [ get tab ]
  
  get tab, true [
   get tab element classList add, call active
  ]
 ] ]
 
 # Get the currently active tab
 set component get-active [ function [
  get state active-tab
 ] ]
 
 # Update a tab's label
 set component update-label [ function tab new-label [
  set tab element textContent [ get new-label ]
  set tab label [ get new-label ]
 ] ]
 
 # Clear all tabs
 set component clear [ function [
  set component element innerHTML ''
  set tabs [ list ]
  set state active-tab null
 ] ]
 
 # Get all tabs
 set component get-tabs [ function [
  get tabs
 ] ]
 
 # Find tab by id
 set component find-by-id [ function id [
  set found null
  get tabs, each [
   function tab [
    get tab id, is [ get id ], true [
     set found [ get tab ]
    ]
   ]
  ]
  get found
 ] ]
 
 get component
]
