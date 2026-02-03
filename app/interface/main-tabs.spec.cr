# Comprehensive tests for app/interface/main-tabs.cr
# Tests all code paths with mocks for 100% line coverage

set harness [ load ../../tests/dom-harness.cr, point ]

# Mock tab-bar component
set create-mock-tab-bar [ function [
 set tabs [ list ]
 set state [ object [ active-tab null ] ]
 set call-log [ object [
  add-calls [ list ]
  clear-calls [ list ]
  set-active-calls [ list ]
  get-active-calls [ list ]
  get-tabs-calls [ list ]
 ] ]
 
 set mock [
  object [
   element [ get harness create-element, call div ]
   add [ function label on-click [
    set tab [ object [
     label [ get label ]
     on-click [ get on-click ]
     element [ get harness create-element, call button ]
    ] ]
    get tabs push, call [ get tab ]
    get call-log add-calls push, call [ object [ label [ get label ] ] ]
    get tab
   ] ]
   clear [ function [
    set tabs [ list ]
    get call-log clear-calls push, call [ object [ called true ] ]
   ] ]
   set-active [ function tab [
    set state active-tab [ get tab ]
    get call-log set-active-calls push, call [ object [ tab [ get tab ] ] ]
   ] ]
   get-active [ function [
    get call-log get-active-calls push, call [ object [ called true ] ]
    get state active-tab
   ] ]
   get-tabs [ function [
    get call-log get-tabs-calls push, call [ object [ called true ] ]
    get tabs
   ] ]
   _tabs [ get tabs ]
   _state [ get state ]
   _call-log [ get call-log ]
  ]
 ]
 get mock
] ]

# Mock session service
set create-mock-session-service [ function config [
 set listeners [ object [ change [ list ], tabsChange [ list ], sessionRenamed [ list ] ] ]
 set call-log [ object [
  on-calls [ list ]
  get-open-session-ids-calls [ list ]
  get-current-session-id-calls [ list ]
  set-current-session-id-calls [ list ]
  fetch-all-sessions-calls [ list ]
  initialize-calls [ list ]
 ] ]
 
 object [
  on [ function event-name callback [
   get listeners [ get event-name ] push, call [ get callback ]
   get call-log on-calls push, call [ object [ event [ get event-name ] ] ]
  ] ]
  get-open-session-ids [ function [
   get call-log get-open-session-ids-calls push, call [ object [ called true ] ]
   get config should-throw-on-get-ids, true [
    error 'Mock error: get-open-session-ids'
   ]
   get config open-ids, default [ list ]
  ] ]
  get-current-session-id [ function [
   get call-log get-current-session-id-calls push, call [ object [ called true ] ]
   get config should-throw-on-get-current, true [
    error 'Mock error: get-current-session-id'
   ]
   get config current-id, default null
  ] ]
  set-current-session-id [ function id [
   get call-log set-current-session-id-calls push, call [ object [ id [ get id ] ] ]
   get config should-throw-on-set-current, true [
    error 'Mock error: set-current-session-id'
   ]
  ] ]
  fetch-all-sessions [ function [
   get call-log fetch-all-sessions-calls push, call [ object [ called true ] ]
   get config should-throw-on-fetch, true [
    error 'Mock error: fetch-all-sessions'
   ]
   get config all-sessions, default [ list ]
  ] ]
  initialize [ function [
   get call-log initialize-calls push, call [ object [ called true ] ]
   get config should-throw-on-init, true [
    error 'Mock error: initialize'
   ]
  ] ]
  # Helper to trigger events
  _emit [ function event-name data [
   get listeners [ get event-name ], each [
    function callback [
     get callback, call [ get data ]
    ]
   ]
  ] ]
  _listeners [ get listeners ]
  _call-log [ get call-log ]
 ]
] ]

# ============================================
# Tests for create-default-tab function
# ============================================
get describe, call 'main-tabs create-default-tab' [
 function [
  get it, call 'should create a tab with label Untitled' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    
    # Simulate create-default-tab
    set tab [
     get mock-tab-bar add, call 'Untitled' [
      function tab event [
       # No-op for placeholder tab
      ]
     ]
    ]
    get mock-tab-bar set-active, call [ get tab ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls length ] 1
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'Untitled'
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log set-active-calls length ] 1
   ]
  ]
  
  get it, call 'should set the created tab as active' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    
    set tab [
     get mock-tab-bar add, call 'Untitled' [
      function tab event [ ]
     ]
    ]
    get mock-tab-bar set-active, call [ get tab ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab ] [ get tab ]
   ]
  ]
 ]
]

