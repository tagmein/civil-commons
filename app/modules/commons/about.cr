get conductor register, call commons:about [
 function [
  set session-service [ get main session-service ]
  set about-window [
   get components window, call 'About Civil Commons' 400 500
  ]
  set log-entry [ get conductor getLastLoggedEntry, call ]
  get log-entry, true [
   get log-entry id, true [
    set about-window logEntryId [ get log-entry id ]
   ]
  ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev id, true [
    set about-window logEntryId [ get replay-ev id ]
   ]
  ]
  set original-close [ get about-window close ]
  set about-window close [ function [
   get about-window logEntryId, true [
    get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
     get session-service mark-event-skipped-on-replay, call [ get about-window logEntryId ]
    ]
   ], false [
    get session-service get-preference, call 'skipClosedWindowsOnReplay', true [
     get session-service mark-last-event-with-action-skipped-on-replay, call 'commons:about'
    ]
   ]
   get original-close, call
  ] ]
  get about-window logEntryId, true [
   set about-window onMinimize [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] true ] ]
   set about-window onRestore [ function win [ get session-service set-event-minimized, call [ get win logEntryId ] false ] ]
  ]
  set content [
   global document createElement, call div
  ]
  set padding-container [
   global document createElement, call div
  ]
  set padding-container style padding '20px'
  set title [
   global document createElement, call h1
  ]
  set title textContent 'Civil Commons'
  set title style fontSize '24px'
  set title style margin '0 0 10px 0'
  get padding-container appendChild, call [ get title ]
  set description [
   global document createElement, call p
  ]
  set description [
   global document createElement, call p
  ]
  set description-text [
   global document createElement, call span
  ]
  set description-text textContent 'A public gathering space for internet-enabled minds. '
  get description appendChild, call [ get description-text ]
  set repo-link [
   global document createElement, call a
  ]
  set repo-link href 'https://github.com/tagmein/civil-commons'
  set repo-link target '_blank'
  set repo-link textContent 'View on GitHub'
  set repo-link style color '#4a9eff'
  set repo-link style textDecoration 'none'
  get repo-link addEventListener, tell mouseenter [
   function [
    set repo-link style textDecoration 'underline'
   ]
  ]
  get repo-link addEventListener, tell mouseleave [
   function [
    set repo-link style textDecoration 'none'
   ]
  ]
  get description appendChild, call [ get repo-link ]
  set description style margin '0 0 20px 0'
  set description style lineHeight '1.6'
  get padding-container appendChild, call [ get description ]
  set version-label [
   global document createElement, call p
  ]
  set version-label textContent 'Version 0.0.0'
  set version-label style margin '0 0 20px 0'
  set version-label style color '#808080'
  get padding-container appendChild, call [ get version-label ]
  set tech-title [
   global document createElement, call h2
  ]
  set tech-title textContent 'Built with'
  set tech-title style fontSize '18px'
  set tech-title style margin '0 0 10px 0'
  get padding-container appendChild, call [ get tech-title ]
  set tech-list [
   global document createElement, call ul
  ]
  set tech-list style margin '0 0 20px 0'
  set tech-list style paddingLeft '20px'
  set tech-list style lineHeight '1.8'
  set crown-li [
   global document createElement, call li
  ]
  set crown-link [
   global document createElement, call a
  ]
  set crown-link href 'https://github.com/tagmein/crown'
  set crown-link target '_blank'
  set crown-link textContent 'Crown metaprogramming language'
  set crown-link style color '#4a9eff'
  set crown-link style textDecoration 'none'
  get crown-link addEventListener, tell mouseenter [
   function [
    set crown-link style textDecoration 'underline'
   ]
  ]
  get crown-link addEventListener, tell mouseleave [
   function [
    set crown-link style textDecoration 'none'
   ]
  ]
  get crown-li appendChild, call [ get crown-link ]
  get tech-list appendChild, call [ get crown-li ]
  list 'Node.js' 'HTML5 Canvas', each [
   function item [
    set li [
     global document createElement, call li
    ]
    set li textContent [ get item ]
    get tech-list appendChild, call [ get li ]
   ]
  ]
  get padding-container appendChild, call [ get tech-list ]
  set license-title [
   global document createElement, call h2
  ]
  set license-title textContent 'License'
  set license-title style fontSize '18px'
  set license-title style margin '0 0 10px 0'
  get padding-container appendChild, call [ get license-title ]
  set license-text [
   global document createElement, call p
  ]
  set license-text textContent 'MIT License + Public Domain'
  set license-text style margin '0'
  set license-text style color '#808080'
  set license-text style fontSize '14px'
  get padding-container appendChild, call [ get license-text ]
  get content appendChild, call [ get padding-container ]
  get about-window fill, call [ get content ]
  get main stage place-window, call [
   get about-window
  ] [ get main status ]
  set replay-ev [ get conductor getReplayEvent, call ]
  get replay-ev, true [
   get replay-ev minimized, true [
    get about-window minimize-window, tell
   ]
  ]
 ]
]
