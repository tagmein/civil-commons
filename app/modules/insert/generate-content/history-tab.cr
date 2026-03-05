# "History" tab for the Generate Content window

function get-history get-history-url open-preview-tab prompt-textarea gen-tab-api [
 set container [ global document createElement, call div ]
 get container classList add, call generate-content-tab-content

 set history-padding [
  global document createElement, call div
 ]
 set history-padding style padding '20px'
 set history-padding style display flex
 set history-padding style flex-direction column
 set history-padding style height '100%'
 set history-padding style box-sizing border-box
 get container appendChild, call [ get history-padding ]

 set history-table-wrap [
  global document createElement, call div
 ]
 get history-table-wrap classList add, call generate-content-history-wrap
 get history-padding appendChild, call [ get history-table-wrap ]

 set refresh-history [ function [
  set history-table-wrap innerHTML ''
  set history [ get get-history, call ]
  try [
   get history length, = 0, true [
    set empty [ global document createElement, call div ]
    set empty textContent 'No generation history yet.'
    set empty style color '#808080'
    set empty style padding '20px'
    set empty style text-align 'center'
    get history-table-wrap appendChild, call [ get empty ]
   ], false [
    set table [ global document createElement, call table ]
    get table classList add, call generate-content-history-table
    set thead [ global document createElement, call thead ]
    set tr [ global document createElement, call tr ]
    set th1 [ global document createElement, call th ]
    set th1 textContent 'Prompt'
    get tr appendChild, call [ get th1 ]
    set th2 [ global document createElement, call th ]
    set th2 textContent 'Date'
    get tr appendChild, call [ get th2 ]
    set th3 [ global document createElement, call th ]
    set th3 textContent 'Actions'
    get tr appendChild, call [ get th3 ]
    get thead appendChild, call [ get tr ]
    get table appendChild, call [ get thead ]

    set tbody [ global document createElement, call tbody ]
    get history, each [
     function item [
      set row [ global document createElement, call tr ]

      set td1 [ global document createElement, call td ]
      set prompt-text [ get item prompt, default '' ]
      get prompt-text length, > 40, true [
       set prompt-text [ template '%0...' [ get prompt-text substring, call 0 40 ] ]
      ]
      set td1 textContent [ get prompt-text ]
      get row appendChild, call [ get td1 ]

      set td2 [ global document createElement, call td ]
      set d [ global Date, new [ get item date ] ]
      set td2 textContent [ get d toLocaleDateString, call ]
      get row appendChild, call [ get td2 ]

      set td3 [ global document createElement, call td ]
      get td3 classList add, call generate-content-history-actions

      set preview-btn [ global document createElement, call button ]
      set preview-btn textContent 'Preview'
      get preview-btn addEventListener, call click [
       function [
        get open-preview-tab, call [ get item ]
       ]
      ]
      get td3 appendChild, call [ get preview-btn ]

      set edit-btn [ global document createElement, call button ]
      set edit-btn textContent 'Edit Prompt'
      get edit-btn addEventListener, call click [
       function [
        set prompt-textarea value [ get item prompt ]
        get gen-tab-api set-active, call
       ]
      ]
      get td3 appendChild, call [ get edit-btn ]

      set del-btn [ global document createElement, call button ]
      set del-btn textContent 'Delete'
      get del-btn addEventListener, call click [
       function [
        set url [ get get-history-url, call ]
        set opts [ object [
         method 'DELETE'
         headers [ object [ Content-Type 'application/json' ] ]
         body [ global JSON stringify, call [ object [ id [ get item id ] ] ] ]
        ] ]
        try [
         global fetch, call [ get url ] [ get opts ]
         get refresh-history, call
        ] [ ]
       ]
      ]
      get td3 appendChild, call [ get del-btn ]

      get row appendChild, call [ get td3 ]
      get tbody appendChild, call [ get row ]
     ]
    ]
    get table appendChild, call [ get tbody ]
    get history-table-wrap appendChild, call [ get table ]
   ]
  ] [
   set empty [ global document createElement, call div ]
   set empty textContent 'Error loading history.'
   set empty style color '#ff8080'
   set empty style padding '20px'
   set empty style text-align 'center'
   get history-table-wrap appendChild, call [ get empty ]
  ]
 ] ]

 get refresh-history, call

 object [
  element [ get container ]
  refresh [ get refresh-history ]
 ]
]
