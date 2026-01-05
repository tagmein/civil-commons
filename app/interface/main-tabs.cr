set main-tabs [
 get components action-bar, call
]

get main-tabs add, call Home

global document body appendChild, call [ get main-tabs element ]
