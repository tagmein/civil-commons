# Menu: Commons

set commons [ get components menu, call Commons ]
get commons add, call About [
 get conductor dispatch, will commons:about
]

get commons add, call Preferences [
 get conductor dispatch, will commons:preferences
]

get commons
