get lib style-tag

tell .window [
 object [
  background-color '#222226'
  border-radius 8px
  box-shadow '0 0 4px #444448'
  display flex
  flex-direction column
  left 0
  min-height 34px
  min-width 100px
  overflow hidden
  position absolute
  top 0
 ]
]

tell .window-title-bar [
 object [
  background-color '#111114'
  border-bottom '1px solid #333337'
  cursor move
  display flex
  flex-direction row
  flex-shrink 0
  height 34px
  line-height 35px
  overflow hidden
  padding '0 10px'
  white-space nowrap
 ]
]

tell .window-title-bar-title [
 object [
  color '#e0e0d0'
  flex-grow 1
  overflow hidden
  text-overflow ellipsis
  user-select none
  white-space nowrap
 ]
]

tell .window-content [
 object [
  color '#e0e0d0'
  flex-grow 1
  overflow auto
 ]
]

tell .window.maximized [
 object [
  border-radius 0
  height 100%
  left 0
  top 0
  width 100%
 ]
]

tell .window-resize-handle [
 object [
  bottom 0
  cursor nwse-resize
  display none
  height 16px
  position absolute
  right 0
  width 16px
  z-index 10
 ]
]

tell '.window:hover .window-resize-handle' [
 object [
  display block
 ]
]

tell '.window.maximized .window-resize-handle' [
 object [
  display none
 ]
]

tell '.window-resize-handle svg' [
 object [
  color '#e0e0d0'
  height 12px
  opacity 0.6
  position absolute
  right 2px
  bottom 2px
  width 12px
 ]
]

tell '.window-resize-handle:hover svg' [
 object [
  opacity 1
 ]
]

tell .window-resize-overlay [
 object [
  background-color transparent
  cursor nwse-resize
  height 100vh
  left 0
  position fixed
  top 0
  width 100vw
  z-index 999999
 ]
]

# Virtual stage constants
set VIRTUAL_STAGE_SIZE 10000
set MIN_WINDOW_WIDTH 150
set MIN_WINDOW_HEIGHT 100

set global-window-z [
 object [
  current 0
  next [
   function [
    set global-window-z current [
     get global-window-z current, add 1
    ]
    get global-window-z current
   ]
  ]
 ]
]

# Clamp window position to virtual stage bounds (0 to 10000-size)
# Uses reference objects to avoid Crown's scoping issues with set in conditionals
set clamp-window-position [
 function x y width height [
  set max-x-raw [ get VIRTUAL_STAGE_SIZE, subtract [ get width ] ]
  set max-y-raw [ get VIRTUAL_STAGE_SIZE, subtract [ get height ] ]
  # Use ref object for max values that may need modification
  set max-ref [ object [ x [ get max-x-raw ], y [ get max-y-raw ] ] ]
  # Ensure max isn't negative
  get max-ref x, < 0, true [
   set max-ref x 0
  ]
  get max-ref y, < 0, true [
   set max-ref y 0
  ]
  # Use ref object for clamped values
  set result [ object [ x [ get x ], y [ get y ] ] ]
  get result x, < 0, true [
   set result x 0
  ]
  get result x, > [ get max-ref x ], true [
   set result x [ get max-ref x ]
  ]
  get result y, < 0, true [
   set result y 0
  ]
  get result y, > [ get max-ref y ], true [
   set result y [ get max-ref y ]
  ]
  get result
 ]
]

# Clamp window size to fit in virtual stage from current position
# Uses reference objects to avoid Crown's scoping issues with set in conditionals
set clamp-window-size [
 function x y width height [
  set max-width [ get VIRTUAL_STAGE_SIZE, subtract [ get x ] ]
  set max-height [ get VIRTUAL_STAGE_SIZE, subtract [ get y ] ]
  # Use ref object for clamped values
  set result [ object [ width [ get width ], height [ get height ] ] ]
  # Apply minimum
  get result width, < [ get MIN_WINDOW_WIDTH ], true [
   set result width [ get MIN_WINDOW_WIDTH ]
  ]
  get result height, < [ get MIN_WINDOW_HEIGHT ], true [
   set result height [ get MIN_WINDOW_HEIGHT ]
  ]
  # Apply maximum
  get result width, > [ get max-width ], true [
   set result width [ get max-width ]
  ]
  get result height, > [ get max-height ], true [
   set result height [ get max-height ]
  ]
  get result
 ]
]

