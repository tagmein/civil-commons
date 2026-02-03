# Tests for app/interface/main-menu/document.cr
get describe, call 'document menu' [
 function [
  get it, call 'should create menu with Document label' [
   function [
    set menu [ object [ label 'Document' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Document'
   ]
  ]
 ]
]
