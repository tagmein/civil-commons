# Load bounds module and store the exported object
load ../../app/lib/bounds.cr, point, to bounds

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
      # Window at x=9800 with width 500 would end at 10300, should clamp to 9500
      set result [ get bounds clamp-window-position, call 9800 200 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 9500
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should clamp y when window would extend past stage' [
     function [
      # Window at y=9800 with height 400 would end at 10200, should clamp to 9600
      set result [ get bounds clamp-window-position, call 100 9800 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 100
      get expect, call [ get to-equal ] [ get result y ] 9600
     ]
    ]
    
    get it, call 'should clamp both x and y when needed' [
     function [
      set result [ get bounds clamp-window-position, call -100 11000 500 400 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 9600
     ]
    ]
    
    get it, call 'should position at origin for window filling stage' [
     function [
      set result [ get bounds clamp-window-position, call 500 500 10000 10000 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
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
      # At x=9500, max width is 500
      set result [ get bounds clamp-window-size, call 9500 200 1000 400 ]
      get expect, call [ get to-equal ] [ get result width ] 500
     ]
    ]
    
    get it, call 'should clamp height to not exceed stage boundary' [
     function [
      # At y=9700, max height is 300
      set result [ get bounds clamp-window-size, call 100 9700 500 500 ]
      get expect, call [ get to-equal ] [ get result height ] 300
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
      # Viewport at x=9000 with width 1920 would end at 10920, should clamp to 8080
      set result [ get bounds clamp-viewport-position, call 9000 200 1920 1080 ]
      get expect, call [ get to-equal ] [ get result x ] 8080
      get expect, call [ get to-equal ] [ get result y ] 200
     ]
    ]
    
    get it, call 'should start at origin (0,0) by default' [
     function [
      set result [ get bounds clamp-viewport-position, call 0 0 1920 1080 ]
      get expect, call [ get to-equal ] [ get result x ] 0
      get expect, call [ get to-equal ] [ get result y ] 0
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
    
    get it, call 'should calculate correct scale for 206px minimap' [
     function [
      set result [ get bounds calculate-minimap-scale, call 206 ]
      get expect, call [ get to-equal ] [ get result ] 0.0206
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
    
    get it, call 'should convert end of stage' [
     function [
      set result [ get bounds stage-to-minimap, call 10000 10000 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 200
      get expect, call [ get to-equal ] [ get result y ] 200
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
    
    get it, call 'should convert end of minimap' [
     function [
      set result [ get bounds minimap-to-stage, call 200 200 0.02 ]
      get expect, call [ get to-equal ] [ get result x ] 10000
      get expect, call [ get to-equal ] [ get result y ] 10000
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
    
    get it, call 'should scale large window for minimap' [
     function [
      set result [ get bounds scale-dimensions, call 1000 800 0.02 ]
      get expect, call [ get to-equal ] [ get result width ] 20
      get expect, call [ get to-equal ] [ get result height ] 16
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
