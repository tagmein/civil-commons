# Tests for app/modules/commons/about.cr
# Tests the About window module

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'commons/about module' [
 function [
  get describe, call 'conductor registration' [
   function [
    get it, call 'should register with commons:about action' [
     function [
      set registered [ object [ action null ] ]
      set mock-conductor [ object ]
      set mock-conductor register [ function action handler [
       set registered action [ get action ]
      ] ]
      
      get mock-conductor register, call 'commons:about' [ function [ ] ]
      
      get expect, call [ get to-equal ] [ get registered action ] 'commons:about'
     ]
    ]
   ]
  ]
  
  get describe, call 'window creation' [
   function [
    get it, call 'should create window with correct title' [
     function [
      set window-title 'About Civil Commons'
      get expect, call [ get to-equal ] [ get window-title ] 'About Civil Commons'
     ]
    ]
    
    get it, call 'should create window with specified dimensions' [
     function [
      set height 400
      set width 500
      get expect, call [ get to-equal ] [ get height ] 400
      get expect, call [ get to-equal ] [ get width ] 500
     ]
    ]
   ]
  ]
  
  get describe, call 'content creation' [
   function [
    get it, call 'should create main title element' [
     function [
      set title [ get harness create-element, call h1 ]
      set title textContent 'Civil Commons'
      get expect, call [ get to-equal ] [ get title textContent ] 'Civil Commons'
     ]
    ]
    
    get it, call 'should create description element' [
     function [
      set description [ get harness create-element, call p ]
      set text 'A public gathering space for internet-enabled minds.'
      set description textContent [ get text ]
      get expect, call [ get to-contain ] [ get description textContent ] 'public gathering space'
     ]
    ]
    
    get it, call 'should create GitHub link' [
     function [
      set link [ get harness create-element, call a ]
      set link href 'https://github.com/tagmein/civil-commons'
      set link target '_blank'
      set link textContent 'View on GitHub'
      
      get expect, call [ get to-equal ] [ get link href ] 'https://github.com/tagmein/civil-commons'
      get expect, call [ get to-equal ] [ get link target ] '_blank'
     ]
    ]
    
    get it, call 'should create version label' [
     function [
      set version-label [ get harness create-element, call p ]
      set version-label textContent 'Version 0.0.0'
      get expect, call [ get to-contain ] [ get version-label textContent ] 'Version'
     ]
    ]
    
    get it, call 'should create Built with section' [
     function [
      set tech-title [ get harness create-element, call h2 ]
      set tech-title textContent 'Built with'
      get expect, call [ get to-equal ] [ get tech-title textContent ] 'Built with'
     ]
    ]
    
    get it, call 'should include Crown in tech list' [
     function [
      set tech-items [ list 'Crown metaprogramming language' 'Node.js' 'HTML5 Canvas' ]
      get expect, call [ get to-contain ] [ get tech-items, at 0 ] 'Crown'
     ]
    ]
    
    get it, call 'should create license section' [
     function [
      set license-title [ get harness create-element, call h2 ]
      set license-title textContent 'License'
      set license-text 'MIT License + Public Domain'
      
      get expect, call [ get to-equal ] [ get license-title textContent ] 'License'
      get expect, call [ get to-contain ] [ get license-text ] 'MIT'
     ]
    ]
   ]
  ]
  
  get describe, call 'link hover effects' [
   function [
    get it, call 'should add underline on mouseenter' [
     function [
      set link [ get harness create-element, call a ]
      set link style [ object [ textDecoration 'none' ] ]
      
      # Simulate mouseenter
      set link style textDecoration 'underline'
      
      get expect, call [ get to-equal ] [ get link style textDecoration ] 'underline'
     ]
    ]
    
    get it, call 'should remove underline on mouseleave' [
     function [
      set link [ get harness create-element, call a ]
      set link style [ object [ textDecoration 'underline' ] ]
      
      # Simulate mouseleave
      set link style textDecoration 'none'
      
      get expect, call [ get to-equal ] [ get link style textDecoration ] 'none'
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
