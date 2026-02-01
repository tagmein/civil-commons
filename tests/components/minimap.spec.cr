# Load bounds module for testing
load ../../app/lib/bounds.cr, point, to bounds

# Minimap tests for 10000x10000 virtual stage with fixed scale
# Minimap is 200px square, scale = 200/10000 = 0.02

set MINIMAP_SIZE 200
set VIRTUAL_SIZE 10000
set SCALE 0.02

get describe, call 'minimap coordinate conversion' [
 function [
  get describe, call 'stage-to-minimap' [
   function [
    get it, call 'should convert stage origin to minimap origin' [
     function [
      set result [ get bounds stage-to-minimap, call 0 0 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should convert stage center to minimap center' [
     function [
      set result [ get bounds stage-to-minimap, call 5000 5000 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 100
     ]
    ]
    
    get it, call 'should convert stage corner to minimap corner' [
     function [
      set result [ get bounds stage-to-minimap, call 10000 10000 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 200
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should convert window at (1000, 2000)' [
     function [
      set result [ get bounds stage-to-minimap, call 1000 2000 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 20
      get expect, call [ get to-equal ] [ get result y ] 40
     ]
    ]
   ]
  ]
  
  get describe, call 'minimap-to-stage' [
   function [
    get it, call 'should convert minimap origin to stage origin' [
     function [
      set result [ get bounds minimap-to-stage, call 0 0 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
     ]
    ]
    
    get it, call 'should convert minimap center to stage center' [
     function [
      set result [ get bounds minimap-to-stage, call 100 100 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 5000
      get expect, call [ get to-equal ] [ get result y ] 5000
     ]
    ]
    
    get it, call 'should convert minimap click at (20, 40) to stage position' [
     function [
      set result [ get bounds minimap-to-stage, call 20 40 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result x ] 1000
      get expect, call [ get to-equal ] [ get result y ] 2000
     ]
    ]
   ]
  ]
  
  get describe, call 'scale-dimensions' [
   function [
    get it, call 'should scale 500x400 window to 10x8 on minimap' [
     function [
      set result [ get bounds scale-dimensions, call 500 400 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result width ] 10
      get expect, call [ get to-equal ] [ get result height ] 8
     ]
    ]
    
    get it, call 'should scale 1920x1080 viewport to 38.4x21.6 on minimap' [
     function [
      set result [ get bounds scale-dimensions, call 1920 1080 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result width ] 38.4
      get expect, call [ get to-equal ] [ get result height ] 21.6
     ]
    ]
    
    get it, call 'should scale full stage (10000x10000) to full minimap (200x200)' [
     function [
      set result [ get bounds scale-dimensions, call 10000 10000 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get result width ] 200
      get expect, call [ get to-equal ] [ get result height ] 200
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'minimap viewport positioning' [
 function [
  get describe, call 'viewport at origin' [
   function [
    get it, call 'should place viewport at minimap origin when stage viewport is at (0,0)' [
     function [
      set viewport-pos [ get bounds stage-to-minimap, call 0 0 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get viewport-pos x ] 0
      get expect, call [ get to-equal ] [ get viewport-pos y ] 0
     ]
    ]
   ]
  ]
  
  get describe, call 'viewport scrolled' [
   function [
    get it, call 'should place viewport correctly when stage viewport is at (1000, 500)' [
     function [
      set viewport-pos [ get bounds stage-to-minimap, call 1000 500 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get viewport-pos x ] 20
      get expect, call [ get to-equal ] [ get viewport-pos y ] 10
     ]
    ]
    
    get it, call 'should place viewport at bottom-right when scrolled to max' [
     function [
      # If viewport is 1920x1080, max scroll is (10000-1920, 10000-1080) = (8080, 8920)
      set viewport-pos [ get bounds stage-to-minimap, call 8080 8920 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get viewport-pos x ] 161.6
      get expect, call [ get to-equal ] [ get viewport-pos y ] 178.4
     ]
    ]
   ]
  ]
  
  get describe, call 'viewport clamping' [
   function [
    get it, call 'should clamp viewport to not exceed virtual stage' [
     function [
      # Try to place viewport past the edge
      set clamped [ get bounds clamp-viewport-position, call 9000 9000 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 8080
      get expect, call [ get to-equal ] [ get clamped y ] 8920
     ]
    ]
    
    get it, call 'should clamp negative viewport position to 0' [
     function [
      set clamped [ get bounds clamp-viewport-position, call -100 -50 1920 1080 ]
      get expect, call [ get to-equal ] [ get clamped x ] 0
      get expect, call [ get to-equal ] [ get clamped y ] 0
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'minimap window representation' [
 function [
  get describe, call 'window positioning on minimap' [
   function [
    get it, call 'should show window at (0,0) at minimap origin' [
     function [
      set window-pos [ get bounds stage-to-minimap, call 0 0 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-pos x ] 0
      get expect, call [ get to-equal ] [ get window-pos y ] 0
     ]
    ]
    
    get it, call 'should show window at (5000, 2500) at (100, 50) on minimap' [
     function [
      set window-pos [ get bounds stage-to-minimap, call 5000 2500 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-pos x ] 100
      get expect, call [ get to-equal ] [ get window-pos y ] 50
     ]
    ]
    
    get it, call 'should show window at max position (9500, 9600) correctly' [
     function [
      # Window at (9500, 9600) with size (500, 400) would be at edge
      set window-pos [ get bounds stage-to-minimap, call 9500 9600 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-pos x ] 190
      get expect, call [ get to-equal ] [ get window-pos y ] 192
     ]
    ]
   ]
  ]
  
  get describe, call 'window sizing on minimap' [
   function [
    get it, call 'should scale 500x400 window to 10x8 pixels on minimap' [
     function [
      set window-size [ get bounds scale-dimensions, call 500 400 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-size width ] 10
      get expect, call [ get to-equal ] [ get window-size height ] 8
     ]
    ]
    
    get it, call 'should scale minimum window (100x100) to 2x2 on minimap' [
     function [
      set window-size [ get bounds scale-dimensions, call 100 100 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-size width ] 2
      get expect, call [ get to-equal ] [ get window-size height ] 2
     ]
    ]
    
    get it, call 'should scale large window (2000x1500) to 40x30 on minimap' [
     function [
      set window-size [ get bounds scale-dimensions, call 2000 1500 [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get window-size width ] 40
      get expect, call [ get to-equal ] [ get window-size height ] 30
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'minimap window dragging' [
 function [
  get describe, call 'converting minimap drag deltas to stage deltas' [
   function [
    get it, call 'should convert 10px minimap drag to 500px stage movement' [
     function [
      # 10px minimap / 0.02 scale = 500px stage
      set stage-delta-x [ value 10, divide [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get stage-delta-x ] 500
     ]
    ]
    
    get it, call 'should convert 20px minimap drag to 1000px stage movement' [
     function [
      set stage-delta-x [ value 20, divide [ get SCALE ] ]
      get expect, call [ get to-equal ] [ get stage-delta-x ] 1000
     ]
    ]
   ]
  ]
  
  get describe, call 'window position after minimap drag' [
   function [
    get it, call 'should move window from (100,100) by 10px minimap drag to (600,100)' [
     function [
      set start-x 100
      set start-y 100
      set minimap-drag-x 10
      set minimap-drag-y 0
      set stage-delta-x [ get minimap-drag-x, divide [ get SCALE ] ]
      set stage-delta-y [ get minimap-drag-y, divide [ get SCALE ] ]
      set new-x [ get start-x, add [ get stage-delta-x ] ]
      set new-y [ get start-y, add [ get stage-delta-y ] ]
      get expect, call [ get to-equal ] [ get new-x ] 600
      get expect, call [ get to-equal ] [ get new-y ] 100
     ]
    ]
    
    get it, call 'should clamp window after drag to stay in bounds' [
     function [
      # Start at (9000, 9000) with 500x400 window
      # Drag 100px right on minimap = 5000px stage movement
      # New position would be (14000, 9000) but should clamp to (9500, 9000)
      set start-x 9000
      set start-y 9000
      set window-width 500
      set window-height 400
      set minimap-drag-x 100
      set stage-delta-x [ get minimap-drag-x, divide [ get SCALE ] ]
      set unclamped-x [ get start-x, add [ get stage-delta-x ] ]
      set clamped [ get bounds clamp-window-position, call [ get unclamped-x ] [ get start-y ] [ get window-width ] [ get window-height ] ]
      get expect, call [ get to-equal ] [ get clamped x ] 9500
      get expect, call [ get to-equal ] [ get clamped y ] 9000
     ]
    ]
   ]
  ]
 ]
]

get describe, call 'minimap scale calculation' [
 function [
  get it, call 'should calculate scale of 0.02 for 200px minimap' [
   function [
    set scale [ get bounds calculate-minimap-scale, call 200 ]
    get expect, call [ get to-equal ] [ get scale ] 0.02
   ]
  ]
  
  get it, call 'should calculate scale of 0.0206 for 206px minimap' [
   function [
    set scale [ get bounds calculate-minimap-scale, call 206 ]
    get expect, call [ get to-equal ] [ get scale ] 0.0206
   ]
  ]
  
  get it, call 'should calculate scale of 0.01 for 100px minimap' [
   function [
    set scale [ get bounds calculate-minimap-scale, call 100 ]
    get expect, call [ get to-equal ] [ get scale ] 0.01
   ]
  ]
 ]
]
