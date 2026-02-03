# Tests for app/interface/main-menu/view.cr
get describe, call 'view menu' [
 function [
  get it, call 'should create menu with View label' [
   function [
    set menu [ object [ label 'View' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'View'
   ]
  ]
 ]
]
