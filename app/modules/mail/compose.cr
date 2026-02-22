# Mail compose form - from, to, cc, bcc, subject, body

load ./compose-styles.cr, point

function mail-service contact-service on-send [
 set contacts [ get contact-service fetch-contacts, call ]
 set from-field [ get lib email-input, call 'From' [ get contacts ] ]
 set to-field [ get lib email-input, call 'To' [ get contacts ] ]
 set cc-field [ get lib email-input, call 'Cc' [ get contacts ] ]
 set bcc-field [ get lib email-input, call 'Bcc' [ get contacts ] ]
 set wrap [ global document createElement, call div ]
 get wrap classList add, call mail-compose
 get wrap appendChild, call [ get from-field element ]
 get wrap appendChild, call [ get to-field element ]
 get wrap appendChild, call [ get cc-field element ]
 get wrap appendChild, call [ get bcc-field element ]
 set subj-wrap [ global document createElement, call div ]
 get subj-wrap classList add, call mail-compose-field
 set subj-lbl [ global document createElement, call label ]
 set subj-lbl textContent 'Subject'
 get subj-wrap appendChild, call [ get subj-lbl ]
 set subj-input [ global document createElement, call input ]
 get subj-input classList add, call mail-compose-input
 get subj-input placeholder 'Subject'
 get subj-wrap appendChild, call [ get subj-input ]
 get wrap appendChild, call [ get subj-wrap ]
 set body-wrap [ global document createElement, call div ]
 get body-wrap classList add, call mail-compose-field
 set body-lbl [ global document createElement, call label ]
 set body-lbl textContent 'Message'
 get body-wrap appendChild, call [ get body-lbl ]
 set body-ta [ global document createElement, call textarea ]
 get body-ta classList add, call mail-compose-textarea
 get body-ta placeholder 'Type your message...'
 get body-wrap appendChild, call [ get body-ta ]
 get wrap appendChild, call [ get body-wrap ]
 set send-btn [ global document createElement, call button ]
 get send-btn classList add, call mail-send-btn
 set send-btn textContent 'Send'
 get send-btn addEventListener, call click [
  function [
   get on-send, call [
    object [
     from [ get from-field getValue, call ]
     to [ get to-field getValue, call ]
     cc [ get cc-field getValue, call ]
     bcc [ get bcc-field getValue, call ]
     subject [ get subj-input value ]
     body [ get body-ta value ]
    ]
   ]
  ]
 ]
 get wrap appendChild, call [ get send-btn ]
 object [
 element [ get wrap ]
 setSubject [ function s [ set subj-input value [ get s ] ] ]
 setBody [ function s [ set body-ta value [ get s ] ] ]
]
]
