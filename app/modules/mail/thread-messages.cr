# Thread messages list

set messages-el [ global document createElement, call div ]
get messages-el classList add, call mail-thread-messages
get thread messages, each [
 function msg [
  set msg-el [ global document createElement, call div ]
  get msg-el classList add, call mail-message
  set meta [ global document createElement, call div ]
  get meta classList add, call mail-message-meta
  set time-str [ global Date, new [ get msg timestamp ], at toLocaleString, call ]
  set meta textContent [ template '%0 -> %1 (%2)' [
   get msg from, default ''
  ] [
   get msg to, default [ list ], at join, call ', '
  ] [ get time-str ] ]
  get msg-el appendChild, call [ get meta ]
  set body-el [ global document createElement, call div ]
  get body-el classList add, call mail-message-body
  set body-el textContent [ get msg body, default '' ]
  get msg-el appendChild, call [ get body-el ]
  get messages-el appendChild, call [ get msg-el ]
 ]
]
get messages-el