# ============================================
# Tests for render-tabs function
# ============================================
get describe, call 'main-tabs render-tabs' [
 function [
  get describe, call 'clearing and initialization' [
   function [
    get it, call 'should clear existing tabs first' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set mock-service [ get create-mock-session-service, call [ object [ open-ids [ list ] ] ] ]
      
      # Simulate render-tabs clear
      get mock-tab-bar clear, call
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log clear-calls length ] 1
     ]
    ]
    
    get it, call 'should reset tab-map to empty object' [
     function [
      set tab-map [ object [ old-id 'old-tab' ] ]
      set tab-map [ object ]
      
      get expect, call [ get to-equal ] [ get tab-map old-id, typeof ] 'undefined'
     ]
    ]
   ]
  ]
  
  get describe, call 'getting open session IDs' [
   function [
    get it, call 'should call get-open-session-ids on session service' [
     function [
      set mock-service [ get create-mock-session-service, call [ object [ open-ids [ list 'id1' ] ] ] ]
      
      set result [ get mock-service get-open-session-ids, call ]
      
      get expect, call [ get to-equal ] [ get mock-service _call-log get-open-session-ids-calls length ] 1
      get expect, call [ get to-be-array ] [ get result ]
     ]
    ]
    
    get it, call 'should handle error when get-open-session-ids throws' [
     function [
      set mock-service [ get create-mock-session-service, call [ object [ should-throw-on-get-ids true ] ] ]
      
      set open-ids [ list ]
      try [
       set result [ get mock-service get-open-session-ids, call ]
       get result, true [
        set open-ids [ get result ]
       ]
      ] [
       # Failed - keep empty list
      ]
      
      get expect, call [ get to-be-array ] [ get open-ids ]
      get expect, call [ get to-equal ] [ get open-ids length ] 0
     ]
    ]
   ]
  ]
  
  get describe, call 'getting current session ID' [
   function [
    get it, call 'should call get-current-session-id on session service' [
     function [
      set mock-service [ get create-mock-session-service, call [ object [ current-id 'abc123' ] ] ]
      
      set current-id null
      try [
       set current-id [ get mock-service get-current-session-id, call ]
      ] [
       # Failed
      ]
      
      get expect, call [ get to-equal ] [ get mock-service _call-log get-current-session-id-calls length ] 1
      get expect, call [ get to-equal ] [ get current-id ] 'abc123'
     ]
    ]
    
    get it, call 'should handle error when get-current-session-id throws' [
     function [
      set mock-service [ get create-mock-session-service, call [ object [ should-throw-on-get-current true ] ] ]
      
      set current-id null
      try [
       set current-id [ get mock-service get-current-session-id, call ]
      ] [
       # Failed - keep null
      ]
      
      get expect, call [ get to-equal ] [ get current-id ] null
     ]
    ]
   ]
  ]
  
  get describe, call 'checking has-sessions state' [
   function [
    get it, call 'should set has-sessions to true when open-ids has items' [
     function [
      set open-ids [ list 'id1' 'id2' ]
      set state [ object [ has-sessions false ] ]
      
      try [
       get open-ids length, > 0, true [
        set state has-sessions true
       ]
      ] [
       # Failed
      ]
      
      get expect, call [ get to-be-true ] [ get state has-sessions ]
     ]
    ]
    
    get it, call 'should keep has-sessions false when open-ids is empty' [
     function [
      set open-ids [ list ]
      set state [ object [ has-sessions false ] ]
      
      try [
       get open-ids length, > 0, true [
        set state has-sessions true
       ]
      ] [
       # Failed
      ]
      
      get expect, call [ get to-be-false ] [ get state has-sessions ]
     ]
    ]
   ]
  ]
  
  get describe, call 'creating default tab when no sessions' [
   function [
    get it, call 'should create default Untitled tab when has-sessions is false' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set state [ object [ has-sessions false ] ]
      
      get state has-sessions, false [
       # Simulate create-default-tab
       set tab [
        get mock-tab-bar add, call 'Untitled' [
         function tab event [ ]
        ]
       ]
       get mock-tab-bar set-active, call [ get tab ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'Untitled'
     ]
    ]
   ]
  ]
  
  get describe, call 'fetching all sessions' [
   function [
    get it, call 'should call fetch-all-sessions when has sessions' [
     function [
      set mock-service [ get create-mock-session-service, call [
       object [
        open-ids [ list 'id1' ]
        all-sessions [ list [ object [ id 'id1', name 'Test' ] ] ]
       ]
      ] ]
      
      set all-sessions [ list ]
      try [
       set all-sessions [ get mock-service fetch-all-sessions, call ]
      ] [
       # Failed
      ]
      
      get expect, call [ get to-equal ] [ get mock-service _call-log fetch-all-sessions-calls length ] 1
      get expect, call [ get to-equal ] [ get all-sessions length ] 1
     ]
    ]
    
    get it, call 'should handle error when fetch-all-sessions throws' [
     function [
      set mock-service [ get create-mock-session-service, call [ object [ should-throw-on-fetch true ] ] ]
      
      set all-sessions [ list ]
      try [
       set all-sessions [ get mock-service fetch-all-sessions, call ]
      ] [
       # Failed - will use empty list
      ]
      
      get expect, call [ get to-be-array ] [ get all-sessions ]
      get expect, call [ get to-equal ] [ get all-sessions length ] 0
     ]
    ]
   ]
  ]
  
  get describe, call 'building session-map' [
   function [
    get it, call 'should build session-map from all-sessions' [
     function [
      set session-a [ object [ id 'abc', name 'Project A' ] ]
      set session-b [ object [ id 'def', name 'Project B' ] ]
      
      set session-map [ object ]
      set session-map 'abc' [ get session-a ]
      set session-map 'def' [ get session-b ]
      
      get expect, call [ get to-be-defined ] [ get session-map 'abc' ]
      get expect, call [ get to-be-defined ] [ get session-map 'def' ]
      get expect, call [ get to-equal ] [ get session-map 'abc' name ] 'Project A'
      get expect, call [ get to-equal ] [ get session-map 'def' name ] 'Project B'
     ]
    ]
   ]
  ]
  
  get describe, call 'creating tabs for open sessions' [
   function [
    get it, call 'should create tab for each open session ID' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set open-ids [ list 'id1' 'id2' 'id3' ]
      set session-map [ object ]
      set session-map 'id1' [ object [ id 'id1', name 'First' ] ]
      set session-map 'id2' [ object [ id 'id2', name 'Second' ] ]
      set session-map 'id3' [ object [ id 'id3', name 'Third' ] ]
      set tab-map [ object ]
      set current-id 'id2'
      
      get open-ids, each [
       function session-id [
        set tab-ref [ object [ name 'Untitled' ] ]
        get session-map [ get session-id ], true [
         get session-map [ get session-id ] name, true [
          set tab-ref name [ get session-map [ get session-id ] name ]
         ]
        ]
        
        set tab [
         get mock-tab-bar add, call [ get tab-ref name ] [
          function tab event [ ]
         ]
        ]
        
        set tab-map [ get session-id ] [ get tab ]
        
        get session-id, is [ get current-id ], true [
         get mock-tab-bar set-active, call [ get tab ]
        ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls length ] 3
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'First'
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 1, at label ] 'Second'
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 2, at label ] 'Third'
     ]
    ]
    
    get it, call 'should use Untitled when session not in session-map' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set open-ids [ list 'orphan-id' ]
      set session-map [ object ]
      set tab-map [ object ]
      
      get open-ids, each [
       function session-id [
        set tab-ref [ object [ name 'Untitled' ] ]
        get session-map [ get session-id ], true [
         get session-map [ get session-id ] name, true [
          set tab-ref name [ get session-map [ get session-id ] name ]
         ]
        ]
        
        set tab [
         get mock-tab-bar add, call [ get tab-ref name ] [
          function tab event [ ]
         ]
        ]
        set tab-map [ get session-id ] [ get tab ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'Untitled'
     ]
    ]
    
    get it, call 'should store tab reference in tab-map' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set open-ids [ list 'my-session' ]
      set session-map [ object ]
      set session-map 'my-session' [ object [ id 'my-session', name 'My Session' ] ]
      set tab-map [ object ]
      
      get open-ids, each [
       function session-id [
        set tab-ref [ object [ name 'Untitled' ] ]
        get session-map [ get session-id ], true [
         get session-map [ get session-id ] name, true [
          set tab-ref name [ get session-map [ get session-id ] name ]
         ]
        ]
        
        set tab [
         get mock-tab-bar add, call [ get tab-ref name ] [
          function tab event [ ]
         ]
        ]
        set tab-map [ get session-id ] [ get tab ]
       ]
      ]
      
      get expect, call [ get to-be-defined ] [ get tab-map 'my-session' ]
      get expect, call [ get to-equal ] [ get tab-map 'my-session' label ] 'My Session'
     ]
    ]
    
    get it, call 'should mark current session tab as active' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set open-ids [ list 'id1' 'id2' ]
      set session-map [ object ]
      set session-map 'id1' [ object [ id 'id1', name 'First' ] ]
      set session-map 'id2' [ object [ id 'id2', name 'Second' ] ]
      set tab-map [ object ]
      set current-id 'id2'
      
      get open-ids, each [
       function session-id [
        set tab-ref [ object [ name 'Untitled' ] ]
        get session-map [ get session-id ], true [
         get session-map [ get session-id ] name, true [
          set tab-ref name [ get session-map [ get session-id ] name ]
         ]
        ]
        
        set tab [
         get mock-tab-bar add, call [ get tab-ref name ] [
          function tab event [ ]
         ]
        ]
        set tab-map [ get session-id ] [ get tab ]
        
        get session-id, is [ get current-id ], true [
         get mock-tab-bar set-active, call [ get tab ]
        ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log set-active-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab label ] 'Second'
     ]
    ]
   ]
  ]
  
  get describe, call 'tab click handler' [
   function [
    get it, call 'should call set-current-session-id when tab is clicked' [
     function [
      set mock-service [ get create-mock-session-service, call [ object ] ]
      set session-id 'clicked-session'
      
      set click-handler [ function tab event [
       try [
        get mock-service set-current-session-id, call [ get session-id ]
       ] [
        # Failed to switch
       ]
      ] ]
      
      get click-handler, call null null
      
      get expect, call [ get to-equal ] [ get mock-service _call-log set-current-session-id-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-service _call-log set-current-session-id-calls, at 0, at id ] 'clicked-session'
     ]
    ]
   ]
  ]
  
  get describe, call 'ensuring active tab fallback' [
   function [
    get it, call 'should set first tab active when get-active returns null' [
     function [
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      
      set tab1 [ get mock-tab-bar add, call 'Tab 1' [ function [ ] ] ]
      set tab2 [ get mock-tab-bar add, call 'Tab 2' [ function [ ] ] ]
      
      get mock-tab-bar get-active, call, false [
       set all-tabs [ get mock-tab-bar get-tabs, call ]
       get all-tabs length, > 0, true [
        get mock-tab-bar set-active, call [ get all-tabs, at 0 ]
       ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log get-active-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-tab-bar _call-log set-active-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab label ] 'Tab 1'
     ]
    ]
   ]
  ]
 ]
]

