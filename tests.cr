set ( fs, path ) [ global import, call ( fs/promises, path ) ]

set find-spec-files [
 function dir [
  set files [ list ]
  set entries [ global fs readdir, call [ get dir ] [ object [ withFileTypes true ] ] ]
  get entries, map [
   function entry [
    set entry-path [ global path join, call [ get dir ] [ get entry name ] ]
    get entry isDirectory, call, true [
     set sub-files [ get find-spec-files, call [ get entry-path ] ]
     get sub-files, map [
      function file [
       get files push, call [ get file ]
      ]
     ]
    ], false [
     get entry name, pick [
      value [ at endsWith, call .spec.cr ]
      get files push, call [ get entry-path ]
     ] [
      true
      # skip non-spec files
     ]
    ]
   ]
  ]
  get files
 ]
]

set test-results [
 object [
  passed [ list ]
  failed [ list ]
  total 0
 ]
]

set describe [
 function name tests [
  log [ template '  %0' [ get name ] ]
  get tests, call
 ]
]

set it [
 function name test-fn [
  set test-name [ template '    %0' [ get name ] ]
  clear_error
  set test-error null
  try [
   get test-fn, call
  ] [
   # Error occurred - capture it
   get_error, to test-error
  ]
  get test-error, true [
   # test-error is truthy, so it's an error message (string) - test failed
   get test-results failed push, call [ get test-name ]
   set test-results total [ get test-results total, add 1 ]
   log [ template '%0 ✗' [ get test-name ] ]
   log [ template '      Error: %0' [ get test-error ] ]
   clear_error
  ], false [
   # test-error is falsy (null or undefined), so no error - test passed
   get test-results passed push, call [ get test-name ]
   set test-results total [ get test-results total, add 1 ]
   log [ template '%0 ✓' [ get test-name ] ]
  ]
 ]
]

set expect [
 function matcher actual expected [
  # Check if expected is defined (not undefined) rather than truthy
  # This allows comparing to 0, false, null, empty string, etc.
  get expected, typeof, is undefined, true [
   get matcher, call [ get actual ]
  ], false [
   get matcher, call [ get actual ] [ get expected ]
  ]
 ]
]

set to-equal [
 function actual expected [
  get actual, is [ get expected ], true [
   true
  ], false [
   error [ template 'Expected %0 to equal %1' [ get actual ] [ get expected ] ]
  ]
 ]
]

set to-be-null [
 function actual [
  get actual, is null, true [
   true
  ], false [
   throw [ template 'Expected %0 to be null' [ get actual ] ]
  ]
 ]
]

set to-be-true [
 function actual [
  get actual, true [
   true
  ], false [
   throw [ template 'Expected %0 to be true' [ get actual ] ]
  ]
 ]
]

set to-be-false [
 function actual [
  get actual, false [
   true
  ], false [
   throw [ template 'Expected %0 to be false' [ get actual ] ]
  ]
 ]
]

# Matcher that expects a function to throw an error
# Usage: get expect-error, call [ function [ ... code that should error ... ] ]
# This is a special matcher that doesn't use the normal expect pattern
set expect-error [
 function test-fn [
  set result [ object [ threw false ] ]
  try [
   get test-fn, call
  ] [
   set result threw true
  ]
  get result threw, false [
   error 'Expected function to throw an error, but it did not'
  ]
  true
 ]
]

# Matcher that expects a value to be defined (not undefined)
set to-be-defined [
 function actual [
  get actual, typeof, is undefined, true [
   error 'Expected value to be defined, but got undefined'
  ], false [
   true
  ]
 ]
]

set run-tests [
 function [
  log 'Running tests...'
  log ''
  set spec-files [ get find-spec-files, call tests ]
  get spec-files, map [
   function file [
    log [ template 'Running %0...' [ get file ] ]
    try [
     load [ get file ], point
    ] [
     log [ template 'Error loading %0: %1' [ get file ] [ current_error ] ]
    ]
    log ''
   ]
  ]
  log ''
  log 'Test Results:'
  log [ template '  Total: %0' [ get test-results total ] ]
  log [ template '  Passed: %0' [ get test-results passed length ] ]
  log [ template '  Failed: %0' [ get test-results failed length ] ]
  get test-results failed length, > 0, true [
   log ''
   log 'Failed tests:'
   get test-results failed, map [
    function test [
     log [ template '  - %0' [ get test ] ]
    ]
   ]
   global process exit, call 1
  ]
 ]
]

get run-tests, call
