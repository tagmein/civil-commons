# Menu: Script

set script [ get components menu, call Script ]

get script add, call 'Run' [
 function item event [
  set last [ get main last-interacted ]
  get last type, is script, true [
   get conductor dispatch, call 'script:run' [ object [ id [ get last id ] ] ]
  ]
 ]
]

get script