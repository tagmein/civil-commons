get conductor register, call log:open [
 function [
  set log-window [
   get components window, call 'Log'
  ]
  get main stage place-window, call [
   get log-window
  ]
 ]
]
