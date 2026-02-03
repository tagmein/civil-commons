# Tests for app/interface/main-menu/log.cr
get describe, call 'log menu' [
 function [
  get it, call 'should create menu with Log label' [
   function [
    set menu [ object [ label 'Log' ] ]
    get expect, call [ get to-equal ] [ get menu label ] 'Log'
   ]
  ]
  
  get it, call 'should dispatch log:open on click' [
   function [
    set dispatched [ object [ value false ] ]
    set mock-conductor [ object ]
    set mock-conductor dispatch [ function action [
     set dispatched value true
    ] ]
    
    get mock-conductor dispatch, call 'log:open'
    get expect, call [ get to-be-true ] [ get dispatched value ]
   ]
  ]
 ]
]
