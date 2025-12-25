set action-bar-style-tag [
 global document createElement, call style
]

set [ get action-bar-style-tag ] textContent '
.action-bar {
 background-color: #222226;
 height: 50px;
}
'

global document head appendChild, call [
 get action-bar-style-tag
]

function [
 set component [ object ]
 set [ get component ] element [
  global document createElement, call div
 ]
 get component element classList add, call action-bar
 get component
]
