# Tests for app/interface/main-menu/insert.cr
get describe, call 'insert menu' [
 function [
  get it, call 'should create menu with Insert label' [
   function [
    set menu [ object [ label 'Insert' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Insert'
   ]
  ]
 ]
]
