# Drag handler utility for mouse drag operations
# Provides common pattern for mousedown/mousemove/mouseup drag handling

# Create a drag handler function
# component: the component object (captured in closure)
# on-start: function(event, component) - called on mousedown, returns initial state object
# on-move: function(event, start-x, start-y, state, component, delta-x, delta-y) - called on mousemove
# on-end: function(state, component) - called on mouseup for cleanup
# Returns a function that can be used as a mousedown event handler
set create [
 function component on-start on-move on-end [
  function event [
   get event stopPropagation, tell
   get event preventDefault, tell
   set start-x [ get event clientX ]
   set start-y [ get event clientY ]
   set state-result [ get on-start, call [ get event ] [ get component ] ]
   set state [ get state-result ]
   set handle-mousemove [
    function event [
     set delta-x [ get event clientX, subtract [ get start-x ] ]
     set delta-y [ get event clientY, subtract [ get start-y ] ]
     get on-move, call [ get event ] [ get start-x ] [ get start-y ] [ get state ] [ get component ] [ get delta-x ] [ get delta-y ]
    ]
   ]
   set handle-mouseup [
    function event [
     get on-end, call [ get state ] [ get component ]
     global document removeEventListener, tell mousemove [ get handle-mousemove ]
     global document removeEventListener, tell mouseup [ get handle-mouseup ]
    ]
   ]
   global document addEventListener, tell mousemove [ get handle-mousemove ]
   global document addEventListener, tell mouseup [ get handle-mouseup ]
  ]
 ]
]

object [
 create [ get create ]
]
