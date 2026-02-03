# Tests for app/interface/main-menu.cr
# Tests main menu interface functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'main-menu interface' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create main-menu from action-bar component' [
     function [
      # Simulating: set main-menu [ get components action-bar, call ]
      set main-menu [ object ]
      set main-menu element [ get harness create-element, call div ]
      get main-menu element classList add, call action-bar
      
      get expect, call [ get to-be-defined ] [ get main-menu element ]
      get expect, call [ get to-be-true ] [ get main-menu element classList contains, call 'action-bar' ]
     ]
    ]
   ]
  ]
  
  get describe, call 'menu items loading' [
   function [
    get it, call 'should load all menu items' [
     function [
      set menu-items [ list 'commons' 'document' 'edit' 'file' 'insert' 'layout' 'log' 'page' 'presentation' 'session' 'view' 'window' ]
      get expect, call [ get to-equal ] [ get menu-items length ] 12
     ]
    ]
    
    get it, call 'should include commons menu' [
     function [
      set menu-items [ list 'commons' 'document' 'edit' 'file' ]
      get expect, call [ get to-contain ] [ get menu-items, at 0 ] 'commons'
     ]
    ]
    
    get it, call 'should include session menu' [
     function [
      set menu-items [ list 'commons' 'document' 'edit' 'file' 'insert' 'layout' 'log' 'page' 'presentation' 'session' 'view' 'window' ]
      set has-session [ object [ value false ] ]
      get menu-items, each [
       function item [
        get item, is 'session', true [
         set has-session value true
        ]
       ]
      ]
      get expect, call [ get to-be-true ] [ get has-session value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'menu item addition' [
   function [
    get it, call 'should add menu item with label' [
     function [
      set main-menu [ object ]
      set main-menu element [ get harness create-element, call div ]
      set items-added [ list ]
      
      set main-menu add [ function label toggle-fn [
       get items-added push, call [ get label ]
      ] ]
      
      get main-menu add, call 'Test Menu' [ function [ ] ]
      
      get expect, call [ get to-equal ] [ get items-added length ] 1
      get expect, call [ get to-equal ] [ get items-added, at 0 ] 'Test Menu'
     ]
    ]
    
    get it, call 'should add menu item with toggle function' [
     function [
      set toggle-called [ object [ value false ] ]
      set toggle-fn [ function [
       set toggle-called value true
      ] ]
      
      get toggle-fn, call
      
      get expect, call [ get to-be-true ] [ get toggle-called value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'DOM appending' [
   function [
    get it, call 'should append main-menu element to document body' [
     function [
      set document [ get harness create-document, call ]
      set main-menu [ object ]
      set main-menu element [ get harness create-element, call div ]
      
      get document body appendChild, call [ get main-menu element ]
      
      get expect, call [ get to-equal ] [ get document body children length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return main-menu object' [
     function [
      set main-menu [ object ]
      set main-menu element [ get harness create-element, call div ]
      set main-menu add [ function label toggle [ ] ]
      
      get expect, call [ get to-be-defined ] [ get main-menu ]
      get expect, call [ get to-be-defined ] [ get main-menu element ]
      get expect, call [ get to-be-defined ] [ get main-menu add ]
     ]
    ]
   ]
  ]
 ]
]
