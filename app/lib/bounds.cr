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
  set merged-ref [
   object [
    minX [ get stage-min-x ]
    minY [ get stage-min-y ]
    maxX [ get stage-max-x ]
    maxY [ get stage-max-y ]
   ]
  ]
  get window-min-x, < [ get merged-ref minX ], true [
   set merged-ref minX [ get window-min-x ]
  ]
  get window-min-y, < [ get merged-ref minY ], true [
   set merged-ref minY [ get window-min-y ]
  ]
  get window-max-x, > [ get merged-ref maxX ], true [
   set merged-ref maxX [ get window-max-x ]
  ]
  get window-max-y, > [ get merged-ref maxY ], true [
   set merged-ref maxY [ get window-max-y ]
  ]
  set result [
   object [
    minX [ get merged-ref minX ]
    minY [ get merged-ref minY ]
    maxX [ get merged-ref maxX ]
    maxY [ get merged-ref maxY ]
   ]
  ]
  get result
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
