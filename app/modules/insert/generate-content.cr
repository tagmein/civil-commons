# Generate Content - AI content generation via Gemini, insert into open documents

get conductor register, call insert:generate-content [
 function [
  set session-service [ get main session-service ]
  set doc-window-api [ get main document-window-api ]

  set history-api [ load ./generate-content/history.cr, point ]
  set ( get-history-url, get-history, add-to-history ) [
   get history-api ( get-history-url, get-history, add-to-history )
  ]

  set gen-window [
   get components window, call 'Generate Content' 600 500
  ]

  set content [
   global document createElement, call div
  ]
  get content classList add, call generate-content-root

  set tabs [ get components tab-bar, call ]
  get content appendChild, call [ get tabs element ]
  
  set all-tab-elements [ list ]

  set gen-tab-api [ object ]
  set hist-tab-api [ object ]

  set create-generate-tab [ load ./generate-content/generate-tab.cr, point ]
  set generate-tab [
   get create-generate-tab, call [ get session-service ] [ get doc-window-api ] [ get add-to-history ] [
    function [ get hist-tab-api refresh, call ]
   ]
  ]
  get content appendChild, call [ get generate-tab element ]
  get all-tab-elements push, call [ get generate-tab element ]

  set create-history-tab [ load ./generate-content/history-tab.cr, point ]
  
  set open-preview-tab-fn [ object [ fn null ] ]
  set history-tab [
   get create-history-tab, call [ get get-history ] [ get get-history-url ] [
    function item [ get open-preview-tab-fn fn, call [ get item ] ]
   ] [ get generate-tab prompt-textarea ] [ get gen-tab-api ]
  ]
  get content appendChild, call [ get history-tab element ]
  get all-tab-elements push, call [ get history-tab element ]
  set history-tab element style display 'none'

  set create-preview-tab [ load ./generate-content/preview-tab.cr, point ]
  set open-preview-tab [
   get create-preview-tab, call [ get tabs ] [ get hist-tab-api ]
  ]
  set open-preview-tab-fn fn [ get open-preview-tab ]
  
  set gen-tab [
   get tabs add, call 'Generate' [
    function tab event [
     get all-tab-elements, each [ function el [ set el style display 'none' ] ]
     set generate-tab element style display 'block'
    ]
   ]
  ]
  set gen-tab-api set-active [ function [
   get tabs set-active, call [ get gen-tab ]
  ] ]

  set hist-tab [
   get tabs add, call 'History' [
    function tab event [
     get all-tab-elements, each [ function el [ set el style display 'none' ] ]
     set history-tab element style display 'block'
     get history-tab refresh, call
    ]
   ]
  ]
  set hist-tab-api tab [ get hist-tab ]

  get tabs set-active, call [ get gen-tab ]

  get gen-window fill, call [ get content ]
  get main stage place-window, call [
   get gen-window
  ] [ get main status ]
 ]
]
