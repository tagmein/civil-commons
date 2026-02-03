# Tests for app/interface/main-menu/window.cr
get describe, call 'window menu' [
 function [
  get it, call 'should create menu with Window label' [
   function [
    set menu [ object [ label 'Window' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Window'
   ]
  ]
 ]
]
