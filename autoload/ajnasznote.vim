scriptencoding utf-8

function! s:get_matching_tag(tags)
	" let l:buffer_tags = s:buffer_get_tags()
	let l:buffer_tags = luaeval('require("ajnasznote").buffer_get_tags()')
  let l:tag_path = luaeval('require("ajnasznote").get_tag_path(_A[1], _A[2])', [a:tags, l:buffer_tags])

  if l:tag_path ==# v:null
    return ''
  else
    return l:tag_path
  endif
endfunction

function! ajnasznote#add_match_tags(tags)
	if !exists('g:ajnasznote_match_tags')
		let g:ajnasznote_match_tags = []
	endif

	let g:ajnasznote_match_tags = g:ajnasznote_match_tags + a:tags
endfunction

function! ajnasznote#rename_note()
  let l:title = luaeval('require("ajnasznote").to_safe_file_name(_A)', getline(1))
	if empty(l:title)
		return
	endif

	let l:matching_tag = s:get_matching_tag(g:ajnasznote_match_tags)

	if empty(l:matching_tag)
		let l:file_path = fnameescape(resolve(expand('%:h')))

		if empty(l:file_path)
			let l:file_path = expand(g:ajnasznote_directory)
		endif
	else
		let l:file_path = fnameescape(expand(printf('%s/%s', g:ajnasznote_directory, l:matching_tag)))
	endif

	if !exists(l:file_path)
		call mkdir(l:file_path, 'p')
	endif

	if !isdirectory(l:file_path)
		echoerr 'M004: Not a directory'
	endif

	let l:old_name = expand('%:p')
	let l:new_name = fnamemodify(printf('%s/%s.md', l:file_path, l:title), ':p')

	call luaeval('require("ajnasznote").move_note(_A[1], _A[2])', [l:old_name, l:new_name])
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
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
	let line = a:lines[0]
	let tail = matchstrpos(line, ":")
	let link = line[0:tail[1] - 1]
	let linked = fnamemodify(link, ':t')
	let current = expand('%:p:h')

	let p = luaeval('require("ajnasznote").handle_search(_A[1], _A[2], _A[3])', [link, current, line])

	exe 'normal! a['. linked .'](' . p . ')'
endfunction



function! ajnasznote#insert_note(pattern)
	call fzf#run(
				\ fzf#wrap({
				\ 'sink': function('ajnasznote#handle_search'),
				\ 'source': join([
					\ 'command',
					\ 'rg',
					\ '--follow',
					\ '--smart-case',
					\ '--line-number',
					\ '--color never',
					\ '--no-messages',
					\ '--no-heading',
					\ '--with-filename',
					\ a:pattern,
					\ '/home/ajnasz/Documents/Notes'
				\ ])}))
endfunction
