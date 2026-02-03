# Tests for app/components/window-title-buttons.cr
# Tests window title bar buttons component

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'window-title-buttons component' [
 function [
  get describe, call 'component creation' [
   function [
    get it, call 'should create main element with window-title-bar-buttons class' [
     function [
      set element [ get harness create-element, call div ]
      get element classList add, call window-title-bar-buttons
      get expect, call [ get to-be-true ] [ get element classList contains, call 'window-title-bar-buttons' ]
     ]
    ]
    
    get it, call 'should create minimize button' [
     function [
      set minimize-button [ get harness create-element, call button ]
      get minimize-button classList add, call window-title-bar-button
      get expect, call [ get to-be-true ] [ get minimize-button classList contains, call 'window-title-bar-button' ]
     ]
    ]
    
    get it, call 'should create maximize button' [
     function [
      set maximize-button [ get harness create-element, call button ]
      get maximize-button classList add, call window-title-bar-button
      get expect, call [ get to-be-true ] [ get maximize-button classList contains, call 'window-title-bar-button' ]
     ]
    ]
    
    get it, call 'should create restore button' [
     function [
      set restore-button [ get harness create-element, call button ]
      get restore-button classList add, call window-title-bar-button
      get expect, call [ get to-be-true ] [ get restore-button classList contains, call 'window-title-bar-button' ]
     ]
    ]
    
    get it, call 'should create close button' [
     function [
      set close-button [ get harness create-element, call button ]
      get close-button classList add, call window-title-bar-button
      get expect, call [ get to-be-true ] [ get close-button classList contains, call 'window-title-bar-button' ]
     ]
    ]
    
    get it, call 'should hide restore button by default' [
     function [
      set restore-button [ object ]
      set restore-button style [ object [ display none ] ]
      get expect, call [ get to-equal ] [ get restore-button style display ] 'none'
     ]
    ]
   ]
  ]
  
  get describe, call 'button click handlers' [
   function [
    get it, call 'should call on-minimize when minimize clicked' [
     function [
      set called [ object [ value false ] ]
      set on-minimize [ function [ set called value true ] ]
      
      get on-minimize, true [
       get on-minimize, call
      ]
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should call on-maximize when maximize clicked' [
     function [
      set called [ object [ value false ] ]
      set on-maximize [ function [ set called value true ] ]
      
      get on-maximize, true [
       get on-maximize, call
      ]
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should call on-restore when restore clicked' [
     function [
      set called [ object [ value false ] ]
      set on-restore [ function [ set called value true ] ]
      
      get on-restore, true [
       get on-restore, call
      ]
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should call on-close when close clicked' [
     function [
      set called [ object [ value false ] ]
      set on-close [ function [ set called value true ] ]
      
      get on-close, true [
       get on-close, call
      ]
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should not error when on-minimize is null' [
     function [
      set on-minimize null
      get on-minimize, true [
       get on-minimize, call
      ]
      get expect, call [ get to-be-true ] true
     ]
    ]
    
    get it, call 'should not error when on-maximize is null' [
     function [
      set on-maximize null
      get on-maximize, true [
       get on-maximize, call
      ]
      get expect, call [ get to-be-true ] true
     ]
    ]
    
    get it, call 'should not error when on-restore is null' [
     function [
      set on-restore null
      get on-restore, true [
       get on-restore, call
      ]
      get expect, call [ get to-be-true ] true
     ]
    ]
    
    get it, call 'should not error when on-close is null' [
     function [
      set on-close null
      get on-close, true [
       get on-close, call
      ]
      get expect, call [ get to-be-true ] true
     ]
    ]
   ]
  ]
  
  get describe, call 'event propagation' [
   function [
    get it, call 'should stop propagation on button click' [
     function [
      set event [ object [ propagation-stopped false ] ]
      set event stopPropagation [ function [
       set event propagation-stopped true
      ] ]
      
      get event stopPropagation, call
      
      get expect, call [ get to-be-true ] [ get event propagation-stopped ]
     ]
    ]
   ]
  ]
  
  get describe, call 'button ordering' [
   function [
    get it, call 'should append buttons in correct order' [
     function [
      set container [ get harness create-element, call div ]
      set minimize [ get harness create-element, call button ]
      set maximize [ get harness create-element, call button ]
      set restore [ get harness create-element, call button ]
      set close [ get harness create-element, call button ]
      
      get container appendChild, call [ get minimize ]
      get container appendChild, call [ get maximize ]
      get container appendChild, call [ get restore ]
      get container appendChild, call [ get close ]
      
      get expect, call [ get to-equal ] [ get container children length ] 4
     ]
    ]
   ]
  ]
 ]
]
