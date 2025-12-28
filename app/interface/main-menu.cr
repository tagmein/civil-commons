set main-toolbar [
 get components action-bar, call
]

# Menu: Civil Commons

set commons [ get components menu, call ]
get commons add, call About

get main-toolbar add, call 'Civil Commons' [
 get commons toggle
]

# Menu: Guest

set guest [ get components menu, call ]
get guest add, call 'Sign in'
get guest add, call 'Sign up'

get main-toolbar add, call 'Guest' [
 get guest toggle
]

# Menu: View

set view [ get components menu, call ]
get view add, call 'Full screen'

get main-toolbar add, call 'View' [
 get view toggle
]

# Menu: Window

set window [ get components menu, call ]
get window add, call 'Close'
get window add, call 'Maximize'
get window add, call 'Minimize'

get main-toolbar add, call 'Window' [
 get window toggle
]

global document body appendChild, call [ get main-toolbar element ]
