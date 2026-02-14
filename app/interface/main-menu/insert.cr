# Menu: Insert

set insert [ get components menu, call Insert ]
get insert add, call 'Component'
get insert add, call 'AI content' [
 get conductor dispatch, will insert:generate-content
]

get insert
