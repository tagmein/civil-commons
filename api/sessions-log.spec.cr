# Tests for api/sessions-log.cr
# Tests session event log API endpoints

set fs [ global import, call fs/promises ]
set test-data-path './test-data-log'

set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]
set data-path [ get test-data-path ]

set api-sessions-log [ load ./sessions-log.cr, point ]

# Cleanup after tests
set afterAll [
 get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
]

get describe, call 'sessions-log API' [
 function [
  get describe, call 'GET handler' [
   function [
    get it, call 'should return empty array when no log exists' [
     function [
      set result [ get api-sessions-log get-handler, call 'no-log-session' ]
      get expect, call [ get to-be-array ] [ get result ]
      get expect, call [ get to-equal ] [ get result length ] 0
     ]
    ]
    
    get it, call 'should return events when log exists' [
     function [
      # Create a log file manually
      set session-id 'test-get-session'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      set log-data [ list ]
      get log-data push, call [ object [ action 'test:action', arg null, timestamp 1234567890 ] ]
      get log-data push, call [ object [ action 'test:action2', arg 'arg-value', timestamp 1234567891 ] ]
      get oj, call [ template '%0/log.json' [ get session-dir ] ] [ get log-data ]
      
      set result [ get api-sessions-log get-handler, call [ get session-id ] ]
      get expect, call [ get to-be-array ] [ get result ]
      get expect, call [ get to-equal ] [ get result length ] 2
      get expect, call [ get to-equal ] [ get result, at 0, at action ] 'test:action'
      get expect, call [ get to-equal ] [ get result, at 1, at action ] 'test:action2'
     ]
    ]
   ]
  ]
  
  get describe, call 'POST handler' [
   function [
    get it, call 'should add event to empty log' [
     function [
      set session-id 'test-post-empty'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      set body [ object [ action 'commons:about', arg null ] ]
      set result [ get api-sessions-log post-handler, call [ get session-id ] [ get body ] ]
      
      get expect, call [ get to-equal ] [ get result index ] 0
      get expect, call [ get to-equal ] [ get result event action ] 'commons:about'
      get expect, call [ get to-be-defined ] [ get result event timestamp ]
     ]
    ]
    
    get it, call 'should append event to existing log' [
     function [
      set session-id 'test-post-existing'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      # Create existing log
      set existing-log [ list ]
      get existing-log push, call [ object [ action 'first:action', arg null, timestamp 1000 ] ]
      get oj, call [ template '%0/log.json' [ get session-dir ] ] [ get existing-log ]
      
      # Add new event
      set body [ object [ action 'second:action', arg 'test-arg' ] ]
      set result [ get api-sessions-log post-handler, call [ get session-id ] [ get body ] ]
      
      get expect, call [ get to-equal ] [ get result index ] 1
      get expect, call [ get to-equal ] [ get result event action ] 'second:action'
      get expect, call [ get to-equal ] [ get result event arg ] 'test-arg'
      
      # Verify log file has both events
      set log [ get ij, call [ template '%0/log.json' [ get session-dir ] ] ]
      get expect, call [ get to-equal ] [ get log length ] 2
     ]
    ]
   ]
  ]
  
  get describe, call 'DELETE handler' [
   function [
    get it, call 'should return 404 when log does not exist' [
     function [
      set result [ get api-sessions-log delete-handler, call 'nonexistent-session' '0' ]
      get expect, call [ get to-equal ] [ get result status ] 404
     ]
    ]
    
    get it, call 'should return 400 for invalid index' [
     function [
      set session-id 'test-delete-invalid'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      set log-data [ list ]
      get log-data push, call [ object [ action 'test:action', arg null, timestamp 1000 ] ]
      get oj, call [ template '%0/log.json' [ get session-dir ] ] [ get log-data ]
      
      # Test negative index
      set result [ get api-sessions-log delete-handler, call [ get session-id ] '-1' ]
      get expect, call [ get to-equal ] [ get result status ] 400
     ]
    ]
    
    get it, call 'should return 400 for out of bounds index' [
     function [
      set session-id 'test-delete-oob'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      set log-data [ list ]
      get log-data push, call [ object [ action 'test:action', arg null, timestamp 1000 ] ]
      get oj, call [ template '%0/log.json' [ get session-dir ] ] [ get log-data ]
      
      set result [ get api-sessions-log delete-handler, call [ get session-id ] '5' ]
      get expect, call [ get to-equal ] [ get result status ] 400
     ]
    ]
    
    get it, call 'should delete event at index' [
     function [
      set session-id 'test-delete-success'
      set session-dir [ template '%0/sessions/%1' [ get test-data-path ] [ get session-id ] ]
      get ensure-dir, call [ get session-dir ]
      
      set log-data [ list ]
      get log-data push, call [ object [ action 'first:action', arg null, timestamp 1000 ] ]
      get log-data push, call [ object [ action 'second:action', arg null, timestamp 2000 ] ]
      get log-data push, call [ object [ action 'third:action', arg null, timestamp 3000 ] ]
      get oj, call [ template '%0/log.json' [ get session-dir ] ] [ get log-data ]
      
      # Delete middle event
      set result [ get api-sessions-log delete-handler, call [ get session-id ] '1' ]
      get expect, call [ get to-be-true ] [ get result success ]
      get expect, call [ get to-equal ] [ get result remaining ] 2
      
      # Verify log file
      set log [ get ij, call [ template '%0/log.json' [ get session-dir ] ] ]
      get expect, call [ get to-equal ] [ get log length ] 2
      get expect, call [ get to-equal ] [ get log, at 0, at action ] 'first:action'
      get expect, call [ get to-equal ] [ get log, at 1, at action ] 'third:action'
     ]
    ]
   ]
  ]
 ]
]

get afterAll
