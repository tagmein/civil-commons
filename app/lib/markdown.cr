# Simple markdown renderer

set render-markdown-to-element [ function element text [
 set html [ get text, default '' ]
 set html [ get html replace, call [ global RegExp, new '^(#{1,6})\\s+(.+)$' 'gm' ] [ function match hashes title [
  template '<h%0>%1</h%0>' [ get hashes length ] [ get title ]
 ] ] ]
 set html [ get html replace, call [ global RegExp, new '\\*\\*(.+?)\\*\\*' 'g' ] '<strong>$1</strong>' ]
 set html [ get html replace, call [ global RegExp, new '\\*(.+?)\\*' 'g' ] '<em>$1</em>' ]
 set html [ get html replace, call [ global RegExp, new '```([\\s\\S]*?)```' 'g' ] '<pre><code>$1</code></pre>' ]
 set html [ get html replace, call [ global RegExp, new '`([^`]+)`' 'g' ] '<code>$1</code>' ]
 set html [ get html replace, call [ global RegExp, new '\\n\\n' 'g' ] '<br><br>' ]
 set element innerHTML [ get html ]
] ]

get render-markdown-to-element