# function route() {
#  const page = window.location.hash.substring(1)
#  console.log("page", page)
# }
# route()
# window.addEventListener("hashchange", route)
log Civil Commons

set toolbarStyleTag [
 global document createElement, call style
]
set [ get toolbarStyleTag ] textContent '
 .toolbar {
  background-color: #222226;
  height: 50px;
 }
'
global document head appendChild, call [ get toolbarStyleTag ]

set toolbar [
 global document createElement, call div
]
get toolbar classList add, call toolbar

global document body appendChild, call [ get toolbar ]
