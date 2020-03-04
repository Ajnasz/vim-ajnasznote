scriptencoding utf-8

function! s:move_note(old_name, new_name)
	if empty(a:new_name)
		echoerr 'M006: Note name cannot be empty'
	endif

	let l:old_name = resolve(a:old_name)
	let l:new_name = resolve(a:new_name)
	" Same file
	if l:old_name == l:new_name
		return
	endif

	let l:new_name = luaeval('require("ajnasznote").generate_new_note_name(_A[1], _A[2])', [l:old_name, l:new_name])


	if empty(a:old_name)
		exec printf('write %s', l:new_name)
	else
		bd
		let rename_success = rename(a:old_name, l:new_name)

		if rename_success == 0
			exec printf('edit %s', l:new_name)
			filetype detect
		else
			echoerr 'M003: Rename failed'
		endif
	endif
endfunction

function! s:get_matching_tag(tags)
	return luaeval('require("ajnasznote").get_matching_tag(unpack(_A))', [a:tags])
endfunction

function! ajnasznote#rename_note()
	let l:noramalized_name = luaeval('require("ajnasznote").fix_filename(_A)', getline(1))
	let l:title = tolower(substitute(substitute(l:noramalized_name, '[^A-Za-z0-9_-]\+', '_', 'g'), '^[^A-Za-z0-9]', '', ''))

	if empty(l:title)
		return
	endif

	let l:matching_tag = luaeval('require("ajnasznote").get_matching_tag(unpack(_A))', [g:ajnasznote_match_tags])

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

	call s:move_note(l:old_name, l:new_name)
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
endfunction
