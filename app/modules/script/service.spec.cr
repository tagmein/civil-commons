# Tests for app/modules/script/service.cr

get describe, call 'script-service' [
 function [
  get describe, call 'event system' [
   function [
    get it, call 'should store listeners by event name' [
     function [
      set listeners [ object [ change [ list ], scriptRenamed [ list ] ] ]
      get expect, call [ get to-be-array ] [ get listeners change ]
      get expect, call [ get to-be-array ] [ get listeners scriptRenamed ]
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
      set listeners [ object [ scriptRenamed [ list ] ] ]
      get listeners scriptRenamed push, call [ function data [ set call-count value [ get call-count value, add 1 ] ] ]
      get listeners scriptRenamed push, call [ function data [ set call-count value [ get call-count value, add 1 ] ] ]
      get listeners scriptRenamed, each [ function cb [ get cb, call [ object [ id 'x', name 'y' ] ] ] ]
      get expect, call [ get to-equal ] [ get call-count value ] 2
     ]
    ]
   ]
  ]
  get describe, call 'current script and last-interacted' [
   function [
    get it, call 'should set last-interacted type to script when set-current-script-id called' [
     function [
      set main [ object [ last-interacted [ object [ type null, id null ] ] ] ]
      set current-script-ref [ object [ id null ] ]
      set set-current-script-id [ function id [
       set current-script-ref id [ get id ]
       set main last-interacted [ object [ type script, id [ get id ] ] ]
      ] ]
      get set-current-script-id, call 'script-123'
      get expect, call [ get to-equal ] [ get main last-interacted type ] 'script'
      get expect, call [ get to-equal ] [ get main last-interacted id ] 'script-123'
     ]
    ]
   ]
  ]
  get describe, call 'exports' [
   function [
    get it, call 'should export expected functions' [
     function [
      set exports [ list 'on' 'get-current-script-id' 'set-current-script-id' 'fetch-all-scripts' 'fetch-script' 'create-script' 'rename-script' 'save-script' ]
      get expect, call [ get to-equal ] [ get exports length ] 8
      get expect, call [ get to-contain ] [ get exports ] 'fetch-script'
      get expect, call [ get to-contain ] [ get exports ] 'create-script'
      get expect, call [ get to-contain ] [ get exports ] 'rename-script'
     ]
    ]
   ]
  ]
 ]
]
