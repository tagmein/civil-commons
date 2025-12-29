set main-toolbar [
 get components action-bar, call
]

# Menu: Commons

set commons [ get components menu, call ]
get commons add, call About

get main-toolbar add, call 'Commons' [
 get commons toggle
]

# Menu: Document

set document [ get components menu, call ]
get document add, call 'Item'

get main-toolbar add, call 'Document' [
 get document toggle
]

# Menu: Edit

set edit [ get components menu, call ]
get edit add, call 'Item'

get main-toolbar add, call 'Edit' [
 get edit toggle
]

# Menu: File

set file [ get components menu, call ]
get file add, call 'Item'

get main-toolbar add, call 'File' [
 get file toggle
]

# Menu: Layout

set layout [ get components menu, call ]
get layout add, call 'Item'

get main-toolbar add, call 'Layout' [
 get layout toggle
]

# Menu: Log

set log [ get components menu, call ]
get log add, call 'Item'

get main-toolbar add, call 'Log' [
 get log toggle
]

# Menu: Page

set page [ get components menu, call ]
get page add, call 'Item'

get main-toolbar add, call 'Page' [
 get page toggle
]

# Menu: Presentation

set presentation [ get components menu, call ]
get presentation add, call 'Item'

get main-toolbar add, call 'Presentation' [
 get presentation toggle
]

# Menu: Session

set session [ get components menu, call ]
get session add, call 'Sign in'
get session add, call 'Sign up'

get main-toolbar add, call 'Session' [
 get session toggle
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
