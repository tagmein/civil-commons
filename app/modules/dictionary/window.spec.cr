# Tests for dictionary window module

get describe, call 'Dictionary Window Module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with dictionary:open action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]

      get mock-conductor register, call dictionary:open [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] dictionary:open
     ]
    ]

    get it, call 'should register with !dictionary:new action (skip on replay)' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]

      get mock-conductor register, call '!dictionary:new' [ function [ ] ]
      get expect, call [ get to-equal ] [ get registered action ] '!dictionary:new'
     ]
    ]
   ]
  ]
 ]
]
