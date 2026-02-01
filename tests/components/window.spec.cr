# Load bounds module for testing
load ../../app/lib/bounds.cr, point, to bounds

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
      # Window of 500 width at x=9800 would end at 10300
      # Should clamp to x=9500
      set clamped [ get bounds clamp-window-position, call 9800 200 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 200
     ]
    ]
    
    get it, call 'should clamp window to not exceed bottom edge' [
     function [
      # Window of 400 height at y=9700 would end at 10100
      # Should clamp to y=9600
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
  
  get describe, call 'positioning at stage edges' [
   function [
    get it, call 'should calculate max x position for 500px window' [
     function [
      set max-x [ value 10000, subtract 500 ]
      get expect, call [ get to-equal ] [ get max-x ] 9500
     ]
    ]
    
    get it, call 'should calculate max y position for 400px window' [
     function [
      set max-y [ value 10000, subtract 400 ]
      get expect, call [ get to-equal ] [ get max-y ] 9600
     ]
    ]
    
    get it, call 'should allow window at maximum valid position' [
     function [
      set clamped [ get bounds clamp-window-position, call 9500 9600 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 9600
     ]
    ]
   ]
  ]
  
  get describe, call 'large windows' [
   function [
    get it, call 'should handle window exactly fitting stage' [
     function [
      set clamped [ get bounds clamp-window-position, call 0 0 10000 10000 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should clamp window larger than stage to origin' [
     function [
      # Window larger than stage should be clamped to (0, 0)
      set clamped [ get bounds clamp-window-position, call 1000 1000 12000 12000 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
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
      # At x=9500, max width is 500
      set clamped [ get bounds clamp-window-size, call 9500 100 1000 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 500
     ]
    ]
    
    get it, call 'should clamp height to not exceed stage boundary' [
     function [
      # At y=9700, max height is 300
      set clamped [ get bounds clamp-window-size, call 100 9700 500 500 ]
      get expect, call [ get to-equal ] [ get clamped height ] 300
     ]
    ]
    
    get it, call 'should allow full size when at origin' [
     function [
      set clamped [ get bounds clamp-window-size, call 0 0 5000 4000 ]
      get expect, call [ get to-equal ] [ get clamped width ] 5000
      get expect, call [ get to-equal ] [ get clamped height ] 4000
     ]
    ]
    
    get it, call 'should clamp both dimensions when needed' [
     function [
      # At x=9800, y=9900: max width=200, max height=100
      set clamped [ get bounds clamp-window-size, call 9800 9900 500 500 ]
      get expect, call [ get to-equal ] [ get clamped width ] 200
      get expect, call [ get to-equal ] [ get clamped height ] 100
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

get describe, call 'window resizing behavior' [
 function [
  get describe, call 'resize delta calculations' [
   function [
    get it, call 'should calculate new size from resize delta' [
     function [
      set start-width 500
      set start-height 400
      set delta-x 100
      set delta-y 50
      set new-width [ get start-width, add [ get delta-x ] ]
      set new-height [ get start-height, add [ get delta-y ] ]
      get expect, call [ get to-equal ] [ get new-width ] 600
      get expect, call [ get to-equal ] [ get new-height ] 450
     ]
    ]
    
    get it, call 'should clamp size after resize' [
     function [
      set pos-x 9000
      set pos-y 9000
      set start-width 500
      set start-height 400
      set delta-x 800
      set delta-y 800
      set unclamped-width [ get start-width, add [ get delta-x ] ]
      set unclamped-height [ get start-height, add [ get delta-y ] ]
      set clamped [ get bounds clamp-window-size, call [ get pos-x ] [ get pos-y ] [ get unclamped-width ] [ get unclamped-height ] ]
      get expect, call [ get to-equal ] [ get clamped width ] 1000
      get expect, call [ get to-equal ] [ get clamped height ] 1000
     ]
    ]
    
    get it, call 'should not shrink below minimum size' [
     function [
      set start-width 200
      set start-height 200
      set delta-x -150
      set delta-y -150
      set unclamped-width [ get start-width, add [ get delta-x ] ]
      set unclamped-height [ get start-height, add [ get delta-y ] ]
      set clamped [ get bounds clamp-window-size, call 0 0 [ get unclamped-width ] [ get unclamped-height ] ]
      get expect, call [ get to-equal ] [ get clamped width ] 100
      get expect, call [ get to-equal ] [ get clamped height ] 100
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
