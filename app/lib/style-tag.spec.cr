# Tests for app/lib/style-tag.cr
# Tests style-tag library functionality

set harness [ load ../../tests/dom-harness.cr, point ]

get describe, call 'style-tag library' [
 function [
  get describe, call 'format-style-line function' [
   function [
    get it, call 'should format property-value pair correctly' [
     function [
      set entry [ list 'color' '#ffffff' ]
      set result [ template ' %0: %1;' [ get entry, at 0 ] [ get entry, at 1 ] ]
      get expect, call [ get to-equal ] [ get result ] ' color: #ffffff;'
     ]
    ]
    
    get it, call 'should handle hyphenated properties' [
     function [
      set entry [ list 'background-color' '#333337' ]
      set result [ template ' %0: %1;' [ get entry, at 0 ] [ get entry, at 1 ] ]
      get expect, call [ get to-equal ] [ get result ] ' background-color: #333337;'
     ]
    ]
    
    get it, call 'should handle numeric values' [
     function [
      set entry [ list 'font-size' '14px' ]
      set result [ template ' %0: %1;' [ get entry, at 0 ] [ get entry, at 1 ] ]
      get expect, call [ get to-equal ] [ get result ] ' font-size: 14px;'
     ]
    ]
   ]
  ]
  
  get describe, call 'style tag creation' [
   function [
    get it, call 'should create style element' [
     function [
      set tag [ get harness create-element, call style ]
      get expect, call [ get to-equal ] [ get tag tagName ] 'style'
     ]
    ]
    
    get it, call 'should set textContent with CSS rule' [
     function [
      set tag [ get harness create-element, call style ]
      set selector '.test-class'
      set css-body ' color: red;'
      
      set tag textContent [ template '%0 {
%1
}
' [ get selector ] [ get css-body ] ]
      
      get expect, call [ get to-contain ] [ get tag textContent ] '.test-class'
      get expect, call [ get to-contain ] [ get tag textContent ] 'color: red'
     ]
    ]
   ]
  ]
  
  get describe, call 'CSS rule formatting' [
   function [
    get it, call 'should format selector correctly' [
     function [
      set selector '.my-component'
      set result [ template '%0 {' [ get selector ] ]
      get expect, call [ get to-equal ] [ get result ] '.my-component {'
     ]
    ]
    
    get it, call 'should handle pseudo-selectors' [
     function [
      set selector '.button:hover'
      set result [ template '%0 {' [ get selector ] ]
      get expect, call [ get to-equal ] [ get result ] '.button:hover {'
     ]
    ]
    
    get it, call 'should handle descendant selectors' [
     function [
      set selector '.menu label'
      set result [ template '%0 {' [ get selector ] ]
      get expect, call [ get to-equal ] [ get result ] '.menu label {'
     ]
    ]
    
    get it, call 'should handle child selectors' [
     function [
      set selector '.button > div'
      set result [ template '%0 {' [ get selector ] ]
      get expect, call [ get to-equal ] [ get result ] '.button > div {'
     ]
    ]
   ]
  ]
  
  get describe, call 'style object to CSS conversion' [
   function [
    get it, call 'should convert single property object' [
     function [
      set entries [ list [ list 'color' '#e0e0d0' ] ]
      set counter [ object [ value 0 ] ]
      
      get entries, each [
       function entry [
        set counter value [ get counter value, add 1 ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get counter value ] 1
     ]
    ]
    
    get it, call 'should convert multiple properties' [
     function [
      set entries [ list ]
      get entries push, call [ list 'color' '#e0e0d0' ]
      get entries push, call [ list 'background-color' '#222226' ]
      get entries push, call [ list 'border' 'none' ]
      
      set formatted [ list ]
      get entries, each [
       function entry [
        set line [ template ' %0: %1;' [ get entry, at 0 ] [ get entry, at 1 ] ]
        get formatted push, call [ get line ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get formatted length ] 3
     ]
    ]
   ]
  ]
  
  get describe, call 'document head appending' [
   function [
    get it, call 'should append style tag to document head' [
     function [
      set document [ get harness create-document, call ]
      set head [ get harness create-element, call head ]
      set style-tag [ get harness create-element, call style ]
      
      get head appendChild, call [ get style-tag ]
      
      get expect, call [ get to-equal ] [ get head children length ] 1
     ]
    ]
   ]
  ]
 ]
]
