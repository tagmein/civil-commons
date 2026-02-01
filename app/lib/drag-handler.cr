# Drag handler utility for mouse drag operations
# Provides common pattern for mousedown/mousemove/mouseup drag handling

# Create a drag handler function
# component: the component object (captured in closure)
# onStart: function(event, component) - called on mousedown, returns initial state object
# onMove: function(event, startX, startY, state, component, deltaX, deltaY) - called on mousemove
# onEnd: function(state, component) - called on mouseup for cleanup
# Returns a function that can be used as a mousedown event handler
set create [
 function component onStart onMove onEnd [
  function event [
   get event stopPropagation, tell
   get event preventDefault, tell
   set startX [ get event clientX ]
   set startY [ get event clientY ]
   set stateResult [ get onStart, call [ get event ] [ get component ] ]
   set state [ get stateResult ]
   set handleMousemove [
    function event [
     set deltaX [ get event clientX, subtract [ get startX ] ]
     set deltaY [ get event clientY, subtract [ get startY ] ]
     get onMove, call [ get event ] [ get startX ] [ get startY ] [ get state ] [ get component ] [ get deltaX ] [ get deltaY ]
    ]
   ]
   set handleMouseup [
    function event [
     get onEnd, call [ get state ] [ get component ]
     global document removeEventListener, tell mousemove [ get handleMousemove ]
     global document removeEventListener, tell mouseup [ get handleMouseup ]
    ]
   ]
   global document addEventListener, tell mousemove [ get handleMousemove ]
   global document addEventListener, tell mouseup [ get handleMouseup ]
  ]
 ]
]

object [
 create [ get create ]
]
