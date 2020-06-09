if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpoptions
set cpoptions&vim

set syntax=markdown
set conceallevel=2 wrap lbr tw=80 wrapmargin=0 showbreak=\\n>

exec printf('au BufWritePost %s/*.md call ajnasznote#rename_note()', resolve(fnamemodify(g:ajnasznote_directory, ':p:h')))

call AjnaszExecCommand()

let &cpoptions = s:cpo_save
unlet s:cpo_save
