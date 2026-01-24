set registry [ object ]

set dispatch [
 function action arg [
  get registry [ get action ]
  false [ log CONDUCTOR WARNING NO MATCH FOR [ get action ] ]
  true [ 
   log CONDUCTOR DISPATCH [ get action ]
   tell [ get arg ]
  ]
 ]
]

set register [
 function name callback [
  set [ get registry ] [ get name ] [ get callback ]
  log CONDUCTOR REGISTERED [ get name ]
 ]
]

object [
 dispatch
 register
]
