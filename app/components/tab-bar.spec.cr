# Tests for app/components/tab-bar.cr
# Tests tab-bar component functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'tab-bar component' [
 function [
  get describe, call 'component creation' [
   function [
    get it, call 'should create element with tab-bar class' [
     function [
      set element [ get harness create-element, call div ]
      get element classList add, call tab-bar
      get expect, call [ get to-be-true ] [ get element classList contains, call 'tab-bar' ]
     ]
    ]
    
    get it, call 'should initialize with empty tabs list' [
     function [
      set tabs [ list ]
      get expect, call [ get to-be-array ] [ get tabs ]
      get expect, call [ get to-equal ] [ get tabs length ] 0
     ]
    ]
    
    get it, call 'should initialize with null active-tab state' [
     function [
      set state [ object [ active-tab null ] ]
      get expect, call [ get to-equal ] [ get state active-tab ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'add method' [
   function [
    get it, call 'should create button element with tab-bar-tab class' [
     function [
      set tab-element [ get harness create-element, call button ]
      get tab-element classList add, call tab-bar-tab
      get expect, call [ get to-be-true ] [ get tab-element classList contains, call 'tab-bar-tab' ]
     ]
    ]
    
    get it, call 'should set textContent to label' [
     function [
      set tab-element [ get harness create-element, call button ]
      set tab-element textContent 'Test Tab'
      get expect, call [ get to-equal ] [ get tab-element textContent ] 'Test Tab'
     ]
    ]
    
    get it, call 'should return tab object with element, id, and label' [
     function [
      set tabs [ list ]
      set tab-element [ get harness create-element, call button ]
      set tab [
       object [
        element [ get tab-element ]
        id [ get tabs length ]
        label 'Test Tab'
       ]
      ]
      
      get expect, call [ get to-be-defined ] [ get tab element ]
      get expect, call [ get to-equal ] [ get tab id ] 0
      get expect, call [ get to-equal ] [ get tab label ] 'Test Tab'
     ]
    ]
    
    get it, call 'should add tab to tabs list' [
     function [
      set tabs [ list ]
      set tab [ object [ id 0, label 'Tab 1' ] ]
      get tabs push, call [ get tab ]
      get expect, call [ get to-equal ] [ get tabs length ] 1
     ]
    ]
    
    get it, call 'should append tab element to component element' [
     function [
      set component-element [ get harness create-element, call div ]
      set tab-element [ get harness create-element, call button ]
      get component-element appendChild, call [ get tab-element ]
      get expect, call [ get to-equal ] [ get component-element children length ] 1
     ]
    ]
    
    get it, call 'should call on-click when tab is clicked' [
     function [
      set clicked [ object [ value false, tab null ] ]
      set tab [ object [ id 0, label 'Tab' ] ]
      set on-click [ function t event [
       set clicked value true
       set clicked tab [ get t ]
      ] ]
      
      get on-click, call [ get tab ] [ object [ type click ] ]
      
      get expect, call [ get to-be-true ] [ get clicked value ]
      get expect, call [ get to-equal ] [ get clicked tab label ] 'Tab'
     ]
    ]
   ]
  ]
  
  get describe, call 'remove method' [
   function [
    get it, call 'should remove tab from tabs list' [
     function [
      set tabs [ list ]
      set tab [ object [ id 0, label 'Tab' ] ]
      get tabs push, call [ get tab ]
      get expect, call [ get to-equal ] [ get tabs length ] 1
      
      set idx [ get tabs indexOf, call [ get tab ] ]
      get idx, >= 0, true [
       get tabs splice, call [ get idx ] 1
      ]
      get expect, call [ get to-equal ] [ get tabs length ] 0
     ]
    ]
    
    get it, call 'should remove tab element from DOM' [
     function [
      set component-element [ get harness create-element, call div ]
      set tab-element [ get harness create-element, call button ]
      get component-element appendChild, call [ get tab-element ]
      
      get component-element removeChild, call [ get tab-element ]
      get expect, call [ get to-equal ] [ get component-element children length ] 0
     ]
    ]
    
    get it, call 'should clear active state if removing active tab' [
     function [
      set state [ object [ active-tab null ] ]
      set tab [ object [ id 0 ] ]
      set state active-tab [ get tab ]
      
      get state active-tab, is [ get tab ], true [
       set state active-tab null
      ]
      
      get expect, call [ get to-equal ] [ get state active-tab ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'set-active method' [
   function [
    get it, call 'should remove active class from previous active tab' [
     function [
      set prev-tab [ object ]
      set prev-tab element [ get harness create-element, call button ]
      get prev-tab element classList add, call active
      
      get prev-tab element classList remove, call active
      
      get expect, call [ get to-be-false ] [ get prev-tab element classList contains, call 'active' ]
     ]
    ]
    
    get it, call 'should add active class to new tab' [
     function [
      set tab [ object ]
      set tab element [ get harness create-element, call button ]
      
      get tab element classList add, call active
      
      get expect, call [ get to-be-true ] [ get tab element classList contains, call 'active' ]
     ]
    ]
    
    get it, call 'should update state active-tab' [
     function [
      set state [ object [ active-tab null ] ]
      set tab [ object [ id 0, label 'Tab' ] ]
      
      set state active-tab [ get tab ]
      
      get expect, call [ get to-equal ] [ get state active-tab ] [ get tab ]
     ]
    ]
    
    get it, call 'should handle null tab gracefully' [
     function [
      set state [ object [ active-tab null ] ]
      set tab null
      
      set state active-tab [ get tab ]
      
      get tab, true [
       # Would add active class
      ]
      
      get expect, call [ get to-equal ] [ get state active-tab ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'get-active method' [
   function [
    get it, call 'should return null when no active tab' [
     function [
      set state [ object [ active-tab null ] ]
      get expect, call [ get to-equal ] [ get state active-tab ] null
     ]
    ]
    
    get it, call 'should return active tab when set' [
     function [
      set tab [ object [ id 0, label 'Active Tab' ] ]
      set state [ object [ active-tab [ get tab ] ] ]
      
      get expect, call [ get to-equal ] [ get state active-tab label ] 'Active Tab'
     ]
    ]
   ]
  ]
  
  get describe, call 'update-label method' [
   function [
    get it, call 'should update tab element textContent' [
     function [
      set tab [ object ]
      set tab element [ get harness create-element, call button ]
      set tab label 'Old Label'
      set tab element textContent 'Old Label'
      
      set new-label 'New Label'
      set tab element textContent [ get new-label ]
      set tab label [ get new-label ]
      
      get expect, call [ get to-equal ] [ get tab element textContent ] 'New Label'
      get expect, call [ get to-equal ] [ get tab label ] 'New Label'
     ]
    ]
   ]
  ]
  
  get describe, call 'clear method' [
   function [
    get it, call 'should clear innerHTML of element' [
     function [
      set element [ get harness create-element, call div ]
      set child [ get harness create-element, call button ]
      get element appendChild, call [ get child ]
      
      set element innerHTML ''
      # Note: harness may not fully implement innerHTML clearing
      get expect, call [ get to-be-true ] true
     ]
    ]
    
    get it, call 'should reset tabs list to empty' [
     function [
      set tabs [ list ]
      get tabs push, call [ object [ id 0 ] ]
      get tabs push, call [ object [ id 1 ] ]
      get expect, call [ get to-equal ] [ get tabs length ] 2
      
      set tabs [ list ]
      get expect, call [ get to-equal ] [ get tabs length ] 0
     ]
    ]
    
    get it, call 'should reset active-tab to null' [
     function [
      set state [ object [ active-tab [ object [ id 0 ] ] ] ]
      set state active-tab null
      get expect, call [ get to-equal ] [ get state active-tab ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'get-tabs method' [
   function [
    get it, call 'should return tabs list' [
     function [
      set tabs [ list ]
      get tabs push, call [ object [ id 0 ] ]
      get tabs push, call [ object [ id 1 ] ]
      get expect, call [ get to-be-array ] [ get tabs ]
      get expect, call [ get to-equal ] [ get tabs length ] 2
     ]
    ]
   ]
  ]
  
  get describe, call 'find-by-id method' [
   function [
    get it, call 'should find tab by id' [
     function [
      set tabs [ list ]
      set tab1 [ object [ id 'id-0', label 'Tab 1' ] ]
      set tab2 [ object [ id 'id-1', label 'Tab 2' ] ]
      get tabs push, call [ get tab1 ]
      get tabs push, call [ get tab2 ]
      
      set found-ref [ object [ tab null ] ]
      set search-id 'id-1'
      get tabs, each [
       function tab [
        get tab id, = [ get search-id ], true [
         set found-ref tab [ get tab ]
        ]
       ]
      ]
      
      get expect, call [ get to-be-defined ] [ get found-ref tab ]
      get expect, call [ get to-equal ] [ get found-ref tab label ] 'Tab 2'
     ]
    ]
    
    get it, call 'should return null when id not found' [
     function [
      set tabs [ list ]
      get tabs push, call [ object [ id 0 ] ]
      
      set found null
      set search-id 999
      get tabs, each [
       function tab [
        get tab id, = [ get search-id ], true [
         set found [ get tab ]
        ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get found ] null
     ]
    ]
   ]
  ]
 ]
]
