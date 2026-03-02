# Tests for value-editor library
# value-editor depends on lib style-tag - provide minimal mock

set mock-style-tag [ function selector style [ value undefined ] ]
set lib [ object [ style-tag [ get mock-style-tag ] ] ]

get describe, call 'value-editor library' [
 function [
  get describe, call 'build-input' [
   function [
    get it, call 'should export build-input function' [
     function [
      set value-editor [ load ./value-editor.cr, point ]
      get expect, call [ get to-be-defined ] [ get value-editor build-input ]
     ]
    ]

    get it, call 'should have build-input as function' [
     function [
      set value-editor [ load ./value-editor.cr, point ]
      set build-input [ get value-editor build-input ]
      get expect, call [ get to-be-defined ] [ get build-input ]
      get expect, call [ get to-be-true ] [ get build-input, at apply, default undefined ]
     ]
    ]
   ]
  ]
 ]
]
