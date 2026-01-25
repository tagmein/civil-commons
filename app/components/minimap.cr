get lib style-tag

tell .minimap [
 object [
  background-color '#1a1a1e'
  border '3px solid #c0c0c0'
  border-radius 2px
  bottom 20px
  height 200px
  pointer-events none
  position absolute
  right 20px
  width 200px
  z-index 1000
 ]
]

tell .minimap-content [
 object [
  height 100%
  overflow hidden
  pointer-events auto
  position relative
  width 100%
 ]
]

tell .minimap-window [
 object [
  background-color '#333337'
  border '1px solid #555559'
  cursor move
  position absolute
 ]
]

tell .minimap-viewport [
 object [
  background-color '#0066ff40'
  border '1px solid #0066ff'
  position absolute
  cursor move
 ]
]

function stage [
 set component [
  object [
   element [
    global document createElement, call div
   ]
   content [
    global document createElement, call div
   ]
   viewport [
    global document createElement, call div
   ]
   stage [ get stage ]
   windows [ object ]
   bounds [
    object [
     minX 0
     minY 0
     maxX 0
     maxY 0
    ]
   ]
   scale 0
   is-dragging-viewport false
   is-dragging-window false
   viewportX 0
   viewportY 0
   viewportWidth 0
   viewportHeight 0
   stage-width 0
   stage-height 0
  ]
 ]
 get component element classList add, call minimap
 get component content classList add, call minimap-content
 get component viewport classList add, call minimap-viewport
get component content appendChild, tell [ get component viewport ]
get component element appendChild, tell [ get component content ]

set update-stage-dimensions [
 function [
  get component stage, true [
   set stage-rect [
    get component stage content getBoundingClientRect, call
   ]
   set component stage-width [ get stage-rect width ]
   set component stage-height [ get stage-rect height ]
  ]
 ]
]

set update-bounds [
  function [
   set component _bounds-ref [
    object [
     minX null
     minY null
     maxX null
     maxY null
    ]
   ]
   get component stage, true [
    set stage-min-x 0
    set stage-min-y 0
    set stage-max-x [ get component stage-width ]
    set stage-max-y [ get component stage-height ]
    get component stage windows, each [
     function window [
      get window maximized, false [
       get window position, true [
        set window-x [ get window position x ]
        set window-y [ get window position y ]
        set window-width [ get window width ]
        set window-height [ get window height ]
        set window-right [ get window-x, add [ get window-width ] ]
        set window-bottom [ get window-y, add [ get window-height ] ]
        get component _bounds-ref minX, is null [
         set component _bounds-ref minX [ get window-x ]
         set component _bounds-ref minY [ get window-y ]
         set component _bounds-ref maxX [ get window-right ]
         set component _bounds-ref maxY [ get window-bottom ]
        ], false [
         get component _bounds-ref minX, > [ get window-x ], false [
          set component _bounds-ref minX [ get window-x ]
         ]
         get component _bounds-ref minY, > [ get window-y ], false [
          set component _bounds-ref minY [ get window-y ]
         ]
         get component _bounds-ref maxX, < [ get window-right ], false [
          set component _bounds-ref maxX [ get window-right ]
         ]
         get component _bounds-ref maxY, < [ get window-bottom ], false [
          set component _bounds-ref maxY [ get window-bottom ]
         ]
        ]
       ]
      ]
     ]
    ]
    set min-x-value [ get component _bounds-ref minX ]
    set min-y-value [ get component _bounds-ref minY ]
    set max-x-value [ get component _bounds-ref maxX ]
    set max-y-value [ get component _bounds-ref maxY ]
    get min-x-value, is null [
     set component _bounds-ref minX [ get stage-min-x ]
     set component _bounds-ref minY [ get stage-min-y ]
     set component _bounds-ref maxX [ get stage-max-x ]
     set component _bounds-ref maxY [ get stage-max-y ]
    ], false [
     get min-x-value, < [ get stage-min-x ], true [
      set component _bounds-ref minX [ get min-x-value ]
     ], false [
      set component _bounds-ref minX [ get stage-min-x ]
     ]
     get min-y-value, < [ get stage-min-y ], true [
      set component _bounds-ref minY [ get min-y-value ]
     ], false [
      set component _bounds-ref minY [ get stage-min-y ]
     ]
     get max-x-value, > [ get stage-max-x ], true [
      set component _bounds-ref maxX [ get max-x-value ]
     ], false [
      set component _bounds-ref maxX [ get stage-max-x ]
     ]
     get max-y-value, > [ get stage-max-y ], true [
      set component _bounds-ref maxY [ get max-y-value ]
     ], false [
      set component _bounds-ref maxY [ get stage-max-y ]
     ]
    ]
    set final-min-x [ get component _bounds-ref minX ]
    set final-min-y [ get component _bounds-ref minY ]
    set final-max-x [ get component _bounds-ref maxX ]
    set final-max-y [ get component _bounds-ref maxY ]
    set component bounds [
     object [
      minX [ get final-min-x ]
      minY [ get final-min-y ]
      maxX [ get final-max-x ]
      maxY [ get final-max-y ]
     ]
    ]
   ], false [
    set component bounds [
     object [
      minX 0
      minY 0
      maxX 1000
      maxY 1000
     ]
    ]
   ]
   get component update-display, call
  ]
 ]

 set update-display [
  function [
   set content-rect [
    get component content getBoundingClientRect, call
   ]
   set content-width [ get content-rect width ]
   set content-height [ get content-rect height ]
   set bounds-width [ get component bounds maxX, subtract [ get component bounds minX ] ]
   set bounds-height [ get component bounds maxY, subtract [ get component bounds minY ] ]
   get content-width, > 0, true [
    get content-height, > 0, true [
     get bounds-width, > 0, true [
      get bounds-height, > 0, true [
       set scale-x [ get content-width, divide [ get bounds-width ] ]
       set scale-y [ get content-height, divide [ get bounds-height ] ]
       set min-scale [ get scale-x ]
       get scale-y, < [ get scale-x ], true [
        set min-scale [ get scale-y ]
       ]
       set component scale [ get min-scale ]
      ]
     ]
    ]
   ]
   get component stage, true [
    get component stage windows, each [
     function window [
      get window maximized, false [
       get window minimap-element, true [
        get window position, true [
         get component scale, > 0, true [
          set window-x [ get window position x ]
          set window-y [ get window position y ]
          set window-width [ get window width ]
          set window-height [ get window height ]
          set bounds-min-x [ get component bounds minX ]
          set bounds-min-y [ get component bounds minY ]
          set scaled-x [
           get window-x, subtract [ get bounds-min-x ], multiply [ get component scale ]
          ]
          set scaled-y [
           get window-y, subtract [ get bounds-min-y ], multiply [ get component scale ]
          ]
          set scaled-width [ get window-width, multiply [ get component scale ] ]
          set scaled-height [ get window-height, multiply [ get component scale ] ]
          set [ get window minimap-element ] style left [
           template %0px [ get scaled-x ]
          ]
          set [ get window minimap-element ] style top [
           template %0px [ get scaled-y ]
          ]
          set [ get window minimap-element ] style width [
           template %0px [ get scaled-width ]
          ]
          set [ get window minimap-element ] style height [
           template %0px [ get scaled-height ]
          ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
   get component stage, true [
    set stage-width [ get component stage-width ]
    set stage-height [ get component stage-height ]
    get stage-width, > 0, true [
     get stage-height, > 0, true [
      get component scale, > 0, true [
       set component viewportWidth [ get stage-width, multiply [ get component scale ] ]
       set component viewportHeight [ get stage-height, multiply [ get component scale ] ]
      ], false [
       set component viewportWidth 0
       set component viewportHeight 0
      ]
      get component scale, > 0, true [
       get component is-dragging-viewport, false [
        set bounds-min-x [ get component bounds minX ]
        set bounds-min-y [ get component bounds minY ]
        set calculated-viewport-x [
         get bounds-min-x, multiply -1, multiply [ get component scale ]
        ]
        set calculated-viewport-y [
         get bounds-min-y, multiply -1, multiply [ get component scale ]
        ]
        set min-viewport-x 0
        set min-viewport-y 0
        set max-viewport-x [ get content-width, subtract [ get component viewportWidth ] ]
        set max-viewport-y [ get content-height, subtract [ get component viewportHeight ] ]
        get max-viewport-x, < 0, true [
         set max-viewport-x 0
        ]
        get max-viewport-y, < 0, true [
         set max-viewport-y 0
        ]
        set component viewportX [ get calculated-viewport-x ]
        get component viewportX, < [ get min-viewport-x ], true [
         set component viewportX [ get min-viewport-x ]
        ]
        get component viewportX, > [ get max-viewport-x ], true [
         set component viewportX [ get max-viewport-x ]
        ]
        set component viewportY [ get calculated-viewport-y ]
        get component viewportY, < [ get min-viewport-y ], true [
         set component viewportY [ get min-viewport-y ]
        ]
        get component viewportY, > [ get max-viewport-y ], true [
         set component viewportY [ get max-viewport-y ]
        ]
       ]
      ], false [
       set component viewportX 0
       set component viewportY 0
      ]
      set [ get component viewport ] style left [
       template %0px [ get component viewportX ]
      ]
      set [ get component viewport ] style top [
       template %0px [ get component viewportY ]
      ]
      set [ get component viewport ] style width [
       template %0px [ get component viewportWidth ]
      ]
      set [ get component viewport ] style height [
       template %0px [ get component viewportHeight ]
      ]
     ]
    ]
   ]
  ]
 ]

 set add-window [
  function window [
   get component windows [ get window ], false [
    set minimap-window-element [
     global document createElement, call div
    ]
    get minimap-window-element classList add, call minimap-window
    get component content appendChild, tell [ get minimap-window-element ]
    set component windows [ get window ] [ get minimap-window-element ]
    set window minimap-element [ get minimap-window-element ]
    set start-window-drag [
     function event [
      get event stopPropagation, tell
      get event preventDefault, tell
      set component is-dragging-window true
      set component dragged-window [ get window ]
      set component drag-start-x [ get event clientX ]
      set component drag-start-y [ get event clientY ]
      get window position, true [
       set component drag-start-window-x [ get window position x ]
       set component drag-start-window-y [ get window position y ]
      ]
      set handle-window-mousemove [
       function event [
        get component is-dragging-window, true [
         get component dragged-window, true [
          set delta-x [ get event clientX, subtract [ get component drag-start-x ] ]
          set delta-y [ get event clientY, subtract [ get component drag-start-y ] ]
          set stage-delta-x [ get delta-x, divide [ get component scale ] ]
          set stage-delta-y [ get delta-y, divide [ get component scale ] ]
          get component dragged-window maximized, false [
           get component drag-start-window-x, true [
            get component drag-start-window-y, true [
             set new-x [ get component drag-start-window-x, add [ get stage-delta-x ] ]
             set new-y [ get component drag-start-window-y, add [ get stage-delta-y ] ]
             set component dragged-window position [
              object [
               x [ get new-x ]
               y [ get new-y ]
              ]
             ]
             set [ get component dragged-window ] element style transform [
              template 'translate(%0px, %1px)' [ get component dragged-window position x ] [ get component dragged-window position y ]
             ]
             get component update-bounds, call
            ]
           ]
          ]
         ]
        ]
       ]
      ]
      set handle-window-mouseup [
       function event [
        set component is-dragging-window false
        unset component dragged-window
        unset component drag-start-window-x
        unset component drag-start-window-y
        global document removeEventListener, tell mousemove [ get handle-window-mousemove ]
        global document removeEventListener, tell mouseup [ get handle-window-mouseup ]
       ]
      ]
      global document addEventListener, tell mousemove [ get handle-window-mousemove ]
      global document addEventListener, tell mouseup [ get handle-window-mouseup ]
     ]
    ]
    get minimap-window-element addEventListener, tell mousedown [
     get start-window-drag
    ]
    get component update-bounds, call
    global setTimeout, call [
     function [
      get component update-display, call
     ]
    ] 0
   ]
  ]
 ]

 set remove-window [
  function window [
   get component windows [ get window ], true [
    get window minimap-element, true [
     get window minimap-element parentNode, true [
      get window minimap-element parentNode removeChild, call [ get window minimap-element ]
     ]
    ]
    unset component windows [ get window ]
    unset window minimap-element
    get component update-bounds, call
   ]
  ]
 ]

 set update-window [
  function window [
   get component windows [ get window ], true [
    get component update-bounds, call
   ]
  ]
 ]

 set start-viewport-drag [
  function event [
   set component is-dragging-viewport true
   get event stopPropagation, tell
   get event preventDefault, tell
   set component drag-start-x [ get event clientX ]
   set component drag-start-y [ get event clientY ]
   set component drag-start-viewport-x [ get component viewportX ]
   set component drag-start-viewport-y [ get component viewportY ]
   set component drag-start-positions [ object ]
   get component stage, true [
    get component stage windows, each [
     function window [
      get window maximized, false [
       get window position, true [
        set component drag-start-positions [ get window ] [
         object [
          x [ get window position x ]
          y [ get window position y ]
         ]
        ]
       ]
      ]
     ]
    ]
   ]
   set handle-viewport-mousemove [
    function event [
     get component is-dragging-viewport, true [
      set content-width [ get component content offsetWidth ]
      set content-height [ get component content offsetHeight ]
      set delta-x [ get event clientX, subtract [ get component drag-start-x ] ]
      set delta-y [ get event clientY, subtract [ get component drag-start-y ] ]
      set new-viewport-x [ get component drag-start-viewport-x, add [ get delta-x ] ]
      set new-viewport-y [ get component drag-start-viewport-y, add [ get delta-y ] ]
      set min-x 0
      set min-y 0
      set max-x [ get content-width, subtract [ get component viewportWidth ] ]
      set max-y [ get content-height, subtract [ get component viewportHeight ] ]
      get max-x, < 0, true [
       set max-x 0
      ]
      get max-y, < 0, true [
       set max-y 0
      ]
      get new-viewport-x, < [ get min-x ], true [
       set new-viewport-x [ get min-x ]
      ]
      get new-viewport-x, > [ get max-x ], true [
       set new-viewport-x [ get max-x ]
      ]
      get new-viewport-y, < [ get min-y ], true [
       set new-viewport-y [ get min-y ]
      ]
      get new-viewport-y, > [ get max-y ], true [
       set new-viewport-y [ get max-y ]
      ]
      set viewport-delta-x [ get new-viewport-x, subtract [ get component drag-start-viewport-x ] ]
      set viewport-delta-y [ get new-viewport-y, subtract [ get component drag-start-viewport-y ] ]
      set scaled-delta-x [ get viewport-delta-x, divide [ get component scale ] ]
      set scaled-delta-y [ get viewport-delta-y, divide [ get component scale ] ]
      set stage-delta-x [ get scaled-delta-x, multiply -1 ]
      set stage-delta-y [ get scaled-delta-y, multiply -1 ]
      get component stage, true [
       get component stage windows, each [
        function window [
         get component drag-start-positions [ get window ], true [
          set start-pos [ get component drag-start-positions [ get window ] ]
          get window maximized, false [
           set new-x [ get start-pos x, add [ get stage-delta-x ] ]
           set new-y [ get start-pos y, add [ get stage-delta-y ] ]
           set window position [
            object [
             x [ get new-x ]
             y [ get new-y ]
            ]
           ]
           set [ get window ] element style transform [
            template 'translate(%0px, %1px)' [ get window position x ] [ get window position y ]
           ]
          ]
         ]
        ]
       ]
      ]
      set component viewportX [ get new-viewport-x ]
      set component viewportY [ get new-viewport-y ]
      set [ get component viewport ] style left [
       template %0px [ get component viewportX ]
      ]
      set [ get component viewport ] style top [
       template %0px [ get component viewportY ]
      ]
      get component update-bounds, call
     ]
    ]
   ]
   set handle-viewport-mouseup [
    function event [
     set component is-dragging-viewport false
     unset component drag-start-positions
     get component update-bounds, call
     global document removeEventListener, tell mousemove [ get handle-viewport-mousemove ]
     global document removeEventListener, tell mouseup [ get handle-viewport-mouseup ]
    ]
   ]
   global document addEventListener, tell mousemove [ get handle-viewport-mousemove ]
   global document addEventListener, tell mouseup [ get handle-viewport-mouseup ]
  ]
 ]

 get component viewport addEventListener, tell mousedown [
  get start-viewport-drag
 ]

set component add-window [ get add-window ]
set component remove-window [ get remove-window ]
set component update-window [ get update-window ]
set component update-bounds [ get update-bounds ]
set component update-display [ get update-display ]
set component update-stage-dimensions [ get update-stage-dimensions ]

set resize-handler [
 function [
  get component update-stage-dimensions, call
  get component update-bounds, call
 ]
]
global addEventListener, call resize [ get resize-handler ]
get component update-stage-dimensions, call
global setTimeout, call [ get resize-handler ]

 get component
]
