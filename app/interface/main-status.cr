set main-status [
 get components action-bar, call
]

get main-status add, call [ global Date, new ]

global document body appendChild, call [ get main-status element ]

get main-status
