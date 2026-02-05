# Tests for document recent module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'Document Recent Module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with document:recent action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'document:recent' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'document:recent'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Recent Documents title' [
     function [
      set window-title 'Recent Documents'
      get expect, call [ get to-equal ] [ get window-title ] 'Recent Documents'
     ]
    ]
    
    get it, call 'should create window with correct dimensions' [
     function [
      set height 400
      set width 450
      get expect, call [ get to-equal ] [ get height ] 400
      get expect, call [ get to-equal ] [ get width ] 450
     ]
    ]
   ]
  ]
  
  get describe, call 'document separation' [
   function [
    get it, call 'should separate active and archived documents' [
     function [
      set all-documents [ list ]
      get all-documents push, call [ object [ id 'doc-1', name 'Active Doc', archived false ] ]
      get all-documents push, call [ object [ id 'doc-2', name 'Archived Doc', archived true ] ]
      
      set active-documents [ list ]
      set archived-documents [ list ]
      
      get all-documents, each [
       function doc [
        get doc archived, = true, true [
         get archived-documents push, call [ get doc ]
        ], false [
         get active-documents push, call [ get doc ]
        ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get active-documents length ] 1
      get expect, call [ get to-equal ] [ get archived-documents length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'tab bar' [
   function [
    get it, call 'should create Active tab with count' [
     function [
      set active-count 3
      set label [ template 'Active (%0)' [ get active-count ] ]
      get expect, call [ get to-equal ] [ get label ] 'Active (3)'
     ]
    ]
    
    get it, call 'should create Archived tab with count' [
     function [
      set archived-count 2
      set label [ template 'Archived (%0)' [ get archived-count ] ]
      get expect, call [ get to-equal ] [ get label ] 'Archived (2)'
     ]
    ]
   ]
  ]
  
  get describe, call 'empty state' [
   function [
    get it, call 'should show No active documents when empty' [
     function [
      set documents [ list ]
      set show-archived false
      set message-ref [ object [ msg '' ] ]
      
      get documents length, = 0, true [
       get show-archived, true [
        set message-ref msg 'No archived documents'
       ], false [
        set message-ref msg 'No active documents'
       ]
      ]
      
      get expect, call [ get to-equal ] [ get message-ref msg ] 'No active documents'
     ]
    ]
    
    get it, call 'should show No archived documents when empty' [
     function [
      set documents [ list ]
      set show-archived true
      set message-ref [ object [ msg '' ] ]
      
      get documents length, = 0, true [
       get show-archived, true [
        set message-ref msg 'No archived documents'
       ], false [
        set message-ref msg 'No active documents'
       ]
      ]
      
      get expect, call [ get to-equal ] [ get message-ref msg ] 'No archived documents'
     ]
    ]
   ]
  ]
  
  get describe, call 'buttons' [
   function [
    get it, call 'should have Open button' [
     function [
      set btn [ get harness create-element, call button ]
      set btn textContent 'Open'
      get expect, call [ get to-equal ] [ get btn textContent ] 'Open'
     ]
    ]
    
    get it, call 'should have Archive button for active docs' [
     function [
      set btn [ get harness create-element, call button ]
      set btn textContent 'Archive'
      get expect, call [ get to-equal ] [ get btn textContent ] 'Archive'
     ]
    ]
    
    get it, call 'should have Restore button for archived docs' [
     function [
      set btn [ get harness create-element, call button ]
      set btn textContent 'Restore'
      get expect, call [ get to-equal ] [ get btn textContent ] 'Restore'
     ]
    ]
   ]
  ]
 ]
]
