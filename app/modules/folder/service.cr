# Folder Service
set listeners [ object [ change [ list ], folderRenamed [ list ], folderItemsChanged [ list ] ] ]
set emit [ function event-name data [ get listeners [ get event-name ], each [ function cb [ get cb, call [ get data ] ] ] ] ]
set on [ function event-name cb [ get listeners [ get event-name ] push, call [ get cb ] ] ]

set current-folder-ref [ object [ id null ] ]
set get-current-folder-id [ function [ get current-folder-ref id ] ]
set set-current-folder-id [ function id [
 set current-folder-ref id [ get id ]
 set main last-interacted [ object [ type folder, id [ get id ] ] ]
 get emit, call change [ get id ]
] ]

set get-session-id [ function [ get main session-service get-current-session-id, call ] ]

set fetch-all-folders [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ folders [ list ] ] ]
 get session-id, true [
  try [ set result-ref folders [ global fetch, call [ template '/api/sessions/%0/folders' [ get session-id ] ], at json, call ] ] [ value undefined ]
 ]
 get result-ref folders
] ]

set fetch-folder [ function folder-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ folder null ] ]
 get session-id, true [
  try [ set result-ref folder [ global fetch, call [ template '/api/sessions/%0/folders/%1' [ get session-id ] [ get folder-id ] ], at json, call ] ] [ value undefined ]
 ]
 get result-ref folder
] ]

set create-folder [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [ set result-ref val [ global fetch, call [ template '/api/sessions/%0/folders' [ get session-id ] ] [ object [ method 'POST' ] ], at json, call ] ] [ ]
 ]
 get result-ref val, true [ global window dispatchEvent, call [ global Event, new 'recent-refresh' ] ]
 get result-ref val
] ]

set rename-folder [ function folder-id new-name [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [
   set result-ref val [ global fetch, call [ template '/api/sessions/%0/folders/%1' [ get session-id ] [ get folder-id ] ] [ object [ method 'PATCH', headers [ object [ Content-Type 'application/json' ] ], body [ global JSON stringify, call [ object [ name [ get new-name ] ] ] ] ] ], at json, call ]
   get emit, call folderRenamed [ object [ id [ get folder-id ], name [ get new-name ] ] ]
  ] [ value undefined ]
 ]
 get result-ref val
] ]

set save-folder [ function folder-id payload [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ val null ] ]
 get session-id, true [
  try [ set result-ref val [ global fetch, call [ template '/api/sessions/%0/folders/%1' [ get session-id ] [ get folder-id ] ] [ object [ method 'PATCH', headers [ object [ Content-Type 'application/json' ] ], body [ global JSON stringify, call [ get payload ] ] ] ], at json, call ] ] [ value undefined ]
 ]
 get result-ref val
] ]

set emit-items-changed [ function folder-id [
 get emit, call folderItemsChanged [ get folder-id ]
] ]

object [
 on
 get-current-folder-id
 set-current-folder-id
 fetch-all-folders
 fetch-folder
 create-folder
 rename-folder
 save-folder
 emit-items-changed
]
