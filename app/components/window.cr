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
  line-height 35px
  overflow hidden
  padding '0 10px'
  white-space nowrap
 ]
]

tell .window-title-bar-title [
 object [
  color '#e0e0d0'
  flex-grow 1
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
 ]
]

tell .window-title-bar-buttons [
 object [
  align-items center
  display flex
  flex-direction row
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

tell .window.maximized [
 object [
  border-radius 0
  height 100%
  left 0
  top 0
  width 100%
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
   title-text [
    global document createElement, call div
   ]
   title-buttons [
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
   title
   open false
   height [ get height, default 300 ]
   width [ get width, default 500 ]
   maximized false
  ]
 ]
 get component element classList add, call window
 get component title-bar classList add, call window-title-bar
 get component title-text classList add, call window-title-bar-title
 get component title-buttons classList add, call window-title-bar-buttons
 get component minimize-button classList add, call window-title-bar-button
 get component maximize-button classList add, call window-title-bar-button
 get component restore-button classList add, call window-title-bar-button
 get component close-button classList add, call window-title-bar-button
 set component title-text textContent [ get title, default 'Untitled' ]
 get component title-bar appendChild, tell [ get component title-text ]
 get component title-bar appendChild, tell [ get component title-buttons ]
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
 get component title-buttons appendChild, tell [ get component minimize-button ]
 get component title-buttons appendChild, tell [ get component maximize-button ]
 get component title-buttons appendChild, tell [ get component restore-button ]
 get component title-buttons appendChild, tell [ get component close-button ]
 set toggle-maximize [
  function [
   get component maximized, true [
    get component element classList remove, call maximized
    set component maximized false
    set component maximize-button style display flex
    set component restore-button style display none
    get component position, true [
     set [ get component ] element style transform [
      template 'translate(%0px, %1px)' [ get component position x ] [ get component position y ]
     ]
    ]
    set [ get component ] element style width [
     template %0px [ get component width ]
    ]
    set [ get component ] element style height [
     template %0px [ get component height ]
    ]
   ], false [
    get component element classList add, call maximized
    set component maximized true
    set component maximize-button style display none
    set component restore-button style display flex
    set [ get component ] element style transform ''
    set [ get component ] element style width ''
    set [ get component ] element style height ''
   ]
  ]
 ]
 get component maximize-button addEventListener, tell click [
  function event [
   get event stopPropagation, tell
   get toggle-maximize, tell
  ]
 ]
 get component restore-button addEventListener, tell click [
  function event [
   get event stopPropagation, tell
   get toggle-maximize, tell
  ]
 ]
 get component element appendChild, tell [ get component title-bar ]
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
