get lib style-tag

tell .grid [
 object [
  flex-grow 1
  position relative
 ]
]

tell '.grid-backdrop, .grid-content' [
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
 set component [ object ]
 set component element [
  global document createElement, call div
 ]
 set component backdrop [
  global document createElement, call canvas
 ]
 set component content [
  global document createElement, call div
 ]
 get component element classList add, call grid
 get component backdrop classList add, call grid-backdrop
 get component content classList add, call grid-content
 get component element appendChild
 tell [ get component backdrop ]
 tell [ get component content ]
 set component backdrop-context [
  get component backdrop getContext, call 2d
 ]

 set grid-size 24

 set draw-grid-halo [
  function x y [
   get component backdrop-context fillRect, call [
    get x, multiply [ get grid-size ], subtract 1
   ] [
    get y, multiply [ get grid-size ], subtract 1
   ] 3 3
  ]
 ]

 set draw-grid-dot [
  function x y [
   get component backdrop-context fillRect, call [
    get x, multiply [ get grid-size ]
   ] [
    get y, multiply [ get grid-size ]
   ] 1 1
  ]
 ]

 set render [
  function [
   set countX [
    global Math floor, call [
     get component width, divide [ get grid-size ] 
    ]
   ]
   set countY [
    global Math floor, call [
     get component height, divide [ get grid-size ] 
    ]
   ]

   # Render grid halos
   set component backdrop-context fillStyle '#80808080'
   set y [ get countY, add 1 ]
   get y
   loop [
     # Decrement Y
     set y [ get y, subtract 1 ]
     # Reset X for the new row
     set x [ get countX, add 1 ]
     get x
     loop [
       # Decrement X
       set x [ get x, subtract 1 ]
       # Draw the pixel
       get draw-grid-halo, call [ get x ] [ get y ]
       # Check if we should stop the X loop
       get x
       drop [ get x, is 0 ]
     ]
     # Check if we should stop the Y loop
     get y
     drop [ get y, is 0 ]
   ]

   # Render grid points
   set component backdrop-context fillStyle '#808080'
   set y [ get countY, add 1 ]
   get y
   loop [
     # Decrement Y
     set y [ get y, subtract 1 ]
     # Reset X for the new row
     set x [ get countX, add 1 ]
     get x
     loop [
       # Decrement X
       set x [ get x, subtract 1 ]
       # Draw the pixel
       get draw-grid-dot, call [ get x ] [ get y ]
       # Check if we should stop the X loop
       get x
       drop [ get x, is 0 ]
     ]
     # Check if we should stop the Y loop
     get y
     drop [ get y, is 0 ]
   ]
  ]
 ]

 set resize [
  function [
   set component height [
    get component backdrop offsetHeight
   ]
   set component width [
    get component backdrop offsetWidth
   ]
   set component backdrop height [
    get component height
   ]
   set component backdrop width [
    get component width
   ]
   get render, call
  ]
 ]

 global setTimeout, call [ get resize ]
 global addEventListener, call resize [ get resize ]
 get component
]
