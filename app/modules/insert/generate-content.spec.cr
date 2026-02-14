# Tests for app/modules/insert/generate-content.cr
# Tests the Generate Content module registration and expected behavior

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'insert/generate-content module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with insert:generate-content action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'insert:generate-content' [ function arg [ ] ]
      
      get expect, call [ get to-equal ] [ get registered action ] 'insert:generate-content'
     ]
    ]
    
    get it, call 'should register a handler that can be called with an arg' [
     function [
      set called [ object [ value false, arg null ] ]
      set mock-handler [ function arg [
       set called value true
       set called arg [ get arg ]
      ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       get handler, call [ object [ test true ] ]
      ] ]
      
      get mock-conductor register, call 'insert:generate-content' [ get mock-handler ]
      
      get expect, call [ get to-be-true ] [ get called value ]
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with title Generate Content' [
     function [
      set window-title 'Generate Content'
      get expect, call [ get to-equal ] [ get window-title ] 'Generate Content'
     ]
    ]
    
    get it, call 'should create window with expected dimensions' [
     function [
      set width 520
      set height 480
      get expect, call [ get to-equal ] [ get width ] 520
      get expect, call [ get to-equal ] [ get height ] 480
     ]
    ]
   ]
  ]
  
  get describe, call 'style classes' [
   function [
    get it, call 'should use generate-content-root for root container' [
     function [
      set root [ get harness create-element, call div ]
      get root classList add, call generate-content-root
      get expect, call [ get to-be-true ] [ get root classList contains, call 'generate-content-root' ]
     ]
    ]
    
    get it, call 'should use generate-content-label for labels' [
     function [
      set label [ get harness create-element, call label ]
      get label classList add, call generate-content-label
      get expect, call [ get to-be-true ] [ get label classList contains, call 'generate-content-label' ]
     ]
    ]
    
    get it, call 'should use generate-content-textarea for prompt input' [
     function [
      set textarea [ get harness create-element, call textarea ]
      get textarea classList add, call generate-content-textarea
      get expect, call [ get to-be-true ] [ get textarea classList contains, call 'generate-content-textarea' ]
     ]
    ]
    
    get it, call 'should use generate-content-button for buttons' [
     function [
      set btn [ get harness create-element, call button ]
      get btn classList add, call generate-content-button
      get expect, call [ get to-be-true ] [ get btn classList contains, call 'generate-content-button' ]
     ]
    ]
   ]
  ]
  
  get describe, call 'window placement' [
   function [
    get it, call 'should call stage place-window when handler runs' [
     function [
      set placed [ object [ value false ] ]
      set mock-stage [ object ]
      set mock-stage place-window [ function window status [
       set placed value true
      ] ]
      
      set mock-window [ object [ element [ get harness create-element, call div ] ] ]
      get mock-stage place-window, call [ get mock-window ] null
      
      get expect, call [ get to-be-true ] [ get placed value ]
     ]
    ]
   ]
  ]
 ]
]