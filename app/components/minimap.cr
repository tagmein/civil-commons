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
        get lib bounds expand-rect, call [ get component _bounds-ref ] [ get window-x ] [ get window-y ] [ get window-width ] [ get window-height ]
       ]
      ]
     ]
    ]
    set window-bounds [
     object [
      minX [ get component _bounds-ref minX ]
      minY [ get component _bounds-ref minY ]
      maxX [ get component _bounds-ref maxX ]
      maxY [ get component _bounds-ref maxY ]
     ]
    ]
    set stage-bounds [
     object [
      minX [ get stage-min-x ]
      minY [ get stage-min-y ]
      maxX [ get stage-max-x ]
      maxY [ get stage-max-y ]
     ]
    ]
    set window-bounds-width [ get window-bounds maxX, subtract [ get window-bounds minX ] ]
    set window-bounds-height [ get window-bounds maxY, subtract [ get window-bounds minY ] ]
    get window-bounds-width, > 0, true [
     get window-bounds-height, > 0, true [
      set merged-bounds [
       get lib bounds merge-bounds, call [ get window-bounds ] [ get stage-bounds ]
      ]
      set component bounds [ get merged-bounds ]
     ], false [
      set component bounds [ get stage-bounds ]
     ]
    ], false [
     set component bounds [ get stage-bounds ]
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
       set min-scale-ref [
        object [
         value [ get scale-x ]
        ]
       ]
       get scale-y, < [ get scale-x ], true [
        set min-scale-ref value [ get scale-y ]
       ]
       set component scale [ get min-scale-ref value ]
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
     get lib drag-handler create, call [ get component ] [
      function event component [
       set component is-dragging-window true
       set component dragged-window [ get window ]
       set return-ref [ object [ value null ] ]
       get window position, true [
        set return-ref value [
         object [
          window [ get window ]
          start-x [ get window position x ]
          start-y [ get window position y ]
         ]
        ]
       ], false [
        set return-ref value [
         object [
          window [ get window ]
          start-x null
          start-y null
         ]
        ]
       ]
       get return-ref value
      ]
     ] [
      function event start-x start-y state component delta-x delta-y [
       get state, true [
        set dragged-window [ get state window ]
        get component is-dragging-window, true [
         get component dragged-window, true [
          get dragged-window, true [
           get state start-x, true [
            get state start-y, true [
             set stage-delta-x [ get delta-x, divide [ get component scale ] ]
             set stage-delta-y [ get delta-y, divide [ get component scale ] ]
             get dragged-window maximized, false [
              set new-pos-ref [
               object [
                x [ get state start-x, add [ get stage-delta-x ] ]
                y [ get state start-y, add [ get stage-delta-y ] ]
               ]
              ]
              get new-pos-ref x, < -6000, true [
               set new-pos-ref x -6000
              ]
              get new-pos-ref y, < -6000, true [
               set new-pos-ref y -6000
              ]
              set window-right [ get new-pos-ref x, add [ get dragged-window width ] ]
              get window-right, > 6000, true [
               set new-pos-ref x [ value 6000, subtract [ get dragged-window width ] ]
              ]
              set window-bottom [ get new-pos-ref y, add [ get dragged-window height ] ]
              get window-bottom, > 6000, true [
               set new-pos-ref y [ value 6000, subtract [ get dragged-window height ] ]
              ]
              set dragged-window position [
               object [
                x [ get new-pos-ref x ]
                y [ get new-pos-ref y ]
               ]
              ]
              set [ get dragged-window ] element style transform [
               template 'translate(%0px, %1px)' [ get dragged-window position x ] [ get dragged-window position y ]
              ]
              get component update-bounds, call
             ]
            ]
           ]
          ]
         ]
        ]
       ]
      ]
     ] [
      function state component [
       get state, true [
        set component is-dragging-window false
        unset component dragged-window
        get component update-bounds, call
       ]
      ]
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
  get lib drag-handler create, call [ get component ] [
   function event component [
    set component is-dragging-viewport true
    set drag-start-positions [ object ]
    get component stage, true [
     get component stage windows, each [
      function window [
       get window maximized, false [
        get window position, true [
         set drag-start-positions [ get window ] [
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
    object [
     drag-start-positions [ get drag-start-positions ]
    ]
   ]
  ] [
   function event start-x start-y state component delta-x delta-y [
    get component is-dragging-viewport, true [
     get component update-bounds, call
     set scaled-delta-x [ get delta-x, divide [ get component scale ] ]
     set scaled-delta-y [ get delta-y, divide [ get component scale ] ]
     set stage-delta-x [ get scaled-delta-x, multiply -1, divide [ value 10 ] ]
     set stage-delta-y [ get scaled-delta-y, multiply -1, divide [ value 10 ] ]
     get component stage, true [
      get component stage windows, each [
       function window [
         get state drag-start-positions [ get window ], true [
         set start-pos [ get state drag-start-positions [ get window ] ]
         get window maximized, false [
          set new-pos-ref [
           object [
            x [ get start-pos x, add [ get stage-delta-x ] ]
            y [ get start-pos y, add [ get stage-delta-y ] ]
           ]
          ]
          get new-pos-ref x, < -6000, true [
           set new-pos-ref x -6000
          ]
          get new-pos-ref y, < -6000, true [
           set new-pos-ref y -6000
          ]
          set window-right [ get new-pos-ref x, add [ get window width ] ]
          get window-right, > 6000, true [
           set new-pos-ref x [ value 6000, subtract [ get window width ] ]
          ]
          set window-bottom [ get new-pos-ref y, add [ get window height ] ]
          get window-bottom, > 6000, true [
           set new-pos-ref y [ value 6000, subtract [ get window height ] ]
          ]
          set window position [
           object [
            x [ get new-pos-ref x ]
            y [ get new-pos-ref y ]
           ]
          ]
          set [ get window ] element style transform [
           template 'translate(%0px, %1px)' [ get window position x ] [ get window position y ]
          ]
          set state drag-start-positions [ get window ] [
           object [
            x [ get new-pos-ref x ]
            y [ get new-pos-ref y ]
           ]
          ]
         ]
        ]
       ]
      ]
     ]
     get component update-bounds, call
    ]
   ]
  ] [
   function state component [
    set component is-dragging-viewport false
    get component update-bounds, call
   ]
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
