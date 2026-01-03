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

 set grid-size 24

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
   log [ get countX ] [ get countY ]
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