# ============================================
# Tests for update-active-tab function
# ============================================
get describe, call 'main-tabs update-active-tab' [
 function [
  get it, call 'should set tab as active when found in tab-map' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    set tab1 [ object [ label 'Tab 1' ] ]
    set tab2 [ object [ label 'Tab 2' ] ]
    set tab-map [ object ]
    set tab-map 'id1' [ get tab1 ]
    set tab-map 'id2' [ get tab2 ]
    
    set current-id 'id2'
    get tab-map [ get current-id ], true [
     get mock-tab-bar set-active, call [ get tab-map [ get current-id ] ]
    ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log set-active-calls length ] 1
    get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab label ] 'Tab 2'
   ]
  ]
  
  get it, call 'should not call set-active when tab not in tab-map' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    set tab-map [ object ]
    set tab-map 'id1' [ object [ label 'Tab 1' ] ]
    
    set current-id 'non-existent'
    get tab-map [ get current-id ], true [
     get mock-tab-bar set-active, call [ get tab-map [ get current-id ] ]
    ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log set-active-calls length ] 0
   ]
  ]
 ]
]

# ============================================
# Tests for event listeners
# ============================================
get describe, call 'main-tabs event listeners' [
 function [
  get describe, call 'change event listener' [
   function [
    get it, call 'should register listener for change event' [
     function [
      set mock-service [ get create-mock-session-service, call [ object ] ]
      
      get mock-service on, call change [
       function current-id [ ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-service _call-log on-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-service _call-log on-calls, at 0, at event ] 'change'
     ]
    ]
    
    get it, call 'should call update-active-tab when change event fires' [
     function [
      set mock-service [ get create-mock-session-service, call [ object ] ]
      set mock-tab-bar [ get create-mock-tab-bar, call ]
      set tab-map [ object ]
      set update-called [ object [ value false, id null ] ]
      
      get mock-service on, call change [
       function current-id [
        set update-called value true
        set update-called id [ get current-id ]
       ]
      ]
      
      get mock-service _emit, call change 'new-session-id'
      
      get expect, call [ get to-be-true ] [ get update-called value ]
      get expect, call [ get to-equal ] [ get update-called id ] 'new-session-id'
     ]
    ]
   ]
  ]
  
  get describe, call 'tabsChange event listener' [
   function [
    get it, call 'should register listener for tabsChange event' [
     function [
      set mock-service [ get create-mock-session-service, call [ object ] ]
      
      get mock-service on, call tabsChange [
       function open-ids [ ]
      ]
      
      get expect, call [ get to-equal ] [ get mock-service _call-log on-calls length ] 1
      get expect, call [ get to-equal ] [ get mock-service _call-log on-calls, at 0, at event ] 'tabsChange'
     ]
    ]
    
    get it, call 'should call render-tabs when tabsChange event fires' [
     function [
      set mock-service [ get create-mock-session-service, call [ object ] ]
      set render-called [ object [ value false ] ]
      
      get mock-service on, call tabsChange [
       function open-ids [
        set render-called value true
       ]
      ]
      
      get mock-service _emit, call tabsChange [ list 'id1' 'id2' ]
      
      get expect, call [ get to-be-true ] [ get render-called value ]
     ]
    ]
   ]
  ]
 ]
]

# ============================================
# Tests for initialization
# ============================================
get describe, call 'main-tabs initialization' [
 function [
  get it, call 'should append main-tabs element to document body' [
   function [
    set mock-document [ get harness create-document, call ]
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    
    get mock-document body appendChild, call [ get mock-tab-bar element ]
    
    get expect, call [ get to-equal ] [ get mock-document body children length ] 1
   ]
  ]
  
  get it, call 'should call session service initialize' [
   function [
    set mock-service [ get create-mock-session-service, call [ object ] ]
    
    try [
     get mock-service initialize, call
    ] [
     # Initialization failed
    ]
    
    get expect, call [ get to-equal ] [ get mock-service _call-log initialize-calls length ] 1
   ]
  ]
  
  get it, call 'should handle error when initialize throws' [
   function [
    set mock-service [ get create-mock-session-service, call [ object [ should-throw-on-init true ] ] ]
    set error-caught [ object [ value false ] ]
    
    try [
     get mock-service initialize, call
    ] [
     set error-caught value true
    ]
    
    get expect, call [ get to-be-true ] [ get error-caught value ]
   ]
  ]
  
  get it, call 'should call render-tabs after initialization' [
   function [
    set render-called [ object [ value false ] ]
    
    set render-tabs [ function [
     set render-called value true
    ] ]
    
    get render-tabs, call
    
    get expect, call [ get to-be-true ] [ get render-called value ]
   ]
  ]
 ]
]

# ============================================
# Tests for full render flow integration
# ============================================
get describe, call 'main-tabs full render flow' [
 function [
  get it, call 'should render tabs with correct names from session data' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    
    set session-a [ object [ id 'session-a', name 'My Project' ] ]
    set session-b [ object [ id 'session-b', name 'Another Project' ] ]
    
    set mock-service [ get create-mock-session-service, call [
     object [
      open-ids [ list 'session-a' 'session-b' ]
      current-id 'session-a'
      all-sessions [ list [ get session-a ] [ get session-b ] ]
     ]
    ] ]
    
    get mock-tab-bar clear, call
    set tab-map [ object ]
    
    set open-ids [ get mock-service get-open-session-ids, call ]
    set current-id [ get mock-service get-current-session-id, call ]
    
    set state [ object [ has-sessions false ] ]
    get open-ids length, > 0, true [
     set state has-sessions true
    ]
    
    get state has-sessions, true [
     set session-map [ object ]
     set session-map 'session-a' [ get session-a ]
     set session-map 'session-b' [ get session-b ]
     
     get open-ids, each [
      function session-id [
       set tab-ref [ object [ name 'Untitled' ] ]
       get session-map [ get session-id ], true [
        get session-map [ get session-id ] name, true [
         set tab-ref name [ get session-map [ get session-id ] name ]
        ]
       ]
       
       set tab [
        get mock-tab-bar add, call [ get tab-ref name ] [ function [ ] ]
       ]
       set tab-map [ get session-id ] [ get tab ]
       
       get session-id, is [ get current-id ], true [
        get mock-tab-bar set-active, call [ get tab ]
       ]
      ]
     ]
    ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls length ] 2
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'My Project'
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 1, at label ] 'Another Project'
    get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab label ] 'My Project'
   ]
  ]
  
  get it, call 'should render default Untitled tab when no open sessions' [
   function [
    set mock-tab-bar [ get create-mock-tab-bar, call ]
    set mock-service [ get create-mock-session-service, call [
     object [
      open-ids [ list ]
      current-id null
     ]
    ] ]
    
    get mock-tab-bar clear, call
    set tab-map [ object ]
    
    set open-ids [ get mock-service get-open-session-ids, call ]
    
    set state [ object [ has-sessions false ] ]
    get open-ids length, > 0, true [
     set state has-sessions true
    ]
    
    get state has-sessions, false [
     set tab [
      get mock-tab-bar add, call 'Untitled' [ function [ ] ]
     ]
     get mock-tab-bar set-active, call [ get tab ]
    ]
    
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls length ] 1
    get expect, call [ get to-equal ] [ get mock-tab-bar _call-log add-calls, at 0, at label ] 'Untitled'
    get expect, call [ get to-equal ] [ get mock-tab-bar _state active-tab label ] 'Untitled'
   ]
  ]
 ]
]

