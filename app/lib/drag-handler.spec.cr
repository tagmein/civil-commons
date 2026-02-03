# Tests for app/lib/drag-handler.cr
# Tests drag handler utility functionality

get describe, call 'drag-handler' [
 function [
  get describe, call 'create function' [
   function [
    get it, call 'should return a function' [
     function [
      set component [ object ]
      set onStart [ function event comp [ object [ started true ] ] ]
      set onMove [ function event startX startY state comp deltaX deltaY [ ] ]
      set onEnd [ function state comp [ ] ]
      
      set handler [ function event [ ] ]
      
      get expect, call [ get to-equal ] [ get handler, typeof ] 'function'
     ]
    ]
    
    get it, call 'should capture startX and startY from event.clientX/Y' [
     function [
      set event [ object [ clientX 100, clientY 200 ] ]
      set startX [ get event clientX ]
      set startY [ get event clientY ]
      
      get expect, call [ get to-equal ] [ get startX ] 100
      get expect, call [ get to-equal ] [ get startY ] 200
     ]
    ]
    
    get it, call 'should call onStart with event and component' [
     function [
      set called [ object [ value false, event null, component null ] ]
      set component [ object [ name 'test-component' ] ]
      set event [ object [ clientX 50, clientY 75 ] ]
      
      set onStart [ function evt comp [
       set called value true
       set called event [ get evt ]
       set called component [ get comp ]
       object [ initialized true ]
      ] ]
      
      set state [ get onStart, call [ get event ] [ get component ] ]
      
      get expect, call [ get to-be-true ] [ get called value ]
      get expect, call [ get to-equal ] [ get called event clientX ] 50
      get expect, call [ get to-equal ] [ get called component name ] 'test-component'
      get expect, call [ get to-be-true ] [ get state initialized ]
     ]
    ]
    
    get it, call 'should call onMove with correct delta values' [
     function [
      set startX 100
      set startY 200
      set currentX 150
      set currentY 250
      
      set deltaX [ get currentX, subtract [ get startX ] ]
      set deltaY [ get currentY, subtract [ get startY ] ]
      
      get expect, call [ get to-equal ] [ get deltaX ] 50
      get expect, call [ get to-equal ] [ get deltaY ] 50
     ]
    ]
    
    get it, call 'should calculate negative deltas correctly' [
     function [
      set startX 200
      set startY 300
      set currentX 150
      set currentY 250
      
      set deltaX [ get currentX, subtract [ get startX ] ]
      set deltaY [ get currentY, subtract [ get startY ] ]
      
      get expect, call [ get to-equal ] [ get deltaX ] -50
      get expect, call [ get to-equal ] [ get deltaY ] -50
     ]
    ]
    
    get it, call 'should call onEnd with state and component' [
     function [
      set called [ object [ value false, state null, component null ] ]
      set component [ object [ name 'test' ] ]
      set state [ object [ dragging true ] ]
      
      set onEnd [ function st comp [
       set called value true
       set called state [ get st ]
       set called component [ get comp ]
      ] ]
      
      get onEnd, call [ get state ] [ get component ]
      
      get expect, call [ get to-be-true ] [ get called value ]
      get expect, call [ get to-be-true ] [ get called state dragging ]
      get expect, call [ get to-equal ] [ get called component name ] 'test'
     ]
    ]
   ]
  ]
  
  get describe, call 'event handling' [
   function [
    get it, call 'should stop propagation on mousedown' [
     function [
      set event [ object [ propagation-stopped false ] ]
      set event stopPropagation [ function [
       set event propagation-stopped true
      ] ]
      
      get event stopPropagation, call
      
      get expect, call [ get to-be-true ] [ get event propagation-stopped ]
     ]
    ]
    
    get it, call 'should prevent default on mousedown' [
     function [
      set event [ object [ default-prevented false ] ]
      set event preventDefault [ function [
       set event default-prevented true
      ] ]
      
      get event preventDefault, call
      
      get expect, call [ get to-be-true ] [ get event default-prevented ]
     ]
    ]
   ]
  ]
  
  get describe, call 'state management' [
   function [
    get it, call 'should pass state from onStart to onMove' [
     function [
      set state [ object [ startValue 'initial' ] ]
      
      get expect, call [ get to-equal ] [ get state startValue ] 'initial'
     ]
    ]
    
    get it, call 'should pass same state to onEnd' [
     function [
      set state [ object [ data 'preserved' ] ]
      
      # Simulating that state is passed through
      get expect, call [ get to-equal ] [ get state data ] 'preserved'
     ]
    ]
   ]
  ]
  
  get describe, call 'document event listeners' [
   function [
    get it, call 'should track mouse move events' [
     function [
      set move-count [ object [ value 0 ] ]
      
      set handleMousemove [ function event [
       set move-count value [ get move-count value, add 1 ]
      ] ]
      
      # Simulate multiple move events
      get handleMousemove, call [ object [ clientX 10, clientY 20 ] ]
      get handleMousemove, call [ object [ clientX 20, clientY 30 ] ]
      get handleMousemove, call [ object [ clientX 30, clientY 40 ] ]
      
      get expect, call [ get to-equal ] [ get move-count value ] 3
     ]
    ]
    
    get it, call 'should clean up event listeners on mouseup' [
     function [
      set cleanup-called [ object [ value false ] ]
      
      set handleMouseup [ function event [
       set cleanup-called value true
      ] ]
      
      get handleMouseup, call [ object [ type mouseup ] ]
      
      get expect, call [ get to-be-true ] [ get cleanup-called value ]
     ]
    ]
   ]
  ]
 ]
]
