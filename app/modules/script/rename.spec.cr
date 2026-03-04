# Tests for app/modules/script/rename.cr

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'script/rename module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with script:rename action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      get mock-conductor register, call 'script:rename' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] 'script:rename'
     ]
    ]
   ]
  ]
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with Rename Script title' [
     function [
      set title 'Rename Script'
      get expect, call [ get to-equal ] [ get title ] 'Rename Script'
     ]
    ]
    get it, call 'should use rename-script-form class for form' [
     function [
      set form [ get harness create-element, call div ]
      get form classList add, call rename-script-form
      get expect, call [ get to-be-true ] [ get form classList contains, call rename-script-form ]
     ]
    ]
    get it, call 'should have Script name label' [
     function [
      set label-text 'Script name:'
      get expect, call [ get to-equal ] [ get label-text ] 'Script name:'
     ]
    ]
   ]
  ]
 ]
]
