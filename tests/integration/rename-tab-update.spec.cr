# Integration test for session rename -> tab update flow
# Tests that renaming a session correctly updates the tab label

get describe, call 'rename -> tab update integration' [
 function [
  get describe, call 'tab-map reference issue' [
   function [
    get it, call 'demonstrates that set creates local scope (returns undefined)' [
     function [
      # This test demonstrates the Crown scoping issue
      # When you set a variable inside a function, it creates a new local
      # unless you use a reference object pattern
      
      # Initial object
      set tab-map [ object ]
      
      # Closure captures tab-map
      set get-from-map [ function id [
       get tab-map [ get id ]
      ] ]
      
      # Function that tries to update tab-map
      set populate-map [ function [
       set tab-map [ object ]
       set tab-map 'session-1' 'Tab 1'
       set tab-map 'session-2' 'Tab 2'
      ] ]
      
      # Call populate
      get populate-map, call
      
      # Try to get from map via closure - returns undefined because set created a new local
      set result [ get get-from-map, call 'session-1' ]
      
      # This returns undefined because the inner function's set created a new local variable
      # We check typeof result equals 'undefined'
      get expect, call [ get to-equal ] [ get result, typeof ] 'undefined'
     ]
    ]
    
    get it, call 'should work with reference object pattern' [
     function [
      # Using reference object pattern to avoid scoping issues
      
      # Initial reference object containing the map
      set tab-map-ref [ object [ map [ object ] ] ]
      
      # Closure captures tab-map-ref (the reference object, not its contents)
      set get-from-map [ function id [
       get tab-map-ref map [ get id ]
      ] ]
      
      # Function that updates the map inside the reference
      set populate-map [ function [
       set tab-map-ref map [ object ]
       set tab-map-ref map 'session-1' 'Tab 1'
       set tab-map-ref map 'session-2' 'Tab 2'
      ] ]
      
      # Call populate
      get populate-map, call
      
      # Get from map via closure - should work with reference pattern
      set result [ get get-from-map, call 'session-1' ]
      
      get expect, call [ get to-equal ] [ get result ] 'Tab 1'
     ]
    ]
   ]
  ]
  
  get describe, call 'session service event emission' [
   function [
    get it, call 'should emit sessionRenamed event with id and name' [
     function [
      # Set up a mock listeners structure like service.cr
      set listeners [ object [
       sessionRenamed [ list ]
      ] ]
      
      # Set up emit function
      set emit [ function event-name data [
       get listeners [ get event-name ], each [
        function callback [
         get callback, call [ get data ]
        ]
       ]
      ] ]
      
      # Set up on function
      set on [ function event-name callback [
       get listeners [ get event-name ] push, call [ get callback ]
      ] ]
      
      # Track received events
      set received [ object [ id null, name null ] ]
      
      # Register listener
      get on, call sessionRenamed [
       function data [
        set received id [ get data id ]
        set received name [ get data name ]
       ]
      ]
      
      # Emit event (simulating rename-session)
      get emit, call sessionRenamed [ object [ id 'test-session', name 'New Name' ] ]
      
      get expect, call [ get to-equal ] [ get received id ] 'test-session'
      get expect, call [ get to-equal ] [ get received name ] 'New Name'
     ]
    ]
   ]
  ]
  
  get describe, call 'tab-bar update-label' [
   function [
    get it, call 'should update tab element textContent and label property' [
     function [
      # Mock tab with element
      set mock-element [ object [ textContent 'Old Name' ] ]
      set tab [ object [
       element [ get mock-element ]
       label 'Old Name'
      ] ]
      
      # update-label function (from tab-bar.cr)
      set update-label [ function tab new-label [
       set tab element textContent [ get new-label ]
       set tab label [ get new-label ]
      ] ]
      
      # Call update-label
      get update-label, call [ get tab ] 'New Name'
      
      get expect, call [ get to-equal ] [ get tab element textContent ] 'New Name'
      get expect, call [ get to-equal ] [ get tab label ] 'New Name'
     ]
    ]
   ]
  ]
  
  get describe, call 'end-to-end flow with reference pattern' [
   function [
    get it, call 'should update tab when session is renamed' [
     function [
      # Set up service mock with event system
      set listeners [ object [ sessionRenamed [ list ] ] ]
      
      set service [ object ]
      set service on [ function event-name callback [
       get listeners [ get event-name ] push, call [ get callback ]
      ] ]
      set service emit [ function event-name data [
       get listeners [ get event-name ], each [
        function callback [
         get callback, call [ get data ]
        ]
       ]
      ] ]
      set service rename-session [ function id new-name [
       # Simulate API call success
       get service emit, call sessionRenamed [ object [ id [ get id ], name [ get new-name ] ] ]
      ] ]
      
      # Set up tabs with reference pattern
      set tab-map-ref [ object [ map [ object ] ] ]
      
      # Mock tab-bar
      set mock-element [ object [ textContent 'Old Name' ] ]
      set tab [ object [ element [ get mock-element ], label 'Old Name' ] ]
      set tab-map-ref map 'session-123' [ get tab ]
      
      set main-tabs [ object ]
      set main-tabs update-label [ function tab new-label [
       set tab element textContent [ get new-label ]
       set tab label [ get new-label ]
      ] ]
      
      # Register sessionRenamed listener (like main-tabs.cr should do)
      get service on, call sessionRenamed [
       function data [
        get tab-map-ref map [ get data id ], true [
         get main-tabs update-label, call [ get tab-map-ref map [ get data id ] ] [ get data name ]
        ]
       ]
      ]
      
      # Trigger rename (like rename.cr does)
      get service rename-session, call 'session-123' 'My Renamed Session'
      
      # Verify tab was updated
      get expect, call [ get to-equal ] [ get tab element textContent ] 'My Renamed Session'
      get expect, call [ get to-equal ] [ get tab label ] 'My Renamed Session'
     ]
    ]
   ]
  ]
 ]
]
