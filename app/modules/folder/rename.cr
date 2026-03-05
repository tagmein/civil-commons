# Rename Folder Window
get conductor register, call folder:rename [
 function [
  set folder-service [ get main folder-service ]
  set current-folder-id [ get folder-service get-current-folder-id, call ]
  get current-folder-id, false [ value undefined ]

  set folder [ get folder-service fetch-folder, call [ get current-folder-id ] ]
  get folder, false [ value undefined ]

  set old-name [ get folder name, default 'Untitled Folder' ]
  set win [ get components window, call [ template 'Rename: %0' [ get old-name ] ] 300 200 ]
  
  set content [ global document createElement, call div ]
  get content style cssText 'padding: 10px; color: #fff;'

  set label [ global document createElement, call div ]
  set label textContent 'New Name:'
  get content appendChild, call [ get label ]

  set input [ global document createElement, call input ]
  set input value [ get old-name ]
  get input style cssText 'width: 100%; margin-bottom: 10px; padding: 4px; background: #222; color: #fff; border: 1px solid #444;'
  get content appendChild, call [ get input ]

  set save-btn [ global document createElement, call button ]
  set save-btn textContent 'Save'
  get content appendChild, call [ get save-btn ]

  get save-btn addEventListener, call click [
   function [
    get folder-service rename-folder, call [ get current-folder-id ] [ get input value ]
    get win close, call
   ]
  ]

  get win fill, call [ get content ]
  get main stage place-window, call [ get win ] [ get main status ]
 ]
]
