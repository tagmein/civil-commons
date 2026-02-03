# Tests for app/modules/log/main.cr
# Tests the Log window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'log/main module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with log:open action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'log:open' [ function [ ] ]
      
      get expect, call [ get to-equal ] [ get registered action ] 'log:open'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Log title' [
     function [
      set window-title 'Log'
      get expect, call [ get to-equal ] [ get window-title ] 'Log'
     ]
    ]
   ]
  ]
  
  get describe, call 'window placement' [
   function [
    get it, call 'should call stage place-window' [
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
