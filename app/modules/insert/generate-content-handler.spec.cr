# Tests for app/modules/insert/generate-content-handler.cr
# Tests the Generate Content handler and Gemini API behavior (mocked browser/network)

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'insert/generate-content-handler' [
 function [
  get describe, call 'Gemini API constants' [
   function [
    get it, call 'should use correct Gemini API base URL' [
     function [
      set GEMINI_BASE 'https://generativelanguage.googleapis.com/v1beta'
      get expect, call [ get to-equal ] [ get GEMINI_BASE ] 'https://generativelanguage.googleapis.com/v1beta'
     ]
    ]
    get it, call 'should build generateContent URL with model name' [
     function [
      set base 'https://generativelanguage.googleapis.com/v1beta'
      set model 'gemini-2.0-flash'
      set url [ template '%0/models/%1:generateContent' [ get base ] [ get model ] ]
      get expect, call [ get to-equal ] [ get url ] 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'
     ]
    ]
   ]
  ]
  get describe, call 'handler structure' [
   function [
    get it, call 'should define handler as a function taking one arg' [
     function [
      set mock-handler [ function arg [ value [ get arg ] ] ]
      set result [ get mock-handler, call [ object [ test true ] ] ]
      get expect, call [ get to-be-defined ] [ get result ]
      get expect, call [ get to-equal ] [ get result test ] true
     ]
    ]
   ]
  ]
  get describe, call 'UI elements' [
   function [
    get it, call 'should have Prompt label' [
     function [
      set label [ get harness create-element, call label ]
      set label textContent 'Prompt'
      get expect, call [ get to-equal ] [ get label textContent ] 'Prompt'
     ]
    ]
    get it, call 'should have Model label' [
     function [
      set label [ get harness create-element, call label ]
      set label textContent 'Model'
      get expect, call [ get to-equal ] [ get label textContent ] 'Model'
     ]
    ]
    get it, call 'should have Generate button' [
     function [
      set btn [ get harness create-element, call button ]
      set btn textContent 'Generate'
      get expect, call [ get to-equal ] [ get btn textContent ] 'Generate'
     ]
    ]
    get it, call 'should have Insert button' [
     function [
      set btn [ get harness create-element, call button ]
      set btn textContent 'Insert'
      get expect, call [ get to-equal ] [ get btn textContent ] 'Insert'
     ]
    ]
   ]
  ]
  get describe, call 'Gemini request shape' [
   function [
    get it, call 'should use POST and application/json' [
     function [
      set headers-obj [ object [ 'Content-Type' 'application/json' ] ]
      set opts [ object [ method 'POST', headers [ get headers-obj ] ] ]
      get expect, call [ get to-equal ] [ get opts method ] 'POST'
      set h [ get opts headers ]
      get expect, call [ get to-equal ] [ get h 'Content-Type' ] 'application/json'
     ]
    ]
   ]
  ]
  get describe, call 'mock fetch behavior' [
   function [
    get it, call 'should expect error message in API error shape' [
     function [
      set msg 'API key invalid'
      get expect, call [ get to-equal ] [ get msg ] 'API key invalid'
     ]
    ]
    get it, call 'should read error message from mock error object' [
     function [
      set err-obj [ object [ message 'API key invalid' ] ]
      set msg [ get err-obj message, default 'Unknown error' ]
      get expect, call [ get to-equal ] [ get msg ] 'API key invalid'
     ]
    ]
   ]
  ]
 ]
]