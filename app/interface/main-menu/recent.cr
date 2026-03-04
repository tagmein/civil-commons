# Menu: Recent

set recent [ get components menu, call Recent ]

get recent add, call 'All' [
 get conductor dispatch, will recent:all
]

get recent add, call 'Documents' [
 get conductor dispatch, will recent:documents
]

get recent add, call 'Sessions' [
 get conductor dispatch, will recent:sessions
]

get recent add, call 'Values' [
 get conductor dispatch, will recent:values
]

get recent add, call 'Scripts' [
 get conductor dispatch, will recent:scripts
]

get recent
