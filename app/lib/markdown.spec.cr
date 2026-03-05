# Tests for markdown library

set harness [ load ../../tests/dom-harness.cr, point ]
set render-markdown-to-element [ load ./markdown.cr, point ]

get describe, call 'markdown library' [
 function [
  get describe, call 'render-markdown-to-element function' [
   function [
    get it, call 'should render headings' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] '# Heading 1
## Heading 2'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<h1>Heading 1</h1>'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<h2>Heading 2</h2>'
     ]
    ]

    get it, call 'should render bold text' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] 'This is **bold** text'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<strong>bold</strong>'
     ]
    ]

    get it, call 'should render italic text' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] 'This is *italic* text'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<em>italic</em>'
     ]
    ]

    get it, call 'should render inline code' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] 'Use `code` here'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<code>code</code>'
     ]
    ]

    get it, call 'should render code blocks' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] '```
line 1
line 2
```'
      get expect, call [ get to-contain ] [ get element innerHTML ] '<pre><code>
line 1
line 2
</code></pre>'
     ]
    ]

    get it, call 'should render line breaks for double newlines' [
     function [
      set element [ get harness create-element, call div ]
      get render-markdown-to-element, call [ get element ] 'Paragraph 1

Paragraph 2'
      get expect, call [ get to-contain ] [ get element innerHTML ] 'Paragraph 1<br><br>Paragraph 2'
     ]
    ]
   ]
  ]
 ]
]
