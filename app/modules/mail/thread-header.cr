# Thread header - Subject, From, To from first message

set header [ global document createElement, call div ]
get header classList add, call mail-thread-header
set subj [ global document createElement, call div ]
get subj classList add, call mail-thread-subject
set subj textContent [ get thread subject, default '(No subject)' ]
get header appendChild, call [ get subj ]
set meta [ global document createElement, call div ]
get meta classList add, call mail-thread-meta
set msgs [ get thread messages, default [ list ] ]
set first [ get msgs length, > 0, true [ get msgs, at 0 ], false [ object [ from '', to [ list ] ] ] ]
set from-str [ get first from, default '' ]
set to-arr [ get first to, default [ list ] ]
set to-str [ get to-arr join, call ', ' ]
set meta textContent [ template 'From: %0 | To: %1' [ get from-str ] [ get to-str ] ]
get header appendChild, call [ get meta ]
get header
