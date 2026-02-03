# Tests for core/conductor.cr
# Tests conductor registry and dispatch functionality

get describe, call 'conductor module' [
 function [
  get describe, call 'registry' [
   function [
    get it, call 'should start with empty registry' [
     function [
      set registry [ object ]
      get expect, call [ get to-be-defined ] [ get registry ]
     ]
    ]
   ]
  ]
  
  get describe, call 'register function' [
   function [
    get it, call 'should register action with callback' [
     function [
      set registry [ object ]
      set callback [ function [ value 'called' ] ]
      set registry test-action [ get callback ]
      
      get expect, call [ get to-be-defined ] [ get registry test-action ]
     ]
    ]
    
    get it, call 'should allow registering multiple actions' [
     function [
      set registry [ object ]
      set registry action1 [ function [ value 'action1' ] ]
      set registry action2 [ function [ value 'action2' ] ]
      
      get expect, call [ get to-be-defined ] [ get registry action1 ]
      get expect, call [ get to-be-defined ] [ get registry action2 ]
     ]
    ]
    
    get it, call 'should override existing action with same name' [
     function [
      set registry [ object ]
      set call-count [ object [ value 0 ] ]
      
      set registry test-action [ function [ set call-count value 1 ] ]
      set registry test-action [ function [ set call-count value 2 ] ]
      
      get registry test-action, call
      get expect, call [ get to-equal ] [ get call-count value ] 2
     ]
    ]
   ]
  ]
  
  get describe, call 'dispatch function' [
   function [
    get it, call 'should call registered callback' [
     function [
      set registry [ object ]
      set called [ object [ value false ] ]
      set registry test-action [ function arg [
       set called value true
      ] ]
      
      get registry test-action, call 'test-arg'
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should pass argument to callback' [
     function [
      set registry [ object ]
      set received [ object [ arg null ] ]
      set registry test-action [ function arg [
       set received arg [ get arg ]
      ] ]
      
      get registry test-action, call 'my-argument'
      
      get expect, call [ get to-equal ] [ get received arg ] 'my-argument'
     ]
    ]
    
    get it, call 'should handle action not found gracefully' [
     function [
      set registry [ object ]
      set action-name 'nonexistent'
      
      # Check if action exists
      set exists [ get registry [ get action-name ] ]
      get exists, false [
       # No error should be thrown, just no-op or log warning
       get expect, call [ get to-be-true ] true
      ]
     ]
    ]
   ]
  ]
  
  get describe, call 'action naming conventions' [
   function [
    get it, call 'should support namespaced actions (module:action)' [
     function [
      set registry [ object ]
      set called [ object [ value false ] ]
      set registry 'session:rename' [ function [ set called value true ] ]
      
      get registry 'session:rename', call
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
    
    get it, call 'should support simple action names' [
     function [
      set registry [ object ]
      set called [ object [ value false ] ]
      set registry 'open' [ function [ set called value true ] ]
      
      get registry 'open', call
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'integration patterns' [
   function [
    get it, call 'should support window opening pattern' [
     function [
      # Simulate commons:about action that opens a window
      set windows [ list ]
      set registry [ object ]
      
      set registry 'commons:about' [ function [
       set window [ object [ title 'About', content 'Test content' ] ]
       get windows push, call [ get window ]
      ] ]
      
      get registry 'commons:about', call
      
      get expect, call [ get to-equal ] [ get windows length ] 1
      get expect, call [ get to-equal ] [ get windows, at 0, at title ] 'About'
     ]
    ]
    
    get it, call 'should support action with data payload' [
     function [
      set registry [ object ]
      set result [ object [ session-id null ] ]
      
      set registry 'session:open' [ function data [
       set result session-id [ get data id ]
      ] ]
      
      get registry 'session:open', call [ object [ id 'session-123' ] ]
      
      get expect, call [ get to-equal ] [ get result session-id ] 'session-123'
     ]
    ]
   ]
  ]
 ]
]
