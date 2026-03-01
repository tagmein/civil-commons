# Main Tabs - Shows one tab per open session
# Uses tab-bar component for proper active tab highlighting
# Uses session service for session management

set main-tabs [
 get components tab-bar, call
]

# Track tab references by session ID
# Using reference pattern to avoid Crown scoping issues
set tab-map-ref [ object [ map [ object ] ] ]

# Helper to create default Untitled tab
set create-default-tab [ function [
 set tab [
  get main-tabs add, call 'Untitled' [
   function tab event [
    # No-op for placeholder tab
   ]
  ]
 ]
 get main-tabs set-active, call [ get tab ]
] ]

# Render tabs from open sessions
set render-tabs [ function [
 # Clear existing tabs first
 get main-tabs clear, call
 set tab-map-ref map [ object ]
 
 # Get session service
 set svc [ get main session-service ]
 
 # Get open session IDs - ensure we always have a list
 # Using reference pattern to avoid Crown scoping issues
 set ids-ref [ object [ ids [ list ] ] ]
 try [
  set result [ get svc get-open-session-ids, call ]
  # Only use result if it's truthy (not null/undefined)
  get result, true [
   set ids-ref ids [ get result ]
  ]
 ] [
  # Failed to get IDs - keep empty list
 ]
 
 set open-ids [ get ids-ref ids ]
 
 # Using reference pattern for current-id too
 set current-ref [ object [ id null ] ]
 try [
  set current-ref id [ get svc get-current-session-id, call ]
 ] [
  # Failed to get current ID
 ]
 set current-id [ get current-ref id ]
 
 # If no open sessions or open-ids is somehow invalid, show a default Untitled tab
 set state [ object [ has-sessions false ] ]
 try [
  get open-ids length, > 0, true [
   set state has-sessions true
  ]
 ] [
  # open-ids.length failed - not a valid list
 ]
 
 get state has-sessions, false [
  get create-default-tab, call
 ], true [
  # Fetch ALL sessions first (single API call), then build a lookup map
  set all-sessions [ list ]
  try [
   set all-sessions [ get svc fetch-all-sessions, call ]
  ] [
   # Failed to fetch - will use empty list
  ]
  
  # Build session lookup map by ID
  set session-map [ object ]
  get all-sessions, each [
   function session [
    set session-map [ get session id ] [ get session ]
   ]
  ]
  
  # Create tab for each open session
  get open-ids, each [
   function session-id [
    # Look up session name from pre-fetched data
    # Use reference object to avoid Crown scoping issues with set in conditionals
    set tab-ref [ object [ name 'Untitled' ] ]
    get session-map [ get session-id ], true [
     get session-map [ get session-id ] name, true [
      set tab-ref name [ get session-map [ get session-id ] name ]
     ]
    ]
    
    set tab [
     get main-tabs add, call [ get tab-ref name ] [
      function tab event [
       # Switch to this session
       try [
        get svc set-current-session-id, call [ get session-id ]
        set main stage content innerHTML ''
        global setTimeout, call [
         function [
          global location reload, call
         ]
        ] 125
       ] [
        # Failed to switch
       ]
      ]
     ]
    ]
    
    # Store reference for later lookup
    set tab-map-ref map [ get session-id ] [ get tab ]
    
    # Mark active tab
    get session-id, is [ get current-id ], true [
     get main-tabs set-active, call [ get tab ]
    ]
   ]
  ]
  
  # Ensure at least one tab is active
  get main-tabs get-active, call, false [
   set all-tabs [ get main-tabs get-tabs, call ]
   get all-tabs length, > 0, true [
    get main-tabs set-active, call [ get all-tabs, at 0 ]
   ]
  ]
 ]
] ]

# Update active tab styling when session changes
set update-active-tab [ function current-id [
 get tab-map-ref map [ get current-id ], true [
  get main-tabs set-active, call [ get tab-map-ref map [ get current-id ] ]
 ]
] ]

# Get session service reference
set session-service [ get main session-service ]

# Listen for session changes
get session-service on, call change [
 function current-id [
  get update-active-tab, call [ get current-id ]
 ]
]

get session-service on, call tabsChange [
 function open-ids [
  get render-tabs, call
 ]
]

# Listen for session rename events to update tab label directly
get session-service on, call sessionRenamed [
 function data [
  set found-tab [ get tab-map-ref map [ get data id ] ]
  get found-tab, true [
   get main-tabs update-label, call [ get found-tab ] [ get data name ]
  ], false [
   # Fallback: if this is the current session, update the active tab
   set current-id [ get session-service get-current-session-id, call ]
   get data id, is [ get current-id ], true [
    set active-tab [ get main-tabs get-active, call ]
    get active-tab, true [
     get main-tabs update-label, call [ get active-tab ] [ get data name ]
     # Also store it in the map for future lookups
     set tab-map-ref map [ get data id ] [ get active-tab ]
    ]
   ]
  ]
 ]
]

# Append element to body first so it's visible
global document body appendChild, call [ get main-tabs element ]

# Initialize session service (this may trigger tabsChange which re-renders tabs)
try [
 set init-result [ get session-service initialize, call ]
] [
 # Initialization failed
]

# Render tabs after initialization
# If initialize triggered tabsChange, this is redundant but safe
# If initialize failed, this ensures we have at least an Untitled tab
get render-tabs, call

get main-tabs
