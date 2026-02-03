# Tests for app/interface/main-menu/presentation.cr
get describe, call 'presentation menu' [
 function [
  get it, call 'should create menu with Presentation label' [
   function [
    set menu [ object [ label 'Presentation' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Presentation'
   ]
  ]
 ]
]
