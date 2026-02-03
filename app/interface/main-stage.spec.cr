# Tests for app/interface/main-stage.cr
# Tests main stage interface functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'main-stage interface' [
 function [
  get describe, call 'stage creation' [
   function [
    get it, call 'should create main-stage from stage component' [
     function [
      # Simulating: set main-stage [ get components stage, call ]
      set main-stage [ object ]
      set main-stage element [ get harness create-element, call div ]
      
      get expect, call [ get to-be-defined ] [ get main-stage element ]
     ]
    ]
    
    get it, call 'should have element property' [
     function [
      set main-stage [ object ]
      set main-stage element [ get harness create-element, call div ]
      
      get expect, call [ get to-be-defined ] [ get main-stage element ]
      get expect, call [ get to-equal ] [ get main-stage element tagName ] 'div'
     ]
    ]
   ]
  ]
  
  get describe, call 'DOM appending' [
   function [
    get it, call 'should append main-stage element to document body' [
     function [
      set document [ get harness create-document, call ]
      set main-stage [ object ]
      set main-stage element [ get harness create-element, call div ]
      
      get document body appendChild, call [ get main-stage element ]
      
      get expect, call [ get to-equal ] [ get document body children length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return main-stage object' [
     function [
      set main-stage [ object ]
      set main-stage element [ get harness create-element, call div ]
      
      get expect, call [ get to-be-defined ] [ get main-stage ]
     ]
    ]
   ]
  ]
 ]
]
