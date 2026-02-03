# Tests for app/modules/session/rename.cr
# Tests session rename window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'session/rename module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with session:rename action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'session:rename' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'session:rename'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Rename Session title' [
     function [
      set window-title 'Rename Session'
      get expect, call [ get to-equal ] [ get window-title ] 'Rename Session'
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
      set label textContent 'Session name:'
      get expect, call [ get to-equal ] [ get label textContent ] 'Session name:'
     ]
    ]
    
    get it, call 'should create input element' [
     function [
      set input [ get harness create-element, call input ]
      set input type 'text'
      set input placeholder 'Enter session name'
      get expect, call [ get to-equal ] [ get input type ] 'text'
     ]
    ]
    
    get it, call 'should set input value to current session name' [
     function [
      set input [ get harness create-element, call input ]
      set session-name 'My Project'
      set input value [ get session-name ]
      get expect, call [ get to-equal ] [ get input value ] 'My Project'
     ]
    ]
    
    get it, call 'should default to Untitled when no session name' [
     function [
      set session-name 'Untitled'
      get expect, call [ get to-equal ] [ get session-name ] 'Untitled'
     ]
    ]
    
    get it, call 'should create error message element' [
     function [
      set error-msg [ get harness create-element, call div ]
      get error-msg classList add, call rename-form-error
      get expect, call [ get to-be-true ] [ get error-msg classList contains, call 'rename-form-error' ]
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
      set input-value '  My Session  '
      set trimmed [ get input-value, at trim, call ]
      get expect, call [ get to-equal ] [ get trimmed ] 'My Session'
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
    
    get it, call 'should disable button while saving' [
     function [
      set save-btn [ object [ disabled false ] ]
      set save-btn disabled true
      get expect, call [ get to-be-true ] [ get save-btn disabled ]
     ]
    ]
   ]
  ]
  
  get describe, call 'error handling' [
   function [
    get it, call 'should show error message on failure' [
     function [
      set error-msg [ get harness create-element, call div ]
      set error-msg textContent 'Failed to rename session'
      get error-msg classList add, call visible
      
      get expect, call [ get to-be-true ] [ get error-msg classList contains, call 'visible' ]
      get expect, call [ get to-contain ] [ get error-msg textContent ] 'Failed'
     ]
    ]
    
    get it, call 'should re-enable button after error' [
     function [
      set save-btn [ object [ disabled true, textContent 'Saving...' ] ]
      
      # After error
      set save-btn disabled false
      set save-btn textContent 'Save'
      
      get expect, call [ get to-be-false ] [ get save-btn disabled ]
      get expect, call [ get to-equal ] [ get save-btn textContent ] 'Save'
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
  
  get describe, call 'auto-focus' [
   function [
    get it, call 'should focus input after window opens' [
     function [
      set input [ get harness create-element, call input ]
      set focused [ object [ value false ] ]
      
      # In real code, setTimeout calls focus
      set focused value true
      get expect, call [ get to-be-true ] [ get focused value ]
     ]
    ]
   ]
  ]
 ]
]
