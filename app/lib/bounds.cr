# Bounds utility functions for geometric calculations

set calculate-scale [
 function container-width container-height bounds-width bounds-height [
  get container-width, > 0, true [
   get container-height, > 0, true [
    get bounds-width, > 0, true [
     get bounds-height, > 0, true [
      set scale-x [ get container-width, divide [ get bounds-width ] ]
      set scale-y [ get container-height, divide [ get bounds-height ] ]
      set min-scale [ get scale-x ]
      get scale-y, < [ get scale-x ], true [
       set min-scale [ get scale-y ]
      ]
      get min-scale
     ], false [
      0
     ]
    ], false [
     0
    ]
   ], false [
    0
   ]
  ], false [
   0
  ]
 ]
]

set merge-bounds [
 function window-bounds stage-bounds [
  set window-min-x [ get window-bounds minX ]
  set window-min-y [ get window-bounds minY ]
  set window-max-x [ get window-bounds maxX ]
  set window-max-y [ get window-bounds maxY ]
  set stage-min-x [ get stage-bounds minX ]
  set stage-min-y [ get stage-bounds minY ]
  set stage-max-x [ get stage-bounds maxX ]
  set stage-max-y [ get stage-bounds maxY ]
  set merged-min-x [ get stage-min-x ]
  get window-min-x, < [ get stage-min-x ], true [
   set merged-min-x [ get window-min-x ]
  ]
  set merged-min-y [ get stage-min-y ]
  get window-min-y, < [ get stage-min-y ], true [
   set merged-min-y [ get window-min-y ]
  ]
  set merged-max-x [ get stage-max-x ]
  get window-max-x, > [ get stage-max-x ], true [
   set merged-max-x [ get window-max-x ]
  ]
  set merged-max-y [ get stage-max-y ]
  get window-max-y, > [ get stage-max-y ], true [
   set merged-max-y [ get window-max-y ]
  ]
  object [
   minX [ get merged-min-x ]
   minY [ get merged-min-y ]
   maxX [ get merged-max-x ]
   maxY [ get merged-max-y ]
  ]
 ]
]

set expand-rect [
 function bounds-ref x y width height [
  set right [ get x, add [ get width ] ]
  set bottom [ get y, add [ get height ] ]
  get bounds-ref minX, is null [
   set bounds-ref minX [ get x ]
   set bounds-ref minY [ get y ]
   set bounds-ref maxX [ get right ]
   set bounds-ref maxY [ get bottom ]
  ], false [
   get bounds-ref minX, > [ get x ], false [
    set bounds-ref minX [ get x ]
   ]
   get bounds-ref minY, > [ get y ], false [
    set bounds-ref minY [ get y ]
   ]
   get bounds-ref maxX, < [ get right ], false [
    set bounds-ref maxX [ get right ]
   ]
   get bounds-ref maxY, < [ get bottom ], false [
    set bounds-ref maxY [ get bottom ]
   ]
  ]
 ]
]

object [
 calculate-scale [ get calculate-scale ]
 merge-bounds [ get merge-bounds ]
 expand-rect [ get expand-rect ]
]
