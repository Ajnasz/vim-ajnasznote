(local notetag (require :ajnasznote.notetag))
(local gen_entry (require :ajnasznote.gen_entry))

(fn strip_md_from_title [title]
  (vim.fn.substitute title "^#\\+\\s*" "" ""))

(fn get_buf_title []
  (local notemeta (require :ajnasznote.notemeta))
  (let [ meta_title (notemeta.get_meta_title) ]
    (or meta_title (notemeta.get_h1))
    )
  )

(fn get_title [bufnr]
  (strip_md_from_title (get_buf_title (or bufnr 0))))

(fn get_note_title [path]
    (get_title (vim.fn.bufnr path true)) (vim.fn.fnamemodify path ":t"))

(fn remove_accent_chars [name]
  (let [chars {
               "á" "a"
               "é" "e"
               "í" "i"
               "ó" "o"
               "ö" "o"
               "ő" "o"
               "ú" "u"
               "ü" "u"
               "ű" "u"
               "Á" "A"
               "É" "E"
               "Í" "I"
               "Ó" "O"
               "Ö" "O"
               "Ő" "O"
               "Ú" "U"
               "Ü" "U"
               "Ű" "U"
               }]
    (var n name)
    (each [key char (pairs chars)]
      (set n (vim.fn.substitute n key char "g"))
      ) n)
  )
(fn remove_leading_char [char input]
  (if (= char (string.sub input 1 1))
    (remove_leading_char char (string.sub input 2))
    input))

(fn to_en_only_file_name [name]
  (string.lower
    (remove_leading_char
      "_"
      (string.gsub (remove_accent_chars name) "[^%a%d_-]+" "_"))))

(fn to_safe_file_name [name]
  (to_en_only_file_name name)
  ; (local str (require :ajnasznote.strings))
  ; (str.trim name)
  )

(fn get_rel_path [p]
  (let [current (vim.fn.expand "%:p:h")]
    ((. (require :pl.path) :relpath) p current)))

(fn get_link [p]
  (let [rel_path (get_rel_path p)]
    (string.format "[%s](%s)" (get_note_title p) rel_path)))

(fn insert_note [lines] (vim.cmd (string.format "normal! a%s" (get_link (. lines 1)))))

(fn buffer_get_commands []
  (accumulate
    [
     out []
     _ word (ipairs (vim.fn.split (notetag.get_tags) "\\s\\+"))
     ]
    (if (= (string.sub word 1 1) "+")
      (let [cmd_parts (vim.fn.split word ":")]
        (tset out (+ 1 (length out)) {:cmd (. cmd_parts 1) :args (. cmd_parts 2)})
        out)
      out)
    )
  )


