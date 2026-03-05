# Menu: New

set new-menu [ get components menu, call New ]

get new-menu add, call 'Dictionary' [
 get conductor dispatch, will '!dictionary:new'
]

get new-menu add, call 'Document' [
 get conductor dispatch, will '!document:new'
]

get new-menu add, call 'Folder' [
 get conductor dispatch, will '!folder:new'
]

get new-menu add, call 'Script' [
 get conductor dispatch, will '!script:new'
]

get new-menu add, call 'Session' [
 function item event [
  get main session-service create-session, call
 ]
]

get new-menu add, call 'Value' [
 get conductor dispatch, will '!value:new'
]

get new-menu add, call 'AI Content' [
 get conductor dispatch, will insert:generate-content
]

get new-menu
