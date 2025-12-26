set menu-style-tag [
 global document createElement, call style
]

set menu-style-tag textContent '
.menu {
 background-color: #222226;
 display: flex;
 flex-direction: column;
 min-height: 50px;
 min-width: 100px;
 position: absolute;
 top: 100%;
 left: 0;
}

.menu label {
 border-right: 1px solid #80808020;
 box-shadow: inset 0 0 1px 0 #ffffff20;
 display: block;
 line-height: 54px;
 padding: 0 8px;
}

.menu label:hover {
 background-color: #80808040;
}
'

global document head appendChild, call [
 get menu-style-tag
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
