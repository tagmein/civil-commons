# Tests for app/interface/main-menu/page.cr
get describe, call 'page menu' [
 function [
  get it, call 'should create menu with Page label' [
   function [
    set menu [ object [ label 'Page' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Page'
   ]
  ]
 ]
]
