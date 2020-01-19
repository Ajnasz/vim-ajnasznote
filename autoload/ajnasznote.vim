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

	let l:oldName = a:1
	let l:newName = a:2

	if filereadable(l:newName) && filereadable(l:oldName)
		if l:oldName == l:newName
			return
		endif
	endif

	if (filereadable(l:newName))
		let l:file_count = 1
		while filereadable(l:newName)
			if l:file_count > 10
				echoerr 'M002: Too many variations of file'
				return
			endif

			let l:file_count = l:file_count + 1

			let l:newName = resolve(printf('%s/%s_%d.md', expand(g:ajnasznote_directory), l:title, l:file_count))
		endwhile

		execute(printf('write %s', l:newName))
	else
		if empty(l:oldName)
			exec printf('write %s', l:newName)
		else
			bd
			let isRenamed = rename(l:oldName, l:newName)
			if isRenamed == 0
				exec printf('edit %s', l:newName)
				doautocmd filetypedetect BufRead '%'
			else
				echoerr 'M003: Rename failed'
			endif
		endif
	endif
endfunction

function! ajnasznote#rename_note()
	let l:noramalizedName = s:fix_filename(getline(1))
	let l:title = tolower(substitute(substitute(l:noramalizedName, '[^A-Za-z0-9_-]\+', '_', 'g'), '^[^A-Za-z0-9]', '', ''))

	if empty(l:title)
		return
	endif

	let l:filePath = fnameescape(resolve(expand('%:h')))

	if empty(l:filePath)
		let l:filePath = expand(g:ajnasznote_directory)
	endif

	let l:oldName = expand('%:p')
	let l:newName = fnamemodify(printf('%s/%s.md', l:filePath, l:title), ':p')

	call s:move_file(l:oldName, l:newName)
endfunction

function! ajnasznote#create_note()
	let fname = strftime('%Y-%m-%d_%H%M%s')
	exec printf('edit %s/%s.md', expand(g:ajnasznote_directory), fname)
endfunction
