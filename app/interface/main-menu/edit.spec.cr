# Tests for app/interface/main-menu/edit.cr
get describe, call 'edit menu' [
 function [
  get it, call 'should create menu with Edit label' [
   function [
    set menu [ object [ label 'Edit' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Edit'
   ]
  ]
 ]
]
