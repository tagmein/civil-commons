# Tests for serve.cr
# Tests server utility functions

# Load serve module - in test mode it returns testable functions
set serve [ load ./serve.cr, point ]

get describe, call 'serve module' [
 function [
  get describe, call 'exports' [
   function [
    get it, call 'should export get-mime-type' [
     function [
      get expect, call [ get to-be-defined ] [ get serve get-mime-type ]
     ]
    ]
    
    get it, call 'should export parse-json-body' [
     function [
      get expect, call [ get to-be-defined ] [ get serve parse-json-body ]
     ]
    ]
    
    get it, call 'should export extract-session-id' [
     function [
      get expect, call [ get to-be-defined ] [ get serve extract-session-id ]
     ]
    ]
    
    get it, call 'should export handler' [
     function [
      get expect, call [ get to-be-defined ] [ get serve handler ]
     ]
    ]
   ]
  ]
  
  get describe, call 'get-mime-type function' [
   function [
    get it, call 'should return image/svg+xml for .svg files' [
     function [
      set result [ get serve get-mime-type, call '/app/icons/close.svg' ]
      get expect, call [ get to-equal ] [ get result ] 'image/svg+xml'
     ]
    ]
    
    get it, call 'should return text/html for .html files' [
     function [
      set result [ get serve get-mime-type, call '/index.html' ]
      get expect, call [ get to-equal ] [ get result ] 'text/html'
     ]
    ]
    
    get it, call 'should return text/css for .css files' [
     function [
      set result [ get serve get-mime-type, call '/app/style.css' ]
      get expect, call [ get to-equal ] [ get result ] 'text/css'
     ]
    ]
    
    get it, call 'should return application/javascript for .js files' [
     function [
      set result [ get serve get-mime-type, call '/app/main.js' ]
      get expect, call [ get to-equal ] [ get result ] 'application/javascript'
     ]
    ]
    
    get it, call 'should return application/json for .json files' [
     function [
      set result [ get serve get-mime-type, call '/data/config.json' ]
      get expect, call [ get to-equal ] [ get result ] 'application/json'
     ]
    ]
    
    get it, call 'should return image/png for .png files' [
     function [
      set result [ get serve get-mime-type, call '/images/logo.png' ]
      get expect, call [ get to-equal ] [ get result ] 'image/png'
     ]
    ]
    
    get it, call 'should return image/jpeg for .jpg files' [
     function [
      set result [ get serve get-mime-type, call '/images/photo.jpg' ]
      get expect, call [ get to-equal ] [ get result ] 'image/jpeg'
     ]
    ]
    
    get it, call 'should return image/jpeg for .jpeg files' [
     function [
      set result [ get serve get-mime-type, call '/images/photo.jpeg' ]
      get expect, call [ get to-equal ] [ get result ] 'image/jpeg'
     ]
    ]
    
    get it, call 'should return image/gif for .gif files' [
     function [
      set result [ get serve get-mime-type, call '/images/animation.gif' ]
      get expect, call [ get to-equal ] [ get result ] 'image/gif'
     ]
    ]
    
    get it, call 'should return image/x-icon for .ico files' [
     function [
      set result [ get serve get-mime-type, call '/favicon.ico' ]
      get expect, call [ get to-equal ] [ get result ] 'image/x-icon'
     ]
    ]
    
    get it, call 'should return text/plain for .cr files' [
     function [
      set result [ get serve get-mime-type, call '/app/main.cr' ]
      get expect, call [ get to-equal ] [ get result ] 'text/plain'
     ]
    ]
    
    get it, call 'should return application/octet-stream for unknown extensions' [
     function [
      set result [ get serve get-mime-type, call '/file.unknown' ]
      get expect, call [ get to-equal ] [ get result ] 'application/octet-stream'
     ]
    ]
    
    get it, call 'should return application/octet-stream for files without extension' [
     function [
      set result [ get serve get-mime-type, call '/somefile' ]
      get expect, call [ get to-equal ] [ get result ] 'application/octet-stream'
     ]
    ]
   ]
  ]
  
  get describe, call 'extract-session-id function' [
   function [
    get it, call 'should extract session ID from /api/sessions/:id path' [
     function [
      set result [ get serve extract-session-id, call '/api/sessions/abc123' ]
      get expect, call [ get to-equal ] [ get result ] 'abc123'
     ]
    ]
    
    get it, call 'should handle longer session IDs' [
     function [
      set result [ get serve extract-session-id, call '/api/sessions/session-123-456-789' ]
      get expect, call [ get to-equal ] [ get result ] 'session-123-456-789'
     ]
    ]
    
    get it, call 'should handle alphanumeric IDs' [
     function [
      set result [ get serve extract-session-id, call '/api/sessions/a1b2c3d4' ]
      get expect, call [ get to-equal ] [ get result ] 'a1b2c3d4'
     ]
    ]
   ]
  ]
  
  get describe, call 'parse-json-body function' [
   function [
    get it, call 'should parse valid JSON object' [
     function [
      set result [ get serve parse-json-body, call '{"name":"test","value":42}' ]
      get expect, call [ get to-equal ] [ get result data name ] 'test'
      get expect, call [ get to-equal ] [ get result data value ] 42
      get expect, call [ get to-equal ] [ get result error ] null
     ]
    ]
    
    get it, call 'should parse valid JSON array' [
     function [
      set result [ get serve parse-json-body, call '[1,2,3]' ]
      get expect, call [ get to-be-array ] [ get result data ]
      get expect, call [ get to-equal ] [ get result data length ] 3
      get expect, call [ get to-equal ] [ get result error ] null
     ]
    ]
    
    get it, call 'should return error for invalid JSON' [
     function [
      set result [ get serve parse-json-body, call 'invalid json {' ]
      get expect, call [ get to-equal ] [ get result data ] null
      get expect, call [ get to-equal ] [ get result error ] 'Invalid JSON'
     ]
    ]
    
    get it, call 'should handle empty body' [
     function [
      set result [ get serve parse-json-body, call '' ]
      get expect, call [ get to-equal ] [ get result data ] null
      get expect, call [ get to-equal ] [ get result error ] null
     ]
    ]
    
    get it, call 'should parse nested JSON' [
     function [
      set result [ get serve parse-json-body, call '{"user":{"name":"test","id":1}}' ]
      get expect, call [ get to-equal ] [ get result data user name ] 'test'
      get expect, call [ get to-equal ] [ get result data user id ] 1
     ]
    ]
    
    get it, call 'should parse JSON with boolean values' [
     function [
      set result [ get serve parse-json-body, call '{"active":true,"archived":false}' ]
      get expect, call [ get to-equal ] [ get result data active ] true
      get expect, call [ get to-equal ] [ get result data archived ] false
     ]
    ]
    
    get it, call 'should parse JSON with null values' [
     function [
      set result [ get serve parse-json-body, call '{"value":null}' ]
      get expect, call [ get to-equal ] [ get result data value ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'handler function' [
   function [
    get it, call 'should be a function' [
     function [
      get expect, call [ get to-be-defined ] [ get serve handler ]
     ]
    ]
   ]
  ]
 ]
]
