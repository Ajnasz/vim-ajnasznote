scriptencoding utf-8

function! ajnasznote#add_match_tags(tags)
  call luaeval('require("ajnasznote").add_match_tags(_A)', a:tags)
endfunction

function! ajnasznote#rename_note()
  call luaeval('require("ajnasznote").rename_note()')
endfunction

function! ajnasznote#create_note()
  call luaeval('require("ajnasznote").create_note()')
endfunction

function! ajnasznote#exec_doc_commands()
	" let l:commands = s:buffer_get_commands()
	" let l:commands = luaeval('require("ajnasznote").buffer_get_commands()')

	" for l:custom_command in l:commands
	" 	if l:custom_command['cmd'] ==# '+md_loadsyntax'
	" 		let g:markdown_fenced_languages += l:custom_command['args']
	" 	endif
	" endfor
endfunction

function ajnasznote#handle_search(lines) abort
	call luaeval('require("ajnasznote").handle_search_2(_A)', a:lines)
endfunction



function! ajnasznote#insert_note()
	call luaeval('require("ajnasznote").insert_note()')
endfunction
