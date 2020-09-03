scriptencoding utf-8
function! s:fix_filename(name)
	let l:name = a:name

	let l:chars = [
		\ ['á', 'a'],
		\ ['é', 'e'],
		\ ['í', 'i'],
		\ ['ó', 'o'],
		\ ['ö', 'o'],
		\ ['ő', 'o'],
		\ ['ú', 'u'],
		\ ['ü', 'u'],
		\ ['ű', 'u'],
		\ ['Á', 'A'],
		\ ['É', 'E'],
		\ ['Í', 'I'],
		\ ['Ó', 'O'],
		\ ['Ö', 'O'],
		\ ['Ő', 'O'],
		\ ['Ú', 'U'],
		\ ['Ü', 'U'],
		\ ['Ű', 'U'],
		\]

	for achar in l:chars
		let l:name = substitute(l:name, achar[0], achar[1], 'g')
	endfor

	return l:name
endfunction

function! s:generate_new_alt_note_name(old_name, new_name, count)
	let l:file_name = fnamemodify(a:new_name, ':t:r')
	let l:file_directory = fnamemodify(a:new_name, ':h')

	let l:formatted_new_name = resolve(printf('%s/%s_%d.md', l:file_directory, l:file_name, a:count))

	if l:formatted_new_name == a:new_name || !filereadable(l:formatted_new_name)
		return l:formatted_new_name
	endif

	if a:count > 10
		echoerr 'M002: Too many variations of file'
		return ''
	endif

	return s:generate_new_alt_note_name(a:old_name, a:new_name, a:count + 1)
endfunction

function! s:generate_new_name(old_name, new_name)
	" New file
	if !filereadable(a:new_name)
		return a:new_name
	endif

	return s:generate_new_alt_note_name(a:old_name, a:new_name, 1)
endfunction

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

	let l:new_name = s:generate_new_name(l:old_name, l:new_name)
	" let l:new_name = luaeval('require("ajnasznote").generate_new_note_name(_A[1], _A[2])', [l:old_name, resolve(a:new_name)])


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

function! s:buffer_get_tags()
	let l:tags = []
	let l:words = split(getline(3), '\s\+')

	for l:word in l:words
		if l:word[0] ==# '@'
			call add(l:tags, l:word)
		endif
	endfor

	return l:tags
endfunction

function! s:buffer_get_commands()
	let l:commands = []
	let l:words = split(getline(3), '\s\+')

	for l:word in l:words
		if l:word[0] ==# '+'
			let l:cmd_parts = split(word, ':')
			let l:cmd = {}
			let l:cmd['cmd'] = l:cmd_parts[0]
			let l:cmd['args'] = l:cmd_parts[1:]
			call add(l:commands, l:cmd)
		endif
	endfor

	return l:commands
endfunction

function! s:buffer_has_tag(tags, tag)
	for l:tag in a:tags
		if a:tag == l:tag
			return v:true
		endif
	endfor

	return v:false
endfunction

function! s:get_matching_tag(tags)
	let l:buffer_tags = s:buffer_get_tags()

	for l:match_tag in a:tags
		let l:pattern = l:match_tag['pattern']
		let l:has_all_tags = v:true
		let l:tags = []
		let l:pattern_type = type(l:pattern)

		if l:pattern_type == v:t_string
			let l:has_all_tags = s:buffer_has_tag(l:buffer_tags, l:pattern)
		elseif l:pattern_type == v:t_list
			let l:tags = l:pattern

			for l:tag in l:tags
				if !s:buffer_has_tag(l:buffer_tags, l:tag)
					let l:has_all_tags = v:false
					break
				endif
			endfor
		else
			echoerr 'M005: Invalid pattern'
		endif

		if l:has_all_tags
			return l:match_tag['path']
		endif
	endfor

	return ''
endfunction

function! ajnasznote#rename_note()
	let l:noramalized_name = s:fix_filename(getline(1))
	let l:title = tolower(substitute(substitute(l:noramalized_name, '[^A-Za-z0-9_-]\+', '_', 'g'), '^[^A-Za-z0-9]', '', ''))

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

	call s:move_note(l:old_name, l:new_name)
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
endfunction

function! ajnasznote#exec_doc_commands()
	let l:commands = s:buffer_get_commands()

	for l:custom_command in l:commands
		if l:custom_command['cmd'] ==# '+md_loadsyntax'
			let g:markdown_fenced_languages += l:custom_command['args']
		endif
	endfor
endfunction
