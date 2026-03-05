# "Preview" tab for the Generate Content window

function tabs hist-tab [
 set preview-tabs [ list ]

 set open-preview-tab [ function item [
  # Check if already open
  set existing null
  get preview-tabs, each [
   function ptab [
    get ptab id, is [ get item id ], true [
     set existing [ get ptab ]
    ]
   ]
  ]

  get existing, true [
   get tabs set-active, call [ get existing tab ]
   value undefined
  ]

  set p-content [ global document createElement, call div ]
  get p-content classList add, call generate-content-tab-content
  set p-padding [ global document createElement, call div ]
  set p-padding style padding '20px'
  get p-content appendChild, call [ get p-padding ]

  set p-header [ global document createElement, call div ]
  set p-header style display flex
  set p-header style justify-content space-between
  set p-header style align-items center
  set p-header style margin-bottom '15px'
  get p-padding appendChild, call [ get p-header ]

  set p-title [ global document createElement, call h3 ]
  set p-title textContent 'Markdown Preview'
  set p-title style margin 0
  get p-header appendChild, call [ get p-title ]

  set p-close [ global document createElement, call button ]
  set p-close textContent 'Close Preview'
  get p-close classList add, call generate-content-button
  set p-close style padding '4px 12px'
  get p-header appendChild, call [ get p-close ]

  set p-body [ global document createElement, call div ]
  get p-body classList add, call generate-content-preview
  set p-body style display 'block'
  get p-padding appendChild, call [ get p-body ]
  get lib markdown, call [ get p-body ] [ get item result ]

  set p-tab [
   get tabs add, call 'Preview' [
    function tab event [
     get preview-tabs, each [ function ptab [
      get ptab content style display 'none'
     ] ]
     set p-content style display 'block'
    ]
   ]
  ]
  
  get preview-tabs push, call [ object [ id [ get item id ], tab [ get p-tab ], content [ get p-content ] ] ]

  get p-close addEventListener, call click [
   function [
    get tabs remove, call [ get p-tab ]
    get p-content remove, call
    
    set new-preview-tabs [ list ]
    get preview-tabs, each [
     function ptab-item [
      get ptab-item tab, is [ get p-tab ], false [
       get new-preview-tabs push, call [ get ptab-item ]
      ]
     ]
    ]
    set preview-tabs [ get new-preview-tabs ]

    get tabs set-active, call [ get hist-tab ]
   ]
  ]

  get tabs set-active, call [ get p-tab ]
 ] ]

 get open-preview-tab
]

function placeholder [ ]
function placeholder [ ]