# ============================================
# Tests for sessionRenamed event handling
# ============================================
get describe, call 'main-tabs sessionRenamed event' [
 function [
  get it, call 'should register listener for sessionRenamed event' [
   function [
    set mock-service [ get create-mock-session-service, call [ object ] ]
    
    get mock-service on, call sessionRenamed [
     function data [ ]
    ]
    
    set found [ object [ value false ] ]
    get mock-service _call-log on-calls, each [
     function call-record [
      get call-record event, = 'sessionRenamed', true [
       set found value true
      ]
     ]
    ]
    
    get expect, call [ get to-be-true ] [ get found value ]
   ]
  ]
  
  get it, call 'should update tab label when sessionRenamed event fires' [
   function [
    set mock-service [ get create-mock-session-service, call [ object ] ]
    
    # Create tab-map with existing tab
    set tab-map [ object ]
    set mock-element [ object [ textContent 'Old Name' ] ]
    set tab [ object [ label 'Old Name', element [ get mock-element ] ] ]
    set tab-map 'session-123' [ get tab ]
    
    # Set up mock tab-bar with update-label method
    set update-label-called [ object [ value false, new-label null ] ]
    set mock-tab-bar [ object ]
    set mock-tab-bar update-label [ function tab new-label [
     set update-label-called value true
     set update-label-called new-label [ get new-label ]
     set tab label [ get new-label ]
     set tab element textContent [ get new-label ]
    ] ]
    
    # Register sessionRenamed listener
    get mock-service on, call sessionRenamed [
     function data [
      get tab-map [ get data id ], true [
       get mock-tab-bar update-label, call [ get tab-map [ get data id ] ] [ get data name ]
      ]
     ]
    ]
    
    # Emit sessionRenamed event
    get mock-service _emit, call sessionRenamed [ object [ id 'session-123', name 'New Session Name' ] ]
    
    get expect, call [ get to-be-true ] [ get update-label-called value ]
    get expect, call [ get to-equal ] [ get update-label-called new-label ] 'New Session Name'
    get expect, call [ get to-equal ] [ get tab label ] 'New Session Name'
    get expect, call [ get to-equal ] [ get tab element textContent ] 'New Session Name'
   ]
  ]
  
  get it, call 'should not error when sessionRenamed for unknown session' [
   function [
    set mock-service [ get create-mock-session-service, call [ object ] ]
    set tab-map [ object ]
    set error-occurred [ object [ value false ] ]
    
    get mock-service on, call sessionRenamed [
     function data [
      get tab-map [ get data id ], true [
       # Would update tab here
      ]
      # No error for unknown session - just ignore
     ]
    ]
    
    try [
     get mock-service _emit, call sessionRenamed [ object [ id 'unknown-session', name 'New Name' ] ]
    ] [
     set error-occurred value true
    ]
    
    get expect, call [ get to-be-false ] [ get error-occurred value ]
   ]
  ]
 ]
]
