# Tests for app/modules/session/service.cr
# Tests session service functionality

get describe, call 'session-service' [
 function [
  get describe, call 'event system' [
   function [
    get it, call 'should store listeners by event name' [
     function [
      set listeners [ object [ change [ list ], tabsChange [ list ] ] ]
      get expect, call [ get to-be-array ] [ get listeners change ]
      get expect, call [ get to-be-array ] [ get listeners tabsChange ]
     ]
    ]
    
    get it, call 'should add listener to correct array' [
     function [
      set listeners [ object [ change [ list ] ] ]
      set callback [ function [ ] ]
      get listeners change push, call [ get callback ]
      get expect, call [ get to-equal ] [ get listeners change length ] 1
     ]
    ]
    
    get it, call 'should emit to all listeners' [
     function [
      set call-count [ object [ value 0 ] ]
      set listeners [ object [ test [ list ] ] ]
      
      get listeners test push, call [ function data [ set call-count value [ get call-count value, add 1 ] ] ]
      get listeners test push, call [ function data [ set call-count value [ get call-count value, add 1 ] ] ]
      
      get listeners test, each [ function cb [ get cb, call 'data' ] ]
      
      get expect, call [ get to-equal ] [ get call-count value ] 2
     ]
    ]
   ]
  ]
  
  get describe, call 'session ID management' [
   function [
    get it, call 'should parse JSON array from storage' [
     function [
      set stored '["id1","id2","id3"]'
      set result [ global JSON parse, call [ get stored ] ]
      get expect, call [ get to-be-array ] [ get result ]
      get expect, call [ get to-equal ] [ get result length ] 3
     ]
    ]
    
    get it, call 'should use reference object pattern for parsing' [
     function [
      set stored '["abc123","def456"]'
      set ref [ object [ result [ list ] ] ]
      
      get stored, true [
       try [
        set ref result [ global JSON parse, call [ get stored ] ]
       ] [ ]
      ]
      
      get expect, call [ get to-be-array ] [ get ref result ]
      get expect, call [ get to-equal ] [ get ref result length ] 2
     ]
    ]
    
    get it, call 'should default to empty list on parse error' [
     function [
      set stored 'invalid json'
      set ref [ object [ result [ list ] ] ]
      
      try [
       set ref result [ global JSON parse, call [ get stored ] ]
      ] [ ]
      
      get expect, call [ get to-be-array ] [ get ref result ]
     ]
    ]
   ]
  ]
  
  get describe, call 'already-open detection' [
   function [
    get it, call 'should detect session is not open' [
     function [
      set open-ids [ list 'id1' 'id2' ]
      set target-id 'id3'
      set already-open [ object [ value false ] ]
      
      get open-ids, each [
       function id [
        get id, is [ get target-id ], true [ set already-open value true ]
       ]
      ]
      
      get expect, call [ get to-be-false ] [ get already-open value ]
     ]
    ]
    
    get it, call 'should detect session is already open' [
     function [
      set open-ids [ list 'id1' 'id2' ]
      set target-id 'id2'
      set already-open [ object [ value false ] ]
      
      get open-ids, each [
       function id [
        get id, is [ get target-id ], true [ set already-open value true ]
       ]
      ]
      
      get expect, call [ get to-be-true ] [ get already-open value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'session filtering' [
   function [
    get it, call 'should separate active and archived sessions' [
     function [
      set session1 [ object [ id 'id1', archived false ] ]
      set session2 [ object [ id 'id2', archived true ] ]
      set session3 [ object [ id 'id3', archived false ] ]
      set sessions [ list ]
      get sessions push, call [ get session1 ]
      get sessions push, call [ get session2 ]
      get sessions push, call [ get session3 ]
      
      set active [ list ]
      set archived-list [ list ]
      
      get sessions, each [
       function session [
        get session archived, = true, true [
         get archived-list push, call [ get session ]
        ], false [
         get active push, call [ get session ]
        ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get active length ] 2
      get expect, call [ get to-equal ] [ get archived-list length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'rename session event' [
   function [
    get it, call 'should emit sessionRenamed event with id and new name' [
     function [
      # Set up listeners to track events
      set listeners [ object [ sessionRenamed [ list ] ] ]
      set emit [ function event-name data [
       get listeners [ get event-name ], each [
        function callback [
         get callback, call [ get data ]
        ]
       ]
      ] ]
      
      # Track received event data
      set received [ object [ id null, name null ] ]
      get listeners sessionRenamed push, call [
       function data [
        set received id [ get data id ]
        set received name [ get data name ]
       ]
      ]
      
      # Simulate rename-session emitting sessionRenamed event
      set session-id 'test-session-123'
      set new-name 'My Renamed Session'
      get emit, call sessionRenamed [ object [ id [ get session-id ], name [ get new-name ] ] ]
      
      get expect, call [ get to-equal ] [ get received id ] 'test-session-123'
      get expect, call [ get to-equal ] [ get received name ] 'My Renamed Session'
     ]
    ]
   ]
  ]
 ]
]
