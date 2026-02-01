get lib style-tag

# Minimap size and virtual stage constants
set MINIMAP_SIZE 200
set VIRTUAL_STAGE_SIZE 10000

tell .minimap [
 object [
  background-color '#1a1a1e'
  border '3px solid #c0c0c0'
  border-radius 2px
  bottom 20px
  height 200px
  pointer-events none
  position absolute
  right 20px
  width 200px
  z-index 1000
 ]
]

tell .minimap-content [
 object [
  height 100%
  overflow hidden
  pointer-events auto
  position relative
  width 100%
 ]
]

tell .minimap-window [
 object [
  background-color '#333337'
  border '1px solid #555559'
  cursor move
  position absolute
 ]
]

tell .minimap-viewport [
 object [
  background-color '#0066ff40'
  border '1px solid #0066ff'
  position absolute
  cursor move
 ]
]

function stage [
 # Calculate fixed scale: minimap-size / virtual-stage-size
 set scale [ get MINIMAP_SIZE, divide [ get VIRTUAL_STAGE_SIZE ] ]
 
 set component [
  object [
   element [
    global document createElement, call div
   ]
   content [
    global document createElement, call div
   ]
   viewport [
    global document createElement, call div
   ]
   stage [ get stage ]
   windows [ list ]
   # Fixed scale for minimap
   scale [ get scale ]
   minimapSize [ get MINIMAP_SIZE ]
   virtualStageSize [ get VIRTUAL_STAGE_SIZE ]
   is-dragging-viewport false
   is-dragging-window false
  ]
 ]
 get component element classList add, call minimap
 get component content classList add, call minimap-content
 get component viewport classList add, call minimap-viewport
 get component content appendChild, tell [ get component viewport ]
 get component element appendChild, tell [ get component content ]

 # Convert stage coordinates to minimap coordinates
 set stage-to-minimap [
  function stage-x stage-y [
   object [ x [ get stage-x, multiply [ get component scale ] ], y [ get stage-y, multiply [ get component scale ] ] ]
  ]
 ]
 
 # Convert minimap coordinates to stage coordinates
 set minimap-to-stage [
  function minimap-x minimap-y [
   object [ x [ get minimap-x, divide [ get component scale ] ], y [ get minimap-y, divide [ get component scale ] ] ]
  ]
 ]
 
 # Scale dimensions for minimap
 set scale-dimensions [
  function width height [
   object [ width [ get width, multiply [ get component scale ] ], height [ get height, multiply [ get component scale ] ] ]
  ]
 ]

 # Update viewport display
 set update-viewport [
  function [
   get component stage, true [
    # Get viewport position and size from stage
    set viewport-x [ get component stage viewportX ]
    set viewport-y [ get component stage viewportY ]
    set viewport-width [ get component stage viewportWidth ]
    set viewport-height [ get component stage viewportHeight ]
    
    # Convert to minimap coordinates
    set minimap-pos [ get stage-to-minimap, call [ get viewport-x ] [ get viewport-y ] ]
    set minimap-size [ get scale-dimensions, call [ get viewport-width ] [ get viewport-height ] ]
    
    # Update viewport element
    set component viewport style left [ template %0px [ get minimap-pos x ] ]
    set component viewport style top [ template %0px [ get minimap-pos y ] ]
    set component viewport style width [ template %0px [ get minimap-size width ] ]
    set component viewport style height [ template %0px [ get minimap-size height ] ]
   ]
  ]
 ]
 
 # Update all window positions on minimap
 set update-display [
  function [
   get component stage, true [
    get component stage windows, each [
     function window [
      get window maximized, false [
       get window minimap-element, true [
        get window position, true [
         # Convert window position to minimap coordinates
         set minimap-pos [ get stage-to-minimap, call [ get window position x ] [ get window position y ] ]
         set minimap-size [ get scale-dimensions, call [ get window width ] [ get window height ] ]
         
         set window minimap-element style left [ template %0px [ get minimap-pos x ] ]
         set window minimap-element style top [ template %0px [ get minimap-pos y ] ]
         set window minimap-element style width [ template %0px [ get minimap-size width ] ]
         set window minimap-element style height [ template %0px [ get minimap-size height ] ]
        ]
       ]
      ]
     ]
    ]
   ]
   get update-viewport, call
  ]
 ]

 # Add window to minimap
 set add-window [
  function window [     
   set minimap-window-element [
    global document createElement, call div
   ]
   get minimap-window-element classList add, call minimap-window
   get component content appendChild, tell [ get minimap-window-element ]
   get component windows push, tell [ get window ]
   set window minimap-element [ get minimap-window-element ]
   get window z-index, true [
    set minimap-window-element style z-index [ get window z-index ]
   ]
   
   # Window drag handler for minimap - store first then attach
   set start-window-drag [
    get lib drag-handler create, call [ get component ] [
     function event component [
      set component is-dragging-window true
      set component dragged-window [ get window ]
      set ref [ object [ value null ] ]
      get window position, true [
       set ref value [ object [ win [ get window ], startX [ get window position x ], startY [ get window position y ] ] ]
      ], false [
       set ref value [ object [ win [ get window ], startX 0, startY 0 ] ]
      ]
      get ref value
     ]
    ] [
     function event startX startY state component deltaX deltaY [
      get state, true [
       set win [ get state win ]
       get component is-dragging-window, true [
        get win maximized, false [
         set stageDeltaX [ get deltaX, divide [ get component scale ] ]
         set stageDeltaY [ get deltaY, divide [ get component scale ] ]
         set newX [ get state startX, add [ get stageDeltaX ] ]
         set newY [ get state startY, add [ get stageDeltaY ] ]
         set maxXRaw [ get VIRTUAL_STAGE_SIZE, subtract [ get win width ] ]
         set maxYRaw [ get VIRTUAL_STAGE_SIZE, subtract [ get win height ] ]
         set maxRef [ object [ x [ get maxXRaw ], y [ get maxYRaw ] ] ]
         get maxRef x, < 0, true [ set maxRef x 0 ]
         get maxRef y, < 0, true [ set maxRef y 0 ]
         set result [ object [ x [ get newX ], y [ get newY ] ] ]
         get result x, < 0, true [ set result x 0 ]
         get result x, > [ get maxRef x ], true [ set result x [ get maxRef x ] ]
         get result y, < 0, true [ set result y 0 ]
         get result y, > [ get maxRef y ], true [ set result y [ get maxRef y ] ]
         set win position [ object [ x [ get result x ], y [ get result y ] ] ]
         get component stage, true [
          get component stage apply-window-transform, call [ get win ]
         ]
         get update-display, call
        ]
       ]
      ]
     ]
    ] [
     function state component [
      get state, true [
       set component is-dragging-window false
       unset component dragged-window
      ]
     ]
    ]
   ]
   get minimap-window-element addEventListener, tell mousedown [
    get start-window-drag
   ]
   get update-display, call
  ]
 ]

 # Remove window from minimap
 set remove-window [
  function window [
   get window minimap-element, true [
    get window minimap-element parentNode, true [
     get window minimap-element parentNode removeChild, call [ get window minimap-element ]
    ]
   ]
   set component windows [
    get component windows filter, call [
     function x [
      get x, is [ get window ], not
     ]
    ]
   ]
   unset window minimap-element
   get update-display, call
  ]
 ]

 # Update window (called when window moves/resizes on stage)
 set update-window [
  function window [
   get update-display, call
  ]
 ]

 # Viewport drag handler - store first then attach
 set start-viewport-drag [
  get lib drag-handler create, call [ get component ] [
   function event component [
    set component is-dragging-viewport true
    set component is-dragging-window false
    unset component dragged-window
    # Use ref pattern to ensure state object is returned from function
    set drag-state [ object [ startX 0, startY 0 ] ]
    get component stage, true [
     set drag-state startX [ get component stage viewportX ]
     set drag-state startY [ get component stage viewportY ]
    ]
    get drag-state
   ]
  ] [
   function event startX startY state component deltaX deltaY [
    get component is-dragging-viewport, true [
     set stageDeltaX [ get deltaX, divide [ get component scale ] ]
     set stageDeltaY [ get deltaY, divide [ get component scale ] ]
     set newX [ get state startX, add [ get stageDeltaX ] ]
     set newY [ get state startY, add [ get stageDeltaY ] ]
     get component stage, true [
      get component stage set-viewport-position, call [ get newX ] [ get newY ]
     ]
    ]
   ]
  ] [
   function state component [
    set component is-dragging-viewport false
   ]
  ]
 ]
 get component viewport addEventListener, tell mousedown [
  get start-viewport-drag
 ]

 # Export functions
 set component add-window [ get add-window ]
 set component remove-window [ get remove-window ]
 set component update-window [ get update-window ]
 set component update-display [ get update-display ]
 set component update-viewport [ get update-viewport ]

 # Initial update
 global setTimeout, call [
  function [
   get update-display, call
  ]
 ]

 get component
]
