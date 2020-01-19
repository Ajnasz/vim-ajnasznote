if exists('g:loaded_ajnasznote')
	finish
endif

let g:loaded_ajnasznote = 1

if !exists('g:ajnasznote_directory')
	let g:ajnasznote_directory = '~/Notes'
endif

if !exists('g:ajnasznote_match_tags')
	let g:ajnasznote_match_tags = {}
endif
