# Add Account modal - form for Gmail or SMTP
# Returns function (mail-service, on-added) that opens the modal

get lib style-tag

tell '.add-account-form' [
 object [
  padding 20px
 ]
]

tell '.add-account-form label' [
 object [
  color '#e0e0d0'
  display block
  font-size 13px
  margin-bottom 4px
 ]
]

tell '.add-account-form input' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  box-sizing border-box
  color '#e0e0d0'
  font-size 14px
  margin-bottom 12px
  padding '8px 12px'
  width '100%'
 ]
]

tell '.add-account-form select' [
 object [
  background-color '#333337'
  border '1px solid #444448'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  margin-bottom 12px
  padding '8px 12px'
  width '100%'
 ]
]

tell '.add-account-form-buttons' [
 object [
  display flex
  gap 10px
  justify-content flex-end
  margin-top 16px
 ]
]

tell '.add-account-form button' [
 object [
  background-color '#444448'
  border none
  border-radius 4px
  color '#e0e0d0'
  cursor pointer
  font-size 14px
  padding '8px 16px'
 ]
]

tell '.add-account-form button.primary' [
 object [
  background-color '#4a9eff'
  color white
 ]
]

tell '.smtp-fields' [
 object [
  margin-bottom 12px
 ]
]

function mail-service on-added [
 set modal-window [
  get components window, call 'Add Account' 360 340
 ]

 set form [ global document createElement, call form ]
 get form classList add, call add-account-form

 set type-label [ global document createElement, call label ]
 set type-label textContent 'Account type'
 get form appendChild, call [ get type-label ]

 set type-select [ global document createElement, call select ]
 get type-select classList add, call add-account-form
 set gmail-opt [ global document createElement, call option ]
 get gmail-opt setAttribute, call 'value' 'gmail'
 set gmail-opt textContent 'Gmail'
 get type-select appendChild, call [ get gmail-opt ]
 set smtp-opt [ global document createElement, call option ]
 get smtp-opt setAttribute, call 'value' 'smtp'
 set smtp-opt textContent 'SMTP'
 get type-select appendChild, call [ get smtp-opt ]
 get form appendChild, call [ get type-select ]

 set email-section [ global document createElement, call div ]
 get email-section classList add, call smtp-fields
 set email-label [ global document createElement, call label ]
 set email-label textContent 'Email'
 get email-section appendChild, call [ get email-label ]
 set email-input [ global document createElement, call input ]
 get email-input setAttribute, call 'type' 'email'
 get email-input setAttribute, call 'placeholder' 'you@example.com'
 get email-section appendChild, call [ get email-input ]
 get form appendChild, call [ get email-section ]

 set smtp-section [ global document createElement, call div ]
 get smtp-section classList add, call smtp-fields
 set host-label [ global document createElement, call label ]
 set host-label textContent 'SMTP host'
 get smtp-section appendChild, call [ get host-label ]
 set host-input [ global document createElement, call input ]
 get host-input setAttribute, call 'placeholder' 'smtp.example.com'
 get smtp-section appendChild, call [ get host-input ]
 set port-label [ global document createElement, call label ]
 set port-label textContent 'Port'
 get smtp-section appendChild, call [ get port-label ]
 set port-input [ global document createElement, call input ]
 get port-input setAttribute, call 'type' 'number'
 get port-input setAttribute, call 'value' '587'
 get smtp-section appendChild, call [ get port-input ]
 get form appendChild, call [ get smtp-section ]

 set update-visibility [ function [
  get type-select value, is 'smtp', true [
   set email-section style display 'block'
   set smtp-section style display 'block'
  ], false [
   set email-section style display 'none'
   set smtp-section style display 'none'
  ]
 ] ]
 get update-visibility, call
 get type-select addEventListener, call change [ get update-visibility ]

 set btn-row [ global document createElement, call div ]
 get btn-row classList add, call add-account-form-buttons
 set cancel-btn [ global document createElement, call button ]
 set cancel-btn textContent 'Cancel'
 get cancel-btn setAttribute, call 'type' 'button'
 get cancel-btn addEventListener, call click [
  function [
   get modal-window close, call
  ]
 ]
 get btn-row appendChild, call [ get cancel-btn ]
 set connect-btn [ global document createElement, call button ]
 get connect-btn classList add, call primary
 set connect-btn textContent 'Connect'
 get connect-btn setAttribute, call 'type' 'submit'
 get btn-row appendChild, call [ get connect-btn ]
 get form appendChild, call [ get btn-row ]

 get form addEventListener, call submit [
  function e [
   get e preventDefault, call
   set type [ get type-select value ]
   get type, is 'gmail', true [
    set auth-url [ get mail-service get-google-auth-url, call ]
    get auth-url, true [
     global location assign, call [ get auth-url ]
    ], false [
     log Google OAuth not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET.
    ]
   ], false [
    set email [ get email-input value ]
    get email length, > 0, true [
     set account [ object [ type [ get type ] email [ get email ] host [ get host-input value ] port [ global parseInt, call [ get port-input value ] 10 ] ] ]
     set created [ get mail-service create-account, call [ get account ] ]
     get created, true [
      get on-added, call
      get modal-window close, call
     ]
    ]
   ]
  ]
 ]

 get modal-window fill, call [ get form ]
 get main stage place-window, call [ get modal-window ] [ get main status ]
]
