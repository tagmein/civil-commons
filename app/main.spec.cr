# Tests for app/main.cr
# Tests main application entry point

get describe, call 'main application' [
 function [
  get describe, call 'version' [
   function [
    get it, call 'should have version 0.0.0' [
     function [
      set version '0.0.0'
      get expect, call [ get to-equal ] [ get version ] '0.0.0'
     ]
    ]
   ]
  ]
  
  get describe, call 'package loader' [
   function [
    get it, call 'should create bundle object' [
     function [
      set bundle [ object ]
      get expect, call [ get to-be-defined ] [ get bundle ]
     ]
    ]
    
    get it, call 'should load parts into bundle' [
     function [
      set bundle [ object ]
      set parts [ list 'item1' 'item2' ]
      
      get parts, each [
       function x [
        set bundle [ get x ] 'loaded'
       ]
      ]
      
      get expect, call [ get to-equal ] [ get bundle 'item1' ] 'loaded'
      get expect, call [ get to-equal ] [ get bundle 'item2' ] 'loaded'
     ]
    ]
   ]
  ]
  
  get describe, call 'lib loading' [
   function [
    get it, call 'should load bounds lib' [
     function [
      set lib-parts [ list 'bounds' 'drag-handler' 'style-tag' 'svg-icon' ]
      get expect, call [ get to-contain ] [ get lib-parts, at 0 ] 'bounds'
     ]
    ]
    
    get it, call 'should load drag-handler lib' [
     function [
      set lib-parts [ list 'bounds' 'drag-handler' 'style-tag' 'svg-icon' ]
      get expect, call [ get to-contain ] [ get lib-parts, at 1 ] 'drag-handler'
     ]
    ]
    
    get it, call 'should load style-tag lib' [
     function [
      set lib-parts [ list 'bounds' 'drag-handler' 'style-tag' 'svg-icon' ]
      get expect, call [ get to-contain ] [ get lib-parts, at 2 ] 'style-tag'
     ]
    ]
    
    get it, call 'should load svg-icon lib' [
     function [
      set lib-parts [ list 'bounds' 'drag-handler' 'style-tag' 'svg-icon' ]
      get expect, call [ get to-contain ] [ get lib-parts, at 3 ] 'svg-icon'
     ]
    ]
   ]
  ]
  
  get describe, call 'components loading' [
   function [
    get it, call 'should load action-bar component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 0 ] 'action-bar'
     ]
    ]
    
    get it, call 'should load stage component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 1 ] 'stage'
     ]
    ]
    
    get it, call 'should load menu component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 2 ] 'menu'
     ]
    ]
    
    get it, call 'should load window component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 3 ] 'window'
     ]
    ]
    
    get it, call 'should load window-title-buttons component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 4 ] 'window-title-buttons'
     ]
    ]
    
    get it, call 'should load minimap component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 5 ] 'minimap'
     ]
    ]
    
    get it, call 'should load tab-bar component' [
     function [
      set components [ list 'action-bar' 'stage' 'menu' 'window' 'window-title-buttons' 'minimap' 'tab-bar' ]
      get expect, call [ get to-contain ] [ get components, at 6 ] 'tab-bar'
     ]
    ]
   ]
  ]
  
  get describe, call 'main object' [
   function [
    get it, call 'should create main object' [
     function [
      set main [ object ]
      get expect, call [ get to-be-defined ] [ get main ]
     ]
    ]
    
    get it, call 'should have session-service property' [
     function [
      set main [ object ]
      set main session-service [ object ]
      get expect, call [ get to-be-defined ] [ get main session-service ]
     ]
    ]
   ]
  ]
  
  get describe, call 'interface loading' [
   function [
    get it, call 'should load tabs interface' [
     function [
      set interfaces [ list 'tabs' 'menu' 'stage' 'status' 'startup' ]
      get expect, call [ get to-contain ] [ get interfaces, at 0 ] 'tabs'
     ]
    ]
    
    get it, call 'should load menu interface' [
     function [
      set interfaces [ list 'tabs' 'menu' 'stage' 'status' 'startup' ]
      get expect, call [ get to-contain ] [ get interfaces, at 1 ] 'menu'
     ]
    ]
    
    get it, call 'should load stage interface' [
     function [
      set interfaces [ list 'tabs' 'menu' 'stage' 'status' 'startup' ]
      get expect, call [ get to-contain ] [ get interfaces, at 2 ] 'stage'
     ]
    ]
    
    get it, call 'should load status interface' [
     function [
      set interfaces [ list 'tabs' 'menu' 'stage' 'status' 'startup' ]
      get expect, call [ get to-contain ] [ get interfaces, at 3 ] 'status'
     ]
    ]
    
    get it, call 'should load startup interface' [
     function [
      set interfaces [ list 'tabs' 'menu' 'stage' 'status' 'startup' ]
      get expect, call [ get to-contain ] [ get interfaces, at 4 ] 'startup'
     ]
    ]
   ]
  ]
  
  get describe, call 'modules loading' [
   function [
    get it, call 'should load commons/about module' [
     function [
      set modules [ list 'commons/about' 'log/main' 'session/rename' 'session/archive' 'session/recent' ]
      get expect, call [ get to-contain ] [ get modules, at 0 ] 'commons/about'
     ]
    ]
    
    get it, call 'should load log/main module' [
     function [
      set modules [ list 'commons/about' 'log/main' 'session/rename' 'session/archive' 'session/recent' ]
      get expect, call [ get to-contain ] [ get modules, at 1 ] 'log/main'
     ]
    ]
    
    get it, call 'should load session/rename module' [
     function [
      set modules [ list 'commons/about' 'log/main' 'session/rename' 'session/archive' 'session/recent' ]
      get expect, call [ get to-contain ] [ get modules, at 2 ] 'session/rename'
     ]
    ]
    
    get it, call 'should load session/archive module' [
     function [
      set modules [ list 'commons/about' 'log/main' 'session/rename' 'session/archive' 'session/recent' ]
      get expect, call [ get to-contain ] [ get modules, at 3 ] 'session/archive'
     ]
    ]
    
    get it, call 'should load session/recent module' [
     function [
      set modules [ list 'commons/about' 'log/main' 'session/rename' 'session/archive' 'session/recent' ]
      get expect, call [ get to-contain ] [ get modules, at 4 ] 'session/recent'
     ]
    ]
   ]
  ]
  
  get describe, call 'stage resize' [
   function [
    get it, call 'should call stage resize on startup' [
     function [
      set resize-called [ object [ value false ] ]
      set mock-stage [ object ]
      set mock-stage resize [ function [ set resize-called value true ] ]
      
      get mock-stage resize, call
      
      get expect, call [ get to-be-true ] [ get resize-called value ]
     ]
    ]
   ]
  ]
 ]
]
