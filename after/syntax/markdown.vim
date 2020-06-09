syn match AjnaszNoteError '!TODO\|!ISSUE\|!ERROR\>'
syn match AjnaszNoteGood '!DONE\|!FIXED'
syn match AjnaszNoteWarning '!PENDING\|!QUESTION\|!IMPORTANT'
syn match AjnaszNoteTodo "\%(\t\| \{0,4\}\%([-*+]\|\d\+\.\)\s\)\[ \]"
syn match AjnaszNoteTodoDone "\%(\t\| \{0,4\}\%([-*+]\|\d\+\.\)\s\)\[X\]"
hi AjnaszNoteError guibg=NONE guifg=#f01d22 gui=NONE ctermbg=NONE ctermfg=160 cterm=NONE guibg=NONE
hi AjnaszNoteTodo guibg=NONE guifg=#f01d22 gui=NONE ctermbg=NONE ctermfg=160 cterm=NONE guibg=NONE
hi AjnaszNoteGood guibg=NONE guifg=#2ac00a gui=NONE ctermbg=NONE ctermfg=40 cterm=NONE guibg=NONE
hi AjnaszNoteTodoDone guibg=NONE guifg=#2ac00a gui=NONE ctermbg=NONE ctermfg=40 cterm=NONE guibg=NONE
hi AjnaszNoteWarning guibg=NONE guifg=#ff9900 gui=NONE ctermbg=NONE ctermfg=40 cterm=NONE guibg=NONE
