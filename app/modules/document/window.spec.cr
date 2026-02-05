# Tests for document window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'Document Window Module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with document:open action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'document:open' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'document:open'
     ]
    ]
    
    get it, call 'should register with !document:new action (skip on replay)' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call '!document:new' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] '!document:new'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with document name as title' [
     function [
      set doc-name 'My Document'
      get expect, call [ get to-equal ] [ get doc-name ] 'My Document'
     ]
    ]
   ]
  ]
  
  get describe, call 'content elements' [
   function [
    get it, call 'should create content container with document-content class' [
     function [
      set content [ get harness create-element, call div ]
      get content classList add, call document-content
      get expect, call [ get to-be-true ] [ get content classList contains, call 'document-content' ]
     ]
    ]
    
    get it, call 'should create textarea with document-textarea class' [
     function [
      set textarea [ get harness create-element, call textarea ]
      get textarea classList add, call document-textarea
      get expect, call [ get to-be-true ] [ get textarea classList contains, call 'document-textarea' ]
     ]
    ]
    
    get it, call 'should set textarea placeholder' [
     function [
      set textarea [ get harness create-element, call textarea ]
      set textarea placeholder 'Start typing...'
      get expect, call [ get to-equal ] [ get textarea placeholder ] 'Start typing...'
     ]
    ]
    
    get it, call 'should create status bar element' [
     function [
      set status [ get harness create-element, call div ]
      get status classList add, call document-status
      set status textContent 'Ready'
      get expect, call [ get to-equal ] [ get status textContent ] 'Ready'
     ]
    ]
   ]
  ]
  
  get describe, call 'status updates' [
   function [
    get it, call 'should show Saving... when saving' [
     function [
      set status [ get harness create-element, call div ]
      set status textContent 'Saving...'
      get expect, call [ get to-equal ] [ get status textContent ] 'Saving...'
     ]
    ]
    
    get it, call 'should show Saved after successful save' [
     function [
      set status [ get harness create-element, call div ]
      set status textContent 'Saved'
      get expect, call [ get to-equal ] [ get status textContent ] 'Saved'
     ]
    ]
    
    get it, call 'should show error on save failure' [
     function [
      set status [ get harness create-element, call div ]
      set status textContent 'Error saving'
      get expect, call [ get to-equal ] [ get status textContent ] 'Error saving'
     ]
    ]
   ]
  ]
  
  get describe, call 'document tracking' [
   function [
    get it, call 'should track open documents by ID' [
     function [
      set open-documents [ object ]
      set doc-id 'doc-123'
      set open-documents [ get doc-id ] [ object [ window true ] ]
      
      get expect, call [ get to-be-defined ] [ get open-documents [ get doc-id ] ]
     ]
    ]
    
    get it, call 'should set current document ID on focus' [
     function [
      set current-doc-ref [ object [ id null ] ]
      set doc-id 'doc-456'
      set current-doc-ref id [ get doc-id ]
      get expect, call [ get to-equal ] [ get current-doc-ref id ] 'doc-456'
     ]
    ]
   ]
  ]
 ]
]
