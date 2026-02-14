# Menu: Document

set document [ get components menu, call Document ]

get document add, call 'New' [
 get conductor dispatch, will '!document:new'
]

get document add, call 'Rename' [
 function item event [
  get conductor dispatch, call document:rename [ get main document-service get-current-document-id, call ]
 ]
]

get document add, call 'Recent' [
 get conductor dispatch, will document:recent
]

get document
