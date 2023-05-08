if exists('g:loaded_ajnasznote')
	finish
endif

let g:loaded_ajnasznote = 1

if !exists('g:ajnasznote_directory')
	let g:ajnasznote_directory = '~/Notes'
endif

if !exists('g:ajnasznote_match_tags')
	let g:ajnasznote_match_tags = []
endif

function! NoteCreate()
	call ajnasznote#create_note()
endfunction

function! NoteExplore()
	exec printf('Lexplore %s', g:ajnasznote_directory)
endfunction

augroup ajnasznote
	au!
	autocmd BufRead,BufNewFile,BufEnter */Notes/*.md call ajnasznote#exec_doc_commands()
	autocmd BufRead,BufNewFile,BufEnter */Notes/*.md set conceallevel=2 wrap lbr tw=80 wrapmargin=0 showbreak=\\n>
	au BufWritePost */Notes/*.md call ajnasznote#rename_note()
augroup end

command NoteCreate call NoteCreate()
command NoteExplore call NoteExplore()

command! -nargs=* -bang InsertLink call ajnasznote#insert_note()
      " \ call fzf#run(
      "     \ fzf#wrap({
      "         \ 'sink*': function('ajnasznote#handle_search'),
      "         \ 'source': join([
      "              \ 'command ',
      "              \ 'rg',
      "              \ '--follow',
      "              \ '--smart-case',
      "              \ '--line-number',
      "              \ '--color never',
      "              \ '--no-messages',
      "              \ '--no-heading',
      "              \ '--with-filename',
      "              \ ((<q-args> is '') ?
      "                \ '"\S"' :
      "                \ shellescape(<q-args>)),
      "              \ '/home/ajnasz/Documents/Notes',
      "              \ '2> /dev/null',
      "           \ ])
      "       \ },<bang>0))
