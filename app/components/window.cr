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
  display flex
  flex-direction row
  height 34px
  line-height 30px
  overflow hidden
  padding '0 10px'
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
   title
   open false
   height [ get height, default 300 ]
   width [ get width, default 500 ]
  ]
 ]
 get component element classList add, call window
 get component title-bar classList add, call window-title-bar
 get component element appendChild, tell [ get component title-bar ]
 set component title-bar textContent [ get title, default Untitled ]
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
 get raise-window, tell
 set [ get component ] element style width [
  template %0px [ get component width ]
 ]
 set [ get component ] element style height [
  template %0px [ get component height ]
 ]
 get component
]
