function path [
 set container [
  global document createElement, call div
 ]
 set response [ global fetch, call [ get path ] ]
 set svg-text [ get response text, call ]
 set parser [
  global DOMParser, new
 ]
 set svg-doc [
  get parser parseFromString, call [ get svg-text ] 'image/svg+xml'
 ]
 set svg-element [
  get svg-doc documentElement
 ]
 get container appendChild, call [ get svg-element ]
 get container
]
