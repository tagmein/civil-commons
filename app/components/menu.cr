get lib style-tag

tell .menu [
 object [
  background-color '#222226'
  border-bottom-left-radius 8px
  border-bottom-right-radius 8px
  display flex
  flex-direction column
  left 0
  min-height 34px
  min-width 100px
  overflow hidden
  position absolute
  top 100%
  z-index 1
 ]
]

tell '.menu label' [
 object [
  border-right '1px solid #80808020'
  box-shadow 'inset 0 0 1px 0 #ffffff20'
  display block
  height 34px
  line-height 35px
  padding '0 12px'
  white-space nowrap
 ]
]

tell '.menu label:hover' [
 object [
  background-color '#80808040'
 ]
]

function [
 set component [ object ]
 set component open false
 set component element [
  global document createElement, call div
 ]
 get component element classList add, call menu
 set component add [
  function label on-click [
   set label-element [
    global document createElement, call label
   ]
   set label-element textContent [ get label ]
   get on-click, true [
    get label-element addEventListener, call click [
     get on-click
    ]
   ]
   get component element appendChild, call [
    get label-element
   ]
  ]
 ]
 set component toggle [
  function parent [
   get component attached
   true [
    get parent element removeChild, call [ get component element ]
    set component attached false
   ]
   false [
    get parent element appendChild, call [ get component element ]
    set component attached true
   ]
  ]
 ]
 get component
]
