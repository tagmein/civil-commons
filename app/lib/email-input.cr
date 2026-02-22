# Email input with contact autocomplete (datalist)
# Returns object with element, getValue (returns array of trimmed emails)

function label contacts [
 set wrap [ global document createElement, call div ]
 get wrap classList add, call mail-compose-field
 set lbl [ global document createElement, call label ]
 set lbl textContent [ get label ]
 get wrap appendChild, call [ get lbl ]
 set input [ global document createElement, call input ]
 get input classList add, call mail-compose-input
 get input placeholder [ template 'e.g. %0' [ get label ] ]
 set list-id [ template 'contacts-%0' [ global Date now, call ] ]
 get input setAttribute, call 'list' [ get list-id ]
 get wrap appendChild, call [ get input ]
 set datalist [ global document createElement, call datalist ]
 get datalist setAttribute, call 'id' [ get list-id ]
 get contacts, each [
  function c [
   set opt [ global document createElement, call option ]
   get opt setAttribute, call 'value' [ get c email, default '' ]
   set opt textContent [ template '%0 <%1>' [ get c name, default '' ] [ get c email, default '' ] ]
   get datalist appendChild, call [ get opt ]
  ]
 ]
 get wrap appendChild, call [ get datalist ]
 set get-value [ function [
  set raw [ get input value, default '' ]
  set parts [ get raw, at split, call ',' ]
  set result [ list ]
  get parts, each [
   function s [
    set trimmed [ get s, at trim, call ]
    get trimmed length, > 0, true [ get result push, call [ get trimmed ] ]
   ]
  ]
  get result
 ] ]
 object [ element [ get wrap ] input [ get input ] getValue [ get get-value ] ]
]
