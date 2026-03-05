# Simple markdown renderer

set render-markdown-to-element [ function element text [
 set html [ get text, default '' ]
 set html [ get html replace, call [ global RegExp, new '^######\\s+(.+)$' 'gm' ] '<h6>$1</h6>' ]
 set html [ get html replace, call [ global RegExp, new '^#####\\s+(.+)$' 'gm' ] '<h5>$1</h5>' ]
 set html [ get html replace, call [ global RegExp, new '^####\\s+(.+)$' 'gm' ] '<h4>$1</h4>' ]
 set html [ get html replace, call [ global RegExp, new '^###\\s+(.+)$' 'gm' ] '<h3>$1</h3>' ]
 set html [ get html replace, call [ global RegExp, new '^##\\s+(.+)$' 'gm' ] '<h2>$1</h2>' ]
 set html [ get html replace, call [ global RegExp, new '^#\\s+(.+)$' 'gm' ] '<h1>$1</h1>' ]
 set html [ get html replace, call [ global RegExp, new '\\*\\*(.+?)\\*\\*' 'g' ] '<strong>$1</strong>' ]
 set html [ get html replace, call [ global RegExp, new '\\*(.+?)\\*' 'g' ] '<em>$1</em>' ]
 set html [ get html replace, call [ global RegExp, new '```([\\s\\S]*?)```' 'g' ] '<pre><code>$1</code></pre>' ]
 set html [ get html replace, call [ global RegExp, new '`([^`]+)`' 'g' ] '<code>$1</code>' ]
 set html [ get html replace, call [ global RegExp, new '\\n\\n' 'g' ] '<br><br>' ]
 set element innerHTML [ get html ]
 get element
] ]

get render-markdown-to-element
