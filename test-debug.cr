set is_test true
set serve [ load ./serve.cr, point ]
log serve object:
log [ get serve ]
log get-mime-type property:
log [ get serve get-mime-type ]
log calling get-mime-type:
set result [ get serve get-mime-type, call '/test.svg' ]
log result:
log [ get result ]
