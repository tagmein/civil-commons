get lib style-tag

tell .stage [
 object [
  flex-grow 1
  position relative
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
 set component [ object ]
 set component element [
  global document createElement, call div
 ]
 set component effects [
  global document createElement, call canvas
 ]
 set component content [
  global document createElement, call div
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
   set component mouseX [ get event offsetX ]
   set component mouseY [ get event offsetY ]
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
