# Tests for dictionary service

get describe, call 'Dictionary Service' [
 function [
  get describe, call 'API URL formatting' [
   function [
    get it, call 'should format fetch-all-dictionaries URL correctly' [
     function [
      set session-id 'sess-xyz'
      set url [ template '/api/sessions/%0/dictionaries' [ get session-id ] ]
      get expect, call [ get to-equal ] [ get url ] '/api/sessions/sess-xyz/dictionaries'
     ]
    ]

    get it, call 'should format fetch-dictionary URL correctly' [
     function [
      set session-id 'sess-abc'
      set dict-id 'dict-123'
      set url [ template '/api/sessions/%0/dictionaries/%1' [ get session-id ] [ get dict-id ] ]
      get expect, call [ get to-equal ] [ get url ] '/api/sessions/sess-abc/dictionaries/dict-123'
     ]
    ]

    get it, call 'should format check-reference-usage URL correctly' [
     function [
      set session-id 'sess-1'
      set ref-type 'value'
      set ref-id 'val-99'
      set url [ template '/api/sessions/%0/references/%1/%2/usage' [ get session-id ] [ get ref-type ] [ get ref-id ] ]
      get expect, call [ get to-equal ] [ get url ] '/api/sessions/sess-1/references/value/val-99/usage'
     ]
    ]
   ]
  ]

  get describe, call 'event listeners' [
   function [
    get it, call 'should have change and dictionaryRenamed events' [
     function [
      set listeners [ object [ change [ list ], dictionaryRenamed [ list ] ] ]
      get expect, call [ get to-be-array ] [ get listeners change ]
      get expect, call [ get to-be-array ] [ get listeners dictionaryRenamed ]
     ]
    ]
   ]
  ]
 ]
]
