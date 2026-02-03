# Load bounds module for testing
load ../lib/bounds.cr, point, to bounds

# Window component tests for 10000x10000 virtual stage
set VIRTUAL_STAGE_SIZE 10000
set MIN_WINDOW_WIDTH 150
set MIN_WINDOW_HEIGHT 100

get describe, call 'window position constraints' [
 function [
  get describe, call 'clamping to virtual stage bounds' [
   function [
    get it, call 'should keep window at origin when placed at (0,0)' [
     function [
      set clamped [ get bounds clamp-window-position, call 0 0 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should clamp negative x to 0' [
     function [
      set clamped [ get bounds clamp-window-position, call -100 200 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 200
     ]
    ]
    
    get it, call 'should clamp negative y to 0' [
     function [
      set clamped [ get bounds clamp-window-position, call 100 -200 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 100
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should clamp window to not exceed right edge' [
     function [
      set clamped [ get bounds clamp-window-position, call 9800 200 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 200
     ]
    ]
    
    get it, call 'should clamp window to not exceed bottom edge' [
     function [
      set clamped [ get bounds clamp-window-position, call 200 9700 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 200
      get expect, call [ get to-equal ] [ get clamped y ] 9600
     ]
    ]
    
    get it, call 'should clamp both x and y when needed' [
     function [
      set clamped [ get bounds clamp-window-position, call -100 11000 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 9600
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'window size constraints' [
 function [
  get describe, call 'minimum size' [
   function [
    get it, call 'should enforce minimum width of 100' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 100 50 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 100
     ]
    ]
    
    get it, call 'should enforce minimum height of 100' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 100 500 50 ]
      get expect, call [ get to-equal ] [ get clamped height ] 100
     ]
    ]
    
    get it, call 'should enforce both minimum dimensions' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 100 50 50 ]
      get expect, call [ get to-equal ] [ get clamped width ] 100
      get expect, call [ get to-equal ] [ get clamped height ] 100
     ]
    ]
   ]
  ]
  
  get describe, call 'maximum size based on position' [
   function [
    get it, call 'should clamp width to not exceed stage boundary' [
     function [
      set clamped [ get bounds clamp-window-size, call 9500 100 1000 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 500
     ]
    ]
    
    get it, call 'should clamp height to not exceed stage boundary' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 9700 500 500 ]
      get expect, call [ get to-equal ] [ get clamped height ] 300
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'window dragging behavior' [
 function [
  get describe, call 'drag delta calculations' [
   function [
    get it, call 'should calculate new position from drag delta' [
     function [
      set start-x 100
      set start-y 200
      set delta-x 50
      set delta-y -30
      set new-x [ get start-x, add [ get delta-x ] ]
      set new-y [ get start-y, add [ get delta-y ] ]
      get expect, call [ get to-equal ] [ get new-x ] 150
      get expect, call [ get to-equal ] [ get new-y ] 170
     ]
    ]
    
    get it, call 'should clamp position after drag' [
     function [
      set start-x 9400
      set start-y 9500
      set delta-x 200
      set delta-y 200
      set unclamped-x [ get start-x, add [ get delta-x ] ]
      set unclamped-y [ get start-y, add [ get delta-y ] ]
      set clamped [ get bounds clamp-window-position, call [ get unclamped-x ] [ get unclamped-y ] 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 9600
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'window z-index management' [
 function [
  get describe, call 'z-index ordering' [
   function [
    get it, call 'should increment z-index for each window' [
     function [
      set z1 1
      set z2 [ get z1, add 1 ]
      set z3 [ get z2, add 1 ]
      get expect, call [ get to-equal ] [ get z1 ] 1
      get expect, call [ get to-equal ] [ get z2 ] 2
      get expect, call [ get to-equal ] [ get z3 ] 3
     ]
    ]
    
    get it, call 'should use z-index 2000 for maximized window' [
     function [
      set maximized-z 2000
      get expect, call [ get to-equal ] [ get maximized-z ] 2000
     ]
    ]
   ]
  ]
 ]
]
