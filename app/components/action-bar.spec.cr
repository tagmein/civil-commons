# Tests for app/components/action-bar.cr
# Tests action-bar component functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'action-bar component' [
 function [
  get describe, call 'component creation' [
   function [
    get it, call 'should create element with action-bar class' [
     function [
      set element [ get harness create-element, call div ]
      get element classList add, call action-bar
      get expect, call [ get to-be-true ] [ get element classList contains, call 'action-bar' ]
     ]
    ]
    
    get it, call 'should return component object with element property' [
     function [
      set component [ object ]
      set component element [ get harness create-element, call div ]
      get expect, call [ get to-be-defined ] [ get component element ]
     ]
    ]
    
    get it, call 'should have add method' [
     function [
      set component [ object ]
      set component add [ function label on-click [ ] ]
      get expect, call [ get to-be-defined ] [ get component add ]
     ]
    ]
    
    get it, call 'should have remove method' [
     function [
      set component [ object ]
      set component remove [ function item [ ] ]
      get expect, call [ get to-be-defined ] [ get component remove ]
     ]
    ]
   ]
  ]
  
  get describe, call 'add method' [
   function [
    get it, call 'should create label element with correct text' [
     function [
      set container [ get harness create-element, call div ]
      set label-element [ get harness create-element, call label ]
      set label-element textContent 'Test Label'
      get container appendChild, call [ get label-element ]
      
      get expect, call [ get to-equal ] [ get label-element textContent ] 'Test Label'
      get expect, call [ get to-equal ] [ get container children length ] 1
     ]
    ]
    
    get it, call 'should return item object with element property' [
     function [
      set label-element [ get harness create-element, call label ]
      set item [ object [ element [ get label-element ] ] ]
      
      get expect, call [ get to-be-defined ] [ get item element ]
      get expect, call [ get to-equal ] [ get item element tagName ] 'label'
     ]
    ]
    
    get it, call 'should add click listener when on-click provided' [
     function [
      set label-element [ get harness create-element, call label ]
      set clicked [ object [ value false ] ]
      
      get label-element addEventListener, call click [
       function event [
        set clicked value true
       ]
      ]
      
      # Simulate click
      get label-element dispatchEvent, call [ object [ type click ] ]
      
      get expect, call [ get to-be-true ] [ get clicked value ]
     ]
    ]
    
    get it, call 'should not add click listener when on-click is null' [
     function [
      set label-element [ get harness create-element, call label ]
      set on-click null
      
      get on-click, true [
       get label-element addEventListener, call click [ get on-click ]
      ]
      
      # Should not error - on-click is null so no listener added
      get expect, call [ get to-be-true ] true
     ]
    ]
    
    get it, call 'should append label to component element' [
     function [
      set component-element [ get harness create-element, call div ]
      set label-element [ get harness create-element, call label ]
      
      get component-element appendChild, call [ get label-element ]
      
      get expect, call [ get to-equal ] [ get component-element children length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'remove method' [
   function [
    get it, call 'should remove item element from component' [
     function [
      set component-element [ get harness create-element, call div ]
      set label-element [ get harness create-element, call label ]
      
      get component-element appendChild, call [ get label-element ]
      get expect, call [ get to-equal ] [ get component-element children length ] 1
      
      get component-element removeChild, call [ get label-element ]
      get expect, call [ get to-equal ] [ get component-element children length ] 0
     ]
    ]
    
    get it, call 'should handle item with no element gracefully' [
     function [
      set item [ object ]
      
      get item element, true [
       # Would remove element
      ]
      
      # Should not error
      get expect, call [ get to-be-true ] true
     ]
    ]
   ]
  ]
  
  get describe, call 'toggle behavior (last-toggle tracking)' [
   function [
    get it, call 'should track last toggled element' [
     function [
      set last-toggle [ object ]
      set label-element [ get harness create-element, call label ]
      
      set last-toggle element [ get label-element ]
      
      get expect, call [ get to-equal ] [ get last-toggle element ] [ get label-element ]
     ]
    ]
    
    get it, call 'should track current toggle callback' [
     function [
      set last-toggle [ object ]
      set callback [ function [ value 'called' ] ]
      
      set last-toggle current [ get callback ]
      
      get expect, call [ get to-be-defined ] [ get last-toggle current ]
     ]
    ]
    
    get it, call 'should call previous toggle callback when new item clicked' [
     function [
      set last-toggle [ object ]
      set call-count [ object [ value 0 ] ]
      
      set callback [ function [
       set call-count value [ get call-count value, add 1 ]
      ] ]
      
      set last-toggle current [ get callback ]
      
      # Simulate clicking different item - should call previous callback
      get last-toggle current, true [
       get last-toggle current, call
      ]
      
      get expect, call [ get to-equal ] [ get call-count value ] 1
     ]
    ]
    
    get it, call 'should clear toggle state when same element clicked twice' [
     function [
      set last-toggle [ object ]
      set label-element [ get harness create-element, call label ]
      
      set last-toggle element [ get label-element ]
      set last-toggle current [ function [ ] ]
      
      # Click same element
      get last-toggle element, is [ get label-element ], true [
       unset last-toggle current
       unset last-toggle element
      ]
      
      get expect, call [ get to-equal ] [ get last-toggle current, typeof ] 'undefined'
      get expect, call [ get to-equal ] [ get last-toggle element, typeof ] 'undefined'
     ]
    ]
   ]
  ]
 ]
]
