# Tests for app/interface/main-menu/new.cr

get describe, call 'New menu' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create menu with New label' [
     function [
      set menu [ object [ label 'New' ] ]
      get expect, call [ get to-equal ] [ get menu label ] 'New'
     ]
    ]
   ]
  ]
  get describe, call 'menu items' [
   function [
    get it, call 'should have Document option' [
     function [
      set items [ list 'Document' 'Script' 'Session' 'Value' ]
      get expect, call [ get to-contain ] [ get items ] 'Document'
     ]
    ]
    get it, call 'should have Script option' [
     function [
      set items [ list 'Document' 'Script' 'Session' 'Value' ]
      get expect, call [ get to-contain ] [ get items ] 'Script'
     ]
    ]
    get it, call 'should have Session option' [
     function [
      set items [ list 'Document' 'Script' 'Session' 'Value' ]
      get expect, call [ get to-contain ] [ get items ] 'Session'
     ]
    ]
    get it, call 'should have Value option' [
     function [
      set items [ list 'Document' 'Script' 'Session' 'Value' ]
      get expect, call [ get to-contain ] [ get items ] 'Value'
     ]
    ]
   ]
  ]
  get describe, call 'return value' [
   function [
    get it, call 'should return new menu object' [
     function [
      set new-menu [ object [ label 'New' ] ]
      get expect, call [ get to-be-defined ] [ get new-menu ]
      get expect, call [ get to-equal ] [ get new-menu label ] 'New'
     ]
    ]
   ]
  ]
 ]
]
