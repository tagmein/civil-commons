set fs [ global import, call fs/promises ]

set i [ function x [
 get fs readFile, call [ get x ]
 at toString, call utf-8
] ]

set o [ function x y [
 get fs writeFile, call [ get x ] [ get y ] utf-8
] ]

set ij [ function x [
 global JSON parse, call [
  get fs readFile, call [ get x ]
  at toString, call utf-8
 ]
] ]

set oj [ function x y [
 get fs writeFile, call [ get x ] [ global JSON stringify, call [ get y ] ] utf-8
] ]
