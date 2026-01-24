get lib style-tag

tell .stage [
 object [
  flex-grow 1
  position relative
  z-index 0
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
   place-next [
    object [
     x 0
     y 0
    ]
   ]
   place-advance [
    function [
     set [ get component ] place-next x [
      get component place-next x, add 20
     ]
     set [ get component ] place-next y [
      get component place-next y, add 20
     ]
    ]
   ]
   place-window [
    function window status [
     get component place-advance, tell
     get component content appendChild, tell [
      get window element
     ]
     set [ get window ] position [
      object [
       x [ get component place-next x ]
       y [ get component place-next y ]
      ]
     ]
     set [ get window ] element style transform [
      template 'translate(%0px, %1px)' [ get window position x ]  [ get window position y ]
     ]
     get status, true [
      set [ get window ] status-bar [ get status ]
      set [ get window ] stage [ get component ]
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
   set component effects height [
    get component height
   ]
   set component effects width [
    get component width
   ]
   get render, call
  ]
 ]

 global setTimeout, call [ get resize ]
 global addEventListener, call resize [ get resize ]
 set component resize [ get resize ]
 get component
]
