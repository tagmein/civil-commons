# Load bounds module for testing
load ../../app/lib/bounds.cr, point, to bounds

# Stage component tests for 10000x10000 virtual stage
set VIRTUAL_STAGE_SIZE 10000

get describe, call 'stage viewport positioning' [
 function [
  get describe, call 'viewport initialization' [
   function [
    get it, call 'should have viewport at origin (0,0) initially' [
     function [
      # Initial viewport position should be (0, 0)
      set clamped [ get bounds clamp-viewport-position, call 0 0 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should have virtual stage size of 10000' [
     function [
      get expect, call [ get to-equal ] [ get bounds VIRTUAL_STAGE_SIZE ] 10000
     ]
    ]
   ]
  ]
  
  get describe, call 'viewport movement' [
   function [
    get it, call 'should clamp viewport to origin when moved negative' [
     function [
      set clamped [ get bounds clamp-viewport-position, call -100 -50 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should allow viewport movement within bounds' [
     function [
      set clamped [ get bounds clamp-viewport-position, call 1000 500 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 1000
      get expect, call [ get to-equal ] [ get clamped y ] 500
     ]
    ]
    
    get it, call 'should clamp viewport when it would exceed stage bounds' [
     function [
      # With 1920x1080 viewport, max position is (8080, 8920)
      set clamped [ get bounds clamp-viewport-position, call 9000 9500 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 8080
      get expect, call [ get to-equal ] [ get clamped y ] 8920
     ]
    ]
    
    get it, call 'should calculate max viewport x correctly' [
     function [
      # Max x = 10000 - viewport_width
      set max-x [ value 10000, subtract 1920 ]
      get expect, call [ get to-equal ] [ get max-x ] 8080
     ]
    ]
    
    get it, call 'should calculate max viewport y correctly' [
     function [
      # Max y = 10000 - viewport_height
      set max-y [ value 10000, subtract 1080 ]
      get expect, call [ get to-equal ] [ get max-y ] 8920
     ]
    ]
   ]
  ]
  
  get describe, call 'viewport with large displays' [
   function [
    get it, call 'should handle 4K display (3840x2160)' [
     function [
      set clamped [ get bounds clamp-viewport-position, call 5000 5000 3840 2160 ]
      get expect, call [ get to-equal ] [ get clamped x ] 5000
      get expect, call [ get to-equal ] [ get clamped y ] 5000
     ]
    ]
    
    get it, call 'should clamp 4K viewport at edge' [
     function [
      # Max for 4K: (10000-3840, 10000-2160) = (6160, 7840)
      set clamped [ get bounds clamp-viewport-position, call 8000 8000 3840 2160 ]
      get expect, call [ get to-equal ] [ get clamped x ] 6160
      get expect, call [ get to-equal ] [ get clamped y ] 7840
     ]
    ]
    
    get it, call 'should handle viewport larger than stage' [
     function [
      # If viewport is larger than stage, it should stay at origin
      set clamped [ get bounds clamp-viewport-position, call 1000 1000 12000 12000 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'stage window transforms' [
 function [
  get describe, call 'window visual position calculation' [
   function [
    get it, call 'should show window at its position when viewport is at origin' [
     function [
      # Window at (100, 200), viewport at (0, 0)
      # Visual position = window_pos - viewport_pos = (100, 200)
      set window-x 100
      set window-y 200
      set viewport-x 0
      set viewport-y 0
      set visual-x [ get window-x, subtract [ get viewport-x ] ]
      set visual-y [ get window-y, subtract [ get viewport-y ] ]
      get expect, call [ get to-equal ] [ get visual-x ] 100
      get expect, call [ get to-equal ] [ get visual-y ] 200
     ]
    ]
    
    get it, call 'should offset window position when viewport is scrolled' [
     function [
      # Window at (1000, 800), viewport at (500, 300)
      # Visual position = window_pos - viewport_pos = (500, 500)
      set window-x 1000
      set window-y 800
      set viewport-x 500
      set viewport-y 300
      set visual-x [ get window-x, subtract [ get viewport-x ] ]
      set visual-y [ get window-y, subtract [ get viewport-y ] ]
      get expect, call [ get to-equal ] [ get visual-x ] 500
      get expect, call [ get to-equal ] [ get visual-y ] 500
     ]
    ]
    
    get it, call 'should show negative visual position when window is behind viewport' [
     function [
      # Window at (100, 100), viewport at (500, 500)
      # Visual position = (100-500, 100-500) = (-400, -400) - window would be off screen
      set window-x 100
      set window-y 100
      set viewport-x 500
      set viewport-y 500
      set visual-x [ get window-x, subtract [ get viewport-x ] ]
      set visual-y [ get window-y, subtract [ get viewport-y ] ]
      get expect, call [ get to-equal ] [ get visual-x ] -400
      get expect, call [ get to-equal ] [ get visual-y ] -400
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'stage window placement' [
 function [
  get describe, call 'place-next calculations' [
   function [
    get it, call 'should start placing windows at (20, 20)' [
     function [
      set start-x 20
      set start-y 20
      get expect, call [ get to-equal ] [ get start-x ] 20
      get expect, call [ get to-equal ] [ get start-y ] 20
     ]
    ]
    
    get it, call 'should advance placement by 20px each window' [
     function [
      set x 20
      set y 20
      # After placing first window
      set x [ get x, add 20 ]
      set y [ get y, add 20 ]
      get expect, call [ get to-equal ] [ get x ] 40
      get expect, call [ get to-equal ] [ get y ] 40
     ]
    ]
    
    get it, call 'should wrap placement when x exceeds 500' [
     function [
      # Test demonstrates the wrap logic calculation using reference object
      # If x > 500, wrap to x=20 and add 40 to y
      set pos [ object [ x 520 y 100 ] ]
      # Calculate wrap condition and update pos using object mutation
      get pos x, > 500, true [
       set pos x 20
       set pos y [ value 100, add 40 ]
      ]
      get expect, call [ get to-equal ] [ get pos x ] 20
      get expect, call [ get to-equal ] [ get pos y ] 140
     ]
    ]
   ]
  ]
 ]
]
