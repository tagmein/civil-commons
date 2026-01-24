set main-status [
 get components action-bar, call
]

global document body appendChild, call [ get main-status element ]

get main-status
