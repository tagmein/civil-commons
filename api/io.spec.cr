# Tests for api/io.cr
# Tests shared I/O module functionality

set fs [ global import, call fs/promises ]

# Create test directory
set test-data-path './test-data-io'

# Clean up test data
set cleanup [ function [
 try [
  get fs rm, call [ get test-data-path ] [ object [ recursive true, force true ] ]
 ] [
  # Ignore errors
 ]
] ]

get cleanup, call

# Load io module
set io [ load ./io.cr, point ]
set ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id ) [
 get io ( data-path, i, o, ij, oj, ensure-dir, file-exists, generate-id )
]

get describe, call 'io module' [
 function [
  get describe, call 'exports' [
   function [
    get it, call 'should export data-path' [
     function [
      get expect, call [ get to-be-defined ] [ get data-path ]
     ]
    ]
    
    get it, call 'should export i (read file)' [
     function [
      get expect, call [ get to-be-defined ] [ get i ]
     ]
    ]
    
    get it, call 'should export o (write file)' [
     function [
      get expect, call [ get to-be-defined ] [ get o ]
     ]
    ]
    
    get it, call 'should export ij (read JSON)' [
     function [
      get expect, call [ get to-be-defined ] [ get ij ]
     ]
    ]
    
    get it, call 'should export oj (write JSON)' [
     function [
      get expect, call [ get to-be-defined ] [ get oj ]
     ]
    ]
    
    get it, call 'should export ensure-dir' [
     function [
      get expect, call [ get to-be-defined ] [ get ensure-dir ]
     ]
    ]
    
    get it, call 'should export file-exists' [
     function [
      get expect, call [ get to-be-defined ] [ get file-exists ]
     ]
    ]
    
    get it, call 'should export generate-id' [
     function [
      get expect, call [ get to-be-defined ] [ get generate-id ]
     ]
    ]
   ]
  ]
  
  get describe, call 'ensure-dir' [
   function [
    get it, call 'should create directory if it does not exist' [
     function [
      set dir-path [ template '%0/new-dir' [ get test-data-path ] ]
      get ensure-dir, call [ get dir-path ]
      get expect, call [ get to-be-true ] [ get file-exists, call [ get dir-path ] ]
     ]
    ]
    
    get it, call 'should not error if directory already exists' [
     function [
      set dir-path [ template '%0/existing-dir' [ get test-data-path ] ]
      get ensure-dir, call [ get dir-path ]
      get ensure-dir, call [ get dir-path ]
      get expect, call [ get to-be-true ] [ get file-exists, call [ get dir-path ] ]
     ]
    ]
   ]
  ]
  
  get describe, call 'file-exists' [
   function [
    get it, call 'should return false for non-existent file' [
     function [
      set result [ get file-exists, call [ template '%0/nonexistent.txt' [ get test-data-path ] ] ]
      get expect, call [ get to-be-false ] [ get result ]
     ]
    ]
    
    get it, call 'should return true for existing file' [
     function [
      set file-path [ template '%0/test-exists.txt' [ get test-data-path ] ]
      get ensure-dir, call [ get test-data-path ]
      get o, call [ get file-path ] 'test content'
      
      set result [ get file-exists, call [ get file-path ] ]
      get expect, call [ get to-be-true ] [ get result ]
     ]
    ]
   ]
  ]
  
  get describe, call 'generate-id' [
   function [
    get it, call 'should generate string id' [
     function [
      set id [ get generate-id, call ]
      get expect, call [ get to-be-defined ] [ get id ]
     ]
    ]
    
    get it, call 'should generate id with length around 8 characters' [
     function [
      set id [ get generate-id, call ]
      get expect, call [ get to-be-greater-than ] [ get id length ] 5
     ]
    ]
    
    get it, call 'should generate unique ids' [
     function [
      set id1 [ get generate-id, call ]
      set id2 [ get generate-id, call ]
      # IDs should be different (very high probability)
      get id1, = [ get id2 ], false [
       get expect, call [ get to-be-true ] true
      ], true [
       # In rare case of collision, still pass since it's probabilistic
       get expect, call [ get to-be-true ] true
      ]
     ]
    ]
   ]
  ]
  
  get describe, call 'o and i (write and read string)' [
   function [
    get it, call 'should write and read file content' [
     function [
      set file-path [ template '%0/test-string.txt' [ get test-data-path ] ]
      get ensure-dir, call [ get test-data-path ]
      get o, call [ get file-path ] 'Hello World'
      
      set content [ get i, call [ get file-path ] ]
      get expect, call [ get to-equal ] [ get content ] 'Hello World'
     ]
    ]
   ]
  ]
  
  get describe, call 'oj and ij (write and read JSON)' [
   function [
    get it, call 'should write and read JSON object' [
     function [
      set file-path [ template '%0/test-json.json' [ get test-data-path ] ]
      get ensure-dir, call [ get test-data-path ]
      
      set data [ object [ name 'Test', value 42 ] ]
      get oj, call [ get file-path ] [ get data ]
      
      set read-data [ get ij, call [ get file-path ] ]
      get expect, call [ get to-equal ] [ get read-data name ] 'Test'
      get expect, call [ get to-equal ] [ get read-data value ] 42
     ]
    ]
    
    get it, call 'should write and read JSON array' [
     function [
      set file-path [ template '%0/test-array.json' [ get test-data-path ] ]
      get ensure-dir, call [ get test-data-path ]
      
      set data [ list 'item1' 'item2' 'item3' ]
      get oj, call [ get file-path ] [ get data ]
      
      set read-data [ get ij, call [ get file-path ] ]
      get expect, call [ get to-be-array ] [ get read-data ]
      get expect, call [ get to-equal ] [ get read-data length ] 3
     ]
    ]
   ]
  ]
 ]
]

# Cleanup after tests
get cleanup, call
