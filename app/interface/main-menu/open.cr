# Menu: Open

set open-menu [ get components menu, call Open ]

get open-menu add, call 'Contacts' [
 get conductor dispatch, will contacts:open
]

get open-menu add, call 'Log' [
 get conductor dispatch, will log:open
]

get open-menu add, call 'Mail' [
 get conductor dispatch, will mail:open
]

get open-menu add, call 'Mail Accounts' [
 get conductor dispatch, will mail-accounts:open
]

get open-menu add, call 'Mail Sync' [
 get conductor dispatch, will mail:sync
]

get open-menu
