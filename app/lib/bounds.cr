# Bounds utility functions for geometric calculations
# Virtual stage is 10000x10000 pixels (0,0) to (10000,10000)

set VIRTUAL_STAGE_SIZE 10000

# Clamp a value to a range [min, max]
# Returns min if value < min, max if value > max, otherwise value
set clamp [
 function value min-val max-val [
  # Use a reference object to allow modification in conditionals
  set ref [ object [ result [ get value ] ] ]
  get ref result, < [ get min-val ], true [
   set ref result [ get min-val ]
  ]
  get ref result, > [ get max-val ], true [
   set ref result [ get max-val ]
  ]
  get ref result
 ]
]

# Helper: ensure a max value is at least 0
set max-with-floor [
 function val [
  set ref [ object [ result [ get val ] ] ]
  get ref result, < 0, true [
   set ref result 0
  ]
  get ref result
 ]
]

# Clamp a window position to stay within virtual stage (0 to 10000-size)
set clamp-window-position [
 function x y width height [
  # Calculate max positions (ensure they're at least 0)
  set max-x-raw [ value 10000, subtract [ get width ] ]
  set max-y-raw [ value 10000, subtract [ get height ] ]
  set max-x [ get max-with-floor, call [ get max-x-raw ] ]
  set max-y [ get max-with-floor, call [ get max-y-raw ] ]
  # Clamp x and y
  set clamped-x [ get clamp, call [ get x ] 0 [ get max-x ] ]
  set clamped-y [ get clamp, call [ get y ] 0 [ get max-y ] ]
  object [
   x [ get clamped-x ]
   y [ get clamped-y ]
  ]
 ]
]

# Clamp window size (minimum 100x100, maximum fits in stage from position)
set clamp-window-size [
 function x y width height [
  set max-width [ value 10000, subtract [ get x ] ]
  set max-height [ value 10000, subtract [ get y ] ]
  # Apply minimum size and maximum
  set clamped-width [ get clamp, call [ get width ] 100 [ get max-width ] ]
  set clamped-height [ get clamp, call [ get height ] 100 [ get max-height ] ]
  object [
   width [ get clamped-width ]
   height [ get clamped-height ]
  ]
 ]
]

# Clamp viewport position within virtual stage
set clamp-viewport-position [
 function x y viewport-width viewport-height [
  # Calculate max positions (ensure they're at least 0)
  set max-x-raw [ value 10000, subtract [ get viewport-width ] ]
  set max-y-raw [ value 10000, subtract [ get viewport-height ] ]
  set max-x [ get max-with-floor, call [ get max-x-raw ] ]
  set max-y [ get max-with-floor, call [ get max-y-raw ] ]
  # Clamp x and y
  set clamped-x [ get clamp, call [ get x ] 0 [ get max-x ] ]
  set clamped-y [ get clamp, call [ get y ] 0 [ get max-y ] ]
  object [
   x [ get clamped-x ]
   y [ get clamped-y ]
  ]
 ]
]

# Calculate minimap scale (minimap-size / 10000)
set calculate-minimap-scale [
 function minimap-size [
  get minimap-size, divide 10000
 ]
]

# Convert stage coordinates to minimap coordinates
set stage-to-minimap [
 function stage-x stage-y scale [
  object [
   x [ get stage-x, multiply [ get scale ] ]
   y [ get stage-y, multiply [ get scale ] ]
  ]
 ]
]

# Convert minimap coordinates to stage coordinates
set minimap-to-stage [
 function minimap-x minimap-y scale [
  object [
   x [ get minimap-x, divide [ get scale ] ]
   y [ get minimap-y, divide [ get scale ] ]
  ]
 ]
]

# Scale dimensions for minimap
set scale-dimensions [
 function width height scale [
  object [
   width [ get width, multiply [ get scale ] ]
   height [ get height, multiply [ get scale ] ]
  ]
 ]
]

# Export module
object [
 VIRTUAL_STAGE_SIZE [ get VIRTUAL_STAGE_SIZE ]
 clamp [ get clamp ]
 clamp-window-position [ get clamp-window-position ]
 clamp-window-size [ get clamp-window-size ]
 clamp-viewport-position [ get clamp-viewport-position ]
 calculate-minimap-scale [ get calculate-minimap-scale ]
 stage-to-minimap [ get stage-to-minimap ]
 minimap-to-stage [ get minimap-to-stage ]
 scale-dimensions [ get scale-dimensions ]
]
