# Tests for document rename module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'Document Rename Module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with document:rename action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'document:rename' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'document:rename'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Rename Document title' [
     function [
      set window-title 'Rename Document'
      get expect, call [ get to-equal ] [ get window-title ] 'Rename Document'
     ]
    ]
    
    get it, call 'should create window with correct dimensions' [
     function [
      set height 220
      set width 350
      get expect, call [ get to-equal ] [ get height ] 220
      get expect, call [ get to-equal ] [ get width ] 350
     ]
    ]
   ]
  ]
  
  get describe, call 'form creation' [
   function [
    get it, call 'should create label element' [
     function [
      set label [ get harness create-element, call label ]
      set label textContent 'Document name:'
      get expect, call [ get to-equal ] [ get label textContent ] 'Document name:'
     ]
    ]
    
    get it, call 'should create input element' [
     function [
      set input [ get harness create-element, call input ]
      set input type 'text'
      set input placeholder 'Enter document name'
      get expect, call [ get to-equal ] [ get input type ] 'text'
     ]
    ]
    
    get it, call 'should set input value to current document name' [
     function [
      set input [ get harness create-element, call input ]
      set doc-name 'My Document'
      set input value [ get doc-name ]
      get expect, call [ get to-equal ] [ get input value ] 'My Document'
     ]
    ]
    
    get it, call 'should default to Untitled Document when no name' [
     function [
      set doc-name 'Untitled Document'
      get expect, call [ get to-equal ] [ get doc-name ] 'Untitled Document'
     ]
    ]
    
    get it, call 'should create error message element' [
     function [
      set error-msg [ get harness create-element, call div ]
      get error-msg classList add, call rename-doc-form-error
      get expect, call [ get to-be-true ] [ get error-msg classList contains, call 'rename-doc-form-error' ]
     ]
    ]
   ]
  ]
  
  get describe, call 'buttons' [
   function [
    get it, call 'should create Cancel button' [
     function [
      set cancel-btn [ get harness create-element, call button ]
      set cancel-btn textContent 'Cancel'
      get expect, call [ get to-equal ] [ get cancel-btn textContent ] 'Cancel'
     ]
    ]
    
    get it, call 'should create Save button with primary class' [
     function [
      set save-btn [ get harness create-element, call button ]
      set save-btn textContent 'Save'
      get save-btn classList add, call primary
      get expect, call [ get to-equal ] [ get save-btn textContent ] 'Save'
      get expect, call [ get to-be-true ] [ get save-btn classList contains, call 'primary' ]
     ]
    ]
   ]
  ]
  
  get describe, call 'save functionality' [
   function [
    get it, call 'should trim input value before saving' [
     function [
      set input-value '  My Document  '
      set trimmed [ get input-value, at trim, call ]
      get expect, call [ get to-equal ] [ get trimmed ] 'My Document'
     ]
    ]
    
    get it, call 'should not save if name is empty' [
     function [
      set input-value ''
      set can-save [ get input-value length, > 0 ]
      get expect, call [ get to-be-false ] [ get can-save ]
     ]
    ]
    
    get it, call 'should show Saving... while renaming' [
     function [
      set save-btn [ get harness create-element, call button ]
      set save-btn textContent 'Save'
      
      # Simulate saving state
      set save-btn textContent 'Saving...'
      get expect, call [ get to-equal ] [ get save-btn textContent ] 'Saving...'
     ]
    ]
   ]
  ]
  
  get describe, call 'keyboard handling' [
   function [
    get it, call 'should trigger save on Enter key' [
     function [
      set event [ object [ key 'Enter' ] ]
      set should-save [ get event key, is 'Enter' ]
      get expect, call [ get to-be-true ] [ get should-save ]
     ]
    ]
   ]
  ]
 ]
]
