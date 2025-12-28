set format-style-line [
 function entry [
  template ' %0: %1;' [ get entry 0 ] [ get entry 1 ]
 ]
]

function selector style-object [
 set tag [
  global document createElement, call style
 ]
 set tag textContent [
  template '%0 {
%1
}
' [ get selector ] [
   get style-object, entries, map [ get format-style-line ]
   at join, call '
'
  ]
 ]
 global document head appendChild, call [
  get tag
 ]
]
