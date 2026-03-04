# Tests for app/modules/script/window.cr

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'Script Window Module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with script:open action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      get mock-conductor register, call 'script:open' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'script:open'
     ]
    ]
    get it, call 'should register with !script:new action (skip on replay)' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      get mock-conductor register, call '!script:new' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] '!script:new'
     ]
    ]
    get it, call 'should register with script:run action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      get mock-conductor register, call 'script:run' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'script:run'
     ]
    ]
   ]
  ]
  get describe, call 'window and content elements' [
   function [
    get it, call 'should use script-content class for content container' [
     function [
      set content [ get harness create-element, call div ]
      get content classList add, call script-content
      get expect, call [ get to-be-true ] [ get content classList contains, call script-content ]
     ]
    ]
    get it, call 'should use script-textarea class for textarea' [
     function [
      set textarea [ get harness create-element, call textarea ]
      get textarea classList add, call script-textarea
      get expect, call [ get to-be-true ] [ get textarea classList contains, call script-textarea ]
     ]
    ]
    get it, call 'should use script-status class for status bar' [
     function [
      set status [ get harness create-element, call div ]
      get status classList add, call script-status
      get expect, call [ get to-be-true ] [ get status classList contains, call script-status ]
     ]
    ]
   ]
  ]
  get describe, call 'window placement' [
   function [
    get it, call 'should call stage place-window when opening script' [
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
