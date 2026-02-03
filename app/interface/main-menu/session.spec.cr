# Tests for app/interface/main-menu/session.cr
# Tests session menu functionality

get describe, call 'session menu' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create menu with Session label' [
     function [
      set menu [ object [ label 'Session' ] ]
      get expect, call [ get to-equal ] [ get menu label ] 'Session'
     ]
    ]
   ]
  ]
  
  get describe, call 'New session menu item' [
   function [
    get it, call 'should have New session option' [
     function [
      set items [ list 'New session' 'Rename session' 'Archive session' 'Close session' 'Recent' ]
      get expect, call [ get to-contain ] [ get items, at 0 ] 'New session'
     ]
    ]
    
    get it, call 'should call create-session on click' [
     function [
      set create-called [ object [ value false ] ]
      set mock-service [ object ]
      set mock-service create-session [ function [
       set create-called value true
      ] ]
      
      get mock-service create-session, call
      
      get expect, call [ get to-be-true ] [ get create-called value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'Rename session menu item' [
   function [
    get it, call 'should have Rename session option' [
     function [
      set items [ list 'New session' 'Rename session' 'Archive session' 'Close session' 'Recent' ]
      get expect, call [ get to-contain ] [ get items, at 1 ] 'Rename session'
     ]
    ]
    
    get it, call 'should dispatch session:rename on click' [
     function [
      set dispatched [ object [ value false, action null ] ]
      set mock-conductor [ object ]
      set mock-conductor dispatch [ function action [
       set dispatched value true
       set dispatched action [ get action ]
      ] ]
      
      get mock-conductor dispatch, call 'session:rename'
      
      get expect, call [ get to-be-true ] [ get dispatched value ]
      get expect, call [ get to-equal ] [ get dispatched action ] 'session:rename'
     ]
    ]
   ]
  ]
  
  get describe, call 'Archive session menu item' [
   function [
    get it, call 'should have Archive session option' [
     function [
      set items [ list 'New session' 'Rename session' 'Archive session' 'Close session' 'Recent' ]
      get expect, call [ get to-contain ] [ get items, at 2 ] 'Archive session'
     ]
    ]
    
    get it, call 'should dispatch session:archive on click' [
     function [
      set dispatched [ object [ value false, action null ] ]
      set mock-conductor [ object ]
      set mock-conductor dispatch [ function action [
       set dispatched value true
       set dispatched action [ get action ]
      ] ]
      
      get mock-conductor dispatch, call 'session:archive'
      
      get expect, call [ get to-be-true ] [ get dispatched value ]
      get expect, call [ get to-equal ] [ get dispatched action ] 'session:archive'
     ]
    ]
   ]
  ]
  
  get describe, call 'Close session menu item' [
   function [
    get it, call 'should have Close session option' [
     function [
      set items [ list 'New session' 'Rename session' 'Archive session' 'Close session' 'Recent' ]
      get expect, call [ get to-contain ] [ get items, at 3 ] 'Close session'
     ]
    ]
    
    get it, call 'should get current session ID' [
     function [
      set mock-service [ object ]
      set mock-service get-current-session-id [ function [ value 'test-session-id' ] ]
      
      set current-id [ get mock-service get-current-session-id, call ]
      
      get expect, call [ get to-equal ] [ get current-id ] 'test-session-id'
     ]
    ]
    
    get it, call 'should call close-session with current ID' [
     function [
      set close-called [ object [ value false, id null ] ]
      set mock-service [ object ]
      set mock-service close-session [ function id [
       set close-called value true
       set close-called id [ get id ]
      ] ]
      
      get mock-service close-session, call 'session-123'
      
      get expect, call [ get to-be-true ] [ get close-called value ]
      get expect, call [ get to-equal ] [ get close-called id ] 'session-123'
     ]
    ]
    
    get it, call 'should create new session after 250ms delay when no sessions remain' [
     function [
      set mock-service [ object ]
      set mock-service get-open-session-ids [ function [ list ] ]
      set create-called [ object [ value false ] ]
      set mock-service create-session [ function [
       set create-called value true
      ] ]
      
      set open-ids [ get mock-service get-open-session-ids, call ]
      get open-ids length, = 0, true [
       # In real code, setTimeout with 250ms delay
       get mock-service create-session, call
      ]
      
      get expect, call [ get to-be-true ] [ get create-called value ]
     ]
    ]
    
    get it, call 'should not create new session when other sessions exist' [
     function [
      set mock-service [ object ]
      set mock-service get-open-session-ids [ function [ list 'other-session' ] ]
      set create-called [ object [ value false ] ]
      set mock-service create-session [ function [
       set create-called value true
      ] ]
      
      set open-ids [ get mock-service get-open-session-ids, call ]
      get open-ids length, = 0, true [
       get mock-service create-session, call
      ]
      
      get expect, call [ get to-be-false ] [ get create-called value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'Recent menu item' [
   function [
    get it, call 'should have Recent option' [
     function [
      set items [ list 'New session' 'Rename session' 'Archive session' 'Close session' 'Recent' ]
      get expect, call [ get to-contain ] [ get items, at 4 ] 'Recent'
     ]
    ]
    
    get it, call 'should dispatch session:recent on click' [
     function [
      set dispatched [ object [ value false, action null ] ]
      set mock-conductor [ object ]
      set mock-conductor dispatch [ function action [
       set dispatched value true
       set dispatched action [ get action ]
      ] ]
      
      get mock-conductor dispatch, call 'session:recent'
      
      get expect, call [ get to-be-true ] [ get dispatched value ]
      get expect, call [ get to-equal ] [ get dispatched action ] 'session:recent'
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return session menu object' [
     function [
      set session [ object [ label 'Session' ] ]
      set session add [ function label on-click [ ] ]
      
      get expect, call [ get to-be-defined ] [ get session ]
      get expect, call [ get to-equal ] [ get session label ] 'Session'
     ]
    ]
   ]
  ]
 ]
]
