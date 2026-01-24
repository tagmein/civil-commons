get lib style-tag

tell .window-title-bar-buttons [
 object [
  align-items center
  display flex
  flex-direction row
  flex-shrink 0
  gap 4px
 ]
]

tell '.window-title-bar-button' [
 object [
  align-items center
  background-color transparent
  border none
  cursor pointer
  display flex
  flex-shrink 0
  height 20px
  justify-content center
  padding 0
  width 20px
 ]
]

tell '.window-title-bar-button:hover' [
 object [
  background-color '#80808040'
 ]
]

tell '.window-title-bar-button svg' [
 object [
  color '#e0e0d0'
  height 12px
  width 12px
 ]
]

tell '.window-title-bar-button > div' [
 object [
  display flex
  align-items center
  justify-content center
 ]
]

function on-minimize on-maximize on-restore on-close [
 set component [
  object [
   element [
    global document createElement, call div
   ]
   minimize-button [
    global document createElement, call button
   ]
   maximize-button [
    global document createElement, call button
   ]
   restore-button [
    global document createElement, call button
   ]
   close-button [
    global document createElement, call button
   ]
  ]
 ]
 get component element classList add, call window-title-bar-buttons
 get component minimize-button classList add, call window-title-bar-button
 get component maximize-button classList add, call window-title-bar-button
 get component restore-button classList add, call window-title-bar-button
 get component close-button classList add, call window-title-bar-button
 get component minimize-button appendChild, tell [
  get lib svg-icon, call /app/icons/minimize.svg
 ]
 get component maximize-button appendChild, tell [
  get lib svg-icon, call /app/icons/maximize.svg
 ]
 get component restore-button appendChild, tell [
  get lib svg-icon, call /app/icons/restore.svg
 ]
 set component restore-button style display none
 get component close-button appendChild, tell [
  get lib svg-icon, call /app/icons/close.svg
 ]
 get component element appendChild, tell [ get component minimize-button ]
 get component element appendChild, tell [ get component maximize-button ]
 get component element appendChild, tell [ get component restore-button ]
 get component element appendChild, tell [ get component close-button ]
 get on-minimize, true [
  get component minimize-button addEventListener, tell click [
   function event [
    get event stopPropagation, tell
    get on-minimize, tell
   ]
  ]
 ]
 get on-maximize, true [
  get component maximize-button addEventListener, tell click [
   function event [
    get event stopPropagation, tell
    get on-maximize, tell
   ]
  ]
 ]
 get on-restore, true [
  get component restore-button addEventListener, tell click [
   function event [
    get event stopPropagation, tell
    get on-restore, tell
   ]
  ]
 ]
 get on-close, true [
  get component close-button addEventListener, tell click [
   function event [
    get event stopPropagation, tell
    get on-close, tell
   ]
  ]
 ]
 get component
]
