# Menu: Log

set log [ get components menu, call Log ]
get log add, call Open [
 get conductor dispatch, will log:open
]

get log
