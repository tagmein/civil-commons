# Menu: Document

set document [ get components menu, call Document ]

get document add, call 'New' [
 get conductor dispatch, will '!document:new'
]

get document add, call 'Rename' [
 get conductor dispatch, will document:rename
]

get document add, call 'Recent' [
 get conductor dispatch, will document:recent
]

get document
