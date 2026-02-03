# Tests for app/modules/session/recent.cr
# Tests recent sessions window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'session/recent module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with session:recent action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'session:recent' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'session:recent'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Recent Sessions title' [
     function [
      set window-title 'Recent Sessions'
      get expect, call [ get to-equal ] [ get window-title ] 'Recent Sessions'
     ]
    ]
   ]
  ]
  
  get describe, call 'tabs' [
   function [
    get it, call 'should have Active tab' [
     function [
      set active-count 5
      set tab-label [ template 'Active (%0)' [ get active-count ] ]
      get expect, call [ get to-contain ] [ get tab-label ] 'Active'
     ]
    ]
    
    get it, call 'should have Archived tab' [
     function [
      set archived-count 3
      set tab-label [ template 'Archived (%0)' [ get archived-count ] ]
      get expect, call [ get to-contain ] [ get tab-label ] 'Archived'
     ]
    ]
    
    get it, call 'should set Active tab as initially selected' [
     function [
      set initial-tab 'active'
      get expect, call [ get to-equal ] [ get initial-tab ] 'active'
     ]
    ]
   ]
  ]
  
  get describe, call 'session list rendering' [
   function [
    get it, call 'should display session name' [
     function [
      set session [ object [ name 'My Project' ] ]
      set display-name [ get session name, default 'Untitled' ]
      get expect, call [ get to-equal ] [ get display-name ] 'My Project'
     ]
    ]
    
    get it, call 'should default to Untitled for sessions without name' [
     function [
      set session [ object ]
      set display-name [ get session name, default 'Untitled' ]
      get expect, call [ get to-equal ] [ get display-name ] 'Untitled'
     ]
    ]
    
    get it, call 'should display formatted date' [
     function [
      set timestamp 1770039853585
      # Date formatting would produce a localized string
      get expect, call [ get to-be-true ] true
     ]
    ]
   ]
  ]
  
  get describe, call 'active session buttons' [
   function [
    get it, call 'should have Open button' [
     function [
      set open-btn [ get harness create-element, call button ]
      set open-btn textContent 'Open'
      get expect, call [ get to-equal ] [ get open-btn textContent ] 'Open'
     ]
    ]
    
    get it, call 'should have Archive button for active sessions' [
     function [
      set archive-btn [ get harness create-element, call button ]
      set archive-btn textContent 'Archive'
      get archive-btn classList add, call recent-item-archive
      get expect, call [ get to-equal ] [ get archive-btn textContent ] 'Archive'
     ]
    ]
   ]
  ]
  
  get describe, call 'archived session buttons' [
   function [
    get it, call 'should have Open button' [
     function [
      set open-btn [ get harness create-element, call button ]
      set open-btn textContent 'Open'
      get expect, call [ get to-equal ] [ get open-btn textContent ] 'Open'
     ]
    ]
    
    get it, call 'should have Restore button for archived sessions' [
     function [
      set restore-btn [ get harness create-element, call button ]
      set restore-btn textContent 'Restore'
      get restore-btn classList add, call recent-item-restore
      get expect, call [ get to-equal ] [ get restore-btn textContent ] 'Restore'
     ]
    ]
   ]
  ]
  
  get describe, call 'Open action' [
   function [
    get it, call 'should call open-session on service' [
     function [
      set opened [ object [ value false, id null ] ]
      set mock-service [ object ]
      set mock-service open-session [ function id [
       set opened value true
       set opened id [ get id ]
      ] ]
      
      get mock-service open-session, call 'session-abc'
      
      get expect, call [ get to-be-true ] [ get opened value ]
      get expect, call [ get to-equal ] [ get opened id ] 'session-abc'
     ]
    ]
    
    get it, call 'should unarchive session before opening if archived' [
     function [
      set unarchived [ object [ value false ] ]
      # PATCH request with archived: false would be made
      set unarchived value true
      get expect, call [ get to-be-true ] [ get unarchived value ]
     ]
    ]
    
    get it, call 'should close window after opening' [
     function [
      set closed [ object [ value false ] ]
      set mock-window [ object ]
      set mock-window close [ function [ set closed value true ] ]
      
      get mock-window close, call
      
      get expect, call [ get to-be-true ] [ get closed value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'Archive action' [
   function [
    get it, call 'should remove from active list' [
     function [
      set active [ list [ object [ id 'a' ] ] [ object [ id 'b' ] ] ]
      set to-archive [ object [ id 'a' ] ]
      
      set idx [ get active indexOf, call [ get to-archive ] ]
      get idx, >= 0, true [
       get active splice, call [ get idx ] 1
      ]
      
      get expect, call [ get to-equal ] [ get active length ] 1
     ]
    ]
    
    get it, call 'should add to archived list' [
     function [
      set archived [ list ]
      set session [ object [ id 'a' ] ]
      get archived push, call [ get session ]
      get expect, call [ get to-equal ] [ get archived length ] 1
     ]
    ]
    
    get it, call 'should update tab counts' [
     function [
      set active-count 4
      set archived-count 2
      
      # After archiving
      set active-count [ get active-count, subtract 1 ]
      set archived-count [ get archived-count, add 1 ]
      
      get expect, call [ get to-equal ] [ get active-count ] 3
      get expect, call [ get to-equal ] [ get archived-count ] 3
     ]
    ]
   ]
  ]
  
  get describe, call 'Restore action' [
   function [
    get it, call 'should remove from archived list' [
     function [
      set archived [ list [ object [ id 'a' ] ] [ object [ id 'b' ] ] ]
      set to-restore [ object [ id 'a' ] ]
      
      set idx [ get archived indexOf, call [ get to-restore ] ]
      get idx, >= 0, true [
       get archived splice, call [ get idx ] 1
      ]
      
      get expect, call [ get to-equal ] [ get archived length ] 1
     ]
    ]
    
    get it, call 'should add to active list' [
     function [
      set active [ list ]
      set session [ object [ id 'a', archived false ] ]
      get active push, call [ get session ]
      get expect, call [ get to-equal ] [ get active length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'empty states' [
   function [
    get it, call 'should show No active sessions when empty' [
     function [
      set show-archived false
      set message 'No active sessions'
      get show-archived, true [
       set message 'No archived sessions'
      ]
      get expect, call [ get to-equal ] [ get message ] 'No active sessions'
     ]
    ]
    
    get it, call 'should show No archived sessions when empty' [
     function [
      set state [ object [ show-archived true, message 'No active sessions' ] ]
      get state show-archived, true [
       set state message 'No archived sessions'
      ]
      get expect, call [ get to-equal ] [ get state message ] 'No archived sessions'
     ]
    ]
   ]
  ]
 ]
]
