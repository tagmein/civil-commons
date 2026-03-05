# Menu: Folder

set folder-menu [ get components menu, call Folder ]

get folder-menu add, call 'New' [
 get conductor dispatch, will '!folder:new'
]

get folder-menu add, call 'Rename...' [
 get conductor dispatch, will folder:rename
]

get folder-menu