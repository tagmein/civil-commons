# Tests for app/interface/main-menu/script.cr

get describe, call 'Script menu' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create menu with Script label' [
     function [
      set script [ object [ label 'Script' ] ]
      get expect, call [ get to-equal ] [ get script label ] 'Script'
     ]
    ]
   ]
  ]
  get describe, call 'menu items' [
   function [
    get it, call 'should have Run option' [
     function [
      set items [ list 'Run' ]
      get expect, call [ get to-equal ] [ get items length ] 1
      get expect, call [ get to-equal ] [ get items, at 0 ] 'Run'
     ]
    ]
   ]
  ]
  get describe, call 'return value' [
   function [
    get it, call 'should return script menu object' [
     function [
      set script [ object [ label 'Script' ] ]
      set script add [ function label on-click [ ] ]
      get expect, call [ get to-be-defined ] [ get script ]
      get expect, call [ get to-equal ] [ get script label ] 'Script'
     ]
    ]
   ]
  ]
 ]
]
