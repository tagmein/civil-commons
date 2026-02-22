# Menu: Contacts

set contacts [ get components menu, call Contacts ]

get contacts add, call 'Open' [
 get conductor dispatch, will contacts:open
]

get contacts
