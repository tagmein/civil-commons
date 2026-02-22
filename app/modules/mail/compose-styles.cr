# Compose form styles - loaded by compose.cr

get lib style-tag

tell '.mail-compose' [
 object [
  border-top '1px solid #333337'
  flex-shrink 0
  padding 16px
 ]
]

tell '.mail-compose-field' [
 object [
  margin-bottom 12px
 ]
]

tell '.mail-compose-field label' [
 object [
  color '#808080'
  display block
  font-size 12px
  margin-bottom 4px
 ]
]

tell '.mail-compose-input' [
 object [
  background-color '#1e1e22'
  border '1px solid #333337'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  padding '8px 12px'
  width '100%'
 ]
]

tell '.mail-compose-textarea' [
 object [
  background-color '#1e1e22'
  border '1px solid #333337'
  border-radius 4px
  color '#e0e0d0'
  font-size 14px
  height 100px
  margin-bottom 12px
  padding 8px
  resize vertical
  width '100%'
 ]
]

tell '.mail-send-btn' [
 object [
  background-color '#4a9eff'
  border none
  border-radius 4px
  color white
  cursor pointer
  font-size 14px
  padding '8px 16px'
 ]
]
