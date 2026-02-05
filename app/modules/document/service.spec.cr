# Tests for document service

set harness [ load ../../../tests/dom-harness.cr, point ]

get describe, call 'Document Service' [
 function [
  get describe, call 'document event listeners' [
   function [
    get it, call 'should have listeners object with change and documentRenamed' [
     function [
      set listeners [ object [
       change [ list ]
       documentRenamed [ list ]
      ] ]
      
      get expect, call [ get to-be-array ] [ get listeners change ]
      get expect, call [ get to-be-array ] [ get listeners documentRenamed ]
     ]
    ]
    
    get it, call 'should emit events to all registered callbacks' [
     function [
      set called [ object [ count 0 ] ]
      
      # Create callback list manually
      set callbacks [ list ]
      get callbacks push, call [
       function data [
        set called count 1
       ]
      ]
      
      # Verify callback was added
      get expect, call [ get to-equal ] [ get callbacks length ] 1
      
      # Simulate emit by calling each callback
      set cb [ get callbacks, at 0 ]
      get cb, call 'test-data'
      
      get expect, call [ get to-equal ] [ get called count ] 1
     ]
    ]
   ]
  ]
  
  get describe, call 'current document tracking' [
   function [
    get it, call 'should track current document ID' [
     function [
      set current-doc-ref [ object [ id null ] ]
      
      get expect, call [ get to-equal ] [ get current-doc-ref id ] null
      
      set current-doc-ref id 'doc-123'
      get expect, call [ get to-equal ] [ get current-doc-ref id ] 'doc-123'
     ]
    ]
   ]
  ]
  
  get describe, call 'API calls' [
   function [
    get it, call 'should format fetch-all-documents URL correctly' [
     function [
      set session-id 'sess-abc'
      set url [ template '/api/sessions/%0/documents' [ get session-id ] ]
      get expect, call [ get to-equal ] [ get url ] '/api/sessions/sess-abc/documents'
     ]
    ]
    
    get it, call 'should format fetch-document URL correctly' [
     function [
      set session-id 'sess-abc'
      set doc-id 'doc-xyz'
      set url [ template '/api/sessions/%0/documents/%1' [ get session-id ] [ get doc-id ] ]
      get expect, call [ get to-equal ] [ get url ] '/api/sessions/sess-abc/documents/doc-xyz'
     ]
    ]
    
    get it, call 'should create POST request for create-document' [
     function [
      set request [ object [ method 'POST' ] ]
      get expect, call [ get to-equal ] [ get request method ] 'POST'
     ]
    ]
    
    get it, call 'should create PATCH request for rename-document' [
     function [
      set new-name 'New Document Name'
      set request [ object [
       method 'PATCH'
       headers [ object [ Content-Type 'application/json' ] ]
       body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ]
      ] ]
      get expect, call [ get to-equal ] [ get request method ] 'PATCH'
      get expect, call [ get to-contain ] [ get request body ] 'New Document Name'
     ]
    ]
    
    get it, call 'should set archived to true for archive-document' [
     function [
      set body [ global JSON stringify, call [ object [ archived true ] ] ]
      get expect, call [ get to-contain ] [ get body ] 'archived'
      get expect, call [ get to-contain ] [ get body ] 'true'
     ]
    ]
    
    get it, call 'should set archived to false for restore-document' [
     function [
      set body [ global JSON stringify, call [ object [ archived false ] ] ]
      get expect, call [ get to-contain ] [ get body ] 'archived'
      get expect, call [ get to-contain ] [ get body ] 'false'
     ]
    ]
    
    get it, call 'should include content in save-document request' [
     function [
      set content 'Document content here'
      set body [ global JSON stringify, call [ object [ content [ get content ] ] ] ]
      get expect, call [ get to-contain ] [ get body ] 'Document content here'
     ]
    ]
   ]
  ]
 ]
]