(fn move_note [old_name_arg new_name_arg]
  (when (= "" new_name_arg) (vim.api.nvim_command "echoerr 'M006: Note name cannot be empty'"))
  (let [
        resolved_old_name (vim.fn.resolve old_name_arg)
        resolved_new_name (vim.fn.resolve new_name_arg)
        ]
    (when (not (= resolved_old_name resolved_new_name))
      (let [new_name ((. (require :ajnasznote.notename) :new) resolved_old_name resolved_new_name)]
        (if (= "" resolved_old_name) (vim.api.nvim_command (string.format "write %s" new_name))
          (do
            (pcall #(vim.api.nvim_command "bd"))
            (if (= 0 (vim.fn.rename resolved_old_name new_name))
              (do
                (vim.api.nvim_command (string.format "edit %s" new_name))
                (vim.api.nvim_command "filetype detect")
                )
              (vim.api.nvim_command "echoerr 'M003: Rename failed'")
              )))
        ))
    )
  )

(fn get_default_file_dir []
  (let [file_path (vim.fn.fnameescape (vim.fn.resolve (vim.fn.expand "%:h")))]
    (if (= file_path "")
      (vim.fn.expand vim.g.ajnasznote_directory)
      file_path))
  )

(fn get_note_dir []
  (let [tag_path (notetag.get_matching_tag vim.g.ajnasznote_match_tags)]
    (if tag_path
      (notetag.get_tag_path_file_dir tag_path)
      (get_default_file_dir))))

(fn mk_note_dir [dirname]
  (when (= 0 (vim.fn.exists dirname)) (vim.fn.mkdir dirname :p))
  (when (= 0 (vim.fn.isdirectory dirname)) (vim.api.nvim_command "M004: Not a directory")))

(fn get_new_file_name [bufnr]
  (let [title (to_safe_file_name (get_title bufnr))]
    (when (not (= title ""))
      (let [file_path (get_note_dir)]
        (when file_path
          (vim.fn.fnamemodify (string.format "%s/%s.md" file_path title) ":p")
          )))))

(fn rename_note []
  (let [new_name (get_new_file_name (vim.fn.bufnr ""))]
    (when new_name
      (do
        (mk_note_dir (get_note_dir))
        (move_note (vim.fn.expand "%:p") new_name)
        )))
  )


(fn create_note []
  (vim.cmd
    (string.format
      "edit %s/%s.md"
      (vim.fn.expand vim.g.ajnasznote_directory)
      (vim.fn.strftime "%Y-%m-%d_%H%M%s")
      )))

(fn exec_insert_note []
  ((. (require :telescope.builtin ) :live_grep)
    {
     :cwd vim.g.ajnasznote_directory
     ; :cmd "rg --line-number --column --color=always"
     :attach_mappings
     (fn [prompt_bufnr map]
       (map :i "<cr>"
            (fn []
              ((. (require :telescope.actions) :close) prompt_bufnr)
              (insert_note [(. ((. (require :telescope.actions.state) :get_selected_entry)) :path)])))
       true)
     }))

(fn note_explore []
  (vim.cmd (string.format "Lexplore %s" vim.g.ajnasznote_directory)))


(fn path_display [opts path]
  (local utils (require "telescope.utils"))
  (local tail (utils.path_tail path))
  (string.format "%s (%s)" tail path)
  )

(fn grep_in_notes []
  ((. (require :telescope.builtin) :live_grep)
    {
     :cwd vim.g.ajnasznote_directory
     ; :entry_maker gen_entry
     :disable_devicons true
     :disable_coordinates true
     ; :cmd "rg --line-number --column --color=always"
     }))

(fn find_links []
  ((. (require :telescope.builtin) :grep_string)
  {
     :cwd vim.g.ajnasznote_directory
     :use_regex true
     :search (.. "\\[[^]]*" (vim.fn.expand "%:t") "\\]\\([^)]+\\)")
   }
  ))

(fn remove_note [opts]
  (let [file_path (if (> (length (. opts :args)) 0) (. opts :args) (vim.fn.expand "%"))]
    (vim.uv.fs_unlink file_path))
    (vim.api.nvim_command "echo 'Note removed'")
    (vim.api.nvim_command "bd")
    )

(fn setup [config]
  (when (not vim.g.ajnasznote_directory)
    (set vim.g.ajnasznote_directory (. config "directory")))
  (when (not vim.g.ajnasznote_match_tags)
    (set vim.g.ajnasznote_match_tags (or (. config :match_tags) [])))

  (vim.api.nvim_create_user_command "NoteCreate" create_note {})
  (vim.api.nvim_create_user_command "NoteExplore" note_explore {})
  (vim.api.nvim_create_user_command "InsertLink" exec_insert_note {})
  (vim.api.nvim_create_user_command "NoteRemove" remove_note {})

  (vim.keymap.set "n" "<leader>nn" create_note {})

  (vim.keymap.set "n" "<leader><esc>" grep_in_notes {})
  (vim.keymap.set "n" "<leader>l" find_links {})

  (local augroup (vim.api.nvim_create_augroup "ajnasznote" {}))
  (vim.api.nvim_create_autocmd
    ["BufRead" "BufNewFile" "BufEnter"]
    {
     :group augroup
     :pattern [(.. vim.g.ajnasznote_directory "/*.md")]
     :command "set conceallevel=2 wrap lbr tw=80 wrapmargin=0 showbreak=\\\\n>"
     }
    )
  (vim.api.nvim_create_autocmd
    ["BufWritePost"]
    {
     :group augroup
     :pattern [(.. vim.g.ajnasznote_directory "/*.md")]
     :callback rename_note
     }
    )
  )

{
 :buffer_get_commands buffer_get_commands
 :rename_note rename_note
 :add_match_tags notetag.add_match_tags
 :create_note create_note
 :insert_note exec_insert_note
 :setup setup
 :get_title get_title
 :find_links find_links
 }
