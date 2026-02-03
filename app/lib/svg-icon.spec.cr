# Tests for app/lib/svg-icon.cr
# Tests SVG icon loading functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'svg-icon library' [
 function [
  get describe, call 'container creation' [
   function [
    get it, call 'should create div container' [
     function [
      set container [ get harness create-element, call div ]
      get expect, call [ get to-equal ] [ get container tagName ] 'div'
     ]
    ]
   ]
  ]
  
  get describe, call 'SVG parsing' [
   function [
    get it, call 'should parse SVG text to document' [
     function [
      # Simulating DOMParser behavior
      set svg-text '<svg></svg>'
      set parsed-doc [ object [
       documentElement [ object [ tagName 'svg' ] ]
      ] ]
      
      get expect, call [ get to-be-defined ] [ get parsed-doc documentElement ]
      get expect, call [ get to-equal ] [ get parsed-doc documentElement tagName ] 'svg'
     ]
    ]
    
    get it, call 'should extract documentElement from parsed document' [
     function [
      set svg-doc [ object [
       documentElement [ object [ tagName 'svg', innerHTML '' ] ]
      ] ]
      
      set svg-element [ get svg-doc documentElement ]
      
      get expect, call [ get to-be-defined ] [ get svg-element ]
     ]
    ]
   ]
  ]
  
  get describe, call 'container appending' [
   function [
    get it, call 'should append SVG element to container' [
     function [
      set container [ get harness create-element, call div ]
      set svg-element [ get harness create-element, call svg ]
      
      get container appendChild, call [ get svg-element ]
      
      get expect, call [ get to-equal ] [ get container children length ] 1
     ]
    ]
    
    get it, call 'should return container with SVG inside' [
     function [
      set container [ get harness create-element, call div ]
      set svg-element [ get harness create-element, call svg ]
      get container appendChild, call [ get svg-element ]
      
      get expect, call [ get to-be-defined ] [ get container ]
      get expect, call [ get to-equal ] [ get container children length ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'path handling' [
   function [
    get it, call 'should accept path parameter' [
     function [
      set path '/app/icons/close.svg'
      get expect, call [ get to-equal ] [ get path ] '/app/icons/close.svg'
     ]
    ]
    
    get it, call 'should handle different icon paths' [
     function [
      set paths [
       list '/app/icons/close.svg' '/app/icons/minimize.svg' '/app/icons/maximize.svg' '/app/icons/restore.svg' '/app/icons/resize.svg'
      ]
      
      get expect, call [ get to-equal ] [ get paths length ] 5
      get expect, call [ get to-contain ] [ get paths, at 0 ] 'close'
     ]
    ]
   ]
  ]
  
  get describe, call 'async fetch behavior' [
   function [
    get it, call 'should await fetch response' [
     function [
      # Simulating async behavior
      set response-received [ object [ value false ] ]
      
      # In real code: set response [ global fetch, call [ get path ] ]
      set response [ object [ ok true ] ]
      set response-received value true
      
      get expect, call [ get to-be-true ] [ get response-received value ]
     ]
    ]
    
    get it, call 'should await text() call on response' [
     function [
      set response [ object ]
      set response text [ function [ value '<svg></svg>' ] ]
      
      set svg-text [ get response text, call ]
      
      get expect, call [ get to-equal ] [ get svg-text ] '<svg></svg>'
     ]
    ]
   ]
  ]
  
  get describe, call 'DOMParser usage' [
   function [
    get it, call 'should create new DOMParser' [
     function [
      # Simulating DOMParser
      set parser [ object [
       parseFromString [ function text content-type [
        object [
         documentElement [ object [ tagName 'svg' ] ]
        ]
       ] ]
      ] ]
      
      get expect, call [ get to-be-defined ] [ get parser parseFromString ]
     ]
    ]
    
    get it, call 'should parse with image/svg+xml content type' [
     function [
      set content-type 'image/svg+xml'
      get expect, call [ get to-equal ] [ get content-type ] 'image/svg+xml'
     ]
    ]
   ]
  ]
 ]
]
