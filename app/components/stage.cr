get lib style-tag

tell .stage [
 object [
  flex-grow 1
  position relative
  z-index 0
  overflow hidden
 ]
]

tell .stage-effects [
 object [
  pointer-events none
 ]
]

tell '.stage-effects, .stage-content' [
 object [
  height 100%
  left 0
  overflow hidden
  position absolute
  top 0
  width 100%
 ]
]

function [
 # Virtual stage is 10000x10000 pixels
 set VIRTUAL_STAGE_SIZE 10000
 
 set component [
  object [
   element [
    global document createElement, call div
   ]
   effects [
    global document createElement, call canvas
   ]
   content [
    global document createElement, call div
   ]
   windows [ list ]
   # Viewport position in virtual stage coordinates
   viewportX 0
   viewportY 0
   # Physical viewport dimensions (set on resize)
   viewportWidth 0
   viewportHeight 0
   # Virtual stage size constant
   virtualStageSize [ get VIRTUAL_STAGE_SIZE ]
   place-next [
    object [
     x 20
     y 20
    ]
   ]
   place-advance [
    function [
     set component place-next x [
      get component place-next x, add 20
     ]
     set component place-next y [
      get component place-next y, add 20
     ]
     # Wrap around if past a threshold (component property mutation works in conditionals)
     get component place-next x, > 500, true [
      set component place-next x 20
      set component place-next y [ get component place-next y, add 40 ]
     ]
    ]
   ]
   place-window [
    function window status [
     get component place-advance, tell
     get component content appendChild, tell [
      get window element
     ]
     set window position [
      object [
       x [ get component place-next x ]
       y [ get component place-next y ]
      ]
     ]
     # Position window using virtual stage coordinates
     get component apply-window-transform, call [ get window ]
     get status, true [
      set window status-bar [ get status ]
      set window stage [ get component ]
     ]
     get component windows push, tell [ get window ]
     get component minimap, true [
      get component minimap add-window, call [ get window ]
     ]
    ]
   ]
   # Apply transform to window based on viewport position
   apply-window-transform [
    function window [
     get window position, true [
      # Window position in virtual stage, offset by viewport
      set visual-x [ get window position x, subtract [ get component viewportX ] ]
      set visual-y [ get window position y, subtract [ get component viewportY ] ]
      set window element style transform [
       template 'translate(%0px, %1px)' [ get visual-x ] [ get visual-y ]
      ]
     ]
    ]
   ]
   # Update all window transforms (when viewport moves)
   update-all-window-transforms [
    function [
     get component windows, each [
      function window [
       get window maximized, false [
        get component apply-window-transform, call [ get window ]
       ]
      ]
     ]
    ]
   ]
   # Set viewport position (clamped to virtual stage)
   # Uses reference objects to avoid Crown's scoping issues with set in conditionals
   set-viewport-position [
    function x y [
     set max-x-raw [ get VIRTUAL_STAGE_SIZE, subtract [ get component viewportWidth ] ]
     set max-y-raw [ get VIRTUAL_STAGE_SIZE, subtract [ get component viewportHeight ] ]
     # Use ref object for max values
     set max-ref [ object [ x [ get max-x-raw ], y [ get max-y-raw ] ] ]
     # Clamp max to 0 if viewport is larger than stage
     get max-ref x, < 0, true [
      set max-ref x 0
     ]
     get max-ref y, < 0, true [
      set max-ref y 0
     ]
     # Use ref object for result values
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
     set component viewportX [ get result x ]
     set component viewportY [ get result y ]
     get component update-all-window-transforms, call
     get component minimap, true [
      get component minimap update-display, call
     ]
    ]
   ]
  ]
 ]
 get component element classList add, call stage
 get component effects classList add, call stage-effects
 get component content classList add, call stage-content
 get component element appendChild
 tell [ get component effects ]
 tell [ get component content ]
 set component effects-context [
  get component effects getContext, call 2d
 ]
 set component mouseX 0
 set component mouseY 0

 get component element addEventListener, call 'mousemove' [
  function event [
   set stage-rect [
    get component element getBoundingClientRect, call
   ]
   set component mouseX [
    get event clientX, subtract [ get stage-rect left ]
   ]
   set component mouseY [
    get event clientY, subtract [ get stage-rect top ]
   ]
   get render, call
  ]
 ]

 set render [
  function [
   get component effects-context clearRect, tell 0 0 [ get component width ] [ get component height ]

   set component effects-context fillStyle '#00000040'
   get component effects-context fillRect, tell 0 [ get component mouseY, subtract 2 ] [ get component width ] 5
   get component effects-context fillRect, tell [ get component mouseX, subtract 2 ] 0 5 [ get component height ]

   set component effects-context fillStyle '#40404040'
   get component effects-context fillRect, tell 0 [ get component mouseY, subtract 1 ] [ get component width ] 3
   get component effects-context fillRect, tell [ get component mouseX, subtract 1 ] 0 3 [ get component height ]

   set component effects-context fillStyle '#60606060'
   get component effects-context fillRect, tell 0 [ get component mouseY ] [ get component width ] 1
   get component effects-context fillRect, tell [ get component mouseX ] 0 1 [ get component height ]
  ]
 ]

 set resize [
  function [
   set component height [
    get component effects offsetHeight
   ]
   set component width [
    get component effects offsetWidth
   ]
   set component viewportWidth [ get component width ]
   set component viewportHeight [ get component height ]
   set component effects height [
    get component height
   ]
   set component effects width [
    get component width
   ]
   # Re-clamp viewport position after resize
   get component set-viewport-position, call [ get component viewportX ] [ get component viewportY ]
   get render, call
  ]
 ]

 global setTimeout, call [ get resize ]
 global addEventListener, call resize [ get resize ]
 set component resize [ get resize ]

 set component minimap [
  get components minimap, call [ get component ]
 ]
 get component element appendChild, tell [ get component minimap element ]

 get component
]
