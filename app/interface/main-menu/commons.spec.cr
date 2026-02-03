# Tests for app/interface/main-menu/commons.cr
# Tests commons menu functionality

get describe, call 'commons menu' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create menu with Commons label' [
     function [
      set menu [ object [ label 'Commons' ] ]
      get expect, call [ get to-equal ] [ get menu label ] 'Commons'
     ]
    ]
   ]
  ]
  
  get describe, call 'About menu item' [
   function [
    get it, call 'should have About option' [
     function [
      set items [ list 'About' ]
      get expect, call [ get to-contain ] [ get items, at 0 ] 'About'
     ]
    ]
    
    get it, call 'should dispatch commons:about on click' [
     function [
      set dispatched [ object [ value false, action null ] ]
      set mock-conductor [ object ]
      set mock-conductor dispatch [ function action [
       set dispatched value true
       set dispatched action [ get action ]
      ] ]
      
      get mock-conductor dispatch, call 'commons:about'
      
      get expect, call [ get to-be-true ] [ get dispatched value ]
      get expect, call [ get to-equal ] [ get dispatched action ] 'commons:about'
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return commons menu object' [
     function [
      set commons [ object [ label 'Commons' ] ]
      
      get expect, call [ get to-be-defined ] [ get commons ]
      get expect, call [ get to-equal ] [ get commons label ] 'Commons'
     ]
    ]
   ]
  ]
 ]
]
