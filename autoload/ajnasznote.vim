function! s:fix_filename(...)
	let l:name = a:1

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

function! s:move_file(...)
	if a:0 != 2
		echoerr 'M001: Expected exactly two parameters'
	endif

	let l:old_name = resolve(a:1)
	let l:new_name = resolve(a:2)

	if filereadable(l:new_name) && filereadable(l:old_name)
		if l:old_name == l:new_name
			return
		endif
	endif

	if (filereadable(l:new_name))
		let l:file_name = fnamemodify(l:new_name, ':t:r')
		let l:file_directory = fnamemodify(l:new_name, ':h')
		let l:file_count = 1
		while filereadable(l:new_name)
			if l:file_count > 10
				echoerr 'M002: Too many variations of file'
				return
			endif

			let l:file_count = l:file_count + 1

			let l:new_name = resolve(printf('%s/%s_%d.md', l:file_directory, l:file_name, l:file_count))
		endwhile
	endif

	if empty(l:old_name)
		exec printf('write %s', l:new_name)
	else
		bd
		let rename_success = rename(l:old_name, l:new_name)
		if rename_success == 0
			exec printf('edit %s', l:new_name)
			doautocmd filetypedetect BufRead '%'
		else
			echoerr 'M003: Rename failed'
		endif
	endif
endfunction

function! s:buffer_has_tag(tag)
	let l:x = 1

	let l:match = '\<' . a:tag . '\>'

	while l:x < 5
		let l:line = getline(l:x)

		if (l:line =~ a:tag)
			return 1
		endif

		let l:x = l:x + 1
	endwhile

	return 0
endfunction

function! s:get_matching_tag(tags)
	for match_tag in a:tags
		if s:buffer_has_tag(match_tag['pattern'])
			return match_tag['path']
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

	if !empty(l:matching_tag)
		let l:file_path = fnameescape(expand(printf('%s/%s', g:ajnasznote_directory, l:matching_tag)))
	else
		let l:file_path = fnameescape(resolve(expand('%:h')))

		if empty(l:file_path)
			let l:file_path = expand(g:ajnasznote_directory)
		endif
	endif

	if !exists(l:file_path)
		call mkdir(l:file_path, 'p')
	endif

	if !isdirectory(l:file_path)
		echoerr "M004: Not a directory"
	endif

	let l:old_name = expand('%:p')
	let l:new_name = fnamemodify(printf('%s/%s.md', l:file_path, l:title), ':p')

	call s:move_file(l:old_name, l:new_name)
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
endfunction
