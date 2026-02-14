# Document window API for AI Generate Content
# Loaded after document/window

set open-documents [ get main open-documents-ref current ]

set get-open-document-ids [ function [
 set result [ list ]
 set entries [ get open-documents, entries ]
 get entries, each [
  function pair [
   set win [ get pair, at 1 ]
   get win, true [
    set doc-id [ get pair, at 0 ]
    get result push, call [ object [ id [ get doc-id ], name [ get win title-text textContent, default 'Untitled' ] ] ]
   ]
  ]
 ]
 get result
] ]

# Single-arg function to avoid Crown parser issue with function name name [ pattern
set append-to-document [ function args [
 set doc-id [ get args doc-id ]
 set text [ get args text ]
 set doc-id-arg [ get doc-id ]
 set win [ get open-documents [ get doc-id-arg ] ]
 get win, true [
  set ta [ get win textarea ]
  get ta, true [
   set cur [ get ta value, default '' ]
   set ta value [ template '%0%1' [ get cur ] [ get text ] ]
  ]
 ]
] ]

set main document-window-api [ object [
 get-open-document-ids [ get get-open-document-ids ]
 append-to-document [ get append-to-document ]
] ]
