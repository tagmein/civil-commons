get lib style-tag

tell .action-bar [
 object [
  background-color '#222226'
  display flex
  height 34px
  overflow visible
 ]
]

tell '.action-bar label' [
 object [
  align-items center
  border-right '1px solid #80808020'
  box-shadow 'inset 0 0 1px 0 #ffffff20'
  display block
  justify-content center
  line-height 35px
  padding '0 10px'
  position relative
  user-select none
 ]
]

tell '.action-bar label:hover' [
 object [
  background-color '#80808040'
 ]
]

function [
 set component [ object ]
 set component element [
  global document createElement, call div
 ]
 get component element classList add, call action-bar
 set last-toggle [ object ]
 set component add [
  function label on-click [
   set label-element [
    global document createElement, call label
   ]
   set label-element textContent [ get label ]
   set item [ object [ element [ get label-element ] ] ]
   get on-click, true [
    get label-element addEventListener, call click [
     function event [
      get last-toggle element, is [ get label-element ], false [
       get last-toggle current, true [
        get last-toggle current, call
        unset last-toggle current
       ] 
       set last-toggle current [
        get on-click, will [ get item ] false
       ]
       set last-toggle element [ get label-element ]
      ], true [
       unset last-toggle ( current, element )
      ]
      get on-click, call [ get item ] [ get event ]
     ]
    ]
   ]
   get component element appendChild, call [
    get label-element
   ]
   get item
  ]
 ]
 set component remove [
  function item [
   get item element, true [
    get last-toggle element, is [ get item element ], true [
     unset last-toggle current
     unset last-toggle element
    ]
    get component element removeChild, call [ get item element ]
   ]
  ]
 ]
 get component
]
