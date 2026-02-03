# DOM Harness for Node.js testing
# Provides a fake document/window environment for component tests

# Create a minimal classList implementation
set create-class-list [ function [
 set classes [ list ]
 object [
  add [ function name [
   get classes indexOf, call [ get name ]
   is -1, true [
    get classes push, call [ get name ]
   ]
  ] ]
  remove [ function name [
   set idx [ get classes indexOf, call [ get name ] ]
   get idx, >= 0, true [
    get classes splice, call [ get idx ] 1
   ]
  ] ]
  contains [ function name [
   get classes indexOf, call [ get name ]
   is -1, not
  ] ]
  toggle [ function name [
   get classes indexOf, call [ get name ]
   is -1, true [
    get classes push, call [ get name ]
   ], false [
    set idx [ get classes indexOf, call [ get name ] ]
    get classes splice, call [ get idx ] 1
   ]
  ] ]
  _classes [ get classes ]
 ]
] ]

# Create a minimal element implementation
set create-element [ function tag-name [
 set children [ list ]
 set event-listeners [ object ]
 set element [
  object [
   tagName [ get tag-name ]
   classList [ get create-class-list, call ]
   children [ get children ]
   textContent ''
   innerHTML ''
   style [ object ]
   appendChild [ function child [
    get children push, call [ get child ]
    set child parentNode [ get element ]
    get child
   ] ]
   removeChild [ function child [
    set idx [ get children indexOf, call [ get child ] ]
    get idx, >= 0, true [
     get children splice, call [ get idx ] 1
     set child parentNode undefined
    ]
    get child
   ] ]
   addEventListener [ function event-type handler [
    get event-listeners [ get event-type ], false [
     set event-listeners [ get event-type ] [ list ]
    ]
    get event-listeners [ get event-type ] push, call [ get handler ]
   ] ]
   removeEventListener [ function event-type handler [
    get event-listeners [ get event-type ], true [
     set idx [ get event-listeners [ get event-type ] indexOf, call [ get handler ] ]
     get idx, >= 0, true [
      get event-listeners [ get event-type ] splice, call [ get idx ] 1
     ]
    ]
   ] ]
   dispatchEvent [ function event [
    set event-type [ get event type ]
    get event-listeners [ get event-type ], true [
     get event-listeners [ get event-type ], each [
      function handler [
       get handler, call [ get event ]
      ]
     ]
    ]
   ] ]
   click [ function [
    get element dispatchEvent, call [ object [ type click ] ]
   ] ]
   focus [ function [ ] ]
   select [ function [ ] ]
   querySelectorAll [ function selector [
    # Simple implementation - returns empty array
    list
   ] ]
   querySelector [ function selector [
    value null
   ] ]
  ]
 ]
 get element
] ]

# Create a fake document object
set create-document [ function [
 set body [ get create-element, call 'body' ]
 object [
  body [ get body ]
  createElement [ function tag-name [
   get create-element, call [ get tag-name ]
  ] ]
  querySelectorAll [ function selector [
   list
  ] ]
  querySelector [ function selector [
   value null
  ] ]
 ]
] ]

# Create a fake window object
set create-window [ function [
 set document [ get create-document, call ]
 object [
  document [ get document ]
  setTimeout [ function fn delay [
   get fn, call
  ] ]
  clearTimeout [ function id [ ] ]
  setInterval [ function fn delay [
   0
  ] ]
  clearInterval [ function id [ ] ]
 ]
] ]

# Export the harness
object [
 create-element [ get create-element ]
 create-class-list [ get create-class-list ]
 create-document [ get create-document ]
 create-window [ get create-window ]
]
