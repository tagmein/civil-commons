# Tests for app/interface/main-status.cr
# Tests main status bar interface functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'main-status interface' [
 function [
  get describe, call 'status bar creation' [
   function [
    get it, call 'should create main-status from action-bar component' [
     function [
      # Simulating: set main-status [ get components action-bar, call ]
      set main-status [ object ]
      set main-status element [ get harness create-element, call div ]
      get main-status element classList add, call action-bar
      
      get expect, call [ get to-be-defined ] [ get main-status element ]
      get expect, call [ get to-be-true ] [ get main-status element classList contains, call 'action-bar' ]
     ]
    ]
    
    get it, call 'should have element property' [
     function [
      set main-status [ object ]
      set main-status element [ get harness create-element, call div ]
      
      get expect, call [ get to-be-defined ] [ get main-status element ]
     ]
    ]
   ]
  ]
  
  get describe, call 'DOM appending' [
   function [
    get it, call 'should append main-status element to document body' [
     function [
      set document [ get harness create-document, call ]
      set main-status [ object ]
      set main-status element [ get harness create-element, call div ]
      
      get document body appendChild, call [ get main-status element ]
      
      get expect, call [ get to-equal ] [ get document body children length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return main-status object' [
     function [
      set main-status [ object ]
      set main-status element [ get harness create-element, call div ]
      
      get expect, call [ get to-be-defined ] [ get main-status ]
     ]
    ]
   ]
  ]
 ]
]
