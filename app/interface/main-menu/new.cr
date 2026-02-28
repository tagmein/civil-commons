# Menu: New

set new-menu [ get components menu, call New ]

get new-menu add, call 'Document' [
 get conductor dispatch, will '!document:new'
]

get new-menu add, call 'Session' [
 function item event [
  get main session-service create-session, call
 ]
]

get new-menu add, call 'Value' [
 get conductor dispatch, will '!value:new'
]

get new-menu
