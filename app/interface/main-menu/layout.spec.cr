# Tests for app/interface/main-menu/layout.cr
get describe, call 'layout menu' [
 function [
  get it, call 'should create menu with Layout label' [
   function [
    set menu [ object [ label 'Layout' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Layout'
   ]
  ]
 ]
]
