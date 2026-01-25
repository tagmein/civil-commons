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
     set [ get component ] element style transform [
      template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ]
     ]
    ]
    set [ get component ] element style width [
     template %0px [ get component width ]
    ]
    set [ get component ] element style height [
     template %0px [ get component height ]
    ]
    get raise-window, tell
   ], false [
    get component element classList add, call maximized
    set component maximized true
    set component title-buttons maximize-button style display none
    set component title-buttons restore-button style display flex
    set [ get component ] element style transform ''
    set [ get component ] element style width ''
    set [ get component ] element style height ''
    set [ get component ] element style z-index 2000
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
    get component stage minimap, true [
     get component stage minimap remove-window, call [ get component ]
    ]
    set component stage windows [
     get component stage windows, filter [
      function w [
       get w, is [ get component ], false
      ]
     ]
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
     get component position, true [
      set [ get component ] element style transform [
       template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ]
      ]
     ]
     get component maximized, false [
      set [ get component ] element style width [
       template %0px [ get component width ]
      ]
      set [ get component ] element style height [
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
   set [ get component ] element style z-index [
    get global-window-z next, call
   ]
  ]
 ]
 get component element addEventListener, tell click [
  get raise-window
 ]
 set start-drag [
  function event [
   get component maximized, false [
    set component is-dragging true
    get raise-window, tell
    get component position, false [
     set component position [
      object [
       x 0
       y 0
      ]
     ]
    ]
    set component drag-start-x [ get event clientX ]
    set component drag-start-y [ get event clientY ]
    set component drag-start-position-x [ get component position x ]
    set component drag-start-position-y [ get component position y ]
    set handle-drag-mousemove [
     function event [
      get component is-dragging, true [
       set delta-x [ get event clientX, subtract [ get component drag-start-x ] ]
       set delta-y [ get event clientY, subtract [ get component drag-start-y ] ]
       set new-x [ get component drag-start-position-x, add [ get delta-x ] ]
       set new-y [ get component drag-start-position-y, add [ get delta-y ] ]
       set component position [
        object [
         x [ get new-x ]
         y [ get new-y ]
        ]
       ]
       set [ get component ] element style transform [
        template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ]
       ]
       get component stage, true [
        get component stage minimap, true [
         get component stage minimap update-window, call [ get component ]
        ]
       ]
      ]
     ]
    ]
    set handle-drag-mouseup [
     function event [
      set component is-dragging false
      global document removeEventListener, tell mousemove [ get handle-drag-mousemove ]
      global document removeEventListener, tell mouseup [ get handle-drag-mouseup ]
     ]
    ]
    global document addEventListener, tell mousemove [ get handle-drag-mousemove ]
    global document addEventListener, tell mouseup [ get handle-drag-mouseup ]
   ]
  ]
 ]
 get component title-bar addEventListener, tell mousedown [
  get start-drag
 ]
 set start-resize [
  function event [
   get event stopPropagation, tell
   get event preventDefault, tell
   set component start-x [ get event clientX ]
   set component start-y [ get event clientY ]
   set component start-width [ get component width ]
   set component start-height [ get component height ]
   set component is-resizing true
   set handle-mousemove [
    function event [
     get component is-resizing, true [
      set delta-x [ get event clientX, subtract [ get component start-x ] ]
      set delta-y [ get event clientY, subtract [ get component start-y ] ]
      set new-width [
       global Math max, call [
        get component start-width, add [ get delta-x ]
       ] [
        value 150
       ]
      ]
      set new-height [
       global Math max, call [
        get component start-height, add [ get delta-y ]
       ] [
        value 100
       ]
      ]
      set component width [ get new-width ]
      set component height [ get new-height ]
      get component maximized, false [
       set [ get component ] element style width [
        template %0px [ get component width ]
       ]
       set [ get component ] element style height [
        template %0px [ get component height ]
       ]
      ]
      get component stage, true [
       get component stage minimap, true [
        get component stage minimap update-window, call [ get component ]
       ]
      ]
     ]
    ]
   ]
   set handle-mouseup [
    function event [
     set component is-resizing false
     global document removeEventListener, tell mousemove [ get handle-mousemove ]
     global document removeEventListener, tell mouseup [ get handle-mouseup ]
    ]
   ]
   global document addEventListener, tell mousemove [ get handle-mousemove ]
   global document addEventListener, tell mouseup [ get handle-mouseup ]
  ]
 ]
get component resize-handle addEventListener, tell mousedown [
  function event [
   get event stopPropagation, tell
   get event preventDefault, tell
   set component start-x [ get event clientX ]
   set component start-y [ get event clientY ]
   set component start-width [ get component width ]
   set component start-height [ get component height ]
   set component is-resizing true
   set resize-overlay [
    global document createElement, call div
   ]
   get resize-overlay classList add, call window-resize-overlay
   global document body appendChild, tell [ get resize-overlay ]
   set handle-mousemove [
    function event [
     get component is-resizing, true [
      set delta-x [ get event clientX, subtract [ get component start-x ] ]
      set delta-y [ get event clientY, subtract [ get component start-y ] ]
      set new-width [
       global Math max, call [
        get component start-width, add [ get delta-x ]
       ] [
        value 150
       ]
      ]
      set new-height [
       global Math max, call [
        get component start-height, add [ get delta-y ]
       ] [
        value 100
       ]
      ]
      set component width [ get new-width ]
      set component height [ get new-height ]
      get component maximized, false [
       set [ get component ] element style width [
        template %0px [ get component width ]
       ]
       set [ get component ] element style height [
        template %0px [ get component height ]
       ]
      ]
      get component stage, true [
       get component stage minimap, true [
        get component stage minimap update-window, call [ get component ]
       ]
      ]
     ]
    ]
   ]
   set handle-mouseup [
    function event [
     set component is-resizing false
     get resize-overlay parentNode, true [
      get resize-overlay parentNode removeChild, call [ get resize-overlay ]
     ]
     global document removeEventListener, tell mousemove [ get handle-mousemove ]
     global document removeEventListener, tell mouseup [ get handle-mouseup ]
    ]
   ]
   global document addEventListener, tell mousemove [ get handle-mousemove ]
   global document addEventListener, tell mouseup [ get handle-mouseup ]
  ]
 ]
 get raise-window, tell
 set [ get component ] element style width [
  template %0px [ get component width ]
 ]
 set [ get component ] element style height [
  template %0px [ get component height ]
 ]
 set component fill [
  function content-element [
   get component content appendChild, call [ get content-element ]
  ]
 ]
 get component
]
