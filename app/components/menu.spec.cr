# Tests for app/components/menu.cr
# Tests menu component functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'menu component' [
 function [
  get describe, call 'component creation' [
   function [
    get it, call 'should create element with menu class' [
     function [
      set element [ get harness create-element, call div ]
      get element classList add, call menu
      get expect, call [ get to-be-true ] [ get element classList contains, call 'menu' ]
     ]
    ]
    
    get it, call 'should store label property' [
     function [
      set component [ object [ label 'Test Menu' ] ]
      get expect, call [ get to-equal ] [ get component label ] 'Test Menu'
     ]
    ]
    
    get it, call 'should have open property defaulting to false' [
     function [
      set component [ object [ open false ] ]
      get expect, call [ get to-be-false ] [ get component open ]
     ]
    ]
    
    get it, call 'should have add method' [
     function [
      set component [ object ]
      set component add [ function label on-click [ ] ]
      get expect, call [ get to-be-defined ] [ get component add ]
     ]
    ]
    
    get it, call 'should have toggle method' [
     function [
      set component [ object ]
      set component toggle [ function parent [ ] ]
      get expect, call [ get to-be-defined ] [ get component toggle ]
     ]
    ]
   ]
  ]
  
  get describe, call 'add method' [
   function [
    get it, call 'should create label element with correct text' [
     function [
      set label-element [ get harness create-element, call label ]
      set label-element textContent 'Menu Item'
      
      get expect, call [ get to-equal ] [ get label-element textContent ] 'Menu Item'
     ]
    ]
    
    get it, call 'should append label to menu element' [
     function [
      set menu-element [ get harness create-element, call div ]
      set label-element [ get harness create-element, call label ]
      
      get menu-element appendChild, call [ get label-element ]
      
      get expect, call [ get to-equal ] [ get menu-element children length ] 1
     ]
    ]
    
    get it, call 'should add click listener when on-click provided' [
     function [
      set label-element [ get harness create-element, call label ]
      set clicked [ object [ value false ] ]
      
      set on-click [ function event [
       set clicked value true
      ] ]
      
      get on-click, true [
       get label-element addEventListener, call click [ get on-click ]
      ]
      
      get label-element dispatchEvent, call [ object [ type click ] ]
      
      get expect, call [ get to-be-true ] [ get clicked value ]
     ]
    ]
    
    get it, call 'should handle multiple menu items' [
     function [
      set menu-element [ get harness create-element, call div ]
      
      set item1 [ get harness create-element, call label ]
      set item1 textContent 'Item 1'
      get menu-element appendChild, call [ get item1 ]
      
      set item2 [ get harness create-element, call label ]
      set item2 textContent 'Item 2'
      get menu-element appendChild, call [ get item2 ]
      
      set item3 [ get harness create-element, call label ]
      set item3 textContent 'Item 3'
      get menu-element appendChild, call [ get item3 ]
      
      get expect, call [ get to-equal ] [ get menu-element children length ] 3
     ]
    ]
   ]
  ]
  
  get describe, call 'toggle method' [
   function [
    get it, call 'should append menu to parent when not attached' [
     function [
      set parent [ object ]
      set parent element [ get harness create-element, call div ]
      set component [ object ]
      set component element [ get harness create-element, call div ]
      set component attached false
      
      get component attached, false [
       get parent element appendChild, call [ get component element ]
       set component attached true
      ]
      
      get expect, call [ get to-be-true ] [ get component attached ]
      get expect, call [ get to-equal ] [ get parent element children length ] 1
     ]
    ]
    
    get it, call 'should remove menu from parent when attached' [
     function [
      set parent [ object ]
      set parent element [ get harness create-element, call div ]
      set component [ object ]
      set component element [ get harness create-element, call div ]
      
      # First attach
      get parent element appendChild, call [ get component element ]
      set component attached true
      
      # Then detach
      get component attached, true [
       get parent element removeChild, call [ get component element ]
       set component attached false
      ]
      
      get expect, call [ get to-be-false ] [ get component attached ]
      get expect, call [ get to-equal ] [ get parent element children length ] 0
     ]
    ]
    
    get it, call 'should toggle attached state correctly' [
     function [
      set component [ object [ attached false ] ]
      
      # Toggle on
      set component attached true
      get expect, call [ get to-be-true ] [ get component attached ]
      
      # Toggle off
      set component attached false
      get expect, call [ get to-be-false ] [ get component attached ]
     ]
    ]
   ]
  ]
 ]
]
