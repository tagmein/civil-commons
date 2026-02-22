# GET/PATCH /api/sessions/:sessionId/mail/sync-settings
# GET returns { mode, intervalMinutes, lastSyncAt, lastSyncCount, lastSyncAccount }
# PATCH body: { mode?, intervalMinutes?, lastSyncAt?, lastSyncCount?, lastSyncAccount? }

function request respond session-id body [
 set file [ template '%0/sessions/%1/mail/sync-settings.json' [ get data-path ] [ get session-id ] ]
 set defaults [ object [
  mode 'manual'
  intervalMinutes 15
  lastSyncAt null
  lastSyncCount 0
  lastSyncAccount null
 ] ]
 set settings [ get defaults ]
 try [
  set loaded [ get ij, call [ get file ] ]
  get loaded, true [
   set settings [ get loaded ]
  ]
 ] [
 ]
 get request method, is PATCH, true [
  get body, true [
   get body mode, true [ set settings mode [ get body mode ] ]
   get body intervalMinutes, true [ set settings intervalMinutes [ get body intervalMinutes ] ]
   get body lastSyncAt, true [ set settings lastSyncAt [ get body lastSyncAt ] ]
   get body lastSyncCount, true [ set settings lastSyncCount [ get body lastSyncCount ] ]
   get body lastSyncAccount, true [ set settings lastSyncAccount [ get body lastSyncAccount ] ]
  ]
  get ensure-dir, call [ template '%0/sessions/%1/mail' [ get data-path ] [ get session-id ] ]
  get oj, call [ get file ] [ get settings ]
 ]
 get respond, call 200 [
  global JSON stringify, call [ get settings ]
 ] application/json
]
