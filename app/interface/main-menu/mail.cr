# Menu: Mail

set mail [ get components menu, call Mail ]

get mail add, call 'Open' [
 get conductor dispatch, will mail:open
]

get mail add, call 'Accounts' [
 get conductor dispatch, will mail-accounts:open
]

get mail add, call 'Sync' [
 get conductor dispatch, will mail:sync
]

get mail
