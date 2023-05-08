(local path (require :pl.path))
(local list (require "ajnasznote.list"))

(fn tolist [list] (if (= (type list) "table") list [list]))

(fn find_matching_tag [tags buffer_tags]
  (when (> (length tags) 0)
  (let [ pattern (. (. tags 1) :pattern) ]
    (list.find
      (fn [tag]
        (let [patterns (. tag :pattern)]
          (list.has_all (tolist patterns) buffer_tags)))
      tags))))

(fn get_tag_path [tags buffer_tags]
  (let [matching_tag (find_matching_tag tags buffer_tags)]
    (when matching_tag (. matching_tag "path"))))

(fn get_title []
  (vim.fn.substitute (vim.fn.getline 1) "^#\\+\\s*" "" ""))

(fn get_tags [] (vim.fn.getline 3))

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

(fn to_safe_file_name [name]
  (string.lower (remove_leading_char
    "_"
    (string.gsub (remove_accent_chars name) "[^%a%d_-]+" "_"))))

(fn generate_new_alt_note_name [old_name new_name count]
  (let [
        file_name (vim.fn.fnamemodify new_name ":t:r")
        file_directory (vim.fn.fnamemodify ":h")
        formatted_new_name (vim.fn.resolve (vim.fn.printf "%s/%s_%d.md") file_directory file_name count)
        ]

    (if (or (= formatted_new_name new_name) (vim.fn.filereadable formatted_new_name)) formatted_new_name

      (if (> count 10) (do (vim.api.nvim_command "echoerr 'M002: Too many variations of file'") "")
        (generate_new_alt_note_name old_name new_name (+ count 1)))
      )))

(fn generate_new_name [old_name new_name]
  (if vim.fn.filereadable new_name (do (generate_new_alt_note_name old_name new_name 1)) new_name))

(fn handle_search [lines]
  (let [
        line (. lines 1)
        x (print "line: " line)
        tail (vim.fn.matchstrpos line ":")
        link (string.sub line 1 (. tail 2))
        linked (vim.fn.fnamemodify link ":t")
        current (vim.fn.expand "%:p:h")
        p (path.relpath link current)
        ]
    (vim.cmd (vim.fn.printf "normal! a[%s](%s)" linked p))
    )
  )

(fn buffer_get_tags []
  (accumulate
    [
     out []
     _ word (ipairs (vim.fn.split (get_tags) "\\s\\+"))
     ]
    (if (= (string.sub word 1 1) "@")
      (do (tset out (+ 1 (length out)) word) out)
      out)
    )
  )

(fn buffer_get_commands []
  (accumulate
    [
     out []
     _ word (ipairs (vim.fn.split (get_tags) "\\s\\+"))
     ]
    (if (= (string.sub word 1 1) "+")
      (let [cmd_parts (vim.fn.split word ":")]
        (tset out (+ 1 (length out)) {:cmd (. cmd_parts 1) :args (. cmd_parts 2)})
        out)
      out)
    )
  )

(fn buffer_has_tag [tags tag]
  (var has_tag false)
  (each [_ ltag (ipairs tags) :until has_tag]
    (set has_tag (= tag ltag)))
  has_tag)


(fn move_note [old_name_arg new_name_arg]
  (when (= "" new_name) (vim.api.nvim_command "echoerr 'M006: Note name cannot be empty'"))
  (let [
        resolved_old_name (vim.fn.resolve old_name_arg)
        resolved_new_name (vim.fn.resolve new_name_arg)
        ]
    (when (not (= resolved_old_name resolved_new_name))
      (let [new_name (generate_new_name resolved_old_name resolved_new_name)]
        (if (= "" resolved_old_name) (vim.api.nvim_command (vim.fn.printf "write %s" new_name))
          (do
            (vim.api.nvim_command "bd")
            (if (= 0 (vim.fn.rename resolved_old_name new_name))
              (do
                (vim.api.nvim_command (vim.fn.printf "edit %s" new_name))
                (vim.api.nvim_command "filetype detect")
                )
              (vim.api.nvim_command "echoerr 'M003: Rename failed'")
              )))
          ))
      )
    )

(fn get_matching_tag [tags]
  (get_tag_path tags (buffer_get_tags)))

(fn get_default_file_dir []
  (let [file_path (vim.fn.fnameescape (vim.fn.resolve (vim.fn.expand "%:h")))]
  (if (= file_path "")
    (vim.fn.expand vim.g.ajnasznote_directory)
    file_path))
  )

(fn get_tag_path_file_dir [tag_path]
  (vim.fn.fnameescape (vim.fn.expand (vim.fn.printf "%s/%s" vim.g.ajnasznote_directory tag_path))))

(fn get_note_dir []
  (let [tag_path (get_matching_tag vim.g.ajnasznote_match_tags)]
    (if tag_path
      (get_tag_path_file_dir tag_path)
      (get_default_file_dir))))

(fn mk_note_dir [dirname]
  (when (= 0 (vim.fn.exists dirname)) (vim.fn.mkdir dirname :p))
  (when (= 0 (vim.fn.isdirectory dirname)) (vim.api.nvim_command "M004: Not a directory")))

(fn get_new_file_name []
  (let [title (to_safe_file_name (vim.fn.getline 1))]
    (when (not (= title ""))
      (let [file_path (get_note_dir)]
        (when file_path
          (vim.fn.fnamemodify (vim.fn.printf "%s/%s.md" file_path title) ":p")
          )))))

(fn rename_note []
  (let [new_name (get_new_file_name)]
    (when new_name
      (do
        (mk_note_dir (get_note_dir))
        (move_note (vim.fn.expand "%:p") new_name)
        ))))

(fn add_match_tags [tags]
  (when (not vim.g.ajnasznote_match_tags)
    (tset vim.g "ajnasznote_match_tags" []))
  (tset vim.g "ajnasznote_match_tags" (vim.list_extend vim.g.ajnasznote_match_tags tags)))


(fn create_note []
  (vim.cmd
    (vim.fn.printf
      "edit %s/%s.md"
      (vim.fn.expand vim.g.ajnasznote_directory)
      (vim.fn.strftime "%Y-%m-%d_%H%M%s")
      )))


(fn insert_note []
  (local fzf (require "fzf-lua"))
  (print "insert lua link")

  (fzf.fzf_live
    "rg --column --line-number --no-heading --color=always --smart-case <query> /home/ajnasz/Documents/Notes"
    { :actions { :default handle_search } })
  )

{
 :buffer_get_commands buffer_get_commands
 :rename_note rename_note
 :add_match_tags add_match_tags
 :create_note create_note
 :insert_note insert_note
 }
