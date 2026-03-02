# Shared Value Editor - build-input for type-specific value editing
# Used by value window and dictionary term panel

get lib style-tag

tell '.value-type-row' [
 object [
  display flex
  align-items center
  gap 10px
 ]
]

tell '.value-type-label' [
 object [
  color '#a0a0a0'
  font-size 13px
  min-width 40px
 ]
]

tell '.value-type-select' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding '6px 10px'
  outline none
  flex 1
 ]
]

tell '.value-type-select:focus' [
 object [
  border-color '#4a9eff'
 ]
]

tell '.value-input' [
 object [
  background-color '#1e1e22'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  flex 1
  font-family 'Consolas, Monaco, monospace'
  font-size 14px
  padding '10px 12px'
  outline none
  resize none
 ]
]

tell '.value-input:focus' [
 object [
  border-color '#4a9eff'
  background-color '#222226'
 ]
]

tell '.value-input:disabled' [
 object [
  background-color '#2a2a2e'
  color '#606060'
  cursor not-allowed
 ]
]

tell '.value-checkbox-row' [
 object [
  align-items center
  display flex
  gap 10px
  padding '10px 0'
 ]
]

tell '.value-checkbox-row input' [
 object [
  width 20px
  height 20px
  cursor pointer
 ]
]

tell '.value-checkbox-row label' [
 object [
  color '#e0e0d0'
  font-size 14px
  cursor pointer
 ]
]

tell '.value-null-display' [
 object [
  color '#808080'
  font-style italic
  font-size 14px
  padding '10px 0'
 ]
]

set build-input [ function container val-type val-value on-change [
 set container innerHTML ''

 get val-type, is string, true [
  set input [ global document createElement, call textarea ]
  get input classList add, call value-input
  set input value [ get val-value, default '' ]
  set input placeholder 'Enter string value...'
  get input addEventListener, call blur [
   function [
    get on-change, call [ get val-type ] [ get input value ]
   ]
  ]
  get container appendChild, call [ get input ]
 ]

 get val-type, is integer, true [
  set input [ global document createElement, call input ]
  get input classList add, call value-input
  set input type number
  set input step 1
  set input value [ get val-value, default 0 ]
  set input placeholder 'Enter integer...'
  get input addEventListener, call blur [
   function [
    get on-change, call [ get val-type ] [ global parseInt, call [ get input value ] 10 ]
   ]
  ]
  get container appendChild, call [ get input ]
 ]

 get val-type, is float, true [
  set input [ global document createElement, call input ]
  get input classList add, call value-input
  set input type number
  set input step any
  set input value [ get val-value, default 0 ]
  set input placeholder 'Enter float...'
  get input addEventListener, call blur [
   function [
    get on-change, call [ get val-type ] [ global parseFloat, call [ get input value ] ]
   ]
  ]
  get container appendChild, call [ get input ]
 ]

 get val-type, is boolean, true [
  set row [ global document createElement, call div ]
  get row classList add, call value-checkbox-row
  set checkbox [ global document createElement, call input ]
  set checkbox type checkbox
  set checkbox-id [ template 'value-bool-%0' [ global Math random, call, at toString, call 36, at substring, call 2 9 ] ]
  set checkbox id [ get checkbox-id ]
  set checkbox checked [ get val-value, default false ]
  get row appendChild, call [ get checkbox ]
  set label [ global document createElement, call label ]
  set label htmlFor [ get checkbox-id ]
  set label textContent [ get val-value, default false ]
  get row appendChild, call [ get label ]
  get checkbox addEventListener, call change [
   function [
    set label textContent [ get checkbox checked ]
    get on-change, call [ get val-type ] [ get checkbox checked ]
   ]
  ]
  get container appendChild, call [ get row ]
 ]

 get val-type, is null, true [
  set display [ global document createElement, call div ]
  get display classList add, call value-null-display
  set display textContent 'null'
  get container appendChild, call [ get display ]
 ]

 get val-type, is undefined, true [
  set display [ global document createElement, call div ]
  get display classList add, call value-null-display
  set display textContent 'undefined'
  get container appendChild, call [ get display ]
 ]
] ]

object [
 build-input
]
