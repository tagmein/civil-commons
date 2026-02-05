# Recent Documents Window
# Shows Active and Archived documents in a tabbed interface

get lib style-tag

tell '.recent-documents' [
 object [
  display flex
  flex-direction column
  height '100%'
 ]
]

tell '.recent-documents .tab-bar' [
 object [
  background-color transparent
 ]
]

tell '.recent-doc-list' [
 object [
  flex-grow 1
  overflow-y auto
  padding 10px
 ]
]

tell '.recent-doc-item' [
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

tell '.recent-doc-item:hover' [
 object [
  background-color '#444448'
 ]
]

tell '.recent-doc-item-name' [
 object [
  color '#e0e0d0'
  flex-grow 1
  font-size 14px
 ]
]

tell '.recent-doc-item-date' [
 object [
  color '#808080'
  font-size 12px
  margin-right 10px
 ]
]

tell '.recent-doc-item-btn' [
 object [
  border none
  border-radius 4px
  cursor pointer
  font-size 12px
  padding '4px 12px'
  margin-left 6px
 ]
]

tell '.recent-doc-item-open' [
 object [
  background-color '#4a9eff'
  color '#ffffff'
 ]
]

tell '.recent-doc-item-open:hover' [
 object [
  background-color '#5aafff'
 ]
]

tell '.recent-doc-item-archive' [
 object [
  background-color '#666668'
  color '#e0e0d0'
 ]
]

tell '.recent-doc-item-archive:hover' [
 object [
  background-color '#777778'
 ]
]

tell '.recent-doc-item-restore' [
 object [
  background-color '#44aa44'
  color '#ffffff'
 ]
]

tell '.recent-doc-item-restore:hover' [
 object [
  background-color '#55bb55'
 ]
]

tell '.recent-doc-empty' [
 object [
  color '#808080'
  font-size 14px
  padding 20px
  text-align center
 ]
]

get conductor register, call document:recent [
 function [
  set doc-service [ get main document-service ]
  
  set recent-window [
   get components window, call 'Recent Documents' 400 450
  ]
  
  # Fetch all documents for current session
  set all-documents [ get doc-service fetch-all-documents, call ]
  
  # Separate active and archived
  set active-documents [ list ]
  set archived-documents [ list ]
  
  get all-documents, each [
   function doc [
    get doc archived, true [
     get archived-documents push, call [ get doc ]
    ], false [
     get active-documents push, call [ get doc ]
    ]
   ]
  ]
  
  # Create container
  set container [
   global document createElement, call div
  ]
  get container classList add, call recent-documents
  
  # Create tabs using tab-bar component
  set tabs [ get components tab-bar, call ]
  
  set active-tab [
   get tabs add, call [ template 'Active (%0)' [ get active-documents length ] ] [
    function tab event [
     get render-list, call [ get active-documents ] [ value false ]
    ]
   ]
  ]
  
  set archived-tab [
   get tabs add, call [ template 'Archived (%0)' [ get archived-documents length ] ] [
    function tab event [
     get render-list, call [ get archived-documents ] [ value true ]
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
  get list-container classList add, call recent-doc-list
  get container appendChild, call [ get list-container ]
  
  # Format date helper
  set format-date [ function timestamp [
   global Date, new [ get timestamp ]
   at toLocaleDateString, call
  ] ]
  
  # Render document list
  # show-archived = true means showing archived documents tab
  set render-list [ function documents show-archived [
   set list-container innerHTML ''
   
   get documents length, = 0, true [
    set empty [
     global document createElement, call div
    ]
    get empty classList add, call recent-doc-empty
    set empty textContent [
     get show-archived, true [
      value 'No archived documents'
     ], false [
      value 'No active documents'
     ]
    ]
    get list-container appendChild, call [ get empty ]
   ], false [
    get documents, each [
     function doc [
      set item [
       global document createElement, call div
      ]
      get item classList add, call recent-doc-item
      
      set name [
       global document createElement, call span
      ]
      get name classList add, call recent-doc-item-name
      set name textContent [ get doc name, default 'Untitled Document' ]
      get item appendChild, call [ get name ]
      
      set date [
       global document createElement, call span
      ]
      get date classList add, call recent-doc-item-date
      set date textContent [ get format-date, call [ get doc createdAt ] ]
      get item appendChild, call [ get date ]
      
      # Open button
      set open-btn [
       global document createElement, call button
      ]
      get open-btn classList add, call recent-doc-item-btn
      get open-btn classList add, call recent-doc-item-open
      set open-btn textContent 'Open'
      get open-btn addEventListener, call click [
       function event [
        get event stopPropagation, call
        
        # If archived, restore first
        get show-archived, true [
         get doc-service restore-document, call [ get doc id ]
        ]
        
        # Open the document
        get conductor dispatch, call document:open [ get doc id ]
        
        # Close window properly
        get recent-window close, call
       ]
      ]
      get item appendChild, call [ get open-btn ]
      
      # Archive button for active documents
      get show-archived, false [
       set archive-btn [
        global document createElement, call button
       ]
       get archive-btn classList add, call recent-doc-item-btn
       get archive-btn classList add, call recent-doc-item-archive
       set archive-btn textContent 'Archive'
       get archive-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         
         # Archive the document
         get doc-service archive-document, call [ get doc id ]
         
         # Remove from active list and add to archived
         set idx [ get active-documents indexOf, call [ get doc ] ]
         get idx, >= 0, true [
          get active-documents splice, call [ get idx ] 1
         ]
         set doc archived true
         get archived-documents push, call [ get doc ]
         
         # Update tab counts
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-documents length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-documents length ] ]
         
         # Re-render current list
         get render-list, call [ get active-documents ] [ value false ]
        ]
       ]
       get item appendChild, call [ get archive-btn ]
      ]
      
      # Restore button for archived documents
      get show-archived, true [
       set restore-btn [
        global document createElement, call button
       ]
       get restore-btn classList add, call recent-doc-item-btn
       get restore-btn classList add, call recent-doc-item-restore
       set restore-btn textContent 'Restore'
       get restore-btn addEventListener, call click [
        function event [
         get event stopPropagation, call
         
         # Restore the document
         get doc-service restore-document, call [ get doc id ]
         
         # Remove from archived list and add to active
         set idx [ get archived-documents indexOf, call [ get doc ] ]
         get idx, >= 0, true [
          get archived-documents splice, call [ get idx ] 1
         ]
         set doc archived false
         get active-documents push, call [ get doc ]
         
         # Update tab counts
         get tabs update-label, call [ get active-tab ] [ template 'Active (%0)' [ get active-documents length ] ]
         get tabs update-label, call [ get archived-tab ] [ template 'Archived (%0)' [ get archived-documents length ] ]
         
         # Re-render current list
         get render-list, call [ get archived-documents ] [ value true ]
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
  get render-list, call [ get active-documents ] [ value false ]
  
  get recent-window fill, call [ get container ]
  get main stage place-window, call [
   get recent-window
  ] [ get main status ]
 ]
]
