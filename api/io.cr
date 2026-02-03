# Shared I/O module for API routes
# Variables defined here cascade down to loaded API route modules

set fs [ global import, call fs/promises ]

set data-path './data'

# Read file as string
set i [ function x [
 get fs readFile, call [ get x ]
 at toString, call utf-8
] ]

# Write file as string
set o [ function x y [
 get fs writeFile, call [ get x ] [ get y ] utf-8
] ]

# Read file as JSON
set ij [ function x [
 global JSON parse, call [
  get fs readFile, call [ get x ]
  at toString, call utf-8
 ]
] ]

# Write file as JSON
set oj [ function x y [
 get fs writeFile, call [ get x ] [ global JSON stringify, call [ get y ] ] utf-8
] ]

# Ensure directory exists
set ensure-dir [ function path [
 try [
  get fs mkdir, call [ get path ] [ object [ recursive true ] ]
 ] [
  # Directory may already exist, ignore error
 ]
] ]

# Check if file exists
set file-exists [ function path [
 set result [ object [ exists false ] ]
 try [
  get fs access, call [ get path ]
  set result exists true
 ] [
  # File doesn't exist
 ]
 get result exists
] ]

# Generate random ID
set generate-id [ function [
 global Math random, call
 at toString, call 36
 at substring, call 2 10
] ]

object [
 data-path
 i
 o
 ij
 oj
 ensure-dir
 file-exists
 generate-id
]
