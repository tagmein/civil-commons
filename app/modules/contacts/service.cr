# Contacts Service - Contact management within a session

set get-session-id [ function [
 get main session-service get-current-session-id, call
] ]

set fetch-contacts [ function [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ contacts [ list ] ] ]
 get session-id, true [
  try [
   set result-ref contacts [
    global fetch, call [ template '/api/sessions/%0/contacts' [ get session-id ] ]
    at json, call
   ]
  ] [
   # Failed to fetch
  ]
 ]
 get result-ref contacts
] ]

set create-contact [ function name email [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ contact null ] ]
 get session-id, true [
  try [
   set result-ref contact [
    global fetch, call [ template '/api/sessions/%0/contacts' [ get session-id ] ] [
     object [
      method 'POST'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [
       object [
        name [ get name ]
        email [ get email ]
       ]
      ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to create
  ]
 ]
 get result-ref contact
] ]

set update-contact [ function contact-id name email [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ contact null ] ]
 get session-id, true [
  try [
   set updates [ object ]
   get name, true [ set updates name [ get name ] ]
   get email, true [ set updates email [ get email ] ]
   set result-ref contact [
    global fetch, call [ template '/api/sessions/%0/contacts/%1' [ get session-id ] [ get contact-id ] ] [
     object [
      method 'PATCH'
      headers [ object [ Content-Type 'application/json' ] ]
      body [ global JSON stringify, call [ get updates ] ]
     ]
    ]
    at json, call
   ]
  ] [
   # Failed to update
  ]
 ]
 get result-ref contact
] ]

set delete-contact [ function contact-id [
 set session-id [ get get-session-id, call ]
 set result-ref [ object [ success false ] ]
 get session-id, true [
  try [
   set response [
    global fetch, call [ template '/api/sessions/%0/contacts/%1' [ get session-id ] [ get contact-id ] ] [
     object [ method 'DELETE' ]
    ]
   ]
   set body [ get response json, call ]
   get body success, true [ set result-ref success true ]
  ] [
   # Failed to delete
  ]
 ]
 get result-ref success
] ]

object [
 fetch-contacts
 create-contact
 update-contact
 delete-contact
]
