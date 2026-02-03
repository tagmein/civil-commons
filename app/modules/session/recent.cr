# Recent Sessions Window
# Shows Active and Archived sessions in a tabbed interface

get lib style-tag

tell '.recent-sessions' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.recent-sessions .tab-bar' [
 object [
  background-color transparent
 ]
]

tell '.recent-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.recent-item' [
 object [
  align-items center
  background-color '#333337'
  border-radius 4px
  cursor pointer
  display flex
  margin-bottom 8px
  padding '10px 15px'
 ]
]

tell '.recent-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.recent-item-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.recent-item-date' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.recent-item-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.recent-item-open' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.recent-item-open:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.recent-item-archive' [
 object [
  background-color '#666668'
  color '#e0e0d0'
 ]
]

tell '.recent-item-archive:hover' [
 object [
  background-color '#777778'
 ]
]

tell '.recent-item-restore' [
 object [
  background-color '#44aa44'
  color '#ffffff'
 ]
]

tell '.recent-item-restore:hover' [
 object [
  background-color '#55bb55'
 ]
]

tell '.recent-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

get conductor register, call session:recent [
 function [
  set session-service [ get main session-service ]
  set open-ids [ get session-service get-open-session-ids, call ]
  
  set recent-window [
   get components window, call 'Recent Sessions' 400 450
  ]
  
  # Fetch all sessions
  set all-sessions [ get session-service fetch-all-sessions, call ]
  
  # Separate active and archived
  set active-sessions [ list ]
  set archived-sessions [ list ]
  
  get all-sessions, each [
   function session [
    get session archived, true [
     get archived-sessions push, call [ get session ]
    ], false [
     get active-sessions push, call [ get session ]
    ]
   ]
  ]
  
  # Create container
  set container [
   global document createElement, call div
  ]
  get container classList add, call recent-sessions
  
  # Create tabs using tab-bar component
  set tabs [ get components tab-bar, call ]
  
  set active-tab [
   get tabs add, call [ template 'Active (%0)' [ get active-sessions length ] ] [
    function tab event [
     get render-list, call [ get active-sessions ] [ value false ]
    ]
   ]
  ]
  
  set archived-tab [
   get tabs add, call [ template 'Archived (%0)' [ get archived-sessions length ] ] [
    function tab event [
     get render-list, call [ get archived-sessions ] [ value true ]
    ]
   ]
  ]
  
  # Set active tab as initially selected
  get tabs set-active, call [ get active-tab ]
  
  get container appendChild, call [ get tabs element ]
  
  # Create list container
  set list-container [
   global document createElement, call div
  ]
  get list-container classList add, call recent-list
  get container appendChild, call [ get list-container ]
  
  # Format date helper
  set format-date [ function timestamp [
   global Date, new [ get timestamp ]
   at toLocaleDateString, call
  ] ]
  
  # Render session list
  # show-archived = true means showing archived sessions tab
  set render-list [ function sessions show-archived [
   set list-container innerHTML ''
   
   get sessions length, = 0, true [
    set empty [
     global document createElement, call div
    ]
    get empty classList add, call recent-empty
    set empty textContent [
     get show-archived, true [
      value 'No archived sessions'
     ], false [
      value 'No active sessions'
     ]
    ]
    get list-container appendChild, call [ get empty ]
   ], false [
    get sessions, each [
     function session [
      set item [
       global document createElement, call div
      ]
      get item classList add, call recent-item
      
      set name [
       global document createElement, call span
      ]
      get name classList add, call recent-item-name
      set name textContent [ get session name, default 'Untitled' ]
      get item appendChild, call [ get name ]
      
      set date [
       global document createElement, call span
      ]
      get date classList add, call recent-item-date
      set date textContent [ get format-date, call [ get session createdAt ] ]
      get item appendChild, call [ get date ]
      
      # Open button
      set open-btn [
       global document createElement, call button
      ]
      get open-btn classList add, call recent-item-btn
      get open-btn classList add, call recent-item-open
      set open-btn textContent 'Open'
      get open-btn addEventListener, call click [
       function event [
        get event stopPropagation, call
        
        # If archived, unarchive first
        get show-archived, true [
         global fetch, call [ template '/api/sessions/%0' [ get session id ] ] [
          object [
           method 'PATCH'
           headers [ object [ Content-Type 'application/json' ] ]
           body [ global JSON stringify, call [ object [ archived false ] ] ]
          ]
         ]
        ]
        
        # Open the session
        get session-service open-session, call [ get session id ]
        
        # Close window properly (removes from minimap too)
        get recent-window close, call
       ]
      ]
      get item appendChild, call [ get open-btn ]
      
      # Archive button for active sessions
      get show-archived, false [
       set archive-btn [
        global document createElement, call button
       ]
       get archive-btn classList add, call recent-item-btn
       get archive-btn classList add, call recent-item-archive
       set archive-btn textContent 'Archive'
       get archive-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         
         # Archive the session via API
         global fetch, call [ template '/api/sessions/%0' [ get session id ] ] [
          object [
           method 'PATCH'
           headers [ object [ Content-Type 'application/json' ] ]
           body [ global JSON stringify, call [ object [ archived true ] ] ]
          ]
         ]
         
         # Remove from active list and add to archived
         set idx [ get active-sessions indexOf, call [ get session ] ]
         get idx, >= 0, true [
          get active-sessions splice, call [ get idx ] 1
         ]
         set session archived true
         get archived-sessions push, call [ get session ]
         
         # Update tab counts using tab-bar update-label
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-sessions length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-sessions length ] ]
         
         # Re-render current list
         get render-list, call [ get active-sessions ] [ value false ]
        ]
       ]
       get item appendChild, call [ get archive-btn ]
      ]
      
      # Restore button for archived sessions
      get show-archived, true [
       set restore-btn [
        global document createElement, call button
       ]
       get restore-btn classList add, call recent-item-btn
       get restore-btn classList add, call recent-item-restore
       set restore-btn textContent 'Restore'
       get restore-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         
         # Unarchive the session via API
         global fetch, call [ template '/api/sessions/%0' [ get session id ] ] [
          object [
           method 'PATCH'
           headers [ object [ Content-Type 'application/json' ] ]
           body [ global JSON stringify, call [ object [ archived false ] ] ]
          ]
         ]
         
         # Remove from archived list and add to active
         set idx [ get archived-sessions indexOf, call [ get session ] ]
         get idx, >= 0, true [
          get archived-sessions splice, call [ get idx ] 1
         ]
         set session archived false
         get active-sessions push, call [ get session ]
         
         # Update tab counts using tab-bar update-label
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-sessions length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-sessions length ] ]
         
         # Re-render current list
         get render-list, call [ get archived-sessions ] [ value true ]
        ]
       ]
       get item appendChild, call [ get restore-btn ]
      ]
      
      get list-container appendChild, call [ get item ]
     ]
    ]
   ]
  ] ]
  
  # Initial render - show active
  get render-list, call [ get active-sessions ] [ value false ]
  
  # Tab click handlers are now handled by the tab-bar component
  
  get recent-window fill, call [ get container ]
  get main stage place-window, call [
   get recent-window
  ] [ get main status ]
 ]
]