function title height width [
 set component [
  object [
   element [
    global document createElement, call div
   ]
   title-bar [
    global document createElement, call div
   ]
   title-text [
    global document createElement, call div
   ]
   content [
    global document createElement, call div
   ]
   resize-handle [
    global document createElement, call div
   ]
   title
   open false
   height [
    global Math max, call [
     get height, default 300
    ] [
     value 100
    ]
   ]
   width [
    global Math max, call [
     get width, default 500
    ] [
     value 150
    ]
   ]
   maximized false
   minimized false
   is-resizing false
   is-dragging false
  ]
 ]
 get component element classList add, call window
 get component title-bar classList add, call window-title-bar
 get component title-text classList add, call window-title-bar-title
 get component content classList add, call window-content
 get component resize-handle classList add, call window-resize-handle
 set component title-text textContent [ get title, default 'Untitled' ]
 get component title-bar appendChild, tell [ get component title-text ]
 set toggle-maximize [
  function [
   get component maximized, true [
    get component element classList remove, call maximized
    set component maximized false
    set component title-buttons maximize-button style display flex
    set component title-buttons restore-button style display none
    get component position, true [
     get component stage, true [
      get component stage apply-window-transform, call [ get component ]
     ], false [
      set component element style transform [
       template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ]
      ]
     ]
    ]
    set component element style width [
     template %0px [ get component width ]
    ]
    set component element style height [
     template %0px [ get component height ]
    ]
    get raise-window, tell
   ], false [
    get component element classList add, call maximized
    set component maximized true
    set component title-buttons maximize-button style display none
    set component title-buttons restore-button style display flex
    set component element style transform ''
    set component element style width ''
    set component element style height ''
    set component element style z-index 2000
   ]
   get component stage, true [
    get component stage minimap, true [
     get component stage minimap update-window, call [ get component ]
    ]
   ]
  ]
 ]
 set close-window [
  function [
   get component element parentNode, true [
    get component element parentNode removeChild, call [ get component element ]
   ]
   get component status-item, true [
    get component status-bar remove, call [ get component status-item ]
   ]
   unset component status-item
   unset component status-item-element
   get component stage, true [
    set component stage windows [
     get component stage windows, filter [
      function w [
       get w, is [ get component ], not
      ]
     ]
    ]
    get component stage minimap, true [
     get component stage minimap remove-window, call [ get component ]
    ]
   ]
  ]
 ]
 set minimize-window [
  function [
   get component status-bar, true [
    get component element parentNode, true [
     get component element parentNode removeChild, call [ get component element ]
    ]
    set component minimized true
    set status-item [
     get component status-bar add, call [ get component title ] [ get restore-window ]
    ]
    set component status-item [ get status-item ]
    set component status-item-element [ get status-item element ]
    get component stage, true [
     get component stage minimap, true [
      get component stage minimap remove-window, call [ get component ]
     ]
    ]
   ]
  ]
 ]
 set restore-window [
  function [
   get component minimized, true [
    get component status-item, true [
     get component status-bar remove, call [ get component status-item ]
    ]
    set component minimized false
    unset component status-item
    unset component status-item-element
    get component stage, true [
     get component stage content appendChild, tell [
      get component element
     ]
     get component maximized, true [
      # Restore as maximized - clear transform/size, ensure maximized class and buttons
      set component element style transform ''
      set component element style width ''
      set component element style height ''
      set component element style z-index 2000
      get component element classList add, call maximized
      set component title-buttons maximize-button style display none
      set component title-buttons restore-button style display flex
     ], false [
      # Restore as normal window with position and size
      get component stage apply-window-transform, call [ get component ]
      set component element style width [
       template %0px [ get component width ]
      ]
      set component element style height [
       template %0px [ get component height ]
      ]
     ]
     get component stage minimap, true [
      get component stage minimap add-window, call [ get component ]
     ]
    ]
   ]
  ]
 ]
 set component title-buttons [
  get components window-title-buttons, call [
   function [
    get minimize-window, tell
   ]
  ] [
   function [
    # maximize
    get toggle-maximize, tell
   ]
  ] [
   function [
    # restore
    get toggle-maximize, tell
   ]
  ] [
   function [
    # close
    get close-window, tell
   ]
  ]
 ]
 get component title-bar appendChild, tell [ get component title-buttons element ]
 get component resize-handle appendChild, tell [
  get lib svg-icon, call /app/icons/resize.svg
 ]
 get component element appendChild, tell [ get component title-bar ]
 get component element appendChild, tell [ get component content ]
 get component element appendChild, tell [ get component resize-handle ]
 set raise-window [
  function [
   set z-index-value [
    get global-window-z next, call
   ]
   set component z-index [ get z-index-value ]
   set component element style z-index [ get z-index-value ]
   get component minimap-element, true [
    set component minimap-element style z-index [ get z-index-value ]
   ]
  ]
 ]
 get component element addEventListener, tell click [
  get raise-window
 ]
 # Store drag handler first to avoid parsing issues with inline multi-arg call
 set start-drag [
  get lib drag-handler create, call [ get component ] [
   function event component [
    set return-ref [ object [ value null ] ]
    get component maximized, false [
     set component is-dragging true
     get raise-window, tell
     get component position, false [
      set component position [ object [ x 0, y 0 ] ]
     ]
     set return-ref value [ object [ startX [ get component position x ], startY [ get component position y ] ] ]
    ]
    get return-ref value
   ]
  ] [
   function event startX startY state component deltaX deltaY [
    get state, true [
     get component is-dragging, true [
      set newX [ get state startX, add [ get deltaX ] ]
      set newY [ get state startY, add [ get deltaY ] ]
      set clamped [ get clamp-window-position, call [ get newX ] [ get newY ] [ get component width ] [ get component height ] ]
      set component position [ object [ x [ get clamped x ], y [ get clamped y ] ] ]
      get component stage, true [
       get component stage apply-window-transform, call [ get component ]
       get component stage minimap, true [
        get component stage minimap update-window, call [ get component ]
       ]
      ], false [
       set component element style transform [ template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ] ]
      ]
     ]
    ]
   ]
  ] [
   function state component [
    get state, true [
     set component is-dragging false
    ]
   ]
  ]
 ]
 get component title-bar addEventListener, tell mousedown [
  get start-drag
 ]
 # Store resize handler first to avoid parsing issues with inline multi-arg call
 set start-resize [
  get lib drag-handler create, call [ get component ] [
   function event component [
    set component is-resizing true
    set overlay [ global document createElement, call div ]
    get overlay classList add, call window-resize-overlay
    global document body appendChild, tell [ get overlay ]
    object [ startWidth [ get component width ], startHeight [ get component height ], overlay [ get overlay ] ]
   ]
  ] [
   function event startX startY state component deltaX deltaY [
    get component is-resizing, true [
     set newWidth [ get state startWidth, add [ get deltaX ] ]
     set newHeight [ get state startHeight, add [ get deltaY ] ]
     set posRef [ object [ x 0, y 0 ] ]
     get component position, true [
      set posRef x [ get component position x ]
      set posRef y [ get component position y ]
     ]
     set clamped [ get clamp-window-size, call [ get posRef x ] [ get posRef y ] [ get newWidth ] [ get newHeight ] ]
     set component width [ get clamped width ]
     set component height [ get clamped height ]
     get component maximized, false [
      set component element style width [ template %0px [ get component width ] ]
      set component element style height [ template %0px [ get component height ] ]
     ]
     get component stage, true [
      get component stage minimap, true [
       get component stage minimap update-window, call [ get component ]
      ]
     ]
    ]
   ]
  ] [
   function state component [
    set component is-resizing false
    get state overlay parentNode, true [
     get state overlay parentNode removeChild, call [ get state overlay ]
    ]
   ]
  ]
 ]
 get component resize-handle addEventListener, tell mousedown [
  get start-resize
 ]
 get raise-window, tell
 set component element style width [
  template %0px [ get component width ]
 ]
 set component element style height [
  template %0px [ get component height ]
 ]
 set component fill [
  function content-element [
   get component content appendChild, call [ get content-element ]
  ]
 ]
 get component
]
