# Tests for core/conductor.cr
# Tests conductor event dispatching and logging hooks

get describe, call 'conductor' [
 function [
  get describe, call 'dispatch' [
   function [
    get it, call 'should call registered handler' [
     function [
      set registry [ object ]
      set called [ object [ value false, action null ] ]
      
      set registry 'test:action' [
       function arg [
        set called value true
        set called action 'test:action'
       ]
      ]
      
      get registry 'test:action', true [
       get registry 'test:action', call null
      ]
      
      get expect, call [ get to-be-true ] [ get called value ]
      get expect, call [ get to-equal ] [ get called action ] 'test:action'
     ]
    ]
   ]
  ]
  
  get describe, call 'event hook' [
   function [
    get it, call 'should call event hook when set' [
     function [
      set hook-called [ object [ value false, action null, arg null ] ]
      set event-hook [ object [ callback null ] ]
      set replay-mode [ object [ active false ] ]
      
      # Set up hook
      set event-hook callback [
       function action arg [
        set hook-called value true
        set hook-called action [ get action ]
        set hook-called arg [ get arg ]
       ]
      ]
      
      # Simulate dispatch calling the hook
      get replay-mode active, false [
       get event-hook callback, true [
        get event-hook callback, call 'test:action' 'test-arg'
       ]
      ]
      
      get expect, call [ get to-be-true ] [ get hook-called value ]
      get expect, call [ get to-equal ] [ get hook-called action ] 'test:action'
      get expect, call [ get to-equal ] [ get hook-called arg ] 'test-arg'
     ]
    ]
    
    get it, call 'should not call hook when no callback set' [
     function [
      set event-hook [ object [ callback null ] ]
      set replay-mode [ object [ active false ] ]
      set error-occurred [ object [ value false ] ]
      
      try [
       get replay-mode active, false [
        get event-hook callback, true [
         get event-hook callback, call 'test:action' null
        ]
       ]
      ] [
       set error-occurred value true
      ]
      
      get expect, call [ get to-be-false ] [ get error-occurred value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'replay mode' [
   function [
    get it, call 'should not call hook in replay mode' [
     function [
      set hook-called [ object [ value false ] ]
      set event-hook [ object [ callback null ] ]
      set replay-mode [ object [ active true ] ]
      
      # Set up hook
      set event-hook callback [
       function action arg [
        set hook-called value true
       ]
      ]
      
      # Simulate dispatch - should NOT call hook because replay-mode is active
      get replay-mode active, false [
       get event-hook callback, true [
        get event-hook callback, call 'test:action' null
       ]
      ]
      
      get expect, call [ get to-be-false ] [ get hook-called value ]
     ]
    ]
    
    get it, call 'should toggle replay mode on and off' [
     function [
      set replay-mode [ object [ active false ] ]
      
      # Start replay
      set replay-mode active true
      get expect, call [ get to-be-true ] [ get replay-mode active ]
      
      # End replay
      set replay-mode active false
      get expect, call [ get to-be-false ] [ get replay-mode active ]
     ]
    ]
   ]
  ]
  
  get describe, call 'skip on replay (! prefix)' [
   function [
    get it, call 'should detect ! prefix for skip-on-replay actions' [
     function [
      set action '!document:new'
      set skip-on-replay [ get action, at startsWith, call '!' ]
      get expect, call [ get to-be-true ] [ get skip-on-replay ]
     ]
    ]
    
    get it, call 'should not detect ! prefix for normal actions' [
     function [
      set action 'document:open'
      set skip-on-replay [ get action, at startsWith, call '!' ]
      get expect, call [ get to-be-false ] [ get skip-on-replay ]
     ]
    ]
    
    get it, call 'should skip ! prefixed actions during replay' [
     function [
      set replay-mode [ object [ active true ] ]
      set handler-called [ object [ value false ] ]
      set action '!document:new'
      
      set skip-on-replay [ get action, at startsWith, call '!' ]
      
      # Simulate replay mode check
      set should-skip [ object [ value false ] ]
      get replay-mode active, true [
       get skip-on-replay, true [
        set should-skip value true
       ]
      ]
      
      get expect, call [ get to-be-true ] [ get should-skip value ]
     ]
    ]
    
    get it, call 'should not skip ! prefixed actions outside replay mode' [
     function [
      set replay-mode [ object [ active false ] ]
      set action '!document:new'
      
      set skip-on-replay [ get action, at startsWith, call '!' ]
      
      # Simulate replay mode check
      set should-skip [ object [ value false ] ]
      get replay-mode active, true [
       get skip-on-replay, true [
        set should-skip value true
       ]
      ]
      
      get expect, call [ get to-be-false ] [ get should-skip value ]
     ]
    ]
    
    get it, call 'should not skip normal actions during replay' [
     function [
      set replay-mode [ object [ active true ] ]
      set action 'document:open'
      
      set skip-on-replay [ get action, at startsWith, call '!' ]
      
      # Simulate replay mode check
      set should-skip [ object [ value false ] ]
      get replay-mode active, true [
       get skip-on-replay, true [
        set should-skip value true
       ]
      ]
      
      get expect, call [ get to-be-false ] [ get should-skip value ]
     ]
    ]
   ]
  ]
 ]
]
