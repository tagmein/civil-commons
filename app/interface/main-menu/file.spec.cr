# Tests for app/interface/main-menu/file.cr
# Tests file menu functionality

get describe, call 'file menu' [
 function [
  get describe, call 'menu creation' [
   function [
    get it, call 'should create menu with File label' [
     function [
      set menu [ object [ label 'File' ] ]
      get expect, call [ get to-equal ] [ get menu label ] 'File'
     ]
    ]
   ]
  ]
  
  get describe, call 'menu items' [
   function [
    get it, call 'should have Item option' [
     function [
      set items [ list 'Item' ]
      get expect, call [ get to-equal ] [ get items length ] 1
      get expect, call [ get to-equal ] [ get items, at 0 ] 'Item'
     ]
    ]
   ]
  ]
  
  get describe, call 'Rename dispatch by last-interacted type' [
   function [
    get it, call 'should dispatch script:rename when last type is script' [
     function [
      set last [ object [ type 'script', id 'script-abc' ] ]
      get last type, is 'script', true [
       set expected-action 'script:rename'
       set expected-id [ get last id ]
       get expect, call [ get to-equal ] [ get expected-action ] 'script:rename'
       get expect, call [ get to-equal ] [ get expected-id ] 'script-abc'
      ]
     ]
    ]
   ]
  ]
  
  get describe, call 'return value' [
   function [
    get it, call 'should return file menu object' [
     function [
      set file [ object [ label 'File' ] ]
      set file add [ function label on-click [ ] ]
      
      get expect, call [ get to-be-defined ] [ get file ]
      get expect, call [ get to-equal ] [ get file label ] 'File'
     ]
    ]
   ]
  ]
 ]
]
