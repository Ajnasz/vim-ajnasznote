function! s:fix_filename(...)
	let l:name = a:1

	let l:chars = [['á', 'a'], ['é', 'e'], ['í', 'i'], ['ó', 'o'], ['ö', 'o'], ['ő', 'o'], ['ú', 'u'], ['ü', 'u'], ['ű', 'u'], ['Á', 'A'], ['É', 'E'], ['Í', 'I'], ['Ó', 'O'], ['Ö', 'O'], ['Ő', 'O'], ['Ú', 'U'], ['Ü', 'U'], ['Ű', 'U']]

	for achar in l:chars
		let l:name = substitute(l:name, achar[0], achar[1], 'g')
	endfor

	return l:name
endfunction

function! s:move_file(...)
	if a:0 != 2
		echoerr 'M001: Expected exactly two parameters'
	endif

	let l:oldName = resolve(a:1)
	let l:newName = resolve(a:2)

	if filereadable(l:newName) && filereadable(l:oldName)
		if l:oldName == l:newName
			return
		endif
	endif


	if (filereadable(l:newName))
		let l:fileName = fnamemodify(l:newName, ':t:r')
		let l:fileDirectory = fnamemodify(l:newName, ':h')
		let l:fileCount = 1
		while filereadable(l:newName)
			if l:fileCount > 10
				echoerr 'M002: Too many variations of file'
				return
			endif

			let l:fileCount = l:fileCount + 1

			let l:newName = resolve(printf('%s/%s_%d.md', l:fileDirectory, l:fileName, l:fileCount))
		endwhile

		execute(printf('write %s', l:newName))
	else
		if empty(l:oldName)
			exec printf('write %s', l:newName)
		else
			bd
			let renameSuccess = rename(l:oldName, l:newName)
			if renameSuccess == 0
				exec printf('edit %s', l:newName)
				doautocmd filetypedetect BufRead '%'
			else
				echoerr 'M003: Rename failed'
			endif
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

	let l:noramalizedName = s:fix_filename(getline(1))
	let l:title = tolower(substitute(substitute(l:noramalizedName, '[^A-Za-z0-9_-]\+', '_', 'g'), '^[^A-Za-z0-9]', '', ''))

	if empty(l:title)
		return
	endif

	let l:matching_tag = s:get_matching_tag(g:ajnasznote_match_tags)

	if !empty(l:matching_tag)
		let l:filePath = fnameescape(expand(printf('%s/%s', g:ajnasznote_directory, l:matching_tag)))
	else
		let l:filePath = fnameescape(resolve(expand('%:h')))

		if empty(l:filePath)
			let l:filePath = expand(g:ajnasznote_directory)
		endif
	endif

	if !exists(l:filePath)
		call mkdir(l:filePath, 'p')
	endif

	if !isdirectory(l:filePath)
		echoerr "M004: Not a directory"
	endif

	let l:oldName = expand('%:p')
	let l:newName = fnamemodify(printf('%s/%s.md', l:filePath, l:title), ':p')

	call s:move_file(l:oldName, l:newName)
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
endfunction
