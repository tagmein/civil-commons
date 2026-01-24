get conductor register, call commons:about [
 function [
  set about-window [
   get components window, call 'About Civil Commons'
  ]
  get main stage place-window, call [
   get about-window
  ]
 ]
]
