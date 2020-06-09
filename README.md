# vim-ajnasznote

This plugin provides a few helper functions to manage notes

## Configuration

### g:ajnasznote_directory

Path to the direcotry where the notes going to be stored.

```viml
let g:ajnasznote_directory = '~/Notes'
```

### g:ajnasznote_match_tags

A dictionary where you can define if a note should be moved into subdirectory
in case the first 5 lines are matching to the key of the dict.
```viml
let g:ajnasznote_match_tags = [
	\ { 'pattern': '@important', 'path': 'important' },
	\ { 'pattern': '@personal', 'path': 'personal' }`
	\]
```

With the configuration above, if you add a tag called '@important' the note
will be moved into the "important" direcotry. If you add the tag '@personal' to
the 3th line the note will be moved into the "personal" subdirectory. If you
add both of the tags, the note will be moved into the one which matches first.

## Commands

### :NoteCreate

Creates a new file (calls the `ajnasznote#create_note` command)

### :NoteExplore

Opens the `g:ajnasznote_directory` with `:Lexplore` command

## Meta configuration

Add `+md_loadsyntax:sql:sh` to the 3. line to enable syntax highlihgt inside
markdown codeblocks. In the example it will be enabled for SQL and Shell codes.
Separate syntax names by a colon
