# Load bounds module and store the exported object
load ./bounds.cr, point, to bounds

get describe, call 'bounds utilities' [
 function [
  get describe, call 'clamp' [
   function [
    get it, call 'should return value when within range' [
     function [
      set result [ get bounds clamp, call 50 0 100 ]
      get expect, call [ get to-equal ] [ get result ] 50
     ]
    ]
    
    get it, call 'should clamp to min when value is below range' [
     function [
      set result [ get bounds clamp, call -10 0 100 ]
      get expect, call [ get to-equal ] [ get result ] 0
     ]
    ]
    
    get it, call 'should clamp to max when value is above range' [
     function [
      set result [ get bounds clamp, call 150 0 100 ]
      get expect, call [ get to-equal ] [ get result ] 100
     ]
    ]
    
    get it, call 'should handle edge case at min boundary' [
     function [
      set result [ get bounds clamp, call 0 0 100 ]
      get expect, call [ get to-equal ] [ get result ] 0
     ]
    ]
    
    get it, call 'should handle edge case at max boundary' [
     function [
      set result [ get bounds clamp, call 100 0 100 ]
      get expect, call [ get to-equal ] [ get result ] 100
     ]
    ]
   ]
  ]
  
  get describe, call 'clamp-window-position' [
   function [
    get it, call 'should keep position when fully within stage' [
     function [
      set result [ get bounds clamp-window-position, call 100 200 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should clamp x to 0 when negative' [
     function [
      set result [ get bounds clamp-window-position, call -100 200 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should clamp y to 0 when negative' [
     function [
      set result [ get bounds clamp-window-position, call 100 -200 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should clamp x when window would extend past stage' [
     function [
      set result [ get bounds clamp-window-position, call 9800 200 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 9500
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should clamp y when window would extend past stage' [
     function [
      set result [ get bounds clamp-window-position, call 100 9800 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 9600
     ]
    ]
   ]
  ]
  
  get describe, call 'clamp-window-size' [
   function [
    get it, call 'should keep size when within bounds' [
     function [
      set result [ get bounds clamp-window-size, call 100 200 500 400 ]
      get expect, call [ get to-equal ] [ get result width ] 500
      get expect, call [ get to-equal ] [ get result height ] 400
     ]
    ]
    
    get it, call 'should enforce minimum width of 100' [
     function [
      set result [ get bounds clamp-window-size, call 100 200 50 400 ]
      get expect, call [ get to-equal ] [ get result width ] 100
     ]
    ]
    
    get it, call 'should enforce minimum height of 100' [
     function [
      set result [ get bounds clamp-window-size, call 100 200 500 50 ]
      get expect, call [ get to-equal ] [ get result height ] 100
     ]
    ]
    
    get it, call 'should clamp width to not exceed stage boundary' [
     function [
      set result [ get bounds clamp-window-size, call 9500 200 1000 400 ]
      get expect, call [ get to-equal ] [ get result width ] 500
     ]
    ]
   ]
  ]
  
  get describe, call 'clamp-viewport-position' [
   function [
    get it, call 'should keep position when within stage' [
     function [
      set result [ get bounds clamp-viewport-position, call 100 200 1920 1080 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should clamp to 0 when negative' [
     function [
      set result [ get bounds clamp-viewport-position, call -100 -200 1920 1080 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should clamp when viewport would extend past stage' [
     function [
      set result [ get bounds clamp-viewport-position, call 9000 200 1920 1080 ]
      get expect, call [ get to-equal ] [ get result x ] 8080
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
   ]
  ]
  
  get describe, call 'calculate-minimap-scale' [
   function [
    get it, call 'should calculate correct scale for 200px minimap' [
     function [
      set result [ get bounds calculate-minimap-scale, call 200 ]
      get expect, call [ get to-equal ] [ get result ] 0.02
     ]
    ]
    
    get it, call 'should calculate correct scale for 100px minimap' [
     function [
      set result [ get bounds calculate-minimap-scale, call 100 ]
      get expect, call [ get to-equal ] [ get result ] 0.01
     ]
    ]
   ]
  ]
  
  get describe, call 'stage-to-minimap' [
   function [
    get it, call 'should convert origin correctly' [
     function [
      set result [ get bounds stage-to-minimap, call 0 0 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should convert mid-stage position' [
     function [
      set result [ get bounds stage-to-minimap, call 5000 5000 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 100
     ]
    ]
   ]
  ]
  
  get describe, call 'minimap-to-stage' [
   function [
    get it, call 'should convert origin correctly' [
     function [
      set result [ get bounds minimap-to-stage, call 0 0 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should convert mid-minimap position' [
     function [
      set result [ get bounds minimap-to-stage, call 100 100 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 5000
      get expect, call [ get to-equal ] [ get result y ] 5000
     ]
    ]
   ]
  ]
  
  get describe, call 'scale-dimensions' [
   function [
    get it, call 'should scale dimensions correctly' [
     function [
      set result [ get bounds scale-dimensions, call 500 400 0.02 ]
      get expect, call [ get to-equal ] [ get result width ] 10
      get expect, call [ get to-equal ] [ get result height ] 8
     ]
    ]
   ]
  ]
  
  get describe, call 'VIRTUAL_STAGE_SIZE constant' [
   function [
    get it, call 'should be 10000' [
     function [
      get expect, call [ get to-equal ] [ get bounds VIRTUAL_STAGE_SIZE ] 10000
     ]
    ]
   ]
  ]
 ]
]

# Regression tests for clamping bugs
# These test the Crown scoping issue where `set` inside conditionals creates local variables

get describe, call 'Bug fixes: Crown scoping in clamping functions' [
 function [
  get describe, call 'window position clamping (Bug #1: drag from real stage)' [
   function [
    get it, call 'should clamp x when dragging window past right edge' [
     function [
      # Window at x=9800 with width 500 should clamp to x=9500
      set result [ get bounds clamp-window-position, call 9800 100 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 9500
     ]
    ]
    
    get it, call 'should clamp y when dragging window past bottom edge' [
     function [
      # Window at y=9700 with height 400 should clamp to y=9600
      set result [ get bounds clamp-window-position, call 100 9700 500 400 ]
      get expect, call [ get to-equal ] [ get result y ] 9600
     ]
    ]
    
    get it, call 'should clamp negative x to 0' [
     function [
      set result [ get bounds clamp-window-position, call -500 100 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 0
     ]
    ]
    
    get it, call 'should clamp negative y to 0' [
     function [
      set result [ get bounds clamp-window-position, call 100 -500 500 400 ]
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should handle dragging window to all corners' [
     function [
      # Top-left
      set tl [ get bounds clamp-window-position, call -100 -100 500 400 ]
      get expect, call [ get to-equal ] [ get tl x ] 0
      get expect, call [ get to-equal ] [ get tl y ] 0
      
      # Top-right
      set tr [ get bounds clamp-window-position, call 12000 -100 500 400 ]
      get expect, call [ get to-equal ] [ get tr x ] 9500
      get expect, call [ get to-equal ] [ get tr y ] 0
      
      # Bottom-left
      set bl [ get bounds clamp-window-position, call -100 12000 500 400 ]
      get expect, call [ get to-equal ] [ get bl x ] 0
      get expect, call [ get to-equal ] [ get bl y ] 9600
      
      # Bottom-right
      set br [ get bounds clamp-window-position, call 12000 12000 500 400 ]
      get expect, call [ get to-equal ] [ get br x ] 9500
      get expect, call [ get to-equal ] [ get br y ] 9600
     ]
    ]
   ]
  ]
  
  get describe, call 'minimap window drag clamping (Bug #2)' [
   function [
    get it, call 'should convert minimap drag to stage coordinates and clamp' [
     function [
      # 10px on minimap = 500px on stage (scale 0.02)
      # Window starting at (9000, 9000), drag 100px right = 5000px
      # New unclamped position would be (14000, 9000)
      # Should clamp to (9500, 9000) for 500x400 window
      set scale 0.02
      set start-x 9000
      set start-y 9000
      set minimap-delta-x 100
      set stage-delta-x [ get minimap-delta-x, divide [ get scale ] ]
      set unclamped-x [ get start-x, add [ get stage-delta-x ] ]
      set clamped [ get bounds clamp-window-position, call [ get unclamped-x ] [ get start-y ] 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 9000
     ]
    ]
    
    get it, call 'should clamp window dragged past left edge from minimap' [
     function [
      # Start at (500, 500), drag -50px on minimap = -2500px on stage
      # Unclamped would be (-2000, 500), should clamp to (0, 500)
      set scale 0.02
      set start-x 500
      set minimap-delta-x -50
      set stage-delta-x [ get minimap-delta-x, divide [ get scale ] ]
      set unclamped-x [ get start-x, add [ get stage-delta-x ] ]
      set clamped [ get bounds clamp-window-position, call [ get unclamped-x ] 500 500 400 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
     ]
    ]
   ]
  ]
  
  get describe, call 'viewport position clamping (Bug #3)' [
   function [
    get it, call 'should clamp viewport dragged past right edge' [
     function [
      # Viewport 1920x1080, max x = 10000 - 1920 = 8080
      set clamped [ get bounds clamp-viewport-position, call 9000 500 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 8080
      get expect, call [ get to-equal ] [ get clamped y ] 500
     ]
    ]
    
    get it, call 'should clamp viewport dragged past bottom edge' [
     function [
      # Viewport 1920x1080, max y = 10000 - 1080 = 8920
      set clamped [ get bounds clamp-viewport-position, call 500 9500 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 500
      get expect, call [ get to-equal ] [ get clamped y ] 8920
     ]
    ]
    
    get it, call 'should clamp viewport dragged past left/top edge' [
     function [
      set clamped [ get bounds clamp-viewport-position, call -500 -300 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
    
    get it, call 'should clamp viewport to all corners' [
     function [
      # Top-left
      set tl [ get bounds clamp-viewport-position, call -500 -500 1920 1080 ]
      get expect, call [ get to-equal ] [ get tl x ] 0
      get expect, call [ get to-equal ] [ get tl y ] 0
      
      # Top-right (max-x = 8080)
      set tr [ get bounds clamp-viewport-position, call 10000 -500 1920 1080 ]
      get expect, call [ get to-equal ] [ get tr x ] 8080
      get expect, call [ get to-equal ] [ get tr y ] 0
      
      # Bottom-left (max-y = 8920)
      set bl [ get bounds clamp-viewport-position, call -500 10000 1920 1080 ]
      get expect, call [ get to-equal ] [ get bl x ] 0
      get expect, call [ get to-equal ] [ get bl y ] 8920
      
      # Bottom-right
      set br [ get bounds clamp-viewport-position, call 10000 10000 1920 1080 ]
      get expect, call [ get to-equal ] [ get br x ] 8080
      get expect, call [ get to-equal ] [ get br y ] 8920
     ]
    ]
   ]
  ]
  
  get describe, call 'window resize clamping (Bug #4)' [
   function [
    get it, call 'should clamp width to not exceed stage boundary' [
     function [
      # Window at x=9500, max width = 10000 - 9500 = 500
      set clamped [ get bounds clamp-window-size, call 9500 100 1000 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 500
     ]
    ]
    
    get it, call 'should clamp height to not exceed stage boundary' [
     function [
      # Window at y=9700, max height = 10000 - 9700 = 300
      set clamped [ get bounds clamp-window-size, call 100 9700 500 800 ]
      get expect, call [ get to-equal ] [ get clamped height ] 300
     ]
    ]
    
    get it, call 'should enforce minimum width when resizing smaller' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 100 50 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 100
     ]
    ]
    
    get it, call 'should enforce minimum height when resizing smaller' [
     function [
      set clamped [ get bounds clamp-window-size, call 100 100 500 30 ]
      get expect, call [ get to-equal ] [ get clamped height ] 100
     ]
    ]
    
    get it, call 'should clamp both width and height when at corner' [
     function [
      # Window at (9800, 9850): max width = 200, max height = 150
      set clamped [ get bounds clamp-window-size, call 9800 9850 500 400 ]
      get expect, call [ get to-equal ] [ get clamped width ] 200
      get expect, call [ get to-equal ] [ get clamped height ] 150
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'Bug fix: window restore position (Bug #5)' [
 function [
  get describe, call 'window position preservation' [
   function [
    get it, call 'should preserve position when minimizing and restoring' [
     function [
      # Window position at (500, 600) should be preserved
      set val-x 500
      set val-y 600
      get expect, call [ get to-equal ] [ get val-x ] 500
      get expect, call [ get to-equal ] [ get val-y ] 600
     ]
    ]
    
    get it, call 'should calculate correct visual position after restore' [
     function [
      # Window position (500, 600), viewport at (0, 0)
      # Visual position should be (500, 600)
      set window-x 500
      set window-y 600
      set viewport-x 0
      set viewport-y 0
      set visual-x [ get window-x, subtract [ get viewport-x ] ]
      set visual-y [ get window-y, subtract [ get viewport-y ] ]
      get expect, call [ get to-equal ] [ get visual-x ] 500
      get expect, call [ get to-equal ] [ get visual-y ] 600
     ]
    ]
    
    get it, call 'should handle restore when viewport has moved' [
     function [
      # Window position (500, 600), viewport has moved to (200, 100)
      # Visual position should be (300, 500)
      set window-x 500
      set window-y 600
      set viewport-x 200
      set viewport-y 100
      set visual-x [ get window-x, subtract [ get viewport-x ] ]
      set visual-y [ get window-y, subtract [ get viewport-y ] ]
      get expect, call [ get to-equal ] [ get visual-x ] 300
      get expect, call [ get to-equal ] [ get visual-y ] 500
     ]
    ]
    
    get it, call 'should show window offscreen if viewport scrolled past it' [
     function [
      # Window position (100, 100), viewport at (500, 500)
      # Visual position should be (-400, -400) - window appears offscreen
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
