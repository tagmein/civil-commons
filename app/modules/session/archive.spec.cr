# Tests for app/modules/session/archive.cr
# Tests session archive confirmation window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'session/archive module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with session:archive action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'session:archive' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'session:archive'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Archive Session title' [
     function [
      set window-title 'Archive Session'
      get expect, call [ get to-equal ] [ get window-title ] 'Archive Session'
     ]
    ]
   ]
  ]
  
  get describe, call 'confirmation message' [
   function [
    get it, call 'should show confirmation question' [
     function [
      set message "Are you sure you'd like to archive this session?"
      get expect, call [ get to-contain ] [ get message ] 'archive'
     ]
    ]
   ]
  ]
  
  get describe, call 'buttons' [
   function [
    get it, call 'should have Cancel button' [
     function [
      set cancel-btn [ get harness create-element, call button ]
      set cancel-btn textContent 'Cancel'
      get expect, call [ get to-equal ] [ get cancel-btn textContent ] 'Cancel'
     ]
    ]
    
    get it, call 'should have Archive button with danger class' [
     function [
      set archive-btn [ get harness create-element, call button ]
      set archive-btn textContent 'Archive'
      get archive-btn classList add, call danger
      get expect, call [ get to-equal ] [ get archive-btn textContent ] 'Archive'
      get expect, call [ get to-be-true ] [ get archive-btn classList contains, call 'danger' ]
     ]
    ]
   ]
  ]
  
  get describe, call 'archive action' [
   function [
    get it, call 'should call archive-session on service' [
     function [
      set archived [ object [ value false, id null ] ]
      set mock-service [ object ]
      set mock-service archive-session [ function id [
       set archived value true
       set archived id [ get id ]
      ] ]
      
      get mock-service archive-session, call 'session-123'
      
      get expect, call [ get to-be-true ] [ get archived value ]
      get expect, call [ get to-equal ] [ get archived id ] 'session-123'
     ]
    ]
    
    get it, call 'should create new session if no sessions remain' [
     function [
      set mock-service [ object ]
      set mock-service get-open-session-ids [ function [ list ] ]
      set created [ object [ value false ] ]
      set mock-service create-session [ function [ set created value true ] ]
      
      set open-ids [ get mock-service get-open-session-ids, call ]
      get open-ids length, = 0, true [
       get mock-service create-session, call
      ]
      
      get expect, call [ get to-be-true ] [ get created value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'window closing' [
   function [
    get it, call 'should close window on Cancel' [
     function [
      set window-closed [ object [ value false ] ]
      set mock-window [ object ]
      set mock-window close [ function [ set window-closed value true ] ]
      
      get mock-window close, call
      
      get expect, call [ get to-be-true ] [ get window-closed value ]
     ]
    ]
    
    get it, call 'should close window after Archive' [
     function [
      set window-closed [ object [ value false ] ]
      set mock-window [ object ]
      set mock-window close [ function [ set window-closed value true ] ]
      
      get mock-window close, call
      
      get expect, call [ get to-be-true ] [ get window-closed value ]
     ]
    ]
   ]
  ]
 ]
]
